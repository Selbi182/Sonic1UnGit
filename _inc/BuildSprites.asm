; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) into proper Mega Drive sprites
; and queue them into a linked sprite buffer table (transferred in VBlank).
; ---------------------------------------------------------------------------

BuildSprites:
		lea	(v_spritetablebuffer).w,a2
		moveq	#0,d5					; d5 will be used as counter for total rendered sprites

		tst.b	(v_draw_hud).w				; is HUD rendering on? (Level_started_flag in S2)
		beq.s	.noHud					; if not, branch
		bsr.w	BuildHUD				; draw HUD directly to sprite buffer
	.noHud:

		lea	(v_spritequeue).w,a4
		moveq	#spritelayer_num-1,d7
.priorityLoop:
		cmpi.w	#spritelayer_num-2,d7			; is sprite priority layer 2 up next for rendering?
		bne.s	.noRings				; if not, branch
		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noRings				; if not, branch
		movem.l	d7/a4,-(sp)				; backup v_spritequeue and layer iterator
		bsr.w	BuildRings				; render ring sprites
		movem.l	(sp)+,d7/a4				; restore v_spritequeue and layer iterator
	.noRings:

		tst.w	(a4)					; are there objects left to draw in current priority layer?
		beq.w	.nextPriority				; if not, go to next priority layer

		moveq	#2,d6					; initialize offset pointer to first object after entry counter (2 bytes)
	.objectLoop:
		movea.w	(a4,d6.w),a0				; load object's address in RAM
		tst.b	obID(a0)				; has an object been queued for display but deleted?
		beq.w	.skipObject				; if yes, skip (this appears to be an effort to fix display-and-delete bugs)
		bclr	#sprite_rendered_bit,obRender(a0)	; set object as not visible

	; --- Coordinate system ---
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#sprite_subsprite_bit,d0		; is the multi-draw/sub-sprites flag set?
		bne.w	BuildSprites_MultiDraw			; if yes, branch to multi-sprite drawing logic
		andi.w	#sprite_cam_field|sprite_cam_bg,d0	; get drawing coordinate system in render flags (bit 2-3)
		beq.s	.screenCoords				; branch if 0 (on-screen positioning coordinate system)
		lea	(v_screenposx).w,a1			; load camera pointers for coordinate system (in practice, only foreground camera is ever used)

	; --- Screen bounds check for X-position ---
		moveq	#0,d0
		move.b	obActWid(a0),d0				; get display width
		move.w	obX(a0),d3
		sub.w	(a1),d3					; subtract camera X-position
		move.w	d3,d1
		add.w	d0,d1					; d1 = obX - cameraX + obActWid
		bmi.w	.skipObject				; if underflowed, left edge is out of bounds
		move.w	d3,d1
		sub.w	d0,d1					; d1 = obX - cameraX - obActWid
		cmpi.w	#320,d1					; is result greater than screen width?
		bge.w	.skipObject				; if yes, right edge is out of bounds
		addi.w	#$80,d3					; add VDP sprite start

	; --- Screen bounds check for Y-position ---
		btst	#sprite_customheight_bit,d4		; is custom height flag set?
		beq.s	.assumeHeight				; if not, assume height instead

		moveq	#0,d0
		move.b	obHeight(a0),d0				; use custom height
		move.w	obY(a0),d2
		sub.w	4(a1),d2				; subtract camera Y-position
		move.w	d2,d1
		add.w	d0,d1					; d1 = obY - cameraY + obHeight
		bmi.s	.skipObject				; if negative, top edge is out of bounds
		move.w	d2,d1
		sub.w	d0,d1					; d1 = obY - cameraY - obHeight
		cmpi.w	#224,d1					; is result greater than screen height?
		bge.s	.skipObject				; if yes, bottom edge is out of bounds
		addi.w	#$80,d2					; add VDP sprite start
		andi.w	#$7FF,d2				; wrap Y axis
		bra.s	.drawObject
; ---------------------------------------------------------------------------

	.screenCoords:
		move.w	obScreenY(a0),d2			; special variable for screen Y
		move.w	obX(a0),d3
		bra.s	.drawObject
; ---------------------------------------------------------------------------

	.assumeHeight:
		.ah:	equ 32					; assumed height = 32px ($20)
		move.w	obY(a0),d2
		sub.w	4(a1),d2				; subtract camera Y-position
		addi.w	#$80,d2
		andi.w	#$7FF,d2				; wrap Y axis
		cmpi.w	#$80-.ah,d2				; is top Y-position with assumed height out of bounds?
		blo.s	.skipObject				; if yes, branch
		cmpi.w	#$80+224+.ah,d2				; is bottom Y-position with assumed height out of bounds?
		bhs.s	.skipObject				; if yes, branch

	; --- Load sprite mappings ---
	.drawObject:
		movea.l	obMap(a0),a1

		moveq	#1-1,d1					; write only one sprite for raw-mappings
		btst	#sprite_rawmappings_bit,d4		; is "raw-mappings" flag on?
		bne.s	.drawFrame				; if yes, branch (assume mappings point to a single sprite piece)

		move.b	obFrame(a0),d1
		add.w	d1,d1			; MJ: changed from byte to word (we want more than 7F sprites)
		adda.w	(a1,d1.w),a1				; get mappings frame address
		moveq	#0,d1			; MJ: clear d1 (because of our byte to word change)
		move.b	(a1)+,d1				; get number of sprite pieces in frame
		subq.b	#1,d1					; subtract 1 for dbf
		bmi.s	.setVisible				; skip rendering if mapping was blank

	; --- Do the actual sprite mapping rendering ---
	.drawFrame:
		bsr.w	BuildSpr_Draw

	.setVisible:
		bset	#sprite_rendered_bit,obRender(a0)	; set object as visible

	.skipObject:
		addq.w	#2,d6					; advance to next entry in layer
		subq.w	#2,(a4)					; decrement number of objects left
		bne.w	.objectLoop				; if entries remain, loop

.nextPriority:
		lea	spritelayer_size(a4),a4			; advance to next layer (each layer is $80 bytes)
		dbf	d7,.priorityLoop

		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noLossRings				; if not, branch
		movem.l	d7/a4,-(sp)				; backup v_spritequeue and layer iterator
		bsr.w	BuildRings_Loss				; render ring sprites
		movem.l	(sp)+,d7/a4				; restore v_spritequeue and layer iterator
	.noLossRings:
		move.b	d5,(v_spritecount).w			; write number of rendered sprites to debug var
		cmpi.b	#sprites_max,d5				; check if sprite limit was exhausted
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
		cmpi.b	#sprites_max,d5				; check sprite limit
		beq.s	.return					; if all sprite slots are taken up, abort process

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
		btst	#sprite_xflip_bit,d4			; is X-flip flag set?
		bne.s	BuildSpr_FlipX				; if yes, branch
		btst	#sprite_yflip_bit,d4			; is Y-flip flag set?
		bne.w	BuildSpr_FlipY				; if yes, branch

BuildSpr_Normal:
		buildsprite	0,0
; ---------------------------------------------------------------------------

BuildSpr_FlipX:
		btst	#sprite_yflip_bit,d4			; is Y-flip flag set as well?
		bne.w	BuildSpr_FlipXY				; if yes, branch

		buildsprite	1,0
; ---------------------------------------------------------------------------

BuildSpr_FlipY:
		buildsprite	0,1
; ---------------------------------------------------------------------------

BuildSpr_FlipXY:
		buildsprite	1,1
; End of function BuildSpr_Draw


BuildSprites_MultiDraw:
		move.l	a4,-(sp)
		lea	(v_screenposx).w,a4
		movea.w obGfx(a0),a3
		movea.l obMap(a0),a5
		moveq	#0,d0
	
		; check if object is within X bounds
		move.b	mainspr_width(a0),d0	; load pixel width
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	.skipObject	; left edge out of bounds
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.w	.skipObject	; right edge out of bounds
		addi.w	#128,d3		; VDP sprites start at 128px

		; check if object is within Y bounds
		btst	#sprite_customheight_bit,d4		; is assume height flag on?
		beq.s	.assumeHeight	; if yes, branch
		moveq	#0,d0
		move.b	mainspr_height(a0),d0	; load pixel height
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.w	.skipObject	; top edge out of bounds
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.w	.skipObject	; bottom edge out of bounds
		addi.w	#128,d2		; VDP sprites start at 128px
		andi.w	#$7FF,d2				; wrap Y axis
		bra.s	.drawObject

	.assumeHeight:
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		andi.w	#$7FF,d2				; wrap Y axis
		cmpi.w	#-32+128,d2
		blo.w	.skipObject	; top edge out of bounds
		cmpi.w	#32+128+224,d2
		bhs.w	.skipObject	; bottom edge out of bounds

.drawObject:
		moveq	#0,d1
		move.b	mainspr_mapframe(a0),d1	; get current frame
		beq.s	.setVisible	; branch if parent object has no sprite
		add.b	d1,d1
		movea.l a5,a1
		adda.w	(a1,d1.w),a1	; get mappings frame address
		move.b	(a1)+,d1	; number of sprite pieces
		subq.b	#1,d1
		bmi.s	.setVisible
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite	; write data from sprite pieces to buffer
		move.w	(sp)+,d4
	.setVisible:
		bset	#7,obRender(a0)
		lea	subspr_data(a0),a6
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0	; get child sprite count
		subq.w	#1,d0		; if there are 0, go to next object
		bcs.s	.skipObject

.drawSubSpritesLoop:
		swap	d0
		move.w	(a6)+,d3	; get X pos
		sub.w	(a4),d3
		addi.w	#128,d3
		move.w	(a6)+,d2	; get Y pos
		sub.w	4(a4),d2
		addi.w	#128,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1	; get mapping frame
		add.b	d1,d1
		movea.l a5,a1
		adda.w	(a1,d1.w),a1	; get mappings frame address
		move.b	(a1)+,d1	; number of sprite pieces
		subq.b	#1,d1
		bmi.s	.nextSubSprite
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite	; write data from sprite pieces to buffer
		move.w	(sp)+,d4
	.nextSubSprite:
		swap	d0
		dbf	d0,.drawSubSpritesLoop	; repeat for number of child sprites

.skipObject:
		movea.l (sp)+,a4
		bra.w	BuildSprites_NextObj
; End of fuction .BuildSprites_MultiDraw


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
