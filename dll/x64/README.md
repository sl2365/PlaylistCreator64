# MediaInfo x64 runtime

The x64 build requires a 64-bit `MediaInfo.dll` in this directory while building.

Normally you do not need to place it here manually. `build_x64.bat` calls the PowerShell dependency script when the DLL is missing. The script downloads MediaInfo x64 v26.05, verifies that it is an AMD64 PE file, and writes it here.

The downloaded DLL is then copied beside `pc3.exe` in `bin\x64\Release`.

Do not place a 32-bit MediaInfo DLL in this directory.
