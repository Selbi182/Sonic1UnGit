; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5C - metal pylons in foreground (SLZ)
; ---------------------------------------------------------------------------

Pylon:
		move.l	#Pyl_Display,obID(a0)
		move.l	#Map_Pylon,obMap(a0)			; set mappings
		move.w	#ArtTile_SLZ_Pylon|Tile_Prio,obGfx(a0)	; set art tile and priority flag
		move.b	#32/2,obActWid(a0)			; set display width
		move.b	#sprite_cam_screen,obRender(a0)		; set to screen-fixed positioning mode
; ---------------------------------------------------------------------------

Pyl_Display:
		move.l	(v_screenposx).w,d1			; get current camera X-position
		add.l	d1,d1					; move pylons twice as fast as camera
		swap	d1					; use upper word for position
		neg.w	d1					; make pylons move opposite to the camera direction
		move.w	d1,obX(a0)				; set new X-position

		move.l	(v_screenposy).w,d1			; get current camera Y-position
		add.l	d1,d1					; move pylons twice as fast as camera
		swap	d1					; user upper word for position
		andi.w	#$3F,d1					; vertically wrap pylon every 64px
		neg.w	d1					; make pylons move opposite to the camera direction
		addi.w	#$100,d1				; add base Y-position to move it into visible frame
		move.w	d1,obY(a0)				; set new Y-position

		DisplaySprite
		rts				; keep displaying foreground pylons
; ===========================================================================

Map_Pylon:	include	"_maps/Pylon.asm"
