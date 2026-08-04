; ---------------------------------------------------------------------------
; Animation script - Sonic on the continue screen
; ---------------------------------------------------------------------------

Ani_CSon:	dc.w .onfloor-Ani_CSon

.onfloor:	dc.b 4
		dc.b 1, 1, 1, 1, 2, 2, 2, 3, 3
		dc.b afEnd
		even
