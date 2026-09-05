; ===========================================================================
; ---------------------------------------------------------------------------
; Object 29 - points that appear from destroyed badniks and other places
; (Recoded to be a singleton object at v_points.)
; ---------------------------------------------------------------------------

Points:
		move.l	#Poi_Slower,obID(a0)			; advance to Poi_Slower
		move.l	#Map_Points,obMap(a0)			; set mappings
		move.w	#ArtTile_Points|Tile_Pal2,obGfx(a0)	; set art tile and palette
		move.b	#sprite_cam_field,obRender(a0)		; set to playfield-positioned mode
		move.w	#spr_prio1,obPriority(a0)		; set sprite priority (above Sonic)
		move.b	#16/2,obActWid(a0)			; set display width
		move.w	#-$300,obVelY(a0)			; move points object upwards

		; Load DPLCs for new points art and queue for DMA
		move.b	obFrame(a0),d0				; load current frame to d0
		lea	PointsDynPLC(pc),a2			; load shield/stars DPLCs to a2
		move.l	#Art_Points,d6				; load uncompressed graphics pointer to d6
		move.w	#ArtTile_Points*tile_size,d4		; load art tile x $20 to d4 to get VRAM offset
		jsr	(LoadDynPLC).l				; load DPLCs
; ---------------------------------------------------------------------------

Poi_Slower:	; Routine 2
		tst.w	obVelY(a0)				; has point object stopped moving up?
		bpl.w	DeleteObject				; if yes, delete it
		bsr.w	SpeedToPos				; update position based on velocity
		addi.w	#$18,obVelY(a0)				; reduce upward speed
		DisplaySprite					; display points object
		rts

; ===========================================================================

Map_Points:	include	"_maps/Points.asm"
PointsDynPLC:	include	"_maps/Points - DPLC.asm"
