; ===========================================================================
; ---------------------------------------------------------------------------
; Object 05 - Spin Dash Dust
; ---------------------------------------------------------------------------

SpinDust:
		tst.b	obRoutine(a0)				; has object already been initalized?
		bne.s	SpinDust_Main				; if yes, skip over

		addq.b	#2,obRoutine(a0)			; set dust as initalized
		move.l	#Map_SpinDust,obMap(a0)			; set sprite mapping location
		ori.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio1,obPriority(a0)			; set sprite priority to 1 (in front of Sonic)
		move.b	#32/2,obActWid(a0)			; set sprite display width to 32px
		move.w	#ArtTile_SpinDust,obGfx(a0)		; set VRAM location to $F400 (tile offset $7A0)

SpinDust_Main:
		lea	(v_player).w,a2				; load Sonic object to a2
		tst.b	spindash_flag(a2)			; is a Spin Dash currently active?
		beq.s	.hide					; if not, don't make dust
		btst	#1,obStatus(a2)				; is Sonic airborne?
		bne.s	.hide					; if yes, don't make dust
		cmpi.b	#4,obRoutine(a2)			; is Sonic hurt or dying?
		bhs.s	.hide					; if yes, don't make dust

		move.w	obX(a2),obX(a0)				; copy Sonic's X-position to the dust object
		move.w	obY(a2),obY(a0)				; copy Sonic's Y-position to the dust object
		moveq	#%00000111,d0				; make sure unrelated render modes are disabled
		and.b	obRender(a2),d0				; copy Sonic's render flags (X-flip, Y-flip, coordinate system)
		move.b	d0,obRender(a0)				; set new dust render flags

		btst	#0,(v_framebyte).w			; is this an odd frame?
		bne.s	.display				; if yes, don't advance animation (i.e. slow down by 50%)
		move.b	obFrame(a0),d0				; get current spin dust frame ID
		addq.b	#1,d0					; advance to next frame
		cmpi.b	#7,d0					; are we past the last frame now?
		blo.s	.ok					; if not, branch
		moveq	#0,d0					; reset to first frame
	.ok:	move.b	d0,obFrame(a0)				; set new frame ID

		lea	(DustDynPLC).l,a2			; load dust DPLC table
		move.w	#ArtTile_SpinDust*tile_size,d4		; starting VRAM tile
		move.l	#Art_SpinDust,d6			; base dust art pointer
		jsr	(LoadDynPLC).l				; update dust tiles in VRAM

	.display:
		jmp	(DisplaySprite).l			; display dust sprite

	.hide:
		rts						; don't display dust sprite

; ===========================================================================

		include	"_maps/SpinDust.asm"
		include	"_maps/SpinDust - Dynamic Gfx Script.asm"
