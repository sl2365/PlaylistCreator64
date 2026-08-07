@echo off
setlocal
cd /d "%~dp0"
title Playlist Creator Help Build

set "HHC="
if exist "%ProgramFiles(x86)%\HTML Help Workshop\hhc.exe" set "HHC=%ProgramFiles(x86)%\HTML Help Workshop\hhc.exe"
if not defined HHC if exist "%ProgramFiles%\HTML Help Workshop\hhc.exe" set "HHC=%ProgramFiles%\HTML Help Workshop\hhc.exe"
if not defined HHC for %%I in (hhc.exe) do if not "%%~$PATH:I"=="" set "HHC=%%~$PATH:I"

if not defined HHC (
    echo ============================================================
    echo  HTML HELP COMPILER NOT FOUND
    echo ============================================================
    echo.
    echo Microsoft HTML Help Workshop ^(hhc.exe^) is required only
    echo when rebuilding the .chm help files.
    echo.
    echo Install HTML Help Workshop, then double-click this file again.
    echo The normal x64 application build does not require it.
    echo.
    pause
    exit /b 1
)

echo HTML Help compiler:
echo %HHC%
echo.

pushd "%~dp0help"
if exist "PC3_EN.chm" del /q "PC3_EN.chm"
if exist "PC3_DE.chm" del /q "PC3_DE.chm"

echo Building English help...
"%HHC%" "PC3_EN.hhp"
if not exist "PC3_EN.chm" (
    echo.
    echo BUILD FAILED: help\PC3_EN.chm was not created.
    popd
    pause
    exit /b 1
)

echo.
echo Building German help...
"%HHC%" "PC3_DE.hhp"
if not exist "PC3_DE.chm" (
    echo.
    echo BUILD FAILED: help\PC3_DE.chm was not created.
    popd
    pause
    exit /b 1
)
popd

set "OUTPUT=%~dp0bin\x64\Release"
if not exist "%OUTPUT%" mkdir "%OUTPUT%"

copy /Y "%~dp0help\PC3_EN.chm" "%OUTPUT%\PC3_EN.chm" >nul
if errorlevel 1 (
    echo.
    echo COPY FAILED: PC3_EN.chm could not be copied to:
    echo %OUTPUT%
    pause
    exit /b 1
)

copy /Y "%~dp0help\PC3_DE.chm" "%OUTPUT%\PC3_DE.chm" >nul
if errorlevel 1 (
    echo.
    echo COPY FAILED: PC3_DE.chm could not be copied to:
    echo %OUTPUT%
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  HELP BUILD SUCCEEDED
echo ============================================================
echo.
echo Created and copied beside the x64 Release executable:
echo   bin\x64\Release\PC3_EN.chm
echo   bin\x64\Release\PC3_DE.chm
echo.
pause
exit /b 0
