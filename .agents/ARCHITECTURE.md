# Architecture and invariants

## Current host
- Desktop host: `host/main.cpp`, `host/FrameRecorder.cpp`, `host/Screenshot.cpp`; currently Win32-dependent.
- Generic loader: `host/EngineModule.cpp`; uses Win32 DLL APIs or `dlopen(RTLD_NOW | RTLD_LOCAL)` on ELF/Android.
- `host/NetService.cpp` already implements a non-Windows BSD sockets path.
- Host exports and contracts live in `include/mergeship/EngineApi.h`; per-engine exported `MsEngine_*` functions are resolved dynamically.
- Host standalone Linux probe: `host/linux_probe.cpp`, **does not start either game**.

## Non-negotiable runtime layout
```
mergeship (host)
  ├── libultraship.so (one shared runtime and ABI)
  ├── libsoh.so (OoT, isolated per-engine context)
  └── lib2ship.so (MM, isolated per-engine context)
```
Three separate build trees avoid CMake target collisions. Resources, factories, CVars and caches must remain isolated per game, while the window, input deck, graphics renderer and audio runtime are shared.

## Cross-game behavior
- The normal OoT and MM stories must function with randomizer OFF.
- Lost Woods ↔ Clock Tower transitions and shared state are first-class acceptance tests.
- MM transformations in OoT and adult Link in Termina must retain upstream parity.
- Shared-save versioning and per-game original save files must remain compatible; never mutate or discard user saves without backups.

## Platform boundaries
- Use conditional platform modules rather than leaking Win32 handles, paths and system functions into common APIs.
- Treat Linux/Wayland and Linux/X11 distinctly for screenshots and window discovery.
- Preserve Windows and Android support.
- Reuse ELF loader code but verify symbol visibility, LUS ABI and the two engines' symbol isolation.
- Prefer C++ standard filesystem and SDL where appropriate, not a new UI framework.

## Code and licensing
- Respect all existing root AGENTS.md restrictions.
- Never package copyrighted ROM/game archives in public artifacts.
- Avoid copying ComboShip randomizer or engine implementations; reference its build architecture only when licensing permits.
