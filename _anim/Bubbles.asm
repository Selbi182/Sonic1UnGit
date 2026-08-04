; ---------------------------------------------------------------------------
; Animation script - Bubbles (LZ)
; ---------------------------------------------------------------------------

Ani_Bub:	dc.w .small-Ani_Bub
		dc.w .medium-Ani_Bub
		dc.w .large-Ani_Bub
		dc.w .incroutine-Ani_Bub
		dc.w .incroutine-Ani_Bub
		dc.w .burst-Ani_Bub
		dc.w .bubmaker-Ani_Bub

.small:		dc.b 14
		dc.b 0, 1, 2
		dc.b afRoutine ; small bubble forming
		even

.medium:	dc.b 14
		dc.b 1, 2, 3, 4
		dc.b afRoutine ; medium bubble forming
		even

.large:		dc.b 14
		dc.b 2, 3, 4, 5, 6
		dc.b afRoutine ; full size bubble forming
		even

.incroutine:	dc.b 4
		dc.b afRoutine	; increment routine counter (no animation)
		even

.burst:		dc.b 4
		dc.b 6, 7, 8
		dc.b afRoutine ; large bubble bursts
		even

.bubmaker:	dc.b 15
		dc.b $13, $14, $15
		dc.b afEnd ; bubble maker on the floor
		even
