; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

lhead:	macro mus,pal,plc,fglayout,bglayout,blocks,chunks,collision,objpos,ringpos,palsonuw
	dc.l fglayout
	dc.l bglayout
	dc.l blocks
	dc.l chunks
	dc.l collision
	dc.l objpos
	dc.l ringpos
	dc.b mus, plc, pal, palsonuw
	endm

; ---------------------------------------------------------------------------

LevelHeaders:
	;	Music		Palette		PLC		FG layout	BG layout	Blocks		Chunks		Collision	Objects		Rings		Underwater Sonic Palette
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	Level_GHZ1,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ1,	Rings_GHZ1,	0
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	Level_GHZ2,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ2,	Rings_GHZ2,	0
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	Level_GHZ3,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_GHZ3,	Rings_GHZ3,	0
	lhead	bgm_GHZ,	palid_GHZ,	plcid_GHZ,	Level_Null,	Level_Null,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_Null,	Rings_Null,	0
															
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	Level_LZ1,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ1,	Rings_LZ1,	palid_LZSonWater
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	Level_LZ2,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ2,	Rings_LZ2,	palid_LZSonWater
	lhead	bgm_LZ,		palid_LZ,	plcid_LZ,	Level_LZ3,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_LZ3,	Rings_LZ3,	palid_LZSonWater
	lhead	bgm_SBZ,	palid_SBZ3,	plcid_LZ,	Level_SBZ3,	Level_LZbg,	Blk16_LZ,	Blk256_LZ,	Col_LZ,		ObjPos_SBZ3,	Rings_SBZ3,	palid_SBZ3SonWat ; Labyrinth 4 => Scrap Brain Zone 3
															
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	Level_MZ1,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ1,	Rings_MZ1,	0
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	Level_MZ2,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ2,	Rings_MZ2,	0
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	Level_MZ3,	Level_MZbg,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_MZ3,	Rings_MZ3,	0
	lhead	bgm_MZ,		palid_MZ,	plcid_MZ,	Level_Null,	Level_Null,	Blk16_MZ,	Blk256_MZ,	Col_MZ,		ObjPos_Null,	Rings_Null,	0
															
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	Level_SLZ1,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ1,	Rings_SLZ1,	0
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	Level_SLZ2,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ2,	Rings_SLZ2,	0
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	Level_SLZ3,	Level_SLZbg,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_SLZ3,	Rings_SLZ3,	0
	lhead	bgm_SLZ,	palid_SLZ,	plcid_SLZ,	Level_Null,	Level_Null,	Blk16_SLZ,	Blk256_SLZ,	Col_SLZ,	ObjPos_Null,	Rings_Null,	0
															
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	Level_SYZ1,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ1,	Rings_SYZ1,	0
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	Level_SYZ2,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ2,	Rings_SYZ2,	0
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	Level_SYZ3,	Level_SYZbg,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_SYZ3,	Rings_SYZ3,	0
	lhead	bgm_SYZ,	palid_SYZ,	plcid_SYZ,	Level_Null,	Level_Null,	Blk16_SYZ,	Blk256_SYZ,	Col_SYZ,	ObjPos_Null,	Rings_Null,	0
															
	lhead	bgm_SBZ,	palid_SBZ1,	plcid_SBZ,	Level_SBZ1,	Level_SBZ1bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_SBZ1,	Rings_SBZ1,	0
	lhead	bgm_SBZ,	palid_SBZ2,	plcid_SBZ,	Level_SBZ2_FZ,	Level_SBZ2bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_SBZ2,	Rings_SBZ2,	0
	lhead	bgm_FZ,		palid_SBZ2,	plcid_SBZ,	Level_SBZ2_FZ,	Level_SBZ2bg,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_FZ,	Rings_Null,	0 ; Scrap Brain 3 => Final Zone
	lhead	bgm_SBZ,	palid_SBZ1,	plcid_SBZ,	Level_Null,	Level_Null,	Blk16_SBZ,	Blk256_SBZ,	Col_SBZ,	ObjPos_Null,	Rings_Null,	0
															
	lhead	bgm_Ending,	palid_Ending,	plcid_Ending,	Level_End,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_End,	Rings_Null,	0
	lhead	bgm_Ending,	palid_Ending,	plcid_Ending,	Level_End,	Level_GHZbg,	Blk16_GHZ,	Blk256_GHZ,	Col_GHZ,	ObjPos_End,	Rings_Null,	0

	even
