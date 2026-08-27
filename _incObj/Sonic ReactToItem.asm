; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with objects using obColType(a0)
; 
; input:
;	a0 = address of OST of Sonic
; 
; output:
;	d0.l = (unused) -1 if Sonic touches an enemy or harmful object while invincible, or is hurt/killed
;	a2 = address of OST of object hurting/killing Sonic
; ---------------------------------------------------------------------------

ReactToItem:
		jsr	(Touch_Rings).l				; allow Sonic to collect S3K Rings Manager rings

		tst.w	(v_registeredcollision).w		; does collision response queue contain entries?
		bne.s	.queueNotEmpty				; if yes, branch
		rts						; queue is empty, exit early (nothing to do)
.queueNotEmpty:
		move.w	obX(a0),d2				; load Sonic's x-axis position
		move.w	obY(a0),d3				; load Sonic's y-axis position
		subq.w	#sonic_react_width,d2			; d2 = X-position of Sonic's left edge

		moveq	#0,d5					; clear d5
		move.b	obHeight(a0),d5				; load Sonic's height
		subq.b	#3,d5					; shrink by 3px
		sub.w	d5,d3					; d3 = Y-position of Sonic's top edge

		cmpi.b	#id_Duck,obAnim(a0)			; is Sonic in his ducking animation?
		bne.s	.notducking				; if not, branch
		addi.w	#((sonic_height-3)-sonic_duck_height)*2,d3 ; adjust Y-position of Sonic's top edge when ducking
		moveq	#sonic_duck_height,d5			; use alternate hitbox extent
	.notducking:

		move.w	#sonic_react_width*2,d4			; d4 = Sonic's hitbox width
		add.w	d5,d5					; d5 = Sonic's hitbox height

		lea	(v_registeredcollision).w,a3		; load start of register collision objects
		move.w	(a3)+,d6				; get number of entries in queue
		lsr.w	#1,d6					; divide by two (entry count is doubled)
; .loop:
React_LoopObjects:
		move.w	(a3)+,d0				; get next registered object RAM pointer
		beq.s	React_CheckNext				; if slot is empty, skip it
		movea.w	d0,a1					; load pointer to a1
		move.b	obColType(a1),d0			; load object collision type
		bne.s	React_CheckHitboxOverlap		; if valid, begin handling collision response
; .next:
React_CheckNext:
		dbf	d6,React_LoopObjects			; loop for all queued objects

		moveq	#0,d0					; no collision was processed
		rts						; return

; ===========================================================================
;.sizes:
React_Sizes:

; Flags to further split objects into individual property subgroups.
col_none:	equ 0			; marker for no-collision objects
col_badnik:	equ 0			; destroyable badniks
col_boss:	equ 0			; Eggman bosses
col_item:	equ $40			; monitors, rings, giant rings
col_hurt:	equ $80			; damaging objects when touched
col_special:	equ $C0			; objects with special collision properties (Yadrin, Caterkiller, SYZ bumpers)

; Hitbox sizes are stored as box extents (half-width and half-height; similar to radii).
hitbox: macro *,width,height
\*:	equ	(*-React_Sizes)/2+1
		dc.b	width/2, height/2
		endm

		;     width, height
col_40x40:	hitbox	 40, 40		; $01 - GHZ ball
col_24x40:	hitbox	 24, 40		; $02 - (unused)
col_40x24:	hitbox	 40, 24		; $03 - (unused)
col_8x32:	hitbox	  8, 32		; $04 - GHZ spike pole, SYZ boss spike
col_24x36:	hitbox	 24, 36		; $05 - Ball Hog, Burrobot
col_32x32:	hitbox	 32, 32		; $06 - SBZ spikeball, Crabmeat, Monitor, SYZ spikeball, Prison
col_12x12:	hitbox	 12, 12		; $07 - Cannonball, Crab/Buzz missile, Ring
col_48x24:	hitbox	 48, 24		; $08 - Buzz Bomber
col_24x32:	hitbox	 24, 32		; $09 - Chopper
col_32x24:	hitbox	 32, 24		; $0A - Jaws
col_16x16:	hitbox	 16, 16		; $0B - MZ fire, Fireball, Batbrain, LZ spikeball, SLZ seesaw spike, Orbinaut, Caterkiller
col_40x32:	hitbox	 40, 32		; $0C - Newtron, Motobug, Yadrin
col_40x16:	hitbox	 40, 16		; $0D - Newtron
col_28x28:	hitbox	 28, 28		; $0E - Roller
col_48x48:	hitbox	 48, 48		; $0F - Bosses
col_80x32:	hitbox	 80, 32		; $10 - MZ vertical stomper
col_32x48:	hitbox	 32, 48		; $11 - MZ sideways stomper
col_16x32:	hitbox	 16, 32		; $12 - Giant ring
col_64x224:	hitbox	 64,224		; $13 - MZ geyser
col_128x64:	hitbox	128, 64		; $14 - MZ lava wall, MZ lava tag
col_256x64:	hitbox	256, 64		; $15 - MZ lava tag
col_64x64:	hitbox	 64, 64		; $16 - MZ lava tag
col_16x16_alt:	hitbox	 16, 16		; $17 - SYZ bumper
col_8x8:	hitbox	  8,  8		; $18 - SYZ spike chain, Bomb shrapnel, Orbinaut spike, LZ gargoyle fire
col_64x16:	hitbox	 64, 16		; $19 - SLZ swing
col_24x24:	hitbox	 24, 24		; $1A - Bomb enemy, FZ plasma
col_16x8:	hitbox	 16,  8		; $1B - LZ harpoon
col_48x8:	hitbox	 48,  8		; $1C - LZ harpoon
col_80x8:	hitbox	 80,  8		; $1D - LZ harpoon
col_8x16:	hitbox	  8, 16		; $1E - LZ harpoon
col_8x48:	hitbox	  8, 48		; $1F - LZ harpoon
col_8x80:	hitbox	  8, 80		; $20 - LZ harpoon
col_8x64:	hitbox	  8, 64		; $21 - LZ pole
col_48x48_alt:	hitbox	 48, 48		; $22 - SBZ saw
col_24x48:	hitbox	 24, 48		; $23 - SBZ flamethrower
col_144x16:	hitbox	144, 16		; $24 - SBZ electric

; (This list could theoretically go up to $3F entries...)


; ===========================================================================
; ---------------------------------------------------------------------------
; Object has a valid obColType set, check if Sonic is intersecting
; with its hitbox and handle collision if so.
; 
; input:
;	d2 = X-position of Sonic's left edge
;	d3 = Y-position of Sonic's top edge
;	d4 = Sonic's hitbox width
;	d5 = Sonic's hitbox height
;	a0 = OST of Sonic
;	a1 = OST of object to check
; ---------------------------------------------------------------------------

; .proximity:
React_CheckHitboxOverlap:
		andi.w	#$FF-(col_item|col_hurt|col_special),d0	; mask out subgroup bits / limit to $3F entries in React_Sizes
		add.w	d0,d0					; double for word-based indexing
		lea	React_Sizes-2(pc,d0.w),a2		; load React_Sizes array (skip over first entry, colType can't be 0)

.checkXOverlap:
		moveq	#0,d1					; clear d1 (hitbox sizes are stored as bytes)
		move.b	(a2)+,d1				; get object's horizontal hitbox radius
		move.w	obX(a1),d0				; get object's current X-position
		sub.w	d1,d0					; get object's left edge
		sub.w	d2,d0					; compare against Sonic's left edge
		bhs.s	.sonicLeft				; branch if Sonic is to the left of object

		add.w	d1,d1					; convert radius to full width
		add.w	d1,d0					; add width to get distance between right and left edges
		blo.s	.checkYOverlap				; branch if hitboxes overlap horizontally
		bra.w	React_CheckNext				; otherwise, object is not in collision range

	.sonicLeft:
		cmp.w	d4,d0					; is horizontal separation greater than Sonic's width?
		bhi.w	React_CheckNext				; if yes, object is not in collision range
; ---------------------------------------------------------------------------

; .withinx:
.checkYOverlap:
		moveq	#0,d1					; clear d1 (hitbox sizes are stored as bytes)
		move.b	(a2)+,d1				; get object's vertical hitbox radius
		move.w	obY(a1),d0				; get object's current Y-position
		sub.w	d1,d0					; get object's top edge
		sub.w	d3,d0					; compare against Sonic's top edge
		bhs.s	.sonicAbove				; branch if Sonic is above the object

		add.w	d1,d1					; convert radius to full height
		add.w	d0,d1					; add height to get distance between bottom and top edges
		blo.s	React_CollisionDetected			; branch if hitboxes overlap vertically
		bra.w	React_CheckNext				; otherwise, object is not in collision range

	.sonicAbove:
		cmp.w	d5,d0					; is vertical separation greater than Sonic's height?
		bhi.w	React_CheckNext				; if yes, object is not in collision range
		; Continue to React_CollisionDetected...

; ---------------------------------------------------------------------------
; Sonic is touching this object, check what it should do now
; ---------------------------------------------------------------------------

React_CollisionDetected:
		move.b	obColType(a1),d1			; load object collision type
		andi.b	#col_item|col_hurt|col_special,d1	; is obColType $3F or lower?
		beq.w	React_Enemy				; if yes, this is a badnik (col_badnik)
		cmpi.b	#col_special,d1				; is obColType $C0 or higher?
		beq.w	React_Special				; if yes, this is a special object (col_special)
		tst.b	d1					; is obColType $80-$BF?
		bmi.w	React_ChkHurt				; if yes, this is a damaging object (col_hurt)

		; Otherwise, obColType is $40-$7F (col_item)
		move.b	obColType(a1),d0			; reload collision type
		andi.b	#$FF-(col_item|col_hurt|col_special),d0	; mask out special subgroup bits
		cmpi.b	#col_32x32,d0				; has a monitor been touched? ($46)
		beq.s	React_Monitor				; if yes, branch

		; Assume object is a ring (standard, lost, or giant)
	;	cmpi.b	#90,flashtime(a0)			; has Sonic recently been hurt and has more than 90 frames of flashing time left?
	;	bhs.w	.return					; if yes, prevent collecting ring
		addq.b	#2,obRoutine(a1)			; advance the ring's routine counter (e.g. Ring_Collect)

	.return:
		rts						; return


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle touching monitors
; ---------------------------------------------------------------------------

React_Monitor:
		tst.w	obVelY(a0)				; is Sonic moving upwards?
		bpl.s	.chkBreakMonitor			; if not, branch
		btst	#1,obStatus(a0)				; is Sonic in air?
		beq.s	.chkBreakMonitor			; if not, don't bump monitor
		tst.b	doublejump(a0)
		bne.s	.doBreakMonitor

.chkBumpMonitor:
		move.w	obY(a0),d0				; get Sonic's Y-position
		subi.w	#16,d0					; check 16px higher
		cmp.w	obY(a1),d0				; has Sonic touched the monitor from below?
		blo.s	.return					; if not, branch

		neg.w	obVelY(a0)				; reverse Sonic's vertical speed
		move.w	#-$180,obVelY(a1)			; bump monitor upwards a little
		tst.b	ob2ndRout(a1)				; is monitor being stood on or already set to fall?
		bne.s	.return					; if yes, do nothing
		addq.b	#4,ob2ndRout(a1)			; advance the monitor's secondary routine counter to ".fall" state
		rts						; return
; ---------------------------------------------------------------------------

.chkBreakMonitor:
		cmpi.b	#id_Roll,obAnim(a0)			; is Sonic rolling/jumping?
		bne.s	.return					; if not, don't break monitor
		neg.w	obVelY(a0)				; reverse Sonic's y-motion
	.doBreakMonitor:
		addq.b	#2,obRoutine(a1)			; advance the monitor's routine counter
		bsr.w	ResetHomingAttack

	.return:
		rts						; return


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle touching badniks
; ---------------------------------------------------------------------------

React_Enemy:
		tst.b	(v_invinc).w				; is Sonic invincible?
		bne.s	.checkBossHit				; if yes, branch
		cmpi.b	#id_SpinDash,obAnim(a0)			; is Sonic Spin Dashing? 
		beq.s	.checkBossHit				; if yes, branch
		cmpi.b	#id_Roll,obAnim(a0)			; is Sonic rolling/jumping?
		bne.w	React_ChkHurt				; if not, damage Sonic

	.checkBossHit:
		tst.b	obBossHits(a1)				; is target a boss? (has boss HP set)
		beq.s	React_BadnikHit				; if not, it's a badnik

React_BossHit:
		neg.w	obVelX(a0)				; repel Sonic horizontally
		neg.w	obVelY(a0)				; repel Sonic verticallly
		asr.w	obVelX(a0)				; halve current X-speed
		asr.w	obVelY(a0)				; halve current Y-speed
		clr.b	doublejump(a0)
		move.b	#1,jumping(a0)
		move.b	#col_none,obColType(a1)			; set boss to no collision while it's damaged

		subq.b	#1,obBossHits(a1)			; decrement 1 boss HP
		bne.s	.return					; if boss HP remain, branch
		bset	#7,obStatus(a1)				; set flag that boss has been defeated

	.return:
		rts						; return
; ===========================================================================

React_BadnikHit:
		bsr.w	ResetHomingAttack

		; Points and points object
		moveq	#0,d0
		move.w	(v_itembonus).w,d0			; get current combo-score chain before landing on floor again
		addq.w	#1*2,(v_itembonus).w			; increment bonus counter (2 because React_PointsCombo is word-based)
		cmpi.w	#3*2,d0					; have fewer than 3 badniks broken in this chain?
		blo.s	.getPoints				; if yes, branch
		moveq	#3*2,d0					; set cap for points to 1000
	.getPoints:
		move.w	d0,exitem_pointsframe(a1)		; set current carry-over frame ID for points object
		move.w	React_PointsCombo(pc,d0.w),d0		; load bonus points for current combo-score chain
		cmpi.w	#16*2,(v_itembonus).w			; have 16 badniks been destroyed?
		blo.s	.addPoints				; if not, branch
		move.w	#1000,d0				; give 10000 points from that point onward
		move.w	#5*2,exitem_pointsframe(a1)		; use frame 5 for points object (10000)
	.addPoints:
		jsr	(AddPoints).l				; add d0 to current score

		; Change badnik into gray explosion
		move.l	#ExplosionItem,obID(a1)		; change badnik into an to explosion/animal object
		move.b	#0,obRoutine(a1)			; set to "ExItem_Animal" routine to also spawn animal/points objects

		; Bounce Sonic vertically
		tst.w	obVelY(a0)				; is Sonic moving upwards?
		bmi.s	.slowFromBelow				; if yes, branch
		move.w	obY(a0),d0				; get Sonic's Y-position
		cmp.w	obY(a1),d0				; was Sonic below badnik on impact?
		bhs.s	.boostFromBelow				; if yes, branch
		neg.w	obVelY(a0)				; negate Sonic's Y-speed to make him bounce upwards
		rts						; return

	.slowFromBelow:
		addi.w	#$100,obVelY(a0)			; slow down Sonic going up if badnik touched from below
		rts						; return

	.boostFromBelow:
		subi.w	#$100,obVelY(a0)			; add a bit of boost speed when touching from below
		rts						; return

; ---------------------------------------------------------------------------

React_PointsCombo: ; combo points per destroyed badnik /10
		dc.w  10	; 1st
		dc.w  20	; 2nd
		dc.w  50	; 3rd
		dc.w 100	; 4th - 15th
				; 16th and subsequent badniks are hardcoded to 10000 points


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle taking damage
; ---------------------------------------------------------------------------

React_Caterkiller:
		bset	#7,obStatus(a1)				; set flag that spiked body segment has been touched (for fragmentation)
		; Continue to React_ChkHurt to make spiked body segments hurt...
; ---------------------------------------------------------------------------

React_ChkHurt:
		tst.b	(v_invinc).w				; is Sonic invincible?
		beq.s	.damage					; if not, branch

; .isflashing:
.noDamage:
		bra.w	React_CheckNext				; try next object in RAM
; ---------------------------------------------------------------------------

; .notinvincible:
.damage:
		tst.b	flashtime(a0)				; is Sonic flashing?
		bne.s	.noDamage				; if yes, don't take damage

		movea.l	a1,a2					; damaging object needs to be in a2 for HurtSonic/KillSonic
		; continue straight to HurtSonic...


; ---------------------------------------------------------------------------
; Hurting Sonic subroutine
; 
; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object hurting Sonic
; 
; output:
;	a1 = address of OST of ring loss object (if Sonic had rings)
; ---------------------------------------------------------------------------

HurtSonic:
		tst.b	(v_shield).w				; does Sonic have a shield?
		bne.s	.bounceSonicAway			; if yes, branch
		tst.w	(v_rings).w				; does Sonic have any rings?
		beq.w	.hitWithoutRings			; if not, branch to kill Sonic

		jsr	(RLoss_SpawnRings).l
	; .hasshield:
	.bounceSonicAway:
		move.b	#0,(v_shield).w				; remove a potential shield
		move.b	#4,obRoutine(a0)			; set Sonic to "Sonic_Hurt" routine
		bsr.w	Sonic_ResetOnFloor			; reset airborne state
		bset	#1,obStatus(a0)				; force airborne flag again

		move.w	#-$400,obVelY(a0)			; bounce Sonic vertically
		move.w	#-$200,obVelX(a0)			; bounce Sonic horizontally
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.checkDirection				; if not, branch
		move.w	#-$200,obVelY(a0)			; use slower vertical bounce
		move.w	#-$100,obVelX(a0)			; use slower horizontal bounce

	.checkDirection:
		move.w	obX(a0),d0				; get Sonic's X-position
		cmp.w	obX(a2),d0				; compare with X-position of collided object
		blo.s	.setDamageState				; if Sonic is left of the object, branch
		neg.w	obVelX(a0)				; if Sonic is right of the object, reverse

	.setDamageState:
		clr.b	spindash_flag(a0)			; clear Spin Dash flag 
		move.w	#0,obInertia(a0)			; cancel ground speed
		move.b	#id_Hurt,obAnim(a0)			; set Sonic to hurt animation
		move.b	#2*60,flashtime(a0)			; set temporary invulnerability time to 2 seconds

		move.w	#sfx_HitSpikes,d0			; use spike damage sound
		cmpi.l	#Spikes,obID(a2)			; was damage caused by spikes?
		beq.s	.sound					; if yes, branch
		cmpi.l	#Harpoon,obID(a2)			; was damage caused by LZ harpoon?
		beq.s	.sound					; if yes, branch
		move.w	#sfx_Death,d0				; use generic damage sound

	.sound:
		jsr	(QueueSound3).l				; play selected sound
		rts						; return
; ===========================================================================

; .norings:
.hitWithoutRings:
	if DebugSurviveNoRings=1
		tst.w	(f_debugmode).w				; is debug mode cheat on?
		bne.w	.bounceSonicAway			; if yes, survive dying from no rings
	endif
		; continue straight to KillSonic...


; ---------------------------------------------------------------------------
; Subroutine to kill Sonic
; 
; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object killing Sonic
; ---------------------------------------------------------------------------

KillSonic:
		tst.w	(v_debuguse).w				; is debug mode active?
		bne.w	.return					; if yes, branch

		move.b	#0,(v_invinc).w				; remove invincibility
		move.b	#6,obRoutine(a0)			; set Sonic to "Sonic_Death" routine
		bsr.w	Sonic_ResetOnFloor			; reset airborne state
		bset	#1,obStatus(a0)				; force airborne flag again

	if Enable_InfiniteLives
		move.w	#-$380,obVelY(a0)
		asr.w	obVelX(a0)
		asr.w	obVelX(a0)
	else
		move.w	#-$700,obVelY(a0)			; launch Sonic upwards while dying
		move.w	#0,obVelX(a0)				; stop horizontal movement
	endif
		move.w	#0,obInertia(a0)			; stop ground movement

		move.w	(v_screenposy).w,objoff_38(a0)		; remember Sonic's Y position at time of death
		clr.w	(v_scrshiftx).w
		clr.w	(v_scrshifty).w

		move.b	#id_Death,obAnim(a0)			; set Sonic to use death animation
		bset	#7,obGfx(a0)				; set Sonic to high sprite priority state

		move.w	obY(a0),objoff_38(a0)			; remember Sonic's Y position at time of death

		clr.b	(f_timecount).w				; stop time counter

		move.w	#sfx_HitSpikes,d0			; play spikes death sound
		cmpi.l	#Spikes,obID(a2)			; check if you were killed by spikes
		beq.s	.sound					; if yes, branch
		cmpi.l	#Harpoon,obID(a2)			; check if you were killed by a harpoon
		beq.s	.sound					; if yes, branch
		move.w	#sfx_Death,d0				; play normal death sound

	.sound:
		move.l	obID(a2),d1		; get object ID of object that killed Sonic
		cmpi.l	#LavaBall,d1		; MZ and SLZ lava balls (object 14)
		beq.s	.firedeath
		cmpi.l	#GrassFire,d1	; MZ grass fire (object 35)
		beq.s	.firedeath
		cmpi.l	#LavaTag,d1		; MZ invisible lava tag (object 54)
		beq.s	.firedeath
		cmpi.l	#LavaGeyser,d1	; MZ lava geysers/falls (object 4D)
		beq.s	.firedeath
		cmpi.l	#LavaWall,d1		; MZ wall of lava from act 2 (object 4E)
		beq.s	.firedeath
		cmpi.l	#Gargoyle,d1		; LZ gargoyle fireballs (object 62)
		beq.s	.firedeath
		cmpi.l	#Flamethrower,d1	; SBZ flamethrower (obejct 6D)
		beq.s	.firedeath
		cmpi.l	#BossFire,d1		; MZ fire balls from boss (object 74)
		bne.s	.normal			; if it was none of the above, don't do burnt death

	.firedeath:
		move.b	#id_Burnt,obAnim(a0)	; set Sonic to "burnt death" animation
		move.w	#sfx_Flamethrower,d0	; use burnt death sound

	.normal:
		jsr	(QueueSound2).l				; play selected sound

	; .dontdie:
	.return:
		rts						; return
; End of function KillSonic


; ===========================================================================
; ---------------------------------------------------------------------------
; Handle special collision with objects whose obColType is $C0 or above
; ---------------------------------------------------------------------------

React_Special:
		move.b	obColType(a1),d1			; get colType of collided object
		andi.b	#$FF-(col_item|col_hurt|col_special),d1	; mask out special subgroup bits

		cmpi.b	#col_16x16,d1				; touched a Caterkiller body segment? ($CB)
		beq.s	React_CaterkillerBody			; if yes, branch
		cmpi.b	#col_40x32,d1				; touched a Yadrin? ($CC)
		beq.s	React_Yadrin				; if yes, branch
		cmpi.b	#col_16x16_alt,d1			; touched an SYZ bumper? ($D7)
		beq.s	React_SYZBumper				; if yes, branch
		cmpi.b	#col_8x64,d1				; touched breakable LZ pole? ($E1)
		beq.s	React_LZPole				; if yes, branch

		rts						; otherwise, invalid special collision
; ===========================================================================

; .caterkiller:
React_CaterkillerBody:
		bra.w	React_Caterkiller			; get hurt from Caterkiller body and fragmentate it
; ===========================================================================

; .yadrin:
React_Yadrin:
		; The Yadrin's spiked section collision works by having an imaginary,
		; 24x8 pixels wide hitbox at its top, offset by 4px to expose the face.
		sub.w	d0,d5					; d5 = pixels Sonic's bottom edge is clipping into Yadrin's top edge
		cmpi.w	#8,d5					; is Sonic at least 8px into the Yadrin from above?
		bhs.s	.normalBadnik				; if yes, treat as normal badnik

		move.w	obX(a1),d0				; get Yadrin's current X-position
		subq.w	#4,d0					; get left edge of special collision region
		btst	#0,obStatus(a1)				; is Yadrin facing left?
		beq.s	.checkSpikedSection			; if not, branch
		subi.w	#16,d0					; mirror collision region horizontally

	.checkSpikedSection:
		sub.w	d2,d0					; compare spiked section against Sonic's left edge
		bhs.s	.sonicLeft				; branch if Sonic is left of spiked section
		addi.w	#24,d0					; spiked section is 24px wide
		blo.s	.damaging				; branch if Sonic overlaps it
		bra.s	.normalBadnik				; otherwise, handle as normal enemy collision

	.sonicLeft:
		cmp.w	d4,d0					; is Sonic too far left to overlap spiked section?
		bhi.s	.normalBadnik				; if yes, handle as normal enemy collision
; ---------------------------------------------------------------------------

	.damaging:
		bra.w	React_ChkHurt				; take damage when touching Yadrin's spiked section

	.normalBadnik:
		bra.w	React_Enemy				; treat as normal badnik when touching Yadrin in other ways
; ===========================================================================

; .D7orE1:
React_SYZBumper:
React_LZPole:
		addq.b	#1,obColProp(a1)			; set flag that object has been touched (handled in object itself)
		rts						; return
; End of function React_Special
; ===========================================================================

ResetHomingAttack:
		tst.b	doublejump(a0)				; was the homing attack flag set?
		beq.s	.return					; if not, nothing to do
		bmi.s	.reset					; was it set to -1? if yes, skip rebound

		asr.w	obVelX(a0)				; halve X-speed...
		asr.w	obVelX(a0)				; ...twice
		move.w	#-$500,obVelY(a0)			; bounce Sonic upwards a little from the impact
		btst	#6,obStatus(a0)				; is Sonic underwater?
		beq.s	.reset					; if not, branch
		asr.w	obVelY(a0)				; halve rebound speed

	.reset:
		clr.b	doublejump(a0)				; reset homing attack flag so we can do another one
		move.b	#1,jumping(a0)				; force jumping flag to allow variable jump height from rebound

	.return:
		rts						; return
; End of function ResetHomingAttack
