# Dependency audit (in progress)

| Layer | Actual status | Linux work |
| --- | --- | --- |
| CMake / C++20 / Ninja | host desktop CMake uses MSVC flags | isolated Linux probe configured; full host pending |
| Dynamic loader | EngineModule has POSIX `dlopen` branch | verify ELF exports, RTLD_LOCAL symbol isolation and ABI |
| libultraship | desktop build currently configured for Windows; Android shares .so | adapt native Linux shared build and dependency versions |
| Shipwright (SoH) | hosted Windows/Android branches | Linux PIC/shared build, exports and links |
| 2ship2harkinian | hosted Windows/Android branches | Linux PIC/shared build, exports and links |
| SDL / graphics / audio / ImGui | shared service requirement | inspect ownership, backend support and symbol collisions |
| NetService | POSIX sockets implementation exists | compile/test on Linux and check MSG_NOSIGNAL |
| Screenshot | Win32 GDI | SDL/renderer capture, X11/Wayland policy |
| FrameRecorder | Win32 handles/pipes | POSIX subprocess or portable encoder pipe |
| Saves and configuration | Windows APPDATA paths in host | XDG_CONFIG_HOME / XDG_DATA_HOME with safe migration |
| ROM extraction and assets | copyright-restricted inputs | user-local generation, no assets in CI |
| Packaging | Windows-only host staging | Linux AppImage and manifests after playable build |

This is a source-reading inventory, **not** a passing compilation report. Do not infer distribution compatibility from Android ELF support alone.
