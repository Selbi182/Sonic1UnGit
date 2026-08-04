; ---------------------------------------------------------------------------
; Sprite mappings - special stage "UP" block
; ---------------------------------------------------------------------------
Map_SS_Up_internal:	mappingsTable
	mappingsTableEntry.w	.up0
	mappingsTableEntry.w	.up1

.up0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.up0_End

.up1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $12, 0, 0, 0, 0
.up1_End

	even
