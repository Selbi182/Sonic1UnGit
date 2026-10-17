@ECHO OFF

REM // Convenience batch script to build the ROM and open it in the default emulator if compilation succeeds.
REM // Requires ".bin" files to be associated with an emulator.

call build_wide.bat

if exist s1built-wide.bin (
   rem start "" s1built-wide.bin

   set SDL_RENDER_DRIVER=opengl
   start ../ClownMDEmu.exe -f s1built-wide.bin
)