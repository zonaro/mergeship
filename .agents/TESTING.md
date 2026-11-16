# Linux verification matrix

## Bootstrap (without games or ROMs)
```sh
cmake -S host -B build/linux-host -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
cmake --build build/linux-host --target mergeship-linux-probe
ctest --test-dir build/linux-host --output-on-failure
./build/linux-host/mergeship-linux-probe --help
```
- `--help`: exit 0, prints its diagnostic purpose.
- Missing `.so`: nonzero exit, explanatory `dlopen` error.
- Shared objects with missing `MsEngine_*` exports: nonzero exit.
- Asset-free mock ELF libraries: loading two modules with a matching ABI must succeed; incompatible LUS ABI must fail. These fixtures exercise the loader, **not actual gameplay**.
- Modules with incompatible API and LUS IDs: nonzero exit.
- These tests do **not** prove engine startup or standalone game functionality.

## Engine smoke tests (after both hosted libraries exist)
- Build SoH and 2Ship from their exact bundled revisions, position-independent shared libraries, and one LUS ABI ID.
- Run loader probe with both paths and compare engine IDs and the expected ABI.
- Check dependencies using `ldd` / `readelf -d`; inspect exports via `nm -D`.
- Start with `--only soh` and `--only 2ship`, then boot the shared host with both engines.
- Check keyboard, gamepad, sound, window creation, active menu, resize and quit on X11 and Wayland.

## Gameplay acceptance (local legal ROMs only)
1. Default game story progression with all randomizer features OFF.
2. Save OoT and MM separately, close, restart and confirm contents.
3. Move Hyrule → Termina → Hyrule through the actual game transition, not debug hotkeys alone.
4. Confirm hearts/magic/items/masks/inventory and checksums across transitions.
5. Test Deku/Goron/Zora/Fierce Deity in OoT; young and adult Link in Termina.
6. Run 50 debug switches without crashes, audio overlap or UI texture corruption.
7. Back up existing saves and test config import when switching extract directories.
8. Run optional randomizer/multiplayer tests separately; never make them mandatory.

## CI
Public CI must not download or commit ROMs/game assets. Use `ubuntu-latest`, GCC and Clang for host build and probe tests. Additional runtime tests must not silently use simulated gameplay as functional evidence.
