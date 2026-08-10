; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

GetLevelHeader:
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get current zone ID
		lsl.w	#6,d0					; multiply by $40 (4 acts per zone * $10 bytes per act)
		move.w	d0,-(sp)				; backup d0 to stack
		moveq	#0,d0					; clear d0
		move.b	(v_act).w,d0				; get current act number
		lsl.w	#4,d0					; multiply by $10 (bytes for one level header)
		add.w	(sp)+,d0				; restore d0 from stack and add to get index
		lea	LevelHeaders(pc,d0.w),a2		; load level header for current zone/act into a2
		rts						; return
; ---------------------------------------------------------------------------

LevelHeaders:

; PLC, level gfx, 16x16 data, 256x256 data, collision, palette
lhead:	macro plc,lvlgfx,sixteen,twofivesix,collision,pal
		dc.l (plc<<24)+lvlgfx
		dc.l sixteen
		dc.l twofivesix
		dc.l (collision<<8)+pal
		endm

		;	PLC		level gfx	16x16 data	256x256 data	collision	palette
		lhead	plcid_GHZ,	KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_GHZ	; Green Hill 1
		lhead	plcid_GHZ,	KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_GHZ	; Green Hill 2
		lhead	plcid_GHZ,	KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_GHZ	; Green Hill 3
		lhead	plcid_GHZ,	KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_GHZ	; Green Hill 4 (unused)
		
		lhead	plcid_LZ,	KosP_LZ,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		palid_LZ	; Labyrinth 1
		lhead	plcid_LZ,	KosP_LZ,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		palid_LZ	; Labyrinth 2
		lhead	plcid_LZ,	KosP_LZ,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		palid_LZ	; Labyrinth 3
		lhead	plcid_LZ,	KosP_LZ,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		palid_SBZ3	; Labyrinth 4 (Scrap Brain Zone 3)
		
		lhead	plcid_MZ,	KosP_MZ,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		palid_MZ	; Marble 1
		lhead	plcid_MZ,	KosP_MZ,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		palid_MZ	; Marble 2
		lhead	plcid_MZ,	KosP_MZ,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		palid_MZ	; Marble 3
		lhead	plcid_MZ,	KosP_MZ,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		palid_MZ	; Marble 4 (unused)
		
		lhead	plcid_SLZ,	KosP_SLZ,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	palid_SLZ	; Star Light 1
		lhead	plcid_SLZ,	KosP_SLZ,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	palid_SLZ	; Star Light 2
		lhead	plcid_SLZ,	KosP_SLZ,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	palid_SLZ	; Star Light 3
		lhead	plcid_SLZ,	KosP_SLZ,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	palid_SLZ	; Star Light 4 (unused)
		
		lhead	plcid_SYZ,	KosP_SYZ,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	palid_SYZ	; Spring Yard 1
		lhead	plcid_SYZ,	KosP_SYZ,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	palid_SYZ	; Spring Yard 2
		lhead	plcid_SYZ,	KosP_SYZ,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	palid_SYZ	; Spring Yard 3
		lhead	plcid_SYZ,	KosP_SYZ,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	palid_SYZ	; Spring Yard 4 (unused)
		
		lhead	plcid_SBZ,	KosP_SBZ,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	palid_SBZ1	; Scrap Brain 1
		lhead	plcid_SBZ,	KosP_SBZ,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	palid_SBZ2	; Scrap Brain 2
		lhead	plcid_SBZ,	KosP_SBZ,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	palid_SBZ2	; Scrap Brain 3 (Final Zone)
		lhead	plcid_SBZ,	KosP_SBZ,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	palid_SBZ1	; Scrap Brain 4 (unused)

		lhead	0,		KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_Ending	; Ending (good)
		lhead	0,		KosP_GHZ,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	palid_Ending	; Ending (bad)

		even
