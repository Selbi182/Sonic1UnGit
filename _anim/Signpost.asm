; ---------------------------------------------------------------------------
; Animation script - signpost
; ---------------------------------------------------------------------------

Ani_Sign:	dc.w .eggman-Ani_Sign
		dc.w .spin1-Ani_Sign
		dc.w .spin2-Ani_Sign
		dc.w .sonic-Ani_Sign

.eggman:	dc.b 15
		dc.b 0
		dc.b afEnd
		even

.spin1:		dc.b 1
		dc.b 0, 1, 2, 3
		dc.b afEnd
		even

.spin2:		dc.b 1
		dc.b 4, 1, 2, 3
		dc.b afEnd
		even

.sonic:		dc.b 15
		dc.b 4
		dc.b afEnd
		even
