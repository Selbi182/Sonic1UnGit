; ---------------------------------------------------------------------------
; Animation script - ring sparkle (rings themselves are animated with Sync2)
; ---------------------------------------------------------------------------

Ani_Ring:	dc.w .sparkle-Ani_Ring

.sparkle:	dc.b 5
		dc.b 1, 2, 3, 4
		dc.b afRoutine
		even
