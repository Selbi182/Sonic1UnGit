; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

lhead:	macro mus,pal,plc,lvlgfx,fglayout,bglayout,blocks,chunks,collision,objpos,ringpos
	dc.l (mus<<24)+lvlgfx
	dc.l (plc<<24)+fglayout
	dc.l (pal<<24)+bglayout
	dc.l blocks
	dc.l chunks
	dc.l collision
	dc.l objpos
	dc.l ringpos
	endm

; ---------------------------------------------------------------------------

LevelHeaders:
	;	Music		Palette		PLC		level gfx	FG layout	BG layout	Blocks		Chunks		Collision	Objects		Rings	
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	KosP_GHZ,	Level_GHZ1,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ1,	Rings_GHZ1	; Green Hill 1
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	KosP_GHZ,	Level_GHZ2,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ2,	Rings_GHZ1	; Green Hill 2
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	KosP_GHZ,	Level_GHZ3,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ3,	Rings_GHZ1	; Green Hill 3
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	KosP_GHZ,	Level_Null,	Level_Null,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_Null,	Rings_Null	; Green Hill 4 (unused)
																	
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	KosP_LZ,	Level_LZ1,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ1,	Rings_LZ1	; Labyrinth 1
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	KosP_LZ,	Level_LZ2,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ2,	Rings_LZ2	; Labyrinth 2
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	KosP_LZ,	Level_LZ3,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ3,	Rings_LZ3	; Labyrinth 3
	lhead	bgm_SBZ,	palid_SBZ3,	plcid_LZ,	KosP_LZ,	Level_SBZ3,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_SBZ3,	Rings_SBZ3	; Labyrinth 4 (Scrap Brain Zone 3)
																	
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	KosP_MZ,	Level_MZ1,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ1,	Rings_MZ1	; Marble 1
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	KosP_MZ,	Level_MZ2,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ2,	Rings_MZ2	; Marble 2
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	KosP_MZ,	Level_MZ3,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ3,	Rings_MZ3	; Marble 3
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	KosP_MZ,	Level_Null,	Level_Null,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_Null,	Rings_Null	; Marble 4 (unused)
																	
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	KosP_SLZ,	Level_SLZ1,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ1,	Rings_SLZ1	; Star Light 1
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	KosP_SLZ,	Level_SLZ2,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ2,	Rings_SLZ2	; Star Light 2
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	KosP_SLZ,	Level_SLZ3,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ3,	Rings_SLZ3	; Star Light 3
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	KosP_SLZ,	Level_Null,	Level_Null,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_Null,	Rings_Null	; Star Light 4 (unused)
																	
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	KosP_SYZ,	Level_SYZ1,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ1,	Rings_SYZ1	; Spring Yard 1
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	KosP_SYZ,	Level_SYZ2,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ2,	Rings_SYZ2	; Spring Yard 2
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	KosP_SYZ,	Level_SYZ3,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ3,	Rings_SYZ3	; Spring Yard 3
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	KosP_SYZ,	Level_Null,	Level_Null,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_Null,	Rings_Null	; Spring Yard 4 (unused)
																	
	lhead	bgm_SBZ,	palid_SBZ1,	plcid_SBZ,	KosP_SBZ,	Level_SBZ1,	Level_SBZ1bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_SBZ1,	Rings_SBZ1	; Scrap Brain 1
	lhead	bgm_SBZ,	palid_SBZ2,	plcid_SBZ,	KosP_SBZ,	Level_SBZ2_FZ,	Level_SBZ2bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_SBZ2,	Rings_SBZ1	; Scrap Brain 2
	lhead	bgm_FZ,		palid_SBZ2,	plcid_SBZ,	KosP_SBZ,	Level_SBZ2_FZ,	Level_SBZ2bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_FZ,	Rings_Null	; Scrap Brain 3 (Final Zone)
	lhead	bgm_SBZ,	palid_SBZ1,	plcid_SBZ,	KosP_SBZ,	Level_Null,	Level_Null,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_Null,	Rings_Null	; Scrap Brain 4 (unused)
																	
	lhead	bgm_Ending,	palid_Ending,	plcid_Ending,	KosP_GHZ,	Level_End,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_End,	Rings_Null	; Ending (good)
	lhead	bgm_Ending,	palid_Ending,	plcid_Ending,	KosP_GHZ,	Level_End,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_End,	Rings_Null	; Ending (bad)

	even
