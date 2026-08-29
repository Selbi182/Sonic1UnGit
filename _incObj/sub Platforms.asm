; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to detect collision with a platform, and update relevant flags.
; Platform height is assumed to be 8px.
;
; input:
;	d0.w = y position (Plat_NoXCheck_AltY only)
;	d1.w = platform width
; 
; output:
;	d2.w = Sonic's y position
;	a1 = address of OST of Sonic
;	a2 = address of OST of platform that Sonic is already on
; 
; usage:
;		moveq	#0,d1
;		move.b	obActWid(a0),d1
;		bsr.w	PlatformObject
; ---------------------------------------------------------------------------

PlatformObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)				; is Sonic moving up/jumping?
		bmi.w	Plat_Exit				; if yes, branch

		; perform x-axis range check
		move.w	obX(a1),d0
		sub.w	obX(a0),d0				; d0 = Sonic's distance from centre of platform (-ve if left of centre)
		add.w	d1,d0
		bmi.w	Plat_Exit				; branch if Sonic is left of the platform
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit				; branch if Sonic is right of the platform

	Plat_NoXCheck:						; jump here to skip x position check
		move.w	obY(a0),d0
		subq.w	#8,d0					; assume platform is 8px tall

	; Platform3:
	Plat_NoXCheck_AltY:					; jump here to skip x position check and use custom y position

		; perform y-axis range check
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1					; d1 = y pos of Sonic's bottom edge
		addq.w	#4,d1
		sub.w	d1,d0					; d0 = distance between top of platform and Sonic's bottom edge (-ve if below platform)
		bhi.w	Plat_Exit				; branch if Sonic is above platform
		cmpi.w	#-16,d0
		blo.w	Plat_Exit				; branch if Sonic is more than 16px below top of platform

		tst.w	(v_debuguse).w				; is debug mode active?
		bne.w	Plat_Exit				; if yes, prevent getting stuck to platform
		tst.b	(f_playerctrl).w			; is object collision off?
		bmi.w	Plat_Exit				; if yes, branch
		cmpi.b	#6,obRoutine(a1)			; is Sonic dying?
		bhs.w	Plat_Exit				; if yes, branch
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
		addq.b	#2,obRoutine(a0)			; increment object's routine counter

Plat_NoCheck:							; jump here to skip all checks
		btst	#3,obStatus(a1)				; is Sonic on a platform already?
		beq.s	.no					; if not, branch
		moveq	#0,d0
		move.b	standonobject(a1),d0			; get OST index for that platform
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0			; convert index to RAM address
		movea.l	d0,a2					; point a2 to that address
		bclr	#3,obStatus(a2)				; clear platform bit for the other platform
		clr.b	ob2ndRout(a2)
		cmpi.b	#4,obRoutine(a2)			; does its routine counter suggest it's being stood on? (platforms all use similar routines)
		bne.s	.no					; if not, branch
		subq.b	#2,obRoutine(a2)			; decrement counter to "detect mode"

	.no:
		move.w	a0,d0
		subi.w	#v_objspace&$FFFF,d0
		lsr.w	#object_size_bits,d0
		andi.w	#$7F,d0
		move.b	d0,standonobject(a1)			; convert current platform OST address to index and store it
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)				; is Sonic in the air/jumping?
		beq.s	.notinair				; if not, branch
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(Sonic_ResetOnFloor).l			; make Sonic land
		movea.l	(sp)+,a0

	.notinair:
		bset	#3,obStatus(a1)
		bset	#3,obStatus(a0)

Plat_Exit:
		rts
; End of function PlatformObject


; ===========================================================================
; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
;
; input:
;	d1.w = platform half width
;	a2 = address of heightmap data
; 
; output:
;	d2.w = Sonic's y position
;	d3.l = height of platform where Sonic is standing
;	a1 = address of OST of Sonic
; 
; usage:
;		move.w	#$30,d1					; width
;		lea	(Ledge_SlopeData).l,a2			; heightmap
;		bsr.w	SlopeObject
; ---------------------------------------------------------------------------

SlopeObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)				; is Sonic moving up/jumping?
		bmi.w	Plat_Exit				; if yes, branch

		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0					; d0 = x pos of Sonic on platform
		bmi.s	Plat_Exit				; branch if Sonic is left of the platform
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	Plat_Exit				; branch if Sonic is right of the platform

		btst	#sprite_xflip_bit,obRender(a0)
		beq.s	.noflip
		not.w	d0
		add.w	d1,d0					; reverse position if platform is xflipped

	.noflip:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3				; get byte from heightmap
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Plat_NoXCheck_AltY			; detect y collision and make Sonic stand on the platform
; End of function SlopeObject


; ===========================================================================
; ---------------------------------------------------------------------------
; Alternate version of SlopeObject subroutine that assumes Sonic is already
; standing on the platform (skipping the relevant checks).
; 
; input:
;	d1.w = platform half width
;	d2.w = X-position of platform
;	a2 = address of heightmap data
; ---------------------------------------------------------------------------

; SlopeObject2:
SlopeObject_AssumeStoodOn:
		lea	(v_player).w,a1				; get Sonic object
		btst	#3,obStatus(a1)				; is Sonic standing on a platform object?
		beq.s	.return					; if not, branch

		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#sprite_xflip_bit,obRender(a0)		; is ledge mirrored?
		beq.s	.alignSonic				; if not, branch
		not.w	d0
		add.w	d1,d0

	.alignSonic:
		moveq	#0,d1
		move.b	(a2,d0.w),d1				; get relevant byte from Ledge_SlopeData
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)				; align Sonic to slope (Y-axis)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)				; align Sonic to slope (X-axis)

	.return:
		rts
; End of function SlopeObject_AssumeStoodOn


; ===========================================================================
; ---------------------------------------------------------------------------
; Alternate version of PlatformObject with custom solidity height input,
; instead of assuming 8px (only used by swinging platforms on chain links)
;
; input:
;	d1 = platform width
;	d3 = platform height
; ---------------------------------------------------------------------------

; Swing_Solid:
PlatformObject_CustomHeight:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)				; is Sonic moving up/jumping?
		bmi.w	Plat_Exit				; if yes, branch

		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit				; branch if Sonic is left of the platform
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit				; branch if Sonic is right of the platform

		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Plat_NoXCheck_AltY			; use custom platform height defined in d3
; End of function PlatformObject_CustomHeight


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off a platform
; 
; input:
;	d1 = platform width/2
; ---------------------------------------------------------------------------

ExitPlatform:
		move.w	d1,d2					; copy input width to d2
; ---------------------------------------------------------------------------

ExitPlatform2:	; input width is already in d2
		add.w	d2,d2					; double input platform width
		lea	(v_player).w,a1				; load Sonic player object
		tst.w	(v_debuguse).w				; is debug mode active?
		bne.s	.exitedPlatform				; if yes, exit platform right away
		btst	#1,obStatus(a1)				; is Sonic airborne?
		bne.s	.exitedPlatform				; if yes, exit platform right away

		move.w	obX(a1),d0				; get Sonic's X-position
		sub.w	obX(a0),d0				; subtract platform's X-position
		add.w	d1,d0					; add half platform width
		bmi.s	.exitedPlatform				; if Sonic is to the left of the platform, branch
		cmp.w	d2,d0					; is Sonic to the right of the platform?
		blo.s	.return					; if not, stay on platform

	.exitedPlatform:
		bclr	#3,obStatus(a1)				; clear Sonic's on-platform flag
		move.b	#2,obRoutine(a0)			; reset platform to "Sonic is not standing on me" routine (always second)
		bclr	#3,obStatus(a0)				; clear platform's stood-on flag

	.return:
		rts						; return
; End of function ExitPlatform


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's position when standing on a platform.
; Also matches his X-position for moving platforms.
;
; input:
;	d2.w = platform X-position of previous frame
;	d3.w = platform height (MoveWithPlatform_CustomHeight only)
; ---------------------------------------------------------------------------

MvSonicOnPtfm:	; custom platform height (in d3)
		lea	(v_player).w,a1				; get Sonic object
		move.w	obY(a0),d0				; get Y-position of platform
		sub.w	d3,d0					; subtract input height from platform Y-position
		bra.s	MoveWithPlatform			; skip over
; ===========================================================================

MvSonicOnPtfm2:	; assume platform height (fixed to 9px)
		lea	(v_player).w,a1				; get Sonic object
		move.w	obY(a0),d0				; get Y-position of platform
		subi.w	#9,d0					; subtract assumed height of 9px from platform Y-position
; ---------------------------------------------------------------------------

; MvSonic2:
MoveWithPlatform:
		tst.b	(f_playerctrl).w			; is object interaction disabled?
		bmi.s	.return					; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w		; is Sonic dying?
		bhs.s	.return					; if yes, branch
		tst.w	(v_debuguse).w				; is debug mode in use?
		bne.s	.return					; if yes, branch

		moveq	#0,d1					; clear d1
		move.b	obHeight(a1),d1				; get Sonic's current height
		sub.w	d1,d0					; d1 = Y-position so Sonic's feet are on the platform
		move.w	d0,obY(a1)				; set that as Sonic's new Y-position

		sub.w	obX(a0),d2				; d2 = X-delta of platform since last frame
		sub.w	d2,obX(a1)				; update Sonic's X-position to move with the platform

	.return:
		rts						; return
; End of function MvSonicOnPtfm
