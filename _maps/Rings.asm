; ---------------------------------------------------------------------------
; Sprite mappings - rings
; ---------------------------------------------------------------------------
Map_Ring_internal:	mappingsTable
	mappingsTableEntry.w	.ring
	mappingsTableEntry.w	.sparkle1
	mappingsTableEntry.w	.sparkle2
	mappingsTableEntry.w	.sparkle3
	mappingsTableEntry.w	.sparkle4
	mappingsTableEntry.w	.blank
	mappingsTableEntry.w	.sparkle1_ss
	mappingsTableEntry.w	.sparkle2_ss
	mappingsTableEntry.w	.sparkle3_ss
	mappingsTableEntry.w	.sparkle4_ss
	mappingsTableEntry.w	.blank

.ring:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0	; ring
.ring_End

.sparkle1:	spriteHeader
	spritePiece	-8, -8, 2, 2, $A, 0, 0, 0, 0	; sparkle
.sparkle1_End

.sparkle2:	spriteHeader
	spritePiece	-8, -8, 2, 2, $A, 1, 1, 0, 0	; sparkle
.sparkle2_End

.sparkle3:	spriteHeader
	spritePiece	-8, -8, 2, 2, $A, 1, 0, 0, 0	; sparkle
.sparkle3_End

.sparkle4:	spriteHeader
	spritePiece	-8, -8, 2, 2, $A, 0, 1, 0, 0	; sparkle
.sparkle4_End

.blank:	spriteHeader
.blank_End


.sparkle1_ss:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 0, 0	; sparkle
.sparkle1_ss_End

.sparkle2_ss:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 1, 1, 0, 0	; sparkle
.sparkle2_ss_End

.sparkle3_ss:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 1, 0, 0, 0	; sparkle
.sparkle3_ss_End

.sparkle4_ss:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 1, 0, 0	; sparkle
.sparkle4_ss_End

	even
