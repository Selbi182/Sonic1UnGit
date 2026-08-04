; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to move Sonic in demo mode
; ---------------------------------------------------------------------------

MoveSonicInDemo:
		tst.w	(f_demo).w				; is demo mode on?
		bne.s	MDemo_On				; if yes, branch to run demo
		rts						; no demo to run
; ===========================================================================

MDemo_On:
		tst.b	(v_jpadhold1).w				; is start button held?
		bpl.s	.dontquit				; if not, branch
		tst.w	(f_demo).w				; is this an ending sequence demo?
		bmi.s	.dontquit				; if yes, branch
		move.b	#id_Title,(v_gamemode).w		; go to title screen

.dontquit:
		lea	(DemoDataPtr).l,a1
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.b	#id_Special,(v_gamemode).w		; is this a special stage?
		bne.s	.notspecial				; if not, branch
		moveq	#6,d0					; use demo #6

.notspecial:
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1				; fetch address for demo data
		tst.w	(f_demo).w				; is this an ending sequence demo?
		bpl.s	.notcredits				; if not, branch
		lea	(DemoEndDataPtr).l,a1
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1				; fetch address for credits demo

.notcredits:
		move.w	(v_btnpushtime1).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea	(v_jpadhold1).w,a0
		move.b	d0,d1

		move.b	v_jpadhold2-v_jpadhold1(a0),d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(v_btnpushtime2).w
		bcc.s	.end
		move.b	3(a1),(v_btnpushtime2).w
		addq.w	#2,(v_btnpushtime1).w

.end:
		rts
; End of function MoveSonicInDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo sequence pointers
; ---------------------------------------------------------------------------
DemoDataPtr:	dc.l Demo_GHZ		; demos run after the title screen
		dc.l Demo_GHZ
		dc.l Demo_MZ
		dc.l Demo_MZ
		dc.l Demo_SYZ
		dc.l Demo_SYZ
		dc.l Demo_SS
		dc.l Demo_SS

DemoEndDataPtr:	dc.l Demo_EndGHZ1	; demos run during the credits
		dc.l Demo_EndMZ
		dc.l Demo_EndSYZ
		dc.l Demo_EndLZ
		dc.l Demo_EndSLZ
		dc.l Demo_EndSBZ1
		dc.l Demo_EndSBZ2
		dc.l Demo_EndGHZ2
