; ---------------------------------------------------------------------------
; Sprite mappings - "GAME OVER" and "TIME OVER"
; ---------------------------------------------------------------------------
Map_Over_internal:	mappingsTable
	mappingsTableEntry.w	.game
	mappingsTableEntry.w	.over1
	mappingsTableEntry.w	.time
	mappingsTableEntry.w	.over2

.game:	spriteHeader	; "GAME" text
	spritePiece	-$48, -8, 4, 2, 0, 0, 0, 0, 0	; "GA"
	spritePiece	-$28, -8, 4, 2, 8, 0, 0, 0, 0	; "ME"
.game_End

.over1:	spriteHeader	; "OVER" text for game over
	spritePiece	8, -8, 4, 2, $14, 0, 0, 0, 0	; "OV"
	spritePiece	$28, -8, 4, 2, $C, 0, 0, 0, 0	; "ER"
.over1_End

.time:	spriteHeader	; "TIME" text
	spritePiece	-$3C, -8, 3, 2, $1C, 0, 0, 0, 0	; "TI"
	spritePiece	-$24, -8, 4, 2, 8, 0, 0, 0, 0	; "ME"
.time_End

.over2:	spriteHeader	; "OVER" text for time over
	spritePiece	$C, -8, 4, 2, $14, 0, 0, 0, 0	; "OV"
	spritePiece	$2C, -8, 4, 2, $C, 0, 0, 0, 0	; "ER"
.over2_End

	even
