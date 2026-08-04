; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

LevelDataLoad:
	; --- Load Level Header ---
		jsr	(GetLevelHeader).l			; load level header for current zone/act into a2
		move.l	a2,-(sp)				; remember header address for later
		addq.l	#4,a2					; skip 1st PLC and level gfx entry (handled in GM_Level)

	; --- 16x16 Block Mappings ---
		move.l	(a2)+,(v_rom_blocks).w			; set ROM Blk16 pointer

	; --- 256x256 Chunk Mappings ---
		move.l	(a2)+,(v_rom_chunks).w			; load ROM Blk256 pointer

	; --- Level Layout (FG/BG) ---
		bsr.w	LevelLayoutLoad				; load FG and BG layout

	; --- Music (unused) ---
		move.w	(a2)+,d0				; load music (unused)

	; --- Palette ---
		move.w	(a2),d0					; load palette ID
		andi.w	#$FF,d0					; only use lower byte (palette ID is duplicated in headers)
		bsr.w	PalLoad_Fade				; load specified palette into fade-in buffer

	; --- 2nd PLC ---
		movea.l	(sp)+,a2				; restore base level header pointer
		addq.w	#4,a2					; advance to 2nd PLC entry
		moveq	#0,d0
		move.b	(a2),d0					; load 2nd PLC entry from level headers
		beq.s	.skipPLC				; if 2nd PLC is 0 (i.e. the ending sequence), branch
		bsr.w	AddPLC					; load secondary pattern load cues
	.skipPLC:
		rts
; End of function LevelDataLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level layout loading subroutine
; ---------------------------------------------------------------------------

LevelLayoutLoad:
		lea	(v_lvllayout).w,a3
		move.w	#(v_lvllayout_end-v_lvllayout)/4-1,d1
		moveq	#0,d0
	.clear:	move.l	d0,(a3)+
		dbf	d1,.clear				; loop until buffer is cleared ($A400-A7FF)

		lea	(v_lvllayout_fg).w,a3			; target RAM address for level foreground layout
		moveq	#0,d1					; offset in Level_Index (0 = FG layout)
		bsr.w	LevelLayoutLoad2			; load FG level layout into RAM

		lea	(v_lvllayout_bg).w,a3			; target RAM address for background layout
		moveq	#2,d1					; offset in Level_Index (2 = BG layout)
		; fall-through for second run...
; ---------------------------------------------------------------------------

; "LevelLayoutLoad2" is run twice for (once for the FG and BG layouts each)
LevelLayoutLoad2:
		move.w	(v_zone_act).w,d0			; get current zone and act

		cmpi.b	#id_Title,(v_gamemode).w 		; is this the title screen?
		bne.s	.notTitle		 		; if not, branch
		move.w	#(id_EndZ<<8)+act4,d0	 		; use EndZ/act4 (location of title BG pointer)
.notTitle:

		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	d0,d2
		add.w	d0,d0
		add.w	d2,d0					; d0 = Level_Index row for current zone and act
		add.w	d1,d0					; add pre-specified offset to get either FG or BG layout
		lea	(Level_Index).l,a1			; get layout index
		move.w	(a1,d0.w),d0				; advance to desired layout pointer in index
		lea	(a1,d0.w),a1				; load layout pointer from index

		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1				; load level width (in chunks)
		move.b	(a1)+,d2				; load level height (in chunks)
	.loopAllRows:
		move.w	d1,d0					; reset row length (width)
		movea.l	a3,a0					; set next target layout row in RAM
	.loopRow:
		move.b	(a1)+,(a0)+				; copy next chunk ID byte
		dbf	d0,.loopRow				; loop for one whole row
		lea	layout_row(a3),a3			; advance to next (skip over other plane)
		dbf	d2,.loopAllRows				; repeat for number of rows

		rts
; End of function LevelLayoutLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Load main level graphics (Kosinski+ compression)
; ---------------------------------------------------------------------------

LoadZoneTiles:
		jsr	(GetLevelHeader).l	; load level header for current zone/act into a2
		move.l	(a2)+,d0		; Move the first longword of data that a2 points to to d0, this contains the zone's first PLC ID and its art's address.
						; The auto increment is pointless as a2 is overwritten later, and nothing reads from a2 before then
		andi.l	#$FFFFFF,d0    		; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
		movea.l	d0,a0			; Load the address of the zone's art into a0 (source)
		lea	(v_ram_start).l,a1	; Load v_ram_start (in this context, an art buffer) into a1 (destination)
		bsr.w   KosPlusDec		; Decompress a0 to a1 (Kosinski+ compression)

		move.w	a1,d3			; Move a word of a1 to d3, note that a1 doesn't exactly contain the address of v_ram_start anymore, after KosDec, a1 now contains v_ram_start + the size of the file decompressed to it, d3 now contains the length of the file that was decompressed
		move.w	d3,d7			; Move d3 to d7, for use in separate calculations

		andi.w	#$FFF,d3		; Remove the high nibble of the high byte of the length of decompressed file, this nibble is how many $1000 bytes the decompressed art is
		lsr.w	#1,d3			; Half the value of 'length of decompressed file', d3 becomes the 'DMA transfer length'

		rol.w	#4,d7			; Rotate (left) length of decompressed file by one nibble
		andi.w	#$F,d7			; Only keep the low nibble of low byte (the same one filtered out of d3 above), this nibble is how many $1000 bytes the decompressed art is

.loop:		move.w	d7,d2			; Move d7 to d2, note that the ahead dbf removes 1 byte from d7 each time it loops, meaning that the following calculations will have different results each time
		lsl.w	#7,d2			; Shift (left) d2 by $C, making it high nibble of the high byte, d2 is now the size of the decompressed file rounded down to the nearest $1000 bytes, d2 becomes the 'destination address'
		lsl.w	#5,d2			; See above (needs to be two lines, maximum count for a single bit shift instruction is 7)

		move.l	#$FFFFFF,d1		; Fill d1 with $FF
		move.w	d2,d1			; Move d2 to d1, overwriting the last word of $FF's with d2, this turns d1 into 'v_ram_start'+'However many $1000 bytes the decompressed art is', d1 becomes the 'source address'

		jsr	(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
		move.w	d7,-(sp)		; Store d7 in the Stack
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; Set VBlank routine to $C (title cards sequence)
		bsr.w	WaitForVBlank		; Wait for VBlank to run DMA
		move.w	(sp)+,d7		; Restore d7 from the Stack
		move.w	#$1000/2,d3		; Force the DMA transfer length to be $1000/2 (the first cycle is dynamic because the art's DMA'd backwards)
		dbf	d7,.loop		; Loop for each $1000 bytes the decompressed art is

		rts
; End of function LoadZoneTiles
