# Linux verification matrix

## Fast host/loader CI (no games or ROMs)
```sh
cmake -S host -B build/linux-host -G Ninja -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON -DMERGESHIP_BUILD_LINUX_HOST=OFF
cmake --build build/linux-host -j 2
ctest --test-dir build/linux-host --output-on-failure
```
- GCC and Clang CI has passed 5/5 asset-free tests for ELF loader fixtures and XDG configuration behavior.
- Fake ELF libraries exercise `dlopen`, symbol resolution and positive/negative ABI validation; they are not the game engines.

## Full native build and module check
```sh
bash tools/install_linux_build_deps.sh
JOBS=4 bash tools/build_linux_engines.sh
cd build/linux/stage
./mergeship --check-engines
```
The script configures three isolated CMake trees and selects the same `Shipwright/libultraship` source for all. It stages the host, both modules, the shared runtime, public extractor assets and non-ROM O2R source archives. It then runs `--check-engines` before packaging.

The module check must report both engines loaded and the shared LUS ABI matched. It does **not** initialize SDL, open a game window, or prove gameplay.

## Gameplay acceptance (local legal ROMs only)
1. Launch `./run-mergeship.sh` and complete the OoT and MM first-run extraction prompts.
2. Confirm both games reach their normal title/menu and can start a new game with randomizer OFF.
3. Save OoT and MM separately, close, restart and confirm contents.
4. Move Hyrule → Termina → Hyrule through the actual Lost Woods ↔ Clock Tower door.
5. Confirm hearts/magic/items/masks/inventory and checksums across transitions.
6. Test Deku/Goron/Zora/Fierce Deity in OoT; young and adult Link in Termina.
7. Run 50 debug switches with `--debug-switch`; check audio, input, GUI and context isolation.
8. Back up existing saves before migration or compatibility testing.

## CI and licensing
Public CI must not download, commit or package ROMs or ROM-derived `.o2r` archives. It may build the extractor tools and public metadata. No gameplay test may silently substitute a fake engine for a real one.
