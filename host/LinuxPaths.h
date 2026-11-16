#pragma once
#include <filesystem>

namespace MergeShipHost::LinuxPaths {
// Native Linux helpers used by the pending portable desktop host.
// Throws std::runtime_error when a reliable home directory cannot be determined.
std::filesystem::path ExecutableDirectory();
std::filesystem::path ConfigDirectory();
std::filesystem::path DataDirectory();
// Mirrors the existing Windows CarryConfigs behavior without copying over local
// configurations already present. Test scripts never import/export user settings.
void CarryConfigs(bool exiting, const std::filesystem::path& workingDirectory);
}
