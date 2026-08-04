; ---------------------------------------------------------------------------
; Animation script - energy ball launcher in final boss fight (FZ)
; ---------------------------------------------------------------------------

Ani_PLaunch:	dc.w .red-Ani_PLaunch
		dc.w .redsparking-Ani_PLaunch
		dc.w .whitesparking-Ani_PLaunch

.red:		dc.b 126
		dc.b 0
		dc.b afEnd
		even

.redsparking:	dc.b 1
		dc.b 0, 2, 0, 3
		dc.b afEnd
		even

.whitesparking:	dc.b 1
		dc.b 1, 2, 1, 3
		dc.b afEnd
		even
