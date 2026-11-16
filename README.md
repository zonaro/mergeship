# MergeShip

Ocarina of Time and Majora's Mask as one game on PC. The Windows host (`mergeship.exe`) or experimental Linux host (`mergeship`) runs both
[Ship of Harkinian](https://github.com/HarbourMasters/Shipwright) (Hyrule) and
[2 Ship 2 Harkinian](https://github.com/HarbourMasters/2ship2harkinian) (Termina). It switches between them through a
door in the Lost Woods, with one shared save: hearts, magic, rupees, items, masks and quest status.

What it adds on top of the two ports:

- **All four of Majora's Mask's transformations in Ocarina of Time.** The Deku, Goron, Zora and Fierce Deity masks,
  with their own moves, cutscenes, sounds and items.
- **Ocarina of Time's adult Link in Termina.** He brings Hyrule's swords, shields, items and equipment.
- **A unified randomizer** across both worlds, with Anchor multiplayer.
- **Quality-of-life features.** Sprinting, a shared item tracker, and one settings menu that reaches both games.

Every MergeShip feature is optional, from the **Mergeship** menu in either game.

## Screenshots

<table>
<tr>
<td width="50%"><img src="docs/screenshots/deku_kokiri_forest.jpg" alt="Deku Link in Kokiri Forest"><br><b>Deku Link</b> in Kokiri Forest. Majora's Mask's masks work in Ocarina of Time.</td>
<td width="50%"><img src="docs/screenshots/goron_death_mountain.jpg" alt="Goron Link rolling on Death Mountain Trail"><br><b>Goron Link</b> rolling up Death Mountain Trail, past a Tektite.</td>
</tr>
<tr>
<td><img src="docs/screenshots/zora_lake_hylia.jpg" alt="Zora Link swimming in Lake Hylia"><br><b>Zora Link</b> swimming through Lake Hylia.</td>
<td><img src="docs/screenshots/fierce_deity_hyrule_field.jpg" alt="The Fierce Deity in Hyrule Field"><br><b>The Fierce Deity</b> in Hyrule Field.</td>
</tr>
<tr>
<td><img src="docs/screenshots/young_link_clock_town.jpg" alt="Young Link in Clock Town with the Hylian Shield"><br><b>Into Termina</b> through the Lost Woods, with Hyrule's Hylian Shield on his back.</td>
<td><img src="docs/screenshots/adult_link_clock_town.jpg" alt="Adult Link in Clock Town"><br><b>Adult Link in Termina</b>, with the Master Sword and the Hylian Shield.</td>
</tr>
<tr>
<td><img src="docs/screenshots/item_tracker.jpg" alt="The item tracker with both worlds"><br><b>One item tracker</b> for both worlds: Hyrule's items on the left, Termina's on the right.</td>
<td><img src="docs/screenshots/settings_menu.jpg" alt="Termina's settings in Ocarina of Time's menu"><br><b>One settings menu</b>: Termina's settings, opened from Ocarina of Time's menu.</td>
</tr>
<tr>
<td><img src="docs/screenshots/ganondorf_clock_town.jpg" alt="Ganondorf in Clock Town"><br><b>A secret Ganondorf mode</b>, here in Clock Town.</td>
<td></td>
</tr>
</table>

**No game data is included.** You need your own Ocarina of Time and Majora's Mask ROMs. On its first run the game
builds `oot.o2r` and `mm.o2r` from them.

Player builds: https://odysseyapp.fun/mergeship-dist-latest.zip

## Layout

| Folder | What it is |
|---|---|
| `host/` | `mergeship.exe` / `mergeship`: loads both engines (`soh.dll` / `2ship.dll` on Windows; `soh.so` / `2ship.so` on Linux) and coordinates the shared runtime, window, audio, controllers and shared save |
| `include/mergeship/` | Code both engines share: the engine API, the shared save, the settings map, sprinting, the menu mirror and more |
| `Shipwright/` | The Ship of Harkinian fork (its `mergeship2` branch), with its `libultraship` and `torch` |
| `2ship2harkinian/` | The 2 Ship 2 Harkinian fork (its `mergeship2` branch), with its `libultraship`, `ZAPDTR` and `OTRExporter` |
| `tools/` | Build, test and asset scripts (`build_host.ps1`, `run_final.sh`, the settings-map checker, and more) |
| `assets/` | MergeShip's own assets |
| `android/` | The Android build |
| `docs/` | Architecture, status and design notes |

The submodules are included as plain folders, MergeShip's changes and all. Both engines are built against the same
libultraship.

## Building (Windows)

You need Visual Studio 2022 with C++, CMake and Python 3. The build sets up its own vcpkg.

```powershell
powershell -ExecutionPolicy Bypass -File tools\build_host.ps1          # configure + build everything, then stage
powershell -ExecutionPolicy Bypass -File tools\build_host.ps1 -Fast    # after a code change
```

The game is staged into `build\latest`. Run `mergeship.exe` from there and point it at your ROMs on its first run.

Keep line endings as they are (`git config core.autocrlf false`): libultraship's dependency patches need LF.

## Building (experimental Linux port)

The native Linux port is under active development. The current test path builds both hosted engines and the host as ELF shared objects, then stages a ROM-free tar.gz. It is not yet a supported release or an AppImage.

On CachyOS / Arch Linux:

```sh
bash tools/install_linux_build_deps.sh
JOBS=4 bash tools/build_linux_engines.sh
cd build/linux/stage
./mergeship --check-engines
./run-mergeship.sh
```

The first run uses the games' own extractors and asks for your legally obtained OoT and MM ROMs. ROMs and generated `.o2r` archives stay local and are never included in CI artifacts. The initial Linux build disables legacy MPQ/`.otr` support; modern `.o2r` extraction remains enabled. Screenshot and frame recording are not yet available.

See [docs/LINUX_TESTING.md](docs/LINUX_TESTING.md) for dependencies, first-run details and current limitations.

## Credits and licenses

MergeShip contributors:

- [Vio (@AgitationSkeleton)](https://github.com/AgitationSkeleton): the transformation forms and Fierce Deity features
  from soh_fd, including the Fierce Deity's sword beam, and most of the bug reports and testing.

Ship of Harkinian and 2 Ship 2 Harkinian are by [HarbourMasters](https://github.com/HarbourMasters) and their
contributors. Each port, and each library under them, keeps its own license file in its folder. MergeShip is built on
their work.
