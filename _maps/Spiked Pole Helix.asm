; ---------------------------------------------------------------------------
; Sprite mappings - helix of spikes on a pole (GHZ)
; ---------------------------------------------------------------------------
Map_Hel_internal:	mappingsTable
	mappingsTableEntry.w	.opti0
	mappingsTableEntry.w	.opti1
	mappingsTableEntry.w	.opti2
	mappingsTableEntry.w	.opti3
	mappingsTableEntry.w	.opti4
	mappingsTableEntry.w	.opti5
	mappingsTableEntry.w	.opti6
	mappingsTableEntry.w	.opti7

.opti0:	spriteHeader
	spritePiece	-68, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-51, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	40, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
.opti0_End

.opti1:	spriteHeader
	spritePiece	-51, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	40, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	60, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
.opti1_End

.opti2:	spriteHeader
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	40, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	60, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	77, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
.opti2_End

.opti3:	spriteHeader
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	40, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	60, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	77, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	96, 0, 0, 0, $00, 0, 0, 0, 0		; blank
.opti3_End

.opti4:	spriteHeader
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	40, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	60, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	77, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	96, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	109, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
.opti4_End

.opti5:	spriteHeader
	spritePiece	-120, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	-104, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-88, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	-68, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-51, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
.opti5_End

.opti6:	spriteHeader
	spritePiece	-104, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-88, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	-68, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-51, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
.opti6_End

.opti7:	spriteHeader
	spritePiece	-88, -5, 2, 2, $A, 0, 0, 0, 0		; 45 degree
	spritePiece	-68, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-51, 4, 1, 1, $10, 0, 0, 0, 0		; 45 degree
	;spritePiece	-32, 0, 0, 0, $00, 0, 0, 0, 0		; blank
	spritePiece	-19, -$C, 1, 1, $11, 0, 0, 0, 0		; 45 degree
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0		; points straight up (harmful)
	spritePiece	8, -$B, 2, 2, 2, 0, 0, 0, 0		; 45 degree
	spritePiece	24, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
.opti7_End
	even
