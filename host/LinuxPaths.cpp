#include "LinuxPaths.h"

#if !defined(__linux__) || defined(__ANDROID__)
#error "LinuxPaths is intended for native desktop Linux only"
#endif

#include <array>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <system_error>
#include <unistd.h>

namespace MergeShipHost::LinuxPaths {
namespace fs = std::filesystem;

namespace {
fs::path Home() {
    const char* value = std::getenv("HOME");
    if (value == nullptr || value[0] != '/') {
        throw std::runtime_error("HOME is required to resolve Linux settings directories");
    }
    return fs::path(value);
}

fs::path XdgDirectory(const char* variable, const char* fallback) {
    const char* value = std::getenv(variable);
    const fs::path root = (value != nullptr && value[0] == '/') ? fs::path(value) : Home() / fallback;
    return root / "mergeship";
}
} // namespace

fs::path ExecutableDirectory() {
    // std::filesystem::current_path() is not necessarily the game directory.
    std::array<char, 4096> buffer{};
    const ssize_t len = readlink("/proc/self/exe", buffer.data(), buffer.size() - 1);
    if (len <= 0 || static_cast<size_t>(len) >= buffer.size() - 1) {
        throw std::runtime_error("Could not determine executable directory using /proc/self/exe");
    }
    buffer[static_cast<size_t>(len)] = '\0';
    return fs::path(buffer.data()).parent_path();
}

fs::path ConfigDirectory() { return XdgDirectory("XDG_CONFIG_HOME", ".config") / "config"; }
fs::path DataDirectory() { return XdgDirectory("XDG_DATA_HOME", ".local/share"); }

void CarryConfigs(bool exiting, const fs::path& workingDirectory) {
    if (std::getenv("MERGESHIP_TEST_SCRIPT_SOH") != nullptr ||
        std::getenv("MERGESHIP_TEST_SCRIPT_2SHIP") != nullptr) {
        return;
    }
    const fs::path persistent = ConfigDirectory();
    std::error_code ec;
    fs::create_directories(persistent, ec);
    if (ec) throw fs::filesystem_error("Cannot create persistent config directory", persistent, ec);
    for (const char* name : {"shipofharkinian.json", "2ship2harkinian.json", "imgui.ini"}) {
        const fs::path local = workingDirectory / name;
        const fs::path saved = persistent / name;
        if (exiting) {
            if (fs::is_regular_file(local, ec)) {
                ec.clear();
                fs::copy_file(local, saved, fs::copy_options::overwrite_existing, ec);
                if (ec) throw fs::filesystem_error("Cannot back up config", local, saved, ec);
            }
        } else {
            ec.clear();
            if (!fs::exists(local, ec) && fs::is_regular_file(saved, ec)) {
                ec.clear();
                fs::copy_file(saved, local, fs::copy_options::none, ec);
                if (ec && ec != std::errc::file_exists)
                    throw fs::filesystem_error("Cannot restore config", saved, local, ec);
            }
        }
    }
}
} // namespace MergeShipHost::LinuxPaths
