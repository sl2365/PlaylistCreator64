#pragma once

// The x64 build targets supported 64-bit Windows releases. Windows 10 is the
// minimum API contract used by the modern Visual Studio project.
#ifndef WINVER
#define WINVER 0x0A00
#endif

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0A00
#endif

#ifndef _WIN32_IE
#define _WIN32_IE 0x0A00
#endif

#include <SDKDDKVer.h>
