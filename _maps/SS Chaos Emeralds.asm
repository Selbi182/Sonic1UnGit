; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos emeralds
; This is some weird intermingled setup with three different map tables
; ---------------------------------------------------------------------------
Map_SS_Chaos1:	mappingsTable
	mappingsTableEntry.w	M_Chaos_1
	mappingsTableEntry.w	M_Chaos_White
Map_SS_Chaos2:	mappingsTable
	mappingsTableEntry.w	M_Chaos_2
	mappingsTableEntry.w	M_Chaos_White
Map_SS_Chaos3:	mappingsTable
	mappingsTableEntry.w	M_Chaos_3
	mappingsTableEntry.w	M_Chaos_White

M_Chaos_1:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
M_Chaos_1_End

M_Chaos_2:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 0, 0
M_Chaos_2_End

M_Chaos_3:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 0, 0
M_Chaos_3_End

M_Chaos_White:	spriteHeader	; cross-referenced in all three mappings
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
M_Chaos_White_End

		even

