; ---------------------------------------------------------------------------
; Sprite mappings - Caterkiller enemy (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_Cat_internal:	mappingsTable
	mappingsTableEntry.w	.head1
	mappingsTableEntry.w	.head2
	mappingsTableEntry.w	.head3
	mappingsTableEntry.w	.head4
	mappingsTableEntry.w	.head5
	mappingsTableEntry.w	.head6
	mappingsTableEntry.w	.head7
	mappingsTableEntry.w	.head8
	mappingsTableEntry.w	.body1
	mappingsTableEntry.w	.body2
	mappingsTableEntry.w	.body3
	mappingsTableEntry.w	.body4
	mappingsTableEntry.w	.body5
	mappingsTableEntry.w	.body6
	mappingsTableEntry.w	.body7
	mappingsTableEntry.w	.body8
	mappingsTableEntry.w	.mouth1
	mappingsTableEntry.w	.mouth2
	mappingsTableEntry.w	.mouth3
	mappingsTableEntry.w	.mouth4
	mappingsTableEntry.w	.mouth5
	mappingsTableEntry.w	.mouth6
	mappingsTableEntry.w	.mouth7
	mappingsTableEntry.w	.mouth8

.head1:	spriteHeader
	spritePiece	-8, -$E, 2, 3, 0, 0, 0, 0, 0
.head1_End

.head2:	spriteHeader
	spritePiece	-8, -$F, 2, 3, 0, 0, 0, 0, 0
.head2_End

.head3:	spriteHeader
	spritePiece	-8, -$10, 2, 3, 0, 0, 0, 0, 0
.head3_End

.head4:	spriteHeader
	spritePiece	-8, -$11, 2, 3, 0, 0, 0, 0, 0
.head4_End

.head5:	spriteHeader
	spritePiece	-8, -$12, 2, 3, 0, 0, 0, 0, 0
.head5_End

.head6:	spriteHeader
	spritePiece	-8, -$13, 2, 3, 0, 0, 0, 0, 0
.head6_End

.head7:	spriteHeader
	spritePiece	-8, -$14, 2, 3, 0, 0, 0, 0, 0
.head7_End

.head8:	spriteHeader
	spritePiece	-8, -$15, 2, 3, 0, 0, 0, 0, 0
.head8_End

.body1:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
.body1_End

.body2:	spriteHeader
	spritePiece	-8, -9, 2, 2, $C, 0, 0, 0, 0
.body2_End

.body3:	spriteHeader
	spritePiece	-8, -$A, 2, 2, $C, 0, 0, 0, 0
.body3_End

.body4:	spriteHeader
	spritePiece	-8, -$B, 2, 2, $C, 0, 0, 0, 0
.body4_End

.body5:	spriteHeader
	spritePiece	-8, -$C, 2, 2, $C, 0, 0, 0, 0
.body5_End

.body6:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $C, 0, 0, 0, 0
.body6_End

.body7:	spriteHeader
	spritePiece	-8, -$E, 2, 2, $C, 0, 0, 0, 0
.body7_End

.body8:	spriteHeader
	spritePiece	-8, -$F, 2, 2, $C, 0, 0, 0, 0
.body8_End

.mouth1:	spriteHeader
	spritePiece	-8, -$E, 2, 3, 6, 0, 0, 0, 0
.mouth1_End

.mouth2:	spriteHeader
	spritePiece	-8, -$F, 2, 3, 6, 0, 0, 0, 0
.mouth2_End

.mouth3:	spriteHeader
	spritePiece	-8, -$10, 2, 3, 6, 0, 0, 0, 0
.mouth3_End

.mouth4:	spriteHeader
	spritePiece	-8, -$11, 2, 3, 6, 0, 0, 0, 0
.mouth4_End

.mouth5:	spriteHeader
	spritePiece	-8, -$12, 2, 3, 6, 0, 0, 0, 0
.mouth5_End

.mouth6:	spriteHeader
	spritePiece	-8, -$13, 2, 3, 6, 0, 0, 0, 0
.mouth6_End

.mouth7:	spriteHeader
	spritePiece	-8, -$14, 2, 3, 6, 0, 0, 0, 0
.mouth7_End

.mouth8:	spriteHeader
	spritePiece	-8, -$15, 2, 3, 6, 0, 0, 0, 0
.mouth8_End

	even
