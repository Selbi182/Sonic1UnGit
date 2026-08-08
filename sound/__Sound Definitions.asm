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



; ===========================================================================
; Relocated to have it all be in one file
sound_defs_include	macro

; ---------------------------------------------------------------------------
; SMPS2ASM - A collection of macros that make SMPS's bytecode human-readable.
; ---------------------------------------------------------------------------
SonicDriverVer = 1 ; Tell SMPS2ASM that we're using Sonic 1's driver.
		include "sound/_smps2asm_inc.asm"

; ---------------------------------------------------------------------------
; Music data
; ---------------------------------------------------------------------------
Music81:	include "sound/music/Mus81 - GHZ.asm"
		even
Music82:	include "sound/music/Mus82 - LZ.asm"
		even
Music83:	include "sound/music/Mus83 - MZ.asm"
		even
Music84:	include "sound/music/Mus84 - SLZ.asm"
		even
Music85:	include "sound/music/Mus85 - SYZ.asm"
		even
Music86:	include "sound/music/Mus86 - SBZ.asm"
		even
Music87:	include "sound/music/Mus87 - Invincibility.asm"
		even
Music88:	include "sound/music/Mus88 - Extra Life.asm"
		even
Music89:	include "sound/music/Mus89 - Special Stage.asm"
		even
Music8A:	include "sound/music/Mus8A - Title Screen.asm"
		even
Music8B:	include "sound/music/Mus8B - Ending.asm"
		even
Music8C:	include "sound/music/Mus8C - Boss.asm"
		even
Music8D:	include "sound/music/Mus8D - FZ.asm"
		even
Music8E:	include "sound/music/Mus8E - Sonic Got Through.asm"
		even
Music8F:	include "sound/music/Mus8F - Game Over.asm"
		even
Music90:	include "sound/music/Mus90 - Continue Screen.asm"
		even
Music91:	include "sound/music/Mus91 - Credits.asm"
		even
Music92:	include "sound/music/Mus92 - Drowning.asm"
		even
Music93:	include "sound/music/Mus93 - Get Emerald.asm"
		even

; ---------------------------------------------------------------------------
; Sound effect data
; ---------------------------------------------------------------------------
SoundA0:	include "sound/sfx/SndA0 - Jump.asm"
		even
SoundA1:	include "sound/sfx/SndA1 - Lamppost.asm"
		even
SoundA2:	include "sound/sfx/SndA2.asm"
		even
SoundA3:	include "sound/sfx/SndA3 - Death.asm"
		even
SoundA4:	include "sound/sfx/SndA4 - Skid.asm"
		even
SoundA5:	include "sound/sfx/SndA5.asm"
		even
SoundA6:	include "sound/sfx/SndA6 - Hit Spikes.asm"
		even
SoundA7:	include "sound/sfx/SndA7 - Push Block.asm"
		even
SoundA8:	include "sound/sfx/SndA8 - SS Goal.asm"
		even
SoundA9:	include "sound/sfx/SndA9 - SS Item.asm"
		even
SoundAA:	include "sound/sfx/SndAA - Splash.asm"
		even
SoundAB:	include "sound/sfx/SndAB.asm"
		even
SoundAC:	include "sound/sfx/SndAC - Hit Boss.asm"
		even
SoundAD:	include "sound/sfx/SndAD - Get Bubble.asm"
		even
SoundAE:	include "sound/sfx/SndAE - Fireball.asm"
		even
SoundAF:	include "sound/sfx/SndAF - Shield.asm"
		even
SoundB0:	include "sound/sfx/SndB0 - Saw.asm"
		even
SoundB1:	include "sound/sfx/SndB1 - Electric.asm"
		even
SoundB2:	include "sound/sfx/SndB2 - Drown Death.asm"
		even
SoundB3:	include "sound/sfx/SndB3 - Flamethrower.asm"
		even
SoundB4:	include "sound/sfx/SndB4 - Bumper.asm"
		even
SoundB5:	include "sound/sfx/SndB5 - Ring.asm"
		even
SoundB6:	include "sound/sfx/SndB6 - Spikes Move.asm"
		even
SoundB7:	include "sound/sfx/SndB7 - Rumbling.asm"
		even
SoundB8:	include "sound/sfx/SndB8.asm"
		even
SoundB9:	include "sound/sfx/SndB9 - Collapse.asm"
		even
SoundBA:	include "sound/sfx/SndBA - SS Glass.asm"
		even
SoundBB:	include "sound/sfx/SndBB - Door.asm"
		even
SoundBC:	include "sound/sfx/SndBC - Teleport.asm"
		even
SoundBD:	include "sound/sfx/SndBD - ChainStomp.asm"
		even
SoundBE:	include "sound/sfx/SndBE - Roll.asm"
		even
SoundBF:	include "sound/sfx/SndBF - Get Continue.asm"
		even
SoundC0:	include "sound/sfx/SndC0 - Basaran Flap.asm"
		even
SoundC1:	include "sound/sfx/SndC1 - Break Item.asm"
		even
SoundC2:	include "sound/sfx/SndC2 - Drown Warning.asm"
		even
SoundC3:	include "sound/sfx/SndC3 - Giant Ring.asm"
		even
SoundC4:	include "sound/sfx/SndC4 - Bomb.asm"
		even
SoundC5:	include "sound/sfx/SndC5 - Cash Register.asm"
		even
SoundC6:	include "sound/sfx/SndC6 - Ring Loss.asm"
		even
SoundC7:	include "sound/sfx/SndC7 - Chain Rising.asm"
		even
SoundC8:	include "sound/sfx/SndC8 - Burning.asm"
		even
SoundC9:	include "sound/sfx/SndC9 - Hidden Bonus.asm"
		even
SoundCA:	include "sound/sfx/SndCA - Enter SS.asm"
		even
SoundCB:	include "sound/sfx/SndCB - Wall Smash.asm"
		even
SoundCC:	include "sound/sfx/SndCC - Spring.asm"
		even
SoundCD:	include "sound/sfx/SndCD - Switch.asm"
		even
SoundCE:	include "sound/sfx/SndCE - Ring Left Speaker.asm"
		even
SoundCF:	include "sound/sfx/SndCF - Signpost.asm"
		even
SoundD0:	include "sound/sfx/SndD1 - Spin Dash Rev.asm"
		even
SoundD1:	include "sound/sfx/SndD2 - Peelout Charge.asm"
		even
SoundD2:	include "sound/sfx/SndD3 - Peelout Release.asm"
		even
SoundD3:	include "sound/sfx/SndD4 - Peelout Stop.asm"
		even

; ---------------------------------------------------------------------------
; Special sound effect data
; ---------------------------------------------------------------------------
SoundWaterfall:	include "sound/sfx/SndD0 - Waterfall.asm"
		even

	endm