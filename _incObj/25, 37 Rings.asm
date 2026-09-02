; ===========================================================================
; ---------------------------------------------------------------------------
; Object 25 - standalone rings
; 
; With the introduction of the S3K rings manager, these are rarely
; used anymore, mainly only in case rings get placed in debug mode.
; Note that these standalone rings cannot be attracted by a shield.
; ---------------------------------------------------------------------------

Rings:
		move.l	#Ring_Animate,obID(a0)
		move.l	#Map_Ring,obMap(a0)			; set mappings
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; set art tile and palette line
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio2,obPriority(a0)		; set sprite priority
		move.b	#col_12x12|col_item,obColType(a0)	; set to power-up collision type and hitbox 12x12 (=$47)
		move.b	#16/2,obActWid(a0)			; set sprite display width
; ---------------------------------------------------------------------------

Ring_Animate:
		out_of_range.s	Ring_Delete			; has ring gone out of range? if yes, delete it
		bra.s	Ring_Display
; ===========================================================================

; Set from ReactToItem if ring was touched (except for S3K Ring Manager rings!)
Ring_Collect:
		bsr.w	CollectRing				; add 1 ring
		; continue to Ring_Sparkle_Init...
; ---------------------------------------------------------------------------

Ring_Sparkle_Init:
		move.l	#Ring_Sparkle_Main,obID(a0)		; advance to Ring_Sparkle_Main
		move.l	#Map_Ring,obMap(a0)			; set mappings
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; reset art tile for sparkle animation
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio1,obPriority(a0)		; make ring sparkles appear in front of Sonic's sprites
		move.b	#16/2,obActWid(a0)			; set sprite display width
		clr.b	obColType(a0)				; prevent ring from being collected again
		clr.b	obFrame(a0)				; start at frame 0
		clr.b	obDelayAni(a0)				; force first animation advancement
; ---------------------------------------------------------------------------

Ring_Sparkle_Main:
		subq.b	#1,obDelayAni(a0)			; decrement sparkle animation interval
		bpl.s	Ring_Display				; if time remains, branch
		addq.b	#1,obFrame(a0)				; go to next frame
		cmpi.b	#4,obFrame(a0)				; has final sparkle frame been exceeded?
		bhi.s	Ring_Delete				; if yes, delete sparkle object
		move.b	#6-1,obDelayAni(a0)			; reset animation interval
; ---------------------------------------------------------------------------

Ring_Display:
		DisplaySprite					; display ring sparkle
		rts
; ===========================================================================

Ring_Delete:
		jmp	(DeleteObject).l			; delete ring or ring sparkle object


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic when he's hit
; 
; GREATLY optimized, with lots of in-lined code, preshifted velocities,
; and its own, separate ring collection and sprite rendering systems.
; ---------------------------------------------------------------------------
rloss_velX:	equ	objoff_32				; X-speed of lost ring (long, preshifted <<8)
rloss_velY:	equ	objoff_36				; Y-speed of lost ring (long, preshifted <<8)
; ---------------------------------------------------------------------------

RingLoss_Shortcut:
		lea	object_size(a0),a0			; advance to next object RAM slot (assumed to be another RingLoss, see .shortcut below)
; ---------------------------------------------------------------------------

RingLoss:

; Apply gravity and delete ring if it has gone below the level boundary
.speedToPosAndFall:
		move.l	rloss_velY(a0),d1			; get ring's current Y-speed
		addi.l	#$1800,d1				; increase falling speed
		move.l	obY(a0),d2				; get ring's current Y-position
		add.l	d1,d2					; add Y-speed to Y-position
		cmp.l	(v_limitbtm3).w,d2			; has ring moved below the bottom level boundary?
		bge.s	Ring_Delete				; if yes, delete ring
		move.l	d2,obY(a0)				; update Y-position
		move.l	d1,rloss_velY(a0)			; update Y-speed

		move.l	rloss_velX(a0),d3			; keep updating horizontal position at unchanging speed
		add.l	d3,obX(a0)				; add X-speed to X-position

; Decrement lifetime, delete if expired, flicker if one second before expiring
.lifetimeAndFlash:
		move.b	obDelayAni(a0),d0			; get remaining lifetime for ring
		subq.b	#1,d0					; decrement remaining lifetime
		beq.w	Ring_Delete				; if time reached zero, delete ring
		move.b	d0,obDelayAni(a0)			; update remaining lifetime
		cmpi.b	#60,d0					; is remaining lifetime less than 1 second?
		bhi.s	.checkOnScreen				; if not, branch
		andi.b	#1,d0					; flicker ring on every other frame
		bne.w	.checkFloorBounce			; skip rendering on odd frame	

; Calculate sprite position, skip touch check if already known to be offscreen
.checkOnScreen:
		move.w	obY(a0),d5				; get ring's current Y-position
		sub.w	(v_screenposy).w,d5			; subtract camera Y-position
		addq.w	#16/2,d5				; add half of ring height (16/2 = 8px)
		cmpi.w	#224+16,d5				; is ring vertically inside visible screen?
		bcc.s	.checkFloorBounce			; if not, don't render (unsigned check = both sides)
		subi.w	#16-$80,d5				; add VDP sprite start and undo earlier 8px offset
		swap	d5					; Y-position is written with X-position into v_lostring_spritequeue later

		move.w	obX(a0),d5				; get ring's current X-position
		sub.w	(v_screenposx).w,d5			; subtract camera X-position
		addq.w	#16/2,d5				; add half of ring width (16/2 = 8px)
		cmpi.w	#320+16,d5				; is ring horizontally inside visible screen?
		bcc.s	.checkFloorBounce			; if not, don't render (unsigned check = both sides)
		subi.w	#16-$80,d5				; add VDP sprite start and undo earlier 8px offset

; Touch check against Sonic, collect if so (this is an in-lined and trimmed-down ReactToItem)
.checkTouch:
		moveq	#sonic_react_width-(16/2),d0		; set Sonic's collesion width, adjusted by ring radius
		add.w	obX(a0),d0				; get ring's current X-position
		sub.w	(v_player+obX).w,d0			; load Sonic's x-axis position
		bhs.s	.left					; branch if Sonic is to the left of ring
		addi.w	#16,d0					; add width to get distance between right and left edges
		blo.s	.checkYOverlap				; branch if hitboxes overlap horizontally
		bra.s	.renderLostRingSprite			; otherwise, ring is not in collision range
	.left:	cmpi.w	#sonic_react_width*2,d0			; is horizontal separation greater than Sonic's width?
		bhi.s	.renderLostRingSprite			; if yes, ring is not in collision range

	.checkYOverlap:
		moveq	#0,d1					; clear d1
		move.b	(v_player+obHeight).w,d1		; load Sonic's height
		subq.b	#3,d1					; shrink by 3px
		moveq	#-16/2,d0				; get ring's top edge
		add.w	obY(a0),d0				; get ring's current Y-position
		add.w	d1,d0					; d3 = Y-position of Sonic's top edge
		sub.w	(v_player+obY).w,d0			; compare against Sonic's top edge
		bhs.s	.above					; branch if Sonic is above the ring
		addi.w	#16,d0					; add height to get distance between bottom and top edges
		blo.s	.ringTouched				; branch if hitboxes overlap vertically
		bra.s	.renderLostRingSprite			; otherwise, ring is not in collision range
	.above:	add.w	d1,d1					; d1 = Sonic's hitbox height
		cmp.w	d1,d0					; is vertical separation greater than Sonic's height?
		bhi.s	.renderLostRingSprite			; if yes, ring is not in collision range

	.ringTouched:
	;	cmpi.b	#90,(v_player+flashtime).w		; are more than 1.5s of invulnerability time from getting hurt left?
	;	bhs.s	.renderLostRingSprite			; if yes, disallow collecting ring
		tst.b	(v_debuguse).w				; is debug mode in use?
		bne.s	.renderLostRingSprite			; if yes, prevent ring collection
		cmpi.b	#2,(v_player+obRoutine).w		; is Sonic in his normal mode? (Sonic_Control)
		beq.w	Ring_Collect				; if yes, collect lost ring

; Lost ring is on screen but not touched, queue for custom sprite rendering
.renderLostRingSprite:
		lea	(v_lostring_spritequeue).w,a1		; get target sprite queue
		move.w	(a1),d0					; get sprite queue's entry count
		addq.b	#4,d0					; increase count by another entry (longword)
		bmi.s	.checkFloorBounce			; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new sprite queue's entry count
		move.l	d5,(a1,d0.w)				; write ring's Y and X position (screen-fixed)

; Floor collision check and bounce
.checkFloorBounce:
		move.w	(v_framecount).w,d0			; get frame counter byte
		add.w	d7,d0					; add object RAM index as crude spreading-out of collision check over multiple frames
		andi.w	#3,d0					; only check for floor collision every 4th frame for optimization
		bne.w	.lostRingDone				; branch on other frames
		tst.w	rloss_velY(a0)				; is ring still going upwards?
		bmi.w	.lostRingDone				; if yes, skip floor collision check

		; In-lined and trimmed-down ObjFloorDist
		move.w	obX(a0),d3				; get ring's current X-position
		move.w	obY(a0),d2				; get ring's current Y-position
		addq.w	#16/2,d2				; add ring height (8px)
		move.w	d2,d0					; get Y-position of bottom edge of object
		andi.w	#$700,d0				; read only high byte of Y-position (because each level chunk is 256px tall and level height wraps at $7FF)
		move.w	d3,d1					; get X-position of object
		lsr.w	#8,d1					; shift into lower byte
		andi.w	#$7F,d1					; read only high byte of X-position
		add.w	d1,d0					; combine for position within layout
		moveq	#0,d1					; changed from -1 to 0
		lea	(v_lvllayout_fg).w,a1			; load foreground level layout (chunk arrangements)
		move.b	(a1,d0.w),d1				; get 256x256 chunk number
		beq.s	.lostRingDone				; branch if 0 (blank chunk)
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
		beq.s	.lostRingDone				; if not, branch
		andi.w	#$7FF,d0				; ignore solid/orientation bits
		movea.l	(v_collindex).w,a2
		move.b	(a2,d0.w),d0				; get collision heightmap id
		andi.w	#$FF,d0					; heightmap id is 1 byte
		beq.s	.lostRingDone				; branch if 0
		lsl.w	#4,d0					; d0 = heightmap id * $10 (the width of a heightmap for 1 block)
		move.w	d3,d1					; get X-position of object
		andi.w	#$F,d1					; read only low nybble of X-position (i.e. X-position within 16x16 block)
		add.w	d0,d1					; (id * $10) + X-position. = place in heightmap data
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0				; get actual height value from heightmap
		beq.s	.lostRingDone				; branch if height is 0
		ext.w	d0
		move.w	d2,d1					; get Y-position of object
		andi.w	#$F,d1					; read only low nybble for Y-position within 16x16 block
		add.w	d1,d0
		moveq	#$F,d1
		sub.w	d0,d1					; return distance to floor
		; End of in-lined ObjFloorDist

		add.w	d1,obY(a0)				; ring hit the floor, align it to the surface
		move.l	rloss_velY(a0),d0			; get current ring fall speed
		asr.l	#2,d0					; divide it by 4
		sub.l	#$1800*3,d0				; add a bit of extra bounce so rings don't glide on the floor
		sub.l	d0,rloss_velY(a0)			; subtract that result from the previous speed to make it bounce less
		neg.l	rloss_velY(a0)				; negate fall speed to make ring bounce up


; If the next object in RAM is another lost ring, go there immediately as a shortcut (dirty optimization!)
.lostRingDone:
		cmpi.l	#RingLoss,object_size(a0)		; is the adjacent object in object RAM another ring loss object?
		bne.s	.exit					; if not, return to regular ExecuteObjects loop
		dbf	d7,RingLoss_Shortcut			; otherwise, decrement d7 (remaining objects in ExecuteObjects loop), if non-zero, shortcut
	.exit:	rts						; return to ExecuteObjects loop
; End of function RingLoss


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to spawn lost ring objects when hurt (called from ReactToItem).
; 
; input:
;	a0 = v_player
;	a2 = damaging object (must not be touched!)
; 	d5 = Number of lost rings to spawn (will be capped to 32)
; ---------------------------------------------------------------------------

RLoss_SpawnRings:
		moveq	#32,d0					; set maximum rings allowed to be spilled to 32
		cmp.w	d0,d5					; do you more than 32 rings?
		blo.s	.ok					; if not, branch
		move.w	d0,d5					; if yes, cap spilled ring count to 32
	.ok:	subq.w	#1,d5					; decrement for dbf
		bmi.s	.return					; if we have no rings, abort (failsafe)

		move.l	#RingLoss,d4				; load ring loss objects
		move.w	obX(a0),d2				; spawn rings at Sonic's X-position
		move.w	obY(a0),d3				; spawn rings at Sonic's Y-position
		lea	SpillRingData(pc),a3			; load pre-calculated spill velocities
		
		lea	(v_lvlobjspace).w,a1			; set start of level object RAM
		moveq	#(v_objspace_end-v_lvlobjspace)/object_size-1,d0 ; set iteration count

.loopSpawnLostRings:
		tst.l	(a1)					; is this object slot free?
		beq.s	.makeRing				; if yes, load lost ring into there
		lea	object_size(a1),a1			; otherwise, advance to next object slot...
		dbf	d0,.loopSpawnLostRings			; ...and try again
		bra.s	.return					; if we landed here, level object RAM is full, abort loading rings
	.makeRing:
		move.l	d4,obID(a1)				; load RingLoss object
		move.w	d2,obX(a1)				; copy parent X-position
		move.w	d3,obY(a1)				; copy parent Y-position
		move.l	(a3)+,rloss_velX(a1)			; load next start X-speed
		move.l	(a3)+,rloss_velY(a1)			; load next start Y-speed
		dbf	d5,.loopSpawnLostRings			; repeat for number of spilled rings (max 31)

		move.w	a1,(v_firstfreeobjslot).w		; update lowest free object for future FindFreeObj optimization

	.return:
		rts						; spawning done
; ---------------------------------------------------------------------------

; Precalculated spilled rings velocities, preshifted by <<8 for optimization.
SpillRingData:
		dc.l   -$C400,-$3EC00,   $C400,-$3EC00,  -$23800,-$35000,  $23800,-$35000  ; 4
		dc.l  -$35000,-$23800,  $35000,-$23800,  -$3EC00, -$C400,  $3EC00, -$C400  ; 8
		dc.l  -$3EC00,  $C400,  $3EC00,  $C400,  -$35000, $23800,  $35000, $23800  ; 12
		dc.l  -$23800, $35000,  $23800, $35000,   -$C400, $3EC00,   $C400, $3EC00  ; 16
		dc.l   -$6200,-$1F600,   $6200,-$1F600,  -$11C00,-$1A800,  $11C00,-$1A800  ; 20
		dc.l  -$1A800,-$11C00,  $1A800,-$11C00,  -$1F600, -$6200,  $1F600, -$6200  ; 24
		dc.l  -$1F600,  $6200,  $1F600,  $6200,  -$1A800, $11C00,  $1A800, $11C00  ; 28
		dc.l  -$11C00, $1A800,  $11C00, $1A800,   -$6200, $15600,   $6200, $15600  ; 32
; End of function RLoss_SpawnRings


; ===========================================================================
; ---------------------------------------------------------------------------
; Attracted rings (set from S3K Rings Manager => AttractRing)
; ---------------------------------------------------------------------------

RAttract_Init:
		move.l	#RAttract_Main,obID(a0)			; advance to RAttract_Main
		move.l	#Map_Ring,obMap(a0)			; set mappings
		move.w	#ArtTile_Ring|Tile_Pal2,obGfx(a0)	; special art tile for smooth rings
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio2,obPriority(a0)		; set sprite priority
		move.b	#col_12x12|col_item,obColType(a0)	; set to power-up collision type and hitbox 12x12 (=$47)
		move.b	#16/2,obActWid(a0)			; set sprite display width
; ---------------------------------------------------------------------------

RAttract_Main:
		tst.b	(v_shield).w				; does Sonic still have a shield?
		beq.w	RAttract_ShieldLost			; if not, branch

		move.l	#$30<<8,d2				; set attraction speed (both directions, preshifted for optimization)

		move.l	d2,d1					; set horizontal ring move speed
		lea	(v_player).w,a1				; load Sonic player object
		move.w	obX(a1),d0				; get Sonic's current X-position
		cmp.w	obX(a0),d0				; is attracted ring to the right of Sonic?
		bcc.s	.ringLeft				; if not, branch

	.ringRight:
		neg.l	d1					; move ring to the left instead
		tst.l	rloss_velX(a0)				; is ring already moving left?
		bmi.s	.updateXSpeed				; if yes, branch
		asl.l	#2,d1					; quadruple horizontal speed if ring needs to turn around
		bra.s	.updateXSpeed				; update horizontal speed

	.ringLeft:
		tst.l	rloss_velX(a0)				; is ring already moving right?
		bpl.s	.updateXSpeed				; if yes, branch
		asl.l	#2,d1					; quadruple horizontal speed if ring needs to turn around

	.updateXSpeed:
		add.l	d1,rloss_velX(a0)			; update attracted ring's current X-speed
; ---------------------------------------------------------------------------

		move.l	d2,d1					; set vertical ring move speed
		move.w	obY(a1),d0				; get Sonic's current Y-position
		cmp.w	obY(a0),d0				; is attracted ring below Sonic?
		bcc.s	.ringAbove				; if not, branch

	.ringBelow:
		neg.l	d1					; move right upwards instead
		tst.l	rloss_velY(a0)				; is ring already moving up?
		bmi.s	.updateYSpeed				; if yes, branch
		asl.l	#2,d1					; quadruple vertical speed if ring needs to turn around
		bra.s	.updateYSpeed				; update vertical speed

	.ringAbove:
		tst.l	rloss_velY(a0)				; is ring already moving down?
		bpl.s	.updateYSpeed				; if yes, branch
		asl.l	#2,d1					; quadruple vertical speed if ring needs to turn around

	.updateYSpeed:
		add.l	d1,rloss_velY(a0)			; update attracted ring's current Y-speed
; ---------------------------------------------------------------------------

		move.l	rloss_velX(a0),d0			; get current X-speed
		add.l	d0,obX(a0)				; add Y-speed to current X-position
		move.l	rloss_velY(a0),d1			; get current Y-speed
		add.l	d1,obY(a0)				; add Y-speed to current Y-position

		DisplaySprite					; display attracted ring sprite
		rts
; ===========================================================================

RAttract_ShieldLost:
		move.b	#255,d0					; set both timers to 255 frames
		move.b	d0,obDelayAni(a0)			; set ring despawn timer
		move.b	d0,(v_ani3_time).w			; set animation timer

		move.l	#RingLoss,obID(a0)			; make attracted rings bounce away at their current speed if Sonic lost his shield
		bra.w	RingLoss				; continue straight to ring loss object
; ===========================================================================
