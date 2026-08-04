
; ---------------------------------------------------------------
SampleTable:
; name?                         type            pointer         Hz              flags?          ; sample id
                dcSample        TYPE_DPCM,      Kick,           8000                            ; $81
                dcSample        TYPE_PCM,       Snare,          24000                           ; $82
                dcSample        TYPE_DPCM,      Timpani,        7250                            ; $83
                dcSample        TYPE_NONE                                                       ; $84
                dcSample        TYPE_NONE                                                       ; $85
                dcSample        TYPE_NONE                                                       ; $86
                dcSample        TYPE_NONE                                                       ; $87
                dcSample        TYPE_DPCM,      Timpani,        9750                            ; $88
                dcSample        TYPE_DPCM,      Timpani,        8750                            ; $89
                dcSample        TYPE_DPCM,      Timpani,        7150                            ; $8A
                dcSample        TYPE_DPCM,      Timpani,        7000                            ; $8B
dacSega:        dcSample        TYPE_PCM,       SegaVoice,      16000,          FLAGS_SFX       ; $8C (or just `dacSega.id`)
                dc.w    -1      ; end marker

; ---------------------------------------------------------------
                incdac  Kick, "sound/dac/kick.dpcm"
                incdac  Snare, "sound/dac/snare.wav"
                incdac  Timpani, "sound/dac/timpani.dpcm"
                incdac  SegaVoice, "sound/dac/sega.wav"
                even
