; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to smash a block into fragment objects (GHZ walls and MZ blocks)
; 
; inputs:
; 	d1 = number of fragments to spawn - 1
;	d2 = base gravity (only needed for edge cases)
;	a4 = array of X/Y velocities for each fragment (2 words each)
; ---------------------------------------------------------------------------

SmashObject:
		moveq	#0,d0					; clear d0 (obFrame is a byte)
		move.b	obFrame(a0),d0				; get current frame ID
		add.w	d0,d0					; double it for word-based indexing
		movea.l	obMap(a0),a3				; get object mappings set
		adda.w	(a3,d0.w),a3				; find mappings for current frame
		addq.w	#1,a3					; skip over sprite piece count
		bset	#sprite_rawmappings_bit,obRender(a0)	; set "raw-mappings" flag
		move.b	obID(a0),d4				; copy object ID
		move.b	obRender(a0),d5				; copy render flags
		movea.l	a0,a1					; replace current object with first fragment
		bra.s	.loadFirstFrag				; skip over object RAM search
; ===========================================================================

.loopFragments:
		bsr.w	FindNextFreeObj				; find a free object slot after the previous one
		bne.s	.playSmashSound				; if object RAM is full, abort process
		addq.w	#5,a3					; advance to next sprite piece in mappings (each piece is 5 bytes)

	.loadFirstFrag:
		move.b	#4,obRoutine(a1)			; set routine to 4 (assumed to be a simple ObjectFall, display, delete)
		move.b	d4,obID(a1)				; use same object ID as parent
		move.l	a3,obMap(a1)				; use same mappings as parent
		move.b	d5,obRender(a1)				; use same render flags as parent (including "raw-mappings")
		move.w	obX(a0),obX(a1)				; use same X-position as parent
		move.w	obY(a0),obY(a1)				; use same Y-position as parent
		move.w	obGfx(a0),obGfx(a1)			; use same art tile as parent
		move.w	obPriority(a0),obPriority(a1)		; use same sprite priority as parent
		move.b	obActWid(a0),obActWid(a1)		; use same display width as parent

		move.w	(a4)+,obVelX(a1)			; load next X-speed from input array
		move.w	(a4)+,obVelY(a1)			; load next Y-speed from input array

		dbf	d1,.loopFragments			; loop until all fragments have been spawned

.playSmashSound:
		move.w	#sfx_WallSmash,d0			; set smashing sound
		jmp	(QueueSound2).l				; play it
; End of function SmashObject
