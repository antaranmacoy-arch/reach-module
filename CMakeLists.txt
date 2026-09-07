cmake_minimum_required(VERSION 3.18)
project(reach_module CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ── Dobby: auto-detect prebuilt vs submodule ─────────────
set(DOBBY_PREBUILT "${CMAKE_SOURCE_DIR}/dobby_prebuilt/${ANDROID_ABI}/libdobby.a")
set(DOBBY_SRC_DIR  "${CMAKE_SOURCE_DIR}/dobby_src")

if(EXISTS "${DOBBY_PREBUILT}")
    message(STATUS "[+] Using prebuilt Dobby: ${DOBBY_PREBUILT}")
    add_library(dobby_static STATIC IMPORTED)
    set_target_properties(dobby_static PROPERTIES
        IMPORTED_LOCATION "${DOBBY_PREBUILT}"
    )
    set(DOBBY_LIB dobby_static)
elseif(EXISTS "${DOBBY_SRC_DIR}/CMakeLists.txt")
    message(STATUS "[+] Building Dobby from source")
    add_subdirectory(${DOBBY_SRC_DIR} dobby_build)
    set(DOBBY_LIB dobby_static)
else()
    message(FATAL_ERROR "[-] Dobby not found. Put libdobby.a in dobby_prebuilt/${ANDROID_ABI}/ OR clone Dobby into dobby_src/")
endif()

# ── Module ───────────────────────────────────────────────
add_library(reach_module SHARED
    src/main.cpp
)

target_include_directories(reach_module PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    src/
)

target_link_libraries(reach_module PRIVATE
    ${DOBBY_LIB}
    android
    log
)

target_compile_options(reach_module PRIVATE
    -O2
    -fvisibility=hidden
    -fno-exceptions
    -fno-rtti
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_link_options(reach_module PRIVATE -Wl,--strip-all)
endif()
