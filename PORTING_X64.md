# Playlist Creator x64 port

## Build entry point

`PlaylistCreator3.sln` is an x64-only Visual Studio/MSBuild solution. It contains the application plus native x64 static-library projects for CxImage, libpng and zlib.

The cleaned x64 source package is deliberately separate from the original Visual Studio 2008/x86 build. Legacy x86 project files, precompiled libraries, DLLs and build/deployment scripts are not included here.

## Prerequisites

Install Visual Studio Community 2026 with:

- Desktop development with C++
- MSVC Build Tools for x64/x86 (Latest)
- C++ MFC for x64/x86 (Latest MSVC)
- A current Windows 11 SDK

The projects explicitly target Visual Studio 2026 Platform Toolset `v145`.

CMake, ARM/ARM64 tools, Spectre-mitigated libraries and older Visual Studio 2019/2022 compiler toolsets are not required by the current project configuration.

The recommended build entry point is `build_x64.bat`. It:

1. checks MSBuild, the x64 MSVC compiler, MFC and the Windows SDK;
2. downloads MediaInfo x64 v26.05 if required;
3. validates the MediaInfo DLL as AMD64 (`0x8664`);
4. rebuilds the solution as `Release | x64`;
5. writes the complete build output to `build_x64.log`.

You can also open `PlaylistCreator3.sln` in Visual Studio Community 2026 and build `Release | x64`.

## Main porting changes

- Added x64-only MSBuild projects targeting Visual Studio 2026 / MSVC `v145`.
- Rebuilt CxImage, libpng and zlib from bundled source instead of linking the old x86 `.lib` files.
- Replaced pointer-truncating Win32 window/class data calls with pointer-width-safe APIs such as `SetWindowLongPtr`, `SetClassLongPtr` and `GetClassLongPtr`.
- Corrected custom window procedure and MFC handler signatures for current 64-bit MFC.
- Widened owner-drawn menu identifiers and popup-menu handles to pointer-width-safe types.
- Updated timer handler IDs from `UINT` to `UINT_PTR`.
- Updated custom message handlers to `LRESULT (WPARAM, LPARAM)`.
- Updated `CFileDialog::DoModal()` compatibility to use `INT_PTR`.
- Updated obsolete Windows theme-header usage for the current Windows SDK.
- Removed the duplicate legacy `CHANGEFILTERSTRUCT` definition and use the Windows SDK definition.
- Updated `SendMessageTimeout` result storage to `DWORD_PTR`.
- Added automatic download and architecture validation for the x64 MediaInfo runtime.
- Enabled the modern x64 project security/linker settings already present in the port, including ASLR, high-entropy VA and DEP.

## x64 source cleanup

The modern package no longer carries build-time x86 artifacts that are unrelated to the x64 build. Removed items include:

- `PlaylistCreator3-VS2008.sln`;
- the Visual Studio 2008 `.vcproj` application project;
- the old VS2008 build/deployment batch directory;
- precompiled x86 `MediaInfo.dll` and `cximage.dll` files;
- precompiled x86 `cximage.lib`, `png.lib` and `zlib.lib` files;
- the bundled legacy MediaInfo i386 archive/runtime;
- CxImage VC6 `.dsp`, `.dsw`, `.mak` and `.clw` project files;
- CxImage DLL/demo project trees that are not used by Playlist Creator x64;
- the old VS2008 setup screenshots and legacy installer build tree.

Architecture-independent application source, resources, help source and bundled library source are retained.

Important: the `WIN32` macro is not proof that a file is 32-bit-only. Microsoft headers and older cross-version Windows code commonly use `WIN32` for both 32-bit and 64-bit Windows builds. Do not remove those definitions merely as part of x64 cleanup.

## Dependencies

### MediaInfo

A 64-bit process must load a 64-bit MediaInfo DLL. The x64 build uses only:

```text
dll\x64\MediaInfo.dll
```

If that file is absent, `tools\Get-MediaInfoX64.ps1` downloads and validates it automatically.

### CxImage, libpng and zlib

These are built from source into:

```text
lib\x64\Release\
```

They are static build products, not runtime DLL dependencies. The generated `lib\x64` directory is intentionally excluded from source control/package input and is recreated by MSBuild.

## Release output

A successful Release build writes:

```text
bin\x64\Release\pc3.exe
bin\x64\Release\MediaInfo.dll
```

Compiled `.chm` files already present in `help` are also copied to that directory.

The standard build is therefore usable as a portable application folder; no installer is required to run it.

## Help build

The help source is architecture-independent and retained. `build_x64.bat` does not compile `.chm` files. Rebuilding them requires Microsoft HTML Help Workshop separately; this is optional and is not an application-build requirement.

## Validation status

The Release x64 build has compiled and linked successfully with Visual Studio Community 2026 / MSVC 14.51 / MFC / Windows 11 SDK 10.0.26100.x.

Runtime smoke testing confirms that the application starts. Functional regression testing should still cover at least:

- adding files and folders;
- reading MediaInfo duration/tags;
- opening existing M3U/PLS playlists;
- creating M3U/PLS playlists;
- drag and drop;
- settings dialogs and persistence;
- large playlists;
- shutdown/restart and single-instance behavior.

The compiler still reports several warnings inherited from the old CxImage/Oddgravity codebase, including pointer-truncation warnings. These should be reviewed before declaring the x64 port fully complete, even though the current Release build succeeds.

## Build diagnostics

`build_x64.bat` keeps the console window open and writes the complete output to `build_x64.log`.

The solution explicitly targets `PlatformToolset v145`. A Visual Studio installation that does not provide that toolset must either install the matching Visual Studio 2026 C++ components or deliberately retarget the projects.
