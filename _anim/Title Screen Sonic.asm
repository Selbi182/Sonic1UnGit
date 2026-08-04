; ---------------------------------------------------------------------------
; Animation script - Sonic on the title screen
; ---------------------------------------------------------------------------

Ani_TSon:	dc.w .titlesonic-Ani_TSon

.titlesonic:	dc.b 7
		dc.b 0, 1, 2, 3, 4, 5 ; popping up
		dc.b 6, 7 ; finger wagging loop
		dc.b afBack, 2
		even
