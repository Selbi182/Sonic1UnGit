; ===========================================================================
; ---------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - Spin Dash Dust
; ---------------------------------------------------------------------------

DustDynPLC:	mappingsTable
	mappingsTableEntry.w DustDynPLC_0
	mappingsTableEntry.w DustDynPLC_1
	mappingsTableEntry.w DustDynPLC_2
	mappingsTableEntry.w DustDynPLC_3
	mappingsTableEntry.w DustDynPLC_4
	mappingsTableEntry.w DustDynPLC_5
	mappingsTableEntry.w DustDynPLC_6

DustDynPLC_0:	dplcHeader
	dplcEntry	8, 0
DustDynPLC_0_End

DustDynPLC_1:	dplcHeader
	dplcEntry	8, 8
DustDynPLC_1_End

DustDynPLC_2:	dplcHeader
	dplcEntry	8, 16
DustDynPLC_2_End

DustDynPLC_3:	dplcHeader
	dplcEntry	10, 24
DustDynPLC_3_End

DustDynPLC_4:	dplcHeader
	dplcEntry	12, 34
DustDynPLC_4_End

DustDynPLC_5:	dplcHeader
	dplcEntry	14, 46
DustDynPLC_5_End

DustDynPLC_6:	dplcHeader
	dplcEntry	14, 60
DustDynPLC_6_End

	even
