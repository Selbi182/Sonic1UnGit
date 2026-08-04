; ---------------------------------------------------------------------------
; Sprite mappings - special stage breakable glass blocks and red-white blocks
; ---------------------------------------------------------------------------
Map_SS_Glass_internal:	mappingsTable
	mappingsTableEntry.w	.glass0
	mappingsTableEntry.w	.glass1
	mappingsTableEntry.w	.glass2
	mappingsTableEntry.w	.glass3

.glass0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.glass0_End

.glass1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 1, 0, 0, 0
.glass1_End

.glass2:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 1, 1, 0, 0
.glass2_End

.glass3:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 1, 0, 0
.glass3_End

	even
