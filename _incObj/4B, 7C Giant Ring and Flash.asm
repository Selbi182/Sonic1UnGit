; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4B - Giant Ring for entry to Special Stage
; ---------------------------------------------------------------------------

GiantRing:
		move.l	#Map_GRing,obMap(a0)			; set mappings
		move.w	#ArtTile_Giant_Ring|Tile_Pal2,obGfx(a0)	; set art tile and palette line
		ori.b	#sprite_cam_field,obRender(a0)		; set to playfield positioned mode
		move.b	#128/2,obActWid(a0)			; set sprite display width

		tst.b	obRender(a0)				; is giant ring on screen?
		bpl.s	GRing_Display				; if not, branch
		cmpi.b	#ss_emeralds_num,(v_emeralds).w		; do you have all 6 emeralds?
		beq.w	DeleteObject				; if yes, branch
		cmpi.w	#ss_giantring_rings,(v_rings).w		; do you have at least 50 rings?
		bhs.s	GRing_Okay				; if yes, branch
		rts						; otherwise, don't show giant ring
; ===========================================================================

GRing_Okay:
		move.l	#GRing_Display,obID(a0)			; set to GRing_Display
		move.w	#spr_prio2,obPriority(a0)		; set sprite priority
		move.b	#col_16x32|col_item,obColType(a0)	; set col type (ReactToItem will advance obRoutine on collection)
		move.b	#1,(v_gfxbigring).w			; start loading giant ring graphics
; ---------------------------------------------------------------------------

GRing_Display:	; Routine 2
		RememberStateXY
		rts
; ===========================================================================

GRing_Collect:	; optimized to change ring directly into flash object
		move.l	#Flash_ChkDel,obID(a0)			; set to Flash_ChkDel
		move.b	#col_none,obColType(a0)			; disable further collision with ring
		move.l	#Map_GRing,obMap(a0)
		move.w	#ArtTile_Giant_Ring|Tile_Pal2,obGfx(a0)
		ori.b	#sprite_cam_field,obRender(a0)		; set to playfield positioned mode
		move.w	#spr_prio0,obPriority(a0)		; set to maximum sprite priority
		move.b	#64/2,obActWid(a0)			; set sprite display width
		move.b	#2,(v_gfxbigring).w
		move.b	#-1,(v_ani2_frame).w

		move.w	(v_player+obX).w,d0			; get Sonic's X-position
		cmp.w	obX(a0),d0				; has Sonic entered the giant ring from the right?
		blo.s	.playSnd				; if not, branch
		bset	#sprite_xflip_bit,obRender(a0)		; set X-flip flag for flash object
	.playSnd:
		move.w	#sfx_GiantRing,d0			; set giant ring sound
		jsr	(QueueSound2).l				; play it
; ---------------------------------------------------------------------------

Flash_ChkDel:	; Routine 2
		subq.b	#1,obTimeFrame(a0)			; decrement delay until next frame
		bpl.s	.return					; if time remains, branch
		move.b	#1,obTimeFrame(a0)			; reset delay to 2 frames
		addq.b	#1,(v_ani2_frame).w
		cmpi.b	#8,(v_ani2_frame).w	                ; has animation finished?
		bhs.s	.deleteSonic		                ; if yes, branch
		cmpi.b	#3,(v_ani2_frame).w	                ; is 3rd frame displayed?
		bne.s   .return		                        ; if not, branch

		move.b	#id_Null,(v_player+obAnim).w		; make Sonic invisible
		move.b	#1,(f_bigring).w			; set flag that giant ring was collected
		clr.b	(v_invinc).w				; remove invincibility
		clr.b	(v_shield).w				; remove shield

	.return:
		DisplaySprite
		rts						; return
; ---------------------------------------------------------------------------

.deleteSonic:
		clr.l	(v_player+obID).w			; delete Sonic object
		clr.b	(v_gfxbigring).w			; stop loading giant ring graphics
		bra.w	DeleteObject				; delete flash

; ===========================================================================

Map_GRing:	include	"_maps/Giant Ring.asm"
