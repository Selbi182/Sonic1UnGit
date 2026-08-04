; --------------------------------------------------------------------------------
; Sprite mappings - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3
	mappingsTableEntry.w	.frame4
	mappingsTableEntry.w	.frame5
	mappingsTableEntry.w	.frame6
	mappingsTableEntry.w	.frame7

.frame0:	spriteHeader
.frame0_End

.frame1:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 9, 0, 0, 0, 0
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 9, 0, 1, 0, 0
.frame1_End

.frame2:	spriteHeader
	spritePiece -23, -24, 3, 3, 0, 1, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece -23, 0, 3, 3, 0, 1, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 0, 1, 0, 0
.frame2_End

.frame3:	spriteHeader
	spritePiece -24, -24, 3, 3, 9, 1, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 1, 0, 0, 0
	spritePiece -24, 0, 3, 3, 9, 1, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame3_End

.frame4:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 9, 0, 0, 0, 0
	spritePiece -24, 0, 3, 3, 9, 1, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame4_End

.frame5:	spriteHeader
	spritePiece -24, -24, 3, 3, 9, 1, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 1, 0, 0, 0
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 9, 0, 1, 0, 0
.frame5_End

.frame6:	spriteHeader
	spritePiece -24, -24, 3, 3, 0, 0, 0, 0, 0
	spritePiece 0, -24, 3, 3, 9, 0, 0, 0, 0
	spritePiece -24, 0, 3, 3, 9, 1, 1, 0, 0
	spritePiece 0, 0, 3, 3, 0, 1, 1, 0, 0
.frame6_End

.frame7:	spriteHeader
	spritePiece -24, -24, 3, 3, 9, 1, 0, 0, 0
	spritePiece 0, -24, 3, 3, 0, 1, 0, 0, 0
	spritePiece -24, 0, 3, 3, 0, 0, 1, 0, 0
	spritePiece 0, 0, 3, 3, 9, 0, 1, 0, 0
.frame7_End

	even
