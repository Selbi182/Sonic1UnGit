; --- Extended Sonic 1 Title Cards System (ASM68K Version) ---
; * Created by Selbi
; * AS port and Level/SS result screens extension by RobiWanKenobi
; * Lowercase letters taken from "Yuu Yuu Hakusho: Makyou Toitsusen"
; * Missing uppercase letter graphics "JQVWX" by SameyTheHedgie
; * Titlecase "Act" and fixed lowercase "a" graphics by MDTravis
; * Act "4" number graphics by Cinossu
; See also: https://www.deviantart.com/sameythehedgie/art/s1cardext-846313458

; ===========================================================================
; ---------------------------------------------------------------------------
; Zone title card definitions. Stipulations:
; - All letters from the English alphabet are supported
; - Uppercase AND lowercase letters are supported
; - Maximum length 20 characters
; - ZONE text must be 5 characters or less
; - Sonic Has & Passed Text Combined must 20 or fewer characters
; - Special Stage Results Text must only be 20 characters or less
; ---------------------------------------------------------------------------

TitleCard_GHZ1:	equs "Green Hill"
TitleCard_GHZ2:	equs "Green Hill"
TitleCard_GHZ3:	equs "Green Hill"
TitleCard_GHZ4:	equs "Green Hill"

TitleCard_MZ1:	equs "Marble"
TitleCard_MZ2:	equs "Marble"
TitleCard_MZ3:	equs "Marble"
TitleCard_MZ4:	equs "Marble"

TitleCard_SYZ1:	equs "Spring Yard"
TitleCard_SYZ2:	equs "Spring Yard"
TitleCard_SYZ3:	equs "Spring Yard"
TitleCard_SYZ4:	equs "Spring Yard"

TitleCard_LZ1:	equs "Labyrinth"
TitleCard_LZ2:	equs "Labyrinth"
TitleCard_LZ3:	equs "Labyrinth"
TitleCard_LZ4:	equs "Scrap Brain"	; LZ4 is SBZ3

TitleCard_SLZ1:	equs "Star Light"
TitleCard_SLZ2:	equs "Star Light"
TitleCard_SLZ3:	equs "Star Light"
TitleCard_SLZ4:	equs "Star Light"

TitleCard_SBZ1:	equs "Scrap Brain"
TitleCard_SBZ2:	equs "Scrap Brain"
TitleCard_SBZ3:	equs "Final"		; SBZ3 is FZ
TitleCard_SBZ4:	equs "Scrap Brain"

TitleCard_Zone:	equs "Zone"
TitleCard_UseLowerAct: equ 1	; 0 = ACT // 1 = Act

; ---------------------------------------------------------------------------

TitleCard_SonicHas:	equs "Sonic Has"
TitleCard_Passed:	equs "Passed"

TitleCard_SpecialStage:	 equs "Special Stage"
TitleCard_ChaosEmeralds: equs "Chaos Emeralds"
TitleCard_GotThemAll:	 equs "Sonic Got Them All"

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to dynamically load title card letters into VRAM.
; Also see the related macro below.
; ---------------------------------------------------------------------------

TTL_LetterTiles:	equ 4	; tile count for a single letter (16x16 sprite)
TTL_NumberTiles:	equ 6	; tile count for an act number (16x24 sprite)
TTL_ActTxtTiles:	equ 3	; tile count for the act text (8x24 sprite)
TTL_OvalTiles:		equ 16	; tiles used by the blue oval (repurposed)
TTL_SmallOvalTiles:	equ 2	; tiles used by the blue oval (repurposed)
TTL_BonuTiles:		equ 8	; tiles used by the "BONU" results letters
SonicHasPassed_Tiles:	equ TTL_LetterTiles*(strlen("\TitleCard_SonicHas") + strlen("\TitleCard_Passed"))

TTL_BONU:		equ TTL_OvalTiles+TTL_ActTxtTiles+SonicHasPassed_Tiles+2
TTL_SmOval:		equ TTL_BONU+TTL_BonuTiles
TTL_SmOvalSSR:		equ TTL_OvalTiles+100+TTL_BonuTiles+TTL_SmallOvalTiles

TTL_Numbers:		equ ("Z"-"A"+1)*TTL_LetterTiles*tile_size
TTL_ActText:		equ ("z"-"A"+1)*TTL_LetterTiles*tile_size+(TTL_ActTxtTiles*TitleCard_UseLowerAct*tile_size)
TTL_BlueOval:		equ ((("z"-"A"+1)*TTL_LetterTiles)+TTL_ActTxtTiles*2)*tile_size
TTL_EOL:		equ (((("z"-"A"+1)*TTL_LetterTiles)+TTL_ActTxtTiles*2)+TTL_OvalTiles)*tile_size
; ---------------------------------------------------------------------------

TitleCards_LoadArt:
		move.w	sr,-(sp)
		disable_ints

		; blue oval, act text, act number
		bsr.w	TTL_LoadMainPatterns

		; zone text
		lea	TTLCard_Zone_Array(pc),a2
		bsr.w	TTL_WriteLetters

		; letters
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		add.b	(v_act).w,d0
		lsl.b	#3,d0
		lea	TTL_ConData(pc),a2
		movea.l	4(a2,d0.w),a2
		bsr.w	TTL_WriteLetters

		move.w	(sp)+,sr
		rts

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; "Sonic Has Passed" title cards loading subroutine
; ---------------------------------------------------------------------------

Got_LoadArt:
		move.w	sr,-(sp)
		disable_ints

		; blue oval, act text, act number
		bsr.w	TTL_LoadMainPatterns

		; "Sonic Has" text
		lea	TTLCard_Got_SonicHas_Array(pc),a2
		bsr.w	TTL_WriteLetters

		; "Passed" text
 		lea	TTLCard_Got_Passed_Array(pc),a2
		bsr.w	TTL_WriteLetters

		; "BONU" and small oval
		lea	(Unc_TitleCard+TTL_EOL).l,a1
		moveq	#(TTL_SmallOvalTiles+TTL_BonuTiles)-1,d1
		bsr.w	TTL_LoadTiles

		move.w	(sp)+,sr
		rts

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Special Stage Results title cards loading subroutine
; ---------------------------------------------------------------------------

SpecStagResults_LoadArt:
		move.w	sr,-(sp)
		disable_ints

		; blue oval
		bsr.w	TTL_SetBaseAndLoadOval

		; header text, depending on emerald count
		lea	TTLCard_SSR_SpeStage_Array(pc),a2 ; 0 emeralds
		tst.b	(v_emeralds).w
		beq.s	.loadSSR
		lea	TTLCard_SSR_Chaos_Array(pc),a2	  ; 1-5 emeralds
		cmpi.b	#6,(v_emeralds).w
		blo.s	.loadSSR
		lea	TTLCard_SSR_GotAll_Array(pc),a2	  ; 6 emeralds
.loadSSR:
		bsr.s	TTL_WriteLetters

		locVRAM	(ArtTile_Title_Card+(17*4)+5+TTL_NumberTiles+TTL_ActTxtTiles+TTL_OvalTiles+20)*tile_size
		lea	(Unc_TitleCard+TTL_EOL).l,a1
		moveq	#(TTL_SmallOvalTiles+TTL_BonuTiles)-1,d1
		bsr.s	TTL_LoadTiles

		move.w	(sp)+,sr
		rts

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Helper subroutines
; ---------------------------------------------------------------------------

TTL_WriteLetters:
		move.l	#Unc_TitleCard,d4	; load base art offset
	.loop:	moveq	#0,d2			; clear d2
		move.b	(a2)+,d2		; get next letter from array
		beq.s	.done			; if it's 0, end
		cmpi.b	#' ',d2			; is it a space?
		beq.s	.loop			; if yes, go to next char
		subi.b	#'A',d2			; make letters 0-based
		lsl.l	#7,d2			; multiply by $40
		add.l	d4,d2			; add title card art offset
		movea.l	d2,a1			; write final offset to a1
		moveq	#TTL_LetterTiles-1,d1	; four tiles per letter
		bsr.s	TTL_LoadTiles		; write tiles to VRAM
		bra.s	.loop			; loop until all letters are written
	.done:	rts

; ---------------------------------------------------------------------------

TTL_LoadTiles:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		dbf	d1,TTL_LoadTiles
		rts

; ---------------------------------------------------------------------------

TTL_LoadMainPatterns:
		; blue oval
		bsr.s	TTL_SetBaseAndLoadOval

		; act text
		lea	(Unc_TitleCard+TTL_ActText).l,a1
		moveq	#TTL_ActTxtTiles-1,d1
		bsr.w	TTL_LoadTiles

		; act number
		lea	(Unc_TitleCard+TTL_Numbers).l,a1
		moveq	#0,d0
		move.b	(v_act).w,d0
		cmpi.w	#id_LZ_act4,(v_zone).w	; is this specifically SBZ3 (LZ4)?
		bne.s	.load			; if not, branch
		subq.b	#1,d0			; force to use act 3 number instead of 4
	.load:	mulu.w	#TTL_NumberTiles*tile_size,d0
		adda.w	d0,a1
		moveq	#TTL_NumberTiles-1,d1
		bra.s	TTL_LoadTiles

; ---------------------------------------------------------------------------

TTL_SetBaseAndLoadOval:
		lea	(vdp_data_port).l,a6
		locVRAM	ArtTile_Title_Card*tile_size

		lea	(Unc_TitleCard+TTL_BlueOval).l,a1
		moveq	#TTL_OvalTiles-1,d1
		bra.s	TTL_LoadTiles


; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro to generate title card data dynamically:
; sprite mappings, letter loading array, and ConData
; ---------------------------------------------------------------------------

maketitlecard:	macro *,textline,hideAct,specialTileOffset
\*:
		; length check
		len: = strlen(\textline)
		if len>20
			inform 2, "maximum length is 20 characters"
		endif

		; calculate sprite count and width
		useSmallSpaces: = 0
		sizeX: = $00
		spaces: = 0
		i: = 1
		while (i<=len)
			char:	substr i,i,\textline
			i: = i+1
			sizeX: = sizeX+$10
			if ("\char"=' ')
				if (useSmallSpaces)
					sizeX: = sizeX-$08 ; small spaces are 8px smaller
				endif
				spaces: = spaces+1
			elseif ("\char"='I')
				sizeX: = sizeX-8
			elseif ("\char">='a')&("\char"<='z')
				if ("\char"='i')|("\char"='j')|("\char"='l')
					sizeX: = sizeX-7
				else
					sizeX: = sizeX-2
				endif
			endif
			
			if ((sizeX>$FF)&(useSmallSpaces<>1))
				useSmallSpaces: = 1
				sizeX: = $00
				spaces: = 0
				i: = 1
				; retry with small spaces
			endif
		endw
		dc.w len-spaces

		; special tile offset for zone text
		if specialTileOffset>0
			if specialTileOffset<>2 ; special tile offset for passed text
				if specialTileOffset<>3 ; special tile offset for passed text
					tile: = TTL_OvalTiles+TTL_ActTxtTiles+TTL_NumberTiles
				else
					tile: = TTL_OvalTiles
				endif
			else
				tile: = TTL_OvalTiles+TTL_ActTxtTiles+TTL_NumberTiles+((strlen("\TitleCard_SonicHas")-1)*TTL_LetterTiles)
			endif
		else
			tile: = TTL_OvalTiles+TTL_ActTxtTiles+TTL_NumberTiles+(strlen("\TitleCard_Zone")*TTL_LetterTiles)

		endif

		; write per-letter sprite mappings
		x: = $08-(sizeX/2)
		if specialTileOffset<>2
			x: = x-8 ; move "Passed" text forward by 1 tile
		endif

		i: = 1
		while (i<=len)
			char:	substr i,i,\textline
			i: = i+1
			addX: = $10
			if ("\char"=' ')
				; space
				if (useSmallSpaces<>0)
					addX: = addX-8
				endif
			elseif ("\char">='A')&("\char"<='z')
				yOffset: = 0
				if ("\char"='p')|("\char"='q')|("\char"='y')
					yOffset: = 5
				elseif ("\char"='g')
					yOffset: = 2
				endif

				dc.w $FFF8+yOffset, $0500, tile, x

				tile: = tile+4
				if ("\char">='a')&("\char"<='z')
					if ("\char"='i')|("\char"='j')|("\char"='l')
						addX: = addX-7
					else
						addX: = addX-2
					endif
				elseif ("\char"='I')
					addX: = 8
				endif
			else
				inform 2, "illegal char \char"
			endif
			x: = x+addX
		endw
		even

\*_Array:	; create tile VRAM load array
		i:   = 1
		while (i<=len)
			char:	substr i,i,\textline
			i: = i+1
			dc.b "\char"
		endw
		dc.b 0
		even

\*_ConData:	; create ConData
		if hideAct<>0
			noActAdjust: = $10
		else
			noActAdjust: = 0
		endif
		name_target: = $0120
		name_start:  = $0000
		zone_target: = $00F0+(sizeX/2)+noActAdjust
		zone_start:  = zone_target-$0240+noActAdjust
		oval_target: = zone_target+$0018-noActAdjust
		oval_start:  = oval_target+$00C0
		if hideAct<>0
			act_target: = $03EC
			act_start:  = act_target
		else
			act_target: = oval_target
			act_start:  = act_target+$02C0
		endif

		dc.w name_start&$FFFF, name_target&$FFFF
		dc.w zone_start&$FFFF, zone_target&$FFFF
		dc.w  act_start&$FFFF,  act_target&$FFFF
		dc.w oval_start&$FFFF, oval_target&$FFFF
	endm

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Extended zone title cards including full alphabet.
; These are dynamically generated by the above macro.
; Act numbers and the oval had to be redesigned to accomedate for the new
; VRAM layout, and EOL and SSR both still require the old text.
; ---------------------------------------------------------------------------

Map_Card:	mappingsTable
	mappingsTableEntry.w	TTLCard_GHZ1	; Green Hill Zone 1
	mappingsTableEntry.w	TTLCard_GHZ2	; Green Hill Zone 2
	mappingsTableEntry.w	TTLCard_GHZ3	; Green Hill Zone 3
	mappingsTableEntry.w	TTLCard_GHZ4	; Green Hill Zone 4
	mappingsTableEntry.w	TTLCard_LZ1	; Labyrinth Zone 1
	mappingsTableEntry.w	TTLCard_LZ2	; Labyrinth Zone 2
	mappingsTableEntry.w	TTLCard_LZ3	; Labyrinth Zone 3
	mappingsTableEntry.w	TTLCard_LZ4	; Labyrinth Zone 4 (Scrap Brain Zone 3)
	mappingsTableEntry.w	TTLCard_MZ1	; Marble Zone 1
	mappingsTableEntry.w	TTLCard_MZ2	; Marble Zone 2
	mappingsTableEntry.w	TTLCard_MZ3	; Marble Zone 3
	mappingsTableEntry.w	TTLCard_MZ4	; Marble Zone 4
	mappingsTableEntry.w	TTLCard_SLZ1	; Star Light Zone 1
	mappingsTableEntry.w	TTLCard_SLZ2	; Star Light Zone 2
	mappingsTableEntry.w	TTLCard_SLZ3	; Star Light Zone 3
	mappingsTableEntry.w	TTLCard_SLZ4	; Star Light Zone 4
	mappingsTableEntry.w	TTLCard_SYZ1	; Spring Yard Zone 1
	mappingsTableEntry.w	TTLCard_SYZ2	; Spring Yard Zone 2
	mappingsTableEntry.w	TTLCard_SYZ3	; Spring Yard Zone 3
	mappingsTableEntry.w	TTLCard_SYZ4	; Spring Yard Zone 4
	mappingsTableEntry.w	TTLCard_SBZ1	; Scrap Brain Zone 1
	mappingsTableEntry.w	TTLCard_SBZ2	; Scrap Brain Zone 2
	mappingsTableEntry.w	TTLCard_SBZ3	; Scrap Brain Zone 3 (Final Zone)
	mappingsTableEntry.w	TTLCard_SBZ4	; Scrap Brain Zone 4
	mappingsTableEntry.w	TTLCard_Zone	; "ZONE" text
	mappingsTableEntry.w	TTLCard_Act	; Act number
	mappingsTableEntry.w	TTLCard_Oval	; Blue oval

TTLCard_GHZ1:	maketitlecard "\TitleCard_GHZ1",0,0
TTLCard_GHZ2:	maketitlecard "\TitleCard_GHZ2",0,0
TTLCard_GHZ3:	maketitlecard "\TitleCard_GHZ3",0,0
TTLCard_GHZ4:	maketitlecard "\TitleCard_GHZ4",0,0
TTLCard_LZ1:	maketitlecard "\TitleCard_LZ1",0,0
TTLCard_LZ2:	maketitlecard "\TitleCard_LZ2",0,0
TTLCard_LZ3:	maketitlecard "\TitleCard_LZ3",0,0
TTLCard_LZ4:	maketitlecard "\TitleCard_LZ4",0,0	; SBZ3
TTLCard_MZ1:	maketitlecard "\TitleCard_MZ1",0,0
TTLCard_MZ2:	maketitlecard "\TitleCard_MZ2",0,0
TTLCard_MZ3:	maketitlecard "\TitleCard_MZ3",0,0
TTLCard_MZ4:	maketitlecard "\TitleCard_MZ4",0,0
TTLCard_SLZ1:	maketitlecard "\TitleCard_SLZ1",0,0
TTLCard_SLZ2:	maketitlecard "\TitleCard_SLZ2",0,0
TTLCard_SLZ3:	maketitlecard "\TitleCard_SLZ3",0,0
TTLCard_SLZ4:	maketitlecard "\TitleCard_SLZ4",0,0
TTLCard_SYZ1:	maketitlecard "\TitleCard_SYZ1",0,0
TTLCard_SYZ2:	maketitlecard "\TitleCard_SYZ2",0,0
TTLCard_SYZ3:	maketitlecard "\TitleCard_SYZ3",0,0
TTLCard_SYZ4:	maketitlecard "\TitleCard_SYZ4",0,0
TTLCard_SBZ1:	maketitlecard "\TitleCard_SBZ1",0,0
TTLCard_SBZ2:	maketitlecard "\TitleCard_SBZ2",0,0
TTLCard_SBZ3:	maketitlecard "\TitleCard_SBZ3",1,0	; FZ (hide act)
TTLCard_SBZ4:	maketitlecard "\TitleCard_SBZ4",0,0
TTLCard_Zone:	maketitlecard "\TitleCard_Zone",1,1	; ZONE label (alternate tile offset)

TTLCard_Act:	spriteHeader	; "ACT" and number 1/2/3/4
	spritePiece	-$14, 4, 3, 1, TTL_OvalTiles, 0, 0, 0, 0
	spritePiece	 $08, -$C, 2, 3, TTL_OvalTiles+TTL_ActTxtTiles, 0, 0, 0, 0
TTLCard_Act_End

TTLCard_Oval:	spriteHeader	; Blue oval, updated tile offsets
	spritePiece	 -$C, -$1C, 4, 1, $00, 0, 0, 0, 0
	spritePiece	 $14, -$1C, 1, 3, $04, 0, 0, 0, 0
	spritePiece	-$14, -$14, 2, 1, $07, 0, 0, 0, 0
	spritePiece	 -$1C, -$C, 2, 2, $09, 0, 0, 0, 0
	spritePiece	 -$14, $14, 4, 1, $00, 1, 1, 0, 0
	spritePiece	   -$1C, 4, 1, 3, $04, 1, 1, 0, 0
	spritePiece 	     4, $C, 2, 1, $07, 1, 1, 0, 0
	spritePiece	    $C, -4, 2, 2, $09, 1, 1, 0, 0
	spritePiece	  -4, -$14, 3, 1, $0D, 0, 0, 0, 0
	spritePiece	  -$C, -$C, 4, 1, $0C, 0, 0, 0, 0
	spritePiece	   -$C, -4, 3, 1, $0C, 0, 0, 0, 0
	spritePiece	   -$14, 4, 4, 1, $0C, 0, 0, 0, 0
	spritePiece	  -$14, $C, 3, 1, $0C, 0, 0, 0, 0
TTLCard_Oval_End
	even

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Configuration data and dynamic letter loading index, generated by the macro
; ---------------------------------------------------------------------------

TTL_ConData:
	dc.l TTLCard_GHZ1_ConData, TTLCard_GHZ1_Array	; GHZ1
	dc.l TTLCard_GHZ2_ConData, TTLCard_GHZ2_Array	; GHZ2
	dc.l TTLCard_GHZ3_ConData, TTLCard_GHZ3_Array	; GHZ3
	dc.l TTLCard_GHZ4_ConData, TTLCard_GHZ4_Array	; GHZ4

	dc.l TTLCard_LZ1_ConData,  TTLCard_LZ1_Array	; LZ1
	dc.l TTLCard_LZ2_ConData,  TTLCard_LZ2_Array	; LZ2
	dc.l TTLCard_LZ3_ConData,  TTLCard_LZ3_Array	; LZ3
	dc.l TTLCard_LZ4_ConData,  TTLCard_LZ4_Array	; LZ4 (SBZ3)

	dc.l TTLCard_MZ1_ConData,  TTLCard_MZ1_Array	; MZ1
	dc.l TTLCard_MZ2_ConData,  TTLCard_MZ2_Array	; MZ2
	dc.l TTLCard_MZ3_ConData,  TTLCard_MZ3_Array	; MZ3
	dc.l TTLCard_MZ4_ConData,  TTLCard_MZ4_Array	; MZ4

	dc.l TTLCard_SLZ1_ConData, TTLCard_SLZ1_Array	; SLZ1
	dc.l TTLCard_SLZ2_ConData, TTLCard_SLZ2_Array	; SLZ2
	dc.l TTLCard_SLZ3_ConData, TTLCard_SLZ3_Array	; SLZ3
	dc.l TTLCard_SLZ4_ConData, TTLCard_SLZ4_Array	; SLZ4

	dc.l TTLCard_SYZ1_ConData, TTLCard_SYZ1_Array	; SYZ1
	dc.l TTLCard_SYZ2_ConData, TTLCard_SYZ2_Array	; SYZ2
	dc.l TTLCard_SYZ3_ConData, TTLCard_SYZ3_Array	; SYZ3
	dc.l TTLCard_SYZ4_ConData, TTLCard_SYZ4_Array	; SYZ4

	dc.l TTLCard_SBZ1_ConData, TTLCard_SBZ1_Array	; SBZ1
	dc.l TTLCard_SBZ2_ConData, TTLCard_SBZ2_Array	; SBZ2
	dc.l TTLCard_SBZ3_ConData, TTLCard_SBZ3_Array	; SBZ3 (FZ)
	dc.l TTLCard_SBZ4_ConData, TTLCard_SBZ4_Array	; SBZ4


; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Extended "Sonic Has Passed" title cards.
; ---------------------------------------------------------------------------

Map_Got:	mappingsTable
	mappingsTableEntry.w	TTLCard_Got_SonicHas
	mappingsTableEntry.w	TTLCard_Got_Passed
	mappingsTableEntry.w	TTLCard_Got_Score
	mappingsTableEntry.w	TTLCard_Got_TBonus
	mappingsTableEntry.w	TTLCard_Got_RBonus
	mappingsTableEntry.w	TTLCard_Oval
	mappingsTableEntry.w	TTLCard_Act
	mappingsTableEntry.w	TTLCard_Act
	mappingsTableEntry.w	TTLCard_Act
	mappingsTableEntry.w	TTLCard_Act

TTLCard_Got_SonicHas:	maketitlecard "\TitleCard_SonicHas",1,1
TTLCard_Got_Passed:	maketitlecard "\TitleCard_Passed",1,2

TTLCard_Got_Score:	spriteHeader		; SCORE
	spritePiece	-$50, -8, 4, 2, $14A, 0, 0, 0, 0	; "SCOR"
	spritePiece	-$30, -8, 1, 2, $160, 0, 0, 0, 0	; "E"
	spritePiece	-$33, -9, 2, 1, TTL_SmOval, 0, 0, 0, 0	; Small oval (upper half)
	spritePiece	-$34, -1, 2, 1, TTL_SmOval, 1, 1, 0, 0	; Small oval (lower half)
	spritePiece	 $18, -8, 3, 2, $164, 0, 0, 0, 0	; Tally (first four digits)
	spritePiece	 $30, -8, 4, 2, $16A, 0, 0, 0, 0	; Tally (last four digits)
TTLCard_Got_Score_End

TTLCard_Got_TBonus:	spriteHeader		; TIME BONUS
	spritePiece	-$50, -8, 4, 2, $15A, 0, 0, 0, 0	; "TIME"
	spritePiece	-$27, -7, 4, 2, TTL_BONU, 0, 0, 0, 0	; "BONU"
	spritePiece	-$07, -8, 1, 2, $14A, 0, 0, 0, 0	; "S"
	spritePiece	-$0A, -9, 2, 1, TTL_SmOval, 0, 0, 0, 0	; Small oval (upper half)
	spritePiece	-$0B, -1, 2, 1, TTL_SmOval, 1, 1, 0, 0	; Small oval (lower half)
	spritePiece	 $28, -$8, 4, 2, -$10, 0, 0, 0, 0	; Tally (first four digits)
	spritePiece	 $48, -8, 1, 2, $170, 0, 0, 0, 0	; Tally (last four digits)
TTLCard_Got_TBonus_End

TTLCard_Got_RBonus:	spriteHeader		; RING BONUS
	spritePiece	-$50, -8, 4, 2, $152, 0, 0, 0, 0	; "RING"
	spritePiece	-$27, -7, 4, 2, TTL_BONU, 0, 0, 0, 0	; "BONU"
	spritePiece	-$07, -8, 1, 2, $14A, 0, 0, 0, 0	; "S"
	spritePiece	-$0A, -9, 2, 1, TTL_SmOval, 0, 0, 0, 0	; Small oval (upper half)
	spritePiece	-$0B, -1, 2, 1, TTL_SmOval, 1, 1, 0, 0	; Small oval (lower half)
	spritePiece	 $28, -$8, 4, 2, -8, 0, 0, 0, 0		; Tally (first four digits)
	spritePiece	 $48, -8, 1, 2, $170, 0, 0, 0, 0	; Tally (last four digits)
TTLCard_Got_RBonus_End
	even

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Extended Special Stage Results title cards.
; ---------------------------------------------------------------------------

Map_SSR:	mappingsTable
	mappingsTableEntry.w	TTLCard_SSR_Chaos	; "CHAOS EMERLADS" text
	mappingsTableEntry.w	TTLCard_SSR_Score	; Score tally
	mappingsTableEntry.w	TTLCard_SSR_Ring	; Ring Bonus tally
	mappingsTableEntry.w	TTLCard_Oval		; Blue oval (cross-referended from the regular title card mappings)
	mappingsTableEntry.w	TTLCard_SSR_ContSon1	; Continue tally with mini Sonic (foot down)
	mappingsTableEntry.w	TTLCard_SSR_ContSon2	; Continue tally with mini Sonic (foot up)
	mappingsTableEntry.w	TTLCard_SSR_Continue	; Continue tally without mini Sonic
	mappingsTableEntry.w	TTLCard_SSR_SpeStage	; "SPECIAL STAGE" text
	mappingsTableEntry.w	TTLCard_SSR_GotAll	; "SONIC GOT THEM ALL" text

TTLCard_SSR_Chaos:	maketitlecard "\TitleCard_ChaosEmeralds",1,3
TTLCard_SSR_SpeStage:	maketitlecard "\TitleCard_SpecialStage",1,3
TTLCard_SSR_GotAll:	maketitlecard "\TitleCard_GotThemAll",1,3

TTLCard_SSR_Score:	spriteHeader	; Score tally
	spritePiece	-$50, -8, 4, 2, $14A, 0, 0, 0, 0	; "SCOR"
	spritePiece	-$30, -8, 1, 2, $162, 0, 0, 0, 0	; "E"
	spritePiece	-$33, -9, 2, 1, TTL_SmOvalSSR, 0, 0, 0, 0	; Small oval (upper half)
	spritePiece	-$34, -1, 2, 1, TTL_SmOvalSSR, 1, 1, 0, 0	; Small oval (lower half)
	spritePiece	 $18, -8, 3, 2, $164, 0, 0, 0, 0	; Tally (first four digits)
	spritePiece	 $30, -8, 4, 2, $16A, 0, 0, 0, 0	; Tally (last four digits)
TTLCard_SSR_Score_End

TTLCard_SSR_Ring:	spriteHeader	; Ring Bonus tally
	spritePiece	-$50, -8, 4, 2, $152, 0, 0, 0, 0	; "RING"
	spritePiece	-$27, -7, 4, 2, TTL_SmOvalSSR-TTL_BonuTiles, 0, 0, 0, 0 ; "BONU"
	spritePiece	-$07, -8, 1, 2, $14A, 0, 0, 0, 0	; "S"
	spritePiece	-$0A, -9, 2, 1, TTL_SmOvalSSR, 0, 0, 0, 0 ; Small oval (upper half)
	spritePiece	-$0B, -1, 2, 1, TTL_SmOvalSSR, 1, 1, 0, 0 ; Small oval (lower half)
	spritePiece	 $28, -8, 4, 2, -8, 0, 0, 0, 0		; Tally (first four digits)
	spritePiece	 $48, -8, 1, 2, $170, 0, 0, 0, 0	; Tally (last four digits)
TTLCard_SSR_Ring_End

TTLCard_SSR_ContSon1:	spriteHeader	; Continue tally with mini Sonic (foot down)
	spritePiece	-$50, -8, 4, 2, -$2F, 0, 0, 0, 0	; "CONT"
	spritePiece	-$30, -8, 4, 2, -$27, 0, 0, 0, 0	; "INUE" and small oval (left half)
	spritePiece	-$10, -8, 1, 2, -$1F, 0, 0, 0, 0	; Small oval (right half)
	spritePiece	 $40, -8, 2, 3, -$1D, 0, 0, 1, 0	; Mini Sonic (foot down)
TTLCard_SSR_ContSon1_End

TTLCard_SSR_ContSon2:	spriteHeader	; Continue tally with mini Sonic (foot up)
	spritePiece	-$50, -8, 4, 2, -$2F, 0, 0, 0, 0	; "CONT"
	spritePiece	-$30, -8, 4, 2, -$27, 0, 0, 0, 0	; "INUE" and small oval (left half)
	spritePiece	-$10, -8, 1, 2, -$1F, 0, 0, 0, 0	; Small oval (right half)
	spritePiece	 $40, -8, 2, 3, -$17, 0, 0, 1, 0	; Mini Sonic (foot up)
TTLCard_SSR_ContSon2_End

TTLCard_SSR_Continue:	spriteHeader	; Continue tally without mini Sonic
	spritePiece	-$50, -8, 4, 2, -$2F, 0, 0, 0, 0	; "CONT"
	spritePiece	-$30, -8, 4, 2, -$27, 0, 0, 0, 0	; "INUE" and small oval (left half)
	spritePiece	-$10, -8, 1, 2, -$1F, 0, 0, 0, 0	; Small oval (right half)
TTLCard_SSR_Continue_End
	even

; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Extended uncompressed title card letter data. Letter art is arranged so
; that A-Z and a-z have ASCII-compliant distance between them. The gap is
; filled with the act numbers. 1 has been widened to for ease of use.
; "Act" text comes after lowercase z, and oval art right after that, and
; lastly the "BONU" and small oval used for results screens.
; ---------------------------------------------------------------------------
Unc_TitleCard:	incbin	"artunc/Title Cards Extended.unc"
		even
; ---------------------------------------------------------------------------
; ===========================================================================
