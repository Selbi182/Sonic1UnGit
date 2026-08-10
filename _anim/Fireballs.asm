; ---------------------------------------------------------------------------
; Animation script - lava balls
; ---------------------------------------------------------------------------

Ani_Fire:	dc.w .vertical-Ani_Fire
		dc.w .vertcollide-Ani_Fire
		dc.w .horizontal-Ani_Fire
		dc.w .horicollide-Ani_Fire

.vertical:	dc.b 5
		dc.b 0, 6, 1, 7
		dc.b afEnd
		even

.vertcollide:	dc.b 5
		dc.b 2
		dc.b afRoutine
		even

.horizontal:	dc.b 5
		dc.b 3, 8, 4, 9
		dc.b afEnd
		even

.horicollide:	dc.b 5
		dc.b 5
		dc.b afRoutine
		even
