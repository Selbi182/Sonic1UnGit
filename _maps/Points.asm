; ---------------------------------------------------------------------------
; Sprite mappings - points that appear when you destroy something
; ---------------------------------------------------------------------------
Map_Poi_internal:	mappingsTable
	mappingsTableEntry.w	.points_100
	mappingsTableEntry.w	.points_200
	mappingsTableEntry.w	.points_500
	mappingsTableEntry.w	.points_1000
	mappingsTableEntry.w	.points_10
	mappingsTableEntry.w	.points_10000
	mappingsTableEntry.w	.points_100000

.points_100:	spriteHeader	; 100 points
	spritePiece -6, -4, 1, 1, 0, 0, 0, 0, 0	; 1
	spritePiece -2, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 3, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_100_End

.points_200:	spriteHeader	; 200 points
	spritePiece -7, -4, 1, 1, 0, 0, 0, 0, 0	; 2
	spritePiece -2, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 3, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_200_End

.points_500:	spriteHeader	; 500 points
	spritePiece -7, -4, 1, 1, 0, 0, 0, 0, 0	; 5
	spritePiece -2, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 3, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_500_End

.points_1000:	spriteHeader	; 1000 points
	spritePiece -8, -4, 1, 1, 0, 0, 0, 0, 0	; 1
	spritePiece -4, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 1, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 6, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_1000_End

.points_10:	spriteHeader	; 10 points
	spritePiece -4, -4, 1, 1, 0, 0, 0, 0, 0	; 1
	spritePiece 0, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_10_End

.points_10000:	spriteHeader	; 10,000 points
	spritePiece -12, -4, 1, 1, 0, 0, 0, 0, 0; 1
	spritePiece -8, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece -3, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 2, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 7, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_10000_End

.points_100000:	spriteHeader	; 100,000 points
	spritePiece -12, -4, 1, 1, 0, 0, 0, 0, 0; 1
	spritePiece -8, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece -3, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 2, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 7, -4, 1, 1, 1, 0, 0, 0, 0	; 0
	spritePiece 12, -4, 1, 1, 1, 0, 0, 0, 0	; 0
.points_100000_End

	even
