# Native Linux port — epic and child-issue backlog

> **Issue tracker is now enabled.** Epic [#3](https://github.com/zonaro/mergeship/issues/3) has linked issue-checklist references to #4–#14. Native GitHub sub-issue hierarchy still needs manual linking; the connected issue tools do not provide a sub-issue mutation.

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
cmake -S host -B build/linux-host -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/linux-host --target mergeship-linux-probe
./build/linux-host/mergeship-linux-probe --help
# After shared engines are built:
./build/linux-host/mergeship-linux-probe ./libsoh.so ./lib2ship.so
```

The probe only tests dynamic loading and the host-defined engine ABI. It **does not** render a window, run the game, validate the actual libultraship runtime ABI independently, or prove that the hosted engines compile on Linux.

## Implementation notes — 2026-11-16

- `AGENTS.md` already existed; its original MergeShip constraints were retained and extended with Linux guidance.
- Added `.agents/ARCHITECTURE.md`, `WORKFLOW.md`, `TESTING.md`, `DEPENDENCIES.md` and directory README.
- Loader diagnostic is compiling and passing CTest on both GCC and Clang in GitHub Actions run [#43818264488](https://github.com/zonaro/mergeship/actions/runs/43818264488).
- Added native Linux XDG config directory helpers and safe settings carry tests in `host/LinuxPaths.*` and `host/linux_paths_test.cpp`. **These functions are not yet connected to the playable host**; pending host platform refactor (#5).
- Initial workflow exists at `.github/workflows/linux-probe.yml`; full game builds and gameplay tests have not been performed.
- Local issue #2 (OoT DX and Dungeon/Boss Rush) was triaged separately in #14 and is not a prerequisite for the Linux port.
