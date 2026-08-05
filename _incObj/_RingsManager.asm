; ===========================================================================
; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen as you move
; through the level, and otherwise updates them.
;
; Taken from Sonic 2, upgraded to S3K equivalent (with further optimizations).
;
; v_ringstates_pointer = address within v_ringstates RAM of the first ring found within left screen boundary
; v_ringwindow_start   = address in ROM ring layout of the first ring found within left screen boundary
; v_ringwindow_end     = address in ROM ring layout of the first ring found beyond right screen boundary
; v_ringanimqueue      = queue of recently collected rings storing pointers pointing inside v_ringstates
; Note: v_ringstart_addr_ROM and v_ringstart_addr_RAM will both point to data of the same ring.
;
; Each ring stored in ROM is 4 bytes, two per X/Y-axis [XXXX YYYY].
; Each ring stored in v_ringstates is 2 bytes:
; - 0000 => Uncollected rings. They use one frame, which is dynamically altered by the animated art in VRAM.
; - 0604 => (Or any other positive values) Recently collected rings set to play the sparkle animation.
; - FFFF => Collected and gone ring ("destroyed"). Gets set after sparkle animation finished playing.
; The format for the sparkle animation is [TTFF]: TT = timer counting down each frame, FF = frame ID incrementing.
; ----------------------------------------------------------------------------

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to initialize rings manager on level start (S3K Rings Manager)
; ---------------------------------------------------------------------------

RingsManager_Init:
		; clear ring manager RAM
		clearRAM v_ringmanager,(v_ringmanager+v_ringmanager_size)

		; load ring positions for this level
		moveq	#0,d0					; clear d0
		move.w	(v_zone_act).w,d0			; get current zone and act
		ror.b	#2,d0					; shift act number to upper bits in lower byte
		lsr.w	#4,d0					; shift zone and act for long-based indexing
		lea	(RingPos_Index).l,a1			; load ring position data from ROM
		movea.l	(a1,d0.w),a1				; get ring position data for current level
		move.l	a1,(v_ringwindow_start).w		; set starting address in ROM
; ---------------------------------------------------------------------------

RingsManager_FindStartAndEnd_Init:
		lea	(v_ringstates).w,a2			; load ring status table to a2
		move.w	(v_screenposx).w,d4			; get left-most pixel displayed
		subq.w	#16/2,d4				; d4 = v_screenposx - 8px (half width of rings)

RingsManager_FindStart_Init:
		; find first currently visible ring in position data
		bhi.s	.start					; branch if valid (greater than 0)
		moveq	#1,d4					; no negative values allowed
		bra.s	.start					; begin searching for first visible ring
	.loop:
		addq.w	#4,a1					; load next ring from ROM
		addq.w	#1,a2					; load next ring status from RAM
	.start:	cmp.w	(a1),d4					; is this ring right of left screen boundary?
		bhi.s	.loop					; if not, check next ring (ring is left of left boundary)

		move.l	a1,(v_ringwindow_start).w		; set start position of currently visible rings in ROM
		move.w	a2,(v_ringstates_pointer).w		; do the same for the ring states table

RingsManager_FindEnd_Init:
		; find last currently visible ring in position data
		addi.w	#320+16,d4				; advance by screen width screen + 16px (ring width)
		bra.s	.start					; begin searching for last visible ring
	.loop:
		addq.w	#4,a1					; load next ring from ROM
	.start:	cmp.w	(a1),d4					; is ring past right screen boundary?
		bhi.s	.loop					; if not, check next
		move.l	a1,(v_ringwindow_end).w			; set end position of currently visible rings in ROM

		rts						; ring manager init done
; End of function RingsManager_Init

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to run advance rings data as level scrolls (S3K Rings Manager)
; ---------------------------------------------------------------------------

RingsManager:
		; animate ring sparkle for recently collected rings
		move.w	(v_ringanimqueue_count).w,d1		; get number of recently collected rings
		subq.w	#1,d1					; do we have any recently collected rings that need sparkling?
		bcs.s	RingsManager_FindCurrentStartAndEnd	; if not, no animations necessary
		lea	(v_ringanimqueue).w,a2			; load animation data for recently collected rings (for sparkle)

	.loop:
		move.w	(a2)+,d0				; is there a collected ring in this slot?
		beq.s	.loop					; if not, loop until one is found
		movea.w	d0,a1					; load ring address to an address register so we can work with it

		move.b	(a1),d0					; get ring collection animation state for this ring
		subi.b	#$10,d0					; decrement sparkle animation delay timer (upper nybble)
		bcc.s	.updateState				; if time remains, branch
		addi.b	#$10+$60,d0				; undo last decrement and reset animation delay to 6 frames
		move.b	d0,d2					; copy for below
		andi.b	#$F0,d0					; limit d0 to just the timer (upper nybble)
		andi.b	#$0F,d2					; limit d2 to just the frame ID (lower nybble)
		addq.b	#1,d2					; go to next ring sparkle frame
		cmpi.b	#7,d2					; is it destruction time? (last sparkle frame is 7, zero-based)
		bls.s	.updateFrame				; if not, branch
		clr.w	-2(a2)					; delete entry from animation queue
		subq.w	#1,(v_ringanimqueue_count).w		; decrement count of rings in animation queue
		moveq	#-1,d0					; destroy ring inside ring status table
	.updateFrame:
		or.b	d2,d0					; merge animation timer and frame ID
	.updateState:
		move.b	d0,(a1)					; update ring state in status table

	.next:
		dbf	d1,.loop				; loop for all rings that need to sparkle
; ---------------------------------------------------------------------------

RingsManager_FindCurrentStartAndEnd:
		movea.l	(v_ringwindow_start).w,a1		; load current start of ring layout in ROM
		movea.w	(v_ringstates_pointer).w,a2		; load current start of ring status table
		move.w	(v_screenposx).w,d4			; get left-most pixel displayed
		subq.w	#16/2,d4				; d4 = v_screenposx - 8px (half width of rings)

RingsManager_FindStart_Forwards:
		; update ring data start address(es) as level scrolls right
		bhi.s	.start					; branch if valid (greater than 0)
		moveq	#1,d4					; no negative values allowed
		bra.s	.start					; begin searching for first visible ring
	.loop:
		addq.w	#4,a1					; load next ring from ROM
		addq.w	#1,a2					; load next ring status from RAM
	.start:	cmp.w	(a1),d4					; is this ring left of left screen boundary?
		bhi.s	.loop					; if yes, loop to check next ring (level is going forwards)

RingsManager_FindStart_Backwards:
		; update ring data start address(es) as level scrolls left
		bra.s	.start					; begin backwards search
	.loop:
		subq.w	#4,a1					; load previous ring from ROM
		subq.w	#1,a2					; load previous ring status from RAM
	.start:	cmp.w	-4(a1),d4				; is previous ring right of left screen boundary?
		bls.s	.loop					; if yes, loop to check previous ring (level is going backwards)

		move.l	a1,(v_ringwindow_start).w		; update start position of currently visible rings in ROM
		move.w	a2,(v_ringstates_pointer).w		; do the same for the ring states table
; ---------------------------------------------------------------------------

RingsManager_FindEnd_Forwards:
		; update ring data end address as level scrolls right
		movea.l	(v_ringwindow_end).w,a2			; load ring layout end address
		addi.w	#320+16,d4				; advance by screen width screen + 16px (ring width)
		bra.s	.start					; begin searching for last visible ring
	.loop:
		addq.w	#4,a2					; load next ring from ROM
	.start:	cmp.w	(a2),d4					; is this ring left of right screen boundary?
		bhi.s	.loop					; if yes, loop to check next ring (level is going forwards)

RingsManager_FindEnd_Backwards:
		; update ring data end address as level scrolls left
		bra.s	.start					; begin backwards search
	.loop:
		subq.w	#4,a2					; load previous ring from ROM
	.start:	cmp.w	-4(a2),d4				; is previous ring right of right screen boundary?
		bls.s	.loop					; if yes, loop to check previous ring (level is going backwards)

		move.l	a2,(v_ringwindow_end).w			; set end position of currently visible rings in ROM
		rts						; rings manager window update done
; End of function RingsManager

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to allow Sonic collecting level rings (S3K Rings Manager)
; 
; input:
;	a0 = v_player (Sonic)
; ---------------------------------------------------------------------------

Touch_Rings:
		cmpi.w	#90,flashtime(a0)			; has Sonic recently been hurt and is still flashing? (1.5 seconds left)
		bhs.w	Touch_Rings_return			; if yes, prevent picking up rings

		movea.l	(v_ringwindow_start).w,a1		; load ring layout start address
		movea.l	(v_ringwindow_end).w,a2			; load ring layout end address
		cmpa.l	a1,a2					; are there rings in this area?
		beq.w	Touch_Rings_return			; if not, nothing to do
		movea.w	(v_ringstates_pointer).w,a4		; load ring status start address

	if Enable_AttractRings
		tst.b	(v_shield).w				; does Sonic have a shield?
		beq.s	Touch_Rings_Normal			; if not, branch
		move.w	obX(a0),d2				; get Sonic's current X-position
		move.w	obY(a0),d3				; get Sonic's current Y-position
		subi.w	#128/2,d2				; adjust left for horizontal radius
		subi.w	#128/2,d3				; adjust up for vertical radius
		move.w	#(128*2)/2,d4				; set Sonic's X diameter 
		move.w	#(128*2)/2,d5				; set Sonic's Y diameter
		moveq	#12/2,d1				; set ring radius
		moveq	#(12*2)/2,d6				; set ring diameter
		bra.s	Touch_Rings_Loop			; skip regular ring collection check
	endif
		
Touch_Rings_Normal:
		; this is a modified copy of the start of ReactToItem
		move.w	obX(a0),d2				; load Sonic's x-axis position
		move.w	obY(a0),d3				; load Sonic's y-axis position
		subi.w	#sonic_react_width,d2			; d2 = X-position of Sonic's left edge
		moveq	#0,d5					; clear d5
		move.b	obHeight(a0),d5				; load Sonic's height
		subq.b	#3,d5					; shrink by 3px
		sub.w	d5,d3					; d3 = Y-position of Sonic's top edge
		cmpi.b	#id_Duck,obAnim(a0)			; is Sonic in his ducking animation?
		bne.s	.notDucking				; if not, branch
		addi.w	#((sonic_height-3)-sonic_duck_height)*2,d3 ; adjust Y-position of Sonic's top edge when ducking
		moveq	#sonic_duck_height,d5			; use alternate hitbox extent
	.notDucking:
		move.w	#sonic_react_width*2,d4			; d4 = Sonic's hitbox width
		add.w	d5,d5					; d5 = Sonic's hitbox height
		moveq	#12/2,d1				; set ring radius
		moveq	#(12*2)/2,d6				; set ring diameter
; ---------------------------------------------------------------------------

Touch_Rings_Loop:
		tst.b	(a4)					; has this an active ring? (not collected yet)
		bne.s	Touch_Rings_Next			; if not, skip checking it

	.checkX:
		move.w	(a1),d0					; get ring X pos
		sub.w	d1,d0					; get ring left edge X pos
		sub.w	d2,d0					; subtract Sonic's left edge X pos
		bhs.s	.sonicLeft				; if Sonic's to the left of the ring, branch
		add.w	d6,d0					; add ring diameter
		blo.s	.checkY					; if Sonic's is in X range of ring, check for Y next
		bra.s	Touch_Rings_Next			; otherwise, test next ring
	.sonicLeft:
		cmp.w	d4,d0					; is horizontal separation greater than Sonic's width?
		bhi.s	Touch_Rings_Next			; if yes, ring is not in collision range

	.checkY:
		move.w	2(a1),d0				; get ring Y pos
		sub.w	d1,d0					; get ring top edge pos
		sub.w	d3,d0					; subtract Sonic's top edge pos
		bhs.s	.sonicAbove				; if Sonic's above the ring, branch
		add.w	d6,d0					; add ring diameter
		blo.s	Touch_Rings_Collect_CheckShield		; if Sonic's is in Y range of ring as well, collect ring
		bra.s	Touch_Rings_Next			; otherwise, test next ring
	.sonicAbove:
		cmp.w	d5,d0					; is vertical separation greater than Sonic's height?
		bhi.s	Touch_Rings_Next			; if yes, ring is not in collision range
; ---------------------------------------------------------------------------

Touch_Rings_Collect_CheckShield:
	if Enable_AttractRings
		tst.b	(v_shield).w				; does Sonic have a shield?
		bne.s	AttractRing				; if yes, attract ring
	endif

Touch_Rings_Collect:
		move.b	#$64,(a4)				; set initial sparkle animation delay (6) and sparkle frame ID (4)
		bsr.w	CollectRing				; add 1 ring

		; queue ring sparkle animation
		lea	(v_ringanimqueue).w,a3			; load animation data for recently collected rings (for sparkle)
	.loop:	tst.w	(a3)+					; is this animation slot free?
		bne.s	.loop					; if not, loop until free slot is found
		move.w	a4,-(a3)				; store ring address for animation slot
		addq.w	#1,(v_ringanimqueue_count).w		; increase count for currently sparkling rings

Touch_Rings_Next:
		addq.w	#4,a1					; load next ring from ROM
		addq.w	#1,a4					; load next ring status from RAM
		cmpa.l	a1,a2					; are we at the last ring for this area?
		bne.s	Touch_Rings_Loop			; if not, for more rings

Touch_Rings_return:
		rts						; ring manager touch response done
; ===========================================================================

	if Enable_AttractRings
AttractRing:
		movea.l	a1,a3					; backup address of current ring (a1 gets overwritten in FindFreeObj)
		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.failAttract				; if object RAM is full, branch
		move.b	#id_RingLoss,(a1)			; load a new individual ring object
		move.b	#$A,obRoutine(a1)			; set to "Rings_Attracted" routine
		move.w	(a3),obX(a1)				; set X-position of object based on X-position in table
		move.w	2(a3),obY(a1)				; do the same for the Y-position
		move.b	#-1,(a4)				; destroy ring inside ring status table
		rts						; exit ring manager (only one new attracted ring per frame)
; ---------------------------------------------------------------------------
		
	.failAttract:
		movea.l	a3,a1					; restore previous ring pointer
		bra.s	Touch_Rings_Collect			; try continuing with regular rings manager
	endif
; End of function Touch_Rings

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to render ring sprites, called from BuildSprites.
; 
; input/output:
; 	a2 = v_spritetablebuffer
;	d5 = counter for rendered sprites
; ---------------------------------------------------------------------------

BuildRings:
		movea.l	(v_ringwindow_start).w,a0		; load start of ring layout in ROM
		move.l	(v_ringwindow_end).w,d7			; load ring layout end address
		sub.l	a0,d7					; is start = end?
		beq.s	.return					; if yes, nothing to do (no rings on-screen)

		movea.w	(v_ringstates_pointer).w,a4		; load ring status start address
		lea	(v_screenposx).w,a3			; load camera X-position

	.loop:
		cmpi.b	#sprites_max,d5				; has the sprite limit of 80 been reached?
		bhs.s	.return					; if yes, abort drawing more sprites to avoid corruption

		move.b	(a4)+,d1				; has this ring been collected and finished sparkling?
		bmi.w	.next					; if yes, check next ring
		move.w	(a0),d3					; get ring X-position
		sub.w	(a3),d3					; subtract camera X-position
		addi.w	#$80-8,d3				; add VDP sprite start - half of ring width (16/2 = 8px)

		move.w	2(a0),d2				; get ring Y-position
		sub.w	4(a3),d2				; subtract camera Y-position (4(a3) = v_screenposy)
		addi.w	#8,d2					; add half of ring height (16/2 = 8px)
		andi.w	#$7FF,d2				; apply vertical screen wrap
		cmpi.w	#224+16,d2				; is ring below visible screen?
		bhs.s	.next					; if yes, don't render
		addi.w	#$80-8-8,d2				; add VDP sprite start and undo earlier 8px offset

		move.w	d2,(a2)+				; store sprite Y-position in sprite buffer

		andi.w	#$000F,d1				; extract stored ring frame value
		bne.s	.renderRing				; does this ring have a custom frame ID? if yes, use that (sparkle for collected rings)
		moveq	#0,d1					; force frame 0 for all smooth ring frames (updated in VRAM)
	.renderRing:
		move.b	#5,(a2)+				; store sprite width/height in sprite buffer

		addq.b	#1,d5					; increase total sprites counter
		move.b	d5,(a2)+				; store sprite link in sprite buffer

		add.w	d1,d1					; double frame ID for word-based indexing
		move.w	Map_RingsCompact(pc,d1.w),(a2)+		; get VRAM settings and store in sprite buffer

		move.w	d3,(a2)+				; store sprite X-position in sprite buffer

	.next:
		addq.w	#4,a0					; advance to next ring in ROM
		subq.w	#4,d7					; decrement number of remaining rings to handle
		bne.w	.loop					; if we've got more rings to render, loop

	.return:
		rts						; rings manager rings sprite rendering done
; End of function BuildRings

; ---------------------------------------------------------------------------

; Compact rings mappings for optimization purposes
Map_RingsCompact:
		dc.w ArtTile_Ring+$0|Tile_Pal2			; 0 - ring
		dc.w ArtTile_Ring+$4|Tile_Pal2			; 1 - ring
		dc.w ArtTile_Ring+$8|Tile_Pal2			; 2 - ring
		dc.w ArtTile_Ring+$4|Tile_Pal2|$800		; 3 - ring
			     
		dc.w ArtTile_Ring+$A|Tile_Pal2			; 4 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$1800		; 5 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$0800		; 6 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$1000		; 7 - sparkle

		dc.w 0, 0					; blank frames in case of overflow

; ===========================================================================

BuildRings_Loss:
		tst.w	(v_ani3_time).w
		beq.w	.return


		lea	(v_lvlobjspace).w,a4
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1-1,d7

		lea	(v_screenposx).w,a3			; load camera X-position

	.loop:
		tst.b	obRoutine(a4)
		bne.s	.next
		cmpi.b	#id_RingLoss,(a4)
		bne.s	.next

		cmpi.b	#sprites_max,d5				; has the sprite limit of 80 been reached?
		bhs.s	.return					; if yes, abort drawing more sprites to avoid corruption

		move.w	obX(a4),d3				; get ring X-position
		sub.w	(a3),d3					; subtract camera X-position
		addi.w	#8,d3
		cmpi.w	#320+16,d3
		bhs.s	.next
		addi.w	#$80-8-8,d3

		move.w	obY(a4),d2				; get ring Y-position
		sub.w	4(a3),d2				; subtract camera Y-position (4(a3) = v_screenposy)
		addi.w	#8,d2					; add half of ring height (16/2 = 8px)
		andi.w	#$7FF,d2				; apply vertical screen wrap
		cmpi.w	#224+16,d2				; is ring below visible screen?
		bhs.s	.next					; if yes, don't render
		addi.w	#$80-8-8,d2				; add VDP sprite start and undo earlier 8px offset

		move.w	d2,(a2)+				; store sprite Y-position in sprite buffer

		move.b	#5,(a2)+				; store sprite width/height in sprite buffer

		addq.b	#1,d5					; increase total sprites counter
		move.b	d5,(a2)+				; store sprite link in sprite buffer

		move.w	#ArtTile_Ring_Loss|Tile_Pal2,(a2)+	; get VRAM settings and store in sprite buffer

		move.w	d3,(a2)+				; store sprite X-position in sprite buffer

	.next:
		lea	object_size(a4),a4
		dbf	d7,.loop					; if we've got more rings to render, loop

	.return:
		rts
; End of function BuildRings_Loss
