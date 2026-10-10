; ---------------------------------------------------------------------------
; Sprite mappings - collapsing floors (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
Map_CFlo_internal:	mappingsTable
	mappingsTableEntry.w	.idle_generic
	mappingsTableEntry.w	.collapse_generic
	mappingsTableEntry.w	.idle_slz
	mappingsTableEntry.w	.collapse_slz

.idle_generic:	spriteHeader
	spritePiece	-$20, -8, 4, 2, 0, 0, 0, 0, 0	; MZ and SBZ blocks (identical 16x16 pixel blocks)
	spritePiece	-$20, 8, 4, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 4, 2, 0, 0, 0, 0, 0
	spritePiece	0, 8, 4, 2, 0, 0, 0, 0, 0
.idle_generic_End

.collapse_generic:	spriteHeader
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, 8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, 8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, 8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$10, 8, 2, 2, 0, 0, 0, 0, 0
.collapse_generic_End

.idle_slz:	spriteHeader
	spritePiece	-$20, -8, 4, 2, 0, 0, 0, 0, 0	; SLZ blocks (mirrored in the middle)
	spritePiece	-$20, 8, 4, 2, 8, 0, 0, 0, 0
	spritePiece	0, -8, 4, 2, 0, 0, 0, 0, 0
	spritePiece	0, 8, 4, 2, 8, 0, 0, 0, 0
.idle_slz_End

.collapse_slz:	spriteHeader
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, 4, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, 4, 0, 0, 0, 0
	spritePiece	-$20, 8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	-$10, 8, 2, 2, $C, 0, 0, 0, 0
	spritePiece	0, 8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	$10, 8, 2, 2, $C, 0, 0, 0, 0
.collapse_slz_End

	even
