
; ==============================================================================
; ------------------------------------------------------------------------------
; Mega PCM 2.1 - DAC Sound Driver (Macro Definitions)
;
; Documentation, examples and source code are available at:
; - https://github.com/vladikcomper/MegaPCM/tree/2.x
;
; (c) 2012-2026, Vladikcomper
; ------------------------------------------------------------------------------

; ==============================================================================
; ------------------------------------------------------------------------------
; Macros
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Macro to generate sample record in a sample table
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	type - Sample type (e.g. TYPE_PCM, TYPE_DPCM, TYPE_PCM_TURBO, TYPE_NONE)
;	samplePtr - Sample pointer/name (assigned via `incdac` macro)
;	sampleRateHz? - (Optional) Sample rate in Hz, auto-detected for .WAV, .DPCMQ
;	flags? - (Optional) Additional flags (FLAGS_SFX, FLAGS_LOOP, PRIO_NORMAL...)
; ------------------------------------------------------------------------------

dcSample: macro	*, type, samplePtr, sampleRateHz, flags
	; Make sure macro is invoked correctly
	if (narg>4)|((narg=1)&(\type<>TYPE_NONE))
		inform 2, "Incorrect number of arguments. USAGE: dcSample type, samplePtr, sampleRateHz?, flags?"
	endif

	; Setup default sample description field (based on flags and type)
	if narg<4 ; if "flags" parameter is not specified
		@desc\@: equ \type|PRIO_NORMAL
	elseif instr("\flags", "PRIO_")
		@desc\@: equ \type|\flags
	else	; if "priority" flag isn't present, default to PRIO_NORMAL
		@desc\@: equ \type|\flags|PRIO_NORMAL
	endif

	; Track sample ID since start of the sample table (supports multiple tables)
	; This trick works for both linkable and non-linkable builds
	@macroInvokeId: substr 2,,"\@"
	@macroPrevInvokeId: = @macroInvokeId-1
	if ~def(__ST_SampleID)
		__ST_SampleID: = $80
	elseif def(__ST_SamplePtr_\#@macroPrevInvokeId)
		if (*-__ST_SamplePtr_\#@macroPrevInvokeId>10)
			__ST_SampleID: = $80
		endif
	endif

	__ST_SamplePtr\@:	equ	*	; offset of the current sample for back-reference
	__ST_SampleID: = __ST_SampleID+1

	; Define additional properties if the label is given
	if ~strcmp("\*","")
\*:		equ	*
\*.id: 	equ	__ST_SampleID
	endif

	@pitch\@: = 0
	if \type=TYPE_PCM
		if \sampleRateHz+0>TYPE_PCM_MAX_RATE
			inform 2, "Invalid sample rate: \sampleRateHz\. TYPE_PCM only supports sample rates <= \#TYPE_PCM_MAX_RATE Hz"
		endif
		@pitch\@: = (\sampleRateHz+0)*256/TYPE_PCM_BASE_RATE
		dc.b	@desc\@									; $00	- type, flags
		dc.b	@pitch\@								; $01	- pitch (based on sample rate)
		dc.l	\samplePtr								; $02	- start offset
		dc.l	\samplePtr\_End							; $06	- end offset

	elseif \type=TYPE_PCM_TURBO
		if (\sampleRateHz+0<>TYPE_PCM_TURBO_MAX_RATE)&(\sampleRateHz+0<>0)
			inform 2, "Invalid sample rate: \sampleRateHz\. TYPE_PCM_TURBO only supports sample rate of \#TYPE_PCM_TURBO_MAX_RATE Hz"
		endif
		dc.b	@desc\@									; $00	- type, flags
		dc.b	$FF										; $01	- pitch (ignored in Turbo mode)
		dc.l	\samplePtr								; $02	- start offset
		dc.l	\samplePtr\_End							; $06	- end offset

	elseif \type=TYPE_DPCM
		if \sampleRateHz+0>TYPE_DPCM_MAX_RATE
			inform 2, "Invalid sample rate: \sampleRateHz\. TYPE_DPCM only supports sample rates <= \#TYPE_DPCM_MAX_RATE Hz"
		endif
		@pitch\@: = (\sampleRateHz+0)*256/TYPE_DPCM_BASE_RATE
		dc.b	@desc\@									; $00	- type, flags
		dc.b	@pitch\@								; $01	- pitch (based on sample rate)
		dc.l	\samplePtr								; $02	- start offset
		dc.l	\samplePtr\_End							; $06	- end offset

	elseif \type=TYPE_DPCM_TURBO
		if (\sampleRateHz+0<>TYPE_DPCM_TURBO_MAX_RATE)&(\sampleRateHz+0<>0)
			inform 2, "Invalid sample rate: \sampleRateHz\. TYPE_DPCM_TURBO only supports sample rate of \#TYPE_DPCM_TURBO_MAX_RATE Hz"
		endif
		dc.b	@desc\@									; $00	- type, flags
		dc.b	$FF										; $01	- pitch (ignored in Turbo mode)
		dc.l	\samplePtr								; $02	- start offset
		dc.l	\samplePtr\_End							; $06	- end offset

	elseif \type=TYPE_NONE
		dc.b	@desc\@									; $00	- type, flags (ignored)
		dc.b	0										; $01	- pitch (ignored for empty samples)
		dc.l	0										; $02	- start offset (ignored for empty samples)
		dc.l	0										; $06	- end offset (ignored for empty samples)

	else
		inform 2, "Unknown sample type. Please use one of: TYPE_PCM, TYPE_DPCM, TYPE_PCM_TURBO, TYPE_DPCM_TURBO, TYPE_NONE"
	endif

	if ~strcmp("\*","")
	if (@pitch\@<>0)
\*.pitch: 	equ	@pitch\@
	endif
\*.desc:	equ	@desc\@
	endif

	endm

; ------------------------------------------------------------------------------
; Macro to include a sample file
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	name - Name assigned to the sample (label)
;	path - Sample's include path (string)
; ------------------------------------------------------------------------------

incdac:	macro name, path
		even
	\name:
		incbin	\path
	\name\_End:
	endm

; ------------------------------------------------------------------------------
; Macro to play sample
; Fast alternative to `jsr MegaPCM_PlaySample`
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	sampleIdOp - Sample operand (e.g. #$81, #mysample.id, d0)
;
; EXAMPLES:
;	MPCM_play #$81
;	MPCM_play #mysample.id	; if sample has a label in sample table
;	MPCM_play d1			; value stored in d1
; ------------------------------------------------------------------------------

MPCM_play:	macro sampleIdOp
	MPCM_stopZ80
	move.b	\sampleIdOp, MPCM_Z80_RAM+Z_MPCM_CommandInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to pause current sample playback
; Fast alternative to `jsr MegaPCM_PausePlayback`
; ------------------------------------------------------------------------------

MPCM_pause:	macro
	MPCM_stopZ80
	move.b	#Z_MPCM_COMMAND_PAUSE, MPCM_Z80_RAM+Z_MPCM_CommandInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to unpause playback
; Fast alternative to `jsr MegaPCM_UnpausePlayback`
; ------------------------------------------------------------------------------

MPCM_unpause:	macro
	MPCM_stopZ80
	move.b	#0, MPCM_Z80_RAM+Z_MPCM_CommandInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to stop all playback
; Fast alternative to `jsr MegaPCM_StopPlayback`
; ------------------------------------------------------------------------------

MPCM_stop:	macro
	MPCM_stopZ80
	move.b	#Z_MPCM_COMMAND_STOP, MPCM_Z80_RAM+Z_MPCM_CommandInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to set panning for normal (non-SFX) samples
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	panOp - pan operand (e.g. #$40, #$80, #$C0 or d0)
; ------------------------------------------------------------------------------

MPCM_setPan:	macro	panOp
	if strcmp("\panOp","$40")|strcmp("\panOp","$80")|strcmp("\panOp","$C0")
		inform 1, "MPCM_setPan: Possibly erroneous operand: \panOp\. Did you mean #\panOp\?"
	endif
	MPCM_stopZ80
	move.b	\panOp, MPCM_Z80_RAM+Z_MPCM_PanInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to sets panning for SFX samples (added with FLAGS_SFX)
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	panOp - pan operand (e.g. #$40, #$80, #$C0 or d0)
; ------------------------------------------------------------------------------

MPCM_setSfxPan:	macro	panOp
	if strcmp("\panOp","$40")|strcmp("\panOp","$80")|strcmp("\panOp","$C0")
		inform 1, "MPCM_setSfxPan: Possibly erroneous operand: \panOp\. Did you mean #\panOp\?"
	endif
	MPCM_stopZ80
	move.b	\panOp, MPCM_Z80_RAM+Z_MPCM_SFXPanInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to set volume for normal (non-SFX) samples
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	volumeOp - volume operand (e.g. #0 (max), #$F (min) or d0)
; ------------------------------------------------------------------------------

MPCM_setVol:	macro	volumeOp
	MPCM_stopZ80
	move.b	\volumeOp, MPCM_Z80_RAM+Z_MPCM_VolumeInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to set volume for SFX samples (added with FLAGS_SFX)
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	volumeOp - volume operand (e.g. #0 (max), #$F (min) or d0)
; ------------------------------------------------------------------------------

MPCM_setSfxVol:	macro	volumeOp
	MPCM_stopZ80
	move.b	\volumeOp, MPCM_Z80_RAM+Z_MPCM_SFXVolumeInput
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to set pitch (alternative to `jsr MegaPCM_SetActiveSamplePitch`)
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	pitchOp	- pitch operand (e.g. #mypcm.pitch, #0 = 0%, #$FF = 100% base rate)
; ------------------------------------------------------------------------------

MPCM_setPitch:	macro pitchOp
	MPCM_stopZ80
	move.b	\pitchOp, MPCM_Z80_RAM+Z_MPCM_ActiveSamplePitch
	MPCM_startZ80
	endm

; ------------------------------------------------------------------------------
; Macro to stop Z80 and take over its bus
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	opBusReq? - (Optional) Custom operand for Z80_BUSREQ
; ------------------------------------------------------------------------------

MPCM_stopZ80:	macro opBusReq
	pusho
	opt		l-		; make sure "@" marks local labels

	if narg=1
		move.w	#$100, \opBusReq
		@wait\@:
			btst	#0, \opBusReq
			bne.s	@wait\@
	else
		move.w	#$100, MPCM_Z80_BUSREQ
		@wait\@:
			btst	#0, MPCM_Z80_BUSREQ
			bne.s	@wait\@
	endif

	popo
	endm

; ------------------------------------------------------------------------------
; Macro to start Z80 and release its bus
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	opBusReq? - (Optional) Custom operand for Z80_BUSREQ
; ------------------------------------------------------------------------------

MPCM_startZ80:	macro opBusReq
	if narg=1
		move.w	#0, \opBusReq
	else
		move.w	#0, MPCM_Z80_BUSREQ
	endif
	endm

; ------------------------------------------------------------------------------
; Ensures Mega PCM 2 isn't busy writing to YM (other than DAC output obviously)
; ------------------------------------------------------------------------------
; ARGUMENTS:
;	opBusReq? - (Optional) Custom operand for Z80_BUSREQ
; ------------------------------------------------------------------------------

MPCM_ensureYMWriteReady:	macro opBusReq
	pusho
	opt		l-		; make sure "@" marks local labels

	@chk_ready\@:
		tst.b	(MPCM_Z80_RAM+Z_MPCM_DriverReady).l
		bne.s	@ready\@
		MPCM_startZ80 \opBusReq
		move.w	d0, -(sp)
		moveq	#10, d0
		dbf		d0, *						; waste 100+ cycles
		move.w	(sp)+, d0
		MPCM_stopZ80 \opBusReq
		bra.s	@chk_ready\@
	@ready\@:

	popo
	endm

; ==============================================================================
; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------


; ------------------------------------------------------------------------------
; Definitions for sample table (`dcSample` macro)
; ------------------------------------------------------------------------------

; "Type" field constants
TYPE_NONE:		equ $00		; marks empty slot
TYPE_PCM:		equ	$02		; PCM/WAV samples
TYPE_PCM_TURBO:	equ	$04		; PCM/WAV samples (32 kHz Turbo playback mode)
TYPE_DPCM:		equ	$06		; DPCM/DPCM-HQ samples
TYPE_DPCM_TURBO:equ	$08		; DPCM/DPCM-HQ samples (25.8 kHz Turbo playback mode)

; "Flags" field constants
FLAGS_LOOP:		equ	$01		; loop sample indefinitely
FLAGS_SFX:		equ	$40		; sample is SFX, normal BGM drums cannot interrupt it

; "Priority" field constants
; Note that SFX and normal samples have their own level of priorities
PRIO_LOW:		equ	$00		; priority level 0 (low)
PRIO_NORMAL:	equ	$10		; priority level 1 (normal) - that's the default
PRIO_HIGH:		equ	$20		; priority level 2 (high)
PRIO_HIGHEST:	equ	$30		; priority level 3 (higest)

; ------------------------------------------------------------------------------
; Maximum playback rates:
TYPE_PCM_TURBO_MAX_RATE:	equ	32000 ; Hz
TYPE_PCM_MAX_RATE:			equ	25100 ; Hz
TYPE_DPCM_TURBO_MAX_RATE:	equ	25800 ; Hz
TYPE_DPCM_MAX_RATE:			equ	20600 ; Hz

; Internal driver's base rates for pitched playback.
; NOTICE: Actual max rates are slightly lower,
; because the highest pitch is 255/256, not 256/256.
TYPE_PCM_BASE_RATE:			equ	25208 ; Hz
TYPE_DPCM_BASE_RATE:		equ	20691 ; Hz


; ------------------------------------------------------------------------------
; Return error codes for `MegaPCM_LoadSampleTable`
; ------------------------------------------------------------------------------

MPCM_ST_TOO_MANY_SAMPLES:			equ $01		; Too many samples in table
MPCM_ST_UNKNOWN_SAMPLE_TYPE:		equ $02		; Unknown sample type or missing end marker. Please use one of: TYPE_PCM, TYPE_DPCM, TYPE_PCM_TURBO, TYPE_NONE

MPCM_ST_PITCH_NOT_SET:				equ $10		; Sample rate can't be auto-detected (only works for .WAV files). Please set it manually

MPCM_ST_WAVE_INVALID_HEADER:		equ $20		; WAVE error: Invalid WAVE header
MPCM_ST_WAVE_BAD_AUDIO_FORMAT:		equ $21		; WAVE error: Unsupported audio format. Only PCM is supported
MPCM_ST_WAVE_NOT_MONO:				equ $22		; WAVE error: Audio must be mono
MPCM_ST_WAVE_NOT_8BIT:				equ $23		; WAVE error: Audio must be 8-bit unsigned PCM
MPCM_ST_WAVE_BAD_SAMPLE_RATE:		equ $24		; WAVE error: Unsupported sample rate. Use <=25100 Hz for TYPE_PCM or 32000 Hz for TYPE_PCM_TURBO.
MPCM_ST_WAVE_MISSING_DATA_CHUNK:	equ $25		; WAVE error: Failed to locate 'data' chunk

MPCM_ST_DPCM_HQ_UNSUPPORTED_VERSION:equ $30		; DPCM-HQ error: Unsupported version specified in header
MPCM_ST_DPCM_HQ_BAD_SAMPLE_RATE:	equ $31		; DPCM-HQ error: Unsupported sample rate. Use <=20600 Hz for TYPE_DPCM or 25800 Hz for TYPE_DPCM_TURBO.


; ------------------------------------------------------------------------------
; System Ports used by Mega PCM
; ------------------------------------------------------------------------------

MPCM_Z80_RAM:		equ		$A00000
MPCM_Z80_BUSREQ:	equ		$A11100
MPCM_Z80_RESET:		equ		$A11200

MPCM_YM2612_A0:		equ		$A04000
MPCM_YM2612_D0:		equ		$A04001
MPCM_YM2612_A1:		equ		$A04002
MPCM_YM2612_D1:		equ		$A04003

; ------------------------------------------------------------------------------
; Z80 equates
; ------------------------------------------------------------------------------

Z_MPCM_DriverReady:	equ $1fc2
Z_MPCM_CommandInput:	equ $1
Z_MPCM_VolumeInput:	equ $1fc3
Z_MPCM_SFXVolumeInput:	equ $1fc4
Z_MPCM_PanInput:	equ $1fc5
Z_MPCM_SFXPanInput:	equ $1fc6
Z_MPCM_LoopId:	equ $1fd3
Z_MPCM_ActiveSamplePitch:	equ $1fd2
Z_MPCM_VBlankActive:	equ $1fd9
Z_MPCM_CalibrationApplied:	equ $1fda
Z_MPCM_CalibrationScore_ROM:	equ $1fdb
Z_MPCM_CalibrationScore_RAM:	equ $1fdd
Z_MPCM_LastErrorCode:	equ $1fdf
Z_MPCM_SampleTable:	equ $808
Z_MPCM_COMMAND_STOP:	equ $1
Z_MPCM_COMMAND_PAUSE:	equ $2
Z_MPCM_LOOP_IDLE:	equ $1
Z_MPCM_LOOP_PAUSE:	equ $2
Z_MPCM_LOOP_PCM:	equ $10
Z_MPCM_LOOP_PCM_TURBO:	equ $18
Z_MPCM_LOOP_DPCM:	equ $20
Z_MPCM_LOOP_CALIBRATION:	equ $80
Z_MPCM_TYPE_NONE:	equ $0
Z_MPCM_TYPE_PCM:	equ $2
Z_MPCM_TYPE_PCM_TURBO:	equ $4
Z_MPCM_TYPE_DPCM:	equ $6
Z_MPCM_TYPE_DPCM_TURBO:	equ $8
Z_MPCM_TYPE_DPCM_HQ:	equ $a
Z_MPCM_TYPE_DPCM_HQ_TURBO:	equ $c
Z_MPCM_ERROR__BAD_SAMPLE_TYPE:	equ $1
Z_MPCM_ERROR__UNKNOWN_COMMAND:	equ $80

; ------------------------------------------------------------------------------
; MIT License
;
; Copyright (c) 2012-2026 Vladikcomper
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
; ------------------------------------------------------------------------------
