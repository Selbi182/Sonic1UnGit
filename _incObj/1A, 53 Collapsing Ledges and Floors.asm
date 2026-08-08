; ---------------------------------------------------------------------------
; NOTE: Object 1A and 53 were merged into the same text file because their
; fragmentation logic is shared and very tightly coupled together, despite
; the two objects being located in entirely different zones. They are more
; or less direct copies of each other, only with slight format adjustments.
; ---------------------------------------------------------------------------

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1A - collapsing ledge (GHZ)
; ---------------------------------------------------------------------------

CollapseLedge:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ledge_Index(pc,d0.w),d1
		jmp	Ledge_Index(pc,d1.w)
; ===========================================================================
Ledge_Index:	dc.w Ledge_Main-Ledge_Index
		dc.w Ledge_ChkTouch-Ledge_Index
		dc.w Ledge_OnPlatform-Ledge_Index
		dc.w Ledge_FragmentPiece-Ledge_Index
		dc.w Ledge_Delete-Ledge_Index
		dc.w Ledge_WalkOff-Ledge_Index
		dc.w Ledge_Fragment-Ledge_Index

collapsible_timedelay:	equ objoff_38	; delay before fragment starts to fall
collapsible_flag:	equ objoff_3A	; flag set if collapsing has started
; ===========================================================================

Ledge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Ledge,obMap(a0)
		move.w	#ArtTile_Level|Tile_Pal3,obGfx(a0)
		ori.b	#sprite_cam_field,obRender(a0)
		move.w	#spr_prio4,obPriority(a0)
		move.b	#7,collapsible_timedelay(a0)		; set time delay for collapse
		move.b	#96/2,obActWid(a0)
		move.b	obSubtype(a0),obFrame(a0)		; use subtype as frame ID (0 or 1)
		move.b	#112/2,obHeight(a0)
		bset	#sprite_customheight_bit,obRender(a0)	; set custom height flag

Ledge_ChkTouch:	; Routine 2
		tst.b	collapsible_flag(a0)			; is ledge collapsing?
		beq.s	.chkTouch				; if not, branch
		tst.b	collapsible_timedelay(a0)		; has time reached zero?
		beq.w	Fragmentate_GHZLedge			; if yes, begin fragmentation
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time (Sonic not on platform)

	.chkTouch:
		move.w	#96/2,d1
		lea	(Ledge_SlopeData).l,a2
		bsr.w	SlopeObject				; sets obRoutine to 4 on touch (Ledge_OnPlatform)
		RememberState
		rts
; ===========================================================================

Ledge_OnPlatform:	; Routine 4
		tst.b	collapsible_timedelay(a0)		; has time reached zero?
		beq.w	Fragmentate_GHZLedge_NoReset		; if yes, begin fragmentation
		move.b	#1,collapsible_flag(a0)			; set collapse flag
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time (Sonic on platform)
; ---------------------------------------------------------------------------

Ledge_WalkOff:	; Routine $A
		move.w	#96/2,d1
		bsr.w	ExitPlatform				; sets obRoutine back to 2 on exit (Ledge_ChkTouch)

		move.w	#96/2,d1
		lea	(Ledge_SlopeData).l,a2
		move.w	obX(a0),d2
		bsr.w	SlopeObject_AssumeStoodOn

		RememberState
		rts
; ===========================================================================

Ledge_FragmentPiece:	; Routine 6
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		beq.s	.fragmentFall				; if yes, branch
		tst.b	collapsible_flag(a0)			; is ledge collapsing?
		bne.w	.delayCollapse				; if yes, branch
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time
		DisplaySprite
		rts
; ---------------------------------------------------------------------------

.delayCollapse:
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time

		bsr.w	Ledge_WalkOff				; allow Sonic to move off the platform

		lea	(v_player).w,a1				; load Sonic object
		btst	#3,obStatus(a1)				; is Sonic standing on platform?
		beq.s	.startCollapse				; if not, branch
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		bne.s	.return					; if not, branch
		bclr	#3,obStatus(a1)				; clear Sonic's on-platform flag
		bclr	#5,obStatus(a1)				; clear Sonic's pushing flag
		move.b	#id_Run,obPrevAni(a1)			; restart Sonic's animation

	.startCollapse:
		move.b	#0,collapsible_flag(a0)
		move.b	#6,obRoutine(a0)			; run "Ledge_FragmentPiece" routine

	.return:
		rts
; ---------------------------------------------------------------------------

.fragmentFall:
		move.b	#$C,obRoutine(a0)
		bset	#sprite_customheight_bit,obRender(a0)	; set custom height flag
		move.b	#112/2,obHeight(a0)

Ledge_Fragment:
		tst.b	obRender(a0)
		bpl.s	Ledge_Delete

		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,obX(a0)				; add X speed to X position (note this affects the subpixel position)
		asl.l	#8,d2					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,obY(a0)				; add Y speed to Y position (note this affects the subpixel position)
		add.w	#gravity,obVelY(a0)			; increase vertical speed (apply gravity)

		DisplaySprite
		rts
; ===========================================================================

Ledge_Delete:	; Routine 8
		bra.w	DeleteObject


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 53 - collapsing floors (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

CollapseFloor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	CFlo_Index(pc,d0.w),d1
		jmp	CFlo_Index(pc,d1.w)
; ===========================================================================
CFlo_Index:	dc.w CFlo_Main-CFlo_Index
		dc.w CFlo_ChkTouch-CFlo_Index
		dc.w CFlo_OnPlatform-CFlo_Index
		dc.w CFlo_FragmentPiece-CFlo_Index
		dc.w CFlo_Delete-CFlo_Index
		dc.w CFlo_WalkOff-CFlo_Index
; ===========================================================================

CFlo_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_CFlo,obMap(a0)
		move.w	#ArtTile_MZ_Block|Tile_Pal3,obGfx(a0)

		cmpi.b	#id_SLZ,(v_zone).w			; check if level is SLZ
		bne.s	.notSLZ					; if not, branch
		move.w	#ArtTile_SLZ_Collapsing_Floor|Tile_Pal3,obGfx(a0) ; SLZ specific code
		addq.b	#2,obFrame(a0)
	.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w			; check if level is SBZ
		bne.s	.notSBZ					; if not, branch
		move.w	#ArtTile_SBZ_Collapsing_Floor|Tile_Pal3,obGfx(a0) ; SBZ specific code
	.notSBZ:
		ori.b	#sprite_cam_field,obRender(a0)
		move.w	#spr_prio4,obPriority(a0)
		move.b	#7,collapsible_timedelay(a0)		; set time delay for collapse
		move.b	#136/2,obActWid(a0)
; ---------------------------------------------------------------------------

CFlo_ChkTouch:	; Routine 2
		tst.b	collapsible_flag(a0)			; has Sonic touched the object?
		beq.s	.solid					; if not, branch
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		beq.w	Fragmentate_8x2Floor			; if yes, begin fragmentation
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time

	.solid:
		move.w	#64/2,d1
		bsr.w	PlatformObject				; sets obRoutine to 4 on touch (CFlo_OnPlatform)

		; This appears to add a small visual effect specifically to SLZ platforms
		; to invert their collapsing pattern depending on which side was touched.
		tst.b	obSubtype(a0)				; is MSB in subtype set? (>= $80)
		bpl.s	.display				; if not, branch
		btst	#3,obStatus(a1)				; is Sonic standing on platform?
		beq.s	.display				; if not, branch
		bclr	#sprite_xflip_bit,obRender(a0)		; clear X-flip flag
		move.w	obX(a1),d0				; get Sonic's X-position
		sub.w	obX(a0),d0				; has Sonic touched the right side of the platform?
		bcc.s	.display				; if not, branch
		bset	#sprite_xflip_bit,obRender(a0)		; flip platform to inverse collapsing pattern

	.display:
		RememberState
		rts
; ===========================================================================

CFlo_OnPlatform:	; Routine 4
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		beq.w	Fragmentate_8x2Floor_NoReset		; if yes, branch
		move.b	#1,collapsible_flag(a0)			; set object as "touched"
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time
; ---------------------------------------------------------------------------

CFlo_WalkOff:	; Routine $A
		move.w	#64/2,d1
		bsr.w	ExitPlatform

		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm2
		RememberState
		rts
; ===========================================================================

CFlo_FragmentPiece:	; Routine 6
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		beq.s	.fragmentFall				; if yes, branch
		tst.b	collapsible_flag(a0)			; has Sonic touched the object?
		bne.w	.delayCollapse				; if yes, branch
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time
		DisplaySprite
		rts
; ---------------------------------------------------------------------------

.delayCollapse:
		subq.b	#1,collapsible_timedelay(a0)		; subtract 1 from time

		bsr.w	CFlo_WalkOff				; allow Sonic to walk off the platform

		lea	(v_player).w,a1				; load Sonic object
		btst	#3,obStatus(a1)				; is Sonic standing on platform?
		beq.s	.startCollapse				; if not, branch
		tst.b	collapsible_timedelay(a0)		; has time delay reached zero?
		bne.s	.return					; if not, branch
		bclr	#3,obStatus(a1)				; clear Sonic's on-platform flag
		bclr	#5,obStatus(a1)				; clear Sonic's pushing flag
		move.b	#id_Run,obPrevAni(a1)			; restart Sonic's animation

	.startCollapse:
		move.b	#0,collapsible_flag(a0)
		move.b	#6,obRoutine(a0)			; run "CFlo_FragmentPiece" routine

	.return:
		rts
; ---------------------------------------------------------------------------

.fragmentFall:
		bsr.w	ObjectFall
		tst.b	obRender(a0)
		bpl.s	CFlo_Delete
		DisplaySprite
		rts
; ===========================================================================

CFlo_Delete:	; Routine 8
		bsr.w	DeleteObject
		rts
; ===========================================================================


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutines to fragmentate collapsible ledges and floors
; ---------------------------------------------------------------------------

; Entry point to fragmentate 8x2 MZ/SLZ/SBZ floors
Fragmentate_8x2Floor:
		move.b	#0,collapsible_flag(a0)			; reset collapsing flag

Fragmentate_8x2Floor_NoReset:
		; After looking through all object layouts, it appears that type A (swipe)
		; is never used anywhere in the game. The developers probably preferred
		; the visual flair of type B (shuffled) and ended up using it everywhere.
		lea	(CollapseData_8x2_Swipe).l,a4		; use left-to-right collapse data by default
		btst	#0,obSubtype(a0)			; is least significant bit in subtype set?
		beq.s	.setupFrag				; if not, branch
		lea	(CollapseData_8x2_Shuffle).l,a4		; use shuffled collapse data instead

	.setupFrag:
		moveq	#8-1,d1					; fragmentate floor into 8 pieces
		addq.b	#1,obFrame(a0)				; advance to next frame which consists of 8 sprite pieces
		bra.s	FragmentatePlatform			; skip over GHZ ledge
; ===========================================================================

; Entry point to fragmentate GHZ ledges
Fragmentate_GHZLedge:
		move.b	#0,collapsible_flag(a0)			; reset collapsing flag

Fragmentate_GHZLedge_NoReset:
		lea	(CollapseData_GHZLedge).l,a4		; use special GHZ ledge collapse data
		moveq	#25-1,d1				; fragmentate ledge into 25 pieces
		addq.b	#2,obFrame(a0)				; advance two frames which consists of 25 sprite pieces
; ---------------------------------------------------------------------------

FragmentatePlatform:
		moveq	#0,d0					; clear d0
		move.b	obFrame(a0),d0				; get current frame ID
		add.w	d0,d0					; double it for word-based indexing
		movea.l	obMap(a0),a3				; get object mappings pointer
		adda.w	(a3,d0.w),a3				; find sprite mapping for current frame ID
		addq.w	#1,a3					; skip over piece count header
		bset	#sprite_rawmappings_bit,obRender(a0)	; set "raw-mappings" flag
		move.b	obID(a0),d4				; copy object ID to fragments
		move.b	obRender(a0),d5				; copy render flags to fragments
		movea.l	a0,a1					; overwrite main platform with first fragment object
		bra.s	.firstFragment				; skip loop for first fragment
; ===========================================================================

.loopFragments:




; FindNextFreeObj:
		movea.l	a1,a2					; get RAM location of parent object
		move.w	#v_lvlobjend&$FFFF,d0			; get end location of object RAM (16-bit)
		sub.w	a1,d0					; d0 = remaining RAM after parent object
		lsr.w	#6,d0					; divide by $40 (object_size)
		subq.w	#1,d0					; minus 1 for dbf
		bcs.s	.NFree_Found				; if underflowed, parent object is at the end of RAM, quit

.NFree_Loop:
		tst.b	obID(a2)				; is object RAM slot empty?
		beq.s	.NFree_Found				; if yes, exit and use that slot
		lea	object_size(a2),a2			; go to next object RAM slot
		dbf	d0,.NFree_Loop				; repeat for all free object RAM slots after parent

.NFree_Found:
		bne.s	.fragmentationDone			; if object RAM is full, branch


		movea.w	a2,a1




		addq.w	#5,a3					; advance to next sprite piece in mappings
	.firstFragment:
		move.b	#6,obRoutine(a1)			; set fragment routine to "..._FragmentPiece"
		move.b	d4,obID(a1)				; copy object ID
		move.l	a3,obMap(a1)				; copy mappings
		move.b	d5,obRender(a1)				; copy render flags
		move.w	obX(a0),obX(a1)				; copy X position
		move.w	obY(a0),obY(a1)				; copy Y position
		move.w	obGfx(a0),obGfx(a1)			; copy art tile
		move.w	obPriority(a0),obPriority(a1)		; copy sprite priority
		move.b	obActWid(a0),obActWid(a1)		; copy display width

		move.b	(a4)+,collapsible_timedelay(a1)		; write next time delay from "CollapseData_..." array

		dbf	d1,.loopFragments			; loop until all fragments have been spawned in

.fragmentationDone:
		DisplaySprite				; render first fragment this frame
		move.w	#sfx_Collapse,d0			; set collapsing floor sound
		jmp	(QueueSound2).l				; play it

; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing platforms. Each byte represents a number
; of frames to wait before the individual platform fragment starts falling.
; ---------------------------------------------------------------------------

CollapseData_GHZLedge: ; 25 fragments, matching sprite piece order of ledge
		dc.b $1C, $18, $14, $10
		dc.b $1A, $16, $12, $0E, $0A, $06
		dc.b $18, $14, $10, $0C, $08, $04
		dc.b $16, $12, $0E, $0A, $06, $02
		dc.b $14, $10, $0C
		even
; ---------------------------------------------------------------------------
CollapseData_8x2_Swipe: ; 8 fragments, going left to right (unused)
		dc.b $1E, $16, $0E, $06
		dc.b $1A, $12, $0A, $02
		even

CollapseData_8x2_Shuffle: ; 8 fragments, shuffled order
		dc.b $16, $1E, $1A, $12
		dc.b $06, $0E, $0A, $02
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Alternate version of SlopeObject subroutine that assumes Sonic is already
; standing on the platform (skipping the relevant checks).
; 
; input:
;	d1.w = platform half width
;	d2.w = X-position of platform
;	a2 = address of heightmap data
; ---------------------------------------------------------------------------

; SlopeObject2:
SlopeObject_AssumeStoodOn:
		lea	(v_player).w,a1				; get Sonic object
		btst	#3,obStatus(a1)				; is Sonic standing on a platform object?
		beq.s	.return					; if not, branch

		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#sprite_xflip_bit,obRender(a0)		; is ledge mirrored?
		beq.s	.alignSonic				; if not, branch
		not.w	d0
		add.w	d1,d0

	.alignSonic:
		moveq	#0,d1
		move.b	(a2,d0.w),d1				; get relevant byte from Ledge_SlopeData
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)				; align Sonic to slope (Y-axis)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)				; align Sonic to slope (X-axis)

	.return:
		rts
; End of function SlopeObject_AssumeStoodOn

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge (not to scale):
;
;            $2F > /---------- < $30
;                 /
;                /
; $20 > --------/ < $21
;
; Each step is repeated once.
; ---------------------------------------------------------------------------

Ledge_SlopeData:
	dcb.b	4*2,$20		; flat
	range	$21,$2F,+1,2	; ascending
	dcb.b	5*2,$30		; flat
	even
; ===========================================================================

Map_Ledge:	include	"_maps/Collapsing Ledge.asm"
Map_CFlo:	include	"_maps/Collapsing Floors.asm"
