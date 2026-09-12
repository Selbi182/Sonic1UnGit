; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3C - smashable wall (GHZ, SLZ)
; ---------------------------------------------------------------------------
smash_speed:	equ objoff_30		; backup of Sonic's horizontal speed before hitting the wall
smash_posX:	equ objoff_32		; backup of Sonic's X-position before hitting the wall
; ---------------------------------------------------------------------------

SmashWall:
		move.l	#Smash_Solid,obID(a0)
		move.l	#Map_Smash,obMap(a0)			; set mappings
		move.w	#ArtTile_GHZ_SLZ_Smashable_Wall|Tile_Pal3,obGfx(a0) ; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.b	#32/2,obActWid(a0)			; set sprite display width
		move.w	#spr_prio4,obPriority(a0)		; set sprite
		move.b	obSubtype(a0),obFrame(a0)		; set frame ID from subtype (0 = left // 1 = middle // 2 = right)
; ---------------------------------------------------------------------------

Smash_Solid:	; Routine 2
		move.w	(v_player+obVelX).w,smash_speed(a0)	; remember Sonic's speed before calling SolidObject (because it can change it)
		move.w	(v_player+obX).w,smash_posX(a0)		; remember Sonic's X-position before calling SolidObject (because it can change it)

		move.w	#32/2+sonic_solid_width,d1
		move.w	#64/2,d2
		move.w	#64/2,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject				; check collision with Sonic and wall
		cmpi.b	#1,d4
		beq.s	.chkroll
		btst	#5,obStatus(a0)				; is Sonic pushing against the wall?
		bne.s	.chkroll				; if yes, branch

	.return:
		RememberStateXY
		rts
; ===========================================================================

.chkroll:
		tst.b	doublejump(a1)				; jump dash active?
		bne.s	.doSmash				; if yes, smash

		cmpi.b	#id_Roll,obAnim(a1)			; is Sonic rolling?
		bne.w	.return					; if not, don't smash

		move.w	smash_speed(a0),d0			; get Sonic's impact speed
		bpl.s	.chkspeed				; if positive, branch
		neg.w	d0					; make it positive for check
	.chkspeed:
		cmpi.w	#$480,d0				; was Sonic's impact speed $480 or higher?
		blo.w	.return					; if not, don't smash

.doSmash:
		move.w	smash_speed(a0),obVelX(a1)		; restore Sonic's speed before SolidObject got called
		move.w	smash_posX(a0),obX(a1)			; restore Sonic's X-position before SolidObject got called

		lea	(Smash_FragSpd1).l,a4			; use fragments that move right
		move.w	obX(a0),d0				; get wall's X-position
		cmp.w	obX(a1),d0				; has Sonic smashed the wall from the left?
		blo.s	.smash					; if yes, branch
		lea	(Smash_FragSpd2).l,a4			; use fragments that move left

	.smash:
		move.w	obVelX(a1),obInertia(a1)		; copy speed before impact to Sonic's ground speed
		bclr	#5,obStatus(a0)				; clear wall's pushed flag
		bclr	#5,obStatus(a1)				; clear Sonic's pushing flag

		moveq	#8-1,d1					; set number of fragments to load to 8 (number of sprite pieces in wall)
		move.l	#(gravity*2)<<8,d2			; set counter-gravity
		bsr.w	SmashObject				; smash the block into four fragment objects (set to routine 4, Smash_Fragment)
		bra.w	Particle_MovingFragment

; ===========================================================================
; Smashed block fragment speeds used by GHZ smashable walls
; (x-move speed, y-move speed)

Smash_FragSpd1:	; breaking wall from the left
		dc.w  $400, -$500
		dc.w  $600, -$100
		dc.w  $600,  $100
		dc.w  $400,  $500
		dc.w  $600, -$600
		dc.w  $800, -$200
		dc.w  $800,  $200
		dc.w  $600,  $600

Smash_FragSpd2:	; breaking wall from the right
		dc.w -$600, -$600
		dc.w -$800, -$200
		dc.w -$800,  $200
		dc.w -$600,  $600
		dc.w -$400, -$500
		dc.w -$600, -$100
		dc.w -$600,  $100
		dc.w -$400,  $500
; ===========================================================================

Map_Smash:	include	"_maps/Smashable Walls.asm"
