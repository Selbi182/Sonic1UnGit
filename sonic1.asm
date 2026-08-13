;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto
; ---------------------------------------------------------------------------
; NOTE:
; Set your editor's tab width to 8 characters wide for viewing this file.

; ===========================================================================

; ===========================================================================
; Equates section - Names for constants. Needs to be included before flags.
	include	"_Constants.asm"

; ===========================================================================
; ASSEMBLY OPTIONS:

; Features:
Enable_SpindashPeelout:	= 1
Enable_HomingAttack:	= 1
Enable_Figure8Sprites:	= 1
Enable_ExtendedCamera:	= 1
Enable_InfiniteLives:	= 1
Enable_AttractRings:	= 1
Enable_6ButtonControl:	= 0

; Developer flags:
OneHitBosses: = 1
;	| If 1, all bosses will only take a single hit to defeat

LagOMeter: = 0
;	| If 1, displays a Lag-o-Meter at the top-right of the screen

BootToLevel: = -1
;	| If set, will boot straight to a specified level (e.g. id_GHZ_act1)
;	|         (set to -1 for booting to Sega Screen normally)

CheatsEnabled: = 3
;	| If 1, all in-game cheats (Level Select, Debug Mode, Slow-Motion, Japanese Credits)
;	|       will be enabled by default, without requiring any title screen button inputs
;	| If 2, same as 1 but debug mode doesn't need to have A held down to get activated
;	| If 3, same as 2 but debug mode will NOT prevent death when getting hit with no rings

; ===========================================================================
; Simplifying macros and functions
	include	"Macros.asm"
	include "sound/MegaPCM.Macros.asm"

; ===========================================================================
; Equates section - Names for variables
	include	"_Variables.asm"

; ===========================================================================
; MD Debugger and Error Handler macros
	include	"_inc/Debugger.asm"

;__DEBUG__: equ "DEB"
; 	| Comment this in to enable extra debugging tools ("KDebug" and "assert").
; 	| If commented out, extra tools are disabled to avoid performance penalties.

; ===========================================================================
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer = 1
SonicDplcVer = 1
	include	"_maps/_MapMacros.asm"

; ===========================================================================
; start of ROM

StartOfRom:
	if * <> 0
		fatal "StartOfRom was $\{*} but it should be 0"
	endif

Vectors:
		dc.l v_systemstack&$FFFFFF			; Initial stack pointer value
		dc.l EntryPoint					; Start of program
		dc.l BusError					; Bus error
		dc.l AddressError				; Address error (4)
		dc.l IllegalInstr				; Illegal instruction
		dc.l ZeroDivide					; Division by zero
		dc.l ChkInstr					; CHK exception
		dc.l TrapvInstr					; TRAPV exception (8)
		dc.l PrivilegeViol				; Privilege violation
		dc.l Trace					; TRACE exception
		dc.l Line1010Emu				; Line-A emulator
		dc.l Line1111Emu				; Line-F emulator (12)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (16)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (20)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved)
		dc.l ErrorExcept				; Unused (reserved) (24)
		dc.l ErrorExcept				; Spurious exception
		dc.l ErrorTrap					; IRQ level 1
		dc.l ErrorTrap					; IRQ level 2
		dc.l ErrorTrap					; IRQ level 3 (28)
		dc.l HBlank					; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap					; IRQ level 5
		dc.l VBlank					; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap					; IRQ level 7 (32)
		dc.l ErrorTrap					; TRAP #00 exception
		dc.l ErrorTrap					; TRAP #01 exception
		dc.l ErrorTrap					; TRAP #02 exception
		dc.l ErrorTrap					; TRAP #03 exception (36)
		dc.l ErrorTrap					; TRAP #04 exception
		dc.l ErrorTrap					; TRAP #05 exception
		dc.l ErrorTrap					; TRAP #06 exception
		dc.l ErrorTrap					; TRAP #07 exception (40)
		dc.l ErrorTrap					; TRAP #08 exception
		dc.l ErrorTrap					; TRAP #09 exception
		dc.l ErrorTrap					; TRAP #10 exception
		dc.l ErrorTrap					; TRAP #11 exception (44)
		dc.l ErrorTrap					; TRAP #12 exception
		dc.l ErrorTrap					; TRAP #13 exception
		dc.l ErrorTrap					; TRAP #14 exception
		dc.l ErrorTrap					; TRAP #15 exception (48)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)
		dc.l ErrorTrap					; Unused (reserved)

		dc.b "SEGA MEGA DRIVE "				; Hardware system ID (Console name)
		dc.b "(C)SEGA 1991.APR"				; Copyright holder and release date (generally year)
	rept 2
		 ; Name (identical for domestic and overseas version)
		dc.b "SONIC THE               HEDGEHOG                "
	endr

		dc.b "GM 00004049-01"				; Serial/version number (Rev non-0)

Checksum:	dc.w $AFC7

		dc.b "J               "				; I/O support
		dc.l StartOfRom					; Start address of ROM
RomEndLoc:	dc.l EndOfRom-1					; End address of ROM
		dc.l $FF0000					; Start address of RAM
		dc.l $FFFFFF					; End address of RAM

		dc.b "    "					; SRAM support
		dc.b "    "					; SRAM start
		dc.b "    "					; SRAM end

		dc.b "                                                    " ; Notes
		dc.b "JUE             "				; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too
ErrorTrap:
		nop						; no operation
		nop						; ''
		bra.s	ErrorTrap				; loop forever
; ===========================================================================

; ---------------------------------------------------------------------------
; Entry point for the game on boot or soft-reset
; (This section from a standard Mega Drive devkit library)
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	(port_1_control_hi).l			; test port A & B control registers
		bne.s	PortA_Ok				; if either of them are already initialized, branch
		tst.w	(expansion_control_hi).l		; test port C control register
PortA_Ok:	bne.s	SkipSetup				; if any port was already initialized, skip the VDP and Z80 setup code (this is a soft-reset)

		lea	SetupValues(pc),a5			; load setup values array address
		movem.w	(a5)+,d5-d7				; d5 = VDP register start number; d6 = size of RAM/4; d7 = VDP register diff
		movem.l	(a5)+,a0-a4				; a0 = start of Z80 RAM; a1 = Z80 bus request; a2 = Z80 reset; a3 = VDP data; a4 = VDP control

		move.b	-$10FF(a1),d0				; get hardware version (from $A10001)
		andi.b	#$F,d0					; only look at Mega Drive version
		beq.s	SkipSecurity				; if the console has no TMSS, skip the security stuff
		move.l	#'SEGA',$2F00(a1)			; write "SEGA" to TMSS security register ($A14000)

SkipSecurity:
		move.w	(a4),d0					; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		moveq	#0,d0					; clear d0
		movea.l	d0,a6					; clear a6
		move.l	a6,usp					; set usp to $0

		moveq	#SetupValues_VDP_End-SetupValues_VDP-1,d1 ; write to all VDP registers
VDPInitLoop:	move.b	(a5)+,d5				; add $8000 to value
		move.w	d5,(a4)					; write value to VDP register
		add.w	d7,d5					; next register
		dbf	d1,VDPInitLoop				; loop until all registers are set up

		move.l	(a5)+,(a4)				; write DMA destination to VDP (VRAM 0000)
		move.w	d0,(a3)					; set DMA fill value to 00 (DMA starts here, clears entire VRAM)

		move.w	d7,(a1)					; stop the Z80
		move.w	d7,(a2)					; reset the Z80
WaitForZ80:	btst	d0,(a1)					; has the Z80 stopped?
		bne.s	WaitForZ80				; if not, loop until it has

		moveq	#SetupValues_Z80_End-SetupValues_Z80-1,d2 ; write all Z80 boot code
Z80InitLoop:	move.b	(a5)+,(a0)+				; write boot code to Z80 RAM
		dbf	d2,Z80InitLoop				; loop until all boot code has been written

		move.w	d0,(a2)					; set Z80 reset on
		move.w	d0,(a1)					; set Z80 stop off
		move.w	d7,(a2)					; set Z80 reset off

ClrRAMLoop:	move.l	d0,-(a6)				; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop				; repeat until the entire RAM is cleared

		move.l	(a5)+,(a4)				; set VDP display mode and increment mode

		move.l	(a5)+,(a4)				; set VDP to CRAM write
		moveq	#(v_palette_end-v_palette)/4-1,d3	; set repeat times to cover full CRAM
ClrCRAMLoop:	move.l	d0,(a3)					; clear 2 colors
		dbf	d3,ClrCRAMLoop				; repeat until the entire CRAM is clear

		move.l	(a5)+,(a4)				; set VDP to VSRAM write
		moveq	#$14-1,d4
ClrVSRAMLoop:	move.l	d0,(a3)					; clear 4 bytes of VSRAM
		dbf	d4,ClrVSRAMLoop				; repeat until the entire VSRAM is clear

		moveq	#SetupValues_PSG_End-SetupValues_PSG-1,d5 ; write to all PSG registers
PSGInitLoop:	move.b	(a5)+,$11(a3)				; write PSG volume values to PSG port ($C00011)
		dbf	d5,PSGInitLoop				; repeat for all channels

		move.w	d0,(a2)					; set Z80 reset on
		movem.l	(a6),d0-a6				; clear all registers
		disable_ints					; disable interrupts

SkipSetup:
		bra.s	GameProgram				; begin actual game
; ===========================================================================

SetupValues:	dc.w $8000					; VDP register start number
		dc.w (v_ram_end-v_ram_start_def/4)-1		; size of RAM/4 ($3FFF)
		dc.w $100					; VDP register diff

		dc.l z80_ram					; start of Z80 RAM
		dc.l z80_bus_request				; Z80 bus request
		dc.l z80_reset					; Z80 reset
		dc.l vdp_data_port				; VDP data
		dc.l vdp_control_port				; VDP control

	SetupValues_VDP:
		; Note that most of these are immediately overwritten again in VDPSetupArray
		dc.b 4						; VDP $80 - 8-colour mode
		dc.b $14					; VDP $81 - Mega Drive mode, DMA enable
		dc.b ($C000>>10)				; VDP $82 - foreground nametable address
		dc.b ($F000>>10)				; VDP $83 - window nametable address
		dc.b ($E000>>13)				; VDP $84 - background nametable address
		dc.b ($D800>>9)					; VDP $85 - sprite table address
		dc.b 0						; VDP $86 - unused
		dc.b 0						; VDP $87 - background colour
		dc.b 0						; VDP $88 - unused
		dc.b 0						; VDP $89 - unused
		dc.b 255					; VDP $8A - HBlank register
		dc.b 0						; VDP $8B - full screen scroll
		dc.b $81					; VDP $8C - 40 cell display
		dc.b ($DC00>>10)				; VDP $8D - h-scroll table address
		dc.b 0						; VDP $8E - unused
		dc.b 1						; VDP $8F - VDP increment
		dc.b 1						; VDP $90 - 64 cell h-scroll size
		dc.b 0						; VDP $91 - window h position
		dc.b 0						; VDP $92 - window v position
		dc.w $FFFF					; VDP $93/94 - DMA length
		dc.w $0000					; VDP $95/96 - DMA source
		dc.b $80					; VDP $97 - DMA fill VRAM
	SetupValues_VDP_End:
		dc.l $40000080					; DMA fill destination (VRAM 0000)

	SetupValues_Z80:
		; Z80 instructions (not the sound driver; that gets loaded later)
		dc.b $AF					; xor	a
		dc.b $01, $D9, $1F				; ld	bc,1fd9h
		dc.b $11, $27, $00				; ld	de,0027h
		dc.b $21, $26, $00				; ld	hl,0026h
		dc.b $F9					; ld	sp,hl
		dc.b $77					; ld	(hl),a
		dc.b $ED, $B0					; ldir
		dc.b $DD, $E1					; pop	ix
		dc.b $FD, $E1					; pop	iy
		dc.b $ED, $47					; ld	i,a
		dc.b $ED, $4F					; ld	r,a
		dc.b $D1					; pop	de
		dc.b $E1					; pop	hl
		dc.b $F1					; pop	af
		dc.b $08					; ex	af,af'
		dc.b $D9					; exx
		dc.b $C1					; pop	bc
		dc.b $D1					; pop	de
		dc.b $E1					; pop	hl
		dc.b $F1					; pop	af
		dc.b $F9					; ld	sp,hl
		dc.b $F3					; di
		dc.b $ED, $56					; im1
		dc.b $36, $E9					; ld	(hl),e9h
		dc.b $E9					; jp	(hl)
	SetupValues_Z80_End:

		dc.w $8104					; VDP display mode
		dc.w $8F02					; VDP increment
		dc.l $C0000000					; CRAM write mode
		dc.l $40000010					; VSRAM address 0

	SetupValues_PSG:
		dc.b $9F, $BF, $DF, $FF				; values for PSG channel volumes
	SetupValues_PSG_End:
; End of SetupValues


; ===========================================================================
; ---------------------------------------------------------------------------
; Proper game entry point for Sonic the Hedgehog after initialization
; ---------------------------------------------------------------------------

GameProgram:
		tst.w	(vdp_control_port).l			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		btst	#6,(expansion_control).l		; has port C been initialized?
		beq.s	CheckSumOk				; if not, branch
		cmpi.l	#'init',(v_init).w			; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumOk:
		lea	(v_crossresetram).w,a6			; load cross-reset RAM location
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_ram_end-v_crossresetram)/4-1,d6	; write to all of cross-reset RAM ($FE00-$FFFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		move.b	(console_version).l,d0			; get hardware information from console
		andi.b	#%11000000,d0				; filter to only overseas flag and PAL flag
		move.b	d0,(v_megadrive).w			; store region settings

		btst	#6,(v_megadrive).w			; is Mega Drive PAL?
		sne.b	(v_pal).w				; remember flag if so

		move.l	#'init',(v_init).w			; set flag so checksum won't run again

GameInit:
		lea	(v_ram_start).l,a6			; load start location of RAM
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_crossresetram-v_ram_start_def)/4-1,d6 ; write to all of RAM except cross-reset RAM ($0000-$FDFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		jsr	(InitDMAQueue).l
		bsr.w	VDPSetupGame				; initialize (proper) VDP registers
		bsr.w	JoypadInit				; initialize controller ports
		move.b	#id_Sega,(v_gamemode).w			; set first Game Mode to Sega Screen

	if CheatsEnabled>0
		moveq	#1,d0					; enable all cheats by default
		move.b	d0,(f_levselcheat).w			; enable level select cheat
		move.b	d0,(f_slomocheat).w			; enable slow-motion cheat
		move.b	d0,(f_debugcheat).w			; enable debug mode cheat
		move.b	d0,(f_creditscheat).w			; enable hidden Japanese credits cheat
	endif

		jsr	(MegaPCM_LoadDriver).l
		lea	(SampleTable).l,a0
		jsr	(MegaPCM_LoadSampleTable).l
		tst.w	d0			; was sample table loaded successfully?
		beq.s	.SampleTableOk		; if yes, branch
		if def(__DEBUG__)
			; for MD Debugger v.2.5 or above
			RaiseError "MegaPCM_LoadSampleTable returned %<.b d0>", MPCM_Debugger_LoadSampleTableException
		else
			illegal
		endif
.SampleTableOk:

	if (BootToLevel>=0)
		move.b	#id_Level,(v_gamemode).w
		move.w	#BootToLevel,(v_zone_act).w
		enable_display
	endif

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$3C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

gmptr:		macro *,gamemode
\*:	equ	(*-GameModeArray)
		bra.w	gamemode
		endm

id_Sega:	gmptr	GM_Sega					; Sega Screen ($00)
id_Title:	gmptr	GM_Title				; Title Screen ($04)
id_Demo:	gmptr	GM_Level				; Demo Mode ($08) (deleted)
id_Level:	gmptr	GM_Level				; Normal Level ($0C)
id_Special:	gmptr	GM_Special				; Special Stage ($10)
id_Continue:	gmptr	GM_Continue				; Continue Screen ($14)
id_Ending:	gmptr	GM_Ending				; End of game sequence ($18)
id_Credits:	gmptr	GM_Credits				; Credits ($1C)


; ===========================================================================
; ---------------------------------------------------------------------------
; Uncompressed art text for debug mode, level select, and errors
; (formerly "menutext.bin")
; ---------------------------------------------------------------------------

Art_Text:	bincludeEndMarker	"artunc/Level Select & Debug Text.unc"
		dc.w	0

; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------
id_VBlank_Lag:		equ $00					; (lag frame)
id_VBlank_Sega:		equ $02					; Sega Screen
id_VBlank_Title:	equ $04					; Title Screen, Credits
id_VBlank_Unused06:	equ $06					; (unused)
id_VBlank_Levels:	equ $08					; Levels
id_VBlank_SpecialStage:	equ $0A					; Special Stages
id_VBlank_TitleCards:	equ $0C					; Title Cards
id_VBlank_Unused0E:	equ $0E					; (unused)
id_VBlank_Paused:	equ $10					; Paused
id_VBlank_PaletteFade:	equ $12					; Palette Fade
id_VBlank_SegaPCM:	equ $14					; Sega Screen PCM
id_VBlank_Continue:	equ $16					; Continue Screen
id_VBlank_Ending:	equ $18					; Ending Sequence
; ---------------------------------------------------------------------------

; loc_B10: VBla:
VBlank:
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)

		tst.b	(v_vblank_routine).w			; was a VBlank routine set?
		beq.s	VBlank_Lag				; if not, this is a lag frame, branch

		move.w	(vdp_control_port).l,d0			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		move.l	#$40000010,(vdp_control_port).l		; set VDP to VSRAM write mode
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l	; send screen y-axis pos. to VSRAM

		; Wait here in a loop doing nothing for a while. This seems to be a pretty harsh attempt
		; to push CRAM dots outside of the visible view area, due to Sonic 1 not using all
		; the available screen space PAL offers, as they would otherwise be seen at the bottom.
		tst.b	(v_pal).w			; is Mega Drive PAL?
		beq.s	.notPAL					; if not, branch
		move.w	#$700,d0				; set to waste a bunch of cycles
	.waitPAL:
		dbf	d0,.waitPAL				; loop until cycles have been wasted

.notPAL:
		move.b	(v_vblank_routine).w,d0			; copy specified VBlank routine to d0
		move.b	#id_VBlank_Lag,(v_vblank_routine).w	; reset actual routine to lag frame (which ideally should get set again in the next frame)
		move.w	#1,(f_hblank_pal).w			; set HBlank palette swap flag (only relevant for LZ)
		andi.w	#$3E,d0					; mask out irrelevant bits in VBlank routine
		move.w	VBlank_Index(pc,d0.w),d0		; load address to relevant VBlank routine
		jsr	VBlank_Index(pc,d0.w)			; jump to VBlank routine and then return here

VBlank_Music:
		jsr	(UpdateMusic).l				; run sound driver to advance music

VBlank_Exit:
		addq.l	#1,(v_vblank_count).w			; increment VBlank counter
		movem.l	(sp)+,d0-a6				; restore all backed-up registers
		rte						; return from interrupt and resume normal operation

; ===========================================================================
; VBla_Index:
VBlank_Index:	dc.w VBlank_Lag-VBlank_Index			; $00 - (lag frame)
		dc.w VBlank_Sega-VBlank_Index			; $02 - Sega Screen
		dc.w VBlank_Title-VBlank_Index			; $04 - Title Screen, Credits, Try Again
		dc.w VBlank_Unused06-VBlank_Index		; $06 - (unused)
		dc.w VBlank_Levels-VBlank_Index			; $08 - Levels
		dc.w VBlank_SpecialStage-VBlank_Index		; $0A - Special Stages
		dc.w VBlank_TitleCards-VBlank_Index		; $0C - Title Cards
		dc.w VBlank_Unused0E-VBlank_Index		; $0E - (unused)
		dc.w VBlank_Paused-VBlank_Index			; $10 - Paused
		dc.w VBlank_PaletteFade-VBlank_Index		; $12 - Palette Fade
		dc.w VBlank_SegaPCM-VBlank_Index		; $14 - Sega Screen PCM
		dc.w VBlank_Continue-VBlank_Index		; $16 - Continue Screen, SS Finish
		dc.w VBlank_Ending-VBlank_Index			; $18 - Ending Sequence
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 00 - Lag frame (VBlank occurred before call to WaitForVBlank)
; ---------------------------------------------------------------------------

; loc_B88: VBla_00:
VBlank_Lag:
		cmpi.b	#$80+id_Level,(v_gamemode).w		; is pre level sequence active?
		beq.s	.isLevel				; if not, just update sound driver and resume operation
		cmpi.b	#id_Level,(v_gamemode).w		; is game on a level?
		bne.w	VBlank_Music				; if not, just update sound driver and resume operation

.isLevel:
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.w	VBlank_Music				; if not, just update sound driver and resume operation

		; --- A lag frame has occurred while in Labyrinth Zone ---

		move.w	(vdp_control_port).l,d0			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)

		; Same as in the opening block of the VBlank routine, this time during a lag frame.
		; This only happens if the level is LZ (note, Sonic 2/3/&K would change this so it runs in any level).
		tst.b	(v_pal).w			; is Mega Drive PAL?
		beq.s	.paletteTransfer			; if not, branch
		move.w	#$700,d0				; set to waste a bunch of cycles
	.waitPAL:
		dbf	d0,.waitPAL				; loop until cycles have been wasted

.paletteTransfer:
		move.w	#1,(f_hblank_pal).w			; set HBlank flag
		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)
		bra.w	VBlank_Music				; branch back to update sound driver and resume operation

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 02 - Sega Screen
; ---------------------------------------------------------------------------

; loc_C32: VBla_02:
VBlank_Sega:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		; fall-through...

; ---------------------------------------------------------------------------
; VBlank 14 - Sega Screen while the PCM sample is playing
; ---------------------------------------------------------------------------

; loc_C36: VBla_14:
VBlank_SegaPCM:
		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 04 - Title Screen, Level Select, Credits, "Try Again" screen
; ---------------------------------------------------------------------------

; loc_C44: VBla_04:
VBlank_Title:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		bsr.w	LoadTilesAsYouMove_BGOnly		; update background tiles as title screen scrolls

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 06 - Unused and unknown purpose
; ---------------------------------------------------------------------------

; loc_C5E: VBla_06:
VBlank_Unused06:
		bra.w	VBlank_StandardTransfers		; do standard screen transfers and nothing else

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 10 - While game is paused
; ---------------------------------------------------------------------------

; loc_C64: VBla_10:
VBlank_Paused:
		cmpi.b	#id_Special,(v_gamemode).w		; is game on special stage?
		beq.w	VBlank_SpecialStage			; if yes, branch
		; fall-through...

; ---------------------------------------------------------------------------
; VBlank 08 - Levels
; ---------------------------------------------------------------------------

; loc_C6E: VBla_08:
VBlank_Levels:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:

		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		jsr	ProcessDMAQueue(pc)

		movem.l	(v_screenposx).w,d0-d7			; copy everything from v_screenposx to v_bg3screenposy...
		movem.l	d0-d7,(v_screenposx_dup).w		; ...to backup RAM (used in LoadTilesAsYouMove)
		movem.l	(v_fg_scroll_flags).w,d0-d1		; copy FG and BG scroll flags...
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w		; ...to backup RAM

		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)
		move.w	d0,(a5)			; write to VDP register ($8Axx)

		; The following code handles an awkward visual glitch for the LZ water surface.
		; If the surface is near the top of the screen (within 96 pixels), the VDP would not have
		; enough time to do all the transfers in VBlank_UpdateScreen before the palette needs to get
		; changed for the water. Without this special check, the water surface would violently flicker
		; whenever it's near the top of the screen. It's a rather dirty workaround, but it works.
		cmpi.b	#96,(v_hblank_line).w			; is LZ water surface within 96 pixels of the top of the screen?
		bhs.s	VBlank_UpdateScreen			; if not, do screen updates now
		move.b	#1,(f_doupdatesinhblank).w		; otherwise, we don't have enough time to do them now before HBlank hits, defer updates to then
		addq.l	#4,sp					; skip return address (i.e. postpone updating the sound driver as well)
		bra.w	VBlank_Exit				; go straight back to to the VBlank exit

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to update various screen elements during interrupts.
; Also deducts the generic timer that controls the length of a Demo.
; ---------------------------------------------------------------------------

; Demo_Time: VBla_UpdateScreen:
VBlank_UpdateScreen:
		bsr.w	LoadTilesAsYouMove			; update level tiles while screen is moving
		jsr	(AnimateLevelGfx).l			; updated animated tiles
		jsr	(HUD_Update).l				; update HUD data

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return
; End of function VBlank_UpdateScreen

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0A - Special Stages
; ---------------------------------------------------------------------------

; loc_DA6: VBla_0A:
VBlank_SpecialStage:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)

		bsr.w	PalCycle_SS				; advance special stage palette cycle and animate bird/fish graphics

		jsr	(SS_LoadWalls).l			; update graphics for square blocks in VRAM

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0C - While title cards are displayed (Levels and SS Results)
; VBlank 18 - During the Ending Sequence
; ---------------------------------------------------------------------------

; loc_E72: VBla_0C: VBla_18:
VBlank_TitleCards:
VBlank_Ending:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)

		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		jsr	ProcessDMAQueue(pc)

		movem.l	(v_screenposx).w,d0-d7			; copy everything from v_screenposx to v_bg3screenposy...
		movem.l	d0-d7,(v_screenposx_dup).w		; ...to backup RAM (used in LoadTilesAsYouMove)
		movem.l	(v_fg_scroll_flags).w,d0-d1		; copy FG and BG scroll flags...
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w		; ...to backup RAM

		bsr.w	LoadTilesAsYouMove			; update rendered
		jsr	(AnimateLevelGfx).l			; animate uncompressed level graphics (e.g. MZ lava)
		jmp	(HUD_Update).l				; update HUD numbers

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 0E - Unused (possibly once used as a lag frame counter?)
; ---------------------------------------------------------------------------

; loc_F8A: VBla_0E:
VBlank_Unused0E:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		addq.b	#1,(v_vblank_0e_counter).w		; increment some counter (unused besides this one write...)
		move.b	#id_VBlank_Unused0E,(v_vblank_routine).w ; set itself to land back here again if not further altered
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 12 - During palette fades
; ---------------------------------------------------------------------------

; loc_F9A: VBla_12:
VBlank_PaletteFade:
		bsr.w	VBlank_StandardTransfers		; do standard screen transfers
		move.w	(v_hblank_hreg).w,d0	; get HBlank interrupt counter
		move.w	d0,(a5)			; write to VDP register ($8Axx)
		move.b	d0,(v_waterline).w	; copy target scan line ($xx)
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; VBlank 16 - Continue Screen and Special Stage finish loop
; ---------------------------------------------------------------------------

; loc_FA6: VBla_16:
VBlank_Continue:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)

		jsr	(SS_LoadWalls).l			; update graphics for square blocks in VRAM

		tst.w	(v_generictimer).w			; is generic timer set?
		beq.w	.end					; if not, branch
		subq.w	#1,(v_generictimer).w			; decrement generic timer
	.end:
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to perform standard VRAM transfers (palette, sprites, H-scroll)
; ---------------------------------------------------------------------------

; sub_106E:
VBlank_StandardTransfers:
		bsr.w	ReadJoypads				; read joypads and update buffered inputs in RAM

		tst.b	(f_wtr_state).w				; is the screen completely underwater?
		bne.s	.waterAbove 				; if not, branch
		writeCRAM	v_palette,0			; write regular palette buffer to CRAM
		bra.s	.waterBelow				; skip over
	.waterAbove:
		writeCRAM	v_palette_water,0		; write water palette buffer to CRAM
	.waterBelow:

		writeVRAM	v_spritetablebuffer,vram_sprites  ; transfer sprite buffer table to actual sprites VRAM
		writeVRAM	v_hscrolltablebuffer,vram_hscroll ; transfer H-scroll buffer table to actual H-scroll VRAM
		jsr	ProcessDMAQueue(pc)

		rts						; return
; End of function VBlank_StandardTransfers
; End of VBlank (as a whole)


; ===========================================================================
; ---------------------------------------------------------------------------
; Horizontal interrupt (exclusively used for the LZ water palette effect)
; ---------------------------------------------------------------------------

; PalToCRAM: <-- old misnomer
HBlank:
		tst.w	(f_hblank_pal).w			; is palette set to change?
		beq.w	.nochg					; if not, branch
		move.w	#0,(f_hblank_pal).w			; clear palette change flag

		movem.l	d0-d2/a0-a2,-(sp)			; backup registers

		lea	(vdp_data_port).l,a1			; load VDP data port to a1
		move.w	#$8A00+223,4(a1)			; reset horizontal interrupt counter

		lea	HBlank_LZWater(pc),a2			; get water transition LUT
		move.w	#(HBlank_LZWater_End-HBlank_LZWater)/2-1,d1 ; get number of entries in list
		move.b	(v_waterline).w,d0			; get scanline that was written to
		subi.b	#200,d0					; is H-int occurring below line 200?
		bcs.s	.transferColors				; if it is, branch
		sub.b	d0,d1					; skip relevant number of entries in LUT
		bcs.s	.skipTransfer				; if everything was skipped, branch

	.transferColors:
		moveq	#0,d0					; clear d0
		move.w	(a2)+,d0				; get palette offset from LUT
		lea	(v_palette_water).w,a0			; get buffered water palette
		adda.w	d0,a0					; go to specified entry in palette buffer
		addi.w	#$C000,d0				; prepare CRAM write
		swap	d0					; move to upper word
		move.l	d0,4(a1)				; write to CRAM at appropriate address

		swap	d1					; high word of D1 is used for buffering
		move.l	(a0)+,d2				; buffer colors to registers for faster transfer
		move.w	(a0)+,d1				; ''

		move.b	#320/2,d0				; trigger transfer once H-Counter has gone offscreen to the right
	.waitH:	cmp.b	vdp_Hcounter-vdp_data_port(a1),d0	; read H-Counter, has it gone offscreen?
		bhi.s	.waitH					; if not, loop until it has

		move.l	d2,(a1)					; transfer two colors
		move.w	d1,(a1)					; transfer the third color
		swap	d1					; use d1 as counter again
		dbf	d1,.transferColors			; repeat for number of colors
; ---------------------------------------------------------------------------

.skipTransfer:
		movem.l	(sp)+,d0-d2/a0-a2			; restore registers

		tst.b	(f_doupdatesinhblank).w			; was frame update delayed by water surface being near the top of the screen?
		bne.s	.delayed_transfer			; if yes, resume transfer now

	.nochg:
		rte						; return from horizontal interrupt and resume normal operation
; ===========================================================================

; loc_119E:
.delayed_transfer:
		clr.b	(f_doupdatesinhblank).w			; clear delayed updates flag
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)
		bsr.w	VBlank_UpdateScreen			; do all the screen updates that were skipped during VBlank now
		jsr	(UpdateMusic).l				; update the sound driver
		movem.l	(sp)+,d0-a6				; restore registers
		rte						; return from horizontal interrupt and resume normal operation
; End of function HBlank

; ---------------------------------------------------------------------------

HBlank_LZWater:
		dc.w $62	; line 4, color 1-2-3
		dc.w $68	; line 4, color 4-5-6
		dc.w $7A	; line 4, color D-E-F
		dc.w $6E	; line 4, color 7-8-9
		dc.w $74	; line 4, color A-B-C

		dc.w $42	; line 3, color 1-2-3
		dc.w $48	; line 3, color 4-5-6
		dc.w $4E	; line 3, color 7-8-9
		dc.w $54	; line 3, color A-B-C
		dc.w $5A	; line 3, color D-E-F

		dc.w $02	; line 1, color 1-2-3
		dc.w $08	; line 1, color 4-5-6
		dc.w $0E	; line 1, color 7-8-9
		dc.w $14	; line 1, color A-B-C
		dc.w $1A	; line 1, color D-E-F

		dc.w $34	; line 2, color A-B-C
		dc.w $22	; line 2, color 1-2-3
		dc.w $3A	; line 2, color D-E-F
		dc.w $2E	; line 2, color 7-8-9
		dc.w $28	; line 2, color 4-5-6
HBlank_LZWater_End:


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to initialize joypads and check if either port is using
; a 6-button controller. MSB is set in v_jpadhold_6btn/v_jpadhold_6btn_p2
; if one has been detected.
; For reference, see: https://www.plutiedev.com/controllers#6-button
; ---------------------------------------------------------------------------

; Small helper macro that toggles the TH line and adds the required delay
; so the controller can output the correct button states. Defined as a macro
; to avoid repeating the same move/nop sequence over and over.
PollTH	macro	hiPoll
		if hiPoll>0
			move.b	#$40,(a1)		; read D-Pad, B, and C input (hi poll)
		else
			move.b	#0,(a1)			; read A and Start input (lo poll)
		endif
		nop					; wait a bit after polling
		nop					; (bus synchronization)
	endm

; ---------------------------------------------------------------------------

JoypadInit:
		moveq	#$40,d0				; set TH high
		move.b	d0,(port_1_control).l		; init port 1 (joypad 1)
		move.b	d0,(port_2_control).l		; init port 2 (joypad 2)
		move.b	d0,(expansion_control).l	; init port 3 (expansion/extra)

		lea	(port_1_data).l,a1		; load address to read controller 1 data
		bsr.s	.check6btn			; check whether it's a 6-button controller
		sne.b	(v_jpadhold_6btn).w		; set P1 to 6-button controller flag if it is

		lea	(port_2_data).l,a1		; load address to read controller 2 data
		bsr.s	.check6btn			; check whether it's a 6-button controller
		sne.b	(v_jpadhold_6btn_p2).w		; set P2 to 6-button controller flag if it is
		rts					; return
; ---------------------------------------------------------------------------

.check6btn:
		PollTH	1				; 1st TH poll (hi)
		PollTH	0				; 2nd TH poll (lo)
		PollTH	1				; 3rd TH poll (hi)
		PollTH	0				; 4th TH poll (lo)
		PollTH	1				; 5th TH poll (hi)
		PollTH	0				; 6th TH poll (lo)
		cmpi.b	#%00110011,(a1)			; check if 6th TH poll returned 3-button controller data
		rts					; CCR check is done after the return
; End of function JoypadInit

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to read joypad input for P1 and P2 controllers and write to RAM.
; Extended to support 6-button controllers for both controller ports.
; ---------------------------------------------------------------------------

ReadJoypads:
		lea	(port_1_data).l,a1		; set to read first joypad port
		lea	(v_jpadhold1).w,a0		; address where P1 joypad states are written to
	if Enable_6ButtonControl
		bsr.s	.read_3btn			; read standard 3-button inputs for P1
		tst.b	(a0)				; is P1 using a 6-button controller?
		bpl.s	.readP2				; if not, branch
		bsr.s	.read_6btn			; read additional 6-button inputs for P1
	
	.readP2:
		lea	(port_2_data).l,a1		; set to read second joypad port
		lea	(v_jpadhold_p2).w,a0		; address where P2 joypad states are written to
		bsr.s	.read_3btn			; read standard 3-button inputs for P2
		tst.b	(a0)				; is P2 using a 6-button controller?
		bpl.s	.return				; if not, branch
		bsr.s	.read_6btn			; read additional 6-button inputs for P2
	
	.return:
		rts					; return
	endif
; ---------------------------------------------------------------------------

.read_3btn:
		; 3-Button inputs (SACBRLDU)
		PollTH	1				; 1st TH poll (hi)
		moveq	#%00111111,d0			; clear all other inputs from the hi-poll (for sanity)
		and.b	(a1),d0				; write D-Pad, B, and C input states to d0
		PollTH	0				; 2nd TH poll (lo)
		moveq	#%00110000,d1			; clear all other inputs from the lo-poll (up and down)
		and.b	(a1),d1				; write A and Start input states to d1
		lsl.b	#2,d1				; move A and Start to highest bits
		or.b	d1,d0				; merge both poll results into d0
		; write result to v_jpadhold/v_jpadpress

	.toJpadRam:
		not.b	d0				; flip bits so that 0=released and 1=pressed
		move.b	(a0),d1				; get buttons held the previous frame
		move.b	d0,(a0)+			; write new HELD buttons
		eor.b	d0,d1				; xor with buttons held this frame
		and.b	d0,d1				; find buttons pressed this frame
		move.b	d1,(a0)+			; write new PRESSED buttons
		rts					; return
; ---------------------------------------------------------------------------

	if Enable_6ButtonControl
.read_6btn:
		; 6-button inputs (0000MXYZ)
		PollTH	1				; 3rd TH poll (hi)
		PollTH	0				; 4th TH poll (lo)
		PollTH	1				; 5th TH poll (hi)
		PollTH	0				; 6th TH poll (lo)
		PollTH	1				; 7th TH poll (hi, extra buttons are returned now)
		moveq	#%00001111,d0			; clear all other inputs from the poll
		and.b	(a1),d0				; write MODE, X, Y, Z input states to d0
		bra.s	.toJpadRam			; write result to v_jpadhold_6btn/v_jpadpress_6btn
	endif
; End of function ReadJoypads
; ---------------------------------------------------------------------------
; ===========================================================================



; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to setup the VDP with values used for the game itself
; ---------------------------------------------------------------------------

VDPSetupGame:
		lea	(vdp_control_port).l,a0			; load VDP control port
		lea	(vdp_data_port).l,a1			; load VDP data port
		lea	(VDPSetupArray).l,a2			; load address of register values
		moveq	#(VDPSetupArray_End-VDPSetupArray)/2-1,d7 ; set repeat times
.setreg:
		move.w	(a2)+,(a0)				; save register value to VDP
		dbf	d7,.setreg				; repeat until all register values have been sent

		move.w	(VDPSetupArray+2).l,d0			; get second entry of VDPSetupArray
		move.w	d0,(v_vdp_buffer1).w			; buffer register $81 (used for enabling/disabling display)

		move.w	#$8A00+223,(v_hblank_hreg).w		; HBlank every 224th scanline

		moveq	#cBlack,d0				; set d0 to 0 (black)
		move.l	#$C0000000,(vdp_control_port).l		; set VDP to CRAM write
		move.w	#($80)/2-1,d7				; set repeat times to cover full CRAM
.clrCRAM:
		move.w	d0,(a1)					; clear colours
		dbf	d7,.clrCRAM				; repeat until the entire palette is clear (black)

		clr.l	(v_scrposy_vdp).w			; clear single vertical scroll buffer
		clr.l	(v_scrposx_vdp).w			; clear single horizontal scroll buffer
		move.l	d1,-(sp)				; store d1 data in the stack for now
		fillVRAM 0,0,$10000				; clear the entirety of VRAM
		move.l	(sp)+,d1				; reload d1 data back out of the stack
		rts						; return
; End of function VDPSetupGame

; ---------------------------------------------------------------------------
; VDP register settings to use for the game. Do note that a handful of these
; are getting rewritten for every game mode change, though the majority
; will stay at their initial settings defined in this array.
; ---------------------------------------------------------------------------
; See here for details on VDP registers:
; https://segaretro.org/Sega_Mega_Drive/VDP_registers
; ---------------------------------------------------------------------------

VDPSetupArray:
		dc.w $8000|%00000100				; 8-color mode
		dc.w $8100|%00110100				; vertical interrupts, DMA, Mega Drive display
		dc.w $8200|(vram_fg>>10)			; foreground nametable address
		dc.w $8300|($A000>>10)				; window nametable address
		dc.w $8400|(vram_bg>>13)			; background nametable address
		dc.w $8500|(vram_sprites>>9)			; sprite table address
		dc.w $8600					; (unused, only relevant for 128KB VRAM mode)
		dc.w $8700|$00					; background colour (palette line 0, entry 0)
		dc.w $8800					; (unused, only relevant for Master System)
		dc.w $8900					; (unused, only relevant for Master System)
		dc.w $8A00|$00					; horizontal interrupt register
		dc.w $8B00|%00000000				; full-screen vertical scrolling
		dc.w $8C00|%10000001				; 40-cell display mode
		dc.w $8D00|(vram_hscroll>>10)			; background H-scroll address
		dc.w $8E00					; (unused, only relevant for 128KB VRAM mode)
		dc.w $8F00|$02					; VDP auto-increment size (2)
		dc.w $9000|%00000001				; 64-cell H-scroll size
		dc.w $9100					; window horizontal position
		dc.w $9200					; window vertical position
VDPSetupArray_End:

; ===========================================================================

		include	"_inc/DMA-Queue.asm"

; ---------------------------------------------------------------------------
; Load a Dynamic Pattern Load Cues request into the DMA queue.
; ---------------------------------------------------------------------------
; Input:
;	d0.b = frame number
;	d4.w = starting target VRAM tile address
;	d6.l = pointer to uncompressed art
;	a2   = pointer to DPLC table
; ---------------------------------------------------------------------------

LoadDynPLC:
		andi.w	#$FF,d0					; mask out anything except the input frame
		add.w	d0,d0					; double ID (for word-based indexing)
		adda.w	(a2,d0.w),a2				; find current DPLC entry
		moveq	#0,d5					; clear d5
		move.b	(a2)+,d5				; get number of tasks in this DPLC entry
		subq.w	#1,d5					; subtract 1 from number of tasks (will be the loop count)
		bmi.w	.end					; if it underflowed, this is an empty entry, nothing to do
		
	.loop:
		move.b	(a2)+,d3				; get first byte of DPLC task
		move.b	d3,-(sp)				; move it to stack (bytes shift sp by 2)
		moveq	#0,d1					; clear d1
		move.w	(sp)+,d1				; move it from stack to upper byte of d1
		move.b	(a2)+,d1				; get second byte of DPLC task
		andi.w	#$F0,d3					; only look at upper nybble of first byte
		addi.w	#$10,d3					; add 1 to that nybble
		andi.w	#$FFF,d1				; mask out that nybble in the other part
		lsl.l	#5,d1					; multiply by $20 (tile_size)
		add.l	d6,d1					; add art location
		move.w	d4,d2					; set target VRAM location
		add.w	d3,d4					; advance VRAM pointer
		add.w	d3,d4					; (twice, for word-based tiles)
		bsr.w	QueueDMATransfer			; load DMA request into queue (also known as "DMA_68KtoVRAM")
		dbf	d5,.loop				; repeat for number of entries
		
	.end:
		rts						; return
; End of function LoadDynPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the screen (plane mappings, sprites, and scroll data)
; ---------------------------------------------------------------------------

ClearScreen:
		fillVRAM 0, vram_fg, vram_fg+plane_size_64x32	; clear foreground namespace
		fillVRAM 0, vram_bg, vram_bg+plane_size_64x32	; clear background namespace

		clr.l	(v_scrposy_vdp).w			; clear single vertical scroll buffer
		clr.l	(v_scrposx_vdp).w			; clear single horizontal scroll buffer

		clearRAM v_spritetablebuffer,v_spritetablebuffer_end ; clear sprite table buffer
		clearRAM v_hscrolltablebuffer,v_hscrolltablebuffer_end_padded ; clear H-Scroll table buffer

		clr.b	(v_draw_hud).w
		ResetDMAQueue

		rts						; return
; End of function ClearScreen


; ===========================================================================
; >>> Subroutines to queue sound commands to be executed by the sound driver during VBlank
	; includes QueueSound1, QueueSound2, QueueSound3
	; (formerly called PlaySound, PlaySound_Special, PlaySound_Unknown)
	include	"_inc/Queue Sound Routines.asm"


; ===========================================================================
; >>> Subroutine to allow pausing the game
	include	"_inc/PauseGame.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

TilemapToVRAM:
		lea	(vdp_data_port).l,a6			; load VDP data port address
		move.l	#$800000,d4				; prepare plane width size for VDP address advancing (row)

Tilemap_Line:
		move.l	d0,4(a6)				; set the VDP the VRAM write mode with address
		move.w	d1,d3					; load width of rectangle

Tilemap_Cell:
		move.w	(a1)+,(a6)				; copy tile map to VRAM plane space
		dbf	d3,Tilemap_Cell				; repeat for the entire width
		add.l	d4,d0					; advance VDP value address to the next row
		dbf	d2,Tilemap_Line				; repeat for the entire height
		rts						; return
; End of function TilemapToVRAM

; ===========================================================================
; >>> Decompression algorithms
	include	"_inc/Decompression/Enigma Decompression.asm"
	include	"_inc/Decompression/KosinskiPlus Decompression.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add all entries from a PLC list to the PLC queue
; ---------------------------------------------------------------------------
; Input:
;    d0 = index of PLC list
; ---------------------------------------------------------------------------

NewPLC:
		bsr.s	ClearPLC				; like AddPLC, but clear the PLC queue first
; ---------------------------------------------------------------------------

AddPLC:
		movem.l	a1-a2,-(sp)				; store register data
		lea	(ArtLoadCues).l,a1			; load PLC list address
		add.w	d0,d0					; double for word-based indexing
		move.w	(a1,d0.w),d0				; load correct relative add address
		lea	(a1,d0.w),a1				; add and load actual address of list
		move.w	(a1)+,d0				; load size of list
		bmi.s	.return					; if there is no list, branch

		lea	(v_plc_buffer).w,a2			; load PLC process list		
	.findspace:
		tst.l	(a2)					; is this slot taken?
		beq.s	.fillQueue				; if not, branch
		addq.w	#plc_slot_size,a2			; advance to next slot
		bra.s	.findspace				; recheck

.fillQueue:
		cmpa.l	#v_plc_buffer_only_end,a2		; is PLC queue full?
		bhs.s	.overflow				; if yes, overflow...
		move.l	(a1)+,(a2)+				; copy Nemesis art address
		move.w	(a1)+,(a2)+				; copy VRAM location to dump to
		dbf	d0,.fillQueue				; repeat for all entries

	.return:
		movem.l	(sp)+,a1-a2				; restore register data
		rts						; return
; ---------------------------------------------------------------------------

.overflow:
		; WARNING: This will just silently drop the new PLC request and move on
		; like nothing happened. Ideally, you would raise an error here or some
		; other debugging functionality to troubleshoot any queue overflows!
		RaiseError "PLC queue overflow"			; comment this in if you have vladikcomper's Debugger
		bra.s	.return					; otherwise, just silently return...
; End of function AddPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to clear the PLC queue and all helper variables
; ---------------------------------------------------------------------------

ClearPLC:
		lea	(v_plc_buffer).w,a2			; load PLC process list
		moveq	#(v_plc_buffer_end-v_plc_buffer)/4-1,d1	; set size of list
	.loop:	clr.l	(a2)+					; clear PLC process list
		dbf	d1,.loop				; repeat until entire list is cleared
		rts						; return
; End of function ClearPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to directly load a full PLC list outside of VBlank (blocking).
; Not recommended, but Sonic 1 does use this occasionally...
; ---------------------------------------------------------------------------
; Input:
;    d0 = index of PLC list
; ---------------------------------------------------------------------------

QuickPLC:
		bsr.w	NewPLC					; write PLC ID to new queue on the fly...
; ---------------------------------------------------------------------------

.loop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w ; set VBlank routine (palette fade is good enough)
		bsr.w	WaitForVBlank				; execute PLC and DMA in VBlank
		tst.l	(v_plc_buffer).w			; is more work to be done?
		bne.s	.loop					; if yes, loop
		tst.b	(v_plc_Busy).w				; has last entry failed to get DMA'd in time?
		bne.s	.loop					; if yes, VBlank for one extra frame
		rts						; return
; End of function QuickPLC


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to execute PLC (decompress queued entries and queue for DMA)
; ---------------------------------------------------------------------------

ExecutePLC:
		tst.l	(v_plc_buffer).w			; does PLC queue contain any work for us?
		beq.s	.queueEmpty				; if not, branch

		movem.l	d0-a6,-(sp)				; backup all registers
		move.w	#Art_Buffer,(v_plc_BufferPtr).w		; reset decompression buffer pointer to start
		bsr.s	.executePLC				; execute the next PLC entry
		movem.l	(sp)+,d0-a6				; restore backed-up registers

	.queueEmpty:
		rts						; nothing to do
; ---------------------------------------------------------------------------

.executePLC:
		tst.b	(v_plc_Modules).w			; is multi-module decompression currently in progress?
		bne.s	.decompressAndQueueDMA			; if yes, continue decompressing next module
		; fresh entry...

; ---------------------------------------------------------------------------
; Process PLC queue (get next entry, prepare variables, get module count...)
; ---------------------------------------------------------------------------

.getNewPLCEntry:
		lea	(v_plc_buffer).w,a0			; get next entry of PLC queue
		move.l	(a0)+,d0				; get art offset
		move.w	(a0)+,(v_plc_VRAMAddr).w		; remember start VRAM address
		movea.l	d0,a0					; get art pointer

		move.w	(a0)+,d2				; get moduled header
		move.l	a0,(v_plc_ArtPtr).w			; remember start address of compressed data
		move.w	d2,d3					; copy module header
		and.w	#$F000,d2				; high nybble contains number of total modules - 1
		rol.w	#4,d2					; move to low nybble
		and.w	#$0FFF,d3				; get size of the last module
		seq.b	d3					; d3 = 0 if last module size is non-zero, -1 otherwise
		add.b	d3,d2					; reduce number of modules if the last module's size is zero

		addq.b	#1,d2					; make module count 1-based
		move.b	d2,(v_plc_Modules).w			; get number of modules to decompress
		; begin decompressing first module...

; ---------------------------------------------------------------------------
; Decompress a single module and queue it for DMA
; ---------------------------------------------------------------------------

.decompressAndQueueDMA:
		movea.w	(v_plc_BufferPtr).w,a1			; a1 = decompression buffer
		move.l	(v_plc_ArtPtr).w,a0			; a0 = compressed art pointer
        
		bsr.w	KosPlusDec				; decompress module to buffer using Kosinksi+ compression
		move.l	a0,(v_plc_ArtPtr).w			; remember compressed art pointer

		movea.w	(v_plc_BufferPtr).w,a0			; a0 = source
		move.w	a1,d3					; d3 = end of buffer
		sub.w	a0,d3					; d3 = size of decompressed module
		add.w	d3,(v_plc_BufferPtr).w			; adjust decompression buffer pointer
		move.l	a0,d1					; d1 = source address
		andi.l	#$FFFFFF,d1				; mask to 24-bit address
		move.w	(v_plc_VRAMAddr).w,d2			; d2 = destination VRAM address
		add.w	d3,(v_plc_VRAMAddr).w			; adjust destination VRAM address
		lsr.w	#1,d3					; d3 = DMA transfer length (transfer size / 2)

		move.w	sr,-(sp)				; remember interrupt state
		disable_ints					; need to disable interrupts while accessing DMA queue
		jsr	(QueueDMATransfer).l			; queue decompressed art to be DMA'd
		move.w	(sp)+,sr				; restore previous interrupt state
		
		subq.b	#1,(v_plc_Modules).w			; decrement number of remaining modules
		bne.s	.return					; if this is a multi-module asset and more modules are left to do, branch
		; all modules for this entry are completed, go to next PLC entry...

; ---------------------------------------------------------------------------
; When a single PLC entry (with all modules) has been fully decompressed
; ---------------------------------------------------------------------------

.entryCompleted:
		; Shift the whole PLC queue 6 bytes to the left 
		lea	(v_plc_buffer).w,a0			; load PLC process list
		moveq	#(v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)/4-1,d0 ; set size of list
	.loop:	move.l	plc_slot_size(a0),(a0)+			; shift contents of PLC buffer up 6 bytes
		dbf	d0,.loop				; repeat until done

		; Properly 'POP' last entry
		if (v_plc_buffer_only_end-v_plc_buffer-plc_slot_size)&2
			move.w	plc_slot_size(a0),(a0)		; pop trailing word of last entry
		endif
		clr.l	(v_plc_buffer_only_end-plc_slot_size+0).w ; clear art location of last entry
		clr.w	(v_plc_buffer_only_end-plc_slot_size+4).w ; clear VRAM dump location of last entry

		; Immediately execute the next PLC entry if it's small enough to fit into the buffer
		tst.l	(v_plc_buffer).w			; are more tasks in the PLC queue?
		beq.s	.return					; if not, branch
		movea.l	(v_plc_buffer).w,a0			; get art location of next entry from PLC queue
		move.w	(a0),d0					; get module header of art data
		move.w	#Art_Buffer_End,d1			; get end location of decompression buffer
		sub.w	(v_plc_BufferPtr).w,d1			; d1 = remaining space in buffer
		cmp.w	d1,d0					; is remaining space in buffer big enough for the next entry?
		bge.s	.return					; if not, branch
		movea.w	(VDP_Command_Buffer_Slot).w,a0		; get current DMA queue length
		cmpa.w	#VDP_Command_Buffer_Slot,a0		; is DMA queue already full?
		bne.w	.getNewPLCEntry				; if not, immediately execute next PLC entry

.return:
		rts						; return
; End of function ExecutePLC

; ---------------------------------------------------------------------------
; ===========================================================================


; ===========================================================================
; >>> Palette logic routines
	include	"_inc/PaletteCycle.asm"
	include	"_inc/Palette Fading.asm" ; includes "PaletteFadeIn", "PaletteFadeOut", "PaletteWhiteIn", and "PaletteWhiteOut"


; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w			; is light scanning effect done?
		bne.s	PCycSega_FadeIn				; if yes, branch

; ---------------------------------------------------------------------------
; First part of the Sega screen palette cycle (the "light scan effect")
; ---------------------------------------------------------------------------

		lea	(v_palette_line_2).w,a1			; set target start palette line (affects line 2-4 overall)
		lea	(Pal_Sega1).l,a0			; get palette cycle colors for the light scanning effect
		moveq	#(Pal_Sega1_end-Pal_Sega1)/2-1,d1	; set size of colors to write (6 in total)
		move.w	(v_pcyc_num).w,d0			; load current palcycle position (initialized to -$A)

; loc_2020:
.findScanStart:
		bpl.s	.doLightScan				; has start position been found? if yes, branch (d0 >= 0)
		addq.w	#2,a0					; get next color in Pal_Sega1
		subq.w	#1,d1					; set to load one less color
		addq.w	#2,d0					; go to next starting color for light effect
		bra.s	.findScanStart				; loop until current position has been found
; ===========================================================================

; loc_202A:
.doLightScan:
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent1			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_2034:
.notTransparent1:
		cmpi.w	#v_palette_line_4-v_palette_line_1,d0	; (=$60) would we write past the last palette entry?
		bhs.s	.writeNoMore				; if yes, do not write new color
		move.w	(a0)+,(a1,d0.w)				; write current light scan color to palette buffer

; loc_203E:
.writeNoMore:
		addq.w	#2,d0					; go to next starting color for light effect
		dbf	d1,.doLightScan				; loop until all colors have been written

		; Palette dumping is done, update next offset or set to next part
		move.w	(v_pcyc_num).w,d0			; load current palcycle position
		addq.w	#2,d0					; go to next starting color
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent2			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_2054:
.notTransparent2:
		cmpi.w	#v_palette_line_4-v_palette_line_1+4,d0	; (=$64) has light scan effect finished?
		blt.s	.scanNotDone				; if not, branch
		move.w	#(4<<8)+1,(v_pcyc_time).w		; set delay between fade-in increments (high byte) and "light scan done" flag (low byte)
		moveq	#-6*2,d0				; set starting offset for fade-in palette (gets set to 0 for first fade-in step)

; loc_2062:
.scanNotDone:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0					; clear Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; ===========================================================================

; ---------------------------------------------------------------------------
; Second part of the Sega screen palette cycle (the fade-in)
; ---------------------------------------------------------------------------

; loc_206A:
PCycSega_FadeIn:
		subq.b	#1,(v_pcyc_time).w			; decrement delay until next brightness increase
		bpl.s	.delayFadeIn				; does delay time remain? if yes, branch

		move.b	#4,(v_pcyc_time).w			; reset delay between fade-in increments
		move.w	(v_pcyc_num).w,d0			; get current fade-in position
		addi.w	#6*2,d0					; go to next set of colors
		cmpi.w	#(6*2)*4,d0				; have four color sets been done?
		blo.s	.doFadeIn				; if not, do next fade-in step

		moveq	#0,d0					; set Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; ===========================================================================

; loc_2088:
.doFadeIn:
		move.w	d0,(v_pcyc_num).w			; remember position for next fade-in increment
		lea	(Pal_Sega2).l,a0			; get palette cycle colors for the fade-in effect
		lea	(a0,d0.w),a0				; go to relevant color data
		lea	(v_palette_line_1+$04).w,a1		; set to write past transparent and pure-white color
		move.l	(a0)+,(a1)+				; write colors 1 and 2 to buffer
		move.l	(a0)+,(a1)+				; write colors 3 and 4 to buffer
		move.w	(a0)+,(a1)				; write color 5 to buffer

		; Main palette dumping is done, fill remaining palette buffer with 6th color
		lea	(v_palette_line_2).w,a1			; start from second palette line (up to fourth one)
		moveq	#0,d0					; clear d0
		moveq	#((v_palette_line_4-v_palette_line_1)/2)-3-1,d1 ; (=$2C) write 3 lines, minus skipped transparent colors, minus 1

; loc_20A8:
.fillRest:
		move.w	d0,d2					; get current target position
		andi.w	#$1E,d2					; limit to one palette line ($20 bytes)
		bne.s	.notTransparent3			; is it the first (transparent) color? if not, branch
		addq.w	#2,d0					; skip over transparent color

; loc_20B2:
.notTransparent3:
		move.w	(a0),(a1,d0.w)				; write fill color to current palette slot (and don't advance index)
		addq.w	#2,d0					; go to next palette target
		dbf	d1,.fillRest				; loop until remaining palette has been filled completely

; loc_20BC:
.delayFadeIn:
		moveq	#1,d0					; clear Z-flag (possibly for a return signal, but now unsued)
		rts						; return
; End of function PalCycle_Sega

; ===========================================================================
; >>> Palette cycle data used for Sega screen
Pal_Sega1:	bincludeEndMarker	"palette/Sega1.bin"	; used during the light scanning effect
Pal_Sega2:	bincludeEndMarker	"palette/Sega2.bin"	; used during the fade-in (three color sets, 5+1 colors each)


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load main palettes into the fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.

; input:
; d0 = index number for palette
; ---------------------------------------------------------------------------

PalLoad_Fade:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		adda.w	#v_palette_fading-v_palette,a3		; load to palette fade-in buffer instead of active palette buffer (+$80)
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade

; ---------------------------------------------------------------------------
; Subroutine to directly load main palettes to the active palette.
; Same as PalLoad_Fade, but without adding $80.
; ---------------------------------------------------------------------------

PalLoad:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load underwater palettes into the water fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.
; ---------------------------------------------------------------------------

PalLoad_Fade_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water,a3		; load to (water) palette fade-in buffer instead of active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade_Water

; ---------------------------------------------------------------------------
; Subroutine to directly load underwater palettes to the active palette.
; Same as PalLoad_Fade_Water, but writing $80 before it.
; ---------------------------------------------------------------------------

PalLoad_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water_fading,a3	; load to active (water) palette buffer instead of main active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Water

; ===========================================================================
; >>> Palette pointers and palette binary includes
	include	"_inc/Palette Index.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; DelayProgram: <-- old misnomer
; WaitForVBla: <-- old name
WaitForVBlank:
	if LagOMeter
		move.w	#$9100,(vdp_control_port).l ; disable lag-o-meter
	endif
		enable_ints					; enable interrupts so vertical interrupts can occur

		tst.l	(v_plc_buffer).w			; are any PLC jobs queued?
		beq.s	.wait					; if not, branch
		tst.b	(v_plc_Busy).w				; has PLC DMA missed the previous frame?
		bne.s	.wait					; if yes, don't advance PLC this frame
		bsr.w	ExecutePLC				; decompress the next PLC entry and queue it for DMA
		tst.b	(v_vblank_routine).w			; has VBlank interrupt occurred while PLC was running?
		bne.s	.wait					; if not, branch
		st.b	(v_plc_Busy).w				; otherwise, set flag that next frame should skip PLC (flush DMA)
		rts
.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, loop until it has

		sf.b	(v_plc_Busy).w				; clear DMA busy flag

	if LagOMeter
		move.w	#$9193,(vdp_control_port).l ; enable lag-o-meter
	endif
		rts						; resume normal operation
; End of function WaitForVBlank


; ===========================================================================
; >>> Subroutines for generic calculations
	include	"_incObj/sub RandomNumber.asm"
	include	"_incObj/sub CalcSine.asm"
	include	"_incObj/sub CalcAngle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

; SegaScreen:
GM_Sega:
		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteWhiteOut				; white fade-out because the Sega screen has a white background
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8004,(a6)				; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$8700,(a6)				; set background colour (palette entry 0)
		move.w	#$8B00,(a6)				; full-screen vertical scrolling
		clr.b	(f_wtr_state).w				; clear water state

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen

		moveq	#plcid_Sega,d0				; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_SegaLogo).l,a0			; load Sega logo mappings
		move.w	#ArtTile_Sega_Tiles,d0			; set art tile for Sega screen mappings
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer
		copyTilemap v_ram_start,vram_bg+$510,24,8	; transfer decompressed patterns to VRAM (BG plane, light scanning effect)
		copyTilemap v_ram_start+24*8*2,vram_fg,40,28	; transfer decompressed patterns to VRAM (FG plane, Sega logo cutout)

		tst.b	(v_megadrive).w				; is console Japanese?
		bmi.s	.loadpal				; if not, branch
		copyTilemap v_ram_start+$A40,vram_fg+$53A,3,2	; hide "TM" with a white rectangle
.loadpal:

		moveq	#palid_SegaBG,d0			; load Sega screen palette...
		bsr.w	PalLoad					; ...directly to active palette (not fade-in buffer)
		move.w	#-$A,(v_pcyc_num).w			; light scanning palette cycle effect start offset
		move.w	#0,(v_pcyc_time).w			; clear palette fade-in counter
		move.w	#0,(v_pal_buffer+$12).w			; clear some palcycle buffer (unused?)
		move.w	#0,(v_pal_buffer+$10).w			; clear some palcycle buffer (unused?)
		enable_display					; enable screen output
; ---------------------------------------------------------------------------

Sega_WaitPal:		; while light scanning effect is active
		move.b	#id_VBlank_Sega,(v_vblank_routine).w	; set VBlank routine to $02
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		andi.b	#btnStart,(v_jpadhold1).w
		bne.s	Sega_GotoTitle
		bsr.w	PalCycle_Sega				; advance light scanning palette cycle effect
		bne.s	Sega_WaitPal				; loop until it's finished
; ---------------------------------------------------------------------------

		; while "SEGA" sound is playing
		move.b	#sfx_Sega,d0				; set "SEGA" sound
		bsr.w	QueueSound2				; queue it
		move.b	#id_VBlank_SegaPCM,(v_vblank_routine).w	; set VBlank routine to $14
		bsr.w	WaitForVBlank				; wait for VBlank to play the sound (CPU is frozen here until sound finished playing)
; ---------------------------------------------------------------------------

		; after sound has finished playing
		move.w	#(2*60)+30,(v_generictimer).w	; wait 2.5 seconds (150 frames) before automatic fade-out

Sega_WaitEnd:
		move.b	#id_VBlank_Sega,(v_vblank_routine).w	; set VBlank routine to $02
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		tst.w	(v_generictimer).w			; has post-chant timer expired?
		beq.s	Sega_GotoTitle				; if yes, go to title screen
		andi.b	#btnStart,(v_jpadhold1).w		; is Start button pressed?
		beq.s	Sega_WaitEnd				; if not, loop post-chant routine
; ---------------------------------------------------------------------------

Sega_GotoTitle:		; transition to title screen
		move.b	#id_Title,(v_gamemode).w		; go to title screen
		rts						; return to MainGameLoop
; End of function GM_Sega


; ===========================================================================
; ---------------------------------------------------------------------------
; Title screen
; ---------------------------------------------------------------------------

; TitleScreen:
GM_Title:		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading "SONIC TEAM PRESENTS" (STP) patterns
		disable_ints					; disable ints while accessing the VDP
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8004,(a6)				; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		move.w	#$9200,(a6)				; window vertical position
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8720,(a6)				; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen
		clearRAM v_objspace				; clear object RAM
		clearRAM v_lvllayout

		moveq	#plcid_TitleSonicTeam,d0		; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_JapNames).l,a0			; load mappings for hidden Japanese credits
		move.w	#ArtTile_Title_Japanese_Text|Tile_Pal3,d0 ; set art tile for hidden Japanese credits (cyan)
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer
		copyTilemap v_ram_start,vram_fg,40,28		; transfer decompressed patterns from RAM buffer to VRAM

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer
		move.l	#CreditsText,(v_sonicteam+obID).w	; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l			; execute objects to load STP object
		jsr	(BuildSprites).l			; build sprites for the STP object
		bsr.w	PaletteFadeIn				; fade-in STP screen
; ---------------------------------------------------------------------------

		; load main title screen patterns while "SONIC TEAM PRESENTS" screen is shown
		disable_ints					; display is frozen during the STP screen

		moveq	#plcid_TitleForeground,d0		; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		lea	(vdp_data_port).l,a6			; load VDP data transfer port
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6) ; set target VRAM location for level select font
		lea	(Art_Text).l,a5				; load uncompressed level select font
		move.w	#(Art_Text_end-Art_Text)/2-1,d1		; set loop count for level select
Tit_LoadText:
		move.w	(a5)+,(a6)				; write one row of the level select font to VRAM
		dbf	d1,Tit_LoadText				; loop until it's fully loaded

		move.b	#0,(v_lastlamp).w			; clear lamppost counter
		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		move.w	#id_GHZ_act1,(v_zone_act).w		; set level to GHZ1 (000)
		move.w	#0,(v_pcyc_time).w			; disable palette cycling
		bsr.w	LevelSizeLoad				; load level size (will use GHZ1's sizes)

		move.l	#Blk16_Title,(v_rom_blocks).w		; set Blk16 pointer to use Title blocks
		move.l	#Blk256_Title,(v_rom_chunks).w		; set Blk256 pointer to use Title blocks

		lea	(Level_Titlebg).l,a1
		lea	(v_lvllayout_bg).w,a3
		bsr.w	LevelLayoutLoad				; load level layout for the background

		moveq	#60-1,d0				; frames to manually wait on STP screen
	.delay:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		andi.b	#btnStart,(v_jpadhold1).w
		bne.s	.skip

		dbf	d0,.delay
	.skip:
		bsr.w	PaletteFadeOut				; fade-out "SONIC TEAM PRESENTS" screen
; ---------------------------------------------------------------------------

		; "SONIC TEAM PRESENTS" screen has faded out, load remaining patterns and fade in
		disable_ints					; disable interrupts again after the fade-out
		bsr.w	ClearScreen				; wipe screen

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_bgscreenposx).w,a3			; get current background X position
		lea	(v_lvllayout_bg).w,a4			; get location in level layout RAM where background is stored
		move.w	#$4000+(vram_bg-vram_fg),d2		; =$6000 (VRAM write command $4000 + nametable start address relative to vram_fg)
		bsr.w	DrawChunks				; draw initial background layer

		lea	(v_ram_start+$6000).l,a1		; set middle of RAM to be used as decompression buffer (this overwrites unused chunk RAM)
		lea	(Eni_Title).l,a0			; load title screen emblem mappings
		move.w	#ArtTile_Title_Foreground,d0		; set foreground emblem art tile (dynamically set)
		bsr.w	EniDec					; decompress Enigma-compressed emblem mappings to buffer
		copyTilemap	v_ram_start+$6000,vram_fg,40,28	; transfer decompressed patterns from RAM buffer to VRAM (full plane)

		moveq	#plcid_TitleBackground,d0		; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		moveq	#palid_Title,d0				; load title screen palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		move.b	#bgm_Title,d0				; set title screen music
		bsr.w	QueueSound2				; play title screen music
		move.b	#0,(f_debugmode).w			; disable debug mode (cheat remains active though)
		move.w	#376,(v_generictimer).w			; run title screen for 376 frames (6 seconds plus some change)
		tst.b	(v_pal).w				; is Mega Drive set to PAL region?
		beq.s	.notPAL					; if not, branch
		subi.w	#60,(v_generictimer).w			; correct title screen duration for PAL
	.notPAL:

		clearRAM v_sonicteam,v_sonicteam+object_size	; delete RAM used by "SONIC TEAM PRESENTS" object (fully)

		move.l	#TitleSonic,(v_titlesonic+obID).w	; load big Sonic object
		move.l	#PSBTM,(v_pressstart+obID).w		; load "PRESS START BUTTON" object
		jsr	(TitleMenu_LoadTextGraphics).l

		tst.b	(v_megadrive).w				; is console Japanese?
		bpl.s	.isjap					; if yes, don't load TM object
		move.l	#PSBTM,(v_titletm+obID).w		; load title screen HUD object
		move.b	#3,(v_titletm+obFrame).w		; set it to the "TM" frame
	.isjap:

		move.l	#PSBTM,(v_ttlsonichide+obID).w		; load title screen HUD object
		move.b	#2,(v_ttlsonichide+obFrame).w		; load object which hides part of Sonic's torso behind the emblem

		jsr	(ExecuteObjects).l			; load title screen objects
		bsr.w	DeformLayers				; initialize background deformation before fade-in
		jsr	(BuildSprites).l			; build sprites for the title screen objects before fade-in

		move.w	#0,(v_title_dcount).w			; clear D-Pad counter for title screen cheats
		move.w	#0,(v_title_ccount).w			; clear C counter for title screen cheats
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable display
		bsr.w	PaletteFadeIn				; fade-in title screen

; ---------------------------------------------------------------------------
; Title screen main loop and cheat checks
; ---------------------------------------------------------------------------

Tit_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		jsr	(ExecuteObjects).l			; execute title screen objects
		bsr.w	DeformLayers				; run background deformation
		jsr	(BuildSprites).l			; display sprites

		lea	(v_spritetablebuffer+4).w,a1		; fetch sprite table buffer, starting from tile IDs
		moveq	#0,d0					; this will be our X-position
		moveq	#sprites_max-1,d6			; iterate through the whole sprite table (80-1)
	.maskLoop:
		tst.w	(a1)					; does this sprite have tile ID $0000 (indicates either a mask or nothing)?
		bne.s	.next					; if not, then this is a normal sprite, do not modify its X-position
		bchg	#2,d0					; alternate between X-position of 0 and 4 (masks need a non X=0 higher priority sprite to mask)
		move.w	d0,2(a1)				; write to X-position
	.next:	addq.w	#8,a1					; go to next sprite
		dbf	d6,.maskLoop				; loop

		bsr.w	PalCycle_Title				; run title screen palette cycle

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_ChkRegion				; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

Tit_ChkRegion:
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_RegionJap				; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; load US code
		bra.s	Tit_EnterCheat				; skip over

Tit_RegionJap:
		lea	(LevSelCode_J).l,a0			; load J code

Tit_EnterCheat:
		move.w	(v_title_dcount).w,d0			; get number of successful D-Pad cheat inputs
		adda.w	d0,a0					; add to loaded code to find current cheat input requirement
		move.b	(v_jpadpress1).w,d0			; get buttons pressed this frame
		andi.b	#btnDir,d0				; read only D-Pad buttons (UDLR)
		cmp.b	(a0),d0					; does button press match current cheat entry?
		bne.s	Tit_ResetCheat				; if not, branch and reset cheat
		addq.w	#1,(v_title_dcount).w			; increment number of successful D-Pad cheat inputs
		tst.b	d0					; has end of cheat code been reached? (0-entry in cheat)
		bne.s	Tit_CountC				; if not, branch
		clr.w	(v_title_dcount).w			; reset D-Pad counter

Tit_ActivateCheat:
		; (On JAPANESE consoles only) Activated cheat depends on the amount of times C was pressed:
		; 0-1 level select -- 2-3 slow motion -- 4-5 debug mode -- 6-7: hidden Japanese credits & sound test 9E/9F
		; For any other regions, pressing C twice or more will ALWAYS result in slow motion and debug mode,
		; and the hidden Japanese credits cheat is unavailable under any circumstances on such consoles.
		lea	(f_levselcheat).w,a0			; get base cheat index
		move.w	(v_title_ccount).w,d1			; get number of tiles C was pressed
		lsr.w	#1,d1					; half pressed amount
		andi.w	#3,d1					; only four cheats are possible
		beq.s	Tit_PlayRing				; if C was not pressed, only activate level select
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_PlayRing				; if Japanese, branch
		moveq	#1,d1					; on non-Japanese console, force index to slow motion cheat
		move.b	d1,1(a0,d1.w)				; enable debug mode first (and slow motion in the next line)

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat depending on C-press count
		move.b	#sfx_Ring,d0				; set ring sound when code is entered
		bsr.w	QueueSound2				; play it
		bra.s	Tit_CountC				; skip over cheat reset
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0					; has D-Pad been pressed?
		beq.s	Tit_CountC				; if not, don't reset D-Pad counter
		cmpi.w	#9,(v_title_dcount).w			; has cheat reached index 9? (impossible condition)
		beq.s	Tit_CountC				; if yes, don't reset D-Pad counter
		move.w	#0,(v_title_dcount).w			; reset cheat index counter
		lea	(LevSelCode_J).l,a0			; reload J code
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	.chkUp					; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; reload US code
	.chkUp:	cmp.b	(a0),d0					; was incorrect button press the first cheat input?
		beq.s	Tit_EnterCheat				; if yes, treat it as first correct input right away

Tit_CountC:
		move.b	(v_jpadpress1).w,d0			; get currently pressed buttons
		andi.b	#btnC,d0				; is C button pressed?
		beq.s	Tit_ChkStartOrDemo			; if not, branch
		addq.w	#1,(v_title_ccount).w			; increment C counter

; loc_3230:
Tit_ChkStartOrDemo:
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, continue looping title screen

Tit_ChkLevSel:
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.s	.nocheat
		btst	#bitA,(v_jpadhold1).w			; check if A was held while pressing Start
		beq.s	.nocheat
		tst.b	(v_pressstart+obFrame).w
		beq.s	Tit_EnterLevelSelect
	.nocheat:
		jmp	(TitleMenu_SelectionMade).l

Tit_ChkLevSel_AbortDemo:
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, begin game by playing normal level
		btst	#bitA,(v_jpadhold1).w			; check if A was held while pressing Start
		beq.w	PlayLevel				; if not, begin game by playing normal level
; ---------------------------------------------------------------------------

Tit_EnterLevelSelect:
		lea	(v_pressstart).w,a0
		jsr	(DeleteObject).l
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l

		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; run VBlank one extra frame to prevent graphical glitches
		moveq	#palid_LevelSel,d0			; load level select palette...
		bsr.w	PalLoad					; ...directly to active palette

		clearRAM v_hscrolltablebuffer			; clear H-Scroll buffer
		move.l	d0,(v_scrposy_vdp).w			; clear VSRAM (d0 is still 0)
		disable_ints					; disable interrupts

		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	vram_bg					; write to background nametable
		move.w	#plane_size_64x32/4-1,d1		; write full screen
.LevSelClearBG:	move.l	d0,(a6)					; clear background plane
		dbf	d1,.LevSelClearBG			; loop until plane is fully cleared

		bsr.w	LevSelTextLoad				; load level select text before entering main loop

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	LevSelControls				; update selected line if necessary
		tst.l	(v_plc_buffer).w			; are any patterns in the PLC still left to be loaded?
		bne.s	LevelSelect				; if yes, block quitting level select until finished
		andi.b	#btnC+btnStart,(v_jpadpress1).w		; is C or Start pressed?
		beq.s	LevelSelect				; if not, loop level select

LevSel_SelectionMade:
		move.w	(v_levselitem).w,d0			; get currently selected line
		cmpi.w	#levsel_sndtest_row,d0			; have you selected item $14 (sound test)?
		bne.s	LevSel_Level_SS				; if not, go to Level/SS subroutine
		move.w	(v_levselsound).w,d0			; get currently selected sound test entry
		addi.w	#$80,d0					; make it $80-based

		; 9E/9F shortcuts with hidden Japanese Credits cheat
		tst.b	(f_creditscheat).w			; is hidden Japanese Credits cheat on?
		beq.s	LevSel_NoCheat				; if not, branch
		cmpi.w	#$9F,d0					; is sound $9F being played?
		beq.s	LevSel_Ending				; if yes, go to Ending Sequence
		cmpi.w	#$9E,d0					; is sound $9E being played?
		beq.s	LevSel_Credits				; if yes, go to Credits
LevSel_NoCheat:
		bsr.w	QueueSound2				; play selected sound
		bra.s	LevelSelect				; loop level select
; ===========================================================================

LevSel_Ending:
		btst	#bitA,(v_jpadhold1).w
		beq.s	.notA
		move.b	#ss_emeralds_num,(v_emeralds).w
	.notA:
		move.b	#id_Ending,(v_gamemode).w 		; set screen mode to $18 (Ending)
		move.w	#id_EndZ_good,(v_zone_act).w  		; set level to good Ending (will be bad Ending without 6 emeralds)
		rts
; ===========================================================================

LevSel_Credits:
		move.b	#id_Credits,(v_gamemode).w		; set screen mode to $1C (Credits)
		move.b	#bgm_Credits,d0				; set credits music
		bsr.w	QueueSound2				; play it
		move.w	#0,(v_creditsnum).w			; start at the first credits page
		rts
; ===========================================================================

LevSel_Level_SS:
		add.w	d0,d0					; double selected line for word-based indexing
		lea	LevSel_Ptrs(pc),a0
		move.w	(a0,d0.w),d0				; find relevant level pointer from table
		bmi.w	LevelSelect				; if it's an invalid entry, branch back to main loop

		cmpi.w	#id_SS<<8,d0				; check if selected level Special Stage (0700 is used as dummy value)
		blt.s	LevSel_Level				; if not, branch

		andi.w	#$0007,d0
		move.b	d0,(v_lastspecial).w

		move.b	#id_Special,(v_gamemode).w		; set screen mode to $10 (Special Stage)
		clr.w	(v_zone_act).w				; clear level
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
		rts
; ===========================================================================

LevSel_Level:
		andi.w	#$3FFF,d0				; mask out invalid bits of level number
		move.w	d0,(v_zone_act).w			; set new level number (zone and act)

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastspecial).w			; clear special stage number
		move.b	d0,(v_emeralds).w			; clear emeralds
		move.l	d0,(v_emldlist).w			; clear emeralds
		move.l	d0,(v_emldlist+4).w			; clear emeralds
		move.b	d0,(v_continues).w			; clear continues
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
		move.b	#bgm_Fade,d0				; set music fade-out command
		bra.w	QueueSound2				; fade out music
; End of function GM_Title

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select - level pointers
; ---------------------------------------------------------------------------
; This is just for the pointers. For the text itself, see: LevelMenuText
; ---------------------------------------------------------------------------

LevSel_Ptrs:
		dc.w id_GHZ_act1
		dc.w id_GHZ_act2
		dc.w id_GHZ_act3
		dc.w id_MZ_act1
		dc.w id_MZ_act2
		dc.w id_MZ_act3
		dc.w id_SYZ_act1
		dc.w id_SYZ_act2
		dc.w id_SYZ_act3
		dc.w id_LZ_act1
		dc.w id_LZ_act2
		dc.w id_LZ_act3
		dc.w id_SLZ_act1
		dc.w id_SLZ_act2
		dc.w id_SLZ_act3
		dc.w id_SBZ_act1
		dc.w id_SBZ_act2
		dc.w id_LZ_act4			; Scrap Brain Zone 3
		dc.w id_FZ			; Final Zone
		dc.w id_SS<<8+$00		; Special Stage 1
		dc.w id_SS<<8+$01		; Special Stage 2
		dc.w id_SS<<8+$02		; Special Stage 3
		dc.w id_SS<<8+$03		; Special Stage 4
		dc.w id_SS<<8+$04		; Special Stage 5
		dc.w id_SS<<8+$05		; Special Stage 6
		dc.w $8000			; Sound Test
LevSel_PtrsEnd:	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select codes
; ---------------------------------------------------------------------------

LevSelCode_J:
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change what you're selecting in the level select
; ---------------------------------------------------------------------------

LevSelControls:
		move.b	(v_jpadpress1).w,d1			; get current button presses
		andi.b	#btnUp+btnDn,d1				; is up/down pressed this frame?
		bne.s	LevSel_UpDown				; if yes, branch
		subq.w	#1,(v_levseldelay).w			; if held, subtract 1 from delay until next move
		bpl.s	LevSel_SndTest				; if time remains, branch

LevSel_UpDown:
		move.w	#12-1,(v_levseldelay).w			; reset time delay
		move.b	(v_jpadhold1).w,d1			; get currently held buttons
		andi.b	#btnUp+btnDn,d1				; is up/down held?
		beq.s	LevSel_SndTest				; if not, branch
		move.w	(v_levselitem).w,d0			; get currently selected line
		btst	#bitUp,d1				; is up held?
		beq.s	LevSel_Down				; if not, branch
		subq.w	#1,d0					; move up 1 selection
		bhs.s	LevSel_Down				; if entry is still valid, branch
		moveq	#levsel_line_count-1,d0			; if selection moves below 0, jump to selection last row

LevSel_Down:
		btst	#bitDn,d1				; is down held?
		beq.s	LevSel_Refresh				; if not, branch
		addq.w	#1,d0					; move down 1 selection
		cmpi.w	#levsel_line_count,d0			; is selection past the last one now?
		blo.s	LevSel_Refresh				; if not, branch
		moveq	#0,d0					; if selection moves past the last row, jump to selection 0

LevSel_Refresh:
		move.w	d0,(v_levselitem).w			; set new selection
		bra.w	LevSelTextLoad				; refresh text
; ===========================================================================

LevSel_SndTest:
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is sound test row selected?
		bne.s	LevSel_NoMove				; if not, branch
		move.b	(v_jpadpress1).w,d1			; get currently pressed buttons
		andi.b	#btnL+btnR+btnA,d1			; is left/right/A pressed?
		beq.s	LevSel_NoMove				; if not, branch

		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		btst	#bitL,d1				; is left pressed?
		beq.s	LevSel_Right				; if not, branch
		subq.w	#1,d0					; subtract 1 from sound test
		bhs.s	LevSel_Right				; is result still positive? if yes, branch
		moveq	#$FF-$80,d0 			; if sound test moves below 0, set to last entry (non-$80 based)

LevSel_Right:
		btst	#bitR,d1				; is right pressed?
		beq.s	LevSel_Refresh2				; if not, branch
		addq.w	#1,d0					; add 1 to sound test
		cmpi.w	#$FF-$80+1,d0			; is result now past the last entry?
		blo.s	LevSel_Refresh2				; if not, branch
		moveq	#0,d0					; if sound test moves above last entry, set to 0

LevSel_Refresh2:
		btst	#bitA,d1				; is A pressed?
		beq.s	LevSel_SetSound				; if not, branch
		btst	#bitB,(v_jpadhold1).w			; was B held down while A was pressed?
		bne.s	LevSel_A_WithB				; if yes, branch
		addi.w	#$10,d0					; advance sound test selection by $10
		cmpi.w	#$FF-$80+1,d0			; is result now past the last entry?
		blo.s	LevSel_SetSound				; if not, branch
		subi.w	#$FF-$80+1,d0			; if sound test moves above last entry, wrap
		bra.s	LevSel_SetSound				; skip over

LevSel_A_WithB:
		subi.w	#$10,d0					; reduce sound test selection by $10
		bhs.s	LevSel_SetSound				; is result still positive? if yes, branch
		addi.w	#$FF-$80+1,d0			; if sound test moves below 0, wrap

LevSel_SetSound:
		move.w	d0,(v_levselsound).w			; set sound test number
		bsr.w	LevSelTextLoad				; refresh text

LevSel_NoMove:
		rts
; End of function LevSelControls

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

levsel_line_count:	equ 26	; total number of lines
levsel_line_length:	equ 24	; characters per line
levsel_sndtest_row:	equ levsel_line_count-1  ; row index of the sound test
levsel_sndtest_col:	equ levsel_line_length-8 ; column offset for the sound test number

levsel_start_row:	equ 1	; top tile offset for start position
levsel_start_col:	equ 8	; left tile offset for start position
levsel_vram_main:	equ vram_bg+(levsel_start_row<<7)+(levsel_start_col<<1)	; nametable address in VRAM
levsel_vram_sndtestnum:	equ levsel_vram_main+(levsel_sndtest_row<<7)+(levsel_sndtest_col<<1) ; nametable address for sound test numbers

levsel_white:		equ ArtTile_Level_Select_Font|Tile_Pal4|Tile_Prio ; VRAM setting for white text (non-selected lines)
levsel_yellow:		equ ArtTile_Level_Select_Font|Tile_Pal3|Tile_Prio ; VRAM setting for yellow text (selected line)

; ---------------------------------------------------------------------------

LevSelTextLoad:
		; Write main text in white
		lea	(LevelMenuText).l,a1			; load menu text offset
		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		move.w	#levsel_white,d3			; VRAM setting
		moveq	#levsel_line_count-1,d1			; number of lines of text to write
.DrawAll:	move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; draw line of text
		addi.l	#$00800000,d4				; jump to next line
		dbf	d1,.DrawAll				; repeat until all lines are drawn

		; Draw currently selected line in yellow
		moveq	#0,d0					; clear d0
		move.w	(v_levselitem).w,d0			; get currently selected line
		move.w	d0,d1					; back up selected line
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		lsl.w	#7,d0					; times $80
		swap	d0					; swap so that line now becomes VRAM nametable offset
		add.l	d0,d4					; add that to base VRAM location
		lea	(LevelMenuText).l,a1			; load menu text offset
	if levsel_line_length=24
		lsl.w	#3,d1					; times 8
		move.w	d1,d0					; copy result
		add.w	d1,d1					; times...
		add.w	d0,d1					; ...3 (because default line length 8 x 3 = 24)
	else
		; The above calculation assumes 24 as line length, we need a different approach if it changes.
		mulu.w	#levsel_line_length,d1			; multiply selected line index by line length
	endif
		adda.w	d1,a1					; add to menu text offset
		move.w	#levsel_yellow,d3 			; prepare selected-line VRAM setting
		move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; recolour selected line

		; Write sound test numbers
		move.w	#levsel_white,d3			; draw numbers in white by default
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is currently selected line the sound test?
		bne.s	LevSel_DrawSnd				; if not, branch
		move.w	#levsel_yellow,d3			; draw numbers in yellow
LevSel_DrawSnd:
		locVRAM	levsel_vram_sndtestnum			; write sound test number position to VRAM
		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		addi.w	#$80,d0					; make sound ID to be drawn $80-based
		move.b	d0,d2					; backup number
		lsr.b	#4,d0					; move first digit to lower nybble
		bsr.w	LevSel_ChgSnd				; draw 1st digit
		move.b	d2,d0					; restore backup
		bra.w	LevSel_ChgSnd				; draw 2nd digit
; ===========================================================================

LevSel_ChgSnd:
		andi.w	#$F,d0					; mask out upper nybble
		cmpi.b	#$A,d0					; is digit $A-$F?
		blo.s	.DrawNum				; if not, branch
		addi.b	#7,d0					; use letter characters
.DrawNum:	add.w	d3,d0					; combine number with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		rts
; ===========================================================================

LevSel_ChgLine:
		moveq	#levsel_line_length-1,d2		; number of characters per line

.LineLoop:	moveq	#0,d0					; clear d0
		move.b	(a1)+,d0				; get current character
		bpl.s	.CharOk					; is it a valid ASCII character? if yes, branch
		move.w	#0,(a6)					; draw a blank character
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts

.CharOk:	add.w	d3,d0					; combine char with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts
; End of function LevSelTextLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select menu text
; ---------------------------------------------------------------------------
; This is just for the actual text. For the level pointers, see: LevSel_Ptrs
; ---------------------------------------------------------------------------

; Macro to convert input text to the correct level select text,
; because ASM68K doesn't support the "charset" feature of AS.
lstxt	macro textline
	i:   = 1
	len: = strlen(\textline)
	if len<>24
		inform 2, "line length must be exactly 24 characters"
	endif

	while (i<=len)
		char:	substr i,i,\textline
		i: = i+1

		if     "\char"=' '
			dc.b	$FF
		elseif ("\char">='0')&("\char"<='9')
			dc.b	$00+"\char"-'0'
		elseif "\char"='$'
			dc.b	$0A
		elseif "\char"='-'
			dc.b	$0B
		elseif "\char"='='
			dc.b	$0C
		elseif "\char"=">"
			dc.b	$0D
		;elseif "\char"=">"	; there are two identical right arrows in the font for some reason
		;	dc.b	$0E
		elseif "\char"='Y'	; Y and Z come before A-X
			dc.b	$0F
		elseif "\char"='Z'
			dc.b	$10
		elseif ("\char">='A')&("\char"<='X')
			dc.b	$11+"\char"-'A'
		else
			inform 2, "illegal char \char"
		endif
	endw
	endm

LevelMenuText:
		lstxt "GREEN HILL ZONE    ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "MARBLE ZONE        ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "SPRING YARD ZONE   ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "LABYRINTH ZONE     ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "STAR LIGHT ZONE    ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "SCRAP BRAIN ZONE   ACT 1"
		lstxt "                   ACT 2"
		lstxt "                   ACT 3"
		lstxt "FINAL ZONE              "
		lstxt "SPECIAL STAGE          1"
		lstxt "                       2"
		lstxt "                       3"
		lstxt "                       4"
		lstxt "                       5"
		lstxt "                       6"
		lstxt "SOUND SELECT            "
		even


	if *-(levsel_line_count*levsel_line_length)<>LevelMenuText
		inform 2, "LevelMenuText does not match expected line count/length."
	endif
	if (LevSel_PtrsEnd-LevSel_Ptrs)/2<>levsel_line_count
		inform 2, "LevSel_Ptrs does not match expected line count."
	endif
	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Music playlist for the start of a level
; ---------------------------------------------------------------------------

PlayCurrentActMusic:
		move.b	(v_levelmusic).w,d0
		bra.w	QueueSound1
; End of function PlayCurrentActMusic


; ===========================================================================
; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; Level:
GM_Level:	; fading out from previous game mode
		bset	#7,(v_gamemode).w			; add $80 to screen mode (for pre level sequence)
		move.b	#bgm_Fade,d0				; queue music fade-out command
		bsr.w	QueueSound2				; fade out music
		bsr.w	ClearPLC				; clear any remaining PLC entries
		bsr.w	PaletteFadeOut				; fade out from the previous screen
; ---------------------------------------------------------------------------

		; load title cards, queue PLCs, setup screen, play music
		jsr	(TitleCards_LoadArt).l			; load level title card graphics

		moveq	#plcid_Main,d0				; load standard patterns
		bsr.w	AddPLC					; merged to have set 1 and 2

Level_ClrRam:
		clearRAM v_objspace				; clear object RAM
		clearRAM v_misc_variables			; clear various miscellaneous RAM
		clearRAM v_levelvariables			; clear level variables RAM (camera position, etc.)
		clearRAM v_timingandscreenvariables		; clear various timing and screen RAM (for animated tiles, etc.)
		clearRAM v_lvllayout

		disable_ints					; disable interrupts
		bsr.w	ClearScreen				; wipe the screen
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6)		; set sprite table address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		move.w	#$8004,(a6)				; 8-colour mode
		move.w	#$8720,(a6)				; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hblank_hreg).w		; set palette change position (for water)
		move.w	(v_hblank_hreg).w,(a6)			; write to VDP

		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.s	Level_LoadPal				; if not, branch
		move.w	#$8014,(a6)				; enable horizontal interrupts (HBlank)
		moveq	#0,d0					; clear d0
		move.b	(v_act).w,d0				; get current LZ act
		add.w	d0,d0					; double for word-based indexing
		lea	(WaterHeight).l,a1			; load water height array
		move.w	(a1,d0.w),d0				; get water height entries for current LZ act
		move.w	d0,(v_waterpos1).w			; set water height (actual)
		move.w	d0,(v_waterpos2).w			; set water height (ignoring surface sway)
		move.w	d0,(v_waterpos3).w			; set water height (target)
		clr.b	(v_wtr_routine).w			; clear water routine counter
		clr.b	(f_wtr_state).w				; clear water state
		move.b	#1,(f_water).w				; enable water

Level_LoadPal:
		move.w	#30,(v_air).w				; set Sonic's air timer to 30 seconds
		enable_ints					; enable interrupts

		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad					; ...directly to active palette (for title cards)
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ?
		bne.s	Level_GetBgm				; if not, branch
		tst.b	(v_lastlamp).w				; are we respawning from a checkpoint?
		beq.s	Level_GetBgm				; if not, branch
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w	; restore water state from checkpoint

Level_GetBgm:
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; transfer data up to this point
		bsr.w	LevelDataLoad				; unified to contain EVERYTHING
		bsr.w	PlayCurrentActMusic			; start playing music immediately
		move.l	#TitleCard,(v_titlecard+obID).w		; load title card object
; ---------------------------------------------------------------------------

Level_TtlCardLoop: ; move in title cards, stay on them until PLCs have finished
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		jsr	(ExecuteObjects).l			; execute title cards object
		jsr	(BuildSprites).l			; build sprites to show title cards

		lea	(v_titlecard).w,a0			; get title card elements
		moveq	#4-1,d1					; number of title card elements
.checkTtlCard:	move.w	obX(a0),d0				; get current position of a title card element
		cmp.w	card_mainX(a0),d0			; has this title card element reached its target position?
		bne.s	Level_TtlCardLoop			; if not, loop until it has
		lea	object_size(a0),a0			; next title card element
		dbf	d1,.checkTtlCard			; loop until every element has reached its target position

		tst.l	(v_plc_buffer).w			; have patterns been fully decompressed and loaded?
		bne.s	Level_TtlCardLoop			; if not, loop until they have
; ---------------------------------------------------------------------------

		; PLCs have finished, load/initialize remaining data
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		jsr	(Hud_Base).l				; load basic HUD graphics

Level_SkipTtlCard:
		bsr.w	InitRingFrame
		moveq	#palid_Sonic,d0				; load Sonic's palette to fade-in buffer
		bsr.w	PalLoad_Fade				; (doesn't actually do anything, the PalFadeIn_Alt call below skips the first palette line)
		bsr.w	LevelSizeLoad				; load level size and set default level boundaries

		bsr.w	DeformLayers				; initialize background deformation
		bset	#2,(v_fg_scroll_flags).w		; draw an extra column at the left side of the screen during level start
		bsr.w	LoadTilesFromStart			; fully draw the foreground and background once before fade-in
		bsr.w	LZWaterFeatures				; initialize water features if zone is LZ

		move.b	#id_VBlank_Levels,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		
		move.l	#SonicPlayer,(v_player+obID).w		; load Sonic object
		move.b	#-1,(v_draw_hud).w			; enable HUD drawing (but don't flash it yet)

Level_ChkDebug:
		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	Level_ChkWater				; if not, branch
		btst	#bitA,(v_jpadhold1).w			; is A button held?
		beq.s	Level_ChkWater				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

Level_ChkWater:
		move.w	#0,(v_jpadhold2).w			; clear button input states for Sonic player object
		move.w	#0,(v_jpadhold1).w			; clear actual button input states for controller 1

Level_LoadObj:
		cmpi.b	#id_SLZ,(v_zone).w			; are we in SLZ?
		bne.s	.nopylon				; if not, don't load pylon
		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.nopylon				; if none are free, branch
		move.l	#Pylon,obID(a1)				; manually load SLZ pylon
.nopylon:
		jsr	(ObjPosLoad_Init).l			; initialize object manager
		jsr	(RingsManager_Init).l			; initialize the S3K Rings Manager at level start
		jsr	(ExecuteObjects).l			; load objects that are already visible during fade-in
		jsr	(BuildSprites).l			; build sprites for objects before fade-in

		moveq	#0,d0					; clear d0
		tst.b	(v_lastlamp).w				; are we starting from a lamppost?
		bne.s	Level_SkipClr				; if yes, branch
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_lifecount).w			; clear extra lives flags when getting 100/200 rings

Level_SkipClr:
		move.b	d0,(f_timeover).w			; clear time over flag
		move.b	d0,(v_shield).w				; clear shield
		move.b	d0,(v_invinc).w				; clear invincibility
		move.b	d0,(v_shoes).w				; clear speed shoes
		move.w	d0,(v_debuguse).w			; exit debug mode if necessary
		move.w	d0,(f_restart).w			; clear level restart flag
		move.w	d0,(v_framecount).w			; reset frames since level start to 0
		bsr.w	OscillateNumInit			; initialize oscillation values
		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_ringcount).w			; update rings counter
		move.b	#1,(f_timecount).w			; update time counter

	if CheatsEnabled>=2
		move.b	#1,(f_debugmode).w			; enable debug mode automatically
	endif

Level_ChkWaterPal:
		cmpi.b	#id_LZ,(v_zone).w			; is level LZ/SBZ3?
		bne.s	Level_Delay				; if not, branch
		moveq	#palid_LZWater,d0			; palette $B (LZ underwater)
		cmpi.b	#act4,(v_act).w				; check if on act 4 (for SBZ3/LZ4)
		bne.s	Level_WtrNotSbz				; if not, branch
		moveq	#palid_SBZ3Water,d0			; palette $D (SBZ3 underwater)

Level_WtrNotSbz:
		bsr.w	PalLoad_Water				; load underwater palette to active palette

Level_Delay:
		move.w	#$202F,(v_pfade_start).w		; set to fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Playable_Alt
		move.b	#1,(v_draw_hud).w			; enable HUD drawing (and allow flashing)

; ---------------------------------------------------------------------------

		; level has faded in, make title cards move and enter main loop
		addq.b	#2,(v_ttlcardname+obRoutine).w		; make title card move (name)
		addq.b	#4,(v_ttlcardzone+obRoutine).w		; make title card move ("ZONE")
		addq.b	#4,(v_ttlcardact+obRoutine).w		; make title card move ("ACT")
		addq.b	#4,(v_ttlcardoval+obRoutine).w		; make title card move (blue oval)

Level_StartGame:
		bclr	#7,(v_gamemode).w			; subtract $80 from mode to end pre-level stuff
		; enter main loop...

; ---------------------------------------------------------------------------
; Main level loop (when all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_Levels,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	LZWaterFeatures				; apply water features if in Labyrinth Zone
		jsr	(ExecuteObjects).l			; execute all objects in object RAM

		tst.w	(f_restart).w				; is the level set to restart?
		bne.s	Level_CheckRestart			; if yes, branch to check restart condition
		bsr.w	DeformLayers				; scroll planes and do background deformation
		jsr	(BuildSprites).l			; build sprite table
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		jsr	(RingsManager).l			; execute S3K Rings Manager
		bsr.w	PaletteCycle				; run palette cycles
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers
		bsr.w	SignpostArtLoad				; check if sign post art needs to be loaded and lock left boundary

Level_CheckRestart:
		tst.w	(f_restart).w				; is the level set to restart?
		bne.w	GM_Level				; if yes, restart leve
		cmpi.b	#id_Level,(v_gamemode).w		; is game mode still set to level?
		beq.w	Level_MainLoop				; if yes, loop level game mode
		rts						; if game mode changed, return to MainGameLoop
; End of function GM_Level

; ===========================================================================
; >>> Misc level logic for specific circumstances
	include	"_inc/LZWaterFeatures.asm"


; ===========================================================================
; >>> Routines to set and update values that change on a fixed timer
	include	"_inc/Oscillatory Routines.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Queue ring frame graphics loading
; ---------------------------------------------------------------------------

InitRingFrame:
		st.b	(v_ani1_prev).w			; Make sure initial frame art loads
		st.b	(v_ani2_prev).w
		st.b	(v_ani3_prev).w

		cmpi.b	#id_Special,(v_gamemode).w
		beq.w	LoadRingFrame_SS
		; otherwise fall through to LoadRingFrame
; ---------------------------------------------------------------------------

LoadRingFrame:
		cmpi.b	#6,(v_player+obRoutine).w	; Is Sonic dead?
		bhs.s	.noring				; If so, branch

		moveq	#0,d1				; Get ring frame offset for regular rings
		move.b	(v_ani1_frame).w,d1
		cmp.b	(v_ani1_prev).w,d1		; Has it changed?
		beq.s	.noring				; If not, branch
		move.b	d1,(v_ani1_prev).w		; Mark frame's art as loaded

		lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
		addi.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Ring*tile_size,d2
		move.w	#$80/2,d3
		jsr	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.noring:
		tst.b	(v_gfxbigring).w		; Is a there a special stage ring?
		beq.s	.nossring			; If not, branch

		move.l	#Art_BigRing,d2			; Use normal special stage ring graphics
		cmpi.b	#1,(v_gfxbigring).w		; Should we be using them?
		beq.s	.loadssring			; If so, branch
		move.l	#Art_BigFlash,d2		; Use special stage ring flash graphics

.loadssring:
		moveq	#0,d1				; Get ring frame offset for special stage rings
		move.b	(v_ani2_frame).w,d1
		cmp.b	(v_ani2_prev).w,d1		; Has it changed?
		beq.s	.nossring			; If not, branch
		move.b	d1,(v_ani2_prev).w		; Mark frame's art as loaded

		lsl.l	#8,d1				; Each giant ring frame takes $800 bytes, so multiply by $800
		lsl.l	#3,d1
		add.l	d2,d1				; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Giant_Ring*tile_size,d2
		move.w	#$800/2,d3
		jsr	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.nossring:
		moveq	#0,d1				; Get ring frame offset for lost rings
		move.b	(v_ani3_frame).w,d1
		cmp.b	(v_ani3_prev).w,d1		; Has it changed?
		beq.s	.end				; If not, branch
		move.b	d1,(v_ani3_prev).w		; Mark frame's art as loaded

		lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
		add.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_Ring_Loss*tile_size,d2
		moveq	#$80/2,d3
		jmp	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)

.end:
		rts
; ---------------------------------------------------------------------------
		
LoadRingFrame_SS:
		moveq	#0,d1				; Get ring frame offset for regular rings
		move.b	(v_ani1_frame).w,d1
		cmp.b	(v_ani1_prev).w,d1		; Has it changed?
		beq.s	.noring				; If not, branch
		move.b	d1,(v_ani1_prev).w		; Mark frame's art as loaded

		lsl.l	#7,d1				; Each ring frame takes $80 bytes, so multiply by $80
		addi.l	#Art_Ring,d1			; Queue a DMA transfer for this ring frame
		move.w	#ArtTile_SS_Ring*tile_size,d2
		moveq	#$80/2,d3
		jmp	(QueueDMATransfer).l		; (or DMA_68KtoVRAM)
.noring:
		rts
; End of function InitRingFrame and LoadRingFrame


; ---------------------------------------------------------------------------
; Subroutine to change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

SynchroAnimate:
		bsr.w	LoadRingFrame

; Used for GHZ spiked log
Sync1:
		subq.b	#1,(v_ani0_time).w			; has first timer reached 0?
		bpl.s	Sync2					; if not, branch
		move.b	#12-1,(v_ani0_time).w			; reset first timer to 12 frames
		subq.b	#1,(v_ani0_frame).w			; go to next frame (backwards)
		andi.b	#7,(v_ani0_frame).w 			; limit to frames 0-7

; Used for rings
Sync2:
		subq.b	#1,(v_ani1_time).w
		bpl.s	Sync3
		move.b	#4-1,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#7,(v_ani1_frame).w

; Used for giant rings
Sync3:
		cmpi.b	#1,(v_gfxbigring).w
		bne.s	Sync4
		subq.b	#1,(v_ani2_time).w
		bpl.s	Sync4
		move.b	#4-1,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#7,(v_ani2_frame).w

; Used for bouncing rings
Sync4:
		tst.b	(v_ani3_time).w
		beq.s	SyncEnd
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#8,d0
		andi.w	#7,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

SyncEnd:
		rts						; return
; End of function SynchroAnimate

; ===========================================================================
; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine. Also locks left boundary.
; ---------------------------------------------------------------------------

SignpostArtLoad:
	;	tst.w	(v_debuguse).w				; is debug mode being used?
	;	bne.w	.return					; if yes, do not lock screen or load art
		cmpi.b	#act3,(v_act).w				; is this a third act?
		beq.s	.return					; if yes, don't load art (due to the boss fight)

		move.w	(v_screenposx).w,d0			; get current X-camera position
		move.w	(v_limitright2).w,d1			; get right level boundary
		subi.w	#$100,d1				; check for $100 pixels before the right boundary
		cmp.w	d1,d0					; has Sonic reached the right edge of the level?
		blt.s	.return					; if not, branch

		tst.b	(f_timecount).w				; has time already stopped from touching the signpost?
		beq.s	.return					; if yes, branch
		cmp.w	(v_limitleft2).w,d1			; has left boundary already been locked?
		beq.s	.return					; if yes, branch
		move.w	d1,(v_limitleft2).w			; lock left level boundary to current screen position
		moveq	#plcid_Signpost,d0			; load signpost, hidden points, giant ring flash patterns
		bra.w	NewPLC					; add to new PLC queue

.return:
		rts						; return
; End of function SignpostArtLoad


; ===========================================================================
; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

; SpecialStage:
GM_Special:		; white fade-out from previous game mode
		move.w	#sfx_EnterSS,d0				; set special stage entry sound
		bsr.w	QueueSound2				; play it
		bsr.w	PaletteWhiteOut				; fade-out to white
; ---------------------------------------------------------------------------

		; load special stage patterns
		disable_ints					; disable interrupts
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8004,(a6)				; 8-colour mode
		move.w	#$8A00+175,(v_hblank_hreg).w		; set HBlank counter to scanline 175 (even though horizontal interrupts aren't used here...)
		move.w	#$9011,(a6)				; 128-cell hscroll size
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe screen
		enable_ints					; enable interrupts

		fillVRAM 0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size ; clear nametables
		bsr.w	SS_BGLoad				; load background clouds/bubbles/birds/fish mappings
		moveq	#plcid_SpecialStage,d0			; load special stage patterns
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)
		bsr.w	InitRingFrame

		clearRAM v_objspace				; clear object RAM space
		clearRAM v_levelvariables			; clear various level variables
		clearRAM v_timingvariables			; clear various timing variables
		clearRAM v_ngfx_buffer				; clear Nemesis decompression buffer

		clr.b	(f_wtr_state).w				; clear water state
		clr.w	(f_restart).w				; clear level restart flag
		moveq	#palid_Special,d0			; load special stage palette...
		bsr.w	PalLoad_Fade				; ...into the palette fade-in buffer

		moveq	#0,d0					; clear d0	
		move.b	(v_lastspecial).w,d0			; get ID of special stage we've just entered
		move.b	SS_Music(pc,d0.w),d0			; find music ID from SS_Music list
		bsr.w	QueueSound1				; play correct special stage BG music
		bra.s	SS_ContinueSetup			; skip over music list

; ===========================================================================
SS_Music:
		dc.b bgm_SS	; stage 1
		dc.b bgm_SS	; stage 2
		dc.b bgm_SS	; stage 3
		dc.b bgm_SS	; stage 4
		dc.b bgm_SS	; stage 5
		dc.b bgm_SS	; stage 6
		;dc.b bgm_SS	; stage 7 (if you ever decide to add it...)
		even
; ===========================================================================

SS_ContinueSetup:
		jsr	(SS_Load).l				; load SS layout data (based on last stage entered and collected emeralds)

		move.w	#$2B0,(v_limittop2).w			; set top boundary
		move.w	#$7D0,(v_limitbtm2).w			; set bottom boundary
		move.w	#$2E0,(v_limitleft2).w			; set left boundary
		move.w	#$7A0,(v_limitright2).w			; set right boundary

		move.l	#0,(v_screenposx).w			; reset X-camera position
		move.l	#0,(v_screenposy).w			; reset Y-camera position
		move.l	#SonicSpecial,(v_player+obID).w		; load special stage Sonic object
		move.b	#-1,(v_ssangleprev).w			; fill previous angle with obviously false value to force initial update
		bsr.w	PalCycle_SS				; initialize palette cycle and background for fade-in
		clr.w	(v_ssangle).w				; set stage angle to "upright"
		move.w	#ss_rotatespeed,(v_ssrotate).w		; set initial stage rotation speed ($40, see object 09)

		clr.w	(v_rings).w				; clear rings
		clr.b	(v_lifecount).w				; clear extra lives flags when getting 100/200 rings

		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	SS_NoDebug				; if not, branch
		btst	#bitA,(v_jpadhold1).w			; is A button held?
		beq.s	SS_NoDebug				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

SS_NoDebug:
		enable_display					; enable screen out-put
		bsr.w	PaletteWhiteIn				; fade-in from white

; ---------------------------------------------------------------------------
; Special Stage main loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame				; handle pausing the game when pressing start
		move.b	#id_VBlank_SpecialStage,(v_vblank_routine).w ; set VBlank routine to $0A
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; copy controller 1 inputs to Sonic player object inputs

		jsr	(ExecuteObjects).l			; execute Special Stage object
		jsr	(BuildSprites).l			; build sprites
		bsr.w	LoadRingFrame_SS
		jsr	(SS_ShowLayout).l			; render Special Stage layout
		bsr.w	SS_BGAnimate				; animate Special Stage background

SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w		; is game mode still the Special Stage?
		beq.w	SS_MainLoop				; if yes, loop game mode
; ---------------------------------------------------------------------------

		; Exiting Special Stage...
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		cmpi.w	#id_FZ+1,(v_zone_act).w			; is level number higher than FZ (0502)?
		blo.s	SS_Finish				; if not, branch
		clr.w	(v_zone_act).w				; set to GHZ1 (possibly as a failsafe)

SS_Finish:
		move.w	#60,(v_generictimer).w			; run fade-out for one second
		move.w	#$003F,(v_pfade_start).w		; set palette fade-out position and size
		clr.w	(v_palchgspeed).w			; do first palette brightening immediately

SS_FinLoop:
		move.b	#id_VBlank_Continue,(v_vblank_routine).w ; set VBlank routine to $16 (uses the same one as the continue screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		move.w	(v_jpadhold1).w,(v_jpadhold2).w		; continue copying 1P inputs to Sonic object (even though controls are locked...)
		jsr	(ExecuteObjects).l			; continue executing objects during fade-out
		jsr	(BuildSprites).l			; continue building sprites during fade-out
		jsr	(SS_ShowLayout).l			; continue rendering Special Stage layout
		bsr.w	SS_BGAnimate				; continue to animate background

		subq.w	#1,(v_palchgspeed).w			; decrement palette fade-out delay
		bpl.s	SS_FinLoop_NoBrighten			; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette fade-out delay
		bsr.w	WhiteOut_ToWhite			; brighten palette further

; loc_47D4:
SS_FinLoop_NoBrighten:
		tst.w	(v_generictimer).w			; has fade-out loop finished?
		bne.s	SS_FinLoop				; if not, loop
; ---------------------------------------------------------------------------

		; Fade-out done, load Special Stage Results screen
		disable_ints					; disable interrupts
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		bsr.w	ClearScreen				; wipe screen

		jsr	(SpecStagResults_LoadArt).l		; load SSR title card graphics

		jsr	(Hud_Base).l				; load basic HUD graphics
		enable_ints					; enable interrupts

		moveq	#palid_SSResult,d0			; load Special Stage results screen palette...
		bsr.w	PalLoad					; ...directly to active palette
		moveq	#plcid_SSResult,d0			; load Special Stage results screen patterns
		bsr.w	AddPLC					; add to PLC queue

		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_endactbonus).w			; update ring bonus counter
		move.w	(v_rings).w,d0				; get rings collected in Special Stage
		mulu.w	#10,d0					; award 100 bonus points per collected ring
		move.w	d0,(v_ringbonus).w			; set rings bonus

		move.w	#bgm_GotThrough,d0			; play end-of-level music
		jsr	(QueueSound2).l	 			; play it

		clearRAM v_objspace				; clear object RAM

		move.l	#SSResult,(v_ssrescard+obID).w		; load Special Stage Results screen object
; ---------------------------------------------------------------------------

SS_NormalExit:		; Special Stage results screen loop
		bsr.w	PauseGame				; allow pausing during the results screen
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; set VBlank routine to $0C
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		jsr	(ExecuteObjects).l			; execute SSR objects
		jsr	(BuildSprites).l			; build sprites
		tst.w	(f_restart).w				; has the SSR object signaled that we can exit?
		beq.s	SS_NormalExit				; if not, loop results screen
; ---------------------------------------------------------------------------

		; Exit Special Stage normally
		move.w	#sfx_EnterSS,d0				; play special stage exit sound
		bsr.w	QueueSound2 				; play it
		bra.w	PaletteWhiteOut				; fade-out to white
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w			; set game mode to Sega screen
		rts						; return to MainGameLoop
; ENd of function GM_Special

; ===========================================================================

; >>> Special Stage background drawing and palette cycle logic
	include	"_inc/Special Stage Background & Palette Cycle.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

; ContinueScreen:
GM_Continue:
		bsr.w	PaletteFadeOut				; fade-out palette from previous game mode

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8004,(a6)				; 8 colour mode
		move.w	#$8700,(a6)				; background colour
		bsr.w	ClearScreen				; wipe screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_Continue,d0			; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		moveq	#10,d1					; draw continue screen countdown to start with digits 10
		jsr	(ContScrCounter).l			; initialize countdown

		moveq	#palid_Continue,d0			; load continue screen palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer
		move.b	#bgm_Continue,d0			; play continue screen music
		bsr.w	QueueSound1				; play it

		move.w	#(11*60)-1,(v_generictimer).w		; show continue screen for 11 seconds in total

		clr.l	(v_screenposx).w			; clear X-camera position
		move.l	#$1000000,(v_screenposy).w		; set Y-camera position to $100

		move.l	#ContSonic,(v_player+obID).w		; load continue screen Sonic object
		move.l	#ContScrItem,(v_continuetext+obID).w	; load continue screen objects (text and misc elements)
		move.l	#ContScrItem,(v_continuelight+obID).w	; load floor light object Sonic is laying on
		move.w	#spr_prio3,(v_continuelight+obPriority).w	; set priority to be behind Sonic
		move.b	#4,(v_continuelight+obFrame).w		; set correct frame for the light
		move.l	#ContScrItem,(v_continueicon+obID).w	; load continue icons object
		move.b	#4,(v_continueicon+obRoutine).w		; set to continue icons routine

		jsr	(ExecuteObjects).l			; initialize objects
		jsr	(BuildSprites).l			; build sprites
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable screen output
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#id_VBlank_Continue,(v_vblank_routine).w ; set VBlank routine to $16
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		cmpi.b	#6,(v_player+obRoutine).w		; has continue screen Sonic object signaled that we want to continue?
		bhs.s	Cont_NoCountdown			; if yes, stop updating countdown timer

		disable_ints					; disable interrupts
		move.w	(v_generictimer).w,d1			; get remaining time for countdown (in frames)
		divu.w	#60,d1					; divide by 60 to get remaining time in seconds
		andi.l	#$F,d1					; mask off remainder and anything except the end digit
		jsr	(ContScrCounter).l			; update countdown digits
		enable_ints					; enable interrupts again
; loc_4DF2:
Cont_NoCountdown:
		jsr	(ExecuteObjects).l			; execute continue screen objects
		jsr	(BuildSprites).l			; build sprites

		cmpi.w	#320+64,(v_player+obX).w		; has Sonic run off screen after using a continue?
		bhs.s	Cont_GotoLevel				; if yes, return to level and continue game
		cmpi.b	#6,(v_player+obRoutine).w		; has continue screen Sonic object signaled that we want to continue?
		bhs.s	Cont_MainLoop				; if yes, Sonic is still running off-screen, loop until he is gone
		tst.w	(v_generictimer).w			; has countdown run out?
		bne.w	Cont_MainLoop				; if not, loop game mode

		; Continue wasn't used. Game Over.
		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen
		rts						; return to MainGameLoop
; ===========================================================================

Cont_GotoLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; clear d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastlamp).w			; clear lamppost count
		subq.b	#1,(v_continues).w			; subtract 1 from continues
		rts						; return to MainGameLoop
; End of function GM_Continue

; ===========================================================================

; >>> Objects for the continue screen
	include	"_incObj/80, 81 Continue Screen Elements and Sonic.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill Zone. This is essentially a stripped-down
; copy-paste of regular levels with lots of hardcoding.
; ---------------------------------------------------------------------------

; EndingSequence:
GM_Ending:
		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		clearRAM v_objspace				; clear object RAM
		clearRAM v_misc_variables			; clear various miscellaneous RAM
		clearRAM v_levelvariables			; clear level variables RAM (camera position, etc.)
		clearRAM v_timingandscreenvariables		; clear various timing and screen RAM (for animated tiles, etc.)

		disable_ints					; disable interrupts
		disable_display					; disable screen output
		bsr.w	ClearScreen				; wipe the screen
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6)		; set sprite table address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		move.w	#$8004,(a6)				; 8-colour mode
		move.w	#$8720,(a6)				; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hblank_hreg).w		; set palette change position (for water)
		move.w	(v_hblank_hreg).w,(a6)			; write to VDP
		move.w	#30,(v_air).w				; replenish air

		move.w	#id_EndZ_good,(v_zone_act).w		; set to good ending by default (level number 600, extra flowers)
		cmpi.b	#ss_emeralds_num,(v_emeralds).w		; do you have all 6 emeralds?
		beq.s	End_LoadData				; if yes, use good ending
		move.w	#id_EndZ_bad,(v_zone_act).w		; otherwise, set to bad ending (level number 601, no extra flowers)

End_LoadData:
		moveq	#plcid_Ending,d0			; load ending sequence patterns (GHZ art, animals, etc.)
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)
		jsr	(Hud_Base).l				; load basic HUD graphics
		bsr.w	LevelSizeLoad				; load level size and set default level boundaries
		bsr.w	DeformLayers				; initialize background deformation
		bset	#2,(v_fg_scroll_flags).w		; draw an extra column at the left side of the screen during level start
		bsr.w	LevelDataLoad				; load block mappings and palettes
		bsr.w	LoadTilesFromStart			; fully draw the foreground and background once before fade-in
		enable_ints					; enable interrupts

		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer

		tst.b	(f_debugcheat).w			; has debug cheat been entered?
		beq.s	End_LoadSonic				; if not, branch
		btst	#bitA,(v_jpadhold1).w			; was button A held while entering ending sequence?
		beq.s	End_LoadSonic				; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode

End_LoadSonic:
		move.l	#SonicPlayer,(v_player+obID).w		; load Sonic object
		bset	#0,(v_player+obStatus).w		; make Sonic face left
		move.b	#1,(f_lockctrl).w			; lock controls to keep simulating D-Pad
		move.w	#(btnL<<8),(v_jpadhold2).w		; simulate holding down the left D-Pad button to move Sonic (and clear v_jpadpress2)
		move.w	#-$600,(v_player+obInertia).w		; set Sonic's initial speed (speed cap immediately limits this to -$600)

		move.b	#1,(v_draw_hud).w			; enable HUD drawing
		jsr	(ObjPosLoad_Init).l			; initialize object manager
		jsr	(ExecuteObjects).l			; execute all objects in object RAM
		jsr	(BuildSprites).l			; build sprite table

		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_lifecount).w			; clear extra lives flags when getting 100/200 rings
		move.b	d0,(v_shield).w				; clear shield
		move.b	d0,(v_invinc).w				; clear invincibility
		move.b	d0,(v_shoes).w				; clear speed shoes
		move.w	d0,(v_debuguse).w			; exit debug mode if necessary
		move.w	d0,(f_restart).w			; clear level restart flag
		move.w	d0,(v_framecount).w			; reset frames since level start to 0
		bsr.w	OscillateNumInit			; initialize oscillation values
		move.b	#1,(f_scorecount).w			; update score counter
		move.b	#1,(f_ringcount).w			; update rings counter
		move.b	#0,(f_timecount).w			; stop time counter for the ending sequence

		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		bsr.w	PlayCurrentActMusic
		enable_display					; enable screen output
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Ending sequence main loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame				; allow pausing during the ending sequence
		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		bsr.w	End_MoveSonic				; control simulated button inputs for Sonic during the cutscene

		jsr	(ExecuteObjects).l			; execute all objects in object RAM
		bsr.w	DeformLayers				; scroll planes and do background deformation
		jsr	(BuildSprites).l			; build sprite table
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		bsr.w	PaletteCycle				; run palette cycles
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers

		cmpi.b	#id_Ending,(v_gamemode).w		; is game mode still set to ending sequence?
		beq.s	End_ChkEmerald				; if yes, branch

End_GoToCredits:
		move.b	#id_Credits,(v_gamemode).w		; change game mode to credits
		move.b	#bgm_Credits,d0				; play credits music
		bsr.w	QueueSound2				; play it
		move.w	#0,(v_creditsnum).w			; set credits page number to 0 ("Sonic Team Staff")
		rts						; return to MainGameLoop
; ===========================================================================

End_ChkEmerald:
		tst.w	(f_restart).w				; is level restart flag set? (set while emeralds are spinning in the good ending)
		beq.w	End_MainLoop				; if not, loop ending sequence game mode normally
; ---------------------------------------------------------------------------

		; prepare slow white-in as the emeralds keep spinning in good ending
		clr.w	(f_restart).w				; clear level restart flag
		move.w	#$003F,(v_pfade_start).w		; prepare fade position and size
		clr.w	(v_palchgspeed).w			; trigger the first brightening immediately
; ---------------------------------------------------------------------------


End_AllEmlds:		; during the slow white-in
		bsr.w	PauseGame				; still allow pausing the game
		move.b	#id_VBlank_Ending,(v_vblank_routine).w	; set VBlank routine to $18
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		jsr	(ExecuteObjects).l			; continue executing objects during white-in
		bsr.w	DeformLayers				; continue upgrading background deformation during white-in
		jsr	(BuildSprites).l			; continue building sprites during white-in
		jsr	(ObjPosLoad).l				; continue running object manager during white-in
		bsr.w	OscillateNumDo				; continue advancing oscillation values during white-in
		bsr.w	SynchroAnimate				; continue advancing animation timers during white-in

		subq.w	#1,(v_palchgspeed).w			; decrement palette white-in delay
		bpl.s	End_SlowFade				; if time remains, branch
		move.w	#2,(v_palchgspeed).w			; reset palette white-in delay
		bsr.w	WhiteOut_ToWhite			; brighten palette further

End_SlowFade:
		cmpi.b	#6,(v_player+obRoutine).w		; has Sonic died?
		bhs.s	End_GoToCredits				; if yes, abort sequence, go straight to credits
		tst.w	(f_restart).w				; has flag been set signaling that the emeralds have disappeared?
		beq.w	End_AllEmlds				; if not, loop
; ---------------------------------------------------------------------------

		; screen is fully white and emeralds are gone, update level layout with extra flowers and fade back in
		clr.w	(f_restart).w				; clear level restart flag
		move.w	#$2E2F,(v_lvllayout_fg+layout_row).w	; swap chunks in level layout to the variants with flowers (chunks $2E / $2F) (row 1 / column 0)

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_screenposx).w,a3			; get current foreground X position
		lea	(v_lvllayout_fg).w,a4			; get location in level layout RAM where foreground is stored
		move.w	#$4000,d2				; set VRAM write command to vram_fg nametable start address
		bsr.w	DrawChunks				; update drawn chunks to show the new flowers

		moveq	#palid_Ending,d0			; reload ending palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		bsr.w	PaletteWhiteIn				; fade-in from white

		bra.w	End_MainLoop				; return to main ending sequence loop for the rest of the scene
; End of function GM_Ending

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence.
; 
; Many aspects of the game use the concept of a state machine.
; If you are interested and want to learn more, these are Mealy and Moore machines
; which have plenty of resources to teach you! This subroutine is a Moore machine.
; Once you understand these concepts, Sonic 1's game logic will make a lot more sense to you!
; ---------------------------------------------------------------------------

End_MoveSonic:
		move.b	(v_sonicend).w,d0			; get ending cutscene routine number
		bne.s	End_MoveSon2				; if it's non-zero, branch to second script

		cmpi.w	#(320/2)-16,(v_player+obX).w		; has Sonic passed $90 on the X-axis (from the right)?
		bhs.s	End_MoveSonExit				; if not, branch

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		move.w	#(btnR<<8),(v_jpadhold2).w		; simulate holding down the right D-Pad button to trigger skidding animation
		rts						; return
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0					; subtract 2 from cutscene routine number
		bne.s	End_MoveSon3				; if it's still non-zero, branch to third script

		cmpi.w	#320/2,(v_player+obX).w			; has Sonic passed $A0 on the X-axis (from the left)?
		blo.s	End_MoveSonExit				; if not, branch

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		moveq	#0,d0					; clear d0
		move.b	d0,(f_lockctrl).w			; unlock controls (no effect, see below)
		move.w	d0,(v_jpadhold2).w			; clear simulated button inputs to stop Sonic moving
		move.w	d0,(v_player+obInertia).w		; clear ground speed to make Sonic stop immediately
		move.b	#$81,(f_playerctrl).w			; set control ignore and disabled object interaction flags

		move.b	#fr_Wait2,(v_player+obFrame).w		; force Sonic to a specific waiting frame
		move.w	#(id_Wait<<8)+id_Wait,(v_player+obAnim).w ; use "standing" animation and prevent it from getting immediately restarted
		move.b	#3,(v_player+obTimeFrame).w		; set a bit of an animation interval so Sonic keeps looking when he gets replaced on the next frame
		rts						; return
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0					; subtract 2 from cutscene routine number
		bne.s	End_MoveSonExit				; if it's still non-zero, the below code has already run, branch to do nothing anymore

		addq.b	#2,(v_sonicend).w			; advance ending cutscene routine number
		move.w	#320/2,(v_player+obX).w			; force Sonic to the middle of the screen
		move.l	#EndSonic,(v_player+obID).w		; replace real Sonic object with a fake ending sequence Sonic object
		clr.w	(v_player+obRoutine).w			; reset routine counter to initialize fake ending Sonic

End_MoveSonExit:
		rts						; return
; End of function End_MoveSonic

; ===========================================================================

; >>> Objects on the ending sequence
	include	"_incObj/87, 88, 89 Ending Sequence Sonic, Emeralds, Logo.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

; CreditsScreen:
GM_Credits:
		; fading out from previous game mode (music gets already started before this)
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8004,(a6)				; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		move.w	#$9200,(a6)				; window vertical position
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8720,(a6)				; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_Credits,d0			; load patterns through PLC list
		bsr.w	QuickPLC				; decompress PLC list now and return once done

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer

		move.l	#CreditsText,(v_credits+obID).w		; load credits text object
		jsr	(ExecuteObjects).l			; execute objects to load credits text object
		jsr	(BuildSprites).l			; build sprites for the credits text object
; ---------------------------------------------------------------------------

		; fade-in palette and enter wait loop
		move.w	#120,(v_generictimer).w			; display a single credits page for 2 seconds
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; Credits page main loop (only shown for 2 seconds)
; ---------------------------------------------------------------------------

Cred_WaitLoop:		; while a credits page is displayed and graphics are getting decompressed
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04 (uses the same one as the title screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished

		tst.w	(v_generictimer).w			; have at least 2 seconds elapsed?
		bne.s	Cred_WaitLoop				; if not, loop
; ---------------------------------------------------------------------------

		; credits page has finished displaying, go to next game mode
		addq.w	#1,(v_creditsnum).w			; increase credits page number for next time
		cmpi.w	#9,(v_creditsnum).w			; are we past the final credits page?
		beq.w	TryAgainEnd				; if yes, go to Try Again/End screen instead
		rts						; otherwise, return to MainGameLoop
; End of function GM_Credits

; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" screen (bad ending) and "END" screen (good ending). This is
; essentially a full game mode, although it's not called from the main
; game mode array, but rather directly from the credits.
; ---------------------------------------------------------------------------

; TryAgainScreen:
TryAgainEnd:		; fading out from previous game mode
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading patterns
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#$8004,(a6)				; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64-cell hscroll size
		move.w	#$9200,(a6)				; window vertical position
		move.w	#$8B03,(a6)				; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#$8720,(a6)				; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen

		clearRAM v_objspace				; clear object RAM

		moveq	#plcid_TryAgain,d0			; load "TRY AGAIN" and "END" patterns
		bsr.w	QuickPLC				; execute PLCs immediately (no queue)

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Ending,d0			; load ending palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		clr.w	(v_palette_fading_line_3).w		; ensure the backdrop color is black

		move.l	#EndEggman,(v_endeggman+obID).w		; load end Eggman object
		jsr	(ExecuteObjects).l			; execute objects to load end objects
		jsr	(BuildSprites).l			; build sprites for end objects
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		move.w	#1800,(v_generictimer).w		; automatically return to Sega screen after 30 seconds
		bsr.w	PaletteFadeIn				; fade-in palette

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END" screen main loop
; ---------------------------------------------------------------------------

TryAg_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04 (uses the same one as the title screen)
		bsr.w	WaitForVBlank				; wait until VBlank has finished

		jsr	(ExecuteObjects).l			; update end objects
		jsr	(BuildSprites).l			; build sprites for end objects

		andi.b	#btnStart,(v_jpadpress1).w		; has Start button been pressed?
		bne.s	TryAg_Exit				; if yes, exit end screen
		tst.w	(v_generictimer).w			; have 30 seconds elapsed?
		beq.s	TryAg_Exit				; if yes, exit end screen
		cmpi.b	#id_Credits,(v_gamemode).w		; is game mode still set to show the end screen?
		beq.s	TryAg_MainLoop				; if yes, loop
; ---------------------------------------------------------------------------

TryAg_Exit:		; exit end screen and restart the gam
		move.b	#id_Sega,(v_gamemode).w			; set game mode to Sega screen
		rts						; return to MainGameLoop
; End of function TryAgainEnd
; ===========================================================================

; >>> Objects on final screen
	include	"_incObj/8B, 8C Try Again, End Eggman, End Emeralds.asm"


; ===========================================================================
; ---------------------------------------------------------------------------
; >> END OF MAIN GAME LOGIC - Everything below this point is file includes <<
; ---------------------------------------------------------------------------
; ===========================================================================


; ===========================================================================
; >>> Level rendering, loading, and updating
		include	"_inc/LevelSizeLoad & BgScrollSpeed.asm" ; merged with "LevelSizeLoad & BgScrollSpeed (JP1).asm"
		include	"_inc/DeformLayers.asm"
		include	"_inc/Level Drawing.asm" ; includes LevelHeaders.asm
		include	"_inc/LevelDataLoad.asm" ; includes LevelDataLoad, LevelLayoutLoad, LoadZoneTiles
		include	"_inc/DynamicLevelEvents.asm"


; ===========================================================================
; >>> Various level objects
		include	"_incObj/11 GHZ Bridge.asm"
		include	"_incObj/15 Swinging Platforms.asm" ; includes "MvSonicOnPtfm" subroutine
		include	"_incObj/17 GHZ Spiked Pole Helix.asm"
		include	"_incObj/18 Platforms.asm"
		include	"_incObj/1A, 53 Collapsing Ledges and Floors.asm" ; includes "SlopeObject_AssumeStoodOn" subroutine
		include	"_incObj/1C GHZ, SYZ Scenery.asm"
		include	"_incObj/2A SBZ Small Door.asm"


; ===========================================================================
; >>> Badniks, explosions, and Badnik-related objects
		include	"_incObj/1E, 20 Badnik - Ball Hog and Cannonball.asm"
		include	"_incObj/27, 3F Explosions.asm"
		include	"_incObj/28, 29 Animals and Points.asm"
		include	"_incObj/1F Badnik - Crabmeat.asm"
		include	"_incObj/22, 23 Badnik - Buzz Bomber and Missile.asm"


; ===========================================================================
; >>> Rings
		include	"_incObj/_RingsManager.asm"
		include	"_incObj/25, 37 Rings.asm"
		include	"_incObj/4B, 7C Giant Ring and Flash.asm"


; ===========================================================================
; >>> Monitors
		include	"_incObj/26, 2E Monitors and Power-Ups.asm"


; ===========================================================================
; >>> Title screen objects (includes AnimateSprite)
		include	"_incObj/0E, 0F Title Screen - Sonic, Press Start, TM.asm"

; ===========================================================================
; >>> More Badniks and level objects
		include	"_incObj/10 Particle.asm"
		include	"_incObj/2B Badnik - Chopper.asm"
		include	"_incObj/2C Badnik - Jaws.asm"
		include	"_incObj/2D Badnik - Burrobot.asm"
		include	"_incObj/2F, 35 MZ Large Grassy Platforms and Burning Grass.asm"
		include	"_incObj/30 MZ Large Green Glass Blocks.asm"
		include	"_incObj/31 MZ Chained Stompers.asm"
		include	"_incObj/32 Button.asm"
		include	"_incObj/33 MZ, LZ Pushable Blocks.asm"


; ===========================================================================
; >>> Title card objects
		include	"_incObj/34 Title Cards.asm"
		include	"_incObj/39 Game Over.asm"
		include	"_incObj/3A Got Through Card.asm"
		include	"_incObj/7E, 7F Special Stage Results and Chaos Emeralds.asm"
Map_Over:	include	"_maps/Game Over.asm"


; ===========================================================================
; >>> More level objects
		include	"_incObj/36 Spikes.asm"
		include	"_incObj/3B GHZ Purple Rock.asm"
		include	"_incObj/49 GHZ Waterfall Sound.asm"
		include	"_incObj/3C GHZ, SLZ Smashable Wall.asm" ; includes SmashObject


; ===========================================================================
; Subroutines to run, render, and update objects
		include	"_incObj/sub AnimateSprite.asm"
		include	"_incObj/_ExecuteObjects.asm"
		include	"_incObj/_ObjectPointers.asm"
		include	"_incObj/sub ObjectFall & SpeedToPos.asm"
		include	"_incObj/sub DeleteObject.asm"
		include	"_incObj/_BuildSprites.asm"
		include	"_incObj/sub ChkObjectVisible.asm"
		include	"_incObj/_ObjPosLoad.asm"
		include	"_incObj/sub FindFreeObj.asm"


; ===========================================================================
; >>> More level objects
		include	"_incObj/41 Springs.asm"
		include	"_incObj/42 Badnik - Newtron.asm"
		include	"_incObj/43 Badnik - Roller.asm"
		include	"_incObj/44 GHZ Edge Walls.asm"
		include	"_incObj/13, 14 MZ, SLZ Fire Balls and Maker.asm"
		include	"_incObj/6D SBZ Flamethrower.asm"
		include	"_incObj/46 MZ Bricks.asm"
		include	"_incObj/12 SYZ Search Light.asm"
		include	"_incObj/47 SYZ Bumper.asm"
		include	"_incObj/0D Signpost.asm" ; includes "GotThroughAct" subroutine
		include	"_incObj/4C, 4D MZ Lava Geyser and Maker.asm"
		include	"_incObj/4E MZ Wall of Lava.asm"
		include	"_incObj/54 MZ Invisible Lava Tag.asm"
		include	"_incObj/40 Badnik - Moto Bug.asm"
		include	"_incObj/50 Badnik - Yadrin.asm"
		include	"_incObj/sub SolidObject.asm"
		include	"_incObj/51 MZ Smashable Green Block.asm"
		include	"_incObj/52 Moving Blocks.asm"
		include	"_incObj/55 Badnik - Basaran.asm"
		include	"_incObj/56 SYZ, SLZ Floating Blocks and LZ Doors.asm"
		include	"_incObj/57 SYZ, LZ Spiked Ball and Chain.asm"
		include	"_incObj/58 SYZ Big Spiked Ball.asm"
		include	"_incObj/59 SLZ Elevators.asm"
		include	"_incObj/5A SLZ Circling Platform.asm"
		include	"_incObj/5B SLZ Staircase.asm"
		include	"_incObj/5C SLZ Foreground Pylon.asm"
		include	"_incObj/0B LZ Pole that Breaks.asm"
		include	"_incObj/0C LZ Flapping Door.asm"
		include	"_incObj/71 Invisible Solid Barriers.asm"
		include	"_incObj/5D SLZ Fan.asm"
		include	"_incObj/5E SLZ Seesaw.asm"
		include	"_incObj/5F Badnik - Walking Bomb.asm"
		include	"_incObj/60 Badnik - Orbinaut.asm"
		include	"_incObj/16 LZ Harpoon.asm"
		include	"_incObj/61 LZ Blocks.asm"
		include	"_incObj/62 LZ Gargoyle.asm"
		include	"_incObj/63 LZ Conveyor.asm"
		include	"_incObj/64 LZ Air Bubbles.asm"
		include	"_incObj/65 LZ Waterfalls.asm"


; ===========================================================================
; >>> Main Sonic player object
		include	"_incObj/01 Sonic.asm"
		include	"_incObj/Sonic ReactToItem.asm"
		include	"_incObj/05 SpinDust.asm"
		include	"_incObj/06 AfterImage.asm"


; ===========================================================================
; >>> Various unique objects
		include	"_incObj/0A LZ Drowning Countdown.asm" ; includes ResumeMusic
		include	"_incObj/38 Shield and Invincibility.asm"
		include	"_incObj/08 LZ Water Splash.asm"


; ===========================================================================
; >>> Collision subroutines for Sonic and other objects
		include	"_incObj/Sonic AnglePos.asm"
		include	"_incObj/sub FindNearestTile & FindFloor & FindWall.asm"
		include	"_incObj/Sonic Collision.asm"


; ===========================================================================
; >>> SBZ level objects
		include	"_incObj/66 SBZ Rotating Junction.asm"
		include	"_incObj/67 SBZ Running Disc.asm"
		include	"_incObj/68 SBZ Conveyor Belt.asm"
		include	"_incObj/69 SBZ Spinning Platforms and Trapdoors.asm"
		include	"_incObj/6A SBZ Saws and Pizza Cutters.asm"
		include	"_incObj/6B SBZ Stomper and Sliding Door.asm"
		include	"_incObj/6C SBZ Vanishing Platforms.asm"
		include	"_incObj/6E SBZ Electrocuter.asm"
		include	"_incObj/6F SBZ Spin Platform Conveyor.asm"
		include	"_incObj/70 SBZ Girder Block.asm"
		include	"_incObj/72 SBZ Teleporter.asm"

; ===========================================================================
; >>> Misc objects
		include	"_incObj/78 Badnik - Caterkiller.asm"
		include	"_incObj/79 Lamppost.asm"
		include	"_incObj/7D Hidden Bonuses.asm"
		include	"_incObj/8A Credits and Sonic Team Presents.asm"


; ===========================================================================
; >>> Bosses and related objects
		include	"_incObj/3D, 48 Boss - GHZ Main and Wrecking Ball.asm" ; includes "BossDefeated" and "BossMove" subroutines
		include	"_anim/Eggman.asm"
Map_Eggman:	include	"_maps/Eggman.asm"
Map_BossItems:	include	"_maps/Boss Items.asm"
		include	"_incObj/77 Boss - LZ Main.asm"
		include	"_incObj/73, 74 Boss - MZ Main and Fire.asm"
		include	"_incObj/7A, 7B Boss - SLZ Main and Spike Balls.asm"
		include	"_incObj/75, 76 Boss - SYZ Main and Blocks.asm"
		include	"_incObj/82, 83 SBZ Eggman Cutscene and Crumbling Floor.asm"
		include	"_incObj/85,84,86 Boss - FZ Main, Cylinders, and Plasma Balls.asm"
		include	"_incObj/3E Prison Capsule.asm"


; ===========================================================================
; >>> Special Stage rendering and objects
		; The following includes "SS_ShowLayout", "SS_AniWallsRings",
		; "SS_FindFreeAnimationSlot", "SS_AniItems", and "SS_Load"
		include	"_inc/Special Stage Loading & Drawing.asm"

		include	"_inc/Special Stage Mappings & VRAM Pointers.asm"
Map_SS_Shared:	include	"_maps/SS Shared Block.asm"
Map_SS_Glass:	include	"_maps/SS Glass Block.asm"
Map_SS_Up:	include	"_maps/SS UP Block.asm"
Map_SS_Down:	include	"_maps/SS DOWN Block.asm"
Map_SS_Chaos:	include	"_maps/SS Chaos Emeralds.asm"
		include	"_incObj/09 Sonic in Special Stage.asm"


; ===========================================================================
; >>> Subroutine for in-place level animations in VRAM
		include	"_inc/AnimateLevelGfx.asm"


; ===========================================================================
; >>> HUD objects
Map_HUD:	include	"_maps/HUD.asm"
		include	"_incObj/sub AddPoints.asm"
		include	"_inc/HUD Update.asm" ; includes "ContScrCounter" subroutine

Art_Hud:	binclude "artunc/HUD Numbers.unc" ; 8x16 pixel numbers on HUD
		binclude "artunc/HUD Numbers Separators.unc" ; ' and " separators for the time
		even

Art_LivesNums:	binclude "artunc/Lives Counter Numbers.unc" ; 8x8 pixel numbers on lives counter
		even


; ===========================================================================
; >>> Debug Mode
		include	"_incObj/DebugMode.asm"


; ===========================================================================
; >>> Level definitions
		include	"_inc/Pattern Load Cues.asm"


; ===========================================================================

; ---------------------------------------------------------------------------
; >> END OF PRIMARY INCLUDES - Everything below this point is art includes <<
; ---------------------------------------------------------------------------

; ===========================================================================
; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Sega screen
; ---------------------------------------------------------------------------
KosPM_SegaLogo:	binclude	"artkospm/Sega Logo.kospm" ; large Sega logo
		even
Eni_SegaLogo:	binclude	"tilemaps/Sega Logo.eni" ; large Sega logo (mappings)
		even

; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Title screen
; ---------------------------------------------------------------------------
Eni_Title:	binclude	"tilemaps/Title Screen.eni" ; title screen foreground (mappings)
		even
KosPM_TitleFg:	binclude	"artkospm/Title Screen Foreground.kospm"
		even
KosPM_TitleSonic:	binclude	"artkospm/Title Screen Sonic.kospm"
		even
KosPM_TitleTM:	binclude	"artkospm/Title Screen TM.kospm"
		even
KosPM_TitlePSB:	binclude	"artkospm/Title Screen PSB.kospm"
		even
Eni_JapNames:	binclude	"tilemaps/Hidden Japanese Credits.eni" ; Japanese credits (mappings)
		even
KosPM_JapNames:	binclude	"artkospm/Hidden Japanese Credits.kospm"
		even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Sonic
; ---------------------------------------------------------------------------
Map_Sonic:	include	"_maps/Sonic.asm"

SonicDynPLC:	include	"_maps/Sonic - Dynamic Gfx Script.asm"

Art_Sonic:	binclude	"artunc/Sonic.unc"
		even

Art_SpinDust:	binclude	"artunc/SpinDust.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Art_Shield:	binclude	"artunc/Shield.unc"
		even
Art_Stars:	binclude	"artunc/Invincibility Stars.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Map_SSWalls:	include	"_maps/SS Walls.asm"

Art_SSWalls:	binclude	"artunc/Special Walls.unc" ; special stage walls (uncompressed)
		even
Eni_SSBg1:	binclude	"tilemaps/SS Background 1.eni" ; special stage background (mappings)
		even
KosPM_SSBgFish:	binclude	"artkospm/Special Birds & Fish.kospm" ; special stage birds and fish background
		even
Eni_SSBg2:	binclude	"tilemaps/SS Background 2.eni" ; special stage background (mappings)
		even
KosPM_SSBgCloud:	binclude	"artkospm/Special Clouds.kospm" ; special stage clouds background
		even
KosPM_SSGOAL:	binclude	"artkospm/Special GOAL.kospm" ; special stage GOAL block
		even
KosPM_SSRBlock:	binclude	"artkospm/Special R.kospm" ; special stage R block
		even
KosPM_SS1UpBlock:	binclude	"artkospm/Special 1UP.kospm" ; special stage 1UP block
		even
KosPM_SSEmStars:	binclude	"artkospm/Special Emerald Twinkle.kospm" ; special stage stars from a collected emerald
		even
KosPM_SSRedWhite:	binclude	"artkospm/Special Red-White.kospm" ; special stage red/white block
		even
KosPM_SSZone1:	binclude	"artkospm/Special ZONE1.kospm" ; special stage ZONE1 block
		even
KosPM_SSZone2:	binclude	"artkospm/Special ZONE2.kospm" ; ZONE2 block
		even
KosPM_SSZone3:	binclude	"artkospm/Special ZONE3.kospm" ; ZONE3 block
		even
KosPM_SSZone4:	binclude	"artkospm/Special ZONE4.kospm" ; ZONE4 block
		even
KosPM_SSZone5:	binclude	"artkospm/Special ZONE5.kospm" ; ZONE5 block
		even
KosPM_SSZone6:	binclude	"artkospm/Special ZONE6.kospm" ; ZONE6 block
		even
KosPM_SSUpDown:	binclude	"artkospm/Special UP-DOWN.kospm" ; special stage UP/DOWN block
		even
KosPM_SSEmerald:	binclude	"artkospm/Special Emeralds.kospm" ; special stage chaos emeralds
		even
KosPM_SSGhost:	binclude	"artkospm/Special Ghost.kospm" ; special stage ghost block
		even
KosPM_SSWBlock:	binclude	"artkospm/Special W.kospm" ; special stage W block
		even
KosPM_SSGlass:	binclude	"artkospm/Special Glass.kospm" ; special stage destroyable glass block
		even
KosPM_ResultEm:	binclude	"artkospm/Special Result Emeralds.kospm" ; chaos emeralds on special stage results screen
		even

; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
KosPM_Stalk:	binclude	"artkospm/GHZ Flower Stalk.kospm"
		even
KosPM_Swing:	binclude	"artkospm/GHZ Swinging Platform.kospm"
		even
KosPM_Bridge:	binclude	"artkospm/GHZ Bridge.kospm"
		even
KosPM_Ball:	binclude	"artkospm/GHZ Giant Ball.kospm"
		even
KosPM_Spikes:	binclude	"artkospm/Spikes.kospm"
		even
KosPM_SpikePole:	binclude	"artkospm/GHZ Spiked Log.kospm"
		even
KosPM_PplRock:	binclude	"artkospm/GHZ Purple Rock.kospm"
		even
KosPM_GhzWall1:	binclude	"artkospm/GHZ Breakable Wall.kospm"
		even
KosPM_GhzWall2:	binclude	"artkospm/GHZ Edge Wall.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
KosPM_Splash:	binclude	"artkospm/LZ Water & Splashes.kospm"
		even
KosPM_LzSpikeBall:binclude	"artkospm/LZ Spiked Ball & Chain.kospm"
		even
KosPM_FlapDoor:	binclude	"artkospm/LZ Flapping Door.kospm"
		even
KosPM_Bubbles:	binclude	"artkospm/LZ Bubbles & Countdown.kospm"
		even
KosPM_LzBlock3:	binclude	"artkospm/LZ 32x16 Block.kospm"
		even
KosPM_LzDoor1:	binclude	"artkospm/LZ Vertical Door.kospm"
		even
KosPM_Harpoon:	binclude	"artkospm/LZ Harpoon.kospm"
		even
KosPM_LzPole:	binclude	"artkospm/LZ Breakable Pole.kospm"
		even
KosPM_LzDoor2:	binclude	"artkospm/LZ Horizontal Door.kospm"
		even
KosPM_LzWheel:	binclude	"artkospm/LZ Wheel.kospm"
		even
KosPM_Gargoyle:	binclude	"artkospm/LZ Gargoyle & Fireball.kospm"
		even
KosPM_LzBlock2:	binclude	"artkospm/LZ Blocks.kospm"
		even
KosPM_LzPlatfm:	binclude	"artkospm/LZ Rising Platform.kospm"
		even
KosPM_Cork:	binclude	"artkospm/LZ Cork.kospm"
		even
KosPM_LzBlock1:	binclude	"artkospm/LZ 32x32 Block.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
KosPM_MzMetal:	binclude	"artkospm/MZ Metal Blocks.kospm"
		even
KosPM_MzSwitch:	binclude	"artkospm/MZ Switch.kospm"
		even
KosPM_MzGlass:	binclude	"artkospm/MZ Green Glass Block.kospm"
		even
KosPM_MzFire:	binclude	"artkospm/Fireballs.kospm"
		even
KosPM_Lava:	binclude	"artkospm/MZ Lava.kospm"
		even
KosPM_MzBlock:	binclude	"artkospm/MZ Green Pushable Block.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
KosPM_Seesaw:	binclude	"artkospm/SLZ Seesaw.kospm"
		even
KosPM_SlzSpike:	binclude	"artkospm/SLZ Little Spikeball.kospm"
		even
KosPM_Fan:	binclude	"artkospm/SLZ Fan.kospm"
		even
KosPM_SlzWall:	binclude	"artkospm/SLZ Breakable Wall.kospm"
		even
KosPM_Pylon:	binclude	"artkospm/SLZ Pylon.kospm"
		even
KosPM_SlzSwing:	binclude	"artkospm/SLZ Swinging Platform.kospm"
		even
KosPM_SlzBlock:	binclude	"artkospm/SLZ 32x32 Block.kospm"
		even
KosPM_SlzCannon:	binclude	"artkospm/SLZ Cannon.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
KosPM_Bumper:	binclude	"artkospm/SYZ Bumper.kospm"
		even
KosPM_SyzSpike2:	binclude	"artkospm/SYZ Small Spikeball.kospm"
		even
KosPM_LzSwitch:	binclude	"artkospm/Switch.kospm"
		even
KosPM_SyzSpike1:	binclude	"artkospm/SYZ Large Spikeball.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
KosPM_SbzWheel1:	binclude	"artkospm/SBZ Running Disc.kospm"
		even
KosPM_SbzWheel2:	binclude	"artkospm/SBZ Junction Wheel.kospm"
		even
KosPM_Cutter:	binclude	"artkospm/SBZ Pizza Cutter.kospm"
		even
KosPM_Stomper:	binclude	"artkospm/SBZ Stomper.kospm"
		even
KosPM_SpinPform:	binclude	"artkospm/SBZ Spinning Platform.kospm"
		even
KosPM_TrapDoor:	binclude	"artkospm/SBZ Trapdoor.kospm"
		even
KosPM_SbzFloor:	binclude	"artkospm/SBZ Collapsing Floor.kospm"
		even
KosPM_Electric:	binclude	"artkospm/SBZ Electrocuter.kospm"
		even
KosPM_SbzBlock:	binclude	"artkospm/SBZ Vanishing Block.kospm"
		even
KosPM_FlamePipe:	binclude	"artkospm/SBZ Flaming Pipe.kospm"
		even
KosPM_SbzDoor1:	binclude	"artkospm/SBZ Small Vertical Door.kospm"
		even
KosPM_SlideFloor:	binclude	"artkospm/SBZ Sliding Floor Trap.kospm"
		even
KosPM_SbzDoor2:	binclude	"artkospm/SBZ Large Horizontal Door.kospm"
		even
KosPM_Girder:	binclude	"artkospm/SBZ Crushing Girder.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
KosPM_BallHog:	binclude	"artkospm/Enemy Ball Hog.kospm"
		even
KosPM_Crabmeat:	binclude	"artkospm/Enemy Crabmeat.kospm"
		even
KosPM_Buzz:	binclude	"artkospm/Enemy Buzz Bomber.kospm"
		even
KosPM_Burrobot:	binclude	"artkospm/Enemy Burrobot.kospm"
		even
KosPM_Chopper:	binclude	"artkospm/Enemy Chopper.kospm"
		even
KosPM_Jaws:	binclude	"artkospm/Enemy Jaws.kospm"
		even
KosPM_Roller:	binclude	"artkospm/Enemy Roller.kospm"
		even
KosPM_Motobug:	binclude	"artkospm/Enemy Motobug.kospm"
		even
KosPM_Newtron:	binclude	"artkospm/Enemy Newtron.kospm"
		even
KosPM_Yadrin:	binclude	"artkospm/Enemy Yadrin.kospm"
		even
KosPM_Basaran:	binclude	"artkospm/Enemy Basaran.kospm"
		even
KosPM_Splats:	binclude	"artkospm/Enemy Splats.kospm"
		even
KosPM_Bomb:	binclude	"artkospm/Enemy Bomb.kospm"
		even
KosPM_Orbinaut:	binclude	"artkospm/Enemy Orbinaut.kospm"
		even
KosPM_Cater:	binclude	"artkospm/Enemy Caterkiller.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
KosPM_TitleCard:	binclude	"artkospm/Title Cards.kospm"
		even
KosPM_Hud:	binclude	"artkospm/HUD.kospm" ; HUD (rings, time, score)
		even
KosPM_Lives:	binclude	"artkospm/HUD - Life Counter Icon.kospm"
		even
Art_Ring:	binclude	"artunc/Rings.unc"
		even
KosPM_Sparkles:	binclude	"artkospm/Ring Sparkles.kospm"
		even
KosPM_Monitors:	binclude	"artkospm/Monitors.kospm"
		even
KosPM_Explode:	binclude	"artkospm/Explosion.kospm"
		even
Art_Points:	binclude	"artunc/Points.unc"
		even
KosPM_GameOver:	binclude	"artkospm/Game Over.kospm" ; game over / time over
		even
KosPM_HSpring:	binclude	"artkospm/Spring Horizontal.kospm"
		even
KosPM_VSpring:	binclude	"artkospm/Spring Vertical.kospm"
		even
KosPM_SignPost:	binclude	"artkospm/Signpost.kospm" ; end of level signpost
		even
KosPM_Lamp:	binclude	"artkospm/Lamppost.kospm"
		even
Art_BigFlash:	binclude	"artunc/Giant Ring Flash.unc"
		even
KosPM_Bonus:	binclude	"artkospm/Hidden Bonuses.kospm" ; hidden bonuses at end of a level
		even

; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
KosPM_ContSonic:	binclude	"artkospm/Continue Screen Sonic.kospm"
		even
KosPM_MiniSonic:	binclude	"artkospm/Continue Screen Stuff.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
KosPM_Rabbit:	binclude	"artkospm/Animal Rabbit.kospm"
		even
KosPM_Chicken:	binclude	"artkospm/Animal Chicken.kospm"
		even
KosPM_Penguin:	binclude	"artkospm/Animal Penguin.kospm"
		even
KosPM_Seal:	binclude	"artkospm/Animal Seal.kospm"
		even
KosPM_Pig:	binclude	"artkospm/Animal Pig.kospm"
		even
KosPM_Flicky:	binclude	"artkospm/Animal Flicky.kospm"
		even
KosPM_Squirrel:	binclude	"artkospm/Animal Squirrel.kospm"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_Title:	binclude	"map16/Title.unc"
		even
KosPM_Title:	binclude	"artkospm/8x8 - Title.kospm" ; Title primary patterns
		even
Blk256_Title:	binclude	"map256/Title.unc"
		even

Blk16_GHZ:	binclude	"map16/GHZ.unc"
		even
KosPM_GHZ:	binclude	"artkospm/8x8 - GHZ.kospm" ; GHZ primary patterns
		even
Blk256_GHZ:	binclude	"map256/GHZ.unc"
		even

Blk16_LZ:	binclude	"map16/LZ.unc"
		even
KosPM_LZ:	binclude	"artkospm/8x8 - LZ.kospm" ; LZ primary patterns
		even
Blk256_LZ:	binclude	"map256/LZ.unc"
		even

Blk16_MZ:	binclude	"map16/MZ.unc"
		even
KosPM_MZ:	binclude	"artkospm/8x8 - MZ.kospm" ; MZ primary patterns
		even
Blk256_MZ:	binclude	"map256/MZ.unc"
		even

Blk16_SLZ:	binclude	"map16/SLZ.unc"
		even
KosPM_SLZ:	binclude	"artkospm/8x8 - SLZ.kospm" ; SLZ primary patterns
		even
Blk256_SLZ:	binclude	"map256/SLZ.unc"
		even

Blk16_SYZ:	binclude	"map16/SYZ.unc"
		even
KosPM_SYZ:	binclude	"artkospm/8x8 - SYZ.kospm" ; SYZ primary patterns
		even
Blk256_SYZ:	binclude	"map256/SYZ.unc"
		even

Blk16_SBZ:	binclude	"map16/SBZ.unc"
		even
KosPM_SBZ:	binclude	"artkospm/8x8 - SBZ.kospm" ; SBZ primary patterns
		even
Blk256_SBZ:	binclude	"map256/SBZ.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
KosPM_Eggman:	binclude	"artkospm/Boss - Main.kospm"
		even
KosPM_Weapons:	binclude	"artkospm/Boss - Weapons.kospm"
		even
KosPM_Prison:	binclude	"artkospm/Prison Capsule.kospm"
		even
KosPM_Sbz2Eggman:	binclude	"artkospm/Boss - Eggman in SBZ2 & FZ.kospm"
		even
KosPM_FzBoss:	binclude	"artkospm/Boss - Final Zone.kospm"
		even
KosPM_FzEggman:	binclude	"artkospm/Boss - Eggman after FZ Fight.kospm"
		even
KosPM_Exhaust:	binclude	"artkospm/Boss - Exhaust Flame.kospm"
		even
KosPM_EndEm:	binclude	"artkospm/Ending - Emeralds.kospm"
		even
KosPM_EndSonic:	binclude	"artkospm/Ending - Sonic.kospm"
		even
KosPM_TryAgain:	binclude	"artkospm/Ending - Try Again.kospm"
		even
Art_EndFlowers:	binclude	"artunc/Flowers at Ending.unc"
		even
KosPM_EndFlower:	binclude	"artkospm/Ending - Flowers.kospm"
		even
KosPM_CreditText:	binclude	"artkospm/Ending - Credits.kospm"
		even
KosPM_EndStH:	binclude	"artkospm/Ending - StH Logo.kospm"
		even


; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	binclude	"collide/Angle Map.bin"
		even
CollArray1:	binclude	"collide/Collision Array (Normal).bin"
		even
CollArray2:	binclude	"collide/Collision Array (Rotated).bin"
		even
Col_GHZ:	binclude	"collide/GHZ.bin" ; GHZ index
		even
Col_LZ:		binclude	"collide/LZ.bin" ; LZ index
		even
Col_MZ:		binclude	"collide/MZ.bin" ; MZ index
		even
Col_SLZ:	binclude	"collide/SLZ.bin" ; SLZ index
		even
Col_SYZ:	binclude	"collide/SYZ.bin" ; SYZ index
		even
Col_SBZ:	binclude	"collide/SBZ.bin" ; SBZ index
		even

; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		binclude	"sslayout/1.eni"
		even
SS_2:		binclude	"sslayout/2.eni"
		even
SS_3:		binclude	"sslayout/3.eni"
		even
SS_4:		binclude	"sslayout/4.eni"
		even
SS_5:		binclude	"sslayout/5.eni"
		even
SS_6:		binclude	"sslayout/6.eni"
		even

; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	binclude	"artunc/GHZ Waterfall.unc"
		even
Art_GhzFlower1:	binclude	"artunc/GHZ Flower Large.unc"
		even
Art_GhzFlower2:	binclude	"artunc/GHZ Flower Small.unc"
		even
Art_MzLava1:	binclude	"artunc/MZ Lava Surface.unc"
		even
Art_MzLava2:	binclude	"artunc/MZ Lava.unc"
		even
Art_MzTorch:	binclude	"artunc/MZ Background Torch.unc"
		even
Art_SbzSmoke:	binclude	"artunc/SBZ Background Smoke.unc"
		even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Giant Rings
; ---------------------------------------------------------------------------
Art_BigRing:	binclude	"artunc/Giant Ring.unc"
Art_BigRing_size:	equ	*-Art_BigRing
		even

; ---------------------------------------------------------------------------
; Level layout index
; ---------------------------------------------------------------------------
Level_Null:	dc.w	$0000, $0000, $000
		even

Level_GHZ1:	binclude	"levels/ghz1.bin"
		even
Level_GHZ2:	binclude	"levels/ghz2.bin"
		even
Level_GHZ3:	binclude	"levels/ghz3.bin"
		even
Level_GHZbg:	binclude	"levels/ghzbg.bin"
		even

Level_LZ1:	binclude	"levels/lz1.bin"
		even
Level_LZ2:	binclude	"levels/lz2.bin"
		even
Level_LZ3:	binclude	"levels/lz3.bin"
		even
Level_SBZ3:	binclude	"levels/sbz3.bin"
		even
Level_LZbg:	binclude	"levels/lzbg.bin"
		even

Level_MZ1:	binclude	"levels/mz1.bin"
		even
Level_MZ2:	binclude	"levels/mz2.bin"
		even
Level_MZ3:	binclude	"levels/mz3.bin"
		even
Level_MZbg:	binclude	"levels/mzbg.bin"
		even

Level_SLZ1:	binclude	"levels/slz1.bin"
		even
Level_SLZ2:	binclude	"levels/slz2.bin"
		even
Level_SLZ3:	binclude	"levels/slz3.bin"
		even
Level_SLZbg:	binclude	"levels/slzbg.bin"
		even

Level_SYZ1:	binclude	"levels/syz1.bin"
		even
Level_SYZ2:	binclude	"levels/syz2.bin"
		even
Level_SYZ3:	binclude	"levels/syz3.bin"
		even
Level_SYZbg:	binclude	"levels/syzbg.bin"
		even

Level_SBZ1:	binclude	"levels/sbz1.bin"
		even
Level_SBZ1bg:	binclude	"levels/sbz1bg.bin"
		even
Level_SBZ2_FZ:	binclude	"levels/sbz2.bin"
		even
Level_SBZ2bg:	binclude	"levels/sbz2bg.bin"
		even

Level_End:	binclude	"levels/ending.bin"
		even

Level_Titlebg:	binclude	"levels/titlebg.bin"
		even

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Null:	dc.w	$FFFF, $0000, $0000
		even

ObjPos_GHZ1:	binclude	"objpos/ghz1.bin"
		even
ObjPos_GHZ2:	binclude	"objpos/ghz2.bin"
		even
ObjPos_GHZ3:	binclude	"objpos/ghz3.bin"
		even

ObjPos_LZ1:	binclude	"objpos/lz1.bin"
		even
ObjPos_LZ2:	binclude	"objpos/lz2.bin"
		even
ObjPos_LZ3:	binclude	"objpos/lz3.bin"
		even
ObjPos_SBZ3:	binclude	"objpos/sbz3.bin"
		even

ObjPos_MZ1:	binclude	"objpos/mz1.bin"
		even
ObjPos_MZ2:	binclude	"objpos/mz2.bin"
		even
ObjPos_MZ3:	binclude	"objpos/mz3.bin"
		even

ObjPos_SLZ1:	binclude	"objpos/slz1.bin"
		even
ObjPos_SLZ2:	binclude	"objpos/slz2.bin"
		even
ObjPos_SLZ3:	binclude	"objpos/slz3.bin"
		even
ObjPos_SYZ1:	binclude	"objpos/syz1.bin"
		even
ObjPos_SYZ2:	binclude	"objpos/syz2.bin"
		even
ObjPos_SYZ3:	binclude	"objpos/syz3.bin"
		even

ObjPos_SBZ1:	binclude	"objpos/sbz1.bin"
		even
ObjPos_SBZ2:	binclude	"objpos/sbz2.bin"
		even
ObjPos_FZ:	binclude	"objpos/fz.bin"
		even

ObjPos_End:	binclude	"objpos/ending.bin"
		even

; ---------------------------------------------------------------------------
; Ring locations index for RingManager
; ---------------------------------------------------------------------------
Rings_Null:	dc.w	$FFFF, $0000, $0000
		even

Rings_GHZ1:	binclude	"objpos/Rings/ghz1.bin"
		even
Rings_GHZ2:	binclude	"objpos/Rings/ghz2.bin"
		even
Rings_GHZ3:	binclude	"objpos/Rings/ghz3.bin"
		even

Rings_LZ1:	binclude	"objpos/Rings/lz1.bin"
		even
Rings_LZ2:	binclude	"objpos/Rings/lz2.bin"
		even
Rings_LZ3:	binclude	"objpos/Rings/lz3.bin"
		even
Rings_SBZ3:	binclude	"objpos/Rings/sbz3.bin"
		even

Rings_MZ1:	binclude	"objpos/Rings/mz1.bin"
		even
Rings_MZ2:	binclude	"objpos/Rings/mz2.bin"
		even
Rings_MZ3:	binclude	"objpos/Rings/mz3.bin"
		even

Rings_SLZ1:	binclude	"objpos/Rings/slz1.bin"
		even
Rings_SLZ2:	binclude	"objpos/Rings/slz2.bin"
		even
Rings_SLZ3:	binclude	"objpos/Rings/slz3.bin"
		even

Rings_SYZ1:	binclude	"objpos/Rings/syz1.bin"
		even
Rings_SYZ2:	binclude	"objpos/Rings/syz2.bin"
		even
Rings_SYZ3:	binclude	"objpos/Rings/syz3.bin"
		even

Rings_SBZ1:	binclude	"objpos/Rings/sbz1.bin"
		even
Rings_SBZ2:	binclude	"objpos/Rings/sbz2.bin"
		even
Rings_FZ:	binclude	"objpos/Rings/fz.bin"
		even

; ---------------------------------------------------------------------------

		include	"_inc/Title Cards Extended.asm"

; ---------------------------------------------------------------------------

		include "sound/MegaPCM.asm"
		include "sound/SampleTable.asm"

SoundDriver:	include "sound/s1.sounddriver.asm"
		even

; =============================================================
; --------------------------------------------------------------
; Debugging modules
; --------------------------------------------------------------

	include	"_inc/ErrorHandler.asm"

; --------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; --------------------------------------------------------------


; end of 'ROM'
EndOfRom:

		END
