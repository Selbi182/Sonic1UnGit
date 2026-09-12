; ===========================================================================
; ---------------------------------------------------------------------------
; Object 12 - spinning light in hexagonal glass prism (SYZ)
; ---------------------------------------------------------------------------

SpinningLight:
		move.l	#Light_Animate,obID(a0)			; advance to Light_Animate
		move.l	#Map_Light,obMap(a0)			; set mappings
		move.w	#ArtTile_Level,obGfx(a0)		; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#32/2,obActWid(a0)			; set display width
		move.w	#spr_prio6,obPriority(a0)		; set very low sprite priority
; ---------------------------------------------------------------------------

Light_Animate:	; Routine 2
		subq.b	#1,obTimeFrame(a0)			; decrement time delay until next frame
		bpl.s	.chkdel					; if time remains, branch
		move.b	#8-1,obTimeFrame(a0)			; reset time delay to 8 frames
		addq.b	#1,obFrame(a0)				; advance to next frame ID
		cmpi.b	#6,obFrame(a0)				; has it reached frame ID 6?
		blo.s	.chkdel					; if not, branch
		clr.b	obFrame(a0)				; reset back to frame 0

	.chkdel:
		RememberStateXY
		rts
; ===========================================================================

Map_Light	include	"_maps/Light.asm"
