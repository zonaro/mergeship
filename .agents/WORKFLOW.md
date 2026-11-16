# Agent workflow

1. Read `AGENTS.md` and `.agents/` before modifying code.
2. Start from epic #3, read the specific #4–#14 task and #26 (optional MPQ), inspect the actual source and define acceptance evidence.
3. Develop on `feature/linux-native-port`; PR #1 remains draft until a playable build is validated.
4. Preserve Windows and Android paths. Guard Linux-specific code with `CMAKE_SYSTEM_NAME STREQUAL "Linux"` or equivalent.
5. Keep separate CMake build trees for host, Shipwright and 2Ship, but point all hosted Linux builds at the same `Shipwright/libultraship` source through `MERGESHIP_LUS_SOURCE_DIR`. Do not bypass the ABI check.
6. Use `tools/build_linux_engines.sh` for staging; never stage ROMs or generated game archives.
7. Run fast GCC/Clang tests and the full hosted Linux workflow. Record compile failures and exact evidence.
8. Distinguish source changes, compile success, ELF module check, first boot and actual cross-world gameplay. Never mark gameplay complete from compile-only evidence.
9. Keep screenshot/recording support marked unavailable until implemented; keep MPQ disabled by default until #26 passes.
10. Update issue checkboxes and `docs/LINUX_PORT.md` / `docs/LINUX_TESTING.md` with observed results.

## Definition of done
An issue closes only with reproducible commands or manual-test instructions, explicit expected/observed results, and no new regression in supported systems. The first user-testable milestone requires a staged host, both real modules, one shared LUS runtime, a passing `--check-engines`, and clear first-run ROM instructions. DX/Rush (#2 / #14) remains outside the Linux critical path.
