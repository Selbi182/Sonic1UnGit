
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

LevelDataLoad:
	; --- Get Level Header ---
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		lsl.w	#7,d0					; multiply by $80 (4 acts per zone * $20 bytes per act)
		moveq	#0,d1					; clear d0
		move.b	(v_act).w,d1				; get current act number
		lsl.w	#5,d1					; multiply by $20 (bytes for one level header)
		add.w	d1,d0					; restore d0 from stack and add to get index
		lea	LevelHeaders(pc,d0.w),a2		; load level header for current zone/act into a2

	; --- Music ---
		move.b	(a2),(v_levelmusic).w			; load BGM ID and store it for current level (protected RAM)
		bsr.w	PlayCurrentActMusic			; start playing music immediately

	; --- Main Level GFX ---
		move.l	(a2)+,d0				; load main level graphics pointer
		andi.l	#$00FFFFFF,d0				; mask out upper byte (BGM ID)
		movea.l	d0,a0					; convert to address register as input
		bsr.w	LoadZoneTiles				; write main level graphics

	; --- PLC ---
		moveq	#0,d0					; clear d0
		move.b	(a2),d0					; load PLC entry
		bsr.w	AddPLC					; add PLCs for level

	; --- FG Level Layout ---
		move.l	(a2)+,d0				; load foreground level layout
		andi.l	#$00FFFFFF,d0				; mask out upper byte (PLC ID)
		movea.l	d0,a1					; conver to address register as input
		lea	(v_lvllayout_fg).w,a3			; write to FG level layout buffer
		bsr.w	LevelLayoutLoad				; write FG level layout

	; --- Palette ---
		moveq	#0,d0					; clear d0
		move.b	(a2),d0					; load palette ID
		move.l	a2,-(sp)				; backup a2 (trashed by PalLoad_Fade otherwise)
		bsr.w	PalLoad_Fade				; load specified palette into fade-in buffer
		move.l	(sp)+,a2				; restore a2

	; --- BG Level Layout ---
		move.l	(a2)+,d0				; load background level layout
		andi.l	#$00FFFFFF,d0				; mask out upper byte (palette ID)
		movea.l	d0,a1					; convert to address register as input
		lea	(v_lvllayout_bg).w,a3			; write to BG level layout buffer
		bsr.w	LevelLayoutLoad				; write BG level layout

	; --- 16x16 Block Mappings ---
		move.l	(a2)+,(v_rom_blocks).w			; load ROM Blk16 pointer (blocks)

	; --- 256x256 Chunk Mappings ---
		move.l	(a2)+,(v_rom_chunks).w			; load ROM Blk256 pointer (chunks)

	; --- Collision index ---
		move.l	(a2)+,(v_collindex).w			; load collision index

	; --- Object positions ---
		move.l	(a2)+,(v_opl_data).w			; load objpos index

	; --- Ring positions ---
		move.l	(a2)+,(v_ringindex).w			; load ring position index

		rts						; done
; End of function LevelDataLoad
; ===========================================================================

		include	"_inc/LevelHeaders.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Level layout loading subroutine
; ---------------------------------------------------------------------------

LevelLayoutLoad:
		moveq	#0,d1					; clear d1
		moveq	#0,d2					; clear d2
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
		rts						; done
; End of function LevelLayoutLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Load main level graphics (Kosinski+ compression)
; ---------------------------------------------------------------------------

LoadZoneTiles:	; a0 = pointer to compressed level graphics
		lea	(v_ram_start).l,a1			; Load v_ram_start (in this context, an art buffer) into a1 (destination)
		bsr.w   KosPlusDec				; Decompress a0 to a1 (Kosinski+ compression)

		move.w	a1,d3					; Move a word of a1 to d3, note that a1 doesn't exactly contain the address of v_ram_start anymore, after KosDec, a1 now contains v_ram_start + the size of the file decompressed to it, d3 now contains the length of the file that was decompressed
		move.w	d3,d7					; Move d3 to d7, for use in separate calculations

		andi.w	#$FFF,d3				; Remove the high nibble of the high byte of the length of decompressed file, this nibble is how many $1000 bytes the decompressed art is
		lsr.w	#1,d3					; Half the value of 'length of decompressed file', d3 becomes the 'DMA transfer length'

		rol.w	#4,d7					; Rotate (left) length of decompressed file by one nibble
		andi.w	#$F,d7					; Only keep the low nibble of low byte (the same one filtered out of d3 above), this nibble is how many $1000 bytes the decompressed art is

.loop:		move.w	d7,d2					; Move d7 to d2, note that the ahead dbf removes 1 byte from d7 each time it loops, meaning that the following calculations will have different results each time
		lsl.w	#7,d2					; Shift (left) d2 by $C, making it high nibble of the high byte, d2 is now the size of the decompressed file rounded down to the nearest $1000 bytes, d2 becomes the 'destination address'
		lsl.w	#5,d2					; See above (needs to be two lines, maximum count for a single bit shift instruction is 7)

		move.l	#$FFFFFF,d1				; Fill d1 with $FF
		move.w	d2,d1					; Move d2 to d1, overwriting the last word of $FF's with d2, this turns d1 into 'v_ram_start'+'However many $1000 bytes the decompressed art is', d1 becomes the 'source address'

		jsr	(QueueDMATransfer).l			; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
		move.w	d7,-(sp)				; Store d7 in the Stack
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; Set VBlank routine to $C (title cards sequence)
		bsr.w	WaitForVBlank				; Wait for VBlank to run DMA
		move.w	(sp)+,d7				; Restore d7 from the Stack
		move.w	#$1000/2,d3				; Force the DMA transfer length to be $1000/2 (the first cycle is dynamic because the art's DMA'd backwards)
		dbf	d7,.loop				; Loop for each $1000 bytes the decompressed art is

		rts						; Done
; End of function LoadZoneTiles
