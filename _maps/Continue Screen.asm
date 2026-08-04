; ---------------------------------------------------------------------------
; Sprite mappings - Continue screen
; ---------------------------------------------------------------------------
Map_ContScr_internal:	mappingsTable
	mappingsTableEntry.w	.cont_text
	mappingsTableEntry.w	.cont_Sonic1
	mappingsTableEntry.w	.cont_Sonic2
	mappingsTableEntry.w	.cont_Sonic3
	mappingsTableEntry.w	.cont_oval
	mappingsTableEntry.w	.cont_Mini1
	mappingsTableEntry.w	.cont_Mini1
	mappingsTableEntry.w	.cont_Mini2

.cont_text:	spriteHeader
	spritePiece	-$3C, -8, 2, 2, $88, 0, 0, 0, 0 ; "CONTINUE", stars and countdown
	spritePiece	-$2C, -8, 2, 2, $B2, 0, 0, 0, 0
	spritePiece	-$1C, -8, 2, 2, $AE, 0, 0, 0, 0
	spritePiece	-$C, -8, 2, 2, $C2, 0, 0, 0, 0
	spritePiece	4, -8, 1, 2, $A0, 0, 0, 0, 0
	spritePiece	$C, -8, 2, 2, $AE, 0, 0, 0, 0
	spritePiece	$1C, -8, 2, 2, $C6, 0, 0, 0, 0
	spritePiece	$2C, -8, 2, 2, $90, 0, 0, 0, 0
	spritePiece	-$18, $38, 2, 2, $21, 0, 0, 1, 0
	spritePiece	8, $38, 2, 2, $21, 0, 0, 1, 0
	spritePiece	-8, $36, 2, 2, $1FC, 0, 0, 0, 0
.cont_text_End

.cont_Sonic1:	spriteHeader
	spritePiece	-4, 4, 2, 2, $15, 0, 0, 0, 0	; Sonic on floor
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
.cont_Sonic1_End

.cont_Sonic2:	spriteHeader
	spritePiece	-4, 4, 2, 2, $19, 0, 0, 0, 0	; Sonic on floor #2
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
.cont_Sonic2_End

.cont_Sonic3:	spriteHeader
	spritePiece	-4, 4, 2, 2, $1D, 0, 0, 0, 0	; Sonic on floor #3
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
.cont_Sonic3_End

.cont_oval:	spriteHeader
	spritePiece	-$18, $60, 3, 2, 0, 0, 0, 1, 0 ; circle on the floor
	spritePiece	0, $60, 3, 2, 0, 1, 0, 1, 0
.cont_oval_End

.cont_Mini1:	spriteHeader
	spritePiece	0, 0, 2, 3, $12, 0, 0, 0, 0	; mini Sonic
.cont_Mini1_End

.cont_Mini2:	spriteHeader
	spritePiece	0, 0, 2, 3, $18, 0, 0, 0, 0	; mini Sonic #2
.cont_Mini2_End

	even
