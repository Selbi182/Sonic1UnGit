; ===========================================================================
; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0					; clear d0
		move.b	obRoutine(a0),d0			; get routine number
		move.w	Mon_Index(pc,d0.w),d1			; find entry in offset table
		jmp	Mon_Index(pc,d1.w)			; jump to current routine
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index				; 0 - init
		dc.w Mon_Solid-Mon_Index			; 2 - idle and unbroken
		dc.w Mon_BreakOpen-Mon_Index			; 4 - break triggered from ReactToItem
		dc.w Mon_Animate-Mon_Index			; 6 - idle and broken
		dc.w Mon_Display-Mon_Index			; 8 - if spawned already broken
; ===========================================================================

Mon_Main:	; Routine 0
		cmpi.b	#8,obSubtype(a0)			; is monitor subtype valid? i.e. no higher than goggles monitor (ID 8)
		bls.s	.valid					; if yes, branch
		move.l	#Invisibarrier,obID(a0)		; otherwise, convert this monitor to an invisible solid barrier
		jmp	(Invisibarrier).l			; execute barrier logic
.valid:

		addq.b	#2,obRoutine(a0)			; go to "Mon_Solid" next
		move.b	#28/2,obHeight(a0)			; set height
		move.b	#28/2,obWidth(a0)			; set width
		move.l	#Map_Monitor,obMap(a0)			; set mappings
		move.w	#ArtTile_Monitor,obGfx(a0)		; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set render mode to playfield-positioned
		move.w	#spr_prio3,obPriority(a0)			; set sprite priority to 3
		move.b	#30/2,obActWid(a0)			; set render width

		respawn_entry.s	.notbroken
		btst	#0,(a2)					; has monitor already been broken?
		beq.s	.notbroken				; if not, branch

		move.b	#8,obRoutine(a0)			; run "Mon_Display" routine
		move.b	#$B,obFrame(a0)				; use broken monitor frame
		rts						; only start displaying next frame
; ===========================================================================

.notbroken:
		move.b	#col_32x32|col_item,obColType(a0)	; set collision size to 16x16 and type to item (=$46)
		move.b	obSubtype(a0),obAnim(a0)		; use subtype as animation ID

Mon_Solid:	; Routine 2
		move.b	ob2ndRout(a0),d0			; is monitor set to fall or being stood on?
		beq.s	.normal					; if not, branch
		subq.b	#2,d0					; is monitor specifically set to fall?
		bne.s	.fall					; if yes, branch

		; 2nd Routine 2
		moveq	#0,d1					; clear d1
		move.b	obActWid(a0),d1				; get monitor's display width
		addi.w	#sonic_solid_width,d1			; add Sonic's collision width for solids ($B)
		bsr.w	ExitPlatform				; clear platform flags if Sonic was standing on the monitor
		btst	#3,obStatus(a1)				; is Sonic still on top of the monitor?
		bne.w	.ontop					; if yes, branch
		clr.b	ob2ndRout(a0)				; clear special monitor subroutines
		bra.w	Mon_Animate				; process monitor normally
; ===========================================================================

.ontop:
		move.w	#32/2,d3				; set solid width
		move.w	obX(a0),d2				; get monitor's X position
		bsr.w	MvSonicOnPtfm				; make Sonic run along the monitor like a platform
		bra.w	Mon_Animate				; process monitor normally
; ===========================================================================

.fall:		; 2nd Routine 4
		bsr.w	ObjectFall				; apply gravity and update monitor position
		jsr	(ObjFloorDist).l			; get distance from monitor to floor
		tst.w	d1					; has monitor hit the floor?
		bpl.w	Mon_Animate				; if not, branch
		add.w	d1,obY(a0)				; align monitor with surface
		clr.w	obVelY(a0)				; stop monitor from falling
		clr.b	ob2ndRout(a0)				; clear special monitor subroutines
		bra.w	Mon_Animate				; process monitor normally
; ===========================================================================

.normal:	; 2nd Routine 0
		move.w	#30/2+sonic_solid_width,d1		; width/2
		move.w	#30/2,d2				; height/2
		bsr.w	Mon_SolidSides				; check collision (0 = none; 1 = side; -1 = top/bottom)
		beq.w	.checkpush				; if not, branch

		tst.b	doublejump(a1)
		bne.s	.checkpush
		tst.w	obVelY(a1)				; is Sonic moving upwards?
		bmi.s	.dontbreak				; if yes, branch
		cmpi.b	#id_Roll,obAnim(a1)			; is Sonic rolling?
		beq.s	.checkpush				; if yes, branch

; loc_A20A:
.dontbreak:
		tst.b	spindash_flag(a1)			; is spindash flag set?
		bne.s	.checkpush				; if yes, branch

		tst.w	d1					; has Sonic touched the monitor from the sides?
		bpl.s	.sidetouch				; if yes, branch
		sub.w	d3,obY(a1)				; align Sonic to the top of the monitor
		bsr.w	Plat_NoCheck				; update platform status flags for Sonic and monitor
		move.b	#2,ob2ndRout(a0)			; set secondary monitor state to ".ontop"
		bra.w	Mon_Animate				; process monitor normally
; ===========================================================================

; loc_A220:
.sidetouch:
		tst.w	d0					; check Sonic's horizontal distance to the monitor
		beq.w	.push					; if exactly the same, branch
		bmi.s	.sonicleft				; if to the left of the monitor, branch

.sonicright:
		tst.w	obVelX(a1)				; is Sonic moving to the left?
		bmi.s	.push					; if yes, branch
		bra.s	.stopsonic				; otherwise, keep Sonic in place
; ===========================================================================

; loc_A230:
.sonicleft:
		tst.w	obVelX(a1)				; is Sonic moving to the right or still?
		bpl.s	.push					; if yes, branch

; loc_A236:
.stopsonic:
		sub.w	d0,obX(a1)				; horizontally align Sonic to monitor
		move.w	#0,obInertia(a1)			; stop Sonic moving
		move.w	#0,obVelX(a1)				; ''

; loc_A246:
.push:
		btst	#1,obStatus(a1)				; is Sonic airborne?
		bne.s	.stoppushing				; if yes, branch
		bset	#5,obStatus(a1)				; set Sonic's pushing flag
		bset	#5,obStatus(a0)				; set monitor's flag that it's being pushed
		bra.s	Mon_Animate				; process monitor normally
; ===========================================================================

; loc_A25C:
.checkpush:
		btst	#5,obStatus(a0)				; is Sonic still pushing against the monitor?
		beq.s	Mon_Animate				; if not, branch

; loc_A26A:
.stoppushing:
		bclr	#5,obStatus(a0)				; clear pushing flag for monitor
		bclr	#5,obStatus(a1)				; clear pushing flag for Sonic

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1			; get animation script for monitor
		bsr.w	AnimateSprite				; animate monitor

Mon_Display:	; Routine 8
		RememberState
		rts				; handle display, respawn table, and offscreen delete
; ===========================================================================

Mon_BreakOpen:	; Routine 4 (set from ReactToItem)
		addq.b	#2,obRoutine(a0)			; advance to "Mon_Animate"
		move.b	#col_none,obColType(a0)			; prevent further collision with monitor

		bsr.w	FindFreeObj				; find a free object slot
		bne.s	Mon_Explode				; if object RAM is full, branch
		move.l	#PowerUp,obID(a1)			; load monitor contents object
		move.w	obX(a0),obX(a1)				; copy X position
		move.w	obY(a0),obY(a1)				; copy Y position
		move.b	obAnim(a0),obAnim(a1)			; copy animation (which also handles the power-up)

Mon_Explode:
		bsr.w	FindFreeObj				; find another free object slot
		bne.s	Mon_RememberBroken			; if object RAM is full, branch
		move.l	#ExplosionItem,obID(a1)		; load explosion object
		addq.b	#2,obRoutine(a1)			; skip over ExItem_Animal so no animal is spawned
		move.w	obX(a0),obX(a1)				; copy X position
		move.w	obY(a0),obY(a1)				; copy Y position

; .fail:
Mon_RememberBroken:
		respawn_entry.s	.broken
		bset	#0,(a2)
.broken:
		move.b	#9,obAnim(a0)				; set monitor animation to broken
		DisplaySprite
		rts				; keep displaying broken monitor


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0					; clear d0
		move.b	obRoutine(a0),d0			; get routine number
		move.w	Pow_Index(pc,d0.w),d1			; find entry in offset table
		jsr	Pow_Index(pc,d1.w)			; jump to current routine and return
		DisplaySprite
		rts				; display monitor icon sprite
; ===========================================================================
Pow_Index:	dc.w Pow_Main-Pow_Index				; 0 - init
		dc.w Pow_Move-Pow_Index				; 2 - icon is moving up
		dc.w Pow_Delete-Pow_Index			; 4 - wait and delete
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to Pow_Move
		move.w	#ArtTile_Monitor,obGfx(a0)		; set art tile
		move.b	#sprite_rawmappings|sprite_cam_field,obRender(a0) ; set "raw-mappings" flag and playfield-positioned mode
		move.w	#spr_prio3,obPriority(a0)			; set sprite priority to 3
		move.b	#16/2,obActWid(a0)			; set display width
		move.w	#-$300,obVelY(a0)			; set initial upwards momentum of the icon

		; Raw Mappings: Set mappings pointer to point directly to the icon sprite piece
		moveq	#0,d0					; clear d0
		move.b	obAnim(a0),d0				; get monitor subtype
		addq.b	#2,d0					; skip over the two extra static frames
		move.b	d0,obFrame(a0)				; set frame (redundant for raw mappings)
		movea.l	#Map_Monitor,a1				; load monitor mappings
		add.b	d0,d0					; double frame ID for word-based indexing
		adda.w	(a1,d0.w),a1				; go to relevant mapping for monitor type
		addq.w	#1,a1					; skip over the sprite header
		move.l	a1,obMap(a0)				; use first sprite piece of mapping for raw mappings pointer

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)				; is icon still moving upwards?
		bpl.w	Pow_Checks				; if not, branch to give monitor reward now
		bsr.w	SpeedToPos				; update icon position
		addi.w	#$18,obVelY(a0)				; reduce icon's upward speed
		rts						; wait until it has stopped moving
; ===========================================================================

Pow_Checks:
		addq.b	#2,obRoutine(a0)			; advance to Pow_Delete
		move.w	#30-1,obTimeFrame(a0)			; display icon for half a second
		move.b	obAnim(a0),d0				; get animation ID to use as check for the monitor type

Pow_ChkEggman:
		cmpi.b	#1,d0					; does monitor contain Eggman?
		bne.s	Pow_ChkSonic				; if not, branch
		move.w	obX(a0),spikes_origX(a0)		; needed to display the icon properly
		jmp	(Spikes_Hurt).l				; use imaginary spikes to hurt Sonic
; ===========================================================================

Pow_ChkSonic:
		cmpi.b	#2,d0					; does monitor contain Sonic?
		bne.s	Pow_ChkShoes				; if not, branch
		jmp	(ExtraLife).l				; add 1 to number of lives and update HUD
; ===========================================================================

Pow_ChkShoes:
		cmpi.b	#3,d0					; does monitor contain speed shoes?
		bne.s	Pow_ChkShield				; if not, branch

		move.b	#1,(v_shoes).w				; set speed shoes flag (used for reverting when time ran out)
		move.l	#AfterImage,(v_afterimage+obID).w		; load after image object
		move.w	#20*60,(v_player+shoetime).w		; set time limit for speed shoes to 20 seconds

		move.w	#son_maxspeed*2,(v_sonspeedmax).w	; double Sonic's top speed
		move.w	#son_acceleration*2,(v_sonspeedacc).w	; double Sonic's acceleration
		move.w	#son_deceleration,(v_sonspeeddec).w 	; set Sonic's deceleration (same as regular)

		btst	#6,(v_player+obStatus).w		; is Sonic underwater?
		beq.s	.notunderwater				; if not, branch
		move.w	#son_maxspeed,(v_sonspeedmax).w		; initial Sonic's top speed
		move.w	#son_acceleration,(v_sonspeedacc).w	; initial Sonic's acceleration
		move.w	#son_deceleration,(v_sonspeeddec).w 	; initial Sonic's deceleration
	.notunderwater:

		move.w	#bgm_Speedup,d0				; set music speed-up command
		jmp	(QueueSound1).l				; play it
; ===========================================================================

Pow_ChkShield:
		cmpi.b	#4,d0					; does monitor contain a shield?
		bne.s	Pow_ChkInvinc				; if not, branch

		move.b	#1,(v_shield).w				; give Sonic a shield
		move.l	#ShieldItem,(v_shieldobj+obID).w		; load shield object ($38)
		move.w	#sfx_Shield,d0				; set shield sound effect
		jmp	(QueueSound1).l				; play it
; ===========================================================================

Pow_ChkInvinc:
		cmpi.b	#5,d0					; does monitor contain invincibility?
		bne.s	Pow_ChkRings				; if not, branch

		move.b	#1,(v_invinc).w				; make Sonic invincible
		move.w	#20*60,(v_player+invtime).w		; set time limit for invincibility to 20 seconds

		move.l	#ShieldItem,(v_starsobj1+obID).w		; load 1st stars object
		move.b	#1,(v_starsobj1+obAnim).w		; set shortest travel delay
		move.l	#ShieldItem,(v_starsobj2+obID).w		; load 2nd stars object
		move.b	#2,(v_starsobj2+obAnim).w		; set short travel delay
		move.l	#ShieldItem,(v_starsobj3+obID).w		; load 3rd stars object
		move.b	#3,(v_starsobj3+obAnim).w		; set long travel delay
		move.l	#ShieldItem,(v_starsobj4+obID).w		; load 4th stars object
		move.b	#4,(v_starsobj4+obAnim).w		; set longest travel delay

		tst.b	(f_lockscreen).w			; is boss mode on?
		bne.s	Pow_NoMusic				; if yes, don't change music
		cmpi.w	#12,(v_air).w				; is Sonic close to drowning? (countdown music playing)
		bls.s	Pow_NoMusic				; if yes, don't change music
		move.w	#bgm_Invincible,d0			; set invincibility music
		jmp	(QueueSound1).l				; play it

Pow_NoMusic:
		rts						; don't play music
; ===========================================================================

Pow_ChkRings:
		cmpi.b	#6,d0					; does monitor contain 10 rings?
		bne.s	Pow_ChkS				; if not, branch
		moveq	#10,d0					; set to award 10 extra rings
		jmp	(AddRings).l				; add specified rings, update HUD, and potentially award extra life
; ===========================================================================

Pow_ChkS:
		cmpi.b	#7,d0					; does monitor contain 'S'?
		bne.s	Pow_ChkGoggles				; if not, branch
		nop						; 'S' does nothing by default
; ===========================================================================

Pow_ChkGoggles:
		cmpi.b	#8,d0					; does monitor contain goggles?
		bne.s	Pow_ChkEnd				; if not, branch
		nop						; goggles do nothing by default
; ===========================================================================

Pow_ChkEnd:
		rts						; subtype isn't any valid monitor ID
; ===========================================================================

Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)			; deduct 1 from final delay (half a second by default)
		bmi.s	.return					; if time remains, branch
		addq.l	#4,sp					; tamper return value to not return to PowerUp
		bra.w	DeleteObject				; delete icon object

.return:
		rts						; return to PowerUp to keep displaying icon


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; 
; input:
;	d1 = width/2
;	d2 = height/2
; 
; output:
;	d0 = distance from side of monitor
;	d1 = collision type: 0 = none; 1 = side collision; -1 = top/bottom collision
;	d3 = distance from top of monitor
; ---------------------------------------------------------------------------

Mon_SolidSides:
		lea	(v_player).w,a1				; load Sonic's player object
		move.w	obX(a1),d0				; get Sonic's X position
		sub.w	obX(a0),d0				; subtract monitor's X position from it
		add.w	d1,d0					; add collision width
		bmi.s	.no_collision				; if Sonic is to the left of the monitor, branch
		move.w	d1,d3					; copy collision width
		add.w	d3,d3					; double it
		cmp.w	d3,d0					; is Sonic to the right of the monitor?
		bhi.s	.no_collision				; if yes, branch

		move.b	obHeight(a1),d3				; get Sonic's collision height
		ext.w	d3					; extend to word
		add.w	d3,d2					; add it to monitor's collision height
		move.w	obY(a1),d3				; get Sonic's Y position
		sub.w	obY(a0),d3				; subtract monitor's Y position from it
		add.w	d2,d3					; add collision height
		bmi.s	.no_collision				; if Sonic is above the monitor, branch
		add.w	d2,d2					; double collision height
		cmp.w	d2,d3					; is Sonic below the monitor?
		bcc.s	.no_collision				; if yes, branch

		tst.b	(f_playerctrl).w			; is Sonic's object interaction disabled?
		bmi.s	.no_collision				; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w		; is Sonic dying?
		bhs.s	.no_collision				; if yes, branch
		tst.w	(v_debuguse).w				; is debug mode active?
		bne.s	.no_collision				; if yes, branch

		cmp.w	d0,d1					; is Sonic between left side and middle of the monitor?
		bcc.s	.left_hit				; if yes, branch

	.right_hit:
		add.w	d1,d1					; double collision width
		sub.w	d1,d0					; update d0 for to right side of monitor

	; loc_A4DC:
	.left_hit:
		cmpi.w	#$10,d3					; is Sonic between top & middle of monitor?
		blo.s	.top_hit				; if yes, branch

; loc_A4E2:
.side_hit:
		moveq	#1,d1					; set side collision flag
		rts						; return with result in CCR
; ===========================================================================

; loc_A4E6:
.no_collision:
		moveq	#0,d1					; set no collision flag
		rts						; return with result in CCR
; ===========================================================================

; loc_A4EA:
.top_hit:
		moveq	#0,d1					; clear d1
		move.b	obActWid(a0),d1				; get display width of monitor
		addq.w	#4,d1					; add 4px to top collision width
		move.w	d1,d2					; copy it for right side check
		add.w	d2,d2					; double the copy for right side check
		add.w	obX(a1),d1				; add Sonic's X position to main collision width
		sub.w	obX(a0),d1				; subtract Monitor's X position
		bmi.s	.side_hit				; if Sonic is to the left of the monitor, branch
		cmp.w	d2,d1					; is Sonic to the right of the monitor?
		bhs.s	.side_hit				; if yes, branch

		moveq	#-1,d1					; set top/bottom collision flag
		rts						; return with result in CCR
; End of function Mon_SolidSides

; ===========================================================================

		include	"_anim/Monitor.asm"
Map_Monitor:	include	"_maps/Monitor.asm"
