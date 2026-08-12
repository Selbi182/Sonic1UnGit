; ===========================================================================
; ---------------------------------------------------------------------------
; Object 49 - invisible waterfall sound effect trigger (GHZ)
; ---------------------------------------------------------------------------

WaterSound:
		move.l	#WSnd_PlaySnd,obID(a0)
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
; ---------------------------------------------------------------------------

WSnd_PlaySnd:	; Routine 2
		move.b	(v_vblank_byte).w,d0			; get low byte of VBlank counter
		andi.b	#$3F,d0					; only play waterfall sound effect every 64 frames
		bne.s	.chkDel					; branch on other frames
		move.w	#sfx_Waterfall,d0			; set waterfall SFX sound command
		jsr	(QueueSound2).l				; play it

	.chkDel:
		out_of_range.w	DeleteObject			; check if object has gone offscreen and delete it if so
		rts						; return (do not display any sprite)
; ===========================================================================
