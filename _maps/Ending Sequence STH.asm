; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC THE HEDGEHOG" text on the ending sequence
; ---------------------------------------------------------------------------
Map_ESth_internal:	mappingsTable
	mappingsTableEntry.w	.eSth_1

.eSth_1:	spriteHeader
	spritePiece	-$30, -$10, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, $10, 0, 0, 0, 0
	spritePiece	$10, -$10, 4, 4, $20, 0, 0, 0, 0
.eSth_1_End

	even
