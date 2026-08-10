; ---------------------------------------------------------------------------
; Animation script - burning grass that sits on the floor (MZ)
; ---------------------------------------------------------------------------

Ani_GFire:	dc.w .burn-Ani_GFire

.burn:		dc.b 5
		dc.b 0, 6, 1, 7
		dc.b afEnd
		even
