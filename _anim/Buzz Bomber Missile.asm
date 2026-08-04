; ---------------------------------------------------------------------------
; Animation script - missile that Buzz Bomber enemy throws (GHZ/MZ)
; ---------------------------------------------------------------------------

Ani_Missile:	dc.w .flare-Ani_Missile
		dc.w .missile-Ani_Missile

.flare:		dc.b 7
		dc.b 0, 1
		dc.b afRoutine
		even

.missile:	dc.b 1
		dc.b 2, 3
		dc.b afEnd
		even
