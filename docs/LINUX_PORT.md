# Native Linux port — epic and child-issue backlog

> **Issue tracker is now enabled.** Epic [#3](https://github.com/zonaro/mergeship/issues/3) has linked issue-checklist references to #4–#14 and optional MPQ follow-up #26. Native GitHub sub-issue hierarchy still needs manual linking; the connected issue tools do not provide a sub-issue mutation.

## EPIC: Native Linux port (ELF, shared engines, original-story parity)

**Goal:** Run OoT and MM as one native Linux MergeShip process with a shared save and native transitions, preserving their *normal campaigns*. Unified randomizer/Anchor remain optional. No ROMs, game data, or derived copyrighted assets in CI/release artifacts.

### Tracked implementation issues (dependency order)

- [ ] **[#4 — LINUX-01 — Audit Linux-hosted build dependencies and establish CMake bootstrap**. Inventory host, Shipwright, 2Ship, libultraship, torch and exporters; isolate Windows flags; document distro packages; compile a standalone loader probe. **Done when:** the Linux CMake project configures and probe compiles with GCC and Clang in CI. **Initial work:** `host/linux_probe.cpp` and an isolated CMake target.
- [ ] **[#5 — LINUX-02 — Portable host OS and filesystem services**. Extract Win32-specific functions from `host/main.cpp` and helpers: local time, executable directory, UTF-8 paths, config persistence, screenshot/file APIs, process/FFmpeg spawning, terminal and socket handling. Use `std::filesystem`, SDL and XDG paths where appropriate; preserve Windows/Android behavior. **Done when:** host sources compile on Linux.
- [ ] **[#6 — LINUX-03 — Build shared libultraship on Linux**. Ensure `LUS_SHARED` and symbol visibility/linkage are correct, and keep exactly one compatible LUS ABI per process, including SDL, ImGui, spdlog and allocator concerns. **Done when:** host and engines report identical LUS ABI IDs.
- [ ] **[#7 — LINUX-04 — Build hosted SoH as libsoh.so**. Adapt SoH's `MERGESHIP_HOSTED` branch for ELF/PIC, exports, `-Bsymbolic` as warranted and Linux dependencies. Preserve standalone build. **Done when:** module loads and exposes `MsEngine_*` exports and launches via the host.
- [ ] **[#8 — LINUX-05 — Build hosted 2Ship as lib2ship.so**. Same as above, including renderer/resource extraction paths and platform-specific dependencies. **Done when:** module loads and launches through the host.
- [ ] **[#9 — LINUX-06 — Single-window, audio, GUI and controller sharing**. Exercise Context activation, GUI swaps, SDL audio and input, shader/resource caches and teardown ordering. **Done when:** at least 50 controlled engine switches without crashes, input loss or context bleed.
- [ ] **[#10 — LINUX-07 — Cross-world transfer, saves and story parity**. Verify Lost Woods ↔ Clock Tower both ways, shared state, native game saves, backwards compatibility, masks/transformation forms and adult Link. Test with randomizer disabled as the default story path. **Done when:** representative normal-story playthrough checkpoints pass with no broken saves.
- [ ] **[#11 — LINUX-08 — Linux scripts, headless CI and diagnostics**. Introduce build orchestration and tests for loaders, ABI IDs and optional runtime smoke tests; do not download ROMs. **Done when:** GCC + Clang jobs are reproducible and diagnose missing dependencies clearly.
- [ ] **[#12 — LINUX-09 — AppImage, docs, and release workflow**. Document building/first-run ROM extraction and distribution, using OS-independent paths; package open-source binaries only, with checksums and clear dependencies. **Done when:** a release-built AppImage starts on supported distros and passes functional smoke tests.

### Upstream issue audit

On 2026-11-16, GitHub issue search for `sonsegajp/mergeship` returned **no public issues**. There are therefore no upstream issue numbers to import at this time. Re-evaluate upstream when issues appear; source comments and `Shipwright/mergeship2/docs/HOST_DESIGN.md` are useful technical references, not public issues.

Review related risk areas during implementation:
- Per-engine resources collide if the game asset managers or contexts are incorrectly combined (2,562 duplicate paths documented).
- Respect libultraship ABI IDs across all three independent builds; never bypass compatibility checks.
- Ensure the Android `dlopen(RTLD_LOCAL)` solution remains intact as the ELF loader is reused.
- Keep settings, save migration and debug tests isolated from production save slots.

### Local Linux probe (first implementation slice)

```sh
cmake -S host -B build/linux-host -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -DMERGESHIP_BUILD_LINUX_HOST=OFF
cmake --build build/linux-host -j 2
ctest --test-dir build/linux-host --output-on-failure

# Full hosted build and ROM-free staging:
bash tools/install_linux_build_deps.sh
JOBS=4 bash tools/build_linux_engines.sh
cd build/linux/stage
./mergeship --check-engines
./run-mergeship.sh
```

The fast probe/CTest job uses mock ELF modules and tests loader behavior only. The full build script configures SoH, 2Ship and host, stages the real modules and then runs the host's headless `--check-engines` against their exported API and shared libultraship ABI. Neither check is a substitute for first-run extraction and actual gameplay.

## Implementation notes — 2026-11-16

- `AGENTS.md` already existed; its original MergeShip constraints were retained and extended with Linux guidance.
- Added `.agents/ARCHITECTURE.md`, `WORKFLOW.md`, `TESTING.md`, `DEPENDENCIES.md` and directory README.
- Loader diagnostic is compiling and passing CTest on both GCC and Clang in GitHub Actions run [#43818264488](https://github.com/zonaro/mergeship/actions/runs/43818264488).
- Added native Linux XDG config directory helpers and safe settings carry tests in `host/LinuxPaths.*` and `host/linux_paths_test.cpp`. **These functions are not yet connected to the playable host**; pending host platform refactor (#5).
- Initial workflow exists at `.github/workflows/linux-probe.yml`; full game builds and gameplay tests have not been performed.
- Local issue #2 (OoT DX and Dungeon/Boss Rush) was triaged separately in #14 and is not a prerequisite for the Linux port.

### Extended loader validation
- Compiled CI-only fake ELF engine modules (`host/linux_fake_engine.cpp`) to exercise successful `dlopen`, symbol resolution and ABI mismatch rejection. These **are not the actual games**.
- GitHub Actions [run 43818971449](https://github.com/zonaro/mergeship/actions/runs/43818971449): GCC and Clang both built successfully; **5/5 CTest cases passed** on each compiler.

## Hosted engine build preparation — 2026-11-16

- Enabled position-independent code for hosted Linux SoH and 2Ship builds, including LUS shared objects.
- Added ELF `-Wl,-Bsymbolic` to both hosted game modules to reduce cross-engine symbol interposition when loaded together. The host loader continues to use `RTLD_LOCAL`.
- Added `tools/build_linux_engines.sh`: separate Ninja/CMake trees, `MERGESHIP_HOSTED=ON`, one shared `Shipwright/libultraship` source selected for SoH, 2Ship and host, and builds of each game plus its project-owned O2R target.
- CI now validates the script syntax and watches the engine CMake files.
- The full build workflow is now configured in `.github/workflows/linux-build.yml`; its first successful engine build and staged `--check-engines` are still pending. Do not claim playable gameplay until the ROM extraction flow and both normal campaigns are tested.

## Host networking compilation coverage — 2026-11-16

- Added a dedicated Linux CMake object target for `host/NetService.cpp`. Its POSIX socket branch already uses BSD sockets, non-blocking connect, `select`, `MSG_NOSIGNAL`, and TCP keepalive; it is now compiled by the Linux CI build rather than being left unverified.
- Added a separate object target for `EngineModule.cpp` to keep the ELF loader independently compile-checked.
- These are compile checks only: Anchor server interoperability and network behavior still need integration tests.
- The Linux host now has POSIX path/config handling, atomic shared-save writes, portable logging/shutdown, SDL title and Ctrl+F12 handling, and a headless `--check-engines` mode. Screenshot and frame recording remain explicit Linux stubs; they are tracked separately in #13.

## Native host integration — 2026-11-16

- Added a real Linux `mergeship` executable target linked to one shared `libultraship.so`, SDL2, Threads and `dl`; the fast probe remains available with `MERGESHIP_BUILD_LINUX_HOST=OFF`.
- Added POSIX XDG config carry, executable-directory discovery, atomic shared-save writes, local-time logging, SDL window title updates, Ctrl+F12 state and normal process shutdown. Windows code remains behind `_WIN32` guards.
- Linux module filenames are `soh.so` and `2ship.so`; the host loads them from its own directory and verifies their exported engine API and LUS ABI before initialization using `--check-engines`.
- 2Ship's CMake now accepts `MERGESHIP_LUS_SOURCE_DIR`; the Linux build script points it at the exact same vendored LUS source used by SoH and host.
- The first hosted Linux build defaults legacy MPQ/`.otr` support OFF because the StormLib v9.25 optimization patch fails to apply. Modern `.o2r` extraction remains enabled. Optional restoration is tracked in [#26](https://github.com/zonaro/mergeship/issues/26).
- Added `tools/install_linux_build_deps.sh`, `docs/LINUX_TESTING.md` and `.github/workflows/linux-build.yml`. The workflow uploads a ROM-free tar.gz only after both engines, host, staging and the headless ABI check pass.
- Current Linux limitations: screenshots and frame recording are not implemented; actual first boot, controller/audio behavior, save compatibility and cross-world gameplay still require a manual CachyOS test.
