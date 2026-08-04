; ---------------------------------------------------------------------------
; Sprite mappings - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------
Map_PSB_internal:	mappingsTable
	mappingsTableEntry.w	.blank
	mappingsTableEntry.w	.psb
	mappingsTableEntry.w	.spritemask
	mappingsTableEntry.w	.tm

.blank:	spriteHeader	; blank frame
.blank_End

.psb:	spriteHeader
	spritePiece	-$40, 0, 4, 1, $0, 0, 0, 0, 0	; "PRESS START BUTTON" (updated)
	spritePiece	-$20, 0, 4, 1, $4, 0, 0, 0, 0
	spritePiece	$00, 0, 4, 1, $8, 0, 0, 0, 0
	spritePiece	$20, 0, 4, 1, $C, 0, 0, 0, 0
	spritePiece	$40, 0, 2, 1, $10, 0, 0, 0, 0
.psb_End

.spritemask:	spriteHeader
	spritePiece	 0, 00, 1, 4, 0, 0, 0, 0, 0	; sprite masks
	spritePiece	-8, 00, 1, 4, 0, 0, 0, 0, 0
	spritePiece	 0, 32, 1, 4, 0, 0, 0, 0, 0
	spritePiece	-8, 32, 1, 4, 0, 0, 0, 0, 0
	spritePiece	 0, 64, 1, 4, 0, 0, 0, 0, 0
	spritePiece	-8, 64, 1, 4, 0, 0, 0, 0, 0
.spritemask_End

.tm:	spriteHeader
	spritePiece	-8, -4, 2, 1, 0, 0, 0, 0, 0	; "TM"
.tm_End

	even
