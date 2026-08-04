; ===========================================================================
; ---------------------------------------------------------------------------
; Level order array (extracted from "_incObj/3A Got Through Card.asm").
; An entry specifying "0" as next level (technically GHZ1) will immediately
; return to the Sega screen instead (see Got_NextLevel in object 3A).
; ---------------------------------------------------------------------------

		; Green Hill Zone
		dc.w id_GHZ_act2	; Act 1
		dc.w id_GHZ_act3	; Act 2
		dc.w id_MZ_act1		; Act 3
		dc.w 0			; Act 4 (unused)

		; Labyrinth Zone
		dc.w id_LZ_act2		; Act 1
		dc.w id_LZ_act3		; Act 2
		dc.w id_SLZ_act1	; Act 3
		dc.w id_FZ		; Act 4 (Scrap Brain Zone Act 3)

		; Marble Zone
		dc.w id_MZ_act2		; Act 1
		dc.w id_MZ_act3		; Act 2
		dc.w id_SYZ_act1	; Act 3
		dc.w 0			; Act 4 (unused)

		; Star Light Zone
		dc.w id_SLZ_act2	; Act 1
		dc.w id_SLZ_act3	; Act 2
		dc.w id_SBZ_act1	; Act 3
		dc.w 0			; Act 4 (unused)

		; Spring Yard Zone
		dc.w id_SYZ_act2	; Act 1
		dc.w id_SYZ_act3	; Act 2
		dc.w id_LZ_act1		; Act 3
		dc.w 0			; Act 4 (unused)

		; Scrap Brain Zone
		dc.w id_SBZ_act2	; Act 1
		dc.w id_LZ_act4		; Act 2
		dc.w 0			; Act 3 (Final Zone)
		dc.w 0			; Act 4 (unused)

; Note: Even though this array properly defines the level order for SBZ2/SBZ3/FZ,
; those transitions are not handled here, as they were hardcoded elsewhere:
; SBZ2 -> SBZ3: "01 Sonic.asm" under "Boundary_Bottom"
; SBZ3 -> FZ:   "DynamicLevelEvents.asm" under "DLE_SBZ3"

