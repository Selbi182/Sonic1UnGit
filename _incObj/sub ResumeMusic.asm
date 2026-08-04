; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to play music for LZ/SBZ3 after a drowning countdown
; ---------------------------------------------------------------------------

ResumeMusic:
		cmpi.w	#12,(v_air).w				; more than 12 seconds of air left?
		bhi.s	.replenishAir				; if yes, only replenish air without changing music 

		tst.b	(v_invinc).w				; is Sonic invincible?
		beq.s	.notInvincible				; if not, branch
		move.w	#bgm_Invincible,d0			; resume invincibility music instead
		bra.s	.playSelected				; play it
; ===========================================================================

.notInvincible:
		tst.b	(f_lockscreen).w			; is Sonic at a boss?
		beq.s	.normal 				; if not, branch
		move.w	#bgm_Boss,d0				; resume boss music instead

.playSelected:
		jsr	(QueueSound1).l				; play selected song
		bra.s	.replenishAir				; do not play regular level music
; ===========================================================================

.normal:
		jsr	(PlayCurrentActMusic).l			; resume regular level music after drowning counting

.replenishAir:
		move.w	#30,(v_air).w				; reset air to 30 seconds
		clr.b	(v_sonicbubbles+bub_time).w		; reset time until next bubble spawn
		rts						; return
; End of function ResumeMusic
