; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite:
		lea	(v_spritequeue).w,a1			; load base sprite queue address
		adda.w	obPriority(a0),a1			; add precalculated queue offse
		move.w	(a1),d0					; get sprite queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.full					; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue
	.full:
		rts
; End of function DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a 2nd sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; DisplaySprite1: <-- old misnomer
DisplaySprite2:
		lea	(v_spritequeue).w,a2			; load base sprite queue address
		adda.w	obPriority(a0),a2			; add precalculated queue offset
		move.w	(a2),d0					; get sprite queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.full					; if byte value went to $80, queue is full
		move.w	d0,(a2)					; set new sprite queue's entry count
		move.w	a1,(a2,d0.w)				; insert RAM address for object to queue
	.full:
		rts
; End of function DisplaySprite2

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already priority*$80
; ---------------------------------------------------------------------------

DisplaySprite3:
		lea	(v_spritequeue).w,a1			; load base sprite queue address
		adda.w	d0,a1					; add precalculated queue offset from d0
		move.w	(a1),d0					; get sprite queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.full					; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue
	.full:
		rts
; End of function DisplaySprite3