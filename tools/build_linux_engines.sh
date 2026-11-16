#!/usr/bin/env bash
# Build both hosted engines, the native Linux host, and stage a testable directory.
# No ROMs or ROM-derived archives are included. The first run extracts game assets locally.
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${BUILD_DIR:-$ROOT/build/linux}"
STAGE="${STAGE_DIR:-$BUILD/stage}"
JOBS="${JOBS:-4}"
GENERATOR="${CMAKE_GENERATOR:-Ninja}"
CONFIG="${CMAKE_BUILD_TYPE:-Release}"

die() { echo "ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }
need cmake
need git
need pkg-config
if [[ "$GENERATOR" == "Ninja" ]]; then need ninja; fi

for dir in "$ROOT/Shipwright" "$ROOT/2ship2harkinian"; do
    [[ -f "$dir/CMakeLists.txt" ]] || die "missing engine checkout: $dir"
    [[ -e "$dir/libultraship/.git" ]] || die "libultraship submodule missing in $dir; run git submodule update --init --recursive"
done

SOH_LUS="$(git -C "$ROOT/Shipwright/libultraship" rev-parse HEAD)"
MM_LUS="$(git -C "$ROOT/2ship2harkinian/libultraship" rev-parse HEAD)"
[[ "$SOH_LUS" == "$MM_LUS" ]] || die "libultraship revisions differ: SoH=$SOH_LUS 2Ship=$MM_LUS"
echo "Shared libultraship source: $SOH_LUS"

# Native dependencies are provided by the distro. The CI workflow installs the Ubuntu equivalents.
for package in sdl2 glew glfw3 libzip libogg vorbis opus opusfile; do
    pkg-config --exists "$package" 2>/dev/null || echo "NOTE: pkg-config could not find '$package'; CMake will perform the authoritative dependency check."
done

configure() {
    local name="$1" source="$2"
    shift 2
    cmake -S "$ROOT/$source" -B "$BUILD/$name" -G "$GENERATOR" \
        -DCMAKE_BUILD_TYPE="$CONFIG" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        "$@"
}
build() {
    local name="$1"; shift
    cmake --build "$BUILD/$name" --parallel "$JOBS" --target "$@"
}
find_one() {
    local root="$1" pattern="$2" result
    result="$(find "$root" -type f -name "$pattern" -print -quit 2>/dev/null || true)"
    [[ -n "$result" ]] || die "could not find $pattern under $root"
    printf '%s\n' "$result"
}

mkdir -p "$BUILD"
configure soh Shipwright -DMERGESHIP_HOSTED=ON -DSUPPRESS_WARNINGS=ON
build soh soh GenerateSohOtr

configure 2ship 2ship2harkinian -DMERGESHIP_HOSTED=ON
build 2ship 2ship Generate2ShipOtr

configure host host -DMERGESHIP_BUILD_LINUX_HOST=ON
build host mergeship

SOH_MODULE="$(find_one "$BUILD/soh" soh.so)"
MM_MODULE="$(find_one "$BUILD/2ship" 2ship.so)"
HOST_BIN="$(find_one "$BUILD/host" mergeship)"
LUS_LIB="$(find_one "$BUILD/host" libultraship.so)"
SOH_OTR="$(find_one "$BUILD/soh" soh.o2r)"
MERGESHIP_OTR="$(find_one "$BUILD/soh" mergeship2.o2r)"
MM_OTR="$(find_one "$BUILD/2ship" 2ship.o2r)"
SOH_OUT="$(dirname "$SOH_MODULE")"
MM_OUT="$(dirname "$MM_MODULE")"

rm -rf "$STAGE"
mkdir -p "$STAGE/assets"
cp "$HOST_BIN" "$LUS_LIB" "$SOH_MODULE" "$MM_MODULE" "$SOH_OTR" "$MERGESHIP_OTR" "$MM_OTR" "$STAGE/"

# The games ship their own extractor metadata beside the executable. Merge the two trees as the
# established Windows staging script does; ROM-derived oot.o2r/mm.o2r are intentionally not copied.
for assets in "$SOH_OUT/assets" "$MM_OUT/assets"; do
    [[ -d "$assets" ]] || die "missing first-run extractor assets: $assets"
    cp -a "$assets/." "$STAGE/assets/"
done
for required in config.yml xml filelists Config_N64_US.xml Config_GC_US.xml; do
    [[ -e "$STAGE/assets/$required" ]] || die "staged extractor files incomplete: assets/$required missing"
done

for controller_db in "$BUILD/soh/gamecontrollerdb.txt" "$BUILD/2ship/gamecontrollerdb.txt"; do
    if [[ -f "$controller_db" ]]; then cp -f "$controller_db" "$STAGE/gamecontrollerdb.txt"; break; fi
done

cat > "$STAGE/run-mergeship.sh" <<'LAUNCHER'
#!/usr/bin/env bash
set -Eeuo pipefail
cd -- "$(dirname -- "$(readlink -f -- "$0")")"
ulimit -s 16384 2>/dev/null || true
exec ./mergeship "$@"
LAUNCHER
chmod +x "$STAGE/run-mergeship.sh"

cat > "$STAGE/README-LINUX.txt" <<'README'
MergeShip — native Linux test build

1. Run ./run-mergeship.sh
2. On first launch, follow the game's own extraction prompts and select your legally obtained,
   supported Ocarina of Time and Majora's Mask ROM files. The resulting oot.o2r/mm.o2r archives
   are generated locally; they are not part of this package.
3. Keep the extracted archives and Save/ folder beside this launcher. Back them up before testing.

Useful options:
  ./run-mergeship.sh --check-engines   Check both ELF modules and the shared libultraship ABI.
  ./run-mergeship.sh --only soh        Start only Ocarina of Time.
  ./run-mergeship.sh --only 2ship      Start only Majora's Mask.
  ./run-mergeship.sh --engine 2ship    Start in Termina.
  ./run-mergeship.sh --debug-switch   Enable Ctrl+F12 manual switching.

This is a native test build, not yet an AppImage. Screenshot and frame recording diagnostics are
not available in this initial Linux host. Do not copy ROMs or ROM-derived archives into this folder
for redistribution.
README

# Verify ELF dependencies and exported engine ABI before declaring the staged build usable.
(
    cd "$STAGE"
    ./mergeship --check-engines
)
tar -C "$STAGE" -czf "$BUILD/mergeship-linux-x86_64.tar.gz" .
echo
echo "Linux test build staged at: $STAGE"
echo "Archive: $BUILD/mergeship-linux-x86_64.tar.gz"
echo "Run: $STAGE/run-mergeship.sh"
