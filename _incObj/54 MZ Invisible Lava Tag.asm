; ===========================================================================
; ---------------------------------------------------------------------------
; Object 54 - invisible lava tag / hurt marker (MZ)
; ---------------------------------------------------------------------------

LTag_ColTypes:	; collision types for ReactToItem
		dc.b	col_64x64|col_hurt 	; subtype 00 - damaging, 64x64  (small)
		dc.b	col_128x64|col_hurt	; subtype 01 - damaging, 128x64 (medium)
		dc.b	col_256x64|col_hurt	; subtype 02 - damaging, 256x64 (large)
		even
; ===========================================================================

LavaTag:
		move.l	#LTag_ChkDel,obID(a0)
		moveq	#0,d0					; clear d0 for word-based addressing
		move.b	obSubtype(a0),d0			; get size in subtype (0-2)
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)	; set collision response type/size based on subtype
		move.l	#Map_LTag,obMap(a0)			; set mappings (blank)
		move.b	#sprite_rendered|sprite_cam_field,obRender(a0) ; set object visible flag ($80) and playfield-positioned mode (4)
; ---------------------------------------------------------------------------

LTag_ChkDel:	; Routine 2
		out_of_range.w	DeleteObject,obX(a0)
		rts						; don't delete, but also don't display
; ===========================================================================

Map_LTag:	include	"_maps/Lava Tag.asm"
