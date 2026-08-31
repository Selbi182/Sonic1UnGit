; ===========================================================================
; ---------------------------------------------------------------------------
; Object 44 - edge walls (GHZ)
; ---------------------------------------------------------------------------

EdgeWalls:
		move.l	#Edge_Solid,obID(a0)			; advance to Edge_Solid
		move.l	#Map_Edge,obMap(a0)			; load mappings
		move.w	#ArtTile_GHZ_Edge_Wall|Tile_Pal3,obGfx(a0) ; load art tile and palette line
		ori.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#16/2,obActWid(a0)			; set sprite display width
		move.w	#spr_prio6,obPriority(a0)		; set sprite priority (very low)

		move.b	obSubtype(a0),obFrame(a0)		; copy object type number to frame number
		bclr	#4,obFrame(a0)				; clear 4th bit (deduct $10)
		beq.s	Edge_Solid				; make object solid if 4th bit = 0
		move.l	#Edge_Display,obID(a0)			; advance to Edge_Display for non-solid cosmetic-only walls
; ---------------------------------------------------------------------------

Edge_Display:	; Routine 4
		out_of_range.w	DeleteObject
		DisplaySprite
		rts
; ===========================================================================

Edge_Solid:	; Routine 2
		out_of_range.w	DeleteObject
		DisplaySprite

; EdgeWall_SolidWall:
		moveq	#38/2,d1				; set collision detection width
		moveq	#80/2,d2				; set collision detection height

		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0				; d0: +ve if Sonic is right; -ve if Sonic is left
		add.w	d1,d0					; add width of object
		bmi.w	.no_collision				; branch if Sonic is outside left boundary
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	.no_collision				; branch if Sonic is outside right boundary

		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2					; add obHeight to stated height
		move.w	obY(a1),d3
		sub.w	obY(a0),d3				; d3: +ve if Sonic is below; -ve if Sonic is above
		add.w	d2,d3					; add total height of object
		bmi.s	.no_collision				; branch if Sonic is outside upper boundary
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.s	.no_collision				; branch if Sonic is outside lower boundary

		tst.b	(f_playerctrl).w			; are controls locked?
		bmi.s	.no_collision				; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w		; is Sonic dying?
		bhs.s	.no_collision				; if yes, branch
		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.s	.no_collision				; if yes, branch
		move.w	d0,d5
		cmp.w	d0,d1					; is Sonic right of centre of object?
		bhs.s	.isright				; if yes, branch
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

	.isright:
		move.w	d3,d1
		cmp.w	d3,d2					; is Sonic below centre of object?
		bhs.s	.isbelow				; if yes, branch
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

	.isbelow:
		cmp.w	d1,d5
		bhi.s	.topbottom
; ---------------------------------------------------------------------------

.side_collision:
		tst.w	d0					; where is Sonic?
		beq.w	.centre					; if inside the object, branch
		bmi.s	.right					; if right of the object, branch
		tst.w	obVelX(a1)				; is Sonic moving left?
		bmi.s	.centre					; if yes, branch
		bra.s	.left
; ===========================================================================

.right:
		tst.w	obVelX(a1)				; is Sonic moving right?
		bpl.s	.centre					; if yes, branch

.left:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)				; stop Sonic moving

.centre:
		btst	#1,obStatus(a1)				; is Sonic in the air?
		bne.s	.air					; if yes, branch
		bset	#5,obStatus(a1)				; make Sonic push object
		bset	#5,obStatus(a0)				; make object be pushed
		rts
; ===========================================================================

.no_collision:
		btst	#5,obStatus(a0)				; is Sonic pushing?
		beq.s	.exit					; if not, branch

.air:
		bclr	#5,obStatus(a0)				; clear pushing flag
		bclr	#5,obStatus(a1)				; clear Sonic's pushing flag

	.exit:
		rts
; ===========================================================================

.topbottom:
		tst.w	obVelY(a1)				; is Sonic moving downwards?
		bpl.s	.exit2					; if yes, branch
		tst.w	d3					; is Sonic above the object?
		bpl.s	.exit2					; if yes, branch
		sub.w	d3,obY(a1)				; correct Sonic's position
		move.w	#0,obVelY(a1)				; stop Sonic moving

	.exit2:
		rts
; End of function EdgeWall_SolidWall
; ===========================================================================

Map_Edge:	include	"_maps/GHZ Edge Walls.asm"

