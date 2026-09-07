#!/usr/bin/env bash
# ═══════════════════════════════════════════════════
#  ReachModule Build Script
#  Requirements: Android NDK r25c+
#  Run: chmod +x build.sh && ./build.sh
# ═══════════════════════════════════════════════════
set -e

# ── CONFIG ──────────────────────────────────────────
NDK="${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/25.2.9519653}"
ABI="arm64-v8a"
API=26
BUILD_TYPE="${1:-Release}"   # pass Debug as arg if needed
BUILD_DIR="build/${ABI}"
OUTPUT="output/libreach_module.so"

# ── PREFLIGHT ────────────────────────────────────────
if [ ! -d "$NDK" ]; then
    echo "[!] NDK not found at: $NDK"
    echo "    Set ANDROID_NDK_HOME or edit NDK var in this script"
    exit 1
fi

if [ ! -f "dobby_prebuilt/arm64-v8a/libdobby.a" ]; then
    echo "[!] Dobby prebuilt not found at dobby_prebuilt/arm64-v8a/libdobby.a"
    echo ""
    echo "    Get it from:"
    echo "    https://github.com/jmpews/Dobby/releases"
    echo "    OR build from source:"
    echo "      git clone https://github.com/jmpews/Dobby"
    echo "      cd Dobby && mkdir build && cd build"
    echo "      cmake .. -DCMAKE_TOOLCHAIN_FILE=\$NDK/build/cmake/android.toolchain.cmake \\"
    echo "               -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-26 \\"
    echo "               -DCMAKE_BUILD_TYPE=Release"
    echo "      make -j\$(nproc)"
    echo "      cp libdobby.a ../../dobby_prebuilt/arm64-v8a/"
    exit 1
fi

echo "[*] NDK: $NDK"
echo "[*] ABI: $ABI  API: $API  Build: $BUILD_TYPE"

# ── BUILD ────────────────────────────────────────────
mkdir -p "$BUILD_DIR" "$( dirname $OUTPUT )"

cmake -S . -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$API" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    2>&1

cmake --build "$BUILD_DIR" --parallel $(nproc) 2>&1

# ── COPY OUTPUT ─────────────────────────────────────
BUILT="$BUILD_DIR/libreach_module.so"
if [ -f "$BUILT" ]; then
    cp "$BUILT" "$OUTPUT"
    SIZE=$(du -sh "$OUTPUT" | cut -f1)
    echo ""
    echo "✓ Build complete"
    echo "  Output : $OUTPUT  ($SIZE)"
    echo "  SHA256 : $(sha256sum $OUTPUT | cut -d' ' -f1)"
    echo ""
    echo "  Drop into LeviLauncher:"
    echo "  /sdcard/LeviLauncher/modules/reach_module/libreach_module.so"
else
    echo "[!] Build succeeded but .so not found at expected path"
    find "$BUILD_DIR" -name "*.so"
fi
