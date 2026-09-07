# ReachModule — 100 block reach for Minecraft LeviLauncher

## Build Requirements
- Android NDK r25c+ (`ANDROID_NDK_HOME` set)
- CMake 3.18+
- Dobby prebuilt `.a` for arm64-v8a

## Quick Build

```bash
# 1. Get Dobby prebuilt
#    → https://github.com/jmpews/Dobby/releases
#    → put libdobby.a in dobby_prebuilt/arm64-v8a/

# 2. Build
chmod +x build.sh
./build.sh

# Output: output/libreach_module.so
```

## Set Offsets

Edit `src/hooks/reach.cpp` → `namespace Offsets`:

```cpp
namespace Offsets {
    constexpr uintptr_t GetAttackRange = 0xYOUROFFSET;
    constexpr uintptr_t CanAttack      = 0xYOUROFFSET;
}
```

Find offsets in Ghidra / IDA by searching:
- String: `"attack"`, `"reach"`, `"getAttackRange"`
- Or use the pattern scanner (fallback already in code)

## Install

```
/sdcard/LeviLauncher/modules/reach_module/
    libreach_module.so
    module.json
```

## Files
```
reach_module/
├── src/
│   ├── module.h          ← base addr + pattern scan
│   ├── main.cpp          ← JNI entry + thread init
│   └── hooks/
│       └── reach.cpp     ← all hooks live here
├── include/
│   └── dobby.h           ← Dobby stub header
├── dobby_prebuilt/
│   └── arm64-v8a/
│       └── libdobby.a    ← YOU put this here
├── CMakeLists.txt
├── build.sh
└── module.json
```
