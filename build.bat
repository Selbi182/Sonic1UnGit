@ECHO OFF

REM // Make sure misc output folder exists.
if not exist "build_tools\generated" (
    mkdir "build_tools\generated"
)
REM // Rename previously successful build if one existed.
IF EXIST s1built.bin move /Y s1built.bin "build_tools\generated\s1built.prev.bin" > NUL

REM // Run the ASM68K assembly with the following parameters:
REM //   k  >>  allow use of ifeq, etc.
REM //   m  >>  expand macros in listing file
REM //   p  >>  produce pure binary output file
REM //   o ___  >>  set assembler options/optimisations:
REM //     ae-  >>  disable automatic even on dc/dcb/ds/rs .w/l
REM //     c+   >>  enable case sensitivity
REM //     l+   >>  use '.' as leading character for local labels
REM //     ws+  >>  allow white space in operands
REM //     v+   >>  write local labels to symbol file
REM //     op+  >>  pc relative optimisation
REM //     os+  >>  short branch optimisation
REM //     ow+  >>  absolute word addressing optimisation
REM //     oz+  >>  zero offset optimisation
REM //     oaq+ >>  addq optimisation
REM //     osq+ >>  subq optimisation
REM //     omq+ >>  moveq optimisation
REM // 
REM // Files:
REM //   sonic.asm    >>  input assembly file
REM //   s1built.bin  >>  assembled ROM
REM //   s1built.sym  >>  symbol file (required for the convsym.exe tool)
REM //   s1built.lst    >>  listing file
REM //   s1built.log    >>  console output redirected to log file
"build_tools\asm68k.exe" /k /m /p /o ae-,c+,l+,ws+,v+,op+,os+,ow+,oz+,oaq+,osq+,omq+ sonic1.asm, s1built.bin, "build_tools\generated\s1built.sym", "build_tools\generated\s1built.lst" > "build_tools\generated\s1built.log"

REM // Still print redirected log output to console (Batch doesn't suppport tee).
type "build_tools\generated\s1built.log"

REM // Fix checksum (only if output was generated).
if exist s1built.bin (
    "build_tools\fixheadr.exe" s1built.bin
)

REM // Append symbol table to the ROM.
"build_tools\convsym.exe" "build_tools\generated\s1built.sym" s1built.bin -a -range 0 FFFFFF -inopt "/localSign=. /processLocals-" -exclude -filter "(SMPS_(Track|RAM).*)|(.+_(END|End|end))"

REM // Pad the ROM.
if exist s1built.bin (
    rem "build_tools\rompad.exe" s1built.bin 255 0
)

REM // If assembly produced warnings or errors, pause here so that the user can read them.
findstr /i /c:"Warning :" /c:"Error :" "build_tools\generated\s1built.log" > NUL
if not errorlevel 1 (
    echo.
    pause
)
