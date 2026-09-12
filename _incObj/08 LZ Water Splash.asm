; ===========================================================================
; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
; ---------------------------------------------------------------------------

Splash:
		move.l	#Spla_Display,obID(a0)			; advance to Spla_Display
		move.l	#Map_Splash,obMap(a0)			; set mappings
		ori.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio1,obPriority(a0)		; set sprite priority (above Sonic)
		move.b	#32/2,obActWid(a0)			; set display width
		move.w	#ArtTile_LZ_Splash|Tile_Pal3,obGfx(a0)	; set art tile and palette line

		move.w	(v_player+obX).w,obX(a0)		; copy X-position from Sonic
; ---------------------------------------------------------------------------

Spla_Display:
		move.w	(v_waterpos1).w,obY(a0)			; copy Y-position from water height

		lea	(Ani_Splash).l,a1			; load splash animation script
		jsr	(AnimateSprite).l			; advance animation (will increase obRoutine on finish to delete)
		tst.b	obRoutine(a0)
		bne.s	Spla_Delete
		DisplaySprite
		rts
; ===========================================================================

Spla_Delete:
		jmp	(DeleteObject).l			; delete when animation is complete

; ===========================================================================

		include	"_anim/Water Splash.asm"
Map_Splash:	include	"_maps/Water Splash.asm"
