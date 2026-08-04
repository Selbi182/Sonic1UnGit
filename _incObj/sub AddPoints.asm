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
; ===========================================================================