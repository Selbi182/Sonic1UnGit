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
; ---------------------------------------------------------------------------

Ring_Animate:	; Routine 2
		out_of_range.w	DeleteObject			; has ring gone out of range? if yes, delete it
		bra.w	DisplaySprite				; display ring sprite


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to set up basic ring data
; ---------------------------------------------------------------------------

Ring_Setup_Self:
		movea.l	a0,a1					; setup parent ring itself
; ---------------------------------------------------------------------------

Ring_Setup:
		addq.b	#2,obRoutine(a1)			; advance to main routine for ring
		move.l	#Map_Ring,obMap(a1)			; set mappings
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a1)	; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a1)		; set to playfield-positioned mode
		move.b	#2,obPriority(a1)			; set sprite priority
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
		move.w	RLoss_Index(pc,d0.w),d1
		jmp	RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:	; rings spilled from getting hurt
		dc.w RLoss_Count-RLoss_Index			;  0
		dc.w RLoss_Bounce-RLoss_Index			;  2
		dc.w RLoss_Collect-RLoss_Index			;  4
		dc.w RLoss_Sparkle-RLoss_Index			;  6
		dc.w RLoss_Delete-RLoss_Index			;  8

		; rings attracted while having a shield
		dc.w RLoss_Attract_Init-RLoss_Index		;  A
		dc.w RLoss_Attract_Main-RLoss_Index		;  C
		dc.w RLoss_Collect-RLoss_Index			;  E
		dc.w RLoss_Sparkle-RLoss_Index			; 10
		dc.w RLoss_Delete-RLoss_Index			; 12
; ===========================================================================

RLoss_Count:	; Routine 0
		move.w	(v_rings).w,d5				; get number of rings you have
		moveq	#32,d0					; set maximum rings allowed to be spilled to 32
		cmp.w	d0,d5					; do you more than 32 rings?
		blo.s	.belowmax				; if not, branch
		move.w	d0,d5					; if yes, cap spilled ring count to 32

	.belowmax:
		subq.w	#1,d5					; decrement for dbf
		bmi.s	.resetcounter				; if we have no rings, abort process (failsafe)

		lea	SpillRingData(pc),a3			; load pre-calculated spill velocities
		movea.l	a0,a1					; load first spilled ring to current RAM location

		move.w	obX(a0),d2				; spawn rings at parent X-position
		move.w	obY(a0),d3				; spawn rings at parent Y-position
		moveq	#0,d6					; set to above water by default
		tst.b	(f_water).w				; does level have water?
		beq.s	.makerings				; if not, branch
		cmp.w	(v_waterpos1).w,d3			; are rings to be spawned underwater?
		scc.b	d6					; d6 = set if rings are underwater
		bra.s	.makerings				; init first ring
; ===========================================================================

.loop:
		bsr.w	FindNextFreeObj				; find next free object RAM slot
		bne.s	.resetcounter				; if object RAM is full, abort generating new rings
	.makerings:
		move.b	(a0),(a1)				; load new bouncing ring object
		move.w	d2,obX(a1)				; copy parent X-position
		move.w	d3,obY(a1)				; copy parent Y-position
		move.l	(a3)+,obVelX(a1)			; move the data contained in the array to obVelX and obVelY, and increment the address in a3
		tst.b	d6					; is ring underwater?
		beq.s	.aboveWater				; if not, branch
		asr.w	obVelX(a1)				; halve X-speed
		asr.w	obVelY(a1)				; halve Y-speed
	.aboveWater:
		bsr.w	Ring_Setup				; complete remaining ring setup (maps etc.)
		move.w	#ArtTile_Ring_Loss|Tile_Pal2,obGfx(a1)	; special art tile for smooth rings
		dbf	d5,.loop				; repeat for number of spilled rings (max 31)

.resetcounter:
		clr.w	(v_rings).w				; reset number of rings to zero
		clr.b	(v_lifecount).w				; reset the flags for extra lives on 100/200 rings collected
		move.b	#$80,(f_ringcount).w			; update ring counter ($80 means all digits should be reset to __0)

		move.b	#255,d0					; set both timers to 255 frames
		move.b	d0,obDelayAni(a0)			; set ring despawn timer
		move.b	d0,(v_ani3_time).w			; set animation timer

		move.w	#sfx_RingLoss,d0			; set ring loss sound
		jsr	(QueueSound2).l				; play it
		bra.w	RLoss_Bounce				; skip over SpillRingData

; ---------------------------------------------------------------------------
; Precalculated spilled rings velocities
; ---------------------------------------------------------------------------

SpillRingData:
		dc.w   -$C4,-$3EC,   $C4,-$3EC,  -$238,-$350,  $238,-$350  ; 4
		dc.w  -$350,-$238,  $350,-$238,  -$3EC, -$C4,  $3EC, -$C4  ; 8
		dc.w  -$3EC,  $C4,  $3EC,  $C4,  -$350, $238,  $350, $238  ; 12
		dc.w  -$238, $350,  $238, $350,   -$C4, $3EC,   $C4, $3EC  ; 16
		dc.w   -$62,-$1F6,   $62,-$1F6,  -$11C,-$1A8,  $11C,-$1A8  ; 20
		dc.w  -$1A8,-$11C,  $1A8,-$11C,  -$1F6, -$62,  $1F6, -$62  ; 24
		dc.w  -$1F6,  $62,  $1F6,  $62,  -$1A8, $11C,  $1A8, $11C  ; 28
		dc.w  -$11C, $1A8,  $11C, $1A8,   -$62, $156,   $62, $156  ; 32

; ===========================================================================

RLoss_Bounce:	; Routine 2
		; SpeedToPos (inlined, optimized)
		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift X up a byte (positions are 16.16 fixed)
		add.l	d0,obX(a0)				; update X-position
		asl.l	#8,d2					; shift Y speed up a byte
		add.l	d2,obY(a0)				; update Y-position

		; apply gravity
		move.w	#$18,d0					; set basic fall velocity
		tst.b	(f_water).w				; does level have water?
		beq.s	.aboveWater				; if not, branch
		move.w	(v_waterpos1).w,d1			; get current water position
		cmp.w	obY(a0),d1				; is ring below water?
		bcc.s	.aboveWater				; if not, branch
		moveq	#$18/2,d0				; use slower fall speed
	.aboveWater:
		add.w	d0,obVelY(a0)				; add fall speed to current Y velocity
		bmi.s	.chkdel					; is ring still going upwards? if yes, skip floor collision check
	
		; floor collision check
		move.b	(v_vblank_byte).w,d0			; get VBlank counter byte
		add.b	d7,d0					; add object RAM index as crude spreading-out of collision check over multiple frames
		andi.b	#3,d0					; only check for floor collision every 4th frame
		bne.s	.chkdel					; if on any other frame, branch
	
		jsr	(ObjFloorDist).l			; calculate distance between this ring and the floor
		tst.w	d1					; has ring hit the floor?
		bpl.s	.chkdel					; if not, branch
		add.w	d1,obY(a0)				; ring hit the floor, align it to the surface
		move.w	obVelY(a0),d0				; get current ring fall speed
		asr.w	#2,d0					; divide it by 4
		sub.w	d0,obVelY(a0)				; subtract that result from the previous speed to make it bounce less
		neg.w	obVelY(a0)				; negate fall speed to make ring bounce up

	.chkdel:
		; check if ring should be deleted
		subq.b	#1,obDelayAni(a0)			; decrement remaining time for bouncing ring
		beq.w	DeleteObject				; if time reached zero, delete ring

		move.w	(v_limitbtm2).w,d0			; get current bottom level boundary
		addi.w	#224,d0					; add vertical screen height
		cmp.w	obY(a0),d0				; has object moved below the bottom level boundary?
		blt.s	RLoss_Delete				; if yes, delete ring
		bra.w	DisplaySprite				; display this ring
; ===========================================================================

RLoss_Collect:	; Routine 4 (set from ReactToItem)
		addq.b	#2,obRoutine(a0)			; advance to RLoss_Sparkle
		move.b	#col_none,obColType(a0)			; prevent ring from being collected again
		move.b	#1,obPriority(a0)			; make ring sparkles appear in front of Sonic's sprites
		bsr.w	CollectRing				; add 1 ring 
; ---------------------------------------------------------------------------

RLoss_Sparkle:	; Routine 6
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; reset art tile for sparkle animation
		lea	(Ani_Ring).l,a1				; get ring animation script
		bsr.w	AnimateSprite				; advance ring animation
		bra.w	DisplaySprite				; display ring sprite
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject				; delete this ring


; ===========================================================================
; ---------------------------------------------------------------------------
; Attracted rings (set from S3K Rings Manager => AttractRing)
; ---------------------------------------------------------------------------

RLoss_Attract_Init:	; Routine A
		bsr.w	Ring_Setup_Self				; set up maps etc.
; ---------------------------------------------------------------------------

RLoss_Attract_Main:	; Routine C
		tst.b	(v_shield).w				; does Sonic still have a shield?
		bne.s	.attract				; if yes, keep attracting ring

		; Make rings bounce away at their current speed if Sonic lost his shield
		move.b	#2,obRoutine(a0)			; change ring to RLoss_Bounce routine
		move.b	#255,d0					; set both timers to 255 frames
		move.b	d0,obDelayAni(a0)			; set ring despawn timer
		move.b	d0,(v_ani3_time).w			; set animation timer
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

		jsr	(SpeedToPos).l				; translate speed to current position
		bra.w	DisplaySprite				; display ring sprite
; ===========================================================================

		include	"_anim/Rings.asm"
Map_Ring:	include	"_maps/Rings.asm"