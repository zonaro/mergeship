// CI-only test fixture: no Zelda game code, assets, ROMs or rendering.
// This exists to test the real ELF dynamic loader, expected exports and ABI checks.
#include <mergeship/EngineApi.h>

#ifndef MERGESHIP_FAKE_ENGINE_ID
#define MERGESHIP_FAKE_ENGINE_ID MS_ENGINE_SOH
#endif

#ifdef MERGESHIP_FAKE_ABI_MISMATCH
static constexpr const char* kAbi = "probe-fixture-incompatible";
#else
static constexpr const char* kAbi = "probe-fixture";
#endif

static const MsEngineAbi kEngine = {
    sizeof(MsEngineAbi),
    MS_ENGINE_API_VERSION,
    MERGESHIP_FAKE_ENGINE_ID,
    "MergeShip CI mock engine (not a game)",
    kAbi,
};

extern "C" {
MS_ENGINE_EXPORT const MsEngineAbi* MsEngine_GetAbi(void) { return &kEngine; }
MS_ENGINE_EXPORT int32_t MsEngine_Init(const MsHostServices*, int32_t, char**) { return 0; }
MS_ENGINE_EXPORT int32_t MsEngine_RunFrame(void) { return MS_FRAME_EXITED; }
MS_ENGINE_EXPORT void MsEngine_Suspend(void) {}
MS_ENGINE_EXPORT void MsEngine_Resume(const MsTransfer*) {}
MS_ENGINE_EXPORT void MsEngine_Shutdown(void) {}
MS_ENGINE_EXPORT void* MsEngine_GetContext(void) { return nullptr; }
}
