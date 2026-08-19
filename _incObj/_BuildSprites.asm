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
		move.w	#224,d1
		add.w	d0,d1					; d1 = SCREEN_HEIGHT + obHeight(a0)
		add.w	d0,d1					; d1 = SCREEN_HEIGHT + 2*obHeight(a0)
		add.w	d2,d0					; d0 = Y + obHeight(a0)
		cmp.w	d1,d0
		bhs.s	.setNotVisible\@

	; --- Screen bounds check for X-position ---
		sub.w	(a5),d3					; subtract camera X-position from object X-position
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	#320,d1
		add.w	d0,d1					; d1 = SCREEN_WIDTH + obActWid(a0)
		add.w	d0,d1					; d1 = SCREEN_WIDTH + 2*obActWid(a0)
		add.w	d3,d0					; d0 = X + obActWid(a0)
		cmp.w	d1,d0
		bhs.s	.setNotVisible\@

	; --- Load sprite mappings ---
	.drawObject\@:
		addi.w	#$80,d3					; add VDP sprite start to X-position
		addi.w	#$80,d2					; add VDP sprite start to Y-position
		andi.w	#$7FF,d2				; wrap Y-position to level height

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
		bne.s	.x					; if non-zero, branch
		addq.w	#1,d0					; force zero X-position to non-zero (avoid unwanted sprite masking)
	.x:	move.l	d0,(a2)+

	; --- Loop for all pieces in mapping ---
		dbf	d1,.loopSpritePieces

	.return:
		rts
	
	.abort\@:
		addq.b	#1,d5
		addq.w	#4,sp
		bra	BuildSprites_Finalize
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
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D01,		($8000+ArtTile_HUD)&$FFFF,	$0000+HUD_BaseX	; "SCOR"
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D02,		($8018+ArtTile_HUD)&$FFFF,	$0020+HUD_BaseX	; "E" and first three score digits
		dc.w	($FF80+HUD_BaseY)&$FFFF,	$0D03,		($8020+ArtTile_HUD)&$FFFF,	$0040+HUD_BaseX	; last four score digits
	
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0D04,		($8010+ArtTile_HUD)&$FFFF,	$0000+HUD_BaseX	; "TIME"
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0D05,		($8028+ArtTile_HUD)&$FFFF,	$0028+HUD_BaseX	; time counter
		dc.w	($FF90+HUD_BaseY)&$FFFF,	$0906,		($7FFA+ArtTile_HUD)&$FFFF,	$0048+HUD_BaseX	; centiseconds
	
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0D07,		($8008+ArtTile_HUD)&$FFFF,	$0000+HUD_BaseX	; "RING"
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0108,		($8000+ArtTile_HUD)&$FFFF,	$0020+HUD_BaseX	; "S"
		dc.w	($FFA0+HUD_BaseY)&$FFFF,	$0909,		($8030+ArtTile_HUD)&$FFFF,	$0030+HUD_BaseX	; rings counter
	if Enable_InfiniteLives=0	
		dc.w	($0040+HUD_BaseY)&$FFFF,	$050A,		($810A+ArtTile_HUD)&$FFFF,	$0000+HUD_BaseX	; lives counter (Sonic icon)
		dc.w	($0040+HUD_BaseY)&$FFFF,	$0D0B,		($810E+ArtTile_HUD)&$FFFF,	$0010+HUD_BaseX	; lives counter ("SONIC x N" text)
		dc.w	($0040+HUD_BaseY)&$FFFF,	$0D0C,		($810E+ArtTile_HUD)&$FFFF,	$0010+HUD_BaseX	; lives counter ("SONIC x N" text)
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
		addi.w	#$2000,(v_spritetablebuffer+$1C).w	; make TIME HUD blink red
	.chkRings:
		tst.w	(v_rings).w				; do you have any rings?
		bne.s	.return					; if so, branch		
		addi.w	#$2000,(v_spritetablebuffer+$34).w	; make RING HUD blink red
		addi.w	#$2000,(v_spritetablebuffer+$3C).w	; same for the "S"
	
	.return:
		rts
; End of function BuildHUD


