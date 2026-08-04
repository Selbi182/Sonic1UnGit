; ---------------------------------------------------------------------------
; Animation script - water splash (LZ)
; ---------------------------------------------------------------------------

Ani_Splash:	dc.w .splash-Ani_Splash

.splash:	dc.b 4
		dc.b 0, 1, 2
		dc.b afRoutine
		even
