; ===========================================================================
; ---------------------------------------------------------------------------
; Defeated boss subroutine (shared by all bosses)
; ---------------------------------------------------------------------------

BossDefeated:
		move.b	(v_vblank_byte).w,d0			; get V-Blank counter
		andi.b	#7,d0 					; limits spawning explosions to every 8 frames
		bne.s	.noExplosion 				; if on other frame, branch

		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.noExplosion 				; if RAM is full, branch

		move.l	#Explosion,obID(a1)			; load explosion object
		move.w	obX(a0),obX(a1) 			; set base explosion X-position to boss X-position
		move.w	obY(a0),obY(a1)				; set base explosion Y-position to boss Y-position

		jsr	(RandomNumber).l 			; generate a random number for position
		move.w	d0,d1 					; copy random number to d1
		moveq	#0,d1 					; ditch the first byte
		move.b	d0,d1 					; copy first byte of d0 to first byte of d1
		lsr.b	#2,d1 					; scale down the random number
		subi.w	#$20,d1 				; shift left by $20 pixels (otherwise all explosions would be on the right side of the boss)
		add.w	d1,obX(a1) 				; apply random x

		; Unlike the X-position, no shift is made for the Y-position.
		; It's hard to tell if it was intentional or not,
		; but all explosions are biased downwards due to this.

		lsr.w	#8,d0 					; shift high byte into low byte
		lsr.b	#3,d0 					; scale down the random number
		add.w	d0,obY(a1) 				; apply random y

	.noExplosion:
		rts						; return
; End of function BossDefeated


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to move a boss (shared by all bosses).
; This is a modified variation of SpeedToPos.
; ---------------------------------------------------------------------------

BossMove:
		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,obBossX(a0)				; add X speed to X position (note this affects the subpixel position)
		asl.l	#8,d2					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,obBossY(a0)				; add Y speed to Y position (note this affects the subpixel position)
		rts
; End of function BossMove
