; ---------------------------------------------------------------------------
; Sprite mappings - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------
Map_But_internal:	mappingsTable
	mappingsTableEntry.w	.up
	mappingsTableEntry.w	.down

.up:	spriteHeader
	spritePiece	-$10, -$B, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -$B, 2, 2, 0, 1, 0, 0, 0
.up_End

.down:	spriteHeader
	spritePiece	-$10, -$B, 2, 2, 4, 0, 0, 0, 0
	spritePiece	0, -$B, 2, 2, 4, 1, 0, 0, 0
.down_End

	even
