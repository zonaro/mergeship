# Dependency audit (in progress)

| Layer | Current state | Linux work / limitation |
| --- | --- | --- |
| CMake / C++20 / Ninja | native build orchestration added | `tools/build_linux_engines.sh`; full engine CI is still the authoritative compile check |
| SDL2 / OpenGL | used by the shared runtime | Linux host links SDL2; game engines own window, input and audio |
| libultraship | one source tree selected for hosted Linux builds | `Shipwright/libultraship` is used by SoH, 2Ship and host; shared ABI ID checked at runtime |
| SoH | hosted ELF target configured | PIC, `soh.so`, `$ORIGIN` RUNPATH; full build pending CI |
| 2Ship | hosted ELF target configured | PIC, `2ship.so`, `$ORIGIN` RUNPATH; CMake accepts shared LUS source override |
| Engine loader | POSIX `dlopen` implementation exists | headless `--check-engines` validates exports and LUS ABI after staging |
| Anchor networking | BSD socket path already exists | Linux CMake compile target; live Anchor interoperability still needs testing |
| Saves and configuration | POSIX host path implemented | XDG settings carry; atomic shared-save replacement; gameplay/save compatibility unverified |
| Screenshot | Windows GDI implementation retained | Linux currently returns unsupported; needs SDL/renderer capture backend |
| FrameRecorder | Windows pipe/process implementation retained | Linux currently no-ops; needs POSIX FFmpeg process/pipeline |
| Legacy MPQ / StormLib | disabled for initial hosted Linux build | pinned optimization patch fails on StormLib v9.25; restoration tracked in #26 |
| ROM extraction | game-owned extractors exposed through host API | user supplies legal ROMs; generated `.o2r` files remain local |
| Packaging | ROM-free tar.gz staging added | not yet an AppImage; runtime dependency portability needs verification |

This is a source-reading and implementation inventory, **not a claim that the full game build or gameplay has passed**. Keep implemented, compiled, module-checked and gameplay-verified as separate statuses.
