; ---------------------------------------------------------------------------
; Animation script - Newtron enemy
; ---------------------------------------------------------------------------

Ani_Newt:	dc.w .blank-Ani_Newt
		dc.w .drop-Ani_Newt
		dc.w .fly1-Ani_Newt
		dc.w .fly2-Ani_Newt
		dc.w .fires-Ani_Newt

.blank:		dc.b 15
		dc.b $A
		dc.b afEnd
		even

.drop:		dc.b 19
		dc.b 0, 1, 3, 4
		dc.b 5
		dc.b afBack, 1
		even

.fly1:		dc.b 2
		dc.b 6, 7
		dc.b afEnd
		even

.fly2:		dc.b 2
		dc.b 8, 9
		dc.b afEnd
		even

.fires:		dc.b 19
		dc.b 0, 1, 1, 2, 1, 1, 0
		dc.b afRoutine
		even
