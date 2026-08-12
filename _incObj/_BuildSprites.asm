; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) into proper Mega Drive sprites
; and queue them into a linked sprite buffer table (transferred in VBlank).
; ---------------------------------------------------------------------------

BuildSprites:
		lea	(v_spritetablebuffer).w,a2
		moveq	#0,d5					; d5 will be used as counter for total rendered sprites
		moveq	#sprites_max,d7

		tst.b	(v_draw_hud).w				; is HUD rendering on? (Level_started_flag in S2)
		beq.s	.noHud					; if not, branch
		bsr.w	BuildHUD				; draw HUD directly to sprite buffer
	.noHud:

spritelayer	macro	screenpospossible


		tst.w	(a4)					; are there objects left to draw in current priority layer?
		beq.w	.nextPriority\@				; if not, go to next priority layer

		moveq	#2,d6					; initialize offset pointer to first object after entry counter (2 bytes)
	.objectLoop\@:
		movea.w	(a4,d6.w),a0				; load object's address in RAM
		bclr	#sprite_rendered_bit,obRender(a0)	; set object as not visible

	; --- Coordinate system ---
		move.b	obRender(a0),d0
		
		move.b	d0,d4
	if narg=1
		moveq	#sprite_cam_field,d0
		and.w	d4,d0	; get drawing coordinate system in render flags (bit 2-3)
		beq.s	.screenCoords\@				; branch if 0 (on-screen positioning coordinate system)
	endif
		lea	(v_screenposx).w,a1			; load camera pointers for coordinate system (in practice, only foreground camera is ever used)

	; --- Screen bounds check for X-position ---
		moveq	#0,d0
		move.b	obActWid(a0),d0				; get display width
		move.w	obX(a0),d3
		sub.w	(a1),d3					; subtract camera X-position
		move.w	d3,d1
		add.w	d0,d1					; d1 = obX - cameraX + obActWid
		bmi.w	.skipObject\@				; if underflowed, left edge is out of bounds
		move.w	d3,d1
		sub.w	d0,d1					; d1 = obX - cameraX - obActWid
		cmpi.w	#320,d1					; is result greater than screen width?
		bge.w	.skipObject\@				; if yes, right edge is out of bounds
		addi.w	#$80,d3					; add VDP sprite start

	; --- Screen bounds check for Y-position ---
		btst	#sprite_customheight_bit,d4		; is custom height flag set?
		beq.s	.assumeHeight\@				; if not, assume height instead

		moveq	#0,d0
		move.b	obHeight(a0),d0				; use custom height
		move.w	obY(a0),d2
		sub.w	4(a1),d2				; subtract camera Y-position
		move.w	d2,d1
		add.w	d0,d1					; d1 = obY - cameraY + obHeight
		bmi.s	.skipObject\@				; if negative, top edge is out of bounds
		move.w	d2,d1
		sub.w	d0,d1					; d1 = obY - cameraY - obHeight
		cmpi.w	#224,d1					; is result greater than screen height?
		bge.s	.skipObject\@				; if yes, bottom edge is out of bounds
		addi.w	#$80,d2					; add VDP sprite start
		andi.w	#$7FF,d2				; wrap Y axis
		bra.s	.drawObject\@
; ---------------------------------------------------------------------------

	if narg=1
	.screenCoords\@:
		move.w	obY(a0),d2				; changed from obScreenY to be consistent
		move.w	obX(a0),d3
		bra.s	.drawObject\@
	endif
; ---------------------------------------------------------------------------

	.assumeHeight\@:
		.ah:	equ 32					; assumed height = 32px ($20)
		move.w	obY(a0),d2
		sub.w	4(a1),d2				; subtract camera Y-position
		addi.w	#$80,d2
		andi.w	#$7FF,d2				; wrap Y axis
		cmpi.w	#$80-.ah,d2				; is top Y-position with assumed height out of bounds?
		blo.s	.skipObject\@				; if yes, branch
		cmpi.w	#$80+224+.ah,d2				; is bottom Y-position with assumed height out of bounds?
		bhs.s	.skipObject\@				; if yes, branch

	; --- Load sprite mappings ---
	.drawObject\@:
		movea.l	obMap(a0),a1

		moveq	#1-1,d1					; write only one sprite for raw-mappings
		btst	#sprite_rawmappings_bit,d4		; is "raw-mappings" flag on?
		bne.s	.drawFrame\@				; if yes, branch (assume mappings point to a single sprite piece)

		move.b	obFrame(a0),d1
		add.w	d1,d1			; MJ: changed from byte to word (we want more than 7F sprites)
		adda.w	(a1,d1.w),a1				; get mappings frame address
		moveq	#0,d1			; MJ: clear d1 (because of our byte to word change)
		move.b	(a1)+,d1				; get number of sprite pieces in frame
		subq.b	#1,d1					; subtract 1 for dbf
		bmi.s	.setVisible\@				; skip rendering if mapping was blank

	; --- Do the actual sprite mapping rendering ---
	.drawFrame\@:
		bsr.w	BuildSpr_Draw

	.setVisible\@:
		bset	#sprite_rendered_bit,obRender(a0)	; set object as visible

	.skipObject\@:
		addq.w	#2,d6					; advance to next entry in layer
		subq.w	#2,(a4)					; decrement number of objects left
		bne.w	.objectLoop\@				; if entries remain, loop

.nextPriority\@:
		lea	spritelayer_size(a4),a4			; advance to next layer (each layer is $80 bytes)

	endm




		lea	(v_spritequeue).w,a4

		spritelayer	1	; 0
		spritelayer	1	; 1


		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noRings				; if not, branch
		move.w	a4,-(sp)				; backup v_spritequeue and layer iterator
		bsr.w	BuildRings				; render ring sprites
		move.w	(sp)+,a4				; restore v_spritequeue and layer iterator
	.noRings:

		spritelayer	1	; 2

		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noLossRings				; if not, branch
		move.w	a4,-(sp)				; backup v_spritequeue and layer iterator
		bsr.w	BuildRings_Loss				; render ring sprites
		move.w	(sp)+,a4				; restore v_spritequeue and layer iterator
	.noLossRings:

		spritelayer	1	; 3
		spritelayer	1	; 4
		spritelayer	1	; 5
		spritelayer	1	; 6
		spritelayer	1	; 7








		move.b	d5,(v_spritecount).w			; write number of rendered sprites to debug var
		tst.b	d7
		;cmpi.b	#sprites_max,d5				; check if sprite limit was exhausted
		beq.s	.spriteLimit				; if yes, branch
		move.l	#0,(a2)					; unlink last sprite
		rts
; ---------------------------------------------------------------------------

	.spriteLimit:
		move.b	#0,-5(a2)				; unlink penultimate sprite
		rts
; End of function BuildSprites

BuildSprites_NextObj: equ .skipObject	; for cross-referencing local labels

; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for all BuildSpr_Draw functions, to visualize the differences between them.
; All four variants work on the same basic principle, only coming with
; modifications for the flipping.
; 
; input:
;	d1 = number of sprite pieces in mapping minus 1
;	d2 = base Y-position
;	d3 = base X-position
;	d5 = total rendered sprites so far (max 80)
;	a1 = pointer to starting sprite piece in sprite mappings (see breakdown above)
;	a2 = pointer to sprite link buffer (v_spritetablebuffer)
;	a3 = art tile / VRAM setting (obGfx)
;
; Each sprite piece is exactly 5 bytes. See here for a breakdown:
; https://info.sonicretro.org/SCHG:Sonic_the_Hedgehog_(16-bit)/Object_Editing#Mappings_editing
; ---------------------------------------------------------------------------

buildsprite:	macro xflip,yflip

.loopSpritePieces:
	; --- Sprite limit check ---
		tst.b	d7
		beq.s	.return

	;	cmpi.b	#sprites_max,d5				; check sprite limit
	;	beq.s	.return					; if all sprite slots are taken up, abort process

	; --- Y-position ---
		move.b	(a1)+,d0				; get relative Y-offset
		if yflip
			move.b	(a1),d4				; get dimensions of sprite piece
			ext.w	d0
			neg.w	d0
			lsl.b	#3,d4
			andi.w	#%11000,d4
			addq.w	#8,d4
			sub.w	d4,d0				; d0 = flipped Y-position
		else
			ext.w	d0
		endif
		add.w	d2,d0					; add base Y-position
		move.w	d0,(a2)+				; write Y-position to buffer

	; --- Sprite width/height ---
		if xflip
			move.b	(a1)+,d4			; get dimensions of sprite piece (WWHH) (backup for later)
			move.b	d4,(a2)+			; write sprite width to buffer
		else
			move.b	(a1)+,(a2)+			; write sprite width to buffer
		endif

	; --- Sprite link ---
		addq.b	#1,d5					; increase total sprites counter
		move.b	d5,(a2)+				; write sprite link to buffer
		subq.b	#1,d7

	; --- VRAM settings / art tile / flipping ---
		move.b	(a1)+,d0				; get first half of VRAM settings
		lsl.w	#8,d0
		move.b	(a1)+,d0				; get second half of VRAM settings
		add.w	a3,d0					; add base art tile offset of object
		if xflip|yflip
			eori.w	#xflip<<11|yflip<<12,d0		; toggle X-flip ($800) and/or Y-flip ($1000) in VDP
		endif
		move.w	d0,(a2)+				; write VRAM settings to buffer

	; --- X-position ---
		move.b	(a1)+,d0				; get relative X-offset
		ext.w	d0
		if xflip
			neg.w	d0
			add.b	d4,d4
			andi.w	#%11000,d4
			addq.w	#8,d4
			sub.w	d4,d0				; d0 = flipped X-position
		endif
		add.w	d3,d0					; add X-position
		andi.w	#$1FF,d0				; keep within 512px (screen wrap)
		bne.s	.x					; if non-zero, branch
		addq.w	#1,d0					; force zero X-position to non-zero (avoid unwanted sprite masking)
	.x:	move.w	d0,(a2)+				; write X-position to buffer

	; --- Loop for all pieces in mapping ---
		dbf	d1,.loopSpritePieces

	.return:
		rts

	endm


; ---------------------------------------------------------------------------
; Subroutine to convert a object mapping frame (with multiple sprite pieces)
; into valid, linked Mega Drive sprites and buffer them, with flipping.
; ---------------------------------------------------------------------------

BuildSpr_Draw:
		movea.w	obGfx(a0),a3				; get VRAM settings for object (art tile, palette line, priority flag)

ChkDrawSprite:
		lsr.w	d4			; is X-flip flag set?
		bcs.s	BuildSpr_FlipX				; if yes, branch
		lsr.w	d4			; is Y-flip flag set?
		bcs.w	BuildSpr_FlipY				; if yes, branch

BuildSpr_Normal:
		buildsprite	0,0
; ---------------------------------------------------------------------------

BuildSpr_FlipX:
		lsr.w	d4			; is Y-flip flag set as well?
		bcs.w	BuildSpr_FlipXY				; if yes, branch

		buildsprite	1,0
; ---------------------------------------------------------------------------

BuildSpr_FlipY:
		buildsprite	0,1
; ---------------------------------------------------------------------------

BuildSpr_FlipXY:
		buildsprite	1,1
; End of function BuildSpr_Draw

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic 2 HUD renderer, ported and optimized for Sonic 1
; ---------------------------------------------------------------------------

BuildHUD:
		moveq	#0,d1					; use frame 0 by default
		btst	#3,(v_framebyte).w			; only blink HUD every 8 frames
		bne.s	.drawHud				; branch otherwise
		tst.w	(v_rings).w				; do you have any rings?
		bne.s	.checkTime				; if so, branch
		tst.b	(v_draw_hud).w
		bmi.s	.drawHud
		addq.w	#2,d1					; make ring counter flash red

.checkTime:
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	.drawHud				; if not, branch
		addq.w	#4,d1					; make time counter flash red

.drawHud:
		lea	(Map_HUD).l,a1				; set mappings location
		adda.w	(a1,d1.w),a1				; get current HUD frame
		move.b	(a1)+,d1				; get number of sprite pieces (changed from .w to .b for S1)
		subq.b	#1,d1					; make it 0-based

		move.w	#$80+$10,d3				; set X pos
		move.w	#$80+$88,d2				; set Y pos
		movea.w	#ArtTile_HUD,a3				; set art tile (prio flag is set from mappings themselves!)
		bra.w	BuildSpr_Normal				; draw HUD directly to sprite buffer
; End of function BuildHUD
