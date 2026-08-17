; DIRTY WIP OPTIMIZAZION !!!!!!!!!!!!!


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 25 - standalone rings
; 
; With the introduction of the S3K rings manager, these are rarely
; used anymore, mainly only in case rings get placed in debug mode.
; Note that these standalone rings cannot be attracted by a shield.
; ---------------------------------------------------------------------------

Rings:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp	Ring_Index(pc,d1.w)
; ===========================================================================
Ring_Index:	; CR = cross-referencing to bouncing rings object
		dc.w Ring_Main-Ring_Index			; 0
		dc.w Ring_Animate-Ring_Index			; 2
		dc.w RLoss_Collect-Ring_Index			; 4 (CR)
		dc.w RLoss_Sparkle-Ring_Index			; 6 (CR)
		dc.w RLoss_Delete-Ring_Index			; 8 (CR)
; ===========================================================================

Ring_Main:	; Routine 0/A
		bsr.s	Ring_Setup_Self				; set up maps etc.
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; set art tile and palette line
		addq.b	#2,obRoutine(a0)			; advance to main routine for ring
; ---------------------------------------------------------------------------

Ring_Animate:	; Routine 2
		out_of_range.w	DeleteObject			; has ring gone out of range? if yes, delete it
		DisplaySprite
		rts				; display ring sprite


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set up basic ring data
; ---------------------------------------------------------------------------

Ring_Setup_Self:
		movea.l	a0,a1					; setup parent ring itself
; ---------------------------------------------------------------------------

Ring_Setup:
		move.l	#Map_Ring,obMap(a1)			; set mappings
		move.b	#sprite_cam_field,obRender(a1)		; set to playfield-positioned mode
		move.w	#spr_prio2,obPriority(a1)			; set sprite priority
		move.b	#col_12x12|col_item,obColType(a1)	; set to power-up collision type and hitbox 12x12 (=$47)
		move.b	#16/2,obActWid(a1)			; set sprite display width
		rts						; return
; End of function Ring_Setup


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add rings (1 or custom amount) to ring counter, set flag
; to update ring HUD, and award an extra life for each multiple of 100 rings.
; ---------------------------------------------------------------------------

CollectRing:
		moveq	#1,d0					; add 1 to rings
		;moveq	#32,d0					; add 32 to rings for quick testing
; ---------------------------------------------------------------------------

AddRings:	; d0 = custom number of rings to add
		add.w	(v_rings).w,d0				; add current rings to number of additional rings
		cmpi.w	#999,d0					; would new result overflow the 999 limit of the counter?
		bls.s	.noOverflow				; if not, branch
		move.w	#999,d0					; otherwise, cap ring counter to 999
.noOverflow:	move.w	d0,(v_rings).w				; write result as new rings amount
		ori.b	#1,(f_ringcount).w			; set flag to refresh rings counter in HUD_Update

	if Enable_InfiniteLives=0
		move.l	d0,-(sp)				; backup d0 (long because mulu affects both words)
		moveq	#1,d0					; set initial extra lives check value
		add.b	(v_lifecount).w,d0			; add remembered value of collected extra lives
		mulu.w	#100,d0					; multiply required ring value by 100 rings
		cmp.l	(sp)+,d0				; do you have at least n*100 rings now?
		bls.s	.extraLifeFromRings			; if yes, award extra life
	endif

.playRingSfx:
		move.w	#sfx_Ring,d0				; set ring sound
		jmp	(QueueSound2).l				; play it
; ---------------------------------------------------------------------------

.extraLifeFromRings:
		addq.b	#1,(v_lifecount).w			; remember extra life for this multiple of 100 rings was awarded
		; continue to ExtraLife...

; ---------------------------------------------------------------------------
; Subroutine to add extra lives (1 or custom amount).
; ---------------------------------------------------------------------------

ExtraLife:
	if Enable_InfiniteLives
		rts
	endif

		moveq	#1,d0				; add 1 to the number of lives you have
; ---------------------------------------------------------------------------

AddLives:	; d0 = custom number of extra lives to add
		add.b	(v_lives).w,d0			; add current lives to number of additional lives
		cmpi.b	#99,d0				; would new result overflow the 99 limit of the counter?
		bls.s	.noOverflow			; if not, branch
		moveq	#99,d0				; otherwise, cap lives counter to 99
.noOverflow:	move.b	d0,(v_lives).w			; write result as new extra lives amount
		ori.b	#1,(f_lifecount).w		; set flag to refresh lives counter in HUD_Update
		move.w	#bgm_ExtraLife,d0		; set extra life music
		jmp	(QueueSound1).l			; play it
; End of functions CollectRing and ExtraLife



; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic when he's hit
; ---------------------------------------------------------------------------

RingLoss:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		beq.s	RLoss_Bounce
		move.w	RLoss_Index(pc,d0.w),d1
		jmp	RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:	; rings spilled from getting hurt
		dc.w RLoss_Bounce-RLoss_Index			;  0
		dc.w RLoss_Collect-RLoss_Index			;  2
		dc.w RLoss_Sparkle-RLoss_Index			;  4
		dc.w RLoss_Delete-RLoss_Index			;  6
		dc.w RLoss_Delete-RLoss_Index			;  8

		; rings attracted while having a shield
		dc.w RLoss_Attract_Init-RLoss_Index		;  A
		dc.w RLoss_Attract_Main-RLoss_Index		;  C
		dc.w RLoss_Collect-RLoss_Index			;  E
		dc.w RLoss_Sparkle-RLoss_Index			; 10
		dc.w RLoss_Delete-RLoss_Index			; 12

rloss_velX:	equ	objoff_32
rloss_velY:	equ	objoff_36
; ===========================================================================

RLoss_Bounce:	; Routine 0
		; SpeedToPos (inlined, optimized)
		movem.l	rloss_velX(a0),d0/d2			; load X and Y speed to d0/d2
		add.l	d0,obX(a0)				; update X-position
		;andi.l	#$7FF0000,d2				; apply vertical screen wrap
		add.l	d2,obY(a0)				; update Y-position

		; apply gravity
		add.l	#$1800,rloss_velY(a0)			; add fall speed to current Y velocity
		bmi.s	.chkdel					; is ring still going upwards? if yes, skip floor collision check
	
		; floor collision check
		move.b	(v_vblank_byte).w,d0			; get VBlank counter byte
		add.b	d7,d0					; add object RAM index as crude spreading-out of collision check over multiple frames
		andi.b	#3,d0					; only check for floor collision every 4th frame
		bne.s	.chkdel					; if on any other frame, branch

		bsr.w	ChkHitFloor_Rings
		beq.s	.chkdel
		jsr	(ObjFloorDist).l			; calculate distance between this ring and the floor
		tst.w	d1					; has ring hit the floor?
		bpl.s	.chkdel					; if not, branch
		add.w	d1,obY(a0)				; ring hit the floor, align it to the surface
		move.l	rloss_velY(a0),d0				; get current ring fall speed
		asr.l	#2,d0					; divide it by 4
		sub.l	d0,rloss_velY(a0)				; subtract that result from the previous speed to make it bounce less
		neg.l	rloss_velY(a0)				; negate fall speed to make ring bounce up

	.chkdel:
		; check if ring should be deleted
		subq.b	#1,obDelayAni(a0)			; decrement remaining time for bouncing ring
		beq.w	DeleteObject				; if time reached zero, delete ring

		move.w	(v_limitbtm3).w,d0
		cmp.w	obY(a0),d0				; has object moved below the bottom level boundary?
		blt.w	DeleteObject				; if yes, delete ring

		moveq	#col_none,d1
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	.pos
		neg.w	d0
	.pos:	cmpi.w	#$20,d0
		bhi.s	.nocol
		moveq	#col_12x12|col_item,d1

		lea	(v_registeredcollision).w,a1		; get target queue
		move.w	(a1),d0					; get queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.nocol				; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue
		
	.nocol:
		move.b	d1,obColType(a0)


		lea	(v_registeredcollision_rings).w,a1	; get target sprite queue
		move.w	(a1),d0			; get sprite queue's entry count
		addq.b	#2,d0			; increase count by another entry (word)
		bmi.s	.Full		; if byte value went to $80, queue is full
		move.w	d0,(a1)			; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)		; insert RAM address for object to queue

	.Full:
		cmpi.l	#RingLoss,object_size(a0)
		bne.s	.exit
		dbf	d7,.shortcut
		rts

	.shortcut:
		lea	object_size(a0),a0
		bra.w	RingLoss

	.exit:
		rts
; ===========================================================================


ChkHitFloor_Rings:
		move.w	obX(a0),d3				; get object's X-position
		moveq	#16/2,d2				; clear d0 (obHeight is a byte)
		add.w	obY(a0),d2				; get object's Y-position

		move.w	d2,d0					; get Y-position of bottom edge of object
		lsr.w	#1,d0					; divide Y-position by 2 (because layout alternates between level and bg lines)
		andi.w	#$380,d0				; read only high byte of Y-position (because each level chunk is 256px tall)
		move.w	d3,d1					; get X-position of object
		lsr.w	#8,d1
		andi.w	#$7F,d1					; read only high byte of X-position
		add.w	d1,d0					; combine for position within layout
		moveq	#0,d1					; changed from -1 to 0
		lea	(v_lvllayout_fg).w,a1
		move.b	(a1,d0.w),d1				; get 256x256 chunk number
		beq.s	.notsolid				; branch if 0 (blank chunk)
		subq.b	#1,d1					; make chunks start at 0
		ror.w	#7,d1					; d1 = $FFFFxx00 where xx is multiplied by 2
		move.w	d2,d0
		add.w	d0,d0					; d0 = Y-position * 2 (because each 16x16 block is represented by 2 bytes)
		andi.w	#$1E0,d0				; read only high nybble of low byte (for Y-position within 256x256 chunk)
		add.w	d0,d1					; add to base address
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$1E,d0					; d0 = high nybble of low byte of X-position, multiplied by 2
		add.w	d0,d1					; add to base address
		add.l	(v_rom_chunks).w,d1			; add ROM chunks pointer
		movea.l	d1,a1

		move.w	(a1),d0					; get value for solidness, orientation and 16x16 block number
		btst	#$D,d0					; is the block solid?
		bne.s	.issolid				; if yes, branch

.notsolid:
		moveq	#0,d0
		rts

.issolid:






		moveq	#-1,d0
		rts
; End of function ChkHitFloor_Rings

; ===========================================================================








RLoss_Collect:	; Routine 2 (set from ReactToItem)
		addq.b	#2,obRoutine(a0)			; advance to RLoss_Sparkle
		move.b	#col_none,obColType(a0)			; prevent ring from being collected again
		move.w	#spr_prio1,obPriority(a0)			; make ring sparkles appear in front of Sonic's sprites
		bsr.w	CollectRing				; add 1 ring 
; ---------------------------------------------------------------------------

RLoss_Sparkle:	; Routine 4
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; reset art tile for sparkle animation
		lea	(Ani_Ring).l,a1				; get ring animation script
		bsr.w	AnimateSprite				; advance ring animation
		DisplaySprite
		rts				; display ring sprite
; ===========================================================================

RLoss_Delete:	; Routine 6
		bra.w	DeleteObject				; delete this ring

; ===========================================================================

;RLoss_Count:	; Routine 8
RLoss_SpawnRings:
		move.w	(v_rings).w,d5				; get number of rings you have
		moveq	#32,d0					; set maximum rings allowed to be spilled to 32
		cmp.w	d0,d5					; do you more than 32 rings?
		blo.s	.belowmax				; if not, branch
		move.w	d0,d5					; if yes, cap spilled ring count to 32

	.belowmax:
		subq.w	#1,d5					; decrement for dbf
		bmi.s	.resetcounter				; if we have no rings, abort process (failsafe)

		lea	(v_lvlobjend-object_size).w,a4
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d4

		lea	SpillRingData(pc),a3			; load pre-calculated spill velocities


		move.w	(v_player+obX).w,d2				; spawn rings at parent X-position
		move.w	(v_player+obY),d3				; spawn rings at parent Y-position

.loop:
		tst.l	(a4)
		beq.s	.makerings_go
		lea	-object_size(a4),a4
		dbf	d4,.loop
		bra.s	.resetcounter
	.makerings_go:
		movea.w	a4,a1
	.makerings:
		move.l	#RingLoss,obID(a1)				; load new bouncing ring object
		move.w	d2,obX(a1)				; copy parent X-position
		move.w	d3,obY(a1)				; copy parent Y-position

		move.l	(a3)+,rloss_velX(a1)
		move.l	(a3)+,rloss_velY(a1)

		move.b	#16/2,obActWid(a1)			; set sprite display width
		move.l	#Map_Ring,obMap(a1)			; set mappings
		move.b	#sprite_cam_field,obRender(a1)		; set to playfield-positioned mode
		bset	#sprite_rendered_bit,obRender(a1)
		move.w	#ArtTile_Ring_Loss|Tile_Pal2,obGfx(a1)	; special art tile for smooth rings
		dbf	d5,.loop				; repeat for number of spilled rings (max 31)

.resetcounter:
		clr.w	(v_rings).w				; reset number of rings to zero
		clr.b	(v_lifecount).w				; reset the flags for extra lives on 100/200 rings collected
		move.b	#$80,(f_ringcount).w			; update ring counter ($80 means all digits should be reset to __0)
		move.b	#255,(v_ani3_time).w			; set animation timer
		move.w	#sfx_RingLoss,d0			; set ring loss sound
		jmp	(QueueSound2).l				; play it

; ---------------------------------------------------------------------------
; Precalculated spilled rings velocities
; ---------------------------------------------------------------------------

SpillRingData:
		dc.l   -$C400,-$3EC00,   $C400,-$3EC00,  -$23800,-$35000,  $23800,-$35000  ; 4
		dc.l  -$35000,-$23800,  $35000,-$23800,  -$3EC00, -$C400,  $3EC00, -$C400  ; 8
		dc.l  -$3EC00,  $C400,  $3EC00,  $C400,  -$35000, $23800,  $35000, $23800  ; 12
		dc.l  -$23800, $35000,  $23800, $35000,   -$C400, $3EC00,   $C400, $3EC00  ; 16
		dc.l   -$6200,-$1F600,   $6200,-$1F600,  -$11C00,-$1A800,  $11C00,-$1A800  ; 20
		dc.l  -$1A800,-$11C00,  $1A800,-$11C00,  -$1F600, -$6200,  $1F600, -$6200  ; 24
		dc.l  -$1F600,  $6200,  $1F600,  $6200,  -$1A800, $11C00,  $1A800, $11C00  ; 28
		dc.l  -$11C00, $1A800,  $11C00, $1A800,   -$6200, $15600,   $6200, $15600  ; 32
		dc.l	$6200, $15600  ; 33


; ===========================================================================
; ---------------------------------------------------------------------------
; Attracted rings (set from S3K Rings Manager => AttractRing)
; ---------------------------------------------------------------------------

RLoss_Attract_Init:	; Routine A
		bsr.w	Ring_Setup_Self				; set up maps etc.
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; special art tile for smooth rings
		addq.b	#2,obRoutine(a0)
; ---------------------------------------------------------------------------

RLoss_Attract_Main:	; Routine C
		tst.b	(v_shield).w				; does Sonic still have a shield?
		bne.s	.attract				; if yes, keep attracting ring

		; Make rings bounce away at their current speed if Sonic lost his shield
		clr.b	obRoutine(a0)			; change ring to RLoss_Bounce routine

		move.b	#255,d0					; set both timers to 255 frames
		move.b	d0,obDelayAni(a0)			; set ring despawn timer
		move.b	d0,(v_ani3_time).w			; set animation timer

		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		move.l	d0,rloss_velX(a0)

		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		move.l	d0,rloss_velY(a0)

		bset	#sprite_rendered_bit,obRender(a0)
		bra.w	RLoss_Bounce				; continue straight to ring loss object
; ---------------------------------------------------------------------------

.attract:
		lea	(v_player).w,a1				; load Sonic player object
		moveq	#$30,d1					; set horizontal ring move speed
		move.w	obX(a1),d0				; get Sonic's current X-position
		cmp.w	obX(a0),d0				; is attracted ring to the right of Sonic?
		bcc.s	.ringLeft				; if not, branch

	.ringRight:
		neg.w	d1					; move ring to the left instead
		tst.w	obVelX(a0)				; is ring already moving left?
		bmi.s	.updateXSpeed				; if yes, branch
		add.w	d1,d1					; quadruple horizontal speed...
		add.w	d1,d1					; ...if ring needs to turn around
		bra.s	.updateXSpeed				; update horizontal speed

	.ringLeft:
		tst.w	obVelX(a0)				; is ring already moving right?
		bpl.s	.updateXSpeed				; if yes, branch
		add.w	d1,d1					; quadruple horizontal speed...
		add.w	d1,d1					; ...if ring needs to turn around

	.updateXSpeed:
		add.w	d1,obVelX(a0)				; update attracted ring's current X-speed
; ---------------------------------------------------------------------------

		moveq	#$30,d1					; set vertical ring move speed
		move.w	obY(a1),d0				; get Sonic's current Y-position
		cmp.w	obY(a0),d0				; is attracted ring below Sonic?
		bcc.s	.ringAbove				; if not, branch

	.ringBelow:
		neg.w	d1					; move right upwards instead
		tst.w	obVelY(a0)				; is ring already moving up?
		bmi.s	.updateYSpeed				; if yes, branch
		add.w	d1,d1					; quadruple vertical speed...
		add.w	d1,d1					; ...if ring needs to turn around
		bra.s	.updateYSpeed				; update vertical speed

	.ringAbove:
		tst.w	obVelY(a0)				; is ring already moving down?
		bpl.s	.updateYSpeed				; if yes, branch
		add.w	d1,d1					; quadruple vertical speed...
		add.w	d1,d1					; ...if ring needs to turn around

	.updateYSpeed:
		add.w	d1,obVelY(a0)				; update attracted ring's current Y-speed
; ---------------------------------------------------------------------------

		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,obX(a0)				; add X speed to X position (note this affects the subpixel position)
		asl.l	#8,d2					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,obY(a0)				; add Y speed to Y position (note this affects the subpixel position)

		DisplaySprite
		rts				; display ring sprite
; ===========================================================================

		include	"_anim/Rings.asm"
Map_Ring:	include	"_maps/Rings.asm"