; ---------------------------------------------------------------------------
; Animation script - geyser of lava (MZ)
; ---------------------------------------------------------------------------

Ani_Geyser:	dc.w .bubble1-Ani_Geyser
		dc.w .bubble2-Ani_Geyser
		dc.w .end-Ani_Geyser
		dc.w .bubble3-Ani_Geyser
		dc.w .blank-Ani_Geyser
		dc.w .bubble4-Ani_Geyser

.bubble1:	dc.b 2
		dc.b 0, 1, 0, 1, 4, 5, 4, 5
		dc.b afRoutine
		even

.bubble2:	dc.b 2
		dc.b 2, 3
		dc.b afEnd
		even

.end:		dc.b 2
		dc.b 6, 7
		dc.b afEnd
		even

.bubble3:	dc.b 2
		dc.b 2, 3, 0, 1, 0, 1
		dc.b afRoutine
		even

.blank:		dc.b 15
		dc.b $13
		dc.b afEnd
		even

.bubble4:	dc.b 2
		dc.b $11, $12
		dc.b afEnd
		even
