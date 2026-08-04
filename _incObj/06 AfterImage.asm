; ---------------------------------------------------------------------------
; Object 06 - After Image effect (ported from S3K "Obj_HyperSonicKnux_Trail")
; ---------------------------------------------------------------------------

AfterImage:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	After_Index(pc,d0.w),d1
		jmp	After_Index(pc,d1.w)
; ===========================================================================
After_Index:	dc.w After_Init-After_Index
		dc.w After_Main-After_Index
; ===========================================================================

After_Init:
		addq.b	#2,obRoutine(a0)		; Advance obRoutine to "After_Main"
		move.l	#Map_Sonic,obMap(a0)
		move.w	#ArtTile_Sonic,obGfx(a0)
		move.b	#2,obPriority(a0)
		move.b	#$18,obWidth(a0)
		move.b	#$18,obHeight(a0)
		move.b	#4,obRender(a0)

After_Main:
		tst.b	(v_shoes).w			; Have Speed Shoes expired?
		beq.w	DeleteObject			; If so, branch and delete

		moveq	#$C,d1				; This will be subtracted from v_trackpos, giving the object an older entry
		btst	#0,(v_framecount+1).w		; Even frame? (Think of it as 'every other number' logic)
		beq.s	.evenframe			; If so, branch
		moveq	#$14,d1				; On every other frame, use a different number to subtract, giving the object an even older entry

	.evenframe:
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)			; Use previous player obX
		move.w	(a1)+,obY(a0)			; Use previous player obY

		move.b	(v_player+obFrame).w,obFrame(a0)	; Use player's current obFrame
		move.b	(v_player+obRender).w,obRender(a0)	; Use player's current obRender
		move.b	(v_player+obPriority).w,obPriority(a0)	; Use player's current obPriority
		bra.w	DisplaySprite
