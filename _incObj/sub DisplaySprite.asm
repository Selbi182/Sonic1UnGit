; precalculated sprite queue offsets, eight in total, $80 bytes each
DSpr_Layers:	dc.w v_spritequeue+($80*0)
		dc.w v_spritequeue+($80*1)
		dc.w v_spritequeue+($80*2)
		dc.w v_spritequeue+($80*3)
		dc.w v_spritequeue+($80*4)
		dc.w v_spritequeue+($80*5)
		dc.w v_spritequeue+($80*6)
		dc.w v_spritequeue+($80*7)
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite:
		moveq	#7,d0			; possible sprite priorities
		and.b	obPriority(a0),d0	; mask by object's sprite priority
		add.w	d0,d0			; double it for word-based indexing
		movea.w	DSpr_Layers(pc,d0.w),a1	; get target sprite queue
		move.w	(a1),d0			; get sprite queue's entry count
		addq.b	#2,d0			; increase count by another entry (word)
		bmi.s	DSpr_Full		; if byte value went to $80, queue is full
		move.w	d0,(a1)			; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)		; insert RAM address for object to queue

DSpr_Full:
		rts
; End of function DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a 2nd sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; DisplaySprite1: <-- old misnomer
DisplaySprite2:
		moveq	#7,d0			; possible sprite priorities
		and.b	obPriority(a1),d0	; mask by object's sprite priority
		add.w	d0,d0			; double it for word-based indexing
		movea.w	DSpr_Layers(pc,d0.w),a2	; get target sprite queue
		move.w	(a2),d0			; get sprite queue's entry count
		addq.b	#2,d0			; increase count by another entry (word)
		bmi.s	DSpr2_Full		; if byte value went to $80, queue is full
		move.w	d0,(a2)			; set new sprite queue's entry count
		move.w	a1,(a2,d0.w)		; insert RAM address for object to queue

DSpr2_Full:
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
		bmi.s	DSpr3_Full				; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue

DSpr3_Full:
		rts
; End of function DisplaySprite3
