# Native Linux test build

This is the first native hosted Linux build of MergeShip. It builds the original SoH and 2Ship engines as ELF shared objects and loads both into one host process linked to one shared `libultraship.so`.

## Supported test environment

- x86_64 Linux (CI currently builds on Ubuntu 24.04).
- CachyOS / Arch Linux is supported as a source-build target; use the dependency installer below.
- OpenGL/SDL2 desktop session (X11 or Wayland through SDL2).
- Two legally obtained, supported ROM dumps supplied by the user at first launch.

The CI bundle is a plain tar.gz, not an AppImage. It is intended for the first local gameplay test, not general distribution.

## Build on CachyOS / Arch

From the repository root:

```sh
bash tools/install_linux_build_deps.sh
git status --short
JOBS=4 bash tools/build_linux_engines.sh
```

The build creates `build/linux/stage/` and `build/linux/mergeship-linux-x86_64.tar.gz`. The script uses the exact same `Shipwright/libultraship` source tree for SoH, 2Ship and the host; it does not trust the two vendored LUS copies to be ABI-identical.

The initial hosted Linux build disables legacy MPQ / `.otr` support because the vendored StormLib optimization patch no longer applies cleanly to the pinned upstream StormLib tag. This does not disable the modern `.o2r` ROM extraction flow used by this MergeShip build. MPQ support remains available in the existing non-hosted Windows build and is an optional future Linux compatibility task.

## Launch and first-run extraction

```sh
cd build/linux/stage
./mergeship --check-engines
./run-mergeship.sh
```

- `--check-engines` loads both ELF modules and verifies their exports and shared libultraship ABI without opening a game window.
- On the first normal launch, SoH asks for a supported Ocarina of Time ROM. MergeShip then uses the 2Ship extractor to create the Majora's Mask archive and asks for that ROM.
- ROMs and ROM-derived `oot.o2r` / `mm.o2r` files are generated locally and are not included in CI artifacts.
- Keep the generated archives and the `Save/` folder beside the launcher. Back them up before testing.

Useful options:

```sh
./run-mergeship.sh --only soh
./run-mergeship.sh --only 2ship
./run-mergeship.sh --engine 2ship
./run-mergeship.sh --debug-switch
```

The host's Ctrl+F12 manual switch is available only with `--debug-switch`; normal story progression should still use the Lost Woods ↔ Clock Tower door.

## Linux-specific limitations in this first test build

- Screenshot capture (`--shots`) is not implemented yet.
- Frame recording (`--record`) is not implemented yet.
- The first test bundle is a tar.gz, not an AppImage.
- Legacy MPQ / `.otr` archive support is disabled; modern `.o2r` archives are the intended flow.
- The native build and module ABI check are automated. Actual first boot, controller/audio behavior, save compatibility and the cross-world door still require manual gameplay verification on a Linux desktop.

## Data and privacy

The host's carried settings are stored under `$XDG_CONFIG_HOME/mergeship/config` (default: `~/.config/mergeship/config`). Game save data and generated ROM archives remain local to the staged game directory. Never upload ROMs or generated game archives to the repository, CI, or issue tracker.
