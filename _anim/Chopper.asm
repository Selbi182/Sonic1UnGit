; ---------------------------------------------------------------------------
; Animation script - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------

Ani_Chop:	dc.w .slow-Ani_Chop
		dc.w .fast-Ani_Chop
		dc.w .still-Ani_Chop

.slow:		dc.b 7
		dc.b 0, 1
		dc.b afEnd
		even

.fast:		dc.b 3
		dc.b 0, 1
		dc.b afEnd
		even

.still:		dc.b 7
		dc.b 0
		dc.b afEnd
		even
