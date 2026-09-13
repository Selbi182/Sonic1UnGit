; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3E - Prison capsule after boss fights
; ---------------------------------------------------------------------------
pri_origY:	equ objoff_30		; original y-axis position
; ===========================================================================

Prison:
		move.l	#Map_Pri,obMap(a0)			; set mappings
		move.w	#ArtTile_Prison_Capsule,obGfx(a0)	; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	obY(a0),pri_origY(a0)			; remember initial Y-position

		tst.b	obSubtype(a0)				; is this the switch?
		bne.s	.switch					; if yes, branch

	.capsule:
		move.l	#Pri_BodyMain,obID(a0)
		move.b	#64/2,obActWid(a0)			; set sprite display width
		move.w	#spr_prio4,obPriority(a0)		; set sprite priority
		move.b	#0,obFrame(a0)				; set frame ID
		bra.s	Pri_BodyMain

	.switch:
		move.l	#Pri_Switch,obID(a0)
		move.b	#24/2,obActWid(a0)			; set sprite display width
		move.w	#spr_prio5,obPriority(a0)		; set sprite priority
		move.b	#1,obFrame(a0)				; set frame ID
		bra.s	Pri_Switch
; ===========================================================================

Pri_Delete:
		jmp	(DeleteObject).l			; delete capsule
; ===========================================================================

Pri_BodyMain:	; Routine 2
		out_of_range.s	Pri_Delete			; is capsule offscreen? if yes, branch
		DisplaySprite					; display capsule

		cmpi.b	#2,(v_bossstatus).w			; has the prison been opened from switch?
		beq.s	.openCapsule				; if yes, branch

		move.w	#64/2+sonic_solid_width,d1		; solid width
		move.w	#48/2,d2				; solid height (initial)
		move.w	#48/2,d3				; solid height (stood on)
		move.w	obX(a0),d4				; X-position (stood on)
		jmp	(SolidObject).l				; make capsule solid
; ---------------------------------------------------------------------------

.openCapsule:
		tst.b	obSolid(a0)				; was Sonic standing on the capsule as it opened
		beq.s	.showOpened				; if not, branch
		clr.b	obSolid(a0)				; clear capsule's collision flag
		bclr	#3,(v_player+obStatus).w		; clear Sonic's on-platform flag
		bset	#1,(v_player+obStatus).w		; set Sonic to be in air

	.showOpened:
		move.b	#2,obFrame(a0)				; use frame number 2 (destroyed prison)
		rts						; return
; ===========================================================================

; Pri_Switched:
Pri_Switch:	; Routine 4
		out_of_range.w	Pri_Delete			; is capsule offscreen? if yes, branch
		DisplaySprite					; display capsule

		lea	(Ani_Pri).l,a1				; load animation script
		jsr	(AnimateSprite).l			; animate switch
		move.w	pri_origY(a0),obY(a0)			; force Y-position to stay at initial

		tst.w	(v_debuguse).w				; is debug mode on?
		bne.s	.return					; if yes, ignore touch
		lea	(v_player).w,a1				; load Sonic player object
		move.w	obX(a1),d0				; get Sonic's current X-position
		move.w	obX(a0),d1				; get bubble's current X-position
		subi.w	#24/2+sonic_solid_width,d1		; check left
		cmp.w	d0,d1					; is Sonic within left edge?
		bhs.s	.return					; if not, branch
		addi.w	#(24/2+sonic_solid_width)*2,d1		; check right
		cmp.w	d0,d1					; is Sonic within right edge?
		blo.s	.return					; if not, branch

		move.w	obY(a1),d0				; get Sonic's current Y-position
		move.w	obY(a0),d1				; get bubble's current Y-position
		subi.w	#16,d1					; check top
		cmp.w	d0,d1					; is Sonic within top edge?
		bhs.s	.return					; if not, branch
		addi.w	#16*2,d1				; check bottom
		cmp.w	d0,d1					; is Sonic within bottom edge?
		blo.s	.return					; if not, branch

	.touch:
		addq.w	#8,obY(a0)				; move switch down 8px
		move.l	#Pri_Explosion,obID(a0)			; advance to Pri_Explosion
		move.w	#1*60,obTimeFrame(a0)			; set time between animal spawns
		clr.b	(f_timecount).w				; stop time counter
		clr.b	(f_lockscreen).w			; lock screen position
		move.b	#1,(f_lockctrl).w			; lock controls
		move.w	#(btnR<<8),(v_jpadhold2).w		; simulate holding down the right D-Pad button to move Sonic
		clr.b	obSolid(a0)				; clear capsule's collision flag
		bclr	#3,(v_player+obStatus).w		; clear Sonic's on-platform flag
		bset	#1,(v_player+obStatus).w		; set Sonic to be in air

	.return:
		rts						; return
; ===========================================================================

Pri_Explosion:	; Routine 6
		moveq	#7,d0					; only spawn an explosion every 8 frames...
		and.b	(v_vblank_byte).w,d0			; ...based in VBlank frame counter
		bne.s	.chkSpawnAnimals			; skip on other frames

		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.chkSpawnAnimals			; if object RAM is full, branch
		move.l	#Explosion,obID(a1)			; load an explosion object
		move.w	obX(a0),obX(a1)				; use prison X-position for explosion base
		move.w	obY(a0),obY(a1)				; use prison Y-position for explosion base
		jsr	(RandomNumber).l			; get a random number in d0/d1
		moveq	#0,d1					; clear d1
		move.b	d0,d1					; get lower byte from random result
		lsr.b	#2,d1					; divide by 4
		subi.w	#32,d1					; pull 32px to the left
		add.w	d1,obX(a1)				; randomly adjust explosion X-position
		lsr.w	#8,d0					; put upper byte of random result into lower byte
		lsr.b	#3,d0					; divide by 8
		add.w	d0,obY(a1)				; randomly adjust explosion Y-position

	.chkSpawnAnimals:
		subq.w	#1,obTimeFrame(a0)			; decrement explosion timer
		beq.s	Pri_SpawnAnimals			; if time expired, spawn animals
		DisplaySprite
		rts						; otherwise, keep exploding
; ---------------------------------------------------------------------------

Pri_SpawnAnimals:
		move.b	#2,(v_bossstatus).w			; set prison as being opened
		move.l	#Pri_Animals,obID(a0)			; advance to Pri_Animals (replace explosions with animals)
		move.b	#6,obFrame(a0)				; 'delete' switch by turning it invisible
		move.w	#(2*60)+30,obTimeFrame(a0)		; time delay before starting to check if animals have gone offscreen
		addi.w	#32,obY(a0)				; load all animals 32px below explosions

		; These animals stay in the prison a bit longer to make it seem more crowded
		moveq	#8-1,d6					; load 8 animals
		move.w	#(2*60)+34,d5				; set start hop-out delay for animals to roughly 2.5 seconds
		moveq	#-28,d4					; set start X-offset for animals
	.loop:
		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.return					; if object RAM is full, branch
		move.l	#Animals,obID(a1)			; load an animal object
		move.w	obX(a0),obX(a1)				; spawn at current X-position
		move.w	obY(a0),obY(a1)				; spawn at current Y-position
		add.w	d4,obX(a1)				; add X-offset for this animal
		addq.w	#7,d4					; advance X-offset for next animal
		move.w	d5,animal_prisondelay(a1)		; set hop-out delay for this animal
		subq.w	#8,d5					; decrement hop-out delay for next animal
		dbf	d6,.loop				; repeat 7 more times

	.return:
		DisplaySprite
		rts						; return
; ===========================================================================

Pri_Animals:	; Routine 8

		; Cut the capsule sequence short if button is held
		moveq	#btnABC,d0				; is ABC...
		and.b	(v_jpadhold1).w,d0			; ...held?
		beq.s	.noSkip					; if not, branch
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d0 ; number of objects to check
		lea	(v_lvlobjspace).w,a1			; start dynamic object RAM space
	.loopFindExplosions:
		move.l	obID(a1),d1
		cmpi.l	#Explosion,d1
		beq.s	.noSkip
		cmpi.l	#ExplosionItem,d1
		beq.s	.noSkip
		cmpi.l	#ExItem_Animate,d1			; have explosion objects full gone away? (VRAM conflict with end cards)
		beq.s	.noSkip					; if not yet, branch
		lea	object_size(a1),a1			; go to next object
		dbf	d0,.loopFindExplosions			; loop for all objects
		bra.w	Pri_LoadEndCard

.noSkip:
		moveq	#7,d0					; only spawn an animal every 8 frames...
		and.b	(v_vblank_byte).w,d0			; ...based in VBlank frame counter
		bne.s	.chkDelay				; skip on other frames

		; These animals hop out almost as soon as they are spawned in.
		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.chkDelay				; if object RAM is full, branch
		move.l	#Animals,obID(a1)			; load an animal object
		move.w	obX(a0),obX(a1)				; spawn at current X-position
		move.w	obY(a0),obY(a1)				; spawn at current Y-position
		jsr	(RandomNumber).l			; get a random number in d0/d1
		andi.w	#$1F,d0					; limit random X-offset to 32px
		subq.w	#6,d0					; pull X-offset 6px to the left
		tst.w	d1					; was random result negative?
		bpl.s	.setX					; if not, branch
		neg.w	d0					; invert random X-offset to other direction
	.setX:	add.w	d0,obX(a1)				; add random X-offset
		move.w	#12,animal_prisondelay(a1)		; make animal hop out after 12 frames (almost instantly)

.chkDelay:
		subq.w	#1,obTimeFrame(a0)			; decrement timer until checking if animals have gone offscreen
		bne.s	.return					; if time remains, branch (probably to avoid lag frames)
.skip:
		move.l	#Pri_EndAct,obID(a0)			; advance to Pri_EndAct

	.return:
		rts						; return
; ===========================================================================

Pri_EndAct:	; Routine $A
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d0 ; number of objects to check
		move.l	#Animals,d1				; set object ID to check
		moveq	#object_size,d2				; set increment value per object to check
		lea	(v_lvlobjspace).w,a1			; start dynamic object RAM space
	.loopFindAnimals:
		cmp.l	obID(a1),d1				; has animal object been deleted?
		beq.s	.return					; if not yet, branch
		adda.w	d2,a1					; check next object RAM slot
		dbf	d0,.loopFindAnimals			; repeat for entire object RAM space
		bra.s	Pri_LoadEndCard
	
	.return:
		rts
; ===========================================================================

Pri_LoadEndCard:
		jsr	(GotThroughAct).l			; all animal objects have been deleted, launch end-of-level title cards (object 3A)
		jmp	(DeleteObject).l			; delete prison switch object

; ===========================================================================

		include	"_anim/Prison Capsule.asm"
Map_Pri:	include	"_maps/Prison Capsule.asm"
