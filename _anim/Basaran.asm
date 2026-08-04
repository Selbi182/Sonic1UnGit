; ---------------------------------------------------------------------------
; Animation script - Basaran enemy (MZ)
; ---------------------------------------------------------------------------

Ani_Bas:	dc.w .still-Ani_Bas
		dc.w .fall-Ani_Bas
		dc.w .fly-Ani_Bas

.still:		dc.b 15
		dc.b 0
		dc.b afEnd
		even

.fall:		dc.b 15
		dc.b 1
		dc.b afEnd
		even

.fly:		dc.b 3
		dc.b 1, 2, 3, 2
		dc.b afEnd
		even
