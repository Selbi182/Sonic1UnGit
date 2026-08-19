; macro to declare a mappings table (taken from Sonic 2 disassembly)
mappingsTable: macro *
\*:
.current_mappings_table = *
    endm

; macro to declare an entry in a mappings table (taken from Sonic 2 disassembly)
mappingsTableEntry: macro ptr
	dc.\0 \ptr-.current_mappings_table
    endm

spriteHeader: macro *
\*:
	dc.w ((\*_End-\*_Begin)/8)
\*_Begin:
    endm

spritePiece: macro xpos,ypos,width,height,tile,xflip,yflip,pal,pri
	dc.w	\ypos
	dc.w	(((((\width)-1)&3)<<2)|(((\height)-1)&3))<<8+($00) ; $00 = sprite link placeholder
	dc.w	((((\pri)&1)<<15)|(((\pal)&3)<<13)|(((\yflip)&1)<<12)|(((\xflip)&1)<<11))+(\tile)
	dc.w	\xpos
	endm

dplcHeader: macro *
\*:
	if SonicDplcVer=1
		dc.b ((\*_End-\*_Begin)/2)
	elseif SonicDplcVer=3
		dc.w (((\*_End-\*_Begin)/2)-1)
	else
		dc.w ((\*_End-\*_Begin)/2)
	endif
\*_Begin:
    endm

dplcEntry macro tiles,offset
	if SonicDplcVer=3
		dc.w	(((\offset)&$FFF)<<4)|(((\tiles)-1)&$F)
	elseif SonicDplcVer=4
		dc.w	((((\tiles)-1)&$F)<<12)|(((\offset)&$FFF)<<4)
	else
		dc.w	((((\tiles)-1)&$F)<<12)|((\offset)&$FFF)
	endif
	endm
