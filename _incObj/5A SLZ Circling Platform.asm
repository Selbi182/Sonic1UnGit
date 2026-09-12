; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5A - platforms moving in circles (SLZ)
; ---------------------------------------------------------------------------
circ_origY:	equ objoff_30		; original y-axis position
circ_origX:	equ objoff_32		; original x-axis position
; ---------------------------------------------------------------------------

CirclingPlatform:
		move.l	#Circ_ChkTouch,obID(a0)			; advance to Circ_ChkTouch
		move.l	#Map_Circ,obMap(a0)			; set mappings
		move.w	#ArtTile_Level|Tile_Pal3,obGfx(a0)	; set art tile and palette
		move.b	#sprite_cam_field,obRender(a0)		; set playfield-positioned mode
		move.w	#spr_prio4,obPriority(a0)		; set sprite priority
		move.b	#48/2,obActWid(a0)			; set sprite display width and platform solidity width
		move.w	obX(a0),circ_origX(a0)			; remember initial X-position
		move.w	obY(a0),circ_origY(a0)			; remember initial Y-position
; ---------------------------------------------------------------------------

Circ_ChkTouch:	; Routine 2
		moveq	#0,d1					; clear d1
		move.b	obActWid(a0),d1				; use sprite display width as platform solidity width
		jsr	(PlatformObject).l			; sets obRoutine to 4 on touch (Circ_OnPlatform)
		btst	#3,obStatus(a0)
		beq.s	.notOn
		move.l	#Circ_OnPlatform,obID(a0)
	.notOn:
		bsr.w	Circ_Types
		bra.s	Circ_Display
; ===========================================================================

Circ_OnPlatform: ; Routine 4
		moveq	#0,d1					; clear d1
		move.b	obActWid(a0),d1				; use sprite display width as platform solidity width
		jsr	(ExitPlatform).l			; allow Sonic to exit the platform again
		btst	#3,obStatus(a0)
		bne.s	.stillOn
		move.l	#Circ_ChkTouch,obID(a0)
	.stillOn:
		move.w	obX(a0),-(sp)				; backup previous X-position for MvSonicOnPtfm
		bsr.s	Circ_Types				; circle platform
		move.w	(sp)+,d2				; restore previous X-position
		jsr	(MvSonicOnPtfm2).l			; move Sonic with the circling platform (assume height to 9px)

Circ_Display:
		out_of_range_with_y_check.w	DeleteObject,circ_origX(a0),circ_origY(a0)
		DisplaySprite
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to circle platforms
; 
; Subtype settings:
; 	bit 0 = if set, shift 180 degrees ahead
; 	bit 1 = if set, shift 90 degrees ahead
; 	bit 2 = if set, circle clockwise (otherwise, counterclockwise)
; ---------------------------------------------------------------------------

Circ_Types:
		moveq	#4,d0					; clear d0
		and.b	obSubtype(a0),d0			; get subtype of platform
		bne.w	Circ_Clockwise				; counterclockwise = $x0, clockwise = $x4
; ---------------------------------------------------------------------------

Circ_Counterclockwise:
		move.b	(v_oscillate+$22).w,d1			; get rotating value A
		subi.b	#$50,d1					; set radius of circle (X)
		ext.w	d1					; make word-based
		move.b	(v_oscillate+$26).w,d2			; get rotating value B
		subi.b	#$50,d2					; set radius of circle (B)
		ext.w	d2					; make word-based

	.shift180:
		btst	#0,obSubtype(a0)			; is flag set to shift 180 degrees ahead?
		beq.s	.shift90				; if not, branch
		neg.w	d1					; negate X-radius
		neg.w	d2					; negate Y-radius

	.shift90:
		btst	#1,obSubtype(a0)			; is flag set to shift 90 degrees ahead?
		beq.s	.setNewPosition				; if not, branch
		neg.w	d1					; negate X-radius
		exg.l	d1,d2					; exchange X/Y-radii

	.setNewPosition:
		add.w	circ_origX(a0),d1			; add original X-position
		move.w	d1,obX(a0)				; set as new X-position to circle platform
		add.w	circ_origY(a0),d2			; add original Y-position
		move.w	d2,obY(a0)				; set as new Y-position to circle platform
		rts						; return
; ===========================================================================

Circ_Clockwise:
		move.b	(v_oscillate+$22).w,d1			; get rotating value A
		subi.b	#$50,d1					; set radius of circle (X)
		ext.w	d1					; make word-based
		move.b	(v_oscillate+$26).w,d2			; get rotating value B
		subi.b	#$50,d2					; set radius of circle (B)
		ext.w	d2					; make word-based

	.shift180:
		btst	#0,obSubtype(a0)			; is flag set to shift 180 degrees ahead?
		beq.s	.shift90				; if not, branch
		neg.w	d1					; negate X-radius
		neg.w	d2					; negate Y-radius

	.shift90:
		btst	#1,obSubtype(a0)			; is flag set to shift 90 degrees ahead?
		beq.s	.setNewPosition				; if not, branch
		neg.w	d1					; negate X-radius
		exg.l	d1,d2					; exchange X/Y-radii

	.setNewPosition:
		neg.w	d1					; reverse X-direction (make clockwise)

		add.w	circ_origX(a0),d1			; add original X-position
		move.w	d1,obX(a0)				; set as new X-position to circle platform
		add.w	circ_origY(a0),d2			; add original Y-position
		move.w	d2,obY(a0)				; set as new Y-position to circle platform
		rts						; return
; End of function Circ_Types

; ===========================================================================

Map_Circ:	include	"_maps/SLZ Circling Platform.asm"
