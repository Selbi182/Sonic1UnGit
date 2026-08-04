; ---------------------------------------------------------------------------
; Animation script - countdown numbers and bubbles (LZ)
; ---------------------------------------------------------------------------

Ani_Drown:	dc.w .zeroappear-Ani_Drown
		dc.w .oneappear-Ani_Drown
		dc.w .twoappear-Ani_Drown
		dc.w .threeappear-Ani_Drown
		dc.w .fourappear-Ani_Drown
		dc.w .fiveappear-Ani_Drown
		dc.w .smallbubble-Ani_Drown
		dc.w .zeroflash-Ani_Drown
		dc.w .oneflash-Ani_Drown
		dc.w .twoflash-Ani_Drown
		dc.w .threeflash-Ani_Drown
		dc.w .fourflash-Ani_Drown
		dc.w .fiveflash-Ani_Drown
		dc.w .blank-Ani_Drown
		dc.w .mediumbubble-Ani_Drown

.zeroappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, 9, $D
		dc.b afRoutine
		even

.oneappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, $C, $12
		dc.b afRoutine
		even

.twoappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, $C, $11
		dc.b afRoutine
		even

.threeappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, $B, $10
		dc.b afRoutine
		even

.fourappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, 9, $F
		dc.b afRoutine
		even

.fiveappear:	dc.b 5
		dc.b 0, 1, 2, 3, 4, $A, $E
		dc.b afRoutine
		even

.smallbubble:	dc.b 14
		dc.b 0, 1, 2
		dc.b afRoutine
		even

.zeroflash:	dc.b 7
		dc.b $16, $D, $16, $D, $16, $D
		dc.b afRoutine
		even

.oneflash:	dc.b 7
		dc.b $16, $12, $16, $12, $16, $12
		dc.b afRoutine
		even

.twoflash:	dc.b 7
		dc.b $16, $11, $16, $11, $16, $11
		dc.b afRoutine
		even

.threeflash:	dc.b 7
		dc.b $16, $10, $16, $10, $16, $10
		dc.b afRoutine
		even

.fourflash:	dc.b 7
		dc.b $16, $F, $16, $F, $16, $F
		dc.b afRoutine
		even

.fiveflash:	dc.b 7
		dc.b $16, $E, $16, $E, $16, $E
		dc.b afRoutine
		even

.blank:		dc.b 14
		dc.b afRoutine ; just increase routine
		even

.mediumbubble:	dc.b 14
		dc.b 1, 2, 3, 4
		dc.b afRoutine
		even
