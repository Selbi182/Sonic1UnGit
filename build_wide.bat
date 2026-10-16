@ECHO OFF

REM // Rename previously successful build if one existed.
IF EXIST s1built-wide.bin move /Y s1built-wide.bin s1built-wide.prev.bin > NUL

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
REM //   s1built-wide.bin  >>  assembled ROM
REM //   s1built-wide.sym  >>  symbol file (required for the convsym.exe tool)
REM //   sonic.lst    >>  listing file
REM //   sonic.log    >>  console output redirected to log file
"build_tools\asm68k.exe" /e __build_wide__=1 /k /m /p /o ae-,c+,l+,ws+,v+,op+,os+,ow+,oz+,oaq+,osq+,omq+ sonic1.asm, s1built-wide.bin, s1built-wide.sym, sonic.lst > sonic.log

REM // Still print redirected log output to console (Batch doesn't suppport tee).
type sonic.log

REM // Fix checksum (only if output was generated).
if exist s1built-wide.bin (
    "build_tools\fixheadr.exe" s1built-wide.bin
)

REM // Append symbol table to the ROM.
"build_tools\convsym.exe" s1built-wide.sym s1built-wide.bin -a -range 0 FFFFFF -inopt "/localSign=. /processLocals-" -exclude -filter "(SMPS_(Track|RAM).*)|(.+_(END|End|end))"

REM // Pad the ROM.
if exist s1built-wide.bin (
    rem "build_tools\rompad.exe" s1built-wide.bin 255 0
)

REM // If assembly produced warnings or errors, pause here so that the user can read them.
findstr /i /c:"Warning :" /c:"Error :" sonic.log > NUL
if not errorlevel 1 (
    echo.
    pause
)
