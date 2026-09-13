; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4C - lava geyser / lavafall producer (MZ)
; ---------------------------------------------------------------------------
gmake_timer:	equ objoff_32		; current time remaining (2 bytes)
gmake_time:	equ objoff_34		; time delay (2 bytes)
gmake_parent:	equ objoff_3C		; address of parent object
; ---------------------------------------------------------------------------

GeyserMaker:
		move.l	#GMake_Wait,obID(a0)			; advance to GMake_Wait
		move.l	#Map_Geyser,obMap(a0)			; set mappings
		move.w	#ArtTile_MZ_Lava|Tile_Pal4|Tile_Prio,obGfx(a0) ; set art tile, palette line (lava palcycle), and priority flag
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio1,obPriority(a0)		; set sprite priority (above Sonic)
		move.b	#112/2,obActWid(a0)			; set sprite display width
		move.w	#120,gmake_time(a0)			; set time delay between spawning lava to 2 seconds
; ---------------------------------------------------------------------------

GMake_Wait:	; Routine 2
		subq.w	#1,gmake_timer(a0)			; decrement lava making timer
		bpl.s	.cancel					; if time remains, branch
		move.w	gmake_time(a0),gmake_timer(a0)		; reset lava making interval timer

		move.w	(v_player+obY).w,d0			; get Sonic's current Y-position
		move.w	obY(a0),d1				; get lava maker's Y-position
		cmp.w	d1,d0					; is Sonic above lava maker?
		bhs.s	.cancel					; if not, branch
		subi.w	#$170,d1				; check ceiling
		cmp.w	d1,d0					; is Sonic within $170 above the lava maker?
		blo.s	.cancel					; if not, branch
		move.l	#GMake_ChkType,obID(a0)			; if Sonic is within range, advance to GMake_ChkType

	.cancel:
		out_of_range.w	DeleteObject
		rts
; ===========================================================================

GMake_ChkType:	; Routine 4
		tst.b	obSubtype(a0)				; is object type 00 (geyser)?
		beq.s	.Xdisplay				; if yes, branch
		move.l	#GMake_MakeLava,obID(a0)		; for object type 01 (lavafall), advance to GMake_MakeLava
		bra.s	.chkdel

.Xdisplay:
		lea	(Ani_Geyser).l,a1			; advance animation
		bsr.w	AnimateSprite				; (for geyser, this will advance obRoutine after bubbling animation has finished)
		tst.b	obRoutine(a0)
		beq.s	.display
		clr.b	obRoutine(a0)
		move.l	#GMake_MakeLava,obID(a0)
	.display:
		DisplaySprite
	.chkdel:
		out_of_range.w	DeleteObject
		rts
; ===========================================================================

GMake_MakeLava:	; Routine 6
		move.l	#GMake_Display,obID(a0)			; advance to GMake_Display

		bsr.w	FindNextFreeObj				; find a free object slot
		bne.s	.setAnim				; if object RAM is full, branch
		move.l	#LavaGeyser,obID(a1)			; load big vertical lava wall object
		move.w	obX(a0),obX(a1)				; copy X-position
		move.w	obY(a0),obY(a1)				; copy Y-position
		move.b	obSubtype(a0),obSubtype(a1)		; copy subtype (0 or 1)
		move.l	a0,gmake_parent(a1)			; remember parent maker object

	.setAnim:
		move.b	#1,obAnim(a0)				; set maker animation to ".bubble2"
		tst.b	obSubtype(a0)				; is object type 00 (geyser) ?
		beq.s	.shootUpPushBlock			; if yes, branch
		move.b	#4,obAnim(a0)				; for lavafall, set to animation ".blank" instead
		bra.s	GMake_Display
; ---------------------------------------------------------------------------

	.shootUpPushBlock:
		movea.l	gmake_parent(a0),a1			; get parent pushable block object address
		bset	#1,obStatus(a1)				; set flag in block to get shot up with geyser
		move.w	#-$580,obVelY(a1)			; shoot block up
	;	bra.s	GMake_Display
; ===========================================================================

GMake_Display:	; Routine 8
		out_of_range.w	DeleteObject
		lea	(Ani_Geyser).l,a1			; advance animation
		bsr.w	AnimateSprite				; (for geyser, this will advance obRoutine after bubbling animation has finished)
		tst.b	obRoutine(a0)
		beq.s	.display
		clr.b	obRoutine(a0)
		move.l	#GMake_ResetOrDelete,obID(a0)
	.display:
		DisplaySprite
		rts
; ===========================================================================

GMake_ResetOrDelete:	; Routine $A
		move.b	#0,obAnim(a0)				; set to ".bubble1" animation (advances animation)
		move.l	#GMake_Wait,obID(a0)			; set to GMake_Wait
		tst.b	obSubtype(a0)				; is this a lava geyser?
		beq.w	DeleteObject				; if yes, delete maker
		out_of_range.w	DeleteObject
		rts						; keep lavafall maker alive indefinitely


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4D - lava geyser / lavafall (MZ)
; ---------------------------------------------------------------------------
geyser_origY:	equ objoff_30	; initial Y-position
; ---------------------------------------------------------------------------

LavaGeyser:
		move.l	#Geyser_Action,obID(a0)			; advance to Geyser_Action
		move.w	obY(a0),geyser_origY(a0)		; remember starting Y-position
		move.w	#-$500,d0
		tst.b	obSubtype(a0)				; is this a lava geyser? (subtype 00)
		beq.s	.setSpeed				; if yes, branch
		subi.w	#$250,obY(a0)				; move lavafall up by $250px
		moveq	#0,d0
	.setSpeed:
		move.w	d0,obVelY(a0)

		movea.l	a0,a1					; write first lava object to current object RAM slot
		moveq	#2-1,d1					; spawn two objects
		bsr.s	.makeLava				; create lava objects, then return here
		bra.s	.configureLavaObjects			; do some further adjustments to the secondary
; ===========================================================================

.loopCreateLava:
		bsr.w	FindNextFreeObj				; find a free object slot
		bne.s	.next					; if object RAM is full, branch

	.makeLava:
		move.l	#Map_Geyser,obMap(a1)			; set mappings
		move.w	#ArtTile_MZ_Lava|Tile_Pal4,obGfx(a1)	; set art tile and palette line (palcycle)
		move.b	#sprite_cam_field,obRender(a1)		; set to playfield-positioned mode
		move.b	#112/2,obActWid(a1)			; set sprite display width
		move.w	obX(a0),obX(a1)				; copy X-position
		move.w	obY(a0),obY(a1)				; copy Y-position
		move.b	obSubtype(a0),obSubtype(a1)		; copy subtype
		move.w	#spr_prio1,obPriority(a1)		; set sprite priority (above Sonic)

		move.b	#5,obAnim(a1)				; use to ".bubble4" animation geyser
		tst.b	obSubtype(a0)				; is this a lava geyser?
		beq.s	.next					; if yes, branch
		move.b	#2,obAnim(a1)				; use ".end" animation for lavafall

	.next:
		dbf	d1,.loopCreateLava			; spawn two objects
		rts
; ===========================================================================

.configureLavaObjects:
		; a0 = bubbling part at (top) tip
		; a1 = large vertical lava wall
		addi.w	#$60,obY(a1)				; move vertical lava wall down
		move.w	geyser_origY(a0),geyser_origY(a1)	; copy original Y-position
		addi.w	#$60,geyser_origY(a1)			; move original Y-position down
		move.b	#col_64x224|col_hurt,obColType(a1)	; set collision type for lava wall
		move.b	#256/2,obHeight(a1)			; set object height
		bset	#sprite_customheight_bit,obRender(a1)	; set custom display sprite height flag
		move.l	#Geyser_BigLavaWall,obID(a1)		; set to Geyser_BigLavaWall
		move.l	a0,gmake_parent(a1)			; remember bubbling (top) tip for lava wall

		tst.b	obSubtype(a0)				; is this a lava geyser?
		beq.s	.sound					; if yes, branch
		moveq	#1-1,d1					; spawn a third object for lavafall
		bsr.w	.loopCreateLava				; a1 = bubbling part at (bottom) tip
		move.l	#Geyser_Action,obID(a1)			; set third object to Geyser_Action
		bset	#4,obGfx(a1)				; set custom display sprite height flag
		addi.w	#$100,obY(a1)				; move bottom tip down
		move.w	#spr_prio0,obPriority(a1)		; set to maximum sprite priority (above lava wall)
		move.w	geyser_origY(a0),geyser_origY(a1)	; copy original Y-position
		move.l	gmake_parent(a0),gmake_parent(a1)	; remember bubbling (top) tip for (bottom) tip
		move.b	#0,obSubtype(a0)			; force to type 00

	.sound:
		move.w	#sfx_Burning,d0
		jsr	(QueueSound2).l				; play flame sound
; ---------------------------------------------------------------------------

Geyser_Action:	; Routine 2
		tst.b	obSubtype(a0)
		bne.s	Geyser_Type01

Geyser_Type00:	; geyser
		addi.w	#$18,obVelY(a0)				; increase object's falling speed
		move.w	geyser_origY(a0),d0			; get original Y-position
		cmp.w	obY(a0),d0				; has object fallen below original position?
		bhs.s	.return					; if not, branch

		move.l	#Geyser_Delete,obID(a0)			; advance to Geyser_Delete
		movea.l	gmake_parent(a0),a1			; get parent bubbling (top) tip object
		move.b	#3,obAnim(a1)				; set bubbler to ".bubble3" animation (will advance routine on finish)

	.return:
; ---------------------------------------------------------------------------

Geyser_Animate:
		bsr.w	SpeedToPos				; update position

		lea	(Ani_Geyser).l,a1
		bsr.w	AnimateSprite

Geyser_ChkDel:
		out_of_range.w	DeleteObject
		DisplaySprite
		rts
; ===========================================================================

Geyser_Type01:	; fall
		addi.w	#$18,obVelY(a0)				; increase object's falling speed
		move.w	geyser_origY(a0),d0			; get original Y-position
		cmp.w	obY(a0),d0				; has object fallen below original position?
		bhs.s	.return					; if not, branch

		move.l	#Geyser_Delete,obID(a0)			; advance to Geyser_Delete
		movea.l	gmake_parent(a0),a1			; get parent bubbling (top) tip object
		move.b	#1,obAnim(a1)				; set bubbler to ".bubble1" animation
	.return:
		bra.s	Geyser_Animate
; ===========================================================================

; loc_EFFC: Geyser_Middle:
Geyser_BigLavaWall: ; Routine 4
		movea.l	gmake_parent(a0),a1			; get bubbling top tip object
		cmpi.l	#Geyser_Delete,obID(a1)			; has it marked itself for deletion?
		beq.w	Geyser_Delete				; if yes, delete lava wall as well

		move.w	obY(a1),d0				; get current Y-position of bubbling top tip
		addi.w	#$60,d0					; add lava wall offset
		move.w	d0,obY(a0)				; vertically move lava wall with tip

		; This sets the lava wall's frame depending on how far it has moved away from
		; the Y-origin. There are three sizes, with two frame variations per size.
		; Interestingly they all have a third frame variation as well, but it goes
		; unused and is broken, the graphics are overwritten by the sideways lava wall.
		; It probably got added late into development and the third frames were cut.
		sub.w	geyser_origY(a0),d0			; subtract original Y-position from current one
		neg.w	d0					; d0 = pixels above original Y-position
		moveq	#8,d1					; use medium-size sprite mapping (".medcolumn1")
		cmpi.w	#$40,d0					; has lava wall moved more than $40px above origin?
		bge.s	.checkLong				; if yes, branch
		moveq	#$B,d1					; use short-size sprite mapping (".shortcolumn1")
	.checkLong:
		cmpi.w	#$80,d0					; has lava wall moved more than $80px above origin?
		ble.s	.aniFrameOffset				; if not, branch
		moveq	#$E,d1					; use long-size sprite mapping (".longcolumn3")
	.aniFrameOffset:
		subq.b	#1,obTimeFrame(a0)			; decrement frame offset time delay
		bpl.s	.setLavaWallFrame			; if time remains, branch
		move.b	#8-1,obTimeFrame(a0)			; reset time delay for frame advance
		addq.b	#1,obAniFrame(a0)			; advance to next frame
		cmpi.b	#2,obAniFrame(a0)			; reached frame 2? (not 3!)
		blo.s	.setLavaWallFrame			; if not, branch
		move.b	#0,obAniFrame(a0)			; reset to 0 (alternate between frame offset 0 and 1)

	.setLavaWallFrame:
		move.b	obAniFrame(a0),d0			; get frame ID offset
		add.b	d1,d0					; add base offset for vertical length
		move.b	d0,obFrame(a0)				; set final lava wall frame ID

		bra.w	Geyser_ChkDel
; ===========================================================================

Geyser_Delete:	; Routine 6
		bra.w	DeleteObject

; ===========================================================================

		include	"_anim/Lava Geyser.asm"
Map_Geyser:	include	"_maps/Lava Geyser.asm"
