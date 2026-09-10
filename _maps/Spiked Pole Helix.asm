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
	spritePiece	-4-$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3-$30, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8+$30, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
.opti0_End

.opti1:	spriteHeader
	spritePiece	-3-$30, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8+$30, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
.opti1_End

.opti2:	spriteHeader
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8+$30, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3+$50, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
.opti2_End

.opti3:	spriteHeader
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8+$30, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3+$50, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0+$60, 0, 0, 0, $00, 0, 0, 0, 0	; blank
.opti3_End

.opti4:	spriteHeader
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8+$30, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3+$50, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0+$60, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3+$70, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
.opti4_End

.opti5:	spriteHeader
	spritePiece	-8-$70, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8-$60, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8-$50, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4-$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3-$30, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
.opti5_End

.opti6:	spriteHeader
	spritePiece	-8-$60, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
	spritePiece	-8-$50, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4-$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3-$30, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
.opti6_End

.opti7:	spriteHeader
	spritePiece	-8-$50, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
	spritePiece	-4-$40, 0, 1, 2, $E, 0, 0, 0, 0		; straight down
	spritePiece	-3-$30, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
	;spritePiece	-0-$20, 0, 0, 0, $00, 0, 0, 0, 0	; blank
	spritePiece	-3-$10, -$C, 1, 1, $11, 0, 0, 0, 0	; 45 degree
	spritePiece	-4+$00, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
	spritePiece	-8+$10, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
	spritePiece	-8+$20, -8, 2, 2, 6, 0, 0, 0, 0		; 90 degree
.opti7_End
	even
