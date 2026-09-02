; ===========================================================================
; ---------------------------------------------------------------------------
; Relocated spritelayer macro for inlining/optimization purposes.
; Also this more easily allows to inject non-standard sprite layers at
; specific priorities (e.g. HUD and rings).
; ---------------------------------------------------------------------------

spritelayer:	macro

		tst.w	(a4)					; are there objects left to draw in current priority layer?
		beq.w	.nextPriority\@				; if not, go to next priority layer

		moveq	#2,d6					; initialize offset pointer to first object after entry counter (2 bytes)

	.objectLoop\@:
		move.w	(a4,d6.w),d4				; load object's address in RAM
		beq.w	.setNotVisible\@			; skip if sprite was queued for display but already got deleted
		movea.w	d4,a0					; load object into to address register

		move.w	obY(a0),d2				; load object Y-position (note, for screen-positioned objects this was changed from obScreenY)
		move.w	obX(a0),d3				; load object X-position

	; --- Coordinate system ---
		moveq	#0,d4
		move.b	obRender(a0),d4				; get object render flags
		btst	#sprite_cam_field_bit,d4		; is it a playfield-positioned object?
		beq.s	.drawObject_direct\@			; branch if 0 (on-screen positioning coordinate system)

	; --- Screen bounds check for Y-position ---
		sub.w	4(a5),d2				; subtract camera Y-position from object Y-position
		moveq	#32,d0					; set assumed height to 32px
		btst	#sprite_customheight_bit,d4		; is custom height flag set?
		beq.s	.checkY\@				; if not, assume height as 32px
		move.b	obHeight(a0),d0				; use custom height
	.checkY\@:
		move.w	#224,d1					; 224 = SCREEN_HEIGHT
		add.w	d0,d1					; d1 = SCREEN_HEIGHT + obHeight(a0)
		add.w	d0,d1					; d1 = SCREEN_HEIGHT + 2*obHeight(a0)
		add.w	d2,d0					; d0 = Y + obHeight(a0)
		andi.w	#$7FF,d0				; wrap Y-position to level height
		cmp.w	d1,d0					; is sprite vertically on screen?
		bcc.s	.setNotVisible\@			; if not, don't render sprite

	; --- Screen bounds check for X-position ---
		sub.w	(a5),d3					; subtract camera X-position from object X-position
		moveq	#0,d0
		move.b	obActWid(a0),d0				; get sprite display width (Note: there is no such thing as "assumed width"!)
		move.w	#320,d1					; 320 = SCREEN_WIDTH
		add.w	d0,d1					; d1 = SCREEN_WIDTH + obActWid(a0)
		add.w	d0,d1					; d1 = SCREEN_WIDTH + 2*obActWid(a0)
		add.w	d3,d0					; d0 = X + obActWid(a0)
		cmp.w	d1,d0					; is sprite horizontally on screen?
		bcc.s	.setNotVisible\@			; if not, don't render sprite

	; --- Load sprite mappings ---
	.drawObject\@:
		addi.w	#$80,d3					; add VDP sprite start to X-position
		addi.w	#$80,d2					; add VDP sprite start to Y-position

	.drawObject_direct\@:
		move.l	obMap(a0),d1				; get object mappings
		beq.s	.setNotVisible\@			; failsafe in case mappings aren't set
		movea.l	d1,a1					; load object mappings into address register

		moveq	#1-1,d1					; write only one sprite for raw-mappings
		btst	#sprite_rawmappings_bit,d4		; is "raw-mappings" flag on?
		bne.s	.drawFrame\@				; if yes, branch (assume mappings point to a single sprite piece)

		move.b	obFrame(a0),d1
		add.w	d1,d1					; MJ: changed from byte to word (we want more than 7F sprites)
		adda.w	(a1,d1.w),a1				; get mappings frame address
		move.w	(a1)+,d1				; get number of sprite pieces in frame
		subq.w	#1,d1					; subtract 1 for dbf
		bmi.s	.nextObject\@				; skip rendering if mapping was blank

	; --- Do the actual sprite mapping rendering ---
	.drawFrame\@:
		bsr.w	BuildSpr_Draw
		bset	#sprite_rendered_bit,obRender(a0)	; set object as visible
		bra.s	.nextObject\@

	; --- Set/clear rendered flag and loop ---
	.setNotVisible\@:
		bclr	#sprite_rendered_bit,obRender(a0)	; set object as not visible

	.nextObject\@:
		addq.w	#2,d6					; advance to next entry in layer
		subq.w	#2,(a4)					; decrement number of objects left
		bne.w	.objectLoop\@				; if entries remain, loop

.nextPriority\@:
		lea	spritelayer_size(a4),a4			; advance to next layer (each layer is $80 bytes)
	endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for all BuildSpr_Draw functions, to visualize the differences between them.
; All four variants work on the same basic principle, only coming with
; modifications for the flipping.
; ---------------------------------------------------------------------------

buildsprite:	macro xflip,yflip

.loopSpritePieces:
	; --- Sprite limit check ---
		subq.b	#1,d7					; check sprite limit
		ble.s	.abort\@				; if all sprite slots are taken up, abort process

	; --- Y-position ---
		move.w	(a1)+,d0				; get relative Y-offset
		if yflip
			neg.w	d0
			move.b	(a1),d4				; get dimensions of sprite piece
			lsl.b	#3,d4
			andi.w	#%11000,d4
			addq.w	#8,d4
			sub.w	d4,d0				; d0 = flipped Y-position
		endif
		add.w	d2,d0					; add base Y-position

		; Y-culling for individual pieces (assuming 32px, max height)
		andi.w	#$1FF,d0	
		cmpi.w	#$80-32,d0
		bls.s	.yCull\@
		cmpi.w	#$80+224+32,d0
		bhs.s	.yCull\@

		; Piece is vertically on screen
		swap	d0					; write together with next (optimization)

	; --- Sprite width/height and Sprite Link ---
		move.w	(a1)+,d0				; get dimensions of sprite piece (WWHH) (preshifted <<8)
		addq.b	#1,d5					; increase total sprites counter
		move.b	d5,d0					; write sprite link to buffer
		move.l	d0,(a2)+

	; --- VRAM settings / art tile / flipping ---
		move.w	(a1)+,d0
		add.w	a3,d0					; add base art tile offset of object
		if xflip|yflip
			eori.w	#xflip<<11|yflip<<12,d0		; toggle X-flip ($800) and/or Y-flip ($1000) in VDP
		endif
		swap	d0					; write together with next (optimization)

	; --- X-position ---
		move.w	(a1)+,d0				; get relative X-offset
		if xflip
			neg.w	d0
			move.b	-6(a1),d4			; get dimensions of sprite piece
			add.b	d4,d4
			andi.w	#%11000,d4
			addq.w	#8,d4
			sub.w	d4,d0				; d0 = flipped X-position
		endif
		add.w	d3,d0					; add X-position

		; Y-culling for individual pieces (assuming 32px, max height)
		andi.w	#$1FF,d0				; wrap every 512px (sprite plane size) for the mask prevention check
		cmpi.w	#$80-32,d0
		bls.s	.xCull\@
		cmpi.w	#$80+320+32,d0
		bhs.s	.xCull\@

	.finish\@:
		; Piece is horizontally on screen
		move.l	d0,(a2)+

	; --- Loop for all pieces in mapping ---
	.next\@:
		dbf	d1,.loopSpritePieces			; loop for all pieces in mapping
		rts						; done
	
	; --- Culling individual sprite pieces in mapping ---
	.yCull\@:
		; sprite buffer (a2) hasn't been advanced yet, no change required
		addq.w	#6,a1					; skip remaining sprite piece definitions
		dbf	d1,.loopSpritePieces			; loop for all pieces in mapping
		rts						; done

	.xCull\@:
	    if (xflip|yflip)=0					; intentional masks can only happen if they aren't flipped (optimization)
		tst.b	(v_skipspriteculling).w			; is X-sprite culling disabled? (for the title screen torso mask)
		bne.s	.finish\@				; if yes, don't cull sprite after all
	    endif

		; sprite piece (a1) has already fully advanced, no change required
		subq.w	#4,a2					; undo first write to sprite buffer
		subq.w	#1,d5					; undo sprite link increase
		addq.w	#1,d7					; undo sprite count increase
		dbf	d1,.loopSpritePieces			; loop for all pieces in mapping
		rts						; done

	; --- Total abortion if limit of 80 sprites is reached ---
	.abort\@:
		addq.b	#1,d5					; sprite limit exhausted
		addq.w	#4,sp					; don't return to sprite render loop
		bra	BuildSprites_Finalize			; skip straight to finalization
	endm


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) into proper Mega Drive sprites
; and queue them into a linked sprite buffer table (transferred in VBlank).
; ---------------------------------------------------------------------------

BuildSprites:
		lea	(v_spritequeue).w,a4			; a4 = input sprite layers (i.e. set from DisplaySprite)
		lea	(v_spritetablebuffer).w,a2		; a2 = target linked sprite list (transferred in VBlank)
		moveq	#0,d5					; d5 = will be used as counter for the sprite linking
		moveq	#sprites_max,d7				; d7 = will be used to abort the process if sprite queue is full
		lea	(v_screenposx).w,a5			; load camera pointers for coordinate system

	; --- Layer -0.5 ---
		tst.b	(v_draw_hud).w				; is HUD rendering on? (Level_started_flag in S2)
		beq.s	.noHud					; if not, branch
		bsr.w	BuildHUD				; draw HUD directly to sprite buffer
	.noHud:

	; --- Layers 0 and 1 ---
		spritelayer					; layer 0
		spritelayer					; layer 1

	; --- Layer 1.5 ---
		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noRings				; if not, branch
		bsr.w	BuildRings				; render ring sprites
	.noRings:

	; --- Layer 2 ---
		spritelayer					; layer 2

	; --- Layer 2.5 ---
		tst.b	(v_draw_hud).w				; are rings even meant to get rendered? (Level_started_flag in S2)
		beq.s	.noLossRings				; if not, branch
		bsr.w	BuildRings_Loss				; render ring sprites
	.noLossRings:

	; --- Layers 3-7 ---
		spritelayer					; layer 3
		spritelayer					; layer 4
		spritelayer					; layer 5
		spritelayer					; layer 6
		spritelayer					; layer 7

	; --- Finalization ---
BuildSprites_Finalize:
		move.b	d5,(v_spritecount).w			; write number of rendered sprites to debug var

		tst.b	d7					; check if sprite limit was exhausted
		ble.s	.spriteLimit				; if yes, branch
		move.l	#0,(a2)					; unlink last sprite
		rts
; ---------------------------------------------------------------------------

	.spriteLimit:
		move.b	#0,-5(a2)				; unlink penultimate sprite
		rts
; End of function BuildSprites

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to convert a object mapping frame (with multiple sprite pieces)
; into valid, linked Mega Drive sprites and buffer them, with flipping.
; ---------------------------------------------------------------------------

BuildSpr_Draw:
		movea.w	obGfx(a0),a3				; get VRAM settings for object (art tile, palette line, priority flag)

ChkDrawSprite:
		lsr.b	d4					; is X-flip flag set?
		bcs.s	BuildSpr_FlipX				; if yes, branch
		lsr.b	d4					; is Y-flip flag set?
		bcs.w	BuildSpr_FlipY				; if yes, branch

BuildSpr_Normal:
		buildsprite	0,0
; ---------------------------------------------------------------------------

BuildSpr_FlipX:
		lsr.b	d4					; is Y-flip flag set as well?
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
; Heavily optimized HUD renderer
; ---------------------------------------------------------------------------

HUD_BaseX: equ $80+$10
HUD_BaseY: equ $80+$88

HUD_DirectMaps:		; Y-position			Size+Link	VRAM settings			X-position
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D01,		$8000+ArtTile_HUDScore_SCOR,	$0000+HUD_BaseX	; "SCOR"
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D02,		$8000+ArtTile_HUDScore_E,	$0020+HUD_BaseX	; "E" and first three score digits
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D03,		$8000+ArtTile_HUDScore_E_2,	$0040+HUD_BaseX	; last four score digits
								
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0D04,		$8000+ArtTile_HUDTime_TIME,	$0000+HUD_BaseX	; "TIME"
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0D05,		$8000+ArtTile_HUDTimeMins,	$0028+HUD_BaseX	; minutes and seconds
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0906,		$8000+ArtTile_HUDTimeCentis,	$0048+HUD_BaseX	; centiseconds
								
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0D07,		$8000+ArtTile_HUDRings_RING,	$0000+HUD_BaseX	; "RING"
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0108,		$8000+ArtTile_HUDScore_SCOR,	$0020+HUD_BaseX	; "S" (stolen from Score)
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0909,		$8000+ArtTile_HUDRings,		$0030+HUD_BaseX	; rings counter
								
	if Enable_InfiniteLives=0	                       	
		dc.w	($0040+HUD_BaseY)&$FFFF,	$050A,		$8000+ArtTile_Lives_Counter,	$0000+HUD_BaseX	; lives counter (Sonic icon)
		dc.w	($0040+HUD_BaseY)&$FFFF,	$0D0B,		$8000+ArtTile_Lives_Counter_2,	$0010+HUD_BaseX	; lives counter ("SONIC x N" text)
	endif

	if LagFrameCounter
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0C0C-(2*Enable_InfiniteLives),	$8000+ArtTile_HUDLagFrame,	$0108+HUD_BaseX	; lag frame counter
	endif
HUD_DirectMaps_End:

HUD_SpriteCount: equ (HUD_DirectMaps_End-HUD_DirectMaps)/8

; ---------------------------------------------------------------------------

BuildHUD:
		lea	HUD_DirectMaps(pc),a3			; load precalculated HUD mappings

	rept HUD_SpriteCount
		move.l	(a3)+,(a2)+				; transfer Y-position and WH+Link
		move.l	(a3)+,(a2)+				; transfer VRAM settings and X-position
	endr
		addi.w	#HUD_SpriteCount,d5			; increase sprite link counter
		subi.w	#HUD_SpriteCount,d7			; decrease remaining sprite counter

		; HUD Blinking
		btst	#3,(v_framebyte).w			; only blink HUD every 8 frames
		bne.s	.return					; branch otherwise
		tst.b	(v_draw_hud).w				; is level still fading in?
		bmi.s	.return					; if yes, don't blink HUD yet
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		blo.s	.chkRings				; if not, branch
		ori.w	#Tile_Pal2,(v_spritetablebuffer+$1C).w	; make TIME HUD blink red
	.chkRings:
		tst.w	(v_rings).w				; do you have any rings?
		bne.s	.return					; if so, branch		
		ori.w	#Tile_Pal2,(v_spritetablebuffer+$34).w	; make RING HUD blink red
		ori.w	#Tile_Pal2,(v_spritetablebuffer+$3C).w	; same for the "S"
	
	.return:
		rts
; End of function BuildHUD


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to render regular ring sprites (S3K Rings Manager)
; ---------------------------------------------------------------------------

BuildRings:
		movea.l	(v_ringwindow_start).w,a0		; load start of ring layout in ROM
		move.l	(v_ringwindow_end).w,d0			; load ring layout end address
		sub.l	a0,d0					; is start = end?
		beq.s	.return					; if yes, nothing to do (no rings on-screen)

		movea.w	(v_ringstates_pointer).w,a1		; load ring status start address
		lea	(v_screenposx).w,a3			; load camera X-position

	.loop:
		tst.b	d7					; is sprite limit exhausted?
		beq.s	.return					; if yes, abort ring rendering
		subq.b	#1,d7					; decrease remaining sprite slots
		
		move.b	(a1)+,d1				; has this ring been collected and finished sparkling?
		bmi.w	.next					; if yes, check next ring
		move.w	(a0),d3					; get ring X-position
		sub.w	(a3),d3					; subtract camera X-position
		addi.w	#$80-8,d3				; add VDP sprite start - half of ring width (16/2 = 8px)

		move.w	2(a0),d2				; get ring Y-position
		sub.w	4(a3),d2				; subtract camera Y-position (4(a3) = v_screenposy)
		addi.w	#8,d2					; add half of ring height (16/2 = 8px)
		andi.w	#$7FF,d2				; apply vertical screen wrap
		cmpi.w	#224+16,d2				; is ring below visible screen?
		bhs.s	.next					; if yes, don't render
		addi.w	#$80-16,d2				; add VDP sprite start and undo earlier 8px offset

		move.w	d2,(a2)+				; store sprite Y-position in sprite buffer

		andi.w	#$000F,d1				; extract stored ring frame value
		bne.s	.renderRing				; does this ring have a custom frame ID? if yes, use that (sparkle for collected rings)
		moveq	#0,d1					; force frame 0 for all smooth ring frames (updated in VRAM)
	.renderRing:
		move.b	#5,(a2)+				; store sprite width/height in sprite buffer

		addq.b	#1,d5					; increase total sprites counter
		move.b	d5,(a2)+				; store sprite link in sprite buffer

		add.w	d1,d1					; double frame ID for word-based indexing
		move.w	Map_RingsCompact(pc,d1.w),(a2)+		; get VRAM settings and store in sprite buffer

		move.w	d3,(a2)+				; store sprite X-position in sprite buffer

	.next:
		addq.w	#4,a0					; advance to next ring in ROM
		subq.w	#4,d0					; decrement number of remaining rings to handle
		bne.w	.loop					; if we've got more rings to render, loop

	.return:
		rts						; rings manager rings sprite rendering done
; ---------------------------------------------------------------------------

; Compact rings mappings for optimization purposes
Map_RingsCompact:
		dc.w ArtTile_Ring+$0|Tile_Pal2			; 0 - ring
		dc.w ArtTile_Ring+$4|Tile_Pal2			; 1 - ring
		dc.w ArtTile_Ring+$8|Tile_Pal2			; 2 - ring
		dc.w ArtTile_Ring+$4|Tile_Pal2|$800		; 3 - ring
			     
		dc.w ArtTile_Ring+$A|Tile_Pal2			; 4 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$1800		; 5 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$0800		; 6 - sparkle
		dc.w ArtTile_Ring+$A|Tile_Pal2|$1000		; 7 - sparkle

		dc.w 0, 0					; blank frames in case of overflow

; End of function BuildRings

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to render lost ring sprites, filled in Objet 37.
; ---------------------------------------------------------------------------

BuildRings_Loss:
		lea	(v_lostring_spritequeue).w,a3		; load queued lost ring sprites
		move.w	(a3),d0					; get entry count
		beq.w	.return					; are there any entries to render? if not, exit
		clr.l	(a3)+					; clear render loop entry count for next time (and a3 += 4)

		lsr.w	#2,d0					; divide entry count by 4
		subq.w	#1,d0					; minus 1 for dbf

		move.w	#ArtTile_Ring_Loss|Tile_Pal2,d3		; all lost rings use the same art tile
		swap	d3					; unchaging in the upper word of d3 for optimization
		move.w	#$0500,d1				; dimension (preshifted by <<8) is always the same (2x2)

	.loop:
		tst.b	d7					; is sprite limit exhausted?
		beq.s	.return					; if yes, abort ring rendering
		subq.b	#1,d7					; decrease remaining sprite slots

		move.w	(a3)+,d2				; get screen-fixed Y-position for ring
		swap	d2					; swap Y-position into upper word
		move.w	d1,d2					; move preshifted dimension to lower word
		addq.b	#1,d5					; increase sprite link count
		move.b	d5,d2					; move new sprite link count to lower byter 
		move.l	d2,(a2)+				; write Y-position, dimension, and link number to sprite buffer

		move.w	(a3)+,d3				; get screen-fixed X-position for ring
		move.l	d3,(a2)+				; write art tile (unchaging) and X-position to sprite buffer

	.next:
		dbf	d0,.loop				; if we've got more rings to render, loop

	.return:
		rts						; return
; End of function BuildRings_Loss


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if an object is off screen
;
; output:
;	d0 = 0 if on screen, 1 if off screen
; ---------------------------------------------------------------------------

ChkObjectVisible:
		move.w	obX(a0),d0				; get object x-position
		sub.w	(v_screenposx).w,d0			; subtract screen x-position
		bmi.s	.offscreen				; branch if object is off screen to the left
		cmpi.w	#320,d0					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the right

		move.w	obY(a0),d1				; get object y-position
		sub.w	(v_screenposy).w,d1			; subtract screen y-position
		bmi.s	.offscreen				; branch if object is off screen to the top
		cmpi.w	#224,d1					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the bottom

		moveq	#0,d0					; set Z-flag (object on screen)
		rts
; ---------------------------------------------------------------------------

.offscreen:
		moveq	#1,d0					; clear Z-flag (object off screen)
		rts
; End of function ChkObjectVisible


; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if an object is off screen
; More precise than above subroutine, taking width into account
;
; output:
;	d0 = 0 if on screen, 1 if off screen
; ---------------------------------------------------------------------------

ChkPartiallyVisible:
		moveq	#0,d1					; clear d1 (obActWid is byte-sized)
		move.b	obActWid(a0),d1				; get object's display width
		move.w	obX(a0),d0				; get object x-position
		sub.w	(v_screenposx).w,d0			; subtract screen x-position
		add.w	d1,d0					; add object display width
		bmi.s	.offscreen				; branch if object is off screen to the left
		add.w	d1,d1					; double width for undoing above addition and right-side check
		sub.w	d1,d0					; sub object display width
		cmpi.w	#320,d0					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the right

		moveq	#0,d1					; clear d1 (obHeight is byte-sized)
		move.b	obHeight(a0),d1				; get object's height
		move.w	obY(a0),d0				; get object's y-position
		sub.w	(v_screenposy).w,d0			; subtract screen y-position
		add.w	d1,d0					; add object height
		bmi.s	.offscreen				; branch if object is off screen to the top
		add.w	d1,d1					; double height for undoing above addition and for bottom-side check
		sub.w	d1,d0					; su object height
		cmpi.w	#224,d1					; is object on screen?
		bge.s	.offscreen				; if not, object is off screen to the bottom

		moveq	#0,d0					; set Z-flag (object on screen)
		rts
; ---------------------------------------------------------------------------

.offscreen:
		moveq	#1,d0					; clear Z-flag (object off screen)
		rts
; End of function ChkPartiallyVisible
