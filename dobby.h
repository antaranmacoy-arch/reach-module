#pragma once
// Dobby hook API — minimal header
// Full header: https://github.com/jmpews/Dobby/blob/master/include/dobby.h

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    DOBBY_GOOD   =  0,
    DOBBY_ERROR  = -1,
} DobbyErrorCode;

// Hook a function at addr, redirect to replace_call,
// save original trampoline into origin_call
int DobbyHook(void* addr, void* replace_call, void** origin_call);

// Destroy a hook and restore original bytes
int DobbyDestroy(void* addr);

// Code patch — write arbitrary bytes at addr
int DobbyCodePatch(void* addr, uint8_t* data, uint32_t data_size);

#ifdef __cplusplus
}
#endif
