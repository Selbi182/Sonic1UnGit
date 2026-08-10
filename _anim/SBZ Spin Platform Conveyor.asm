; ---------------------------------------------------------------------------
; Animation script - platform on conveyor belt (SBZ)
; ---------------------------------------------------------------------------

Ani_SpinConvey:	dc.w .spin-Ani_SpinConvey
		dc.w .still-Ani_SpinConvey

.spin:		dc.b 0
		dc.b 0, 1, 2, 3, 4
		dc.b $D, $C, $B, $A
		dc.b $10, $11, $12, $13
		dc.b 8, 7, 6, 5
		dc.b afEnd
		even

.still:		dc.b 15
		dc.b 0
		dc.b afEnd
		even
