; ===========================================================================
; ---------------------------------------------------------------------------
; Sound ID pointer macros
; ---------------------------------------------------------------------------

sndtbl:		macro	baselabel,startindex
.base_offset:	= *
.base_id:	= \startindex
.end_id:	= .base_id
\baselabel:	equ .base_id
		endm

snddef:		macro	romloc,asmlabel
\asmlabel:	equ ((*-.base_offset)/4)+.base_id
		dc.l romloc
.end_id:	= \asmlabel
		endm

sndtbl_end:	macro endlabel
\endlabel:	equ .end_id
		endm

inceven:	macro path
		include \path
		even
		endm

; ---------------------------------------------------------------------------
; Music Pointers
; ---------------------------------------------------------------------------

MusicIndex:	sndtbl	bgm__First, $81
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
	sndtbl_end	bgm__Last

bgm_includes	macro
Music81:	inceven	"sound/music/Mus81 - GHZ.asm"
Music82:	inceven	"sound/music/Mus82 - LZ.asm"
Music83:	inceven	"sound/music/Mus83 - MZ.asm"
Music84:	inceven	"sound/music/Mus84 - SLZ.asm"
Music85:	inceven	"sound/music/Mus85 - SYZ.asm"
Music86:	inceven	"sound/music/Mus86 - SBZ.asm"
Music87:	inceven	"sound/music/Mus87 - Invincibility.asm"
Music88:	inceven	"sound/music/Mus88 - Extra Life.asm"
Music89:	inceven	"sound/music/Mus89 - Special Stage.asm"
Music8A:	inceven	"sound/music/Mus8A - Title Screen.asm"
Music8B:	inceven	"sound/music/Mus8B - Ending.asm"
Music8C:	inceven	"sound/music/Mus8C - Boss.asm"
Music8D:	inceven	"sound/music/Mus8D - FZ.asm"
Music8E:	inceven	"sound/music/Mus8E - Sonic Got Through.asm"
Music8F:	inceven	"sound/music/Mus8F - Game Over.asm"
Music90:	inceven	"sound/music/Mus90 - Continue Screen.asm"
Music91:	inceven	"sound/music/Mus91 - Credits.asm"
Music92:	inceven	"sound/music/Mus92 - Drowning.asm"
Music93:	inceven	"sound/music/Mus93 - Get Emerald.asm"
		endm

; ---------------------------------------------------------------------------
; Sound effect pointers
; ---------------------------------------------------------------------------

SoundIndex:	sndtbl	sfx__First, $A0
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
	sndtbl_end	sfx__Last

sfx_includes	macro
SoundA0:	inceven	"sound/sfx/SndA0 - Jump.asm"
SoundA1:	inceven	"sound/sfx/SndA1 - Lamppost.asm"
SoundA2:	inceven	"sound/sfx/SndA2.asm"
SoundA3:	inceven	"sound/sfx/SndA3 - Death.asm"
SoundA4:	inceven	"sound/sfx/SndA4 - Skid.asm"
SoundA5:	inceven	"sound/sfx/SndA5.asm"
SoundA6:	inceven	"sound/sfx/SndA6 - Hit Spikes.asm"
SoundA7:	inceven	"sound/sfx/SndA7 - Push Block.asm"
SoundA8:	inceven	"sound/sfx/SndA8 - SS Goal.asm"
SoundA9:	inceven	"sound/sfx/SndA9 - SS Item.asm"
SoundAA:	inceven	"sound/sfx/SndAA - Splash.asm"
SoundAB:	inceven	"sound/sfx/SndAB.asm"
SoundAC:	inceven	"sound/sfx/SndAC - Hit Boss.asm"
SoundAD:	inceven	"sound/sfx/SndAD - Get Bubble.asm"
SoundAE:	inceven	"sound/sfx/SndAE - Fireball.asm"
SoundAF:	inceven	"sound/sfx/SndAF - Shield.asm"
SoundB0:	inceven	"sound/sfx/SndB0 - Saw.asm"
SoundB1:	inceven	"sound/sfx/SndB1 - Electric.asm"
SoundB2:	inceven	"sound/sfx/SndB2 - Drown Death.asm"
SoundB3:	inceven	"sound/sfx/SndB3 - Flamethrower.asm"
SoundB4:	inceven	"sound/sfx/SndB4 - Bumper.asm"
SoundB5:	inceven	"sound/sfx/SndB5 - Ring.asm"
SoundB6:	inceven	"sound/sfx/SndB6 - Spikes Move.asm"
SoundB7:	inceven	"sound/sfx/SndB7 - Rumbling.asm"
SoundB8:	inceven	"sound/sfx/SndB8.asm"
SoundB9:	inceven	"sound/sfx/SndB9 - Collapse.asm"
SoundBA:	inceven	"sound/sfx/SndBA - SS Glass.asm"
SoundBB:	inceven	"sound/sfx/SndBB - Door.asm"
SoundBC:	inceven	"sound/sfx/SndBC - Teleport.asm"
SoundBD:	inceven	"sound/sfx/SndBD - ChainStomp.asm"
SoundBE:	inceven	"sound/sfx/SndBE - Roll.asm"
SoundBF:	inceven	"sound/sfx/SndBF - Get Continue.asm"
SoundC0:	inceven	"sound/sfx/SndC0 - Basaran Flap.asm"
SoundC1:	inceven	"sound/sfx/SndC1 - Break Item.asm"
SoundC2:	inceven	"sound/sfx/SndC2 - Drown Warning.asm"
SoundC3:	inceven	"sound/sfx/SndC3 - Giant Ring.asm"
SoundC4:	inceven	"sound/sfx/SndC4 - Bomb.asm"
SoundC5:	inceven	"sound/sfx/SndC5 - Cash Register.asm"
SoundC6:	inceven	"sound/sfx/SndC6 - Ring Loss.asm"
SoundC7:	inceven	"sound/sfx/SndC7 - Chain Rising.asm"
SoundC8:	inceven	"sound/sfx/SndC8 - Burning.asm"
SoundC9:	inceven	"sound/sfx/SndC9 - Hidden Bonus.asm"
SoundCA:	inceven	"sound/sfx/SndCA - Enter SS.asm"
SoundCB:	inceven	"sound/sfx/SndCB - Wall Smash.asm"
SoundCC:	inceven	"sound/sfx/SndCC - Spring.asm"
SoundCD:	inceven	"sound/sfx/SndCD - Switch.asm"
SoundCE:	inceven	"sound/sfx/SndCE - Ring Left Speaker.asm"
SoundCF:	inceven	"sound/sfx/SndCF - Signpost.asm"
SoundD0:	inceven	"sound/sfx/SndD1 - Spin Dash Rev.asm"
SoundD1:	inceven	"sound/sfx/SndD2 - Peelout Charge.asm"
SoundD2:	inceven	"sound/sfx/SndD3 - Peelout Release.asm"
SoundD3:	inceven	"sound/sfx/SndD4 - Peelout Stop.asm"
		endm

; ---------------------------------------------------------------------------
; Special sound effect pointers
; ---------------------------------------------------------------------------

Sound_ExIndex:	sndtbl	flg__First, $FA
	snddef	PlayWaterfall,	sfx_Waterfall
	snddef	FadeOutMusic,	bgm_Fade
	snddef	PlaySegaSound,	sfx_Sega
	snddef	SpeedUpMusic,	bgm_Speedup
	snddef	SlowDownMusic,	bgm_Slowdown
	snddef	StopAllSound,	bgm_Stop
	sndtbl_end	flg__Last

spec_includes	macro
SoundWaterfall:	inceven	"sound/sfx/SndD0 - Waterfall.asm"
		endm
