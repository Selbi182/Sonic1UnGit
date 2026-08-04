; ---------------------------------------------------------------------------
; Animation script - Bomb enemy (SLZ/SBZ)
; ---------------------------------------------------------------------------

Ani_Bomb:	dc.w .stand-Ani_Bomb
		dc.w .walk-Ani_Bomb
		dc.w .activated-Ani_Bomb
		dc.w .fuse-Ani_Bomb
		dc.w .shrapnel-Ani_Bomb

.stand:		dc.b 19
		dc.b 1, 0
		dc.b afEnd
		even

.walk:		dc.b 19
		dc.b 5, 4, 3, 2
		dc.b afEnd
		even

.activated:	dc.b 19
		dc.b 7, 6
		dc.b afEnd
		even

.fuse:		dc.b 3
		dc.b 8, 9
		dc.b afEnd
		even

.shrapnel:	dc.b 3
		dc.b $A, $B
		dc.b afEnd
		even
