; --------------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - points that appear when you destroy something
; --------------------------------------------------------------------------------

PointsDynPLC_internal:	mappingsTable
	mappingsTableEntry.w	.points_10	; 100
	mappingsTableEntry.w	.points_20	; 200
	mappingsTableEntry.w	.points_50	; 500
	mappingsTableEntry.w	.points_10	; 1000
	mappingsTableEntry.w	.points_10	; 10
	mappingsTableEntry.w	.points_10	; 10,000
	mappingsTableEntry.w	.points_10	; 100,000

.points_10:	dplcHeader
	dplcEntry	2, 2
.points_10_End

.points_20:	dplcHeader
	dplcEntry	1, 1
	dplcEntry	1, 3
.points_20_End

.points_50:	dplcHeader
	dplcEntry	1, 0
	dplcEntry	1, 3
.points_50_End

	even
