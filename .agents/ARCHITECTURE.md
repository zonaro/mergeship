# Architecture and invariants

## Native Linux host (implementation in progress)
- Host executable: `host/main.cpp`; Linux path uses POSIX filesystem/process behavior and SDL2 for the focused window title and Ctrl+F12 state.
- Shared host runtime: `libultraship.so`; host links it directly and both game modules depend on the same SONAME.
- Engine loader: `host/EngineModule.cpp`; uses `dlopen(RTLD_NOW | RTLD_LOCAL)` on ELF.
- Linux module names are `soh.so` and `2ship.so`, loaded from the executable directory.
- The Linux build uses the single source tree `Shipwright/libultraship` for SoH, 2Ship and host. 2Ship's CMake source/include paths are configurable with `MERGESHIP_LUS_SOURCE_DIR`; Linux build script sets it explicitly.
- Shared engine ABI is recomputed from source commit and ABI-affecting CMake options on every configure. The host rejects mismatches.
- `host/linux_probe.cpp` remains a separate asset-free loader test; it is not the playable host.

## Runtime layout
```
stage/
  mergeship
  libultraship.so
  soh.so
  2ship.so
  soh.o2r
  mergeship2.o2r
  2ship.o2r
  assets/                 # public extractor metadata only
  run-mergeship.sh
```
The first launch uses the games' own extraction flow to create local `oot.o2r` and `mm.o2r` from user-supplied ROMs. Those ROMs and derived archives must never enter source control, CI artifacts or releases.

Three separate CMake build trees avoid target-name collisions. The same LUS source tree and ABI-relevant settings must be used in all three. At runtime only the host's `libultraship.so` is staged; module `RUNPATH=$ORIGIN` and host `RPATH=$ORIGIN` make the local runtime discoverable. `RTLD_LOCAL` and ELF `-Bsymbolic` reduce cross-engine symbol interposition.

## Cross-game behavior
- The normal OoT and MM stories must function with randomizer OFF.
- Lost Woods ↔ Clock Tower transitions and shared state are first-class acceptance tests.
- MM transformations in OoT and adult Link in Termina must retain upstream parity.
- Shared-save versioning and per-game original save files must remain compatible; never mutate or discard user saves without backups.

## Platform boundaries
- Keep Win32 APIs inside `_WIN32` branches; preserve Windows and Android behavior.
- Linux configuration carry uses XDG config directories; shared-save commits use a temporary file and atomic rename.
- SDL2 is used for Linux title updates and the manual hotkey. Game engines still own the actual SDL window/event loop.
- Screenshot and frame recording currently have explicit Linux stubs; do not claim those features work until a real capture backend exists.
- Legacy MPQ/`.otr` support is disabled in the first hosted Linux build because the pinned StormLib patch no longer applies. The modern `.o2r` path remains enabled. Optional restoration is tracked in #26.

## Code and licensing
- Respect all existing root AGENTS.md restrictions.
- Never package copyrighted ROM/game archives in public artifacts.
- Avoid copying ComboShip randomizer or engine implementations; reference its build architecture only when licensing permits.
