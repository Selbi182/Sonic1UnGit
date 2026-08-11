; ---------------------------------------------------------------------------
objid_to_rom:	macro
		add.w	d0,d0
		add.w	d0,d0
		lea	Obj_Index-4(pc),a2
		move.l	(a2,d0.w),obID(a1)
		endm

; ---------------------------------------------------------------------------
OPL_S1_Compatibility: equ 0
; If 1, adds compatibility for the Sonic 1 objpos layout without needing any
; further adjustments. This will account for the following limitations:
; * Sonic 3 introduces one extra bit to the upper portion of the second word,
;   which is called the "y-check skip" flag. This pushes the x-flip/y-flip
;   flags one bit further to the right, so it has to be accounted for.
; * Sonic 3 can place object IDs up to $FF in the level. Sonic 1 can only go
;   up to a maximum of $7F, as the MSB is reserved for the (now-unused)
;   remember-state flag. Even though it's no longer necessary, we need to
;   keep the limit or else objects would load with invalid IDs, unless
;   adjusted to never set the remember-state flag in the objpos layout.
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine to load objects whenever they are close to the screen. Unlike in
; normal s2, in this version every object gets an entry in the respawn table.
; This is necessary to get the additional y-range checks to work.
;
; input variables:
;  -none-
;
; writes:
;  d0, d1, d2
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;  d6 = camera position
;
;  a0 = address in object placement list
;  a3 = address in object respawn table
;  a6 = object loading routine
; ---------------------------------------------------------------------------

; loc_17AA4
ObjPosLoad_Init:
		lea     (Object_Respawn_Table).w,a0
		moveq   #0,d0
		move.w  #$C0-1,d1			; set loop counter
OPLBack1:	move.l  d0,(a0)+
		dbf     d1,OPLBack1

		; initialize each object load address with the first object in the layout
		movea.l	(v_opl_data).w,a0		; set from LevelDataLoad
		move.l	a0,(v_opl_data+4).w

		lea	(Object_Respawn_Table).w,a3
		move.w	(v_screenposx).w,d6
		subi.w	#$80,d6				; look one chunk to the left
		bcc.s	OPL1				; if the result was negative,
		moveq	#0,d6				; cap at zero

OPL1:
		andi.w	#$FF80,d6			; limit to increments of $80 (width of a chunk)
		movea.l	(v_opl_data).w,a0		; get first object in layout

OPLBack2:	; at the beginning of a level this gives respawn table entries to any object that is one chunk
		; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	OPL2				; if yes, branch
		addq.w	#6,a0				; next object
		addq.w	#1,a3				; respawn index of next object going right
		bra.s	OPLBack2
; ---------------------------------------------------------------------------

OPL2:
		move.l	a0,(v_opl_data).w		; remember rightmost object that has been processed, so far (we still need to look forward)
		move.w	a3,(v_opl_data+8).w		; and its respawn table index

		lea	(Object_Respawn_Table).w,a3	; reset a3
		movea.l	(v_opl_data+4).w,a0		; reset a0
		subi.w	#$80,d6				; look even farther left (any object behind this is out of range)
		bcs.s	OPL3				; branch, if camera position would be behind level's left boundary

 OPLBack3:	; count how many objects are behind the screen that are not in range and need to remember their state
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	OPL3				; if yes, branch
		addq.w	#6,a0
		addq.w	#1,a3				; respawn index of next object going left
		bra.s	OPLBack3			; continue with next object
; ---------------------------------------------------------------------------

OPL3:
		move.l	a0,(v_opl_data+4).w		; remember current object from the left
		move.w	a3,(v_opl_data+$C).w		; and its respawn table index

		move.w	#-1,(Camera_X_Pos_Last).w	; make sure ObjPosLoad_GoingForward is run

		move.w	(v_screenposy).w,d0
		andi.w	#$FF80,d0
		move.w	d0,(Camera_Y_Pos_Last).w	; make sure the Y check isn't run unnecessarily during initialization
; End of function ObjPosLoad_Init
; ---------------------------------------------------------------------------

ObjPosLoad:
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		move.w	d1,(Camera_X_Coarse_Back).w
 
 		move.w	(v_screenposy).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		move.w	d1,(Camera_Y_Coarse_Back).w

		tst.w	(v_limittop2).w			; does this level y-wrap?
		bpl.s	ObjMan_Main_NoYWrap		; if not, branch
		lea	(ChkLoadObj_YWrap).l,a6		; set object loading routine
		move.w	(v_screenposy).w,d3
		andi.w	#$FF80,d3			; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4			; set lower boundary
		subi.w	#$80,d3				; set upper boundary
		bpl.s	OPL4				; branch, if upper boundary > 0
		andi.w	#$7FF,d3			; wrap value
		bra.s	ObjMan_Main_Cont
; ---------------------------------------------------------------------------

OPL4:
		move.w	#$7FF,d0
		addq.w	#1,d0
		cmp.w	d0,d4
		bls.s	OPL5				; branch, if lower boundary < $7FF
		andi.w	#$7FF,d4			; wrap value
		bra.s	ObjMan_Main_Cont
; ---------------------------------------------------------------------------

ObjMan_Main_NoYWrap:
		move.w	(v_screenposy).w,d3
		andi.w	#$FF80,d3			; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4			; set lower boundary
		subi.w	#$80,d3				; set upper boundary
		bpl.s	OPL5
		moveq	#0,d3				; no negative values allowed

OPL5:
		lea	(ChkLoadObj).l,a6		; set object loading routine

ObjMan_Main_Cont:
		move.w	#$FFF,d5			; this will be used later when we load objects
		move.w	(v_screenposx).w,d6
		andi.w	#$FF80,d6
		cmp.w	(Camera_X_Pos_Last).w,d6	; is the X range the same as last time?
		beq.w	ObjPosLoad_SameXRange		; if yes, branch
		bge.s	ObjPosLoad_GoingForward		; if new pos is greater than old pos, branch

		; if the player is moving back
		move.w	d6,(Camera_X_Pos_Last).w	; remember current position for next time

		movea.l	(v_opl_data+4).w,a0		; get current object going left
		movea.w	(v_opl_data+$C).w,a3		; and its respawn table index

		subi.w	#$80,d6				; look one chunk to the left
		bcs.s	ObjMan_GoingBack_Part2		; branch, if camera position would be behind level's left boundary

		jsr	(FindFreeObj).l			; find an empty object slot
		bne.s	ObjMan_GoingBack_Part2		; branch, if there are none

OPLBack4:	; load all objects left of the screen that are now in range
		cmp.w	-6(a0),d6			; is the previous object's X pos less than d6?
		bge.s	ObjMan_GoingBack_Part2		; if it is, branch
		subq.w	#6,a0				; get object's address
		subq.w	#1,a3				; and respawn table index
		jsr	(a6)				; load object
		bne.s	OPL6				; branch, if SST is full
		subq.w	#6,a0
		bra.s	OPLBack4			; continue with previous object
; ---------------------------------------------------------------------------

OPL6:
		; undo a few things if the object couldn't load
		addq.w	#6,a0				; go back to last object
		addq.w	#1,a3				; since we didn't load the object, undo last change

ObjMan_GoingBack_Part2:
		move.l	a0,(v_opl_data+4).w		; remember current object going left
		move.w	a3,(v_opl_data+$C).w		; and its respawn table index
		movea.l	(v_opl_data).w,a0		; get next object going right
		movea.w	(v_opl_data+8).w,a3		; and its respawn table index
		addi.w	#$300,d6			; look two chunks beyond the right edge of the screen

OPLBack5:	; subtract number of objects that have been moved out of range (from the right side)
		cmp.w	-6(a0),d6			; is the previous object's X pos less than d6?
		bgt.s	OPL7				; if it is, branch
		subq.w	#6,a0				; get object's address
		subq.w	#1,a3				; and respawn table index
		bra.s	OPLBack5			; continue with previous object
; ---------------------------------------------------------------------------

OPL7:
		move.l	a0,(v_opl_data).w		; remember next object going right
		move.w	a3,(v_opl_data+8).w		; and its respawn table index
		bra.s	ObjPosLoad_SameXRange
; ---------------------------------------------------------------------------

ObjPosLoad_GoingForward:
		move.w	d6,(Camera_X_Pos_Last).w

		movea.l	(v_opl_data).w,a0		; get next object from the right
		movea.w (v_opl_data+8).w,a3		; and its respawn table index
		addi.w	#$280,d6			; look two chunks forward
		jsr	(FindFreeObj).l			; find an empty object slot
		bne.s	ObjMan_GoingForward_Part2	; branch, if there are none

OPLBack6:	; load all objects right of the screen that are now in range
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	ObjMan_GoingForward_Part2	; if yes, branch
		jsr	(a6)				; load object (and get address of next object)
		addq.w	#1,a3				; respawn index of next object to the right
		beq.s	OPLBack6			; continue loading objects, if the SST isn't full

ObjMan_GoingForward_Part2:
		move.l	a0,(v_opl_data).w		; remember next object from the right
		move.w	a3,(v_opl_data+8).w		; and its respawn table index
		movea.l	(v_opl_data+4).w,a0		; get current object from the left
		movea.w	(v_opl_data+$C).w,a3		; and its respawn table index
		subi.w	#$300,d6			; look one chunk behind the left edge of the screen
		bcs.s	ObjMan_GoingForward_End		; branch, if camera position would be behind level's left boundary

OPLBack7:	; subtract number of objects that have been moved out of range (from the left)
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	ObjMan_GoingForward_End		; if yes, branch
		addq.w	#6,a0				; next object
		addq.w	#1,a3				; respawn index of next object to the left
		bra.s	OPLBack7			; continue with next object
; ---------------------------------------------------------------------------

ObjMan_GoingForward_End:
		move.l	a0,(v_opl_data+4).w		; remember current object from the left
		move.w	a3,(v_opl_data+$C).w		; and its respawn table index

ObjPosLoad_SameXRange:
		move.w	(v_screenposy).w,d6
		andi.w	#$FF80,d6
		move.w	d6,d3
		cmp.w	(Camera_Y_Pos_Last).w,d6	; is the y range the same as last time?
		beq.w	ObjPosLoad_SameYRange		; if yes, branch
		bge.s	ObjPosLoad_GoingDown		; if the player is moving down

		; if the player is moving up
		tst.w	(v_limittop2).w			; does the level y-wrap?
		bpl.s	ObjMan_GoingUp_NoYWrap		; if not, branch
		tst.w	d6
		bne.s	ObjMan_GoingUp_YWrap
		cmpi.w	#$80,(Camera_Y_Pos_Last).w
		bne.s	ObjMan_GoingDown_YWrap

ObjMan_GoingUp_YWrap:
		subi.w	#$80,d3				; look one chunk up
		bpl.s	ObjPosLoad_YCheck		; go to y check, if camera y position >= $80
		andi.w	#$7FF,d3			; else, wrap value
		bra.s	ObjPosLoad_YCheck

; ---------------------------------------------------------------------------

ObjMan_GoingUp_NoYWrap:
		subi.w	#$80,d3				; look one chunk up
		bmi.w	ObjPosLoad_SameYRange		; don't do anything if camera y position is < $80
		bra.s	ObjPosLoad_YCheck
; ---------------------------------------------------------------------------

ObjPosLoad_GoingDown:
		tst.w	(v_limittop2).w			; does the level y-wrap?
		bpl.s	ObjMan_GoingDown_NoYWrap	; if not, branch
		tst.w	(Camera_Y_Pos_Last).w
		bne.s	ObjMan_GoingDown_YWrap
		cmpi.w	#$80,d6
		bne.s	ObjMan_GoingUp_YWrap

ObjMan_GoingDown_YWrap:
		addi.w	#$180,d3			; look one chunk down
		cmpi.w	#$7FF,d3
		bcs.s	ObjPosLoad_YCheck		; go to  check, if camera y position < $7FF
		andi.w	#$7FF,d3			; else, wrap value
		bra.s	ObjPosLoad_YCheck
; ---------------------------------------------------------------------------

ObjMan_GoingDown_NoYWrap:
		addi.w	#$180,d3			; look one chunk down
		cmpi.w	#$7FF,d3
		bhi.w	ObjPosLoad_SameYRange		; don't do anything, if camera is too close to bottom

ObjPosLoad_YCheck:
		jsr	(FindFreeObj).l			; get an empty object slot
		bne.s	ObjPosLoad_SameYRange		; branch, if there are none
		move.w	d3,d4
		addi.w	#$80,d4
		move.w	#$FFF,d5			; this will be used later when we load objects
		movea.l	(v_opl_data+4).w,a0		; get next object going left
		movea.w	(v_opl_data+$C).w,a3		; and its respawn table index
		move.l	(v_opl_data).w,d7		; get next object going right
		sub.l	a0,d7				; d7 = number of objects between the left and right boundaries * 6
		beq.s	ObjPosLoad_SameYRange		; branch if there are no objects inbetween
		addq.w	#2,a0				; align to object's y position

OPLBack8:	; check if current object needs to be loaded
		tst.b	(a3)				; is object already loaded?
		bmi.s	OPL8				; if yes, branch
		move.w	(a0),d1
		and.w	d5,d1				; get object's y position
		cmp.w	d3,d1
		bcs.s	OPL8				; branch, if object is out of range from the top
		cmp.w	d4,d1
		bhi.s	OPL8				; branch, if object is out of range from the bottom
		bset	#7,(a3)				; mark object as loaded

		; load object
		move.w	-2(a0),obX(a1)
		move.w	(a0),d1
		move.w	d1,d2
		and.w	d5,d1				; get object's y position
		move.w	d1,obY(a1)
	if OPL_S1_Compatibility
		rol.w	#2,d2
	else
		rol.w	#3,d2
	endif
		andi.w	#3,d2				; get object's render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		moveq	#0,d0
		move.b	2(a0),d0
	if OPL_S1_Compatibility
		andi.b	#$7F,d0				; limit level-placeable objects to $7F (MSB is used for old remember state flag)
	endif

		;move.b	d0,obID(a1)
		objid_to_rom

		move.b	3(a0),obSubtype(a1)
		move.w	a3,respawn_index(a1)
		jsr	(FindFreeObj).l			; find new object slot
		bne.s	ObjPosLoad_SameYRange		; brach, if there are none left
OPL8:
		addq.w	#6,a0				; address of next object
		addq.w	#1,a3				; and its respawn index
		subq.w	#6,d7				; subtract from size of remaining objects
		bne.s	OPLBack8			; branch, if there are more

ObjPosLoad_SameYRange:
		move.w	d6,(Camera_Y_Pos_Last).w
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutines to check if an object needs to be loaded,
; with and without y-wrapping enabled.
;
; input variables:
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;
;  a0 = address in object placement list
;  a1 = object
;  a3 = address in object respawn table
;
; writes:
;  d1, d2, d7
; ---------------------------------------------------------------------------

ChkLoadObj_YWrap:
		tst.b	(a3)				; is object already loaded?
		bpl.s	OPL9				; if not, branch
		addq.w	#6,a0				; address of next object
		moveq	#0,d1				; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL9:
		move.w	(a0)+,d7			; x_pos
		move.w	(a0)+,d1			; y_pos, render flags, and y-check skip flag
		move.w	d1,d2
	if OPL_S1_Compatibility=0
		bmi.s	OPL10				; are y-checks skipped? if yes, branch
	endif
		and.w	d5,d1				; y_pos
		cmp.w	d3,d1
		bcc.s	LoadObj_YWrap
		cmp.w	d4,d1
		bls.s	LoadObj_YWrap
		addq.w	#2,a0				; address of next object
		moveq	#0,d1				; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL10:
		and.w	d5,d1				; y_pos

LoadObj_YWrap:
		bset	#7,(a3)				; mark object as loaded
		move.w	d7,obX(a1)
		move.w	d1,obY(a1)
	if OPL_S1_Compatibility
		rol.w	#2,d2				; rotate y-flip, and x-flip flags to lower bits (no y-check flag)
	else
		rol.w	#3,d2				; rotate y-check, y-flip, and x-flip flags to lower bits
	endif
		andi.w	#3,d2				; get render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		moveq	#0,d0
		move.b	(a0)+,d0
	if OPL_S1_Compatibility
		andi.b	#$7F,d0				; limit level-placeable objects to $7F (MSB is used for old remember state flag)
	endif
		;move.b	d0,obID(a1)
		objid_to_rom

		move.b	(a0)+,obSubtype(a1)
		move.w	a3,respawn_index(a1)
		bra.w	FindFreeObj			; find new object slot
; ---------------------------------------------------------------------------

;loc_17F36
ChkLoadObj:
		tst.b	(a3)				; is object already loaded?
		bpl.s	OPL11				; if not, branch
		addq.w	#6,a0				; address of next object
		moveq	#0,d1				; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL11:
		move.w	(a0)+,d7			; x_pos
		move.w	(a0)+,d1			; y_pos, render flags, and y-check skip flag
		move.w	d1,d2
	if OPL_S1_Compatibility=0
		bmi.s	OPL13				; are y-checks skipped? if yes, branch
	endif
		and.w	d5,d1				; y_pos
		cmp.w	d3,d1
		bcs.s	OPL12				; branch, if object is out of range from the top
		cmp.w	d4,d1
		bls.s	LoadObj				; branch, if object is in range from the bottom
OPL12:
		addq.w	#2,a0				; address of next object
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

OPL13:
		and.w	d5,d1				; y_pos

LoadObj:
		bset	#7,(a3)				; mark object as loaded
		move.w	d7,obX(a1)
		move.w	d1,obY(a1)
	if OPL_S1_Compatibility
		rol.w	#2,d2				; rotate y-flip, and x-flip flags to lower bits (no y-check flag)
	else
		rol.w	#3,d2				; rotate y-check, y-flip, and x-flip flags to lower bits
	endif
		andi.w	#3,d2				; get render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		moveq	#0,d0
		move.b	(a0)+,d0
	if OPL_S1_Compatibility
		andi.b	#$7F,d0				; limit level-placeable objects to $7F (MSB is used for old remember state flag)
	endif
		;move.b	d0,obID(a1)
		objid_to_rom

		move.b	(a0)+,obSubtype(a1)
		move.w	a3,respawn_index(a1)
		bra.w	FindFreeObj
; End of function ChkLoadObj
; ===========================================================================
