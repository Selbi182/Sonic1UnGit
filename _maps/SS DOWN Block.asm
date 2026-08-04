; ---------------------------------------------------------------------------
; Sprite mappings - special stage "DOWN" block
; ---------------------------------------------------------------------------
Map_SS_Down_internal:	mappingsTable
	mappingsTableEntry.w	.down0
	mappingsTableEntry.w	.down1

.down0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 9, 0, 0, 0, 0
.down0_End

.down1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $12, 0, 0, 0, 0
.down1_End

	even
