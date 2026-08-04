; ---------------------------------------------------------------------------
; Animation script - Motobug enemy (GHZ)
; ---------------------------------------------------------------------------

Ani_Moto:	dc.w .stand-Ani_Moto
		dc.w .drive-Ani_Moto
		dc.w .smoke-Ani_Moto

.stand:		dc.b 15
		dc.b 2
		dc.b afEnd
		even

.drive:		dc.b 7
		dc.b 0, 1, 0, 2
		dc.b afEnd
		even

.smoke:		dc.b 1
		dc.b 3, 6, 3, 6, 4, 6, 4, 6, 4, 6, 5
		dc.b afRoutine
		even
