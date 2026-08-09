; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

TitleSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TSon_Index(pc,d0.w),d1
		jmp	TSon_Index(pc,d1.w)
; ===========================================================================
TSon_Index:	dc.w TSon_Main-TSon_Index
		dc.w TSon_Delay-TSon_Index
		dc.w TSon_Move-TSon_Index
		dc.w TSon_Animate-TSon_Index
; ===========================================================================

TSon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advance to TSon_Delay
		move.w	#$80+$78,obX(a0)			; +8px
		move.w	#$80+$5E,obY(a0)			; set initial Y-position
		move.l	#Map_TSon,obMap(a0)			; set mappings
		move.w	#ArtTile_Title_Sonic|Tile_Pal2,obGfx(a0) ; set art tile and palette line
		move.w	#spr_prio7,obPriority(a0)			; set sprite priority
		move.b	#30-1,obDelayAni(a0)			; set time delay before Sonic moves in to 0.5 seconds
		lea	(Ani_TSon).l,a1				; load animation script
		bsr.w	AnimateSprite				; advance animation once
; ---------------------------------------------------------------------------

TSon_Delay:	; Routine 2
		subq.b	#1,obDelayAni(a0)			; decrement animation delay
		bpl.s	.wait					; if time remains, branch
		addq.b	#2,obRoutine(a0)			; advance to TSon_Move
		DisplaySprite
		rts				; start displaying Sonic's sprite
	.wait:
		rts						; return
; ===========================================================================

TSon_Move:	; Routine 4
		subq.w	#8,obY(a0)				; move Sonic up
		cmpi.w	#$80+$16,obY(a0)			; has Sonic reached final Y-position?
		bne.s	.display				; if not, branch
		addq.b	#2,obRoutine(a0)			; advance to TSon_Animate
	.display:
		DisplaySprite
		rts				; display Sonic sprite
; ===========================================================================

TSon_Animate:	; Routine 6
		lea	(Ani_TSon).l,a1				; load animation script
		bsr.w	AnimateSprite				; advance animation (will loop on the last two finger-wagging frames)
		DisplaySprite
		rts				; display Sonic sprite


; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON", "TM", and masking sprites on title screen
; ---------------------------------------------------------------------------

PSBTM:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PSB_Index(pc,d0.w),d1
		jsr	PSB_Index(pc,d1.w)
		DisplaySprite
		rts
; ===========================================================================
PSB_Index:	dc.w PSB_Main-PSB_Index
		dc.w PSB_PrsStart-PSB_Index
		dc.w PSB_Exit-PSB_Index
; ===========================================================================

PSB_Main:	; Routine 0

		; This code handles three different variations of title screen objects,
		; all depending on what the frame ID was when the object was loaded
		; (see the code around ".isjap" in "GM_Title").

		addq.b	#2,obRoutine(a0)			; advance to PSB_PrsStart (animate)
		move.w	#$80+$58,obX(a0)			; +8px
		move.w	#$80+$B0,obY(a0)			; set Y-position
		move.l	#Map_PSB,obMap(a0)			; set mappings
		move.w	#ArtTile_Title_PressStart,obGfx(a0)	; set art tile (separated from foreground emblem)

		cmpi.b	#2,obFrame(a0)				; is object "PRESS START"?
		blo.s	PSB_PrsStart_Setup			; if yes, branch

		; Set up sprite mask to hide Sonic's torso
		clr.w	obGfx(a0)				; force art tile ID $0000
		clr.w	obX(a0)					; force X-position 0 to activate masking
		move.w	#$80+104,obY(a0)			; set Y-position to cover Sonic's torso to 104px
		move.w	#spr_prio6,obPriority(a0)		; set sprite priority for sprite mask (above Sonic)

		; Object is either TM or masking sprites
		addq.b	#2,obRoutine(a0)			; advance to PSB_Exit (static)
		cmpi.b	#3,obFrame(a0)				; is the object "TM"?
		bne.s	PSB_Exit				; if not, branch (object is masking sprites)

		move.w	#ArtTile_Title_Trademark|Tile_Pal2,obGfx(a0) ; "TM" specific art tile
		move.w	#spr_prio0,obPriority(a0)			; set sprite priority for TM (highest)
		move.w	#$80+$F8,obX(a0)			; +8px
		move.w	#$80+$78,obY(a0)			; set Y-position for TM
; ---------------------------------------------------------------------------

PSB_Exit:	; Routine 4
		rts						; return to display sprite
; ===========================================================================

PSB_PrsStart_Setup:
		move.w	#$80+$58+$40,obX(a0)			; adjust PSB X-position for new system

PSB_PrsStart:	; Routine 2
		tst.b	ob2ndRout(a0)				; has menu already been activated?
		bne.s	PSB_TitleMenu				; if yes, branch

		btst	#bitStart,(v_jpadpress1).w		; was START button pressed?
		bne.s	.activateMenu				; if yes, branch
		lea	(Ani_PSBTM).l,a1			; "PRESS START" is animated
		bra.w	AnimateSprite				; flash PSB object
; ===========================================================================

	.activateMenu:
		clr.b	(v_jpadpress1).w			; make sure button press doesn't trigger game begin on title screen yet
		move.b	#1,ob2ndRout(a0)			; activate title menu
		move.l	#Map_PSBMenu,obMap(a0)			; use new mappings set
		move.w	#ArtTile_Title_Menu,obGfx(a0)		; use menu art tile
		clr.b	obFrame(a0)				; force initial selection to first entry
		move.b	#sfx_GiantRing,d0			; set giant ring sound
		jsr	(QueueSound2).l				; play it
		move.w	#$80+$58,obX(a0)			; adjust PSB X-position for new system
		move.w	#3000,(v_generictimer).w	
		; continue to PSB_TitleMenu...
; ---------------------------------------------------------------------------

PSB_TitleMenu:
		move.b	obSubtype(a0),d3			; get total entry count (3 by default)
		move.b	(v_jpadpress1).w,d1			; get buttons pressed this frame
		move.b	obFrame(a0),d2				; get current menu selection

	.checkUp:
		btst	#bitUp,d1				; was UP button pressed?
		beq.s	.checkDown				; if not, branch
		subq.b	#1,d2					; go one selection up
		bpl.s	.checkDown				; has selection gone negative? if not, branch
		move.b	d3,d2					; reset selection to last entry...
		subq.b	#1,d2					; ...0-based

	.checkDown:
		btst	#bitDn,d1				; was DOWN button pressed?
		beq.s	.updateSelection			; if not, branch
		addq.b	#1,d2					; go one selection down
		cmp.b	d3,d2					; has selection exceeded entry count?
		blo.s	.updateSelection			; if not, branch
		moveq	#0,d2					; reset selection to first entry

	.updateSelection:
		cmp.b	obFrame(a0),d2				; has selection changed?
		beq.s	.display				; if not, do nothing

		move.b	d2,obFrame(a0)				; update selection
		move.b	#sfx_Switch,d0				; set switch sound
		jsr	(QueueSound2).l				; play sound when selection has changed
	
	.display:
		DisplaySprite
		rts				; display new selection
; End of function PSB_TitleMenu

; ===========================================================================

; Note: Each text must be EXACTLY 16 characters including spaces!
TitleMenu_Entries:
		; Selection 0
		dc.l	PlayLevel
		dc.b	"START GAME      "

		; Selection 1
		dc.l	Tit_EnterLevelSelect
		dc.b	"LEVEL SELECT    "

		; Selection 2
		dc.l	End_GoToCredits
		dc.b	"CREDITS         "

		; End of list marker
		dc.b	-1
		even

; ---------------------------------------------------------------------------
; Subroutine to handle title screen menu selection when START was pressed
; (Called from Tit_ChkLevSel)
; ---------------------------------------------------------------------------

TitleMenu_SelectionMade:
		moveq	#0,d0					; clear d0
		move.b	(v_pressstart+obFrame).w,d0		; get current title menu selection
		mulu.w	#4+16,d0				; multiply by 20 bytes per entry
		movea.l	TitleMenu_Entries(pc,d0.w),a1		; load destination address for selection
		jmp	(a1)					; jump there
; End of function TitleMenu_SelectionMade

; ---------------------------------------------------------------------------
; Subroutine to load title menu text graphics into reserved VRAM space
; (Called from GM_Title)
; ---------------------------------------------------------------------------

TitleMenu_LoadTextGraphics:
		locVRAM	ArtTile_Title_Menu*tile_size		; set target VRAM location
		lea	(vdp_data_port).l,a6			; load VDP data port
		lea	(Art_Text).l,a2				; load menu font

		movea.l	a2,a3					; copy menu font pointer
		adda.w	#$0D*tile_size,a3			; advance to -> symbol (tile $0D in Art_Text)
		rept 8						; eight rows per tile
		move.l	(a3)+,(a6)				; write arrow graphics to VRAM
		endr						; assembler repeat

		lea	(TitleMenu_Entries).l,a1		; load options settings array
		clr.b	(v_pressstart+obSubtype).w		; reset number of entries
.nextEntry:
		tst.b	(a1)					; has end of list been reached? (-1)
		bmi.s	.return					; if yes, exit loop
		addq.b	#1,(v_pressstart+obSubtype).w		; increase number of entries
		addq.w	#4,a1					; skip destination address
		moveq	#16-1,d2				; write 16 chars
	.loopEntry:
		moveq	#0,d0					; clear d0
		move.b	(a1)+,d0				; get next ASCII character from array
		cmpi.b	#' ',d0					; is it a space character?
		beq.s	.space					; if yes, treat it separately

		moveq	#'0',d1					; base character offset for numbers
		cmpi.b	#'Y',d0					; is current character a Y or Z?
		blo.s	.go					; if not, branch
		addi.b	#$1A,d1					; further adjustment for Y and Z (before other letters)
	.go:	sub.b	d1,d0					; offset ASCII letter to actual font index
		lsl.w	#5,d0					; multiply offset by $20 (tile_size)
		movea.l	a2,a3					; reset menu font
		adda.w	d0,a3					; advance to graphics for current character
		rept 8						; eight rows per tile
		move.l	(a3)+,(a6)				; write letter graphics to VRAM
		endr						; assembler repeat
		bra.s	.nextChar				; loop for all characters
	.space:
		moveq	#0,d0					; write blank for space characters
		rept 8						; eight rows per tile
		move.l	d0,(a6)					; write blank data to VRAM
		endr						; assembler repeat
	.nextChar:
		dbf	d2,.loopEntry				; loop for all 16 characters in array
		bra.s	.nextEntry				; if current entry is done, write next one

	.return:
		rts						; we're done here
; End of function TitleMenu_LoadTextGraphics

; ===========================================================================

		include	"_anim/Title Screen Sonic.asm"
		include	"_anim/Press Start and TM.asm"
Map_PSB:	include	"_maps/Press Start and TM.asm"
Map_TSon:	include	"_maps/Title Screen Sonic.asm"
Map_PSBMenu:	include	"_maps/Title Screen Menu.asm"
