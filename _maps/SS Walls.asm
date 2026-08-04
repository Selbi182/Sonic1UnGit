; ---------------------------------------------------------------------------
; Sprite mappings - walls of the special stage
; ---------------------------------------------------------------------------
Map_SSWalls_internal:	mappingsTable
	mappingsTableEntry.w	.straight ; 00/90 degrees
	mappingsTableEntry.w	.angled1
	mappingsTableEntry.w	.angled2
	mappingsTableEntry.w	.angled3
	mappingsTableEntry.w	.angled4
	mappingsTableEntry.w	.angled5
	mappingsTableEntry.w	.angled6
	mappingsTableEntry.w	.angled7
	mappingsTableEntry.w	.angled8 ; 45 degrees
	mappingsTableEntry.w	.angled9
	mappingsTableEntry.w	.angledA
	mappingsTableEntry.w	.angledB
	mappingsTableEntry.w	.angledC
	mappingsTableEntry.w	.angledD
	mappingsTableEntry.w	.angledE
	mappingsTableEntry.w	.angledF

.straight:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.straight_End

.angled1:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 9, 0, 0, 0, 0
.angled1_End

.angled2:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $19, 0, 0, 0, 0
.angled2_End

.angled3:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $29, 0, 0, 0, 0
.angled3_End

.angled4:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $39, 0, 0, 0, 0
.angled4_End

.angled5:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $49, 0, 0, 0, 0
.angled5_End

.angled6:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $59, 0, 0, 0, 0
.angled6_End

.angled7:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $69, 0, 0, 0, 0
.angled7_End

.angled8:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $79, 0, 0, 0, 0
.angled8_End

.angled9:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $89, 0, 0, 0, 0
.angled9_End

.angledA:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $99, 0, 0, 0, 0
.angledA_End

.angledB:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $A9, 0, 0, 0, 0
.angledB_End

.angledC:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $B9, 0, 0, 0, 0
.angledC_End

.angledD:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $C9, 0, 0, 0, 0
.angledD_End

.angledE:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $D9, 0, 0, 0, 0
.angledE_End

.angledF:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $E9, 0, 0, 0, 0
.angledF_End

	even
