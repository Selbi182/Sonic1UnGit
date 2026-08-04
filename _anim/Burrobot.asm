; ---------------------------------------------------------------------------
; Animation script - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------

Ani_Burro:	dc.w .still-Ani_Burro
		dc.w .moving-Ani_Burro
		dc.w .digging-Ani_Burro
		dc.w .fall-Ani_Burro

.still:		dc.b 3
		dc.b 0, 6
		dc.b afEnd
		even

.moving:	dc.b 3
		dc.b 0, 1
		dc.b afEnd
		even

.digging:	dc.b 3
		dc.b 2, 3
		dc.b afEnd
		even

.fall:		dc.b 3
		dc.b 4
		dc.b afEnd
		even
