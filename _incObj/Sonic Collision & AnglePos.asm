; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	calculate distance from Sonic to the wall in front of him
; 
; input:
;	d0 = Sonic's floor angle rotated 90 degrees (i.e. angle of wall ahead)
; 
; output:
;	d1 = distance to wall
; ---------------------------------------------------------------------------

; Sonic_WalkSpeed: <-- old misnomer
Sonic_CalcRoomAhead:
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3					; d3 = predicted x pos. at next frame
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2					; d2 = predicted y pos. at next frame
		swap	d2
		swap	d3
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer2).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	.floor_or_left				; branch if angle is floor or left vertical
		move.b	d1,d0
		bpl.s	.angle_pos
		subq.b	#1,d0

	; loc_14D14:
	.angle_pos:
		addi.b	#$20,d0
		bra.s	.find_wall
; ===========================================================================

; loc_14D1A:
.floor_or_left:
		move.b	d1,d0
		bpl.s	.angle_pos_
		addq.b	#1,d0

	; loc_14D20:
	.angle_pos_:
		addi.b	#$1F,d0

; loc_14D24:
.find_wall:
		andi.b	#$C0,d0
		beq.w	Sonic_FindFloor_Quick
		cmpi.b	#$80,d0
		beq.w	Sonic_FindCeiling_Quick
		andi.b	#$38,d1
		bne.s	.find_wall_lr
		addq.w	#8,d2
		btst	#2,obStatus(a0)				; is Sonic rolling?
		beq.s	.find_wall_lr				; if not, branch
		subq.w	#5,d2					; if so, move push sensor up a bit

	; loc_14D3C:
	.find_wall_lr:
		cmpi.b	#$40,d0
		beq.w	Sonic_FindWallLeft_Quick
		bra.w	Sonic_FindWallRight_Quick
; End of function Sonic_CalcRoomAhead

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	calculate distance from Sonic's head to the ceiling
; 
; input:
;	d0 = Sonic's floor angle inverted
; 
; output:
;	d1 = distance to ceiling
; ---------------------------------------------------------------------------

; sub_14D48:
Sonic_CalcHeadroom:
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer2).w
		addi.b	#$20,d0
		andi.b	#$C0,d0					; read only bits 6 and 7 of angle
		cmpi.b	#$40,d0					; is Sonic on a left-facing wall?
		beq.w	Sonic_FindWallLeft			; ceiling is to the left
		cmpi.b	#$80,d0					; is Sonic on the ground?
		beq.w	Sonic_FindCeiling			; ceiling is directly above
		cmpi.b	#$C0,d0					; is Sonic on a right-facing wall?
		beq.w	Sonic_FindWallRight			; ceiling is to the right
; End of function Sonic_CalcHeadroom

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to floor
; 
; output:
;	d0 = distance to floor (larger if on a slope)
;	d1 = distance to floor (smaller if on a slope)
;	d3 = floor angle
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; Sonic_HitFloor: <-- old misnomer
Sonic_FindFloor:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos. of Sonic's bottom edge
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos. of Sonic's right edge
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor
		move.w	d4,-(sp)
		move.w	d1,-(sp)				; save d1 (distance to floor) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos. of Sonic's bottom edge
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos. of Sonic's left edge
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor				; d1 = distance to floor left side
		move.w	(sp)+,d0				; d0 = distance to floor right side
		move.w	(sp)+,d5
		move.b	#0,d2

; loc_14DD0:
Sonic_FindSmaller:
		move.b	(v_anglebuffer2).w,d3
		cmp.w	d0,d1					; compare the output distances
		ble.s	.no_swap				; branch if d0 > d1
		move.b	(v_anglebuffer).w,d3
		exg	d0,d1					; d1 is always the smaller distance
		exg.l	d5,d4

	; loc_14DDE:
	.no_swap:
		btst	#0,d3					; is bit 0 of angle set?
		beq.s	.no_angle_snap				; if not, branch
		move.b	d2,d3					; clear d3 (this is copied to ost_angle)

	; locret_14DE6:
	.no_angle_snap:
		rts
; End of function Sonic_FindFloor

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to floor, no width/height checks
; 
; input:
;	d2 = y position of Sonic
;	d3 = x position of Sonic
; 
; output:
;	d1 = distance to floor
;	d3 = floor angle
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

Sonic_FindFloor_Quick_UsePos: ; not called from anywhere
		move.w	obY(a0),d2				; unused
		move.w	obX(a0),d3				; unused

; loc_14DF0:
Sonic_FindFloor_Quick:
		addi.w	#sonic_quick_size,d2
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindFloor
		move.b	#0,d2

; loc_14E0A:
Sonic_SnapAngle:
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	.no_angle_snap				; branch if bit 0 of angle is clear
		move.b	d2,d3					; snap angle to 0, $40, $80 or $C0

	; locret_14E16:
	.no_angle_snap:
		rts
; End of function Sonic_FindFloor_Quick


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to right wall when Sonic is moving vertically
; 
; output:
;	d0 = distance to wall (larger if on a slope)
;	d1 = distance to wall (smaller if on a slope)
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; sub_14E50:
Sonic_FindWallRight:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos. of Sonic's upper edge (his left/right)
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos. of Sonic's rightmost edge (his feet/head)
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall
		move.w	d4,-(sp)
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos. of Sonic's lower edge (his right/left)
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos. of Sonic's rightmost edge (his feet/head)
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall				; d1 = distance to wall upper side
		move.w	(sp)+,d0				; d0 = distance to wall lower side
		move.w	(sp)+,d5

		move.b	#$C0,d2
		bra.w	Sonic_FindSmaller			; make d1 the smaller distance
; End of function Sonic_FindWallRight

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to right wall when moving vertically,
; no width/height checks
; 
; input:
;	d2 = y position of Sonic (Sonic_FindWallRight_Quick only)
;	d3 = x position of Sonic (Sonic_FindWallRight_Quick only)
; 
; output:
;	d1 = distance to wall
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; sub_14EB4:
Sonic_FindWallRight_Quick_UsePos:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

; loc_14EBC:
Sonic_FindWallRight_Quick:
		addi.w	#sonic_quick_size,d3
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	Sonic_SnapAngle				; check for snap to 90 degrees
; End of function Sonic_FindWallRight_Quick

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the wall to its right.
; Runs FindWall without the need for inputs, using object RAM instead.
; 
; input:
;	d3.w = x radius of object, right side
; 
; output:
;	d1.w = distance to the wall
;	d3.b = wall angle
;	a1 = address within 256x256 mappings where object is standing
;	(a1).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = wall angle
; ---------------------------------------------------------------------------

; FindWallRightObj:
ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(v_anglebuffer).w,a4			; write angle here
		move.b	#0,(a4)
		movea.w	#$10,a3					; width of a 16x16 tile
		move.w	#0,d6
		moveq	#$E,d5					; bit to test for solidness
		bsr.w	FindWall
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$C0,d3					; snap to flat right wall

	; locret_14F06:
	.no_snap:
		rts
; End of function ObjHitWallRight

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to ceiling, used to prevent Sonic from
; running on walls and ceilings when he touches them
; 
; output:
;	d0 = distance to ceiling (larger if on a slope)
;	d1 = distance to ceiling (smaller if on a slope)
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; Sonic_DontRunOnWalls: <-- old misnomer
Sonic_FindCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos. of Sonic's top edge
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos. of Sonic's right edge
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$1000,d6				; yflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindFloor
		move.w	d4,-(sp)
		move.w	d1,-(sp)				; save d1 (distance to ceiling) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos. of Sonic's top edge
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos. of Sonic's left edge
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$1000,d6				; yflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindFloor				; d1 = distance to ceiling on left side
		move.w	(sp)+,d0				; d0 = distance to ceiling on right side
		move.w	(sp)+,d5

		move.b	#$80,d2
		bra.w	Sonic_FindSmaller			; make d1 the smaller distance
; End of function Sonic_FindCeiling

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to ceiling, no width/height checks
; 
; input:
;	d2 = y position of Sonic
;	d3 = x position of Sonic
; 
; output:
;	d1 = distance to ceiling
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

Sonic_FindCeiling_Quick_UsePos: ; not called from anywhere
		move.w	obY(a0),d2				; unused
		move.w	obX(a0),d3				; unused

; loc_14F7C:
Sonic_FindCeiling_Quick:
		subi.w	#sonic_quick_size,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$1000,d6				; yflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindFloor
		move.b	#-$80,d2
		bra.w	Sonic_SnapAngle				; check for snap to 90 degrees
; End of function Sonic_FindCeiling_Quick

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the ceiling.
; Runs FindFloor without the need for inputs, using object RAM instead.
; 
; output:
;	d1.w = distance to the ceiling
;	d3.b = ceiling angle
;	a1 = address within 256x256 mappings where object is standing
;	(a1).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = ceiling angle
; ---------------------------------------------------------------------------

; FindCeilingObj:
ObjHitCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; height of a 16x16 tile
		move.w	#$1000,d6				; eor mask
		moveq	#$E,d5					; bit to test for solidness
		bsr.w	FindFloor
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$80,d3					; snap to flat ceiling

	; locret_14FD4:
	.no_snap:
		rts
; End of function ObjHitCeiling

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to find distance to left wall when Sonic is moving vertically
; 
; output:
;	d0 = distance to wall (larger if on a slope)
;	d1 = distance to wall (smaller if on a slope)
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; loc_14FD6:
Sonic_FindWallLeft:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos. of Sonic's upper edge (his left/right)
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos. of Sonic's leftmost edge (his feet/head)
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$800,d6				; xflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall
		move.w	d4,-(sp)
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos. of Sonic's lower edge (his right/left)
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos. of Sonic's leftmost edge (his feet/head)
		eori.w	#$F,d3
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$800,d6				; xflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall				; d1 = distance to wall lower side
		move.w	(sp)+,d0				; d0 = distance to wall upper side
		move.w	(sp)+,d5

		move.b	#$40,d2
		bra.w	Sonic_FindSmaller			; make d1 the smaller distance
; End of function Sonic_FindWallLeft

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	find distance to left wall when moving vertically,
; no width/height checks
; 
; input:
;	d2 = y position of Sonic (Sonic_FindWallLeft_Quick only)
;	d3 = x position of Sonic (Sonic_FindWallLeft_Quick only)
; 
; output:
;	d1 = distance to wall
;	a1 = address within 256x256 mappings where Sonic is standing
;	(a1) = 16x16 tile number
;	(a4) = floor angle
; ---------------------------------------------------------------------------

; Sonic_HitWall: <-- old misnomer
Sonic_FindWallLeft_Quick_UsePos:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

; loc_1504A:
Sonic_FindWallLeft_Quick:
		subi.w	#sonic_quick_size,d3
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$800,d6				; xflip tile
		moveq	#$E,d5					; bit to test for solidness (left/right/bottom solid)
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	Sonic_SnapAngle				; check for snap to 90 degrees
; End of function Sonic_FindWallLeft_Quick

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the wall to its left
; Runs FindWall without the need for inputs, taking inputs from local OST variables
; 
; input:
;	d3.w = x radius of object, left side (negative)
; 
; output:
;	d1.w = distance to the wall
;	d3.b = wall angle
;	a1 = address within 256x256 mappings where object is standing
;	(a1).w = 16x16 tile number, x/yflip, solidness
;	(a4).b = wall angle
; ---------------------------------------------------------------------------

; FindWallLeftObj:
ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4			; write angle here
		move.b	#0,(a4)
		movea.w	#-$10,a3				; width of a 16x16 tile
		move.w	#$800,d6				; eor mask
		moveq	#$E,d5					; bit to test for solidness
		bsr.w	FindWall
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3					; is angle snap bit set?
		beq.s	.no_snap
		move.b	#$40,d3					; snap to flat left wall

	; locret_15098:
	.no_snap:
		rts
; End of function ObjHitWallLeft



; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

Sonic_AnglePos:
		btst	#3,obStatus(a0)
		beq.s	.not_on_platform			; branch if Sonic isn't on a platform
		moveq	#0,d0
		move.b	d0,(v_anglebuffer).w			; clear angle hotspots
		move.b	d0,(v_anglebuffer2).w
		rts
; ===========================================================================

; loc_14602:
.not_on_platform:
		moveq	#3,d0
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer2).w
		move.b	obAngle(a0),d0				; get last angle
		addi.b	#$20,d0
		bpl.s	.floor_or_left				; branch if angle is (generally) flat or left vertical
		move.b	obAngle(a0),d0
		bpl.s	.angle_pos				; branch if angle is between $60 and $7F
		subq.b	#1,d0					; subtract 1 if $80-$DF

	; loc_1461E:
	.angle_pos:
		addi.b	#$20,d0					; d0 = angle + ($1F or $20)
		bra.s	.chk_surface
; ===========================================================================

; loc_14624:
.floor_or_left:
		move.b	obAngle(a0),d0
		bpl.s	.angle_pos_				; branch if angle is between 0 and $60
		addq.b	#1,d0					; add 1 if $E0-$FF

	; loc_1462C:
	.angle_pos_:
		addi.b	#$1F,d0					; d0 = angle + ($1F or $20)

; loc_14630:
.chk_surface:
		andi.b	#$C0,d0					; read only bits 6-7 of angle
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL				; branch if on left vertical
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling			; branch if on ceiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR				; branch if on right vertical

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of bottom edge of Sonic
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of right edge of Sonic
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor
		move.w	d1,-(sp)				; save d1 (distance to floor) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of bottom edge of Sonic
		move.b	obWidth(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3					; d3 = x pos of left edge of Sonic
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#$10,a3					; tile height
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor				; d1 = distance to floor left side
		move.w	(sp)+,d0				; d0 = distance to floor right side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_floor				; branch if Sonic is 0px from floor
		bpl.s	.above_floor				; branch if Sonic is above floor
		cmpi.w	#-$E,d1
		blt.s	Sonic_BelowFloor			; branch if Sonic is > 14px below floor
		add.w	d1,obY(a0)				; align to floor

	; locret_146BE:
	.on_floor:
		rts
; ===========================================================================

; loc_146C0:
.above_floor:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px above floor

; loc_146C6:
.on_disc:
		add.w	d1,obY(a0)				; align to floor
		rts
; ===========================================================================

; loc_146CC:
.in_air:
		tst.b	sticktoconvex(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation
		rts
; ===========================================================================

; locret_146E6:
Sonic_BelowFloor:
		rts

; ===========================================================================
		; dead code
		move.l	obX(a0),d2
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,obX(a0)
		move.w	#gravity,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts
; ===========================================================================

; locret_1470A:
Sonic_InsideWall:
		rts

; ===========================================================================
		; dead code
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		subi.w	#gravity,d0
		move.w	d0,obVelY(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		rts
		rts

; ===========================================================================
		; dead code
		move.l	obX(a0),d2
		move.l	obY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,obX(a0)
		move.l	d3,obY(a0)
		rts
; End of function Sonic_AnglePos

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's angle
; 
; input:
;	d0 = distance to floor right side
;	d1 = distance to floor left side
; 
; output:
;	d1 = shortest distance to floor (either side)
;	d2 = angle
; ---------------------------------------------------------------------------

Sonic_Angle:
		move.b	(v_anglebuffer2).w,d2			; use left side angle
		cmp.w	d0,d1
		ble.s	.left_nearer				; branch if floor is nearer on left side
		move.b	(v_anglebuffer).w,d2			; use right side angle
		move.w	d0,d1					; use distance of right side

	; loc_1475E:
	.left_nearer:
		btst	#0,d2
		bne.s	.snap_angle				; branch if bit 0 of angle is set
		move.b	d2,obAngle(a0)				; update angle
		rts
; ===========================================================================

; loc_1476A:
.snap_angle:
		move.b	obAngle(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2					; snap to nearest 90 degree angle
		move.b	d2,obAngle(a0)				; update angle
		rts
; End of function Sonic_Angle

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to his right
; ---------------------------------------------------------------------------

Sonic_WalkVertR:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2					; d2 = y pos of upper edge of Sonic (i.e. his front or back)
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#$10,a3					; tile width
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindWall
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of lower edge of Sonic (i.e. his front or back)
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#$10,a3					; tile width
		move.w	#0,d6
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindWall				; d1 = distance to wall lower side
		move.w	(sp)+,d0				; d0 = distance to wall upper side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_wall				; branch if Sonic is 0px from wall
		bpl.s	.outside_wall				; branch if Sonic is outside wall
		cmpi.w	#-$E,d1
		blt.w	Sonic_InsideWall			; branch if Sonic is > 14px inside wall
		add.w	d1,obX(a0)				; align to wall

	; locret_147F0:
	.on_wall:
		rts
; ===========================================================================

; loc_147F2:
.outside_wall:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px outside wall

; loc_147F8:
.on_disc:
		add.w	d1,obX(a0)				; align to wall
		rts
; ===========================================================================

; loc_147FE:
.in_air:
		tst.b	sticktoconvex(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation
		rts
; End of function Sonic_WalkVertR

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

Sonic_WalkCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge of Sonic (i.e. his feet)
		eori.w	#$F,d2					; add some amount
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3					; d3 = x pos of right edge of Sonic
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$1000,d6				; yflip tile
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor
		move.w	d1,-(sp)				; save d1 (distance to ceiling) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of top edge of Sonic (i.e. his feet)
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of left edge of Sonic
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#-$10,a3				; tile height
		move.w	#$1000,d6				; yflip tile
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindFloor				; d1 = distance to ceiling left side
		move.w	(sp)+,d0				; d0 = distance to ceiling right side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_ceiling				; branch if Sonic is 0px from ceiling
		bpl.s	.below_ceiling				; branch if Sonic is below ceiling
		cmpi.w	#-$E,d1
		blt.w	Sonic_BelowFloor			; branch if Sonic is > 14px inside ceiling
		sub.w	d1,obY(a0)				; align to ceiling

	; locret_14892:
	.on_ceiling:
		rts
; ===========================================================================

; loc_14894:
.below_ceiling:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px below ceiling

; loc_1489A:
.on_disc:
		sub.w	d1,obY(a0)				; align to ceiling
		rts
; ===========================================================================

; loc_148A0:
.in_air:
		tst.b	sticktoconvex(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation
		rts
; End of function Sonic_WalkCeiling

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to his left
; ---------------------------------------------------------------------------

Sonic_WalkVertL:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2					; d2 = y pos of upper edge of Sonic (i.e. his front or back)
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		eori.w	#$F,d3					; add some amount
		lea	(v_anglebuffer).w,a4			; write angle here
		movea.w	#-$10,a3				; tile width
		move.w	#$800,d6				; xflip tile
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindWall
		move.w	d1,-(sp)				; save d1 (distance to wall) to stack

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2					; d2 = y pos of lower edge of Sonic (i.e. his front or back)
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3					; d3 = x pos of bottom edge of Sonic (i.e. his feet)
		eori.w	#$F,d3
		lea	(v_anglebuffer2).w,a4			; write angle here
		movea.w	#-$10,a3				; tile width
		move.w	#$800,d6				; xflip tile
		moveq	#$D,d5					; bit to test for solidness (top solid)
		bsr.w	FindWall				; d1 = distance to wall lower side
		move.w	(sp)+,d0				; d0 = distance to wall upper side
		bsr.w	Sonic_Angle				; update angle
		tst.w	d1
		beq.s	.on_wall				; branch if Sonic is 0px from wall
		bpl.s	.outside_wall				; branch if Sonic is outside wall
		cmpi.w	#-$E,d1
		blt.w	Sonic_InsideWall			; branch if Sonic is > 14px inside wall
		sub.w	d1,obX(a0)				; align to wall

	; locret_14934:
	.on_wall:
		rts
; ===========================================================================

; loc_14936:
.outside_wall:
		cmpi.w	#$E,d1
		bgt.s	.in_air					; branch if Sonic is > 14px outside wall

; loc_1493C:
.on_disc:
		sub.w	d1,obX(a0)				; align to wall
		rts
; ===========================================================================

; loc_14942:
.in_air:
		tst.b	sticktoconvex(a0)
		bne.s	.on_disc				; branch if Sonic is on a SBZ disc
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0)			; restart Sonic's animation
		rts
; End of function Sonic_WalkVertL
