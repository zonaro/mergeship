// Linux-only diagnostics for the hosted game modules. Does not initialize either engine.
// Usage: mergeship-linux-probe [libsoh.so] [lib2ship.so] [--lus-abi ABI_ID]
#include "EngineModule.h"
#include <iostream>
#include <string>
#include <vector>

int main(int argc, char** argv) {
    std::vector<std::string> libraries;
    std::string expectedAbi;
    for (int i = 1; i < argc; ++i) {
        const std::string argument(argv[i]);
        if (argument == "--lus-abi") {
            if (++i == argc) {
                std::cerr << "Missing ABI identifier after --lus-abi\n";
                return 2;
            }
            expectedAbi = argv[i];
        } else if (argument == "--help" || argument == "-h") {
            std::cout << "Usage: mergeship-linux-probe [libsoh.so] [lib2ship.so] [--lus-abi ABI_ID]\n"
                         "Checks that the shared engine modules load and expose the MergeShip ABI.\n"
                         "This is NOT the playable Linux host.\n";
            return 0;
        } else {
            libraries.push_back(argument);
        }
    }
    if (libraries.empty()) {
        libraries = {"./libsoh.so", "./lib2ship.so"};
    }
    if (libraries.size() > 2) {
        std::cerr << "Provide at most two engine libraries.\n";
        return 2;
    }
    int failures = 0;
    std::string firstAbi;
    for (const auto& library : libraries) {
        MergeShipHost::EngineModule module;
        if (!module.Load(library)) {
            std::cerr << "[FAIL] " << library << ": " << module.Error() << '\n';
            ++failures;
            continue;
        }
        const MsEngineAbi* abi = module.Abi();
        const std::string actualAbi = abi->lusAbiId != nullptr ? abi->lusAbiId : "";
        std::cout << "[LOAD] " << library << " engine=" << module.Name()
                  << " id=" << module.Id() << " api=" << abi->apiVersion
                  << " lus=" << actualAbi << '\n';
        if (firstAbi.empty()) firstAbi = actualAbi;
        const std::string& checkAbi = expectedAbi.empty() ? firstAbi : expectedAbi;
        if (!module.CheckAbi(checkAbi.c_str())) {
            std::cerr << "[FAIL] " << library << ": " << module.Error() << '\n';
            ++failures;
        }
    }
    if (failures) {
        std::cerr << failures << " module(s) failed validation.\n";
        return 1;
    }
    std::cout << "All supplied module ABI checks passed. Engine initialization not tested.\n";
    return 0;
}
