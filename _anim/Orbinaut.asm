; ---------------------------------------------------------------------------
; Animation script - Orbinaut enemy (LZ/SLZ)
; ---------------------------------------------------------------------------

Ani_Orb:	dc.w .normal-Ani_Orb
		dc.w .angry-Ani_Orb

.normal:	dc.b 15
		dc.b 0
		dc.b afEnd
		even

.angry:		dc.b 15
		dc.b 1
		dc.b 2
		dc.b afBack, 1
		even
