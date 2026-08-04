; ---------------------------------------------------------------------------
; Sprite mappings - giant ring
; ---------------------------------------------------------------------------
Map_GRing_internal:	mappingsTable
	mappingsTableEntry.w	byte_9FDA

byte_9FDA:	spriteHeader
	spritePiece	-$20, -$20, 4, 4, 0, 0, 0, 0, 0	; ring
	spritePiece	0, -$20, 4, 4, $10, 0, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, $20, 0, 0, 0, 0
	spritePiece	0, 0, 4, 4, $30, 0, 0, 0, 0
byte_9FDA_End

	even
