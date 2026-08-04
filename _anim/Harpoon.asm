; ---------------------------------------------------------------------------
; Animation script - harpoon (LZ)
; ---------------------------------------------------------------------------

Ani_Harp:	dc.w .h_extending-Ani_Harp
		dc.w .h_retracting-Ani_Harp
		dc.w .v_extending-Ani_Harp
		dc.w .v_retracting-Ani_Harp

.h_extending:	dc.b 3
		dc.b 1, 2
		dc.b afRoutine
		even

.h_retracting:	dc.b 3
		dc.b 1, 0
		dc.b afRoutine
		even

.v_extending:	dc.b 3
		dc.b 4, 5
		dc.b afRoutine
		even

.v_retracting:	dc.b 3
		dc.b 4, 3
		dc.b afRoutine
		even
