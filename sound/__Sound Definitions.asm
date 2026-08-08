; ===========================================================================
; ---------------------------------------------------------------------------
; Sound ID pointer macros
; ---------------------------------------------------------------------------

sndtable:	macro	baseindex
.base_offset:	= *
.base_id:	= \baseindex
		endm

snddef:		macro	romloc,asmlabel
\asmlabel:	equ ((*-.base_offset)/4)+.base_id
		dc.l romloc
		endm

; ---------------------------------------------------------------------------
; Music Pointers
; ---------------------------------------------------------------------------

bgm__First:	equ $81
bgm__Last:	equ $93

MusicIndex:	sndtable bgm__First
	snddef	Music81, bgm_GHZ
	snddef	Music82, bgm_LZ
	snddef	Music83, bgm_MZ
	snddef	Music84, bgm_SLZ
	snddef	Music85, bgm_SYZ
	snddef	Music86, bgm_SBZ
	snddef	Music87, bgm_Invincible
	snddef	Music88, bgm_ExtraLife
	snddef	Music89, bgm_SS
	snddef	Music8A, bgm_Title
	snddef	Music8B, bgm_Ending
	snddef	Music8C, bgm_Boss
	snddef	Music8D, bgm_FZ
	snddef	Music8E, bgm_GotThrough
	snddef	Music8F, bgm_GameOver
	snddef	Music90, bgm_Continue
	snddef	Music91, bgm_Credits
	snddef	Music92, bgm_Drowning
	snddef	Music93, bgm_Emerald


; ---------------------------------------------------------------------------
; Sound effect pointers
; ---------------------------------------------------------------------------

sfx__First:	equ $A0
sfx__Last:	equ $D3

SoundIndex:	sndtable sfx__First
	snddef	SoundA0, sfx_Jump
	snddef	SoundA1, sfx_Lamppost
	snddef	SoundA2, sfx_A2
	snddef	SoundA3, sfx_Death
	snddef	SoundA4, sfx_Skid
	snddef	SoundA5, sfx_A5
	snddef	SoundA6, sfx_HitSpikes
	snddef	SoundA7, sfx_Push
	snddef	SoundA8, sfx_SSGoal
	snddef	SoundA9, sfx_SSItem
	snddef	SoundAA, sfx_Splash
	snddef	SoundAB, sfx_AB
	snddef	SoundAC, sfx_HitBoss
	snddef	SoundAD, sfx_Bubble
	snddef	SoundAE, sfx_Fireball
	snddef	SoundAF, sfx_Shield
	snddef	SoundB0, sfx_Saw
	snddef	SoundB1, sfx_Electric
	snddef	SoundB2, sfx_Drown
	snddef	SoundB3, sfx_Flamethrower
	snddef	SoundB4, sfx_Bumper
	snddef	SoundB5, sfx_Ring
	snddef	SoundB6, sfx_SpikesMove
	snddef	SoundB7, sfx_Rumbling
	snddef	SoundB8, sfx_B8
	snddef	SoundB9, sfx_Collapse
	snddef	SoundBA, sfx_SSGlass
	snddef	SoundBB, sfx_Door
	snddef	SoundBC, sfx_Teleport
	snddef	SoundBD, sfx_ChainStomp
	snddef	SoundBE, sfx_Roll
	snddef	SoundBF, sfx_Continue
	snddef	SoundC0, sfx_Basaran
	snddef	SoundC1, sfx_BreakItem
	snddef	SoundC2, sfx_Warning
	snddef	SoundC3, sfx_GiantRing
	snddef	SoundC4, sfx_Bomb
	snddef	SoundC5, sfx_Cash
	snddef	SoundC6, sfx_RingLoss
	snddef	SoundC7, sfx_ChainRise
	snddef	SoundC8, sfx_Burning
	snddef	SoundC9, sfx_Bonus
	snddef	SoundCA, sfx_EnterSS
	snddef	SoundCB, sfx_WallSmash
	snddef	SoundCC, sfx_Spring
	snddef	SoundCD, sfx_Switch
	snddef	SoundCE, sfx_RingLeft
	snddef	SoundCF, sfx_Signpost
	snddef	SoundD0, sfx_SpinDash
	snddef	SoundD1, sfx_PeelCharge
	snddef	SoundD2, sfx_PeelRelease
	snddef	SoundD3, sfx_PeelStop

; ---------------------------------------------------------------------------
; Special sound effect pointers
; ---------------------------------------------------------------------------

flg__First:	equ $FA
flg__Last:	equ $FF

Sound_ExIndex:	sndtable flg__First
	snddef	PlayWaterfall,	sfx_Waterfall
	snddef	FadeOutMusic,	bgm_Fade
	snddef	PlaySegaSound,	sfx_Sega
	snddef	SpeedUpMusic,	bgm_Speedup
	snddef	SlowDownMusic,	bgm_Slowdown
	snddef	StopAllSound,	bgm_Stop