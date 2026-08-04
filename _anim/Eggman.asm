; ---------------------------------------------------------------------------
; Animation script - Eggman (bosses)
; ---------------------------------------------------------------------------

Ani_Eggman:	dc.w .ship-Ani_Eggman
		dc.w .facenormal1-Ani_Eggman
		dc.w .facenormal2-Ani_Eggman
		dc.w .facenormal3-Ani_Eggman
		dc.w .facelaugh-Ani_Eggman
		dc.w .facehit-Ani_Eggman
		dc.w .facepanic-Ani_Eggman
		dc.w .blank-Ani_Eggman
		dc.w .flame1-Ani_Eggman
		dc.w .flame2-Ani_Eggman
		dc.w .facedefeat-Ani_Eggman
		dc.w .escapeflame-Ani_Eggman

.ship:		dc.b 15
		dc.b 0
		dc.b afEnd
		even

.facenormal1:	dc.b 5
		dc.b 1, 2
		dc.b afEnd
		even

.facenormal2:	dc.b 3
		dc.b 1, 2
		dc.b afEnd
		even

.facenormal3:	dc.b 1
		dc.b 1, 2
		dc.b afEnd
		even

.facelaugh:	dc.b 4
		dc.b 3, 4
		dc.b afEnd
		even

.facehit:	dc.b 31
		dc.b 5, 1
		dc.b afEnd
		even

.facepanic:	dc.b 3
		dc.b 6, 1
		dc.b afEnd
		even

.blank:		dc.b 15
		dc.b $A
		dc.b afEnd
		even

.flame1:	dc.b 3
		dc.b 8, 9
		dc.b afEnd
		even

.flame2:	dc.b 1
		dc.b 8, 9
		dc.b afEnd
		even

.facedefeat:	dc.b 15
		dc.b 7
		dc.b afEnd
		even

.escapeflame:	dc.b 2
		dc.b 9, 8, $B, $C, $B, $C
		dc.b 9, 8
		dc.b afBack, 2
		even
