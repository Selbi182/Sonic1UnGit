BubbleParticle:
		
		move.b	obRoutine(a0),d0
		bne.s	BubPar_Inflate

BubbleParticle_Init:
		addq.b	#2,obRoutine(a0)			; advance to BubPar_Inflate
		move.l	#Map_Bub,obMap(a0)			; set mappings
		move.w	#ArtTile_LZ_Bubbles|Tile_Prio,obGfx(a0)	; set art tile and priority flag
		move.b	#sprite_rendered|sprite_cam_field,obRender(a0) ; set to playfield-positioned mode and set rendered flag (avoid immediate deletion)
		move.b	#32/2,obActWid(a0)			; set sprite display width
		move.w	#spr_prio1,obPriority(a0)			; set sprite priority (above Sonic)

		move.b	obSubtype(a0),obAnim(a0)				; set bubble size from subtype (0 = small, 1 = medium, 2 = large)
		move.w	obX(a0),bub_origX(a0)			; remember original X-position
	;	move.w	#-$88,obVelY(a0)			; slowly float bubble upwards
		jsr	(RandomNumber).l			; get a random number
		move.b	d0,obAngle(a0)				; set random start angle for wobble effect
; ---------------------------------------------------------------------------

BubPar_Inflate:	; Routine 2
		subq.b	#4,d0
		beq.s	BubPar_ChkWater
		lea	(Ani_Bub).l,a1				; all animation scripts for individual bubbles increase obRoutine on finish
		jsr	(AnimateSprite).l			; (i.e. they advance to BubPar_ChkWater)

; ---------------------------------------------------------------------------

BubPar_ChkWater:	; Routine 4
		tst.b	obRender(a0)				; has bubble gone offscreen?
		bpl.s	BubPar_Delete					; if yes, delete it

		move.w	(v_waterpos1).w,d0			; get current water height including surface sway
		cmp.w	obY(a0),d0				; is bubble still underwater?
		bhs.s	BubPar_Delete					; if yes, branch

		move.b	obAngle(a0),d0				; get current wobble angle
		addq.b	#1,obAngle(a0)				; increment next wobble angle
		andi.w	#$7F,d0					; limit wobble angle to $80 positions
		lea	(Drown_WobbleData).l,a1			; load wobble offset array
		move.b	(a1,d0.w),d0				; read wobble offset for current angle
		ext.w	d0					; make word-based
		add.w	bub_origX(a0),d0			; add base X-position
		move.w	d0,obX(a0)				; set change bubble's X-position with wobble offset

		add.l	#-$8800,obY(a0)				; add Y speed to Y position (note this affects the subpixel position)

		move.w	#$80,d0
		DisplaySprite_direct
		rts
; ===========================================================================

BubPar_Delete:
		bra.w	DeleteObject				; delete bubble