@echo off
setlocal
cd /d "%~dp0"
title Playlist Creator x64 Build

set "LOG=%~dp0build_x64.log"
if exist "%LOG%" del /q "%LOG%"

cls
echo ============================================================
echo  Playlist Creator - x64 Release Build
echo ============================================================
echo.
echo The complete build output will also be saved to:
echo %LOG%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Build-x64.ps1" -Configuration Release > "%LOG%" 2>&1
set "BUILD_RESULT=%ERRORLEVEL%"

type "%LOG%"
echo.
echo ============================================================
if "%BUILD_RESULT%"=="0" (
    echo  BUILD SUCCEEDED
    echo.
    echo  Program:
    echo  %~dp0bin\x64\Release\pc3.exe
) else (
    echo  BUILD FAILED - error code %BUILD_RESULT%
    echo.
    echo  The window will remain open so the errors can be read.
    echo  A copy is saved in build_x64.log in this folder.
)
echo ============================================================
echo.
pause
exit /b %BUILD_RESULT%
