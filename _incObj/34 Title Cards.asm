; ===========================================================================
; ---------------------------------------------------------------------------
; Object 34 - Zone Title Cards
; 
; Note that this file is just for the object logic itself.
; For the text mappings, refer to: _maps/Title Cards.asm
; ---------------------------------------------------------------------------

TitleCard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Card_Index(pc,d0.w),d1
		jmp	Card_Index(pc,d1.w)
; ===========================================================================
Card_Index:	dc.w Card_LoadForZone-Card_Index
		dc.w Card_MoveIn-Card_Index
		dc.w Card_Wait-Card_Index
		dc.w Card_Wait-Card_Index

card_mainX:	equ	objoff_30	; target X-position for card while moving in
card_finalX:	equ	objoff_32	; target X-position for card while moving out
; ===========================================================================

; Card_CheckSBZ3:
Card_LoadForZone:	; Routine 0
		movea.l	a0,a1					; set this root object to become the level name card

		moveq	#0,d0					; clear d0 (zone is a byte, we need words)
		move.b	(v_zone).w,d0				; get current zone ID and use it as index for mappings and config data
		lsl.b	#2,d0					; quadruple (4 acts per zone)
		add.b	(v_act).w,d0				; add act number
		move.b	d0,d2					; backup d2 = frame ID to use
		lsl.b	#3,d0					; multiply by 8 (number of bytes per zone entry)
		lea	(TTL_ConData).l,a3			; load extended card configuration data
		movea.l	(a3,d0.w),a3				; set pointer to configuration data for current zone

		lea	(Card_ItemData).l,a2			; load card item data
		moveq	#4-1,d1					; set to affect all four title card objects

Card_Loop:
		move.l	#TitleCard,obID(a1)			; load another title card object
		move.w	(a3),obX(a1)				; load start x-position
		move.w	(a3)+,card_finalX(a1)			; load finish x-position (same as start)
		move.w	(a3)+,card_mainX(a1)			; load main target x-position
		move.w	(a2)+,obY(a1)				; load fixed y-position
		move.b	(a2)+,obRoutine(a1)			; set initial routine number
		move.b	(a2)+,d0				; get frame ID
		bne.s	.setupCardObject			; if frame ID is non-zero, branch (i.e. not the level name)
		move.b	d2,d0					; for level name, use frame ID as set in d2 above
	; Card_MakeSprite:
	.setupCardObject:
		move.b	d0,obFrame(a1)				; display frame number set in d0
		move.l	#Map_Card,obMap(a1)			; set mappings pointer
		move.w	#ArtTile_Title_Card|Tile_Prio,obGfx(a1)	; set art tile and sprite priority flag
		move.b	#240/2,obActWid(a1)			; set display width (redundant for screen-positioned sprites)
		move.b	#sprite_cam_screen,obRender(a1)		; set to screen-positioned sprite mode
		move.w	#spr_prio0,obPriority(a1)			; set to highest sprite priority
		move.w	#1*60,obTimeFrame(a1)			; set time delay before moving out again to 1 second

		lea	object_size(a1),a1			; advance to next card object (all elements are back-to-back in RAM)
		dbf	d1,Card_Loop				; repeat sequence another 3 times
; ---------------------------------------------------------------------------

; Card_ChkPos:
Card_MoveIn:	; Routine 2
		move.w	card_mainX(a0),d1			; get target moving-in X-position
		sub.w	obX(a0),d1				; calculate difference to current X-position
		bpl.s	.pos					; is result positive? if yes, branch
		neg.w	d1					; otherwise, make it positive
	.pos:	lsr.w	#3,d1					; divide difference by 8
		addq.w	#1,d1					; set lower cap speed to 1px/frame

		move.w	card_mainX(a0),d0			; get target moving in X-position
		cmp.w	obX(a0),d0				; has item reached its target position?
		beq.s	.checkOffScreen				; if yes, branch
		bge.s	.updateXPos				; is item moving in from the left? if yes, branch
		neg.w	d1					; negate move-in direction if coming from the right
	; Card_Move:
	.updateXPos:
		add.w	d1,obX(a0)				; change card's x-position

	; Card_NoMove:
	.checkOffScreen:
		move.w	obX(a0),d0				; get current x-position of card
		bmi.s	.return					; if it's negative, don't display card
		cmpi.w	#$80+320+64,d0				; has card moved beyond $200 on x-axis (to the right)?
		bgt.s	.return					; if yes, branch
		cmpi.w	#$80-64+16,d0				; has card moved beyond $50 on the x-axis (to the left)?
		bgt.s	.display				; if not, display card

	; locret_C3D8:
	.return:
		rts						; don't display card

	.display:
		DisplaySprite
		rts
; ===========================================================================

Card_Wait:	; Routine 4/6
		tst.w	obTimeFrame(a0)				; is time remaining zero?
		beq.s	Card_MoveOut				; if yes, move out card
		subq.w	#1,obTimeFrame(a0)			; subtract 1 from time
		DisplaySprite
		rts				; display card
; ===========================================================================

; Card_ChkPos2:
Card_MoveOut:
		tst.b	obRender(a0)				; is card off screen?
		bpl.s	Card_ChangeArt				; if yes, branch

		move.w	card_mainX(a0),d1			; get target moving-in X-position
		sub.w	obX(a0),d1				; calculate difference to current X-position
		bpl.s	.pos					; is result positive? if yes, branch
		neg.w	d1					; otherwise, make it positive
	.pos:	lsr.w	#2,d1					; divide difference by 4
		addq.w	#1,d1					; set lower cap speed to 1px/frame

		move.w	card_finalX(a0),d0			; get target moving-out X-position
		cmp.w	obX(a0),d0				; has card reached the finish position?
		beq.s	Card_ChangeArt				; if yes, branch
		bge.s	.updateXPos				; is item moving out to the right? if yes, branch
		neg.w	d1					; negate move-out direction if exiting to the left
	; Card_Move2:
	.updateXPos:
		add.w	d1,obX(a0)				; change card's x-position

	; .checkOffScreen:
		move.w	obX(a0),d0				; get current x-position of card
		cmpi.w	#$80+320+64,d0				; has card moved beyond $200 on x-axis (to the right)?
		bgt.s	Card_ChangeArt				; if yes, branch
		cmpi.w	#$80-64+16,d0				; has card moved beyond $50 on the x-axis (to the left)?
		ble.s	Card_ChangeArt				; if yes, branch
		DisplaySprite
		rts				; otherwise, keep displaying card
; ===========================================================================

Card_ChangeArt:
		; The title cards take up too much VRAM space to fit in with everything else,
		; so space for the explosion and animals graphics is used up by them. Once
		; the cards have moved out, this is where these graphics get loaded again.
		cmpi.b	#4,obRoutine(a0)			; is this the level name title card object?
		bne.s	Card_Delete				; if not, branch (art should only get loaded once)

		moveq	#plcid_Explode,d0			; load explosion patterns
		jsr	(AddPLC).l				; add to pattern load cues
		moveq	#0,d0					; clear d0 (zone is a byte, we need words)
		move.b	(v_zone).w,d0				; get current zone ID
		addi.w	#plcid_GHZAnimals,d0			; add base animal PLC ID (entries are arranged in order)
		jsr	(AddPLC).l				; load animal patterns for current zone

	Card_Delete:
		bra.w	DeleteObject				; delete title card object
; ===========================================================================


; ===========================================================================
; ---------------------------------------------------------------------------
; Title card element setup data. Format:
; - Y-position
; - base routine number
; - frame ID
; ---------------------------------------------------------------------------

Card_ItemData:
		; Level Name
		dc.w $D0
		dc.b 2
		dc.b 0	; dynamic frame ID (see Card_Loop)

		; ZONE
		dc.w $E4
		dc.b 2
		dc.b 6*4

		; ACT
		dc.w $EA
		dc.b 2
		dc.b (6*4)+1

		; Oval
		dc.w $E0
		dc.b 2
		dc.b (6*4)+2
