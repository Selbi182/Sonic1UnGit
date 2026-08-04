; ---------------------------------------------------------------------------
; Sprite mappings - flash effect when you collect the giant ring
; ---------------------------------------------------------------------------
Map_Flash_internal:	mappingsTable
	mappingsTableEntry.w	.flash0
	mappingsTableEntry.w	.flash1
	mappingsTableEntry.w	.flash2
	mappingsTableEntry.w	.flash_full
	mappingsTableEntry.w	.flash4
	mappingsTableEntry.w	.flash5
	mappingsTableEntry.w	.flash6
	mappingsTableEntry.w	.flash_final

.flash0:	spriteHeader
	spritePiece	0, -$20, 4, 4, 0, 0, 0, 0, 0
	spritePiece	0, 0, 4, 4, 0, 0, 1, 0, 0
.flash0_End

.flash1:	spriteHeader
	spritePiece	-$10, -$20, 4, 4, $10, 0, 0, 0, 0
	spritePiece	$10, -$20, 2, 4, $20, 0, 0, 0, 0
	spritePiece	-$10, 0, 4, 4, $10, 0, 1, 0, 0
	spritePiece	$10, 0, 2, 4, $20, 0, 1, 0, 0
.flash1_End

.flash2:	spriteHeader
	spritePiece	-$18, -$20, 4, 4, $28, 0, 0, 0, 0
	spritePiece	8, -$20, 3, 4, $38, 0, 0, 0, 0
	spritePiece	-$18, 0, 4, 4, $28, 0, 1, 0, 0
	spritePiece	8, 0, 3, 4, $38, 0, 1, 0, 0
.flash2_End

.flash_full:	spriteHeader
	spritePiece	-$20, -$20, 4, 4, $34, 1, 0, 0, 0
	spritePiece	0, -$20, 4, 4, $34, 0, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, $34, 1, 1, 0, 0
	spritePiece	0, 0, 4, 4, $34, 0, 1, 0, 0
.flash_full_End

.flash4:	spriteHeader
	spritePiece	-$20, -$20, 3, 4, $38, 1, 0, 0, 0
	spritePiece	-8, -$20, 4, 4, $28, 1, 0, 0, 0
	spritePiece	-$20, 0, 3, 4, $38, 1, 1, 0, 0
	spritePiece	-8, 0, 4, 4, $28, 1, 1, 0, 0
.flash4_End

.flash5:	spriteHeader
	spritePiece	-$20, -$20, 2, 4, $20, 1, 0, 0, 0
	spritePiece	-$10, -$20, 4, 4, $10, 1, 0, 0, 0
	spritePiece	-$20, 0, 2, 4, $20, 1, 1, 0, 0
	spritePiece	-$10, 0, 4, 4, $10, 1, 1, 0, 0
.flash5_End

.flash6:	spriteHeader
	spritePiece	-$20, -$20, 4, 4, 0, 1, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, 0, 1, 1, 0, 0
.flash6_End

.flash_final:	spriteHeader
	spritePiece	-$20, -$20, 4, 4, $44, 0, 0, 0, 0
	spritePiece	0, -$20, 4, 4, $44, 1, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, $44, 0, 1, 0, 0
	spritePiece	0, 0, 4, 4, $44, 1, 1, 0, 0
.flash_final_End

	even
