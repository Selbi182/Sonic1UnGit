; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load level boundaries and start locations
; ---------------------------------------------------------------------------

LevelSizeLoad:
		moveq	#0,d0					; clear d0
		move.b	d0,(v_unused7).w			; clear unused variables
		move.b	d0,(v_unused8).w			; ''
		move.b	d0,(v_unused9).w			; ''
		move.b	d0,(v_unused10).w			; ''
		move.b	d0,(v_dle_routine).w			; reset DynamicLevelEvents routine
		move.b	d0,(f_nobgscroll).w			; clear no-background scroll flag

		move.w	(v_zone_act).w,d0			; get current zone and act
		lsl.b	#6,d0					; align act ID bits next to zone ID
		lsr.w	#4,d0					; send zone and act all back together but keep at x4
		move.w	d0,d1					; copy
		add.w	d0,d0					; multiply by 2
		add.w	d1,d0					; multiply to x3 (d0 = index in LevelSizeArray for current zone and act)
		lea	LevelSizeArray(pc,d0.w),a0		; load level boundaries

		move.w	(a0)+,d0				; (unused) load first entry in level size array
		move.w	d0,(v_unused11).w			; write to unused variable (this is always $0004)

		move.l	(a0)+,d0				; load left and right level boundaries (two words, read as long)
		move.l	d0,(v_limitleft2).w			; set left and right boundaries (actual)
		move.l	d0,(v_limitleft1).w			; set left and right boundaries (target)

		move.l	(a0)+,d0				; load top and bottom level boundaries (two words, read as long)
		move.l	d0,(v_limittop2).w			; set top and bottom boundaries (actual)
		move.l	d0,(v_limittop1).w			; set top and bottom boundaries (target)

		move.w	(v_limitleft2).w,d0			; get initial left boundary
		addi.w	#$240,d0				; add $240 (screen width + 256px)
		move.w	d0,(v_limitleft3).w			; (unused) write to unused variable

		move.w	#$1010,(v_fg_xblock).w			; trigger v_fg_xblock/v_fg_yblock to immediately draw a new column on start

		move.w	(a0)+,d0				; load final entry in level size array
		move.w	d0,(v_lookshift).w			; write to vertical look shift (redundant, this is always $0060)

		bra.w	LevSz_InitScreenAndPlayerStart		; continue to remaining level setup for start location and camera position


; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array
; ---------------------------------------------------------------------------
LevelSizeArray:
		include	"_inc/LevelSizeArray.asm"

; ---------------------------------------------------------------------------
; Ending start location array
; (Previously separated into "_inc/Start Location Array - Ending.asm")
; ---------------------------------------------------------------------------
EndingStLocArray:
		binclude	"startpos/Credits Demos/ghz1 (Credits demo 1).bin"
		binclude	"startpos/Credits Demos/mz2 (Credits demo).bin"
		binclude	"startpos/Credits Demos/syz3 (Credits demo).bin"
		binclude	"startpos/Credits Demos/lz3 (Credits demo).bin"
		binclude	"startpos/Credits Demos/slz3 (Credits demo).bin"
		binclude	"startpos/Credits Demos/sbz1 (Credits demo).bin"
		binclude	"startpos/Credits Demos/sbz2 (Credits demo).bin"
		binclude	"startpos/Credits Demos/ghz1 (Credits demo 2).bin"


; ===========================================================================
; ---------------------------------------------------------------------------
; Initialize Sonic's start location, initial screen position
; ---------------------------------------------------------------------------

; LevSz_ChkLamp:
LevSz_InitScreenAndPlayerStart:
		tst.b	(v_lastlamp).w				; are we respawning from a lamppost?
		beq.s	LevSz_StartLoc				; if not, branch

		jsr	(Lamp_LoadInfo).l			; restore all saved variables in Object 79

		move.w	(v_player+obX).w,d1			; use Sonic's restored positions to initialize camera
		move.w	(v_player+obY).w,d0
		bra.s	LevSz_InitCameraPositions		; don't use initial starting position
; ===========================================================================

LevSz_StartLoc:
		cmpi.b	#id_Title,(v_gamemode).w		; is this the title screen?
		bne.s	.getStartLocEntry			; if not, branch
		move.w	#$0050,d1				; X coordinate (this also dictates the little delay before the title screen starts scrolling)
		move.w	#$03B0,d0				; Y coordinate
		move.w	d1,(v_player+obX).w			; set X coordinate
		move.w	d0,(v_player+obY).w			; set Y coordinate
		bra.s	LevSz_InitCameraPositions		; skip normal Sonic's start location logic

	.getStartLocEntry:
		move.w	(v_zone_act).w,d0			; get current zone and act
		lsl.b	#6,d0
		lsr.w	#4,d0					; d0 = index in StartLocArray for current zone and act
		lea	StartLocArray(pc,d0.w),a1		; load Sonic's start location

		tst.w	(f_demo).w				; is ending credits demo mode on?
		bpl.s	.setSonicPosition			; if not, branch
		move.w	(v_creditsnum).w,d0			; get current credits text page
		subq.w	#1,d0					; sub 1 for 0-based indexing
		lsl.w	#2,d0					; multiply by 4 bytes per entry
		lea	EndingStLocArray(pc,d0.w),a1		; load Sonic's start location in ending credits demo

	; LevSz_SonicPos:
	.setSonicPosition:
		moveq	#0,d1					; clear d1
		move.w	(a1)+,d1				; load starting X-position
		move.w	d1,(v_player+obX).w			; set Sonic's position on x-axis

		moveq	#0,d0					; clear d0
		move.w	(a1),d0					; load starting Y-position
		move.w	d0,(v_player+obY).w			; set Sonic's position on y-axis
; ---------------------------------------------------------------------------

; SetScreen: LevSz_SkipStartPos:
LevSz_InitCameraPositions:
	; --- Camera X-Position ---
	.chkXLeft:
		subi.w	#320/2,d1				; initial camera X-position is Sonic horizontally centered on the screen
		bhs.s	.chkXRight				; is Sonic more than 160px from left edge? if yes, branch
		moveq	#0,d1					; prevent X-camera from underflowing
	.chkXRight:
		move.w	(v_limitright2).w,d2			; get right level boundary
		cmp.w	d2,d1					; is Sonic inside the right edge?
		blo.s	.setX					; if yes, branch
		move.w	d2,d1					; prevent X-camera from going past right edge
	.setX:	move.w	d1,(v_screenposx).w			; set initial horizontal screen position

	; --- Camera Y-Position ---
	.chkYTop:
		subi.w	#(224/2)-16,d0				; initial camera Y-position is Sonic vertically centered on the screen
		bhs.s	.chkYBottom				; is Sonic within 96px of upper edge? if yes, branch
		moveq	#0,d0					; prevent Y-camera from underflowing
	.chkYBottom:
		cmp.w	(v_limitbtm2).w,d0			; is Sonic above the bottom edge?
		blt.s	.setY					; if yes, branch
		move.w	(v_limitbtm2).w,d0			; prevent Y-camera from going past bottom edge
	.setY:	move.w	d0,(v_screenposy).w			; set initial vertical screen position
; ---------------------------------------------------------------------------

LevSz_InitBackgroundAndLoops:
		bsr.w	BgScrollSpeed				; setup background scroll positions

		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		lsl.b	#2,d0					; multiply by 4 bytes per loop chunk data entry
		move.l	LoopChunkNums(pc,d0.w),(v_256loop1).w	; set loop chunk data for current zone

		rts						; return
; End of function LevelSizeLoad


; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic start location array
; (Previously separated into "_inc/Start Location Array - Levels.asm")
; ---------------------------------------------------------------------------
; All unused acts default to the same starting location of x=$0080, y=$00A8
unused_startloc: macro
		dc.w	$0080,$00A8
		endm
; ---------------------------------------------------------------------------

StartLocArray:	binclude	"startpos/ghz1.bin"
		binclude	"startpos/ghz2.bin"
		binclude	"startpos/ghz3.bin"
		unused_startloc

		binclude	"startpos/lz1.bin"
		binclude	"startpos/lz2.bin"
		binclude	"startpos/lz3.bin"
		binclude	"startpos/sbz3.bin"	; SBZ3 is LZ4 internally

		binclude	"startpos/mz1.bin"
		binclude	"startpos/mz2.bin"
		binclude	"startpos/mz3.bin"
		unused_startloc

		binclude	"startpos/slz1.bin"
		binclude	"startpos/slz2.bin"
		binclude	"startpos/slz3.bin"
		unused_startloc

		binclude	"startpos/syz1.bin"
		binclude	"startpos/syz2.bin"
		binclude	"startpos/syz3.bin"
		unused_startloc

		binclude	"startpos/sbz1.bin"
		binclude	"startpos/sbz2.bin"
		binclude	"startpos/fz.bin"	; FZ is SBZ3 internally
		unused_startloc

		binclude	"startpos/end1.bin"
		binclude	"startpos/end2.bin"
		unused_startloc
		unused_startloc

; ===========================================================================
; ---------------------------------------------------------------------------
; Which 256x256 tiles contain loops or roll-tunnels. Values above $80 are
; when the special chunks are active, and $7F is a blank placeholder value.
; ---------------------------------------------------------------------------

; LoopTileNums:
LoopChunkNums:	; 	loop	loop	tunnel	tunnel
		dc.b	$B5,	$7F,	$1F,	$20	; Green Hill
		dc.b	$7F,	$7F,	$7F,	$7F	; Labyrinth
		dc.b	$7F,	$7F,	$7F,	$7F	; Marble
		dc.b	$AA,	$B4,	$7F,	$7F	; Star Light
		dc.b	$7F,	$7F,	$7F,	$7F	; Spring Yard
		dc.b	$7F,	$7F,	$7F,	$7F	; Scrap Brain
		dc.b	$7F,	$7F,	$7F,	$7F	; Ending (Green Hill)
; ===========================================================================


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to setup scroll positions (mostly to set the backgrounds in the right place)
; 
; input:
;	d0 = initial FG camera Y-position
;	d1 = initial FG camera X-position
; ---------------------------------------------------------------------------

BgScrollSpeed:
		tst.b	(v_lastlamp).w				; are we respawning from a lamppost?
		bne.s	.setupZone				; if yes, do not alter background positions
		move.w	d0,(v_bgscreenposy).w			; set background Y-position
		move.w	d0,(v_bg2screenposy).w			; ''
		move.w	d0,(v_bg3screenposy).w			; ''
		move.w	d1,(v_bgscreenposx).w			; set background X-position
		move.w	d1,(v_bg2screenposx).w			; ''
		move.w	d1,(v_bg3screenposx).w			; ''

	; loc_6206:
	.setupZone:
		moveq	#0,d2					; clear d2
		move.b	(v_zone).w,d2				; get zone ID
		add.w	d2,d2					; double for word-based indexing
		move.w	BgScroll_Index(pc,d2.w),d2		; find entry in offset table
		jmp	BgScroll_Index(pc,d2.w)			; jump to background setup logic for zone

; ===========================================================================
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index
		dc.w BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_MZ-BgScroll_Index
		dc.w BgScroll_SLZ-BgScroll_Index
		dc.w BgScroll_SYZ-BgScroll_Index
		dc.w BgScroll_SBZ-BgScroll_Index
		dc.w BgScroll_End-BgScroll_Index
; ===========================================================================

BgScroll_GHZ:
		clr.l	(v_bgscreenposx).w			; force BG X-position to 0

		clr.l	(v_bgscreenposy).w			; force BG Y-positions to 0
		clr.l	(v_bg2screenposy).w			; ''
		clr.l	(v_bg3screenposy).w			; ''

		lea	(v_bgscroll_buffer).w,a2		; clear GHZ BG clouds autoscroll buffer
		clr.l	(a2)+					; '' (upper clouds)
		clr.l	(a2)+					; '' (middle clouds)
		clr.l	(a2)+					; '' (lower clouds)
		rts						; return
; ===========================================================================

BgScroll_LZ:
		asr.l	#1,d0					; divide Y-position by 2
		move.w	d0,(v_bgscreenposy).w			; set BG Y-position (half the speed of FG)
		rts						; return
; ===========================================================================

BgScroll_MZ:
		rts						; return (no setup for MZ required)
; ===========================================================================

BgScroll_SLZ:
		asr.l	#1,d0					; divide Y-position by 2
		addi.w	#$C0,d0					; scroll it up by $C0px (manual adjustment)
		move.w	d0,(v_bgscreenposy).w			; set BG Y position
		clr.l	(v_bgscreenposx).w			; force BG X-position to 0
		rts						; return
; ===========================================================================

BgScroll_SYZ:
		asl.l	#4,d0					; multiply Y-position by $10
		move.l	d0,d2					; backup
		asl.l	#1,d0					; double again
		add.l	d2,d0					; d0 = Y-position * $30
		asr.l	#8,d0					; divide by $100 ($30% the speed of FG)
		addq.w	#1,d0					; manually shift up by 1 extra pixel
		move.w	d0,(v_bgscreenposy).w			; set BG Y-position
		clr.l	(v_bgscreenposx).w			; force BG X-position to 0
		rts						; return
; ===========================================================================

BgScroll_SBZ:
		andi.w	#$7F8,d0				; wrap Y-position, rounded to nearest multiple of 8px
		asr.w	#3,d0					; divide by 8
		addq.w	#1,d0					; manually shift up by 1 extra pixel
		move.w	d0,(v_bgscreenposy).w			; set BG Y-position
		rts						; return
; ===========================================================================

BgScroll_End:
		move.w	(v_screenposx).w,d0			; get starting FG X-position
		asr.w	#1,d0					; divide by 2
		move.w	d0,(v_bgscreenposx).w			; set as starting BG X-position
		move.w	d0,(v_bg2screenposx).w			; ''
		asr.w	#2,d0					; divide again by 4
		move.w	d0,d1					; copy
		add.w	d0,d0					; double
		add.w	d1,d0					; d0 = 3 * v_screenposx / 8
		move.w	d0,(v_bg3screenposx).w			; set tertiary starting BG X-position

		clr.l	(v_bgscreenposy).w			; force BG Y-positions to 0
		clr.l	(v_bg2screenposy).w			; ''
		clr.l	(v_bg3screenposy).w			; ''

		lea	(v_bgscroll_buffer).w,a2		; clear GHZ BG clouds autoscroll buffer
		clr.l	(a2)+					; '' (upper clouds)
		clr.l	(a2)+					; '' (middle clouds)
		clr.l	(a2)+					; '' (lower clouds)
		rts						; return
; End of function BgScrollSpeed
