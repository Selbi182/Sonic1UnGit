PaletteFadeIn_Playable:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_Playable_Alt:				; start position and size are already set
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0
	.fill:	move.w	d1,(a0)+
		dbf	d0,.fill 	; fill palette with black

		moveq	#$0F-1,d4				; MJ: prepare maximum colour check
		moveq	#$00,d6					; MJ: clear d6

.mainloop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w	; set VBlank routine to $08
		bsr.w	WaitForVBlank				; wait until VBlank has finished
		addq.w	#1,(v_framecount).w			; add 1 to level timer

		movem.l	d4/d6,-(sp)
		bsr.w	LZWaterFeatures				; apply water features if in Labyrinth Zone
		jsr	(ExecuteObjects).l			; execute all objects in object RAM
		bsr.w	DeformLayers				; scroll planes and do background deformation
		jsr	(BuildSprites).l			; build sprite table
		jsr	(ObjPosLoad).l				; run the object manager to load level objects
		jsr	(RingsManager).l			; execute S3K Rings Manager
		bsr.w	OscillateNumDo				; advance oscillation values
		bsr.w	SynchroAnimate				; advance animation timers
		movem.l	(sp)+,d4/d6

		bchg	#$00,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame
		bsr.s	FadeIn_FromBlack
		subq.b	#$02,d4					; MJ: decrease colour check
		bne.s	.mainloop				; MJ: if it has not reached null, branch
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w ; MJ: wait for V-blank again (so colours transfer)
		bra.w	WaitForVBlank				; MJ: ''
; End of function PaletteFadeIn_Playable



; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$003F,(v_pfade_start).w ; set start position = 0; size = $40

PalFadeIn_Alt:				; start position and size are already set
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf	d0,.fill 	; fill palette with black

		moveq	#$0F-1,d4				; MJ: prepare maximum colour check
		moveq	#$00,d6					; MJ: clear d6

.mainloop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bchg	#$00,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame
		bsr.s	FadeIn_FromBlack
		subq.b	#$02,d4					; MJ: decrease colour check
		bne.s	.mainloop				; MJ: if it has not reached null, branch
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w ; MJ: wait for V-blank again (so colours transfer)
		bra.w	WaitForVBlank				; MJ: ''
; End of function PaletteFadeIn


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	FadeIn_AddColour ; increase colour
		dbf	d0,.addcolour	; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit		; if not, branch

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	FadeIn_AddColour ; increase colour again
		dbf	d0,.addcolour2 ; repeat

.exit:
		rts
; End of function FadeIn_FromBlack


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_AddColour:
		move.b	(a1),d5					; MJ: load blue
		move.w	(a1)+,d1				; MJ: load green and red
		move.b	d1,d2					; MJ: load red
		lsr.b	#$04,d1					; MJ: get only green
		andi.b	#$0E,d2					; MJ: get only red
		move.w	(a0),d3					; MJ: load current colour in buffer
		cmp.b	d5,d4					; MJ: is it time for blue to fade?
		bhi.s	FCI_NoBlue				; MJ: if not, branch
		addi.w	#$0200,d3				; MJ: increase blue

FCI_NoBlue:
		cmp.b	d1,d4					; MJ: is it time for green to fade?
		bhi.s	FCI_NoGreen				; MJ: if not, branch
		addi.b	#$20,d3					; MJ: increase green

FCI_NoGreen:
		cmp.b	d2,d4					; MJ: is it time for red to fade?
		bhi.s	FCI_NoRed				; MJ: if not, branch
		addq.b	#$02,d3					; MJ: increase red

FCI_NoRed:
		move.w	d3,(a0)+				; MJ: save colour
		rts						; MJ: return
; End of function FadeIn_AddColour


; ---------------------------------------------------------------------------
; Subroutine to fade out to black
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40

		moveq	#$08-1,d4				; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6

.mainloop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bchg	#$00,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame
		bsr.s	FadeOut_ToBlack
		dbf	d4,.mainloop
		rts
; End of function PaletteFadeOut


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	FadeOut_DecColour ; decrease colour
		dbf	d0,.decolour	; repeat for size of palette

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	FadeOut_DecColour
		dbf	d0,.decolour2
		rts
; End of function FadeOut_ToBlack


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:
		move.w	(a0),d5					; MJ: load colour
		move.w	d5,d1					; MJ: copy to d1
		move.b	d1,d2					; MJ: load green and red
		move.b	d1,d3					; MJ: load red
		andi.w	#$0E00,d1				; MJ: get only blue
		beq.s	FCO_NoBlue				; MJ: if blue is finished, branch
		subi.w	#$0200,d5				; MJ: decrease blue

FCO_NoBlue:
		andi.w	#$00E0,d2				; MJ: get only green (needs to be word)
		beq.s	FCO_NoGreen				; MJ: if green is finished, branch
		subi.b	#$20,d5					; MJ: decrease green

FCO_NoGreen:
		andi.b	#$0E,d3					; MJ: get only red
		beq.s	FCO_NoRed				; MJ: if red is finished, branch
		subq.b	#$02,d5					; MJ: decrease red

FCO_NoRed:
		move.w	d5,(a0)+				; MJ: save new colour
		rts
; End of function FadeOut_DecColour


PaletteWhiteIn:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf	d0,.fill 	; fill palette with white

		moveq	#$0F-1,d4				; MJ: prepare maximum colour check
		moveq	#$00,d6					; MJ: clear d6

.mainloop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bchg	#$00,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame
		bsr.s	WhiteIn_FromWhite
		subq.b	#$02,d4					; MJ: decrease colour check
		bne.s	.mainloop				; MJ: if it has not reached null, branch
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w ; MJ: wait for V-blank again (so colours transfer)
		bsr.w	WaitForVBlank				; MJ: ''
; End of function PaletteWhiteIn


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:
		moveq	#0,d0
		lea	(v_palette).w,a0
		lea	(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	WhiteIn_DecColour ; decrease colour
		dbf	d0,.decolour	; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit		; if not, branch
		moveq	#0,d0
		lea	(v_palette_water).w,a0
		lea	(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	WhiteIn_DecColour
		dbf	d0,.decolour2

.exit:
		rts
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_DecColour:
		move.b	(a1),d5					; MJ: load blue
		move.w	(a1)+,d1				; MJ: load green and red
		move.b	d1,d2					; MJ: load red
		lsr.b	#$04,d1					; MJ: get only green
		andi.b	#$0E,d2					; MJ: get only red
		move.w	(a0),d3					; MJ: load current colour in buffer
		cmp.b	d5,d4					; MJ: is it time for blue to fade?
		bls.s	FWI_NoBlue				; MJ: if not, branch
		subi.w	#$0200,d3				; MJ: decrease blue

FWI_NoBlue:
		cmp.b	d1,d4					; MJ: is it time for green to fade?
		bls.s	FWI_NoGreen				; MJ: if not, branch
		subi.b	#$20,d3					; MJ: decrease green

FWI_NoGreen:
		cmp.b	d2,d4					; MJ: is it time for red to fade?
		bls.s	FWI_NoRed				; MJ: if not, branch
		subq.b	#$02,d3					; MJ: decrease red

FWI_NoRed:
		move.w	d3,(a0)+				; MJ: save colour
		rts						; MJ: return
; End of function WhiteIn_DecColour

; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40

		moveq	#$08-1,d4				; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6

.mainloop:
		move.b	#id_VBlank_PaletteFade,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bchg	#$00,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame
		bsr.s	WhiteOut_ToWhite
		dbf	d4,.mainloop
		rts
; End of function PaletteWhiteOut


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:
		moveq	#0,d0
		lea	(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	WhiteOut_AddColour
		dbf	d0,.addcolour

		moveq	#0,d0
		lea	(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf	d0,.addcolour2
		rts
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
		move.w	(a0),d5					; MJ: load colour
		move.w	d5,d1					; MJ: copy to d1
		move.b	d1,d2					; MJ: load green and red
		move.b	d1,d3					; MJ: load red
		andi.w	#$0E00,d1				; MJ: get only blue
		cmpi.w	#$0E00,d1
		beq.s	FWO_NoBlue				; MJ: if blue is finished, branch
		addi.w	#$0200,d5				; MJ: increase blue

FWO_NoBlue:
		andi.w	#$00E0,d2				; MJ: get only green (needs to be word)
		cmpi.w	#$00E0,d2
		beq.s	FWO_NoGreen				; MJ: if green is finished, branch
		addi.b	#$20,d5					; MJ: increase green

FWO_NoGreen:
		andi.b	#$0E,d3					; MJ: get only red
		cmpi.b	#$0E,d3
		beq.s	FWO_NoRed				; MJ: if red is finished, branch
		addq.b	#$02,d5					; MJ: increase red

FWO_NoRed:
		move.w	d5,(a0)+				; MJ: save new colour
		rts
; End of function WhiteOut_AddColour
