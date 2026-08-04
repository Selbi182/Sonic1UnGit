; ---------------------------------------------------------------------------
; Animation script - Buzz Bomber enemy (GHZ/MZ)
; ---------------------------------------------------------------------------

Ani_Buzz:	dc.w .fly1-Ani_Buzz
		dc.w .fly2-Ani_Buzz
		dc.w .fires-Ani_Buzz

.fly1:		dc.b 1
		dc.b 0, 1
		dc.b afEnd
		even

.fly2:		dc.b 1
		dc.b 2, 3
		dc.b afEnd
		even

.fires:		dc.b 1
		dc.b 4, 5
		dc.b afEnd
		even
