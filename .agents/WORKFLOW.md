# Agent workflow

1. Read `AGENTS.md` and `.agents/` before modifying code.
2. Start from issue #3, read the specific #4–#14 task, inspect the actual source and define the acceptance evidence.
3. Develop on `feature/linux-native-port`; PR #1 remains draft until a playable build is validated.
4. Preserve Windows and Android paths and test them when possible; guard new Linux-specific code with `CMAKE_SYSTEM_NAME STREQUAL "Linux"` or equivalent.
5. Use separate CMake builds for the host, Shipwright and 2Ship, with a shared LUS ABI. Do not weaken ABI checks.
6. Keep work incremental. Avoid unnecessary new deps or replacing the existing engines with those from another combination port.
7. Run tests; document skipped tests and compiler/toolchain limitations precisely. Never mark gameplay complete from compile-only evidence.
8. Update issue checkboxes and `docs/LINUX_PORT.md` with actual evidence, not aspirational progress.
9. Do not add copyrighted game assets, ROMs, O2R files or generated save data to source control.
10. Request validation for normal campaigns, cross-world transitions and user saves before merging.

## Definition of done
An issue closes only with reproducible commands or manual-test instructions, explicit expected/observed results, and no new regression in supported systems. DX/Dungeon Rush/Boss Rush (#2 and #14) is outside the critical-path Linux port.
