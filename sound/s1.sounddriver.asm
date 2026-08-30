; ---------------------------------------------------------------------------
; Modified SMPS 68k Type 1b sound driver
; The source code to a similar version of the driver can be found here:
; https://hiddenpalace.org/News/Sega_of_Japan_Sound_Documents_and_Source_Code
; ---------------------------------------------------------------------------

; Constants
SMPS_TRACK_COUNT = (SMPS_RAM.v_track_ram_end-SMPS_RAM.v_track_ram)/SMPS_Track.len
SMPS_MUSIC_TRACK_COUNT = (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/SMPS_Track.len
SMPS_MUSIC_FM_DAC_TRACK_COUNT = (SMPS_RAM.v_music_fmdac_tracks_end-SMPS_RAM.v_music_fmdac_tracks)/SMPS_Track.len
SMPS_MUSIC_FM_TRACK_COUNT = (SMPS_RAM.v_music_fm_tracks_end-SMPS_RAM.v_music_fm_tracks)/SMPS_Track.len
SMPS_MUSIC_PSG_TRACK_COUNT = (SMPS_RAM.v_music_psg_tracks_end-SMPS_RAM.v_music_psg_tracks)/SMPS_Track.len
SMPS_SFX_TRACK_COUNT = (SMPS_RAM.v_sfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len
SMPS_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_sfx_fm_tracks_end-SMPS_RAM.v_sfx_fm_tracks)/SMPS_Track.len
SMPS_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_sfx_psg_tracks_end-SMPS_RAM.v_sfx_psg_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_TRACK_COUNT = (SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_spcsfx_track_ram)/SMPS_Track.len
SMPS_SPECIAL_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_spcsfx_fm_tracks_end-SMPS_RAM.v_spcsfx_fm_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_spcsfx_psg_tracks_end-SMPS_RAM.v_spcsfx_psg_tracks)/SMPS_Track.len
; ---------------------------------------------------------------------------

; ===========================================================================
; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
PSG_Index:
		dc.l PSG1, PSG2, PSG3
		dc.l PSG4, PSG5, PSG6
		dc.l PSG7, PSG8, PSG9

PSG1:		dc.b 0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,$80
PSG2:		dc.b 0,2,4,6,8,$10,$80
PSG3:		dc.b 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,$80
PSG4:		dc.b 0,0,2,3,4,4,5,5,5,6,$80
PSG6:		dc.b 3,3,3,2,2,2,2,1,1,1,0,0,0,0,$80
PSG5:		dc.b 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2
		dc.b 2,2,2,3,3,3,3,3,3,3,3,4,$80
PSG7:		dc.b 0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,5,6,7,$80
PSG8:		dc.b 0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5
		dc.b 5,5,6,6,6,6,6,7,7,7,$80
PSG9:		dc.b 0,1,2,3,4,5,6,7,8,9,$A,$B,$C,$D,$E,$F,$80

; ===========================================================================
; ---------------------------------------------------------------------------
; New tempos for songs during speed shoes
; ---------------------------------------------------------------------------
; DANGER! several songs will use the first few bytes of MusicIndex as their main
; tempos while speed shoes are active. If you don't want that, you should add
; their "correct" sped-up main tempos to the list.

SpeedUpIndex:
		dc.b 7		; GHZ
		dc.b $72	; LZ
		dc.b $73	; MZ
		dc.b $26	; SLZ
		dc.b $15	; SYZ
		dc.b 8		; SBZ
		dc.b $FF	; Invincibility
		dc.b 5		; Extra Life
		dc.b $FF	; Special Stage
		dc.b $FF	; Title Screen
		dc.b $FF	; Ending
		dc.b $FF	; Boss
		dc.b $FF	; FZ
		dc.b $FF	; Sonic Got Through
		dc.b $FF	; Game Over
		dc.b $FF	; Continue Screen
		dc.b $FF	; Credits
		dc.b $FF	; Drowning
		dc.b $FF	; Get Emerald
		even

; ===========================================================================
		include	"sound/__Sound Definitions.asm"
		even
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; ---------------------------------------------------------------------------
; SoundTypes:
SoundPriorities:
		dc.b     $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $81
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $90
		dc.b $80,$70,$70,$70,$70,$70,$70,$70,$70,$70,$68,$70,$70,$70,$60,$70	; $A0
		dc.b $70,$60,$70,$60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$7F	; $B0
		dc.b $60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $C0
		dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $D0
		dc.b $90,$90,$90,$90,$90                                            	; $E0

; ===========================================================================
; ---------------------------------------------------------------------------
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

UpdateMusic:
		lea	(v_snddriver_ram&$FFFFFF).l,a6
		clr.b	SMPS_RAM.f_voice_selector(a6)
		tst.b	SMPS_RAM.f_pausemusic(a6)		; is music paused?
		bne.w	PauseMusic				; if yes, branch
		subq.b	#1,SMPS_RAM.v_main_tempo_timeout(a6)	; has main tempo timer expired?
		bne.s	.skipdelay
		jsr	TempoWait(pc)

.skipdelay:
		move.b	SMPS_RAM.v_fadeout_counter(a6),d0
		beq.s	.skipfadeout
		jsr	DoFadeOut(pc)

.skipfadeout:
		tst.b	SMPS_RAM.f_fadein_flag(a6)
		beq.s	.skipfadein
		jsr	DoFadeIn(pc)

.skipfadein:
		moveq	#0,d0
		or.b	SMPS_RAM.v_soundqueue2(a6),d0
		or.w	SMPS_RAM.v_soundqueue0(a6),d0
		beq.s	.nosndinput				; if not, branch
		jsr	CycleSoundQueue(pc)

.nosndinput:
		cmpi.b	#$80,SMPS_RAM.v_sound_id(a6)		; is song queue set for silence (empty)?
		beq.s	.nonewsound				; if yes, branch
		jsr	PlaySoundID(pc)

.nonewsound:
		tst.b	(v_spindash_sfx_timer).w		; is Spin Dash rev timer active?
		beq.s	.no_spindash				; if not, branch
		subq.b	#1,(v_spindash_sfx_timer).w		; decay Spin Dash rev timer
.no_spindash:
		lea	SMPS_RAM.v_music_dac_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is DAC track playing?
		bpl.s	.dacdone				; branch if not
		jsr	DACUpdateTrack(pc)

.dacdone:
		clr.b	SMPS_RAM.f_updating_dac(a6)
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.bgmfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.bgmfmnext				; branch if not
		jsr	FMUpdateTrack(pc)

.bgmfmnext:
		dbf	d7,.bgmfmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.bgmpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.bgmpsgnext				; branch if not
		jsr	PSGUpdateTrack(pc)

.bgmpsgnext:
		dbf	d7,.bgmpsgloop

		move.b	#$80,SMPS_RAM.f_voice_selector(a6)	; now at SFX tracks
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d7		; 3 FM tracks (SFX)

.sfxfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.sfxfmnext				; branch if not
		jsr	FMUpdateTrack(pc)

.sfxfmnext:
		dbf	d7,.sfxfmloop

		moveq	#SMPS_SFX_PSG_TRACK_COUNT-1,d7		; 3 PSG tracks (SFX)

.sfxpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.sfxpsgnext				; branch if not
		jsr	PSGUpdateTrack(pc)

.sfxpsgnext:
		dbf	d7,.sfxpsgloop

		move.b	#$40,SMPS_RAM.f_voice_selector(a6)	; now at special SFX tracks
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.specfmdone				; branch if not
		jsr	FMUpdateTrack(pc)

.specfmdone:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing
		bpl.s	DoStartZ80				; branch if not
		jsr	PSGUpdateTrack(pc)

DoStartZ80:
		tst.b	(v_pal).w				; is Mega Drive set to PAL region?
		beq.s	.end					; if not, branch
		subq.b	#1,(v_palmuscounter).w			; decrement PAL frame counter
		bhi.s	.end					; is this the 6th frame? if not, branch
		move.b	#6,(v_palmuscounter).w			; reset PAL frame counter
		bra.w	UpdateMusic				; run sound driver a second time this frame
.end:
		rts
; End of function UpdateMusic
; ===========================================================================

DACUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; has DAC sample timeout expired?
		bne.s	.locret					; return if not
		move.b	#$80,SMPS_RAM.f_updating_dac(a6)	; set flag to indicate this is the DAC

		movea.l	SMPS_Track.DataPointer(a5),a4		; dAC track data pointer

.sampleloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; get next SMPS unit
		cmpi.b	#$E0,d5					; is it a coord. flag?
		blo.s	.notcoord				; branch if not
		jsr	CoordFlag(pc)
		bra.s	.sampleloop
; ---------------------------------------------------------------------------

.notcoord:
		tst.b	d5					; is it a sample?
		bpl.s	.gotduration				; branch if not (duration)
		move.b	d5,SMPS_Track.SavedDAC(a5)		; store new sample
		move.b	(a4)+,d5				; get another byte
		bpl.s	.gotduration				; branch if it is a duration
		subq.w	#1,a4					; put byte back
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; use last duration
		bra.s	.gotsampleduration
; ---------------------------------------------------------------------------

.gotduration:
		jsr	SetDuration(pc)

.gotsampleduration:
		move.l	a4,SMPS_Track.DataPointer(a5) 		; save pointer
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.locret					; return if yes
		moveq	#0,d0
		move.b	SMPS_Track.SavedDAC(a5),d0		; get sample
		cmpi.b	#$80,d0					; is it a rest?
		beq.s	.locret					; return if yes
		MPCM_play d0

.locret:
		rts
; ===========================================================================

FMUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; update duration timeout
		bne.s	.notegoing				; branch if it hasn't expired
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; clear 'do not attack next note' bit
		jsr	FMDoNext(pc)
		jsr	FMPrepareNote(pc)
		bra.w	FMNoteOn
; ---------------------------------------------------------------------------

.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack
; ===========================================================================

FMDoNext:
		movea.l	SMPS_Track.DataPointer(a5),a4		; track data pointer
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; clear 'track at rest' bit

.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; get byte from track
		cmpi.b	#$E0,d5					; is this a coord. flag?
		blo.s	.gotnote				; branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ---------------------------------------------------------------------------

.gotnote:
		jsr	FMNoteOff(pc)
		tst.b	d5					; is this a note?
		bpl.s	.gotduration				; branch if not
		jsr	FMSetFreq(pc)
		move.b	(a4)+,d5				; get another byte
		bpl.s	.gotduration				; branch if it is a duration
		subq.w	#1,a4					; otherwise, put it back
		bra.w	FinishTrackUpdate
; ---------------------------------------------------------------------------

.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function FMDoNext
; ===========================================================================

FMSetFreq:
		subi.b	#$80,d5					; make it a zero-based index
		beq.s	TrackSetRest
		add.b	SMPS_Track.Transpose(a5),d5		; add track transposition
		andi.w	#$7F,d5					; clear high byte and sign bit
		lsl.w	#1,d5
		lea	FMFrequencies(pc),a0
		move.w	(a0,d5.w),d6
		move.w	d6,SMPS_Track.Freq(a5)			; store new frequency
		rts
; End of function FMSetFreq
; ===========================================================================

SetDuration:
		move.b	d5,d0
		move.b	SMPS_Track.TempoDivider(a5),d1		; get dividing timing

.multloop:
		subq.b	#1,d1
		beq.s	.donemult
		add.b	d5,d0
		bra.s	.multloop
; ---------------------------------------------------------------------------

.donemult:
		move.b	d0,SMPS_Track.SavedDuration(a5)		; save duration
		move.b	d0,SMPS_Track.DurationTimeout(a5)	; save duration timeout
		rts
; End of function SetDuration
; ===========================================================================

TrackSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		clr.w	SMPS_Track.Freq(a5)			; clear frequency
; ---------------------------------------------------------------------------

FinishTrackUpdate:
		move.l	a4,SMPS_Track.DataPointer(a5)		; store new track position
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; reset note timeout
		btst	#4,SMPS_Track.PlaybackControl(a5)	; is track set to not attack note?
		bne.s	.locret					; if so, branch
		move.b	SMPS_Track.NoteTimeoutMaster(a5),SMPS_Track.NoteTimeout(a5) ; reset note fill timeout
		clr.b	SMPS_Track.VolEnvIndex(a5)		; reset PSG volume envelope index (even on FM tracks...)
		btst	#3,SMPS_Track.PlaybackControl(a5)	; is modulation on?
		beq.s	.locret					; if not, return
		movea.l	SMPS_Track.ModulationPtr(a5),a0		; modulation data pointer
		move.b	(a0)+,SMPS_Track.ModulationWait(a5)	; reset wait
		move.b	(a0)+,SMPS_Track.ModulationSpeed(a5)	; reset speed
		move.b	(a0)+,SMPS_Track.ModulationDelta(a5)	; reset delta
		move.b	(a0)+,d0				; get steps
		lsr.b	#1,d0					; halve them
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; then store
		clr.w	SMPS_Track.ModulationVal(a5)		; reset frequency change

.locret:
		rts
; End of function FinishTrackUpdate
; ===========================================================================

NoteTimeoutUpdate:
		tst.b	SMPS_Track.NoteTimeout(a5)		; is note fill on?
		beq.s	.locret
		subq.b	#1,SMPS_Track.NoteTimeout(a5)		; update note fill timeout
		bne.s	.locret					; return if it hasn't expired
		bset	#1,SMPS_Track.PlaybackControl(a5)	; put track at rest
		tst.b	SMPS_Track.VoiceControl(a5)		; is this a PSG track?
		bmi.w	.psgnoteoff				; if yes, branch
		jsr	FMNoteOff(pc)
		addq.w	#4,sp					; do not return to caller
		rts
; ---------------------------------------------------------------------------

.psgnoteoff:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp					; do not return to caller

.locret:
		rts
; End of function NoteTimeoutUpdate
; ===========================================================================

DoModulation:
		addq.w	#4,sp					; do not return to caller (but see below)
		btst	#3,SMPS_Track.PlaybackControl(a5)	; is modulation active?
		beq.s	.locret					; return if not
		tst.b	SMPS_Track.ModulationWait(a5)		; has modulation wait expired?
		beq.s	.waitdone				; if yes, branch
		subq.b	#1,SMPS_Track.ModulationWait(a5)	; update wait timeout
		rts
; ---------------------------------------------------------------------------

.waitdone:
		subq.b	#1,SMPS_Track.ModulationSpeed(a5)	; update speed
		beq.s	.updatemodulation			; if it expired, want to update modulation
		rts
; ---------------------------------------------------------------------------

.updatemodulation:
		movea.l	SMPS_Track.ModulationPtr(a5),a0		; get modulation data
		move.b	1(a0),SMPS_Track.ModulationSpeed(a5)	; restore modulation speed
		tst.b	SMPS_Track.ModulationSteps(a5)		; check number of steps
		bne.s	.calcfreq				; if nonzero, branch
		move.b	3(a0),SMPS_Track.ModulationSteps(a5)	; restore from modulation data
		neg.b	SMPS_Track.ModulationDelta(a5)		; negate modulation delta
		rts
; ---------------------------------------------------------------------------

.calcfreq:
		subq.b	#1,SMPS_Track.ModulationSteps(a5)	; update modulation steps
		move.b	SMPS_Track.ModulationDelta(a5),d6	; get modulation delta
		ext.w	d6
		add.w	SMPS_Track.ModulationVal(a5),d6		; add cumulative modulation change
		move.w	d6,SMPS_Track.ModulationVal(a5)		; store it
		add.w	SMPS_Track.Freq(a5),d6			; add note frequency to it
		subq.w	#4,sp					; in this case, we want to return to caller after all

.locret:
		rts
; End of function DoModulation
; ===========================================================================

FMPrepareNote:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; is track resting?
		bne.s	locret_71E48				; return if so
		move.w	SMPS_Track.Freq(a5),d6			; get current note frequency
		beq.s	FMSetRest				; branch if zero

FMUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0		; get detune value
		ext.w	d0
		add.w	d0,d6					; add note frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	locret_71E48				; return if so
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#$A4,d0					; register for upper 6 bits of frequency
		jsr	WriteFMIorII(pc)
		move.b	d6,d1
		move.b	#$A0,d0					; register for lower 8 bits of frequency
		jsr	WriteFMIorII(pc)			; (it would be better if this were a jmp)

locret_71E48:
		rts
; ---------------------------------------------------------------------------

FMSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		rts
; End of function FMPrepareNote
; ===========================================================================

PauseMusic:
		bmi.s	.unpausemusic			; Branch if music is being unpaused
		cmpi.b	#2,SMPS_RAM.f_pausemusic(a6)
		beq.w	.done
		move.b	#2,SMPS_RAM.f_pausemusic(a6)
		moveq	#$FFFFFFB4,d0			; Command to set AMS/FMS/panning
		moveq	#0,d1				; No panning, AMS or FMS
		jsr	WriteFMI(pc)			; FM1
		jsr	WriteFMII(pc)			; FM4
		addq.b	#1,d0
		jsr	WriteFMI(pc)			; FM2
		jsr	WriteFMII(pc)			; FM5
		addq.b	#1,d0
		jsr	WriteFMI(pc)			; FM3
		tst.b	SMPS_RAM.v_music_fm6_track(a6)	; is FM6 playing?
		bpl.s	.notFM6				; if not, don't touch it, because FM6 is owned by MegaPCM then
		jsr	WriteFMII(pc)			; FM6
	.notFM6:

		moveq	#2,d3
		moveq	#$28,d0					; key on/off register

.noteoffloop:
		move.b	d3,d1					; FM1, FM2, FM3
		jsr	WriteFMI(pc)
		addq.b	#4,d1					; FM4, FM5, FM6
		jsr	WriteFMI(pc)
		dbf	d3,.noteoffloop

		MPCM_pause

		jsr	PSGSilenceAll(pc)
		bra.w	DoStartZ80
; ---------------------------------------------------------------------------

.unpausemusic:
		clr.b	SMPS_RAM.f_pausemusic(a6)
		moveq	#SMPS_Track.len,d3
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a5
		moveq	#6-1,d4				; 6 FM

.bgmfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; is track playing?
		beq.s	.bgmfmnext				; branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.bgmfmnext				; branch if yes
		move.b	#$B4,d0					; command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; get value from track RAM
		jsr	WriteFMIorII(pc)

.bgmfmnext:
		adda.w	d3,a5
		dbf	d4,.bgmfmloop

		lea	SMPS_RAM.v_sfx_fm_tracks(a6),a5
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d4		; 3 FM tracks (SFX)

.sfxfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; is track playing?
		beq.s	.sfxfmnext				; branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.sfxfmnext				; branch if yes
		move.b	#$B4,d0					; command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; get value from track RAM
		jsr	WriteFMIorII(pc)

.sfxfmnext:
		adda.w	d3,a5
		dbf	d4,.sfxfmloop

		lea	SMPS_RAM.v_spcsfx_track_ram(a6),a5
		btst	#7,SMPS_Track.PlaybackControl(a5)	; is track playing?
		beq.s	.unpausedallfm				; branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.unpausedallfm				; branch if yes
		move.b	#$B4,d0					; command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; get value from track RAM
		jsr	WriteFMIorII(pc)

.unpausedallfm:
		MPCM_unpause

.done:
		bra.w	DoStartZ80
; ===========================================================================

CycleSoundQueue:
		lea	SoundPriorities(pc),a0
		lea	SMPS_RAM.v_soundqueue0(a6),a1		; load music track number
		move.b	SMPS_RAM.v_sndprio(a6),d3		; get priority of currently playing SFX
		moveq	#SMPS_RAM.v_soundqueue_end-SMPS_RAM.v_soundqueue_start-1,d4

.inputloop:
		move.b	(a1),d0					; move track number to d0
		move.b	d0,d1
		clr.b	(a1)+					; clear entry
		subi.b	#bgm__First,d0				; make it into 0-based index
		bcs.s	.nextinput				; if negative (i.e., it was $80 or lower), branch
		cmpi.b	#$80,SMPS_RAM.v_sound_id(a6)		; is v_sound_id a $80 (silence/empty)?
		beq.s	.havesound				; if yes, branch
		move.b	d1,SMPS_RAM.v_soundqueue0(a6)		; put sound into v_soundqueue0
		bra.s	.nextinput
; ---------------------------------------------------------------------------

.havesound:
		andi.w	#$7F,d0					; clear high byte and sign bit
		move.b	(a0,d0.w),d2				; get sound type
		cmp.b	d3,d2					; is it a lower priority sound?
		blo.s	.nextinput				; branch if yes
		move.b	d2,d3					; store new priority
		move.b	d1,SMPS_RAM.v_sound_id(a6)		; queue sound for playing

.nextinput:
		dbf	d4,.inputloop

		tst.b	d3					; we don't want to change sound priority if it is negative
		bmi.s	.locret
		move.b	d3,SMPS_RAM.v_sndprio(a6)		; set new sound priority

.locret:
		rts
; End of function CycleSoundQueue
; ===========================================================================

; Sound_ChkValue:
PlaySoundID:
		moveq	#0,d7
		move.b	SMPS_RAM.v_sound_id(a6),d7
		beq.w	StopAllSound
		bpl.s	.locret					; if >= 0, return (not a valid sound, bgm or command)
		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; reset music flag
		cmpi.b	#bgm__Last,d7				; is this music ($81-$93)?
		bls.w	Sound_PlayBGM				; branch if yes
		cmpi.b	#sfx__First,d7				; is this after music but before sfx? (redundant check)
		blo.w	.locret					; return if yes
		cmpi.b	#sfx__Last,d7				; is this sfx ($A0-$CF)?
		bls.w	Sound_PlaySFX				; branch if yes
		cmpi.b	#flg__First,d7				; is this after special sfx but before $E0?
		blo.w	.locret					; return if yes
		cmpi.b	#flg__Last,d7				; is this $E0-$E4?
		bls.s	Sound_ExtraSpecial			; branch if yes

.locret:
		rts
; ===========================================================================

;Sound_E0toE4:
Sound_ExtraSpecial:
		subi.b	#flg__First,d7
		add.w	d7,d7
		add.w	d7,d7
		lea	Sound_ExIndex(pc),a5
		movea.l	(a5,d7.w),a5
		jmp	(a5)

; ===========================================================================
; ---------------------------------------------------------------------------
; Play "Say-gaa" PCM sound
; ---------------------------------------------------------------------------
; Sound_E1: PlaySega:
PlaySegaSound:
		MPCM_play #dacSega.id
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------
; Sound_81to9F:
Sound_PlayBGM:
		cmpi.b	#bgm_ExtraLife,d7			; is the "extra life" music to be played?
		bne.s	.bgmnot1up				; if not, branch
		tst.b	SMPS_RAM.f_1up_playing(a6)		; is a 1-up music playing?
		bne.w	.locdblret				; if yes, branch
		lea	SMPS_RAM.v_music_track_ram(a6),a5
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0		; 1 DAC + 6 FM + 3 PSG tracks

.clearsfxloop:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX is overriding' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.clearsfxloop

		lea	SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d0		; 3 FM + 3 PSG tracks (SFX)

.cleartrackplayloop:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; clear 'track is playing' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.cleartrackplayloop

		clr.b	SMPS_RAM.v_sndprio(a6)			; clear priority
		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0 ; backup $220 bytes: all variables and music track data

.backupramloop:
		move.l	(a0)+,(a1)+
		dbf	d0,.backupramloop

		move.b	#$80,SMPS_RAM.f_1up_playing(a6)
		clr.b	SMPS_RAM.v_sndprio(a6)			; clear priority again (?)
		bra.s	.bgm_loadMusic
; ---------------------------------------------------------------------------

.bgmnot1up:
		clr.b	SMPS_RAM.f_1up_playing(a6)
		clr.b	SMPS_RAM.v_fadein_counter(a6)

.bgm_loadMusic:
		jsr	InitMusicPlayback(pc)
		lea	SpeedUpIndex(pc),a4
		subi.b	#bgm__First,d7
		move.b	(a4,d7.w),SMPS_RAM.v_speeduptempo(a6)
		lea	MusicIndex(pc),a4
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4				; a4 now points to (uncompressed) song data
		moveq	#0,d0
		move.w	(a4),d0					; load voice pointer
		add.l	a4,d0					; it is a relative pointer
		move.l	d0,SMPS_RAM.v_voice_ptr(a6)
		move.b	5(a4),d0				; load tempo
		move.b	d0,SMPS_RAM.v_tempo_mod(a6)
		tst.b	SMPS_RAM.f_speedup(a6)
		beq.s	.nospeedshoes
		move.b	SMPS_RAM.v_speeduptempo(a6),d0

.nospeedshoes:
		move.b	d0,SMPS_RAM.v_main_tempo(a6)
		move.b	d0,SMPS_RAM.v_main_tempo_timeout(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4					; point past header
		move.b	4(a3),d4				; load tempo dividing timing
		moveq	#SMPS_Track.len,d6
		moveq	#0,d7
		move.b	#1,d5					; note duration for first "note"
		move.b	2(a3),d7				; load number of FM+DAC tracks
		beq.w	.bgm_fmdone				; branch if zero
		subq.b	#1,d7
		move.b	#$C0,d1					; default AMS+FMS+Panning
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a1
		lea	FMDACInitBytes(pc),a2

.bgm_fmloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)		; set "gosub" (coord flag $F8) stack init value
		move.b	d1,SMPS_Track.AMSFMSPan(a1)		; set AMS/FMS/Panning
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0				; load DAC/FM pointer
		add.l	a3,d0					; relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)		; store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)		; load FM channel modifier
		adda.w	d6,a1
		dbf	d7,.bgm_fmloadloop

		cmpi.b	#7,2(a3)				; are 7 FM tracks defined?
		bne.s	.silencefm6
		moveq	#$2B,d0					; DAC enable/disable register
		moveq	#0,d1					; disable DAC
		jsr	WriteFMI(pc)
		bra.w	.bgm_fmdone
; ---------------------------------------------------------------------------

.silencefm6:
		moveq	#$28,d0					; key on/off register
		moveq	#6,d1					; note off on all operators of channel 6
		jsr	WriteFMI(pc)
		move.b	#$42,d0					; TL for operator 1 of FM6
		moveq	#$7F,d1					; total silence
		jsr	WriteFMII(pc)
		move.b	#$4A,d0					; TL for operator 3 of FM6
		moveq	#$7F,d1					; total silence
		jsr	WriteFMII(pc)
		move.b	#$46,d0					; TL for operator 2 of FM6
		moveq	#$7F,d1					; total silence
		jsr	WriteFMII(pc)
		move.b	#$4E,d0					; TL for operator 4 of FM6
		moveq	#$7F,d1					; total silence
		jsr	WriteFMII(pc)
		move.b	#$B6,d0					; AMS/FMS/panning of FM6
		move.b	#$C0,d1					; stereo
		jsr	WriteFMII(pc)

.bgm_fmdone:
		MPCM_stopZ80
		move.b	#0,(MPCM_Z80_RAM+Z_MPCM_VolumeInput).l ; set DAC volume to maximum
		move.b	#$C0,(MPCM_Z80_RAM+Z_MPCM_PanInput).l	; set panning to LR
		MPCM_startZ80

		moveq	#0,d7
		move.b	3(a3),d7				; load number of PSG tracks
		beq.s	.bgm_psgdone				; branch if zero
		subq.b	#1,d7
		lea	SMPS_RAM.v_music_psg_tracks(a6),a1
		lea	PSGInitBytes(pc),a2

.bgm_psgloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)		; set "gosub" (coord flag $F8) stack init value
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0				; load PSG channel pointer
		add.l	a3,d0					; relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)		; store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)		; load PSG modifier
		move.b	(a4)+,d0				; load redundant byte
		move.b	(a4)+,SMPS_Track.VoiceIndex(a1)		; initial PSG tone
		adda.w	d6,a1
		dbf	d7,.bgm_psgloadloop

.bgm_psgdone:
		lea	SMPS_RAM.v_sfx_track_ram(a6),a1
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7		; 6 SFX tracks

.sfxstoploop:
		tst.b	SMPS_Track.PlaybackControl(a1)		; is SFX playing?
		bpl.w	.sfxnext				; branch if not
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a1),d0		; get voice control bits
		bmi.s	.sfxpsgchannel				; branch if this is a PSG channel
		subq.b	#2,d0					; sFX can't have FM1 or FM2
		lsl.b	#2,d0					; convert to index
		bra.s	.gotchannelindex
; ---------------------------------------------------------------------------

.sfxpsgchannel:
		lsr.b	#3,d0					; convert to index

.gotchannelindex:
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#2,SMPS_Track.PlaybackControl(a0)	; set 'SFX is overriding' bit

.sfxnext:
		adda.w	d6,a1
		dbf	d7,.sfxstoploop

		tst.w	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	 ; is special SFX being played?
		bpl.s	.checkspecialpsg			; branch if not
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

.checkspecialpsg:
		tst.w	SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; is special SFX being played?
		bpl.s	.sendfmnoteoff				; branch if not
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

.sendfmnoteoff:
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d4		; 6 FM tracks

.fmnoteoffloop:
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.fmnoteoffloop			; run all FM tracks
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d4	; 3 PSG tracks

.psgnoteoffloop:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.psgnoteoffloop			; run all PSG tracks

.locdblret:
		addq.w	#4,sp					; tamper with return value to not return to caller
		rts
; ---------------------------------------------------------------------------

FMDACInitBytes:	; first byte is for DAC; then notice the 0, 1, 2 then 4, 5, 6
		; this is the gap between parts I and II for YM2612 port writes
		dc.b 6,	0, 1, 2, 4, 5, 6
		even

PSGInitBytes:	; specifically, these configure writes to the PSG port for each channel
		dc.b $80, $A0, $C0
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------
; Sound_A0toF9:
Sound_PlaySFX:
		tst.b	SMPS_RAM.f_1up_playing(a6)		; is 1-up playing?
		bne.w	.clear_sndprio				; exit is it is

		clr.b	(v_spindash_sfx_flag).w			; clear Spin Dash rev flag
		cmpi.b	#sfx_SpinDash,d7			; is this the Spin Dash sound?
		bne.s	.sfx_notSDash				; if not, branch
		moveq	#0,d1					; set default frequency (no pitch-shift)
		tst.b	(v_spindash_sfx_timer).w		; has another Spin Dash been performed quickly enough?
		beq.s	.sfx_dashPitch				; if not, branch
		move.b	(v_spindash_sfx_pitch).w,d1		; get current Spin Dash pitch
		cmpi.b	#12,d1					; has the pitch limit been reached (one octave)?
		bhs.s	.sfx_dashPitch				; if yes, cap max pitch increase
		addq.b	#1,d1					; increase Spin Dash pitch
.sfx_dashPitch:	move.b	d1,(v_spindash_sfx_pitch).w		; set new Spin Dash pitch
		move.b	#1,(v_spindash_sfx_flag).w		; set Spin Dash rev flag
		move.b	#60,(v_spindash_sfx_timer).w		; reset Spin Dash rev timer to one second	
.sfx_notSDash:

		cmpi.b	#sfx_Ring,d7				; is ring sound effect played?
		bne.s	.sfx_notRing				; if not, branch
		tst.b	SMPS_RAM.v_ring_speaker(a6)		; is the ring sound playing on right speaker?
		bne.s	.gotringspeaker				; branch if not
		move.b	#sfx_RingLeft,d7			; play ring sound in left speaker

.gotringspeaker:
		bchg	#0,SMPS_RAM.v_ring_speaker(a6)		; change speaker
; Sound_notB5:
.sfx_notRing:
		cmpi.b	#sfx_Push,d7				; is "pushing" sound played?
		bne.s	.sfx_notPush				; if not, branch
		tst.b	SMPS_RAM.f_push_playing(a6)		; is pushing sound already playing?
		bne.w	.locret					; return if not
		move.b	#$80,SMPS_RAM.f_push_playing(a6)	; mark it as playing
; Sound_notA7:
.sfx_notPush:
		lea	SoundIndex(pc),a0
		subi.b	#sfx__First,d7				; make it 0-based

		lsl.w	#2,d7					; convert sfx ID into index
		movea.l	(a0,d7.w),a3				; sFX data pointer
		movea.l	a3,a1
		moveq	#0,d1
		move.w	(a1)+,d1				; voice pointer
		add.l	a3,d1					; relative pointer
		move.b	(a1)+,d5				; dividing timing
		moveq	#0,d7
		move.b	(a1)+,d7				; number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6

.sfx_loadloop:
		moveq	#0,d3
		move.b	1(a1),d3				; channel assignment bits
		move.b	d3,d4
		bmi.s	.sfxinitpsg				; branch if PSG
		subq.w	#2,d3					; SFX can only have FM3, FM4 or FM5
		lsl.w	#2,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; mark music track as being overridden
		bra.s	.sfxoverridedone
; ---------------------------------------------------------------------------

.sfxinitpsg:
		lsr.w	#3,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; mark music track as being overridden
		cmpi.b	#$C0,d4					; is this PSG 3?
		bne.s	.sfxoverridedone			; branch if not
		move.b	d4,d0
		ori.b	#$1F,d0					; command to silence PSG 3
		move.b	d0,(psg_input).l
		bchg	#5,d0					; command to silence noise channel
		move.b	d0,(psg_input).l

.sfxoverridedone:
		lea	SFX_SFXChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		movea.l	a5,a2
		moveq	#(SMPS_Track.len/4)-1,d0		; $30 bytes

.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; initial playback control bits
		move.b	d5,SMPS_Track.TempoDivider(a5)		; initial voice control bits
		moveq	#0,d0
		move.w	(a1)+,d0				; track data pointer
		add.l	a3,d0					; relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)		; store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier

		tst.b	(v_spindash_sfx_flag).w			; is the Spin Dash sound playing?
		beq.s	.no_spindash				; if not, branch
		move.b	(v_spindash_sfx_pitch).w,d0		; get current Spin Dash rev pitch
		add.b	d0,SMPS_Track.Transpose(a5)		; transpose output sound accordingly
	.no_spindash:

		move.b	#1,SMPS_Track.DurationTimeout(a5)	; set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)		; set "gosub" (coord flag $F8) stack init value
		tst.b	d4					; is this a PSG channel?
		bmi.s	.sfxpsginitdone				; branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)		; AMS/FMS/Panning
		move.l	d1,SMPS_Track.VoicePtr(a5)		; voice pointer

.sfxpsginitdone:
		dbf	d7,.sfx_loadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; is special SFX being played?
		bpl.s	.doneoverride				; branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6) ; is SFX being played?
		bpl.s	.locret					; branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

.locret:
		rts
; ---------------------------------------------------------------------------

.clear_sndprio:
		clr.b	SMPS_RAM.v_sndprio(a6)			; clear priority
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables used by the SFX
; ---------------------------------------------------------------------------
; dword_722CC: BGMChannelRAM:
SFX_BGMChannelRAM:
		dc.l (v_snddriver_ram.v_music_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_music_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF ; plain PSG3
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF ; noise
; dword_722EC: SFXChannelRAM:
SFX_SFXChannelRAM:
		dc.l (v_snddriver_ram.v_sfx_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF ; plain PSG3
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF ; noise

; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------
; Sound_FA:
PlayWaterfall:
		tst.b	SMPS_RAM.f_1up_playing(a6)		; is 1-up playing?
		bne.w	.locret					; return if so

		lea	SoundWaterfall,a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0				; voice pointer
		add.l	a3,d0					; relative pointer
		move.l	d0,SMPS_RAM.v_special_voice_ptr(a6)	; store voice pointer
		move.b	(a1)+,d5				; dividing timing
		moveq	#0,d7
		move.b	(a1)+,d7				; number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6

.sfxloadloop:
		move.b	1(a1),d4				; voice control bits
		bmi.s	.sfxoverridepsg				; branch if PSG
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		bra.s	.sfxinitpsg
; ---------------------------------------------------------------------------

.sfxoverridepsg:
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6) ; set 'SFX is overriding' bit
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5

.sfxinitpsg:
		movea.l	a5,a2
		moveq	#(SMPS_Track.len/4)-1,d0		; $30 bytes

.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; initial playback control bits & voice control bits
		move.b	d5,SMPS_Track.TempoDivider(a5)
		moveq	#0,d0
		move.w	(a1)+,d0				; track data pointer
		add.l	a3,d0					; relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)		; store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)		; load FM/PSG channel modifier
		move.b	#1,SMPS_Track.DurationTimeout(a5)	; set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)		; set "gosub" (coord flag $F8) stack init value
		tst.b	d4					; is this a PSG channel?
		bmi.s	.sfxpsginitdone				; branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)		; AMS/FMS/Panning

.sfxpsginitdone:
		dbf	d7,.sfxloadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; is track playing?
		bpl.s	.doneoverride				; branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; set 'SFX is overriding' bit

.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6) ; is track playing?
		bpl.s	.locret					; branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6) ; set 'SFX is overriding' bit
		ori.b	#$1F,d4					; command to silence channel
		move.b	d4,(psg_input).l
		bchg	#5,d4					; command to silence noise channel
		move.b	d4,(psg_input).l

.locret:
		rts
; End of function PlaySoundID
; ===========================================================================

StopSFX:
		clr.b	SMPS_RAM.v_sndprio(a6)			; clear priority
		lea	SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7		; 3 FM + 3 PSG tracks (SFX)

.trackloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.w	.nexttrack				; branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		moveq	#0,d3
		move.b	SMPS_Track.VoiceControl(a5),d3		; get voice control bits
		bmi.s	.trackpsg				; branch if PSG
		jsr	FMNoteOff(pc)
		cmpi.b	#4,d3					; is this FM4?
		bne.s	.getfmpointer				; branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; is special SFX playing?
		bpl.s	.getfmpointer				; branch if not
		movea.l	a5,a3
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; get special voice pointer
		bra.s	.gotfmpointer
; ---------------------------------------------------------------------------

.getfmpointer:
		subq.b	#2,d3	; SFX only has FM3 and up
		lsl.b	#2,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; get music voice pointer

.gotfmpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5
		bra.s	.nexttrack
; ---------------------------------------------------------------------------

.trackpsg:
		jsr	PSGNoteOff(pc)
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
		tst.b	SMPS_Track.PlaybackControl(a0)		; is track playing?
		bpl.s	.getchannelptr				; branch if not
		cmpi.b	#$E0,d3					; is this a noise channel?
		beq.s	.gotpsgpointer				; branch if yes
		cmpi.b	#$C0,d3					; is this PSG 3?
		beq.s	.gotpsgpointer				; branch if yes

.getchannelptr:
		lsr.b	#3,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0

.gotpsgpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a0)	; clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)	; set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; is this a noise channel?
		bne.s	.nexttrack				; branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l	; set noise type

.nexttrack:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.trackloop

		rts
; End of function StopSFX
; ===========================================================================

StopSpecialSFX:
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.fadedfm				; branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	.fadedfm				; branch if not
		jsr	SendFMNoteOff(pc)
		lea	SMPS_RAM.v_music_fm4_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.fadedfm				; branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; voice pointer
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; current voice
		jsr	SetVoice(pc)

.fadedfm:
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.fadedpsg				; branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	.fadedpsg				; return if not
		jsr	SendPSGNoteOff(pc)
		lea	SMPS_RAM.v_music_psg3_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.fadedpsg				; return if not
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a5)	; is this a noise channel?
		bne.s	.fadedpsg				; return if not
		move.b	SMPS_Track.PSGNoise(a5),(psg_input).l	; set noise type

.fadedpsg:
		rts
; End of function StopSpecialSFX

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------
; Sound_E0:
FadeOutMusic:
		jsr	StopSFX(pc)
		jsr	StopSpecialSFX(pc)
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)		; set fadeout delay to 3
		move.b	#$28,SMPS_RAM.v_fadeout_counter(a6)	; set fadeout counter
		clr.b	SMPS_RAM.f_speedup(a6)			; disable speed shoes tempo
		rts
; ===========================================================================

DoFadeOut:
		move.b	SMPS_RAM.v_fadeout_delay(a6),d0		; has fadeout delay expired?
		beq.s	.continuefade				; branch if yes
		subq.b	#1,SMPS_RAM.v_fadeout_delay(a6)
		rts
; ---------------------------------------------------------------------------

.continuefade:
		subq.b	#1,SMPS_RAM.v_fadeout_counter(a6)	; update fade counter
		beq.w	StopAllSound				; branch if fade is done
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)		; reset fade delay

		; Fade out DAC
		lea	SMPS_RAM.v_music_dac_track(a6),a5
		tst.b	(a5)					; is DAC playing?
		bpl.s	.dac_done				; if yes, branch
		addq.b	#4,SMPS_Track.Volume(a5)		; Increase volume attenuation
		bpl.s	.dac_update_volume
		and.b	#$7F,(a5)				; Stop channel
		bra.s	.dac_done

.dac_update_volume:
		move.b	SMPS_Track.Volume(a5),d0
		lsr.b	#3,d0
		MPCM_setVol d0
.dac_done:

		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.nextfm					; branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; increase volume attenuation
		bpl.s	.sendfmtl				; branch if still positive
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		bra.s	.nextfm
; ---------------------------------------------------------------------------

.sendfmtl:
		jsr	SendVoiceTL(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.nextpsg				; branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; increase volume attenuation
		cmpi.b	#$10,SMPS_Track.Volume(a5)		; is it greater than $F?
		blo.s	.sendpsgvol				; branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		bra.s	.nextpsg
; ---------------------------------------------------------------------------

.sendpsgvol:
		move.b	SMPS_Track.Volume(a5),d6		; store new volume attenuation
		jsr	SetPSGVolume(pc)

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop

		rts
; End of function DoFadeOut
; ===========================================================================

FMSilenceAll:
		moveq	#2,d3					; 3 FM channels for each YM2612 parts
		moveq	#$28,d0					; FM key on/off register

.noteoffloop:
		move.b	d3,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1					; move to YM2612 part 1
		jsr	WriteFMI(pc)
		dbf	d3,.noteoffloop

		moveq	#$40,d0					; set TL on FM channels...
		moveq	#$7F,d1					; ... to total attenuation...
		moveq	#2,d4					; ... for all 3 channels...

.channelloop:
		moveq	#3,d3					; ... for all operators on each channel...

.channeltlloop:
		jsr	WriteFMI(pc)				; ... for part 0...
		jsr	WriteFMII(pc)				; ... and part 1.
		addq.w	#4,d0					; next TL operator
		dbf	d3,.channeltlloop

		subi.b	#$F,d0					; move to TL operator 1 of next channel
		dbf	d4,.channelloop

		rts
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------
; Sound_E4: StopSoundAndMusic:
StopAllSound:
		moveq	#$27,d0					; timers, FM3/FM6 mode
		moveq	#0,d1					; FM3/FM6 normal mode, disable timers
		jsr	WriteFMI(pc)
		movea.l	a6,a0
		move.w	#(SMPS_RAM.v_1up_ram_copy/4)-1,d0	; clear $400 bytes: all variables and track data

.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop

		MPCM_stop

		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; set music to $80 (silence)
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll
; ===========================================================================

InitMusicPlayback:
		movea.l	a6,a0
		; save several values
		move.b	SMPS_RAM.v_sndprio(a6),d1
		move.b	SMPS_RAM.f_1up_playing(a6),d2
		move.b	SMPS_RAM.f_speedup(a6),d3
		move.b	SMPS_RAM.v_fadein_counter(a6),d4
		move.w	SMPS_RAM.v_soundqueue0(a6),d5
		move.b	SMPS_RAM.v_soundqueue2(a6),d6
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0 ; clear $220 bytes: all variables and music track data

.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop

		; restore the values saved above
		move.b	d1,SMPS_RAM.v_sndprio(a6)
		move.b	d2,SMPS_RAM.f_1up_playing(a6)
		move.b	d3,SMPS_RAM.f_speedup(a6)
		move.b	d4,SMPS_RAM.v_fadein_counter(a6)
		move.w	d5,SMPS_RAM.v_soundqueue0(a6)
		move.b	d6,SMPS_RAM.v_soundqueue2(a6)
		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; set music to $80 (silence)

		lea	SMPS_RAM.v_music_dac_track.VoiceControl(a6),a1
		lea	FMDACInitBytes(pc),a2
		moveq	#SMPS_MUSIC_FM_DAC_TRACK_COUNT-1,d1	; 7 DAC/FM tracks
		bsr.s	.writeloop
		lea	PSGInitBytes(pc),a2
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d1	; 3 PSG tracks

.writeloop:
		move.b	(a2)+,(a1)				; write track's channel byte
		lea	SMPS_Track.len(a1),a1			; next track
		dbf	d1,.writeloop				; loop for all DAC/FM/PSG tracks

		rts
; End of function InitMusicPlayback
; ===========================================================================

TempoWait:
		move.b	SMPS_RAM.v_main_tempo(a6),SMPS_RAM.v_main_tempo_timeout(a6) ; reset main tempo timeout
		lea	SMPS_RAM.v_music_track_ram+SMPS_Track.DurationTimeout(a6),a0 ; note timeout
		moveq	#SMPS_Track.len,d0
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d1		; 1 DAC + 6 FM + 3 PSG tracks

.tempoloop:
		addq.b	#1,(a0)					; delay note by 1 frame
		adda.w	d0,a0					; advance to next track
		dbf	d1,.tempoloop

		rts
; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed up music
; ---------------------------------------------------------------------------
; Sound_E2:
SpeedUpMusic:
		tst.b	SMPS_RAM.f_1up_playing(a6)
		bne.s	.speedup_1up
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		move.b	#$80,SMPS_RAM.f_speedup(a6)
		rts
; ---------------------------------------------------------------------------

.speedup_1up:
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo_timeout(a6)
		move.b	#$80,SMPS_RAM.v_1up_ram_copy+SMPS_RAM.f_speedup(a6)
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------
; Sound_E3:
SlowDownMusic:
		tst.b	SMPS_RAM.f_1up_playing(a6)
		bne.s	.slowdown_1up
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		clr.b	SMPS_RAM.f_speedup(a6)
		rts
; ---------------------------------------------------------------------------

.slowdown_1up:
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo_timeout(a6)
		clr.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.f_speedup(a6)
		rts
; ===========================================================================

DoFadeIn:
		tst.b	SMPS_RAM.v_fadein_delay(a6)		; has fadein delay expired?
		beq.s	.continuefade				; branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_delay(a6)
		rts
; ---------------------------------------------------------------------------

.continuefade:
		tst.b	SMPS_RAM.v_fadein_counter(a6)		; is fade done?
		beq.w	.fadedone				; branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_counter(a6)	; update fade counter
		move.b	#2,SMPS_RAM.v_fadein_delay(a6)		; reset fade delay

		; Fade in DAC
		lea	SMPS_RAM.v_music_dac_track(a6),a5
		tst.b	(a5)					; is DAC playing?
		bpl.s	.dac_done				; if yes, branch
		subq.b	#4,SMPS_Track.Volume(a5)		; Increase volume attenuation
		bcc.s	.dac_update_volume
		move.b	#0,SMPS_Track.Volume(a5)
		bra.s	.dac_done

.dac_update_volume:
		move.b	SMPS_Track.Volume(a5),d0
		lsr.b	#3,d0
		MPCM_setVol d0
.dac_done:

		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks

.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.nextfm					; branch if not
		subq.b	#1,SMPS_Track.Volume(a5)		; reduce volume attenuation
		jsr	SendVoiceTL(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.nextpsg				; branch if not
		subq.b	#1,SMPS_Track.Volume(a5)		; reduce volume attenuation
		move.b	SMPS_Track.Volume(a5),d6		; get value
		cmpi.b	#$10,d6					; is it is < $10?
		blo.s	.sendpsgvol				; branch if yes
		moveq	#$F,d6					; limit to $F (maximum attenuation)

.sendpsgvol:
		jsr	SetPSGVolume(pc)

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop
		rts
; ---------------------------------------------------------------------------

.fadedone:
		clr.b	SMPS_RAM.f_fadein_flag(a6)		; stop fadein

		tst.b	SMPS_RAM.v_music_dac_track.PlaybackControl(a6) ; is the DAC channel running?
		bpl.s	.Resume_NoDAC				; if not, branch

		moveq	#$FFFFFFB6,d0				; prepare FM channel 3/6 L/R/AMS/FMS address
		move.b	SMPS_RAM.v_music_dac_track.AMSFMSPan(a6),d1 ; load DAC channel's L/R/AMS/FMS value
		jmp	WriteFMII(pc)				; write to FM 6
.Resume_NoDAC:
		rts
; End of function DoFadeIn
; ===========================================================================

FMNoteOn:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; is track resting?
		bne.s	.locret					; return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.locret					; return if so
		moveq	#$28,d0					; note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1		; get channel bits
		ori.b	#$F0,d1					; note on on all operators
		bra.w	WriteFMI
; ---------------------------------------------------------------------------

.locret:
		rts
; ===========================================================================

FMNoteOff:
		btst	#4,SMPS_Track.PlaybackControl(a5)	; is 'do not attack next note' set?
		bne.s	locret_72714				; return if yes
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	locret_72714				; return if yes

SendFMNoteOff:
		moveq	#$28,d0					; note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1		; note off to this channel
		bra.w	WriteFMI
; ---------------------------------------------------------------------------

locret_72714:
		rts
; End of function FMNoteOff
; ===========================================================================

WriteFMIorIIMain:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden by sfx?
		bne.s	.locret					; return if yes
		bra.w	WriteFMIorII
; ---------------------------------------------------------------------------

.locret:
		rts
; ===========================================================================

WriteFMIorII:
		move.b	SMPS_Track.VoiceControl(a5),d2
		subq.b	#4,d2				; Is this bound for part I or II?
		bcc.s	WriteFMIIPart			; If yes, branch
		addq.b	#4,d2				; Add in voice control bits
		add.b	d2,d0

; ---------------------------------------------------------------------------
WriteFMI:
		MPCM_stopZ80
		MPCM_ensureYMWriteReady
.waitLoop:	tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop		; branch if yes
		move.b	d0,(ym2612_a0).l
		nop
		move.b	d1,(ym2612_d0).l
		nop
		nop
.waitLoop2:	tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop2		; branch if yes
		move.b	#$2A,(ym2612_a0).l	; restore DAC output for MegaPCM
		MPCM_startZ80
		rts
; End of function WriteFMI
; ===========================================================================

WriteFMIIPart:
		add.b	d2,d0			; Add in to destination register

; ---------------------------------------------------------------------------
WriteFMII:
		MPCM_stopZ80
		MPCM_ensureYMWriteReady
.waitLoop:	tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop		; branch if yes
		move.b	d0,(ym2612_a1).l
		nop
		move.b	d1,(ym2612_d1).l
		nop
		nop
.waitLoop2:	tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop2		; branch if yes
		move.b	#$2A,(ym2612_a0).l	; restore DAC output for MegaPCM
		MPCM_startZ80
		rts
; End of function WriteFMII

; ===========================================================================
; FM Note Values: b-0 to a#8
FMFrequencies:
		dc.w $025E,$0284,$02AB,$02D3,$02FE,$032D,$035C,$038F,$03C5,$03FF,$043C,$047C
		dc.w $0A5E,$0A84,$0AAB,$0AD3,$0AFE,$0B2D,$0B5C,$0B8F,$0BC5,$0BFF,$0C3C,$0C7C
		dc.w $125E,$1284,$12AB,$12D3,$12FE,$132D,$135C,$138F,$13C5,$13FF,$143C,$147C
		dc.w $1A5E,$1A84,$1AAB,$1AD3,$1AFE,$1B2D,$1B5C,$1B8F,$1BC5,$1BFF,$1C3C,$1C7C
		dc.w $225E,$2284,$22AB,$22D3,$22FE,$232D,$235C,$238F,$23C5,$23FF,$243C,$247C
		dc.w $2A5E,$2A84,$2AAB,$2AD3,$2AFE,$2B2D,$2B5C,$2B8F,$2BC5,$2BFF,$2C3C,$2C7C
		dc.w $325E,$3284,$32AB,$32D3,$32FE,$332D,$335C,$338F,$33C5,$33FF,$343C,$347C
		dc.w $3A5E,$3A84,$3AAB,$3AD3,$3AFE,$3B2D,$3B5C,$3B8F,$3BC5,$3BFF,$3C3C,$3C7C
; ===========================================================================

PSGUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; update note timeout
		bne.s	.notegoing
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; clear 'do not attack note' bit
		jsr	PSGDoNext(pc)
		jsr	PSGDoNoteOn(pc)
		bra.w	PSGDoVolFX
; ---------------------------------------------------------------------------

.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	PSGUpdateVolFX(pc)
		jsr	DoModulation(pc)
		jmp	PSGUpdateFreq(pc)
; End of function PSGUpdateTrack
; ===========================================================================

PSGDoNext:
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; clear 'track at rest' bit
		movea.l	SMPS_Track.DataPointer(a5),a4		; get track data pointer

.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5				; get byte from track
		cmpi.b	#$E0,d5					; is it a coord. flag?
		blo.s	.gotnote				; branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ---------------------------------------------------------------------------

.gotnote:
		tst.b	d5					; is it a note?
		bpl.s	.gotduration				; branch if not
		jsr	PSGSetFreq(pc)
		move.b	(a4)+,d5				; get another byte
		tst.b	d5					; is it a duration?
		bpl.s	.gotduration				; branch if yes
		subq.w	#1,a4					; put byte back
		bra.w	FinishTrackUpdate
; ---------------------------------------------------------------------------

.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function PSGDoNext
; ===========================================================================

PSGSetFreq:
		subi.b	#$81,d5					; convert to 0-based index
		bcs.s	.restpsg				; if $80, put track at rest
		add.b	SMPS_Track.Transpose(a5),d5		; add in channel transposition
		andi.w	#$7F,d5					; clear high byte and sign bit
		lsl.w	#1,d5
		lea	PSGFrequencies(pc),a0
		move.w	(a0,d5.w),SMPS_Track.Freq(a5)		; set new frequency
		bra.w	FinishTrackUpdate
; ---------------------------------------------------------------------------

.restpsg:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		move.w	#-1,SMPS_Track.Freq(a5)			; invalidate note frequency
		jsr	FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function PSGSetFreq
; ===========================================================================

PSGDoNoteOn:
		move.w	SMPS_Track.Freq(a5),d6			; get note frequency
		bpl.s	PSGUpdateFreq
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		rts
; ---------------------------------------------------------------------------

PSGUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0		; get detune value
		ext.w	d0
		add.w	d0,d6					; add to frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.locret					; return if yes
		btst	#1,SMPS_Track.PlaybackControl(a5)	; is track at rest?
		bne.s	.locret					; return if yes
		move.b	SMPS_Track.VoiceControl(a5),d0		; get channel bits
		cmpi.b	#$E0,d0					; is it a noise channel?
		bne.s	.notnoise				; branch if not
		move.b	#$C0,d0					; use PSG 3 channel bits

.notnoise:
		move.w	d6,d1
		andi.b	#$F,d1					; low nibble of frequency
		or.b	d1,d0					; latch tone data to channel
		lsr.w	#4,d6					; get upper 6 bits of frequency
		andi.b	#$3F,d6					; send to latched channel
		move.b	d0,(psg_input).l
		move.b	d6,(psg_input).l

.locret:
		rts
; End of function PSGUpdateFreq
; ===========================================================================

PSGUpdateVolFX:
		tst.b	SMPS_Track.VoiceIndex(a5)		; test PSG tone
		beq.w	locret_7298A				; return if it is zero

PSGDoVolFX:
		move.b	SMPS_Track.Volume(a5),d6		; get volume
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; get PSG tone
		beq.s	SetPSGVolume
		lea	PSG_Index(pc),a0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a0,d0.w),a0
	
		move.b	SMPS_Track.VolEnvIndex(a5),d0		; get volume envelope index
		addq.b	#1,SMPS_Track.VolEnvIndex(a5)		; increment volume envelope index
		move.b	(a0,d0.w),d0				; volume envelope value
		bpl.s	.gotflutter
		subq.b	#1,SMPS_Track.VolEnvIndex(a5)		; decrement volume envelope index
		rts
; ---------------------------------------------------------------------------

.gotflutter:
		add.w	d0,d6					; add volume envelope value to volume
		cmpi.b	#$10,d6					; is volume $10 or higher?
		blo.s	SetPSGVolume				; branch if not
		moveq	#$F,d6					; limit to silence and fall through

SetPSGVolume:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; is track at rest?
		bne.s	locret_7298A				; return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	locret_7298A				; return if so
		btst	#4,SMPS_Track.PlaybackControl(a5)	; is track set to not attack next note?
		bne.s	PSGCheckNoteTimeout 			; branch if yes

PSGSendVolume:
		or.b	SMPS_Track.VoiceControl(a5),d6		; add in track selector bits
		addi.b	#$10,d6					; mark it as a volume command
		move.b	d6,(psg_input).l

locret_7298A:
		rts
; ===========================================================================

PSGCheckNoteTimeout:
		tst.b	SMPS_Track.NoteTimeoutMaster(a5)	; is note timeout on?
		beq.s	PSGSendVolume				; branch if not
		tst.b	SMPS_Track.NoteTimeout(a5)		; has note timeout expired?
		bne.s	PSGSendVolume				; branch if not
		rts
; End of function SetPSGVolume
; ===========================================================================

PSGNoteOff:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	locret_729B4				; return if so

SendPSGNoteOff:
		move.b	SMPS_Track.VoiceControl(a5),d0		; PSG channel to change
		ori.b	#$1F,d0					; maximum volume attenuation
		move.b	d0,(psg_input).l
		cmpi.b	#$DF,d0					; are stopping PSG3?
		bne.s	locret_729B4
		move.b	#$FF,(psg_input).l			; if so, stop noise channel while we're at it

locret_729B4:
		rts
; End of function PSGNoteOff
; ===========================================================================

PSGSilenceAll:
		lea	(psg_input).l,a0
		move.b	#$9F,(a0)				; silence PSG 1
		move.b	#$BF,(a0)				; silence PSG 2
		move.b	#$DF,(a0)				; silence PSG 3
		move.b	#$FF,(a0)				; silence noise channel
		rts
; End of function PSGSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; PSG Note Values: c-1 to a-6
; ---------------------------------------------------------------------------
PSGFrequencies:
		dc.w $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A, $21A, $1FB, $1DF, $1C4
		dc.w $1AB, $193, $17D, $167, $153, $140, $12E, $11D, $10D,  $FE,  $EF,  $E2
		dc.w  $D6,  $C9,  $BE,  $B4,  $A9,  $A0,  $97,  $8F,  $87,  $7F,  $78,  $71
		dc.w  $6B,  $65,  $5F,  $5A,  $55,  $50,  $4B,  $47,  $43,  $40,  $3C,  $39
		dc.w  $36,  $33,  $30,  $2D,  $2B,  $28,  $26,  $24,  $22,  $20,  $1F,  $1D
		dc.w  $1B,  $1A,  $18,  $17,  $16,  $15,  $13,  $12,  $11,    0
; ===========================================================================

CoordFlag:
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	coordflagLookup(pc,d5.w)
; End of function CoordFlag
; ---------------------------------------------------------------------------

coordflagLookup:
		bra.w	cfPanningAMSFMS		; $E0
		bra.w	cfDetune		; $E1
		bra.w	cfSetCommunication	; $E2
		bra.w	cfJumpReturn		; $E3
		bra.w	cfFadeInToPrevious	; $E4
		bra.w	cfSetTempoDivider	; $E5
		bra.w	cfChangeFMVolume	; $E6
		bra.w	cfHoldNote		; $E7
		bra.w	cfNoteTimeout		; $E8
		bra.w	cfChangeTransposition	; $E9
		bra.w	cfSetTempo		; $EA
		bra.w	cfSetTempoDividerAll	; $EB
		bra.w	cfChangePSGVolume	; $EC
		bra.w	cfClearPush		; $ED
		bra.w	cfStopSpecialFM4	; $EE
		bra.w	cfSetVoice		; $EF
		bra.w	cfModulation		; $F0
		bra.w	cfEnableModulation	; $F1
		bra.w	cfStopTrack		; $F2
		bra.w	cfSetPSGNoise		; $F3
		bra.w	cfDisableModulation	; $F4
		bra.w	cfSetPSGTone		; $F5
		bra.w	cfJumpTo		; $F6
		bra.w	cfRepeatAtPos		; $F7
		bra.w	cfJumpToGosub		; $F8
		bra.w	cfOpF9			; $F9
; ===========================================================================

cfPanningAMSFMS:
		move.b	(a4)+,d1			; New AMS/FMS/panning value
		tst.b	SMPS_Track.VoiceControl(a5)	; Is this a PSG track?
		bmi.s	locret_72AEA			; Return if yes
		moveq	#$37,d0
		and.b	SMPS_Track.AMSFMSPan(a5),d0	; Get current AMS/FMS
		or.b	d0,d1				; Add new panning bits
		move.b	d1,SMPS_Track.AMSFMSPan(a5)	; Store value
		tst.b	SMPS_RAM.f_updating_dac(a6)	; Are we updating DAC?
		bmi.s	.updateDACPanning		; If yes, branch
		moveq	#$FFFFFFB4,d0			; Command to set AMS/FMS/panning
		bra.w	WriteFMIorIIMain

	.updateDACPanning:
		andi.b	#$C0,d1
		MPCM_setPan d1

locret_72AEA:
		rts
; ===========================================================================

cfDetune:
		move.b	(a4)+,SMPS_Track.Detune(a5)		; set detune value
		rts
; ===========================================================================

cfSetCommunication:
		move.b	(a4)+,SMPS_RAM.v_communication_byte(a6)	; set otherwise unused communication byte to parameter
		rts
; ===========================================================================

cfJumpReturn:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0		; track stack pointer
		movea.l	(a5,d0.w),a4				; set track return address
		move.l	#0,(a5,d0.w)				; set 'popped' value to zero
		addq.w	#2,a4					; skip jump target address from gosub flag
		addq.b	#4,d0					; actually 'pop' value
		move.b	d0,SMPS_Track.StackPointer(a5)		; set new stack pointer
		rts
; ===========================================================================

cfFadeInToPrevious:
		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0 ; $220 bytes to restore: all variables and music track data

.restoreramloop:
		move.l	(a1)+,(a0)+
		dbf	d0,.restoreramloop

		move.b	#$2B,d0					; register: DAC mode (bit 7 = enable)
		moveq	#0,d1					; value: DAC mode disable
		jsr	WriteFMI(pc)				; write to YM2612 Port 0 [sub_7272E]

		tst.b	SMPS_RAM.v_music_dac_track(a6)			; is DAC playing?
		bpl.s	.dacdone					; if not, branch
		move.b	#$7F,SMPS_RAM.v_music_dac_track.Volume(a6)	; set initial DAC volume
.dacdone:
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	SMPS_RAM.v_fadein_counter(a6),d6	; if fade already in progress, this adjusts track volume accordingly
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7		; 6 FM tracks
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5

.fmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; is track playing?
		beq.s	.nextfm					; branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		add.b	d6,SMPS_Track.Volume(a5)		; apply current volume fade-in
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	.nextfm					; branch if yes
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; get voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; voice pointer
		jsr	SetVoice(pc)

.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks

.psgloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; is track playing?
		beq.s	.nextpsg				; branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		jsr	PSGNoteOff(pc)
		add.b	d6,SMPS_Track.Volume(a5)		; apply current volume fade-in

.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop

		movea.l	a3,a5
		move.b	#$80,SMPS_RAM.f_fadein_flag(a6)		; trigger fade-in
		move.b	#$28,SMPS_RAM.v_fadein_counter(a6)	; fade-in delay
		clr.b	SMPS_RAM.f_1up_playing(a6)
		addq.w	#8,sp					; tamper return value so we don't return to caller
		rts
; ===========================================================================

cfSetTempoDivider:
		move.b	(a4)+,SMPS_Track.TempoDivider(a5)	; set tempo divider on current track
		rts
; ===========================================================================

cfChangeFMVolume:
		move.b	(a4)+,d0				; get parameter
		add.b	d0,SMPS_Track.Volume(a5)		; add to current volume
		bra.w	SendVoiceTL
; ===========================================================================

cfHoldNote:
		bset	#4,SMPS_Track.PlaybackControl(a5)	; set 'do not attack next note' bit
		rts
; ===========================================================================

cfNoteTimeout:
		move.b	(a4),SMPS_Track.NoteTimeout(a5)		; note fill timeout
		move.b	(a4)+,SMPS_Track.NoteTimeoutMaster(a5)	; note fill master
		rts
; ===========================================================================

cfChangeTransposition:
		move.b	(a4)+,d0				; get parameter
		add.b	d0,SMPS_Track.Transpose(a5)		; add to transpose value
		rts
; ===========================================================================

cfSetTempo:
		move.b	(a4),SMPS_RAM.v_main_tempo(a6)		; set main tempo
		move.b	(a4)+,SMPS_RAM.v_main_tempo_timeout(a6)	; and reset timeout (!)
		rts
; ===========================================================================

cfSetTempoDividerAll:
		lea	SMPS_RAM.v_music_track_ram(a6),a0
		move.b	(a4)+,d0				; get new tempo divider
		moveq	#SMPS_Track.len,d1
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d2		; 1 DAC + 6 FM + 3 PSG tracks

.trackloop:
		move.b	d0,SMPS_Track.TempoDivider(a0)		; set track's tempo divider
		adda.w	d1,a0
		dbf	d2,.trackloop

		rts
; ===========================================================================

cfChangePSGVolume:
		move.b	(a4)+,d0				; get volume change
		add.b	d0,SMPS_Track.Volume(a5)		; apply it
		rts
; ===========================================================================

cfClearPush:
		clr.b	SMPS_RAM.f_push_playing(a6)		; allow push sound to be played once more
		rts
; ===========================================================================

cfStopSpecialFM4:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; clear 'do not attack next note' bit
		jsr	FMNoteOff(pc)
		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; is SFX using FM4?
		bmi.s	.locexit				; branch if yes
		movea.l	a5,a3
		lea	SMPS_RAM.v_music_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; voice pointer
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5

.locexit:
		addq.w	#8,sp					; tamper with return value so we don't return to caller
		rts
; ===========================================================================

cfSetVoice:
		moveq	#0,d0
		move.b	(a4)+,d0				; get new voice
		move.b	d0,SMPS_Track.VoiceIndex(a5)		; store it
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding this track?
		bne.w	locret_72CAA				; return if yes
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; music voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)		; are we updating a music track?
		beq.s	SetVoice				; if yes, branch
		movea.l	SMPS_Track.VoicePtr(a5),a1		; sFX track voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)		; are we updating a SFX track?
		bmi.s	SetVoice				; if yes, branch
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; special SFX voice pointer
; ---------------------------------------------------------------------------

SetVoice:
		subq.w	#1,d0
		bmi.s	.havevoiceptr
		move.w	#25,d1

.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply

.havevoiceptr:
		move.b	(a1)+,d1				; feedback/algorithm
		move.b	d1,SMPS_Track.FeedbackAlgo(a5)		; save it to track RAM
		move.b	d1,d4
		move.b	#$B0,d0					; command to write feedback/algorithm
		jsr	WriteFMIorII(pc)
		lea	FMInstrumentOperatorTable(pc),a2
		moveq	#(FMInstrumentOperatorTable_End-FMInstrumentOperatorTable)-1,d3 ; don't want to send TL yet

.sendvoiceloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	WriteFMIorII(pc)
		dbf	d3,.sendvoiceloop

		moveq	#(FMInstrumentTLTable_End-FMInstrumentTLTable)-1,d5
		andi.w	#7,d4					; get algorithm
		move.b	FMSlotMask(pc,d4.w),d4			; get slot mask for algorithm
		move.b	SMPS_Track.Volume(a5),d3		; track volume attenuation

.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4					; is bit set for this operator in the mask?
		bcc.s	.sendtl					; branch if not
		add.b	d3,d1					; include additional attenuation

.sendtl:
		jsr	WriteFMIorII(pc)
		dbf	d5,.sendtlloop

		move.b	#$B4,d0					; register for AMS/FMS/Panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; value to send
		jsr	WriteFMIorII(pc)			; (It would be better if this were a jmp)

locret_72CAA:
		rts
; End of function SetVoice

; ===========================================================================
FMSlotMask:	dc.b 8,	8, 8, 8, $A, $E, $E, $F
; ===========================================================================

SendVoiceTL:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is SFX overriding?
		bne.s	.locret					; return if so
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0		; current voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)
		beq.s	.gotvoiceptr
		movea.l	SMPS_Track.VoicePtr(a5),a1
		tst.b	SMPS_RAM.f_voice_selector(a6)
		bmi.s	.gotvoiceptr
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1

.gotvoiceptr:
		subq.w	#1,d0
		bmi.s	.gotvoice
		move.w	#25,d1

.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply

.gotvoice:
		adda.w	#21,a1					; want TL
		lea	FMInstrumentTLTable(pc),a2
		move.b	SMPS_Track.FeedbackAlgo(a5),d0		; get feedback/algorithm
		andi.w	#7,d0					; want only algorithm
		move.b	FMSlotMask(pc,d0.w),d4			; get slot mask
		move.b	SMPS_Track.Volume(a5),d3		; get track volume attenuation
		bmi.s	.locret					; if negative, stop
		moveq	#(FMInstrumentTLTable_End-FMInstrumentTLTable)-1,d5

.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4					; is bit set for this operator in the mask?
		bcc.s	.senttl					; branch if not
		add.b	d3,d1					; include additional attenuation
		bcs.s	.senttl					; branch on overflow
		jsr	WriteFMIorII(pc)

.senttl:
		dbf	d5,.sendtlloop

.locret:
		rts
; End of function SendVoiceTL
; ===========================================================================

FMInstrumentOperatorTable:
		dc.b  $30		; detune/multiple operator 1
		dc.b  $38		; detune/multiple operator 3
		dc.b  $34		; detune/multiple operator 2
		dc.b  $3C		; detune/multiple operator 4
		dc.b  $50		; rate scaling/attack rate operator 1
		dc.b  $58		; rate scaling/attack rate operator 3
		dc.b  $54		; rate scaling/attack rate operator 2
		dc.b  $5C		; rate scaling/attack rate operator 4
		dc.b  $60		; amplitude modulation/first decay rate operator 1
		dc.b  $68		; amplitude modulation/first decay rate operator 3
		dc.b  $64		; amplitude modulation/first decay rate operator 2
		dc.b  $6C		; amplitude modulation/first decay rate operator 4
		dc.b  $70		; secondary decay rate operator 1
		dc.b  $78		; secondary decay rate operator 3
		dc.b  $74		; secondary decay rate operator 2
		dc.b  $7C		; secondary decay rate operator 4
		dc.b  $80		; secondary amplitude/release rate operator 1
		dc.b  $88		; secondary amplitude/release rate operator 3
		dc.b  $84		; secondary amplitude/release rate operator 2
		dc.b  $8C		; secondary amplitude/release rate operator 4
FMInstrumentOperatorTable_End

FMInstrumentTLTable:
		dc.b  $40		; total level operator 1
		dc.b  $48		; total level operator 3
		dc.b  $44		; total level operator 2
		dc.b  $4C		; total level operator 4
FMInstrumentTLTable_End
; ===========================================================================

cfModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; turn on modulation
		move.l	a4,SMPS_Track.ModulationPtr(a5)		; save pointer to modulation data
		move.b	(a4)+,SMPS_Track.ModulationWait(a5)	; modulation delay
		move.b	(a4)+,SMPS_Track.ModulationSpeed(a5)	; modulation speed
		move.b	(a4)+,SMPS_Track.ModulationDelta(a5)	; modulation delta
		move.b	(a4)+,d0				; modulation steps...
		lsr.b	#1,d0					; ... divided by 2...
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; ... before being stored
		clr.w	SMPS_Track.ModulationVal(a5)		; total accumulated modulation frequency change
		rts
; ===========================================================================

cfEnableModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; turn on modulation
		rts
; ===========================================================================

cfStopTrack:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; clear 'do not attack next note' bit
		tst.b	SMPS_Track.VoiceControl(a5)		; is this a PSG track?
		bmi.s	.stoppsg				; branch if yes
		tst.b	SMPS_RAM.f_updating_dac(a6)		; is this the DAC we are updating?
		bmi.w	.locexit				; exit if yes
		jsr	FMNoteOff(pc)
		bra.s	.stoppedchannel
; ---------------------------------------------------------------------------

.stoppsg:
		jsr	PSGNoteOff(pc)

.stoppedchannel:
		tst.b	SMPS_RAM.f_voice_selector(a6)		; are we updating SFX?
		bpl.w	.locexit				; exit if not
		clr.b	SMPS_RAM.v_sndprio(a6)			; clear priority
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a5),d0		; get voice control bits
		bmi.s	.getpsgptr				; branch if PSG
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0					; is this FM4?
		bne.s	.getpointer				; branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6) ; is special SFX playing?
		bpl.s	.getpointer				; branch if not
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; get voice pointer
		bra.s	.gotpointer
; ---------------------------------------------------------------------------

.getpointer:
		subq.b	#2,d0					; SFX can only use FM3 and up
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	SMPS_Track.PlaybackControl(a5)		; is track playing?
		bpl.s	.novoiceupd				; branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; get voice pointer

.gotpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; set 'track at rest' bit
		move.b	SMPS_Track.VoiceIndex(a5),d0		; current voice
		jsr	SetVoice(pc)

.novoiceupd:
		movea.l	a3,a5
		bra.s	.locexit
; ---------------------------------------------------------------------------

.getpsgptr:
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
		tst.b	SMPS_Track.PlaybackControl(a0)		; is track playing?
		bpl.s	.getchannelptr				; branch if not
		cmpi.b	#$E0,d0					; is it the noise channel?
		beq.s	.gotchannelptr				; branch if yes
		cmpi.b	#$C0,d0					; is it PSG 3?
		beq.s	.gotchannelptr				; branch if yes

.getchannelptr:
		lea	SFX_BGMChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0

.gotchannelptr:
		bclr	#2,SMPS_Track.PlaybackControl(a0)	; clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)	; set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; is this a noise pointer?
		bne.s	.locexit				; branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l	; set noise tone

.locexit:
		addq.w	#8,sp					; tamper with return value so we don't go back to caller
		rts
; ===========================================================================

cfSetPSGNoise:
		move.b	#$E0,SMPS_Track.VoiceControl(a5)	; turn channel into noise channel
		move.b	(a4)+,SMPS_Track.PSGNoise(a5)		; save noise tone
		btst	#2,SMPS_Track.PlaybackControl(a5)	; is track being overridden?
		bne.s	.locret					; return if yes
		move.b	-1(a4),(psg_input).l			; set tone

.locret:
		rts
; ===========================================================================

cfDisableModulation:
		bclr	#3,SMPS_Track.PlaybackControl(a5)	; disable modulation
		rts
; ===========================================================================

cfSetPSGTone:
		move.b	(a4)+,SMPS_Track.VoiceIndex(a5)		; set current PSG tone
		rts
; ===========================================================================

cfJumpTo:
		move.b	(a4)+,d0				; high byte of offset
		lsl.w	#8,d0					; shift it into place
		move.b	(a4)+,d0				; low byte of offset
		adda.w	d0,a4					; add to current position
		subq.w	#1,a4					; put back one byte
		rts
; ===========================================================================

cfRepeatAtPos:
		moveq	#0,d0
		move.b	(a4)+,d0				; loop index
		move.b	(a4)+,d1				; repeat count
		tst.b	SMPS_Track.LoopCounters(a5,d0.w)	; has this loop already started?
		bne.s	.loopexists				; branch if yes
		move.b	d1,SMPS_Track.LoopCounters(a5,d0.w)	; initialize repeat count

.loopexists:
		subq.b	#1,SMPS_Track.LoopCounters(a5,d0.w)	; decrease loop's repeat count
		bne.s	cfJumpTo				; if nonzero, branch to target
		addq.w	#2,a4					; skip target address
		rts
; ===========================================================================

cfJumpToGosub:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0		; current stack pointer
		subq.b	#4,d0					; add space for another target
		move.l	a4,(a5,d0.w)				; put in current address (*before* target for jump!)
		move.b	d0,SMPS_Track.StackPointer(a5)		; store new stack pointer
		bra.s	cfJumpTo
; ===========================================================================

cfOpF9:
		move.b	#$88,d0					; D1L/RR of Operator 3
		move.b	#$F,d1					; loaded with fixed value (max RR, 1TL)
		jsr	WriteFMI(pc)
		move.b	#$8C,d0					; D1L/RR of Operator 4
		move.b	#$F,d1					; loaded with fixed value (max RR, 1TL)
		bra.w	WriteFMI

; ===========================================================================

		; See "sound/__Sound Definitions.asm"
		sound_defs_include