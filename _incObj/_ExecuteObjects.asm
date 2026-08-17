; ===========================================================================
; ---------------------------------------------------------------------------
; Object code execution subroutine
; 
; output:
;	d7.l = OST index of last object (must not be changed by any object)
;	a0 = address of OST of last object
; ---------------------------------------------------------------------------

ExecuteObjects:
		moveq	#(v_objspace_end-v_objspace)/object_size-1,d7 ; $80 objects - 1
		lea	(v_objspace).w,a0			; set address for object RAM

; loc_D348:
.run_object:
		move.l	obID(a0),d0				; load object ID from RAM
		beq.s	.next_object				; if ID is 0, this is an empty object slot, branch
		movea.l	d0,a1
		jsr	(a1)					; run the object's code

		tst.b	obColType(a0)				; does this object have collision with Sonic?
		beq.s	.next_object				; if not, branch
		tst.b	obRender(a0)				; is object even visible?
		bpl.s	.next_object				; if not, branch
	;	btst	#6,obRender(a0)				; is this a sub-sprite object?
	;	bne.s	.next_object				; if yes, ignore collision (obColType is overwritten with unrelated data)
		lea	(v_registeredcollision).w,a1		; get target queue
		move.w	(a1),d0					; get queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.next_object				; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue

	.next_object:
		lea	object_size(a0),a0			; increase a0 to go to next object entry ($40 bytes)
		dbf	d7,.run_object				; loop until all objects have been executed
		rts						; return
; End of function ExecuteObjects
