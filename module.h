#pragma once
#include <jni.h>
#include <android/log.h>
#include <string>
#include <cstdint>
#include <cstring>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

#define TAG "ReachModule"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__)

namespace MC {
    inline uintptr_t libBase = 0;

    inline uintptr_t getBase() {
        if (libBase != 0) return libBase;
        FILE* maps = fopen("/proc/self/maps", "r");
        if (!maps) return 0;
        char line[512];
        while (fgets(line, sizeof(line), maps)) {
            if (strstr(line, "libminecraftpe.so") && strstr(line, "r-xp")) {
                libBase = (uintptr_t)strtoul(line, nullptr, 16);
                fclose(maps);
                return libBase;
            }
        }
        fclose(maps);
        return 0;
    }

    inline uintptr_t offset(uintptr_t off) {
        return getBase() + off;
    }
}

inline uintptr_t patternScan(const uint8_t* pattern, const char* mask, size_t len) {
    uintptr_t base = MC::getBase();
    if (!base) return 0;
    constexpr size_t SCAN_SIZE = 0x4000000;
    for (uintptr_t i = base; i < base + SCAN_SIZE - len; i++) {
        bool found = true;
        for (size_t j = 0; j < len; j++) {
            if (mask[j] == 'x' && *(uint8_t*)(i + j) != pattern[j]) {
                found = false;
                break;
            }
        }
        if (found) return i;
    }
    return 0;
}
