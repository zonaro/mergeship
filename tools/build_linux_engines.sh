#!/usr/bin/env bash
# Configure and build the two hosted Linux game modules in isolated CMake trees.
# This does NOT build the desktop host or package ROM-derived archives.
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${BUILD_DIR:-$ROOT/build/linux}"
JOBS="${JOBS:-2}"
GENERATOR="${CMAKE_GENERATOR:-Ninja}"
CONFIG="${CMAKE_BUILD_TYPE:-Release}"

command -v cmake >/dev/null || { echo "cmake is required" >&2; exit 1; }
command -v ninja >/dev/null && [[ "$GENERATOR" == "Ninja" ]] || {
    [[ "$GENERATOR" != "Ninja" ]] || { echo "ninja is required (or set CMAKE_GENERATOR)" >&2; exit 1; }
}
for dir in "$ROOT/Shipwright" "$ROOT/2ship2harkinian"; do
    [[ -f "$dir/CMakeLists.txt" ]] || { echo "Missing engine checkout: $dir" >&2; exit 1; }
    [[ -d "$dir/libultraship/.git" || -f "$dir/libultraship/.git" ]] || {
        echo "libultraship submodule missing in $dir; initialize recursive submodules first" >&2; exit 1;
    }
done

SOH_LUS="$(git -C "$ROOT/Shipwright/libultraship" rev-parse HEAD)"
MM_LUS="$(git -C "$ROOT/2ship2harkinian/libultraship" rev-parse HEAD)"
if [[ "$SOH_LUS" != "$MM_LUS" ]]; then
    echo "libultraship source mismatch; both hosted engines must use one exact revision:" >&2
    echo "  Shipwright: $SOH_LUS" >&2
    echo "  2Ship:      $MM_LUS" >&2
    exit 2
fi
echo "Shared libultraship source: $SOH_LUS"

configure() {
    local name="$1" source="$2"
    shift 2
    cmake -S "$ROOT/$source" -B "$BUILD/$name" -G "$GENERATOR" \
        -DCMAKE_BUILD_TYPE="$CONFIG" \
        -DMERGESHIP_HOSTED=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        "$@"
}
build() {
    local name="$1"; shift
    cmake --build "$BUILD/$name" --parallel "$JOBS" --target "$@"
}

configure soh Shipwright
build soh soh GenerateSohOtr

configure 2ship 2ship2harkinian
build 2ship 2ship Generate2ShipOtr

echo
echo "Hosted engine builds completed. These are shared modules, not a runnable MergeShip desktop host."
echo "SoH build:  $BUILD/soh"
echo "2Ship build: $BUILD/2ship"
echo "Next: compare LUS ABI IDs, build one shared LUS runtime and integrate the native host."
