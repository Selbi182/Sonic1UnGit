; ---------------------------------------------------------------------------
; Sprite mappings - special stage generic block mappings shared by
; "W", GOAL, 1-Up, "R", 1-6 ZONE, and ghost blocks
; ---------------------------------------------------------------------------
Map_SS_Shared_internal:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.ghost_switch ; blank

.frame0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.frame0_End

.frame1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 9, 0, 0, 0, 0
.frame1_End

.ghost_switch:	spriteHeader
.ghost_switch_End

	even
