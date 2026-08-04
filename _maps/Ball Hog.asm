; ---------------------------------------------------------------------------
; Sprite mappings - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------
Map_Hog_internal:	mappingsTable
	mappingsTableEntry.w	.hog_Stand
	mappingsTableEntry.w	.hog_Open
	mappingsTableEntry.w	.hog_Squat
	mappingsTableEntry.w	.hog_Leap
	mappingsTableEntry.w	.hog_Ball1
	mappingsTableEntry.w	.hog_Ball2

.hog_Stand:	spriteHeader
	spritePiece	-$C, -$11, 3, 2, 0, 0, 0, 0, 0
	spritePiece	-$C, -1, 3, 3, 6, 0, 0, 0, 0	; Ball hog standing
.hog_Stand_End

.hog_Open:	spriteHeader
	spritePiece	-$C, -$11, 3, 2, 0, 0, 0, 0, 0
	spritePiece	-$C, -1, 3, 3, $F, 0, 0, 0, 0	; Ball hog with hatch open
.hog_Open_End

.hog_Squat:	spriteHeader
	spritePiece	-$C, -$C, 3, 2, 0, 0, 0, 0, 0
	spritePiece	-$C, 4, 3, 2, $18, 0, 0, 0, 0	; Ball hog squatting
.hog_Squat_End

.hog_Leap:	spriteHeader
	spritePiece	-$C, -$1C, 3, 2, 0, 0, 0, 0, 0
	spritePiece	-$C, -$C, 3, 3, $1E, 0, 0, 0, 0	; Ball hog leaping
.hog_Leap_End

.hog_Ball1:	spriteHeader
	spritePiece	-8, -8, 2, 2, $27, 0, 0, 0, 0 ; Ball (black)
.hog_Ball1_End

.hog_Ball2:	spriteHeader
	spritePiece	-8, -8, 2, 2, $2B, 0, 0, 0, 0 ; Ball (red)
.hog_Ball2_End

	even
