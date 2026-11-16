#!/usr/bin/env bash
# Install the native build dependencies for MergeShip on CachyOS/Arch or Ubuntu/Debian.
set -Eeuo pipefail

if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed \
        base-devel git cmake ninja python pkgconf curl \
        sdl2 sdl2_net glew glfw libzip libogg libvorbis opus opusfile \
        libpng nlohmann-json tinyxml2 spdlog fmt zlib bzip2 libusb \
        libx11 libxrandr libxinerama libxcursor libxi libxss libxkbcommon \
        wayland mesa libglvnd libdrm alsa-lib libpulse freetype2 harfbuzz fontconfig
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y \
        build-essential git cmake ninja-build python3 pkg-config curl \
        libsdl2-dev libsdl2-net-dev libglew-dev libglfw3-dev libzip-dev \
        libusb-dev libogg-dev libvorbis-dev libopus-dev libopusfile-dev opus-tools libpng-dev zipcmp zipmerge ziptool \
        nlohmann-json3-dev libtinyxml2-dev libspdlog-dev libfmt-dev \
        zlib1g-dev libbz2-dev libusb-1.0-0-dev \
        libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libxss-dev \
        libxkbcommon-dev libwayland-dev libgl1-mesa-dev libglu1-mesa-dev \
        libdrm-dev libasound2-dev libpulse-dev libfreetype-dev libharfbuzz-dev libfontconfig1-dev
else
    echo "Unsupported package manager. Install CMake >= 3.26, Ninja, SDL2, OpenGL, GLEW, GLFW, libzip, Ogg/Vorbis/Opus/OpusFile, spdlog, fmt, tinyxml2, nlohmann-json, libpng, zlib and bzip2 manually." >&2
    exit 1
fi
