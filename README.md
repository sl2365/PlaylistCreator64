# Playlist Creator

[![Release](https://img.shields.io/github/v/release/sl2365/PlaylistCreator64?style=for-the-badge-square&color=yellow)](https://github.com/sl2365/PlaylistCreator64/releases/latest/download/PlaylistCreator64.rar)
[![Release Date](https://img.shields.io/github/release-date/sl2365/PlaylistCreator64?style=for-the-badge-square&color=yellow)](https://github.com/sl2365/PlaylistCreator64/releases)

[![Latest Asset Downloads](https://img.shields.io/github/downloads/sl2365/PlaylistCreator64/latest/PlaylistCreator64.rar?style=for-the-badge-square&label=downloads-latest&displayAssetName=false&color=blue)](https://github.com/sl2365/PlaylistCreator64/releases/latest)
[![Total Downloads](https://img.shields.io/github/downloads/sl2365/PlaylistCreator64/total?style=for-the-badge-square&label=downloads-total&color=blue)](https://github.com/sl2365/PlaylistCreator64/releases)

Playlist Creator is the classical one-trick pony: Creates playlists - no more, no less.
Originally developed by oddgravity, now released to the general public.

The application is written in native C++ using MFC (Microsoft Foundation Classes). The original source was developed with Visual Studio 2008. This package is the cleaned **native x64** source tree and no longer contains the legacy x86 build system or precompiled x86 libraries/DLLs.

If the original 32-bit build is required, keep it as a separate legacy source tree. Do not mix its binaries or project files into this x64 package.

This version is an updated 64bit version created using ChatGPT 5.6 Sol. It works in the exact same way as the original. This is simply an exercise in preservation for what are essentially, genuinely useful programs that were proof that you don't need to create exe's that are 100's MB's in size to perform simple tasks.

- Original author: `Michael Schulze`
- Original project: [mschulze46/PlaylistCreator](https://github.com/mschulze46/PlaylistCreator)

## Current x64 build

`PlaylistCreator3.sln` is the x64-only Visual Studio solution. The current projects target the Visual Studio 2026 C++ platform toolset (`v145`).

The x64 build has been validated with:

- Visual Studio Community 2026
- MSVC 14.51
- C++ MFC for x64
- Windows 11 SDK 10.0.26100.x

See [PORTING_X64.md](PORTING_X64.md) for the porting notes and [VISUAL_STUDIO_SETUP.txt](VISUAL_STUDIO_SETUP.txt) for the Visual Studio Installer checklist.

## x64 build requirements

Install **Visual Studio Community 2026** and select the **Desktop development with C++** workload. In Visual Studio Installer, make sure these components are selected:

- MSVC Build Tools for x64/x86 (Latest)
- C++ MFC for x64/x86 (Latest MSVC)
- Windows 11 SDK (latest available)

The normal application build does **not** require:

- Visual Studio 2008
- Visual Studio 2019/2022 toolsets
- CMake
- ARM/ARM64 tools
- Spectre-mitigated libraries
- NSIS
- HTML Help Workshop

## Building x64

You do not need to use the Visual Studio editor.

1. Open the root `PlaylistCreator-x64` folder.
2. Double-click `build_x64.bat`.
3. Wait for `BUILD SUCCEEDED`.
4. The full build output is also written to `build_x64.log`.

The build script checks the installed compiler, MFC and Windows SDK. If `dll\x64\MediaInfo.dll` is missing, it downloads MediaInfo x64 v26.05 and verifies that the DLL is an AMD64 PE file before using it.

CxImage, libpng and zlib are rebuilt from the bundled source as native x64 static libraries. No precompiled x86 `.lib` or CxImage DLL is used.

## Release output

A successful Release build writes the runnable files to:

```text
bin\x64\Release\
    pc3.exe
    MediaInfo.dll
```

If compiled `.chm` help files are present in the `help` folder, they are copied to the same output directory.

`pc3.exe` and `MediaInfo.dll` are the required runtime files. CxImage, libpng, zlib, MFC and the C/C++ runtime are linked statically for this build.

## Help files

The help project source (`.hhp`, `.hhc` and HTML content) is retained because it is architecture-independent. The standard x64 build does not compile the help project.

If compiled `PC3_DE.chm` and `PC3_EN.chm` files are present in the `help` folder, `build_x64.bat` copies them into the Release output. Older compiled help files may still contain obsolete website links, so rebuild them from the updated help source before distribution.

Rebuilding the `.chm` files themselves requires Microsoft HTML Help Workshop separately; it is not required to compile Playlist Creator.

To rebuild the supplied English and German help files after editing the HTML help source:

1. Install Microsoft HTML Help Workshop so `hhc.exe` is available.
2. Double-click `build_help.bat` in the project root.
3. Confirm `help\PC3_EN.chm` and `help\PC3_DE.chm` were created.
4. Run `build_x64.bat`; any `.chm` files in `help` are copied beside `pc3.exe`.

## Source layout

The x64 package intentionally excludes the legacy 32-bit build files and binaries. In particular, it does not contain the old VS2008 solution/project, the old x86 MediaInfo/CxImage DLLs, the old precompiled x86 CxImage/libpng/zlib libraries, or the old VS2008/VC6 build batch/project files.

Do not remove `WIN32` preprocessor definitions simply because this is a 64-bit build. Microsoft C/C++ code commonly uses `WIN32` as the Windows-platform macro on both x86 and x64; x64-specific code is identified by `_WIN64`/`WIN64` where needed.

## Installer

The legacy installer build system has been removed from this cleaned x64 source package. The Release output is portable and can be run directly from its folder.

If an installer is required, it should be maintained as a separate modern x64 packaging step rather than reintroducing the old VS2008-era deployment scripts.

## License

Playlist Creator is MIT-licensed.
