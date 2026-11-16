#include "LinuxPaths.h"
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <unistd.h>

namespace fs = std::filesystem;
int main() {
    const auto root = fs::temp_directory_path() / ("mergeship-path-test-" + std::to_string(getpid()));
    const auto local = root / "game";
    const auto xdg = root / "xdg";
    try {
        fs::create_directories(local);
        fs::create_directories(xdg);
        setenv("HOME", root.c_str(), 1);
        setenv("XDG_CONFIG_HOME", xdg.c_str(), 1);
        unsetenv("MERGESHIP_TEST_SCRIPT_SOH");
        unsetenv("MERGESHIP_TEST_SCRIPT_2SHIP");
        if (MergeShipHost::LinuxPaths::ConfigDirectory() != xdg / "mergeship" / "config") return 1;
        if (MergeShipHost::LinuxPaths::ExecutableDirectory().empty()) return 2;
        { std::ofstream(local / "shipofharkinian.json") << "original"; }
        MergeShipHost::LinuxPaths::CarryConfigs(true, local);
        fs::remove(local / "shipofharkinian.json");
        MergeShipHost::LinuxPaths::CarryConfigs(false, local);
        std::string copied;
        { std::ifstream stream(local / "shipofharkinian.json"); stream >> copied; }
        if (copied != "original") return 3;
        { std::ofstream(local / "shipofharkinian.json") << "local"; }
        MergeShipHost::LinuxPaths::CarryConfigs(false, local);
        { std::ifstream stream(local / "shipofharkinian.json"); stream >> copied; }
        if (copied != "local") return 4; // Existing user settings must not be overwritten.
        setenv("MERGESHIP_TEST_SCRIPT_SOH", "1", 1);
        fs::remove(local / "shipofharkinian.json");
        MergeShipHost::LinuxPaths::CarryConfigs(false, local);
        if (fs::exists(local / "shipofharkinian.json")) return 5;
        fs::remove_all(root);
        std::cout << "Linux config directory and safe carry tests passed\n";
        return 0;
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        fs::remove_all(root);
        return 6;
    }
}
