; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add rings (1 or custom amount) to ring counter, set flag
; to update ring HUD, and award an extra life for each multiple of 100 rings.
; ---------------------------------------------------------------------------

CollectRing:
	if RingsCollect32
		moveq	#32,d0					; add 32 to rings for quick testing
	else
		moveq	#1,d0					; add 1 to rings
	endif
; ---------------------------------------------------------------------------

AddRings:	; d0 = custom number of rings to add
		add.w	(v_rings).w,d0				; add current rings to number of additional rings
		cmpi.w	#999,d0					; would new result overflow the 999 limit of the counter?
		bls.s	.noOverflow				; if not, branch
		move.w	#999,d0					; otherwise, cap ring counter to 999
.noOverflow:	move.w	d0,(v_rings).w				; write result as new rings amount
		ori.b	#1,(f_ringcount).w			; set flag to refresh rings counter in HUD_Update

	if Enable_InfiniteLives=0
		move.l	d0,-(sp)				; backup d0 (long because mulu affects both words)
		moveq	#1,d0					; set initial extra lives check value
		add.b	(v_lifecount).w,d0			; add remembered value of collected extra lives
		mulu.w	#100,d0					; multiply required ring value by 100 rings
		cmp.l	(sp)+,d0				; do you have at least n*100 rings now?
		bls.s	.extraLifeFromRings			; if yes, award extra life
	endif

.playRingSfx:
		move.w	#sfx_Ring,d0				; set ring sound
		jmp	(QueueSound2).l				; play it
; ---------------------------------------------------------------------------

.extraLifeFromRings:
		addq.b	#1,(v_lifecount).w			; remember extra life for this multiple of 100 rings was awarded
		; continue to ExtraLife...

; ---------------------------------------------------------------------------
; Subroutine to add extra lives (1 or custom amount).
; ---------------------------------------------------------------------------

ExtraLife:
	if Enable_InfiniteLives
		rts
	endif

		moveq	#1,d0					; add 1 to the number of lives you have
; ---------------------------------------------------------------------------

AddLives:	; d0 = custom number of extra lives to add
		add.b	(v_lives).w,d0				; add current lives to number of additional lives
		cmpi.b	#99,d0					; would new result overflow the 99 limit of the counter?
		bls.s	.noOverflow				; if not, branch
		moveq	#99,d0					; otherwise, cap lives counter to 99
.noOverflow:	move.b	d0,(v_lives).w				; write result as new extra lives amount
		ori.b	#1,(f_lifecount).w			; set flag to refresh lives counter in HUD_Update
		move.w	#bgm_ExtraLife,d0			; set extra life music
		jmp	(QueueSound1).l				; play it
; End of functions CollectRing and ExtraLife


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to add points to the score counter.
; 
; Input:
;	d0 = points to add / 10 (rightmost digit in HUD is a fake 0)
; ---------------------------------------------------------------------------

AddPoints:
		move.b	#1,(f_scorecount).w			; set score counter to update

		lea	(v_score).w,a3				; load current score count
		add.l	d0,(a3)					; add d0*10 to the score
		move.l	#999999,d1				; set maximum score count to 9999990
		cmp.l	(a3),d1					; has score exceeded the maximum?
		bhi.s	.belowmax				; if not, branch
		move.l	d1,(a3)					; cap score to 9999990

.belowmax:
		move.l	(a3),d0					; get new score count
		cmp.l	(v_scorelife).w,d0			; is new score count exceeding the next multiple of 50000?
		blo.s	.return					; if not, branch

		addi.l	#5000,(v_scorelife).w			; increase requirement for next score extra life by 50000
		jmp	(ExtraLife).l				; add 1 to number of lives

.return:
		rts						; return
; End of function AddPoints
