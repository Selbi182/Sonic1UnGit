; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to make an object fall downwards, increasingly fast
; ---------------------------------------------------------------------------
gravity:	equ	$38				; gravity constant used by many objects
; ---------------------------------------------------------------------------

ObjectFall:
		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,obX(a0)				; add X speed to X position (note this affects the subpixel position)
		asl.l	#8,d2					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,obY(a0)				; add Y speed to Y position (note this affects the subpixel position)
		add.w	#gravity,obVelY(a0)			; increase vertical speed (apply gravity)
		rts
; End of function ObjectFall


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine translating object speed to update object position.
; Identical to ObjectFall, but without applying gravity.
; ---------------------------------------------------------------------------

SpeedToPos:
		movem.w	obVelX(a0),d0/d2			; load X and Y speed to d0/d2
		asl.l	#8,d0					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,obX(a0)				; add X speed to X position (note this affects the subpixel position)
		asl.l	#8,d2					; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,obY(a0)				; add Y speed to Y position (note this affects the subpixel position)
		rts
; End of function SpeedToPos
