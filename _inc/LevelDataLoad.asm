
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

	; --- FG Level Layout ---
		movea.l	(a2)+,a1				; load foreground level layout
		lea	(v_lvllayout_fg).w,a3			; write to FG level layout buffer
		bsr.w	LevelLayoutLoad				; write FG level layout

	; --- BG Level Layout ---
		movea.l	(a2)+,a1				; load background level layout
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

	; --- Music ---
		move.b	(a2)+,(v_levelmusic).w			; load BGM ID and store it for current level (protected RAM)

	; --- PLC ---
		moveq	#0,d0					; clear d0
		move.b	(a2)+,d0				; load PLC entry
		bsr.w	AddPLC					; add PLCs for level

	; --- Palette ---
		moveq	#0,d0					; clear d0
		move.b	(a2)+,d0				; load palette ID
		move.l	a2,-(sp)				; backup a2 (PalLoad_Fade trashes it)
		bsr.w	PalLoad_Fade				; load specified palette into fade-in buffer
		move.l	(sp)+,a2				; restore a2
	
	; --- Underwater Sonic Palette ---
		moveq	#0,d0					; clear d0
		move.b	(a2)+,d0				; get Sonic's underwater palette
		beq.s	.return					; if level doesn't have one, skip loading
		bra.w	PalLoad_Fade_Water			; load Sonic's underwater palette into fade-in buffer

	.return:
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
