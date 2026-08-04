; ---------------------------------------------------------------------------
; Animation script - prison capsule
; ---------------------------------------------------------------------------

Ani_Pri:	dc.w .switchflash-Ani_Pri
		dc.w .switchflash-Ani_Pri ; redundant

.switchflash:	dc.b 2
		dc.b 1, 3
		dc.b afEnd
		even
