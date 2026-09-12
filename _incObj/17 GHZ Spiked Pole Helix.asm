; ===========================================================================
; ---------------------------------------------------------------------------
; Object 17 - rotating helix of spikes on a horizontal pole (GHZ)
; Heavily optimized by assuming it always has 16 spikes (256px).
; ---------------------------------------------------------------------------
helix_child:	equ objoff_30		; pointer to child helix, to the right of parent
helix_origX:	equ objoff_32		; initial X-position
; ---------------------------------------------------------------------------

Helix:
		move.l	#Hel_ParentSpike,obID(a0)		; advance to Hel_ParentSpike
		move.l	#Map_Hel,obMap(a0)			; set mappings
		move.w	#ArtTile_GHZ_Spike_Pole|Tile_Pal3,obGfx(a0) ; set art tile and palette (located inside main GHZ graphics)
		move.b	#sprite_cam_field,obRender(a0)		; set playfield-positioned mode
		move.w	#spr_prio3,obPriority(a0)		; set sprite priority
		move.b	#$130/2,obActWid(a0)			; set sprite display width
		move.b	#col_8x32|col_hurt,obColType(a0)	; make middle spike harmful

		move.w	obX(a0),helix_origX(a0)			; remember initial X-position
		subi.w	#256/2,obX(a0)				; shift helix to the left by half its size

		clr.w	helix_child(a0)				; make sure child index is 0 if it failed to load
		bsr.w	FindNextFreeObj				; find a free object after parent
		bne.s	Hel_ParentSpike				; if object RAM is full, branch
		move.w	a1,helix_child(a0)			; remember child location in RAM for parent

		move.l	#Hel_ChildSpike,obID(a1)		; load a second helix object for the child
		move.w	obX(a0),obX(a1)				; copy parent X-position
		addi.w	#256/2,obX(a1)				; move to the right (second set of 8 spikes)
		move.w	helix_origX(a0),helix_origX(a1)		; update base X-position
		addi.w	#256/2,helix_origX(a1)			; move to the right

		move.w	obY(a0),obY(a1)				; copy parent Y-position
		move.l	obMap(a0),obMap(a1)			; set mappings
		move.w	obGfx(a0),obGfx(a1)			; set art tile and palette (located inside main GHZ graphics)
		move.b	obRender(a0),obRender(a1)		; set playfield-positioned mode
		move.w	obPriority(a0),obPriority(a1)		; set sprite priority
		move.b	obActWid(a0),obActWid(a1)		; set sprite display width
		move.b	obColType(a0),obColType(a1)		; make middle spike harmful

; ---------------------------------------------------------------------------

Hel_ParentSpike:
		out_of_range.s	Hel_Delete,helix_origX(a0)	; has helix gone offscreen? if yes, delete it

Hel_ChildSpike:
		moveq	#7,d0					; limit to frames 0-7
		and.b	(v_ani0_frame).w,d0			; get current frame value from SynchroAnimate => Sync1
		move.b	d0,obFrame(a0)				; update current spike frame
		lsl.w	#4,d0					; multiply current frame by $10
		neg.w	d0					; make result negative
		add.w	helix_origX(a0),d0			; add initial X-position
		subi.w	#128/2,d0				; adjust to the left
		cmpi.b	#5,obFrame(a0)				; is frame 5-7 showing? (middle spike had to be wrapped)
		blo.s	.setX					; if not, branch
		addi.w	#128,d0					; wrap middle spike to the right
	.setX:	move.w	d0,obX(a0)				; update X-position so that the upright (damaging) spike is always cnetered

		DisplaySprite					; display 8 spikes
		rts
; ===========================================================================

Hel_Delete:
		move.w	helix_child(a0),d0			; get child object
		beq.s	.deleteParent				; if it doesn't have a child, branch
		movea.w	d0,a1					; load child into address register
		bsr.w	DeleteChild				; delete child

	.deleteParent:
		bra.w	DeleteObject				; delete parent

; ===========================================================================

Map_Hel:	include	"_maps/Spiked Pole Helix.asm"
