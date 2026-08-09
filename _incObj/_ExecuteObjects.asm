; ===========================================================================
; ---------------------------------------------------------------------------
; Object code execution subroutine
; 
; output:
;	d7.l = OST index of last object (must not be changed by any object)
;	a0 = address of OST of last object
; ---------------------------------------------------------------------------

ExecuteObjects:
		lea	(v_objspace).w,a0			; set address for object RAM
		moveq	#0,d0					; clear d0
		move.l	obID(a0),d0					; load first object ID from RAM (v_player)
		beq.s	.noSonicObject				; if ID is 0, Sonic object isn't loader
		move.l	d0,a1
		jsr	(a1)
	.noSonicObject:
		clr.w	(v_registeredcollision).w		; reset number of collision response entries to 0

		lea	object_size(a0),a0			; increase a0 to go to next object entry ($40 bytes)
		moveq	#(v_objspace_end-v_objspace)/object_size-2,d7 ; $80 objects - 2 (Sonic already done)
		moveq	#0,d0					; clear d0

; loc_D348:
.run_object:
		move.l	obID(a0),d0					; load object ID from RAM
		beq.s	.next_object				; if ID is 0, this is an empty object slot, branch
		movea.l	d0,a1
		jsr	(a1)					; run the object's code

		tst.b	obColType(a0)				; does this object have collision with Sonic?
		beq.s	.no_collision				; if not, branch
		tst.b	obRender(a0)				; is object even visible?
		bpl.s	.no_collision				; if not, branch
		btst	#6,obRender(a0)				; is this a sub-sprite object?
		bne.s	.no_collision				; if yes, ignore collision (obColType is overwritten with unrelated data)
		lea	(v_registeredcollision).w,a1		; get target queue
		move.w	(a1),d0					; get queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	.no_collision				; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue
	.no_collision:
		moveq	#0,d0					; clear d0 for next loop

	; loc_D358:
	.next_object:
		lea	object_size(a0),a0			; increase a0 to go to next object entry ($40 bytes)
		dbf	d7,.run_object				; loop until all objects have been executed
		rts						; return
; End of function ExecuteObjects
