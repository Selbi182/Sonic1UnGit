; ---------------------------------------------------------------------------
; Sprite mappings - spinning platforms (SBZ)
; ---------------------------------------------------------------------------

Map_Spin_internal:	mappingsTable
	mappingsTableEntry.w	.flat		; 0
	mappingsTableEntry.w	.spin1		; 1
	mappingsTableEntry.w	.spin2		; 2
	mappingsTableEntry.w	.spin3		; 3
	mappingsTableEntry.w	.spin4		; 4
	
	mappingsTableEntry.w	.flat_x		; 5
	mappingsTableEntry.w	.spin1_x	; 6
	mappingsTableEntry.w	.spin2_x	; 7
	mappingsTableEntry.w	.spin3_x	; 8
	mappingsTableEntry.w	.spin4_x	; 9
	
	mappingsTableEntry.w	.flat_y		; A
	mappingsTableEntry.w	.spin1_y	; B
	mappingsTableEntry.w	.spin2_y	; C
	mappingsTableEntry.w	.spin3_y	; D
	mappingsTableEntry.w	.spin4_y	; E
	
	mappingsTableEntry.w	.flat_xy	; F
	mappingsTableEntry.w	.spin1_xy	; 10
	mappingsTableEntry.w	.spin2_xy	; 11
	mappingsTableEntry.w	.spin3_xy	; 12
	mappingsTableEntry.w	.spin4_xy	; 13


.flat:	spriteHeader
	spritePiece	-$10, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 1, 0, 0, 0
.flat_End

.spin1:	spriteHeader
	spritePiece	-$10, -$10, 4, 2, $14, 0, 0, 0, 0
	spritePiece	-$10, 0, 4, 2, $1C, 0, 0, 0, 0
.spin1_End

.spin2:	spriteHeader
	spritePiece	-$10, -$10, 3, 2, 4, 0, 0, 0, 0
	spritePiece	-8, 0, 3, 2, $A, 0, 0, 0, 0
.spin2_End

.spin3:	spriteHeader
	spritePiece	-$10, -$10, 3, 2, $24, 0, 0, 0, 0
	spritePiece	-8, 0, 3, 2, $2A, 0, 0, 0, 0
.spin3_End

.spin4:	spriteHeader
	spritePiece	-8, -$10, 2, 2, $10, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 2, $10, 0, 1, 0, 0
.spin4_End


.flat_x:	spriteHeader
	spritePiece 0, -8, 2, 2, 0, 1, 0, 0, 0
	spritePiece -16, -8, 2, 2, 0, 0, 0, 0, 0
.flat_x_End

.spin1_x:	spriteHeader
	spritePiece -16, -16, 4, 2, 20, 1, 0, 0, 0
	spritePiece -16, 0, 4, 2, 28, 1, 0, 0, 0
.spin1_x_End

.spin2_x:	spriteHeader
	spritePiece -8, -16, 3, 2, 4, 1, 0, 0, 0
	spritePiece -16, 0, 3, 2, 10, 1, 0, 0, 0
.spin2_x_End

.spin3_x:	spriteHeader
	spritePiece -8, -16, 3, 2, 36, 1, 0, 0, 0
	spritePiece -16, 0, 3, 2, 42, 1, 0, 0, 0
.spin3_x_End

.spin4_x:	spriteHeader
	spritePiece -8, -16, 2, 2, 16, 1, 0, 0, 0
	spritePiece -8, 0, 2, 2, 16, 1, 1, 0, 0
.spin4_x_End


.flat_y:	spriteHeader
	spritePiece -16, -8, 2, 2, 0, 0, 1, 0, 0
	spritePiece 0, -8, 2, 2, 0, 1, 1, 0, 0
.flat_y_End

.spin1_y:	spriteHeader
	spritePiece -16, 0, 4, 2, 20, 0, 1, 0, 0
	spritePiece -16, -16, 4, 2, 28, 0, 1, 0, 0
.spin1_y_End

.spin2_y:	spriteHeader
	spritePiece -16, 0, 3, 2, 4, 0, 1, 0, 0
	spritePiece -8, -16, 3, 2, 10, 0, 1, 0, 0
.spin2_y_End

.spin3_y:	spriteHeader
	spritePiece -16, 0, 3, 2, 36, 0, 1, 0, 0
	spritePiece -8, -16, 3, 2, 42, 0, 1, 0, 0
.spin3_y_End

.spin4_y:	spriteHeader
	spritePiece -8, 0, 2, 2, 16, 0, 1, 0, 0
	spritePiece -8, -16, 2, 2, 16, 0, 0, 0, 0
.spin4_y_End


.flat_xy:	spriteHeader
	spritePiece 0, -8, 2, 2, 0, 1, 1, 0, 0
	spritePiece -16, -8, 2, 2, 0, 0, 1, 0, 0
.flat_xy_End

.spin1_xy:	spriteHeader
	spritePiece -16, 0, 4, 2, 20, 1, 1, 0, 0
	spritePiece -16, -16, 4, 2, 28, 1, 1, 0, 0
.spin1_xy_End

.spin2_xy:	spriteHeader
	spritePiece -8, 0, 3, 2, 4, 1, 1, 0, 0
	spritePiece -16, -16, 3, 2, 10, 1, 1, 0, 0
.spin2_xy_End

.spin3_xy:	spriteHeader
	spritePiece -8, 0, 3, 2, 36, 1, 1, 0, 0
	spritePiece -16, -16, 3, 2, 42, 1, 1, 0, 0
.spin3_xy_End

.spin4_xy:	spriteHeader
	spritePiece -8, 0, 2, 2, 16, 1, 1, 0, 0
	spritePiece -8, -16, 2, 2, 16, 1, 0, 0, 0
.spin4_xy_End

	even
