; ===========================================================================
; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------

; Macro to define PLC pointer entry
plcptr:		macro *,plc
\*:	equ	(*-ArtLoadCues)/2
		dc.w	plc-ArtLoadCues
		endm

; Macro for the header of a PLC list
plcheader:	macro *
\*:
		dc.w ((\*_end-\*-2)/6)-1
		endm

; Macro for single pattern load cue entry
plcm:	macro gfx,vram
	dc.l gfx
	dc.w (vram)*tile_size
	endm

; ---------------------------------------------------------------------------

; Index and ID definitions
ArtLoadCues:

plcid_Main:		plcptr	PLC_Main
plcid_Explode:		plcptr	PLC_Explode
plcid_GameOver:		plcptr	PLC_GameOver
plcid_GHZ:		plcptr	PLC_GHZ
plcid_LZ:		plcptr	PLC_LZ
plcid_MZ:		plcptr	PLC_MZ
plcid_SLZ:		plcptr	PLC_SLZ
plcid_SYZ:		plcptr	PLC_SYZ
plcid_SBZ:		plcptr	PLC_SBZ
plcid_Boss:		plcptr	PLC_Boss
plcid_Signpost:		plcptr	PLC_Signpost
plcid_SpecialStage:	plcptr	PLC_SpecialStage
plcid_SSResult:		plcptr	PLC_SSResult
plcid_Ending:		plcptr	PLC_Ending
plcid_TryAgain:		plcptr	PLC_TryAgain
plcid_EggmanSBZ2:	plcptr	PLC_EggmanSBZ2
plcid_FZBoss:		plcptr	PLC_FZBoss
plcid_Sega:		plcptr	PLC_Sega
plcid_TitleSonicTeam:	plcptr	PLC_TitleSonicTeam
plcid_TitleForeground:	plcptr	PLC_TitleForeground
plcid_TitleBackground:	plcptr	PLC_TitleBackground
plcid_Continue:		plcptr	PLC_Continue
plcid_Credits:		plcptr	PLC_Credits

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	plcheader
		plcm	KosPM_Hud,		ArtTile_HUD			; HUD
		plcm	KosPM_Sparkles,		ArtTile_Sparkles		; ring sparkles
		plcm	KosPM_Lamp,		ArtTile_Lamppost		; lamppost
		plcm	KosPM_Monitors,		ArtTile_Monitor			; monitors
	if Enable_InfiniteLives=0
		plcm	KosPM_Lives,		ArtTile_Lives_Counter		; lives counter
	endif
PLC_Main_end:

; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	plcheader
		plcm	KosPM_Explode,		ArtTile_Explosion		; explosion
PLC_Explode_end:

; ---------------------------------------------------------------------------
; Pattern load cues - game/time over
; ---------------------------------------------------------------------------
PLC_GameOver:	plcheader
		plcm	KosPM_GameOver,		ArtTile_Game_Over		; game/time over
PLC_GameOver_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	plcheader
		plcm	KosPM_GHZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_Stalk,		ArtTile_GHZ_Flower_Stalk	; flower stalk
		plcm	KosPM_PplRock,		ArtTile_GHZ_Purple_Rock		; purple rock
		plcm	KosPM_Crabmeat,		ArtTile_Crabmeat		; crabmeat enemy
		plcm	KosPM_Buzz,		ArtTile_Buzz_Bomber		; buzz bomber enemy
		plcm	KosPM_Chopper,		ArtTile_Chopper			; chopper enemy
		plcm	KosPM_Newtron,		ArtTile_Newtron			; newtron enemy
		plcm	KosPM_Motobug,		ArtTile_Moto_Bug		; motobug enemy
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_Swing,		ArtTile_GHZ_MZ_Swing		; swinging platform
		plcm	KosPM_Bridge,		ArtTile_GHZ_Bridge		; bridge
		plcm	KosPM_SpikePole,	ArtTile_GHZ_Spike_Pole		; spiked pole
		plcm	KosPM_Ball,		ArtTile_GHZ_Giant_Ball		; giant ball
		plcm	KosPM_GhzWall1,		ArtTile_GHZ_SLZ_Smashable_Wall	; breakable wall
		plcm	KosPM_GhzWall2,		ArtTile_GHZ_Edge_Wall		; normal wall
		plcm	KosPM_Rabbit,		ArtTile_Animal_1		; rabbit
		plcm	KosPM_Flicky,		ArtTile_Animal_2		; flicky
PLC_GHZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		plcheader
		plcm	KosPM_LZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_LzBlock1,		ArtTile_LZ_Block_1		; block
		plcm	KosPM_LzBlock2,		ArtTile_LZ_Block_2		; blocks
		plcm	KosPM_Splash,		ArtTile_LZ_Splash		; waterfalls and splash
		plcm	KosPM_LzSpikeBall,	ArtTile_LZ_Spikeball_Chain	; spiked ball
		plcm	KosPM_FlapDoor,		ArtTile_LZ_Flapping_Door	; flapping door
		plcm	KosPM_Bubbles,		ArtTile_LZ_Bubbles		; bubbles and numbers
		plcm	KosPM_LzBlock3,		ArtTile_LZ_Moving_Block		; block
		plcm	KosPM_LzDoor1,		ArtTile_LZ_Door			; vertical door
		plcm	KosPM_Harpoon,		ArtTile_LZ_Harpoon		; harpoon
		plcm	KosPM_Burrobot,		ArtTile_Burrobot		; burrobot enemy
		plcm	KosPM_LzPole,		ArtTile_LZ_Pole			; pole that breaks
		plcm	KosPM_LzDoor2,		ArtTile_LZ_Blocks		; large horizontal door
		plcm	KosPM_LzWheel,		ArtTile_LZ_Conveyor_Belt	; wheel
		plcm	KosPM_Gargoyle,		ArtTile_LZ_Gargoyle		; gargoyle head
		plcm	KosPM_LzPlatfm,		ArtTile_LZ_Rising_Platform	; rising platform
		plcm	KosPM_Orbinaut,		ArtTile_LZ_Orbinaut		; orbinaut enemy
		plcm	KosPM_Jaws,		ArtTile_Jaws			; jaws enemy
		plcm	KosPM_LzSwitch,		ArtTile_Button			; switch
		plcm	KosPM_Cork,		ArtTile_LZ_Cork			; cork block
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_Penguin,		ArtTile_Animal_1		; penguin
		plcm	KosPM_Seal,		ArtTile_Animal_2		; seal
PLC_LZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		plcheader
		plcm	KosPM_MZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_MzMetal,		ArtTile_MZ_Spike_Stomper	; metal blocks
		plcm	KosPM_MzFire,		ArtTile_MZ_Fireball		; fireballs
		plcm	KosPM_Swing,		ArtTile_GHZ_MZ_Swing		; swinging platform
		plcm	KosPM_MzGlass,		ArtTile_MZ_Glass_Pillar		; green glassy block
		plcm	KosPM_Lava,		ArtTile_MZ_Lava			; lava
		plcm	KosPM_Buzz,		ArtTile_Buzz_Bomber		; buzz bomber enemy
		plcm	KosPM_Yadrin,		ArtTile_Yadrin			; yadrin enemy
		plcm	KosPM_Basaran,		ArtTile_Basaran			; basaran enemy
		plcm	KosPM_Cater,		ArtTile_MZ_SYZ_Caterkiller	; caterkiller enemy
		plcm	KosPM_MzSwitch,		ArtTile_Button			; switch
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_MzBlock,		ArtTile_MZ_Block		; green stone block
		plcm	KosPM_Squirrel,		ArtTile_Animal_1		; squirrel
		plcm	KosPM_Seal,		ArtTile_Animal_2		; seal
PLC_MZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	plcheader
		plcm	KosPM_SLZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_Bomb,		ArtTile_Bomb			; bomb enemy
		plcm	KosPM_Orbinaut,		ArtTile_SLZ_Orbinaut		; orbinaut enemy
		plcm	KosPM_MzFire,		ArtTile_SLZ_Fireball		; fireballs
		plcm	KosPM_SlzBlock,		ArtTile_SLZ_Collapsing_Floor	; block
		plcm	KosPM_SlzWall,		ArtTile_GHZ_SLZ_Smashable_Wall+4 ; breakable wall
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_Seesaw,		ArtTile_SLZ_Seesaw		; seesaw
		plcm	KosPM_Fan,		ArtTile_SLZ_Fan			; fan
		plcm	KosPM_Pylon,		ArtTile_SLZ_Pylon		; foreground pylon
		plcm	KosPM_SlzSwing,		ArtTile_SLZ_Swing		; swinging platform
		plcm	KosPM_SlzCannon,	ArtTile_SLZ_Fireball_Launcher	; fireball launcher
		plcm	KosPM_SlzSpike,		ArtTile_SLZ_Spikeball		; spikeball
		plcm	KosPM_Pig,		ArtTile_Animal_1		; pig
		plcm	KosPM_Flicky,		ArtTile_Animal_2		; flicky
PLC_SLZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	plcheader
		plcm	KosPM_SYZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_Crabmeat,		ArtTile_Crabmeat		; crabmeat enemy
		plcm	KosPM_Buzz,		ArtTile_Buzz_Bomber		; buzz bomber enemy
		plcm	KosPM_Yadrin,		ArtTile_Yadrin			; yadrin enemy
		plcm	KosPM_Roller,		ArtTile_Roller			; roller enemy
		plcm	KosPM_Bumper,		ArtTile_SYZ_Bumper		; bumper
		plcm	KosPM_SyzSpike1,	ArtTile_SYZ_Big_Spikeball	; large spikeball
		plcm	KosPM_SyzSpike2,	ArtTile_SYZ_Spikeball_Chain	; small spikeball
		plcm	KosPM_LzSwitch,		ArtTile_Button			; switch
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_Pig,		ArtTile_Animal_1		; pig
		plcm	KosPM_Chicken,		ArtTile_Animal_2		; chicken
PLC_SYZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	plcheader
		plcm	KosPM_SBZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_Stomper,		ArtTile_SBZ_Moving_Block_Short	; moving platform and stomper
		plcm	KosPM_SbzDoor1,		ArtTile_SBZ_Door		; door
		plcm	KosPM_Girder,		ArtTile_SBZ_Girder		; girder
		plcm	KosPM_BallHog,		ArtTile_Ball_Hog		; ball hog enemy
		plcm	KosPM_SbzWheel1,	ArtTile_SBZ_Disc		; spot on large wheel
		plcm	KosPM_SbzWheel2,	ArtTile_SBZ_Junction		; wheel that grabs Sonic
		plcm	KosPM_SyzSpike1,	ArtTile_SBZ_Swing		; large spikeball
		plcm	KosPM_Cutter,		ArtTile_SBZ_Saw			; pizza cutter
		plcm	KosPM_FlamePipe,	ArtTile_SBZ_Flamethrower	; flaming pipe
		plcm	KosPM_SbzFloor,		ArtTile_SBZ_Collapsing_Floor	; collapsing floor
		plcm	KosPM_SbzBlock,		ArtTile_SBZ_Vanishing_Block	; vanishing block
		plcm	KosPM_Cater,		ArtTile_SBZ_Caterkiller		; caterkiller enemy
		plcm	KosPM_Bomb,		ArtTile_Bomb			; bomb enemy
		plcm	KosPM_Orbinaut,		ArtTile_SBZ_Orbinaut		; orbinaut enemy
		plcm	KosPM_SlideFloor,	ArtTile_SBZ_Moving_Block_Long	; floor that slides away
		plcm	KosPM_SbzDoor2,		ArtTile_SBZ_Horizontal_Door	; horizontal door
		plcm	KosPM_Electric,		ArtTile_SBZ_Electric_Orb	; electric orb
		plcm	KosPM_TrapDoor,		ArtTile_SBZ_Trap_Door		; trapdoor
		plcm	KosPM_SbzFloor,		ArtTile_SBZ_Collapsing_Floor+4	; collapsing floor
		plcm	KosPM_SpinPform,	ArtTile_SBZ_Spinning_Platform	; small spinning platform
		plcm	KosPM_LzSwitch,		ArtTile_Button			; switch
		plcm	KosPM_Spikes,		ArtTile_Spikes			; spikes
		plcm	KosPM_HSpring,		ArtTile_Spring_Horizontal	; horizontal spring
		plcm	KosPM_VSpring,		ArtTile_Spring_Vertical		; vertical spring
		plcm	KosPM_Rabbit,		ArtTile_Animal_1		; rabbit
		plcm	KosPM_Chicken,		ArtTile_Animal_2		; chicken
PLC_SBZ_end:

; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	plcheader
		plcm	KosPM_Eggman,		ArtTile_Eggman			; Eggman main patterns
		plcm	KosPM_Weapons,		ArtTile_Eggman_Weapons		; Eggman's weapons
		plcm	KosPM_Prison,		ArtTile_Prison_Capsule		; prison capsule
		plcm	KosPM_Bomb,		ArtTile_Eggman_Spikeball	; bomb enemy (gets overwritten)
		plcm	KosPM_SlzSpike,		ArtTile_Eggman_Spikeball	; spikeball (SLZ boss)
		plcm	KosPM_Exhaust,		ArtTile_Eggman_Exhaust		; exhaust flame
PLC_Boss_end:

; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost
; ---------------------------------------------------------------------------
PLC_Signpost:	plcheader
		plcm	KosPM_SignPost,		ArtTile_Signpost		; signpost
		plcm	KosPM_Bonus,		ArtTile_Hidden_Points		; hidden bonus points
PLC_Signpost_end:

; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	plcheader
		plcm	KosPM_SSBgCloud,	ArtTile_SS_Background_Clouds	; bubble and cloud background
		plcm	KosPM_SSBgFish,		ArtTile_SS_Background_Fish	; bird and fish background
		plcm	KosPM_Sparkles,		ArtTile_SS_Sparkles		; ring sparkles
		plcm	KosPM_Bumper,		ArtTile_SS_Bumper		; bumper
		plcm	KosPM_SSGOAL,		ArtTile_SS_Goal			; GOAL block
		plcm	KosPM_SSUpDown,		ArtTile_SS_Up_Down		; UP and DOWN blocks
		plcm	KosPM_SSRBlock,		ArtTile_SS_R_Block		; R block
		plcm	KosPM_SS1UpBlock,	ArtTile_SS_Extra_Life		; 1UP block
		plcm	KosPM_SSEmStars,	ArtTile_SS_Emerald_Sparkle	; emerald collection stars
		plcm	KosPM_SSRedWhite,	ArtTile_SS_Red_White_Block	; red and white block
		plcm	KosPM_SSGhost,		ArtTile_SS_Ghost_Block		; ghost block
		plcm	KosPM_SSWBlock,		ArtTile_SS_W_Block		; W block
		plcm	KosPM_SSGlass,		ArtTile_SS_Glass		; glass block
		plcm	KosPM_SSEmerald,	ArtTile_SS_Emerald		; emeralds
		plcm	KosPM_SSZone1,		ArtTile_SS_Zone_1		; ZONE 1 block
		plcm	KosPM_SSZone2,		ArtTile_SS_Zone_2		; ZONE 2 block
		plcm	KosPM_SSZone3,		ArtTile_SS_Zone_3		; ZONE 3 block
		plcm	KosPM_SSZone4,		ArtTile_SS_Zone_4		; ZONE 4 block
		plcm	KosPM_SSZone5,		ArtTile_SS_Zone_5		; ZONE 5 block
		plcm	KosPM_SSZone6,		ArtTile_SS_Zone_6		; ZONE 6 block
PLC_SpecialStage_end:

; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:	plcheader
		plcm	KosPM_ResultEm,		ArtTile_SS_Results_Emeralds	; emeralds
		plcm	KosPM_MiniSonic,	ArtTile_Mini_Sonic		; mini Sonic
		plcm	KosPM_Hud,		ArtTile_HUD			; HUD
PLC_SSResult_end:

; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	plcheader
		plcm	KosPM_GHZ,		ArtTile_Level			; main level patterns
		plcm	KosPM_Stalk,		ArtTile_GHZ_Flower_Stalk	; flower stalk
		plcm	KosPM_EndFlower,	ArtTile_Ending_Flowers		; flowers
		plcm	KosPM_EndEm,		ArtTile_Ending_Emeralds		; emeralds
		plcm	KosPM_EndSonic,		ArtTile_Ending_Sonic		; Sonic
		plcm	KosPM_Rabbit,		ArtTile_Ending_Rabbit		; rabbit
		plcm	KosPM_Chicken,		ArtTile_Ending_Chicken		; chicken
		plcm	KosPM_Penguin,		ArtTile_Ending_Penguin		; penguin
		plcm	KosPM_Seal,		ArtTile_Ending_Seal		; seal
		plcm	KosPM_Pig,		ArtTile_Ending_Pig		; pig
		plcm	KosPM_Flicky,		ArtTile_Ending_Flicky		; flicky
		plcm	KosPM_Squirrel,		ArtTile_Ending_Squirrel		; squirrel
		plcm	KosPM_EndStH,		ArtTile_Ending_STH		; "SONIC THE HEDGEHOG"
		plcm	KosPM_Hud,		ArtTile_HUD			; HUD
PLC_Ending_end:

; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	plcheader
		plcm	KosPM_EndEm,		ArtTile_Try_Again_Emeralds	; emeralds
		plcm	KosPM_TryAgain,		ArtTile_Try_Again_Eggman	; Eggman
		plcm	KosPM_CreditText,	ArtTile_Credits_Font		; credits alphabet
PLC_TryAgain_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	plcheader
		plcm	KosPM_SbzBlock,		ArtTile_Eggman_Trap_Floor	; block
		plcm	KosPM_Sbz2Eggman,	ArtTile_Eggman			; Eggman
		plcm	KosPM_LzSwitch,		ArtTile_Eggman_Button-4		; switch
PLC_EggmanSBZ2_end:

; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	plcheader
		plcm	KosPM_FzEggman,		ArtTile_FZ_Eggman_Fleeing	; Eggman after boss
		plcm	KosPM_FzBoss,		ArtTile_FZ_Boss			; FZ boss
		plcm	KosPM_Eggman,		ArtTile_Eggman			; Eggman main patterns
		plcm	KosPM_Sbz2Eggman,	ArtTile_FZ_Eggman_No_Vehicle	; Eggman without ship
		plcm	KosPM_Exhaust,		ArtTile_Eggman_Exhaust		; exhaust flame
PLC_FZBoss_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Sega screen
; ---------------------------------------------------------------------------
PLC_Sega:	plcheader
		plcm	KosPM_SegaLogo,		ArtTile_Sega_Tiles
PLC_Sega_end:

; ---------------------------------------------------------------------------
; Pattern load cues - "SONIC TEAM PRESENTS" before title screen
; ---------------------------------------------------------------------------
PLC_TitleSonicTeam:	plcheader
		plcm	KosPM_JapNames,		ArtTile_Title_Japanese_Text
		plcm	KosPM_CreditText,	ArtTile_Sonic_Team_Font
PLC_TitleSonicTeam_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Title screen FG (while Sonic Team Presents is displayed)
; ---------------------------------------------------------------------------
PLC_TitleForeground:	plcheader
		plcm	KosPM_TitleFg,		ArtTile_Title_Foreground
		plcm	KosPM_TitleSonic,	ArtTile_Title_Sonic
		plcm	KosPM_TitleTM,		ArtTile_Title_Trademark
		plcm	KosPM_TitlePSB,		ArtTile_Title_PressStart
PLC_TitleForeground_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Title screen BG (after Sonic Team Presents faded out)
; ---------------------------------------------------------------------------
PLC_TitleBackground:	plcheader
		plcm	KosPM_Title,		ArtTile_Level
PLC_TitleBackground_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Continue screen
; ---------------------------------------------------------------------------
PLC_Continue:	plcheader
		plcm	KosPM_ContSonic,	ArtTile_Continue_Sonic
		plcm	KosPM_MiniSonic,	ArtTile_Mini_Sonic
		plcm	KosPM_TitleCard,	ArtTile_Title_Card
PLC_Continue_end:

; ---------------------------------------------------------------------------
; Pattern load cues - Credits screen
; ---------------------------------------------------------------------------
PLC_Credits:	plcheader
		plcm	KosPM_CreditText,	ArtTile_Credits_Font
PLC_Credits_end:
