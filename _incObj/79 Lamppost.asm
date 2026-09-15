; ===========================================================================
; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------
lamp_origX:	equ objoff_30		; original x-axis position
lamp_origY:	equ objoff_32		; original y-axis position
lamp_time:	equ objoff_36		; length of time to twirl the lamp
; ---------------------------------------------------------------------------

Lamppost:
		move.l	#Lamp_Blue,obID(a0)			; advance to Lamp_Blue
		move.l	#Map_Lamp,obMap(a0)			; set mappings
		move.w	#ArtTile_Lamppost,obGfx(a0)		; set art tile
		move.b	#sprite_cam_field|sprite_customheight,obRender(a0) ; set to playfield-positioned mode and enable custom render height
		move.b	#16/2,obActWid(a0)			; set sprite display width
		move.b	#88/2,obHeight(a0)			; set sprite display height (otherwise lamppost culls too early below)
		move.w	#spr_prio5,obPriority(a0)		; set sprite priority

		respawn_entry.s	.fail
		btst	#0,(a2)
		bne.s	.red

		move.b	(v_lastlamp).w,d1			; get ID of last hit lamppost number
		andi.b	#$7F,d1					; clear bit 7 (see notes in Lamp_LoadInfo)
		move.b	obSubtype(a0),d2			; get new lamppost number
		andi.b	#$7F,d2					; clear bit 7
		cmp.b	d2,d1					; is this a "new" lamppost? (bigger ID than last hit one)
		blo.s	Lamp_Blue				; if yes, branch

	.red:
		bset	#0,(a2)
	.fail:
		move.l	#Lamp_Finish,obID(a0)			; goto Lamp_Finish next
		move.b	#3,obFrame(a0)				; use red lamppost frame
		bra.w	Lamp_Finish
; ===========================================================================

Lamp_Blue:	; Routine 2
		tst.w	(v_debuguse).w				; is debug mode being used?
		bne.w	.donothing				; if yes, branch
		tst.b	(f_playerctrl).w			; is object interaction disabled?
		bmi.w	.donothing				; if yes, branch

		move.b	(v_lastlamp).w,d1			; get ID of last hit lamppost number
		andi.b	#$7F,d1					; clear bit 7 (see notes in Lamp_LoadInfo)
		move.b	obSubtype(a0),d2			; get new lamppost number
		andi.b	#$7F,d2					; clear bit 7
		cmp.b	d2,d1					; is this a "new" lamppost? (bigger ID than last hit one)
		blo.s	.chkhit					; if yes, branch

		respawn_entry.s	.noEntry
		bset	#0,(a2)
.noEntry:
		move.l	#Lamp_Finish,obID(a0)			; goto Lamp_Finish next
		move.b	#3,obFrame(a0)				; use red lamppost frame
		bra.w	Lamp_Finish
; ===========================================================================

.chkhit:
		move.w	(v_player+obX).w,d0			; get Sonic's X-position
		sub.w	obX(a0),d0				; calculate X-distance from object
		addq.w	#8,d0					; shift range from [-8,+7] to [0,15]
		cmpi.w	#8+8,d0					; is Sonic in X-range?
		bhs.w	.donothing				; if not, branch

		move.w	(v_player+obY).w,d0			; get Sonic's Y-position
		sub.w	obY(a0),d0				; calculate Y-distance from object
		addi.w	#$40,d0					; shift range from [-64,+39] to [0,103] (top-favoring)
		cmpi.w	#$28+$40,d0				; is Sonic in Y-range?
		bhs.s	.donothing				; if not, branch

		move.w	#sfx_Lamppost,d0			; set lamppost sound
		jsr	(QueueSound2).l				; play its
		move.l	#Lamp_Finish,obID(a0)			; goto Lamp_Finish next

		jsr	(FindFreeObj).l				; find a free object slot
		bne.s	.storeInfo				; if object RAM is full, branch
		move.l	#Lamp_Twirl,obID(a1)			; load twirling lamp object
		move.w	obX(a0),lamp_origX(a1)			; remember base X-position
		move.w	obY(a0),lamp_origY(a1)			; remember base Y-position
		subi.w	#$18,lamp_origY(a1)			; move twirling object up a bit to align it
		move.l	#Map_Lamp,obMap(a1)			; set mappings
		move.w	#ArtTile_Lamppost,obGfx(a1)		; set art tile
		move.b	#sprite_cam_field,obRender(a1)		; set to playfield positioning mode
		move.b	#16/2,obActWid(a1)			; set sprite display width
		move.w	#spr_prio4,obPriority(a1)		; set sprite priority
		move.b	#2,obFrame(a1)				; use twirling object to "red ball only" frame
		move.w	#32,lamp_time(a1)			; set twirling time to 32 frames

	; .fail:
	.storeInfo:
		move.b	#1,obFrame(a0)				; use touched lamppost to "post only" frame

		bsr.w	Lamp_StoreInfo				; store all current relevant gameplay data

		respawn_entry.s	.donothing
		bset	#0,(a2)

	.donothing:

Lamp_Finish:	; Routine 4
		RememberStateXY
		rts						; just return
; ===========================================================================

Lamp_Twirl:	; Routine 6
		subq.w	#1,lamp_time(a0)			; decrement timer
		bpl.s	.twirl					; if time remains, keep twirling
		move.l	#Lamp_Finish,obID(a0)			; goto Lamp_Finish next

	.twirl:
		move.b	obAngle(a0),d0				; load current twirl angle
		subi.b	#$10,obAngle(a0)			; increase angle to make object twirl
		subi.b	#$40,d0					; rotate angle by 90 degrees counterclockwise
		jsr	(CalcSine).l				; get sine and cosine for angle
		muls.w	#$C00,d1				; multiply cosine to increase radius
		swap	d1					; use upper word from multiplication result
		add.w	lamp_origX(a0),d1			; add lamppost base's X-position
		move.w	d1,obX(a0)				; set new X-position for twirling object
		muls.w	#$C00,d0				; multiply sine to increase radius
		swap	d0					; use upper word from multiplication result
		add.w	lamp_origY(a0),d0			; add lamppost base's Y-position
		move.w	d0,obY(a0)				; set new Y-position for twirling object

		bra.w	Lamp_Finish

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to store information when you hit a lamppost
; ---------------------------------------------------------------------------

Lamp_StoreInfo:
		move.b	obSubtype(a0),(v_lastlamp).w		; lamppost number
		move.b	(v_lastlamp).w,(v_lastlamp+1).w		; lamppost number backup
		move.w	obX(a0),(v_lamp_xpos).w			; x-position
		move.w	obY(a0),(v_lamp_ypos).w			; y-position

		move.w	(v_rings).w,(v_lamp_rings).w		; rings
		move.b	(v_lifecount).w,(v_lamp_lives).w	; extra life flag on 100/200 rings
		move.l	(v_time).w,(v_lamp_time).w		; time

		move.b	(v_dle_routine).w,(v_lamp_dle).w	; routine counter for dynamic level event
		move.w	(v_limitbtm2).w,(v_lamp_limitbtm).w	; lower y-boundary of level
		move.w	(v_screenposx).w,(v_lamp_scrx).w	; screen x-position
		move.w	(v_screenposy).w,(v_lamp_scry).w	; screen y-position
		move.w	(v_bgscreenposx).w,(v_lamp_bgscrx).w	; bg1 x-position
		move.w	(v_bgscreenposy).w,(v_lamp_bgscry).w	; bg1 y-position
		move.w	(v_bg2screenposx).w,(v_lamp_bg2scrx).w	; bg2 x-position
		move.w	(v_bg2screenposy).w,(v_lamp_bg2scry).w	; bg2 y-position
		move.w	(v_bg3screenposx).w,(v_lamp_bg3scrx).w	; bg3 x-position
		move.w	(v_bg3screenposy).w,(v_lamp_bg3scry).w	; bg3 y-position

		move.w	(v_waterpos2).w,(v_lamp_wtrpos).w	; water height
		move.b	(v_wtr_routine).w,(v_lamp_wtrrout).w	; routine counter for water
		move.b	(f_wtr_state).w,(v_lamp_wtrstat).w	; water direction
		rts
; End of function Lamp_StoreInfo

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load stored info when you start a level from a lamppost
; ---------------------------------------------------------------------------

Lamp_LoadInfo:
		move.b	(v_lastlamp+1).w,(v_lastlamp).w		; lamppost number
		move.w	(v_lamp_xpos).w,(v_player+obX).w	; x-position
		move.w	(v_lamp_ypos).w,(v_player+obY).w	; y-position

		; Rings are reloaded here, but then immediately reset back to 0
		move.w	(v_lamp_rings).w,(v_rings).w		; (useless) rings
		move.b	(v_lamp_lives).w,(v_lifecount).w	; (useless) extra life flag on 100/200 rings
		clr.w	(v_rings).w				; reset rings to 0
		clr.b	(v_lifecount).w				; reset flags for extra life on rings

		move.l	(v_lamp_time).w,(v_time).w		; time
		move.b	#60-1,(v_timecent).w			; set centiseconds part to a second
		subq.b	#1,(v_timesec).w			; roll back a second

		move.b	(v_lamp_dle).w,(v_dle_routine).w	; routine counter for dynamic level event
		move.b	(v_lamp_wtrrout).w,(v_wtr_routine).w	; routine counter for water
		move.w	(v_lamp_limitbtm).w,(v_limitbtm2).w 	; lower y-boundary of level (actual)
		move.w	(v_lamp_limitbtm).w,(v_limitbtm1).w 	; lower y-boundary of level (target)
		move.w	(v_lamp_scrx).w,(v_screenposx).w 	; screen x-position
		move.w	(v_lamp_scry).w,(v_screenposy).w 	; screen y-position
		move.w	(v_lamp_bgscrx).w,(v_bgscreenposx).w	; bg1 x-position
		move.w	(v_lamp_bgscry).w,(v_bgscreenposy).w	; bg1 y-position
		move.w	(v_lamp_bg2scrx).w,(v_bg2screenposx).w	; bg2 x-position
		move.w	(v_lamp_bg2scry).w,(v_bg2screenposy).w	; bg2 y-position
		move.w	(v_lamp_bg3scrx).w,(v_bg3screenposx).w	; bg3 x-position
		move.w	(v_lamp_bg3scry).w,(v_bg3screenposy).w	; bg3 y-position

		cmpi.b	#id_LZ,(v_zone).w			; is this Labyrinth Zone?
		bne.s	.notlabyrinth				; if not, branch
		move.w	(v_lamp_wtrpos).w,(v_waterpos2).w 	; water height
		move.b	(v_lamp_wtrrout).w,(v_wtr_routine).w	; routine counter for water
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w 	; water direction
	.notlabyrinth:
		rts						; return
; End of function Lamp_LoadInfo
; ===========================================================================

Map_Lamp:	include	"_maps/Lamppost.asm"
