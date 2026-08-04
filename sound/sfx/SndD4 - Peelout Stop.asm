SonicCD_AB_Header:
	smpsHeaderStartSong	2, 1
	smpsHeaderVoice		SonicCD_AB_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX	$01
	smpsHeaderSFXChannel	cFM5, SonicCD_AB_FM1, $00, $00

SonicCD_AB_FM1:
	smpsStop
	smpsStop	; Unused

SonicCD_AB_Voices: