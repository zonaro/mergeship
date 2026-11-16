# MergeShip2 implementation constraints

- Do not use code from the original Mergeship project, including its soh_fd tree.
  The user explicitly rejected that implementation on 2026-09-22.
  Exception (user decision, 2026-09-23): PR #1 on sonsegajp/Mergeship2 ("soh_fd's form and
  Fierce Deity features", by Vio) is merged as-is, including its soh_fd-derived features and
  its Fierce Deity sword beam (MergeShipSohFd.*). That code may be maintained and extended;
  do not pull in further soh_fd code without asking.
- Use the native MM implementation in 2ship2harkinian and the OoT implementation
  in Shipwright as the source references for this redo.
- Required result: assets usable in both runtimes, and all four MM transformation
  masks and their native abilities functional in OoT.
- Builds, asset parsing, and skeleton swaps are not gameplay completion evidence.

## Native Linux fork maintenance (2026-11-16)

- Project objective: play both original campaigns, linked through the existing cross-world door. The randomizer, Anchor and unrelated DX/Rush features are **optional** and must never block story mode.
- Linux port tracking epic: #3; individual phase issues #4–#14. Development branch: `feature/linux-native-port`, draft PR #1. Preserve the existing upstream implementation constraints above.
- Read `.agents/ARCHITECTURE.md`, `.agents/WORKFLOW.md`, `.agents/TESTING.md` and `docs/LINUX_PORT.md` before changing the host or engine build.
- Keep three independent build trees (host, SoH, 2Ship) and one ABI-compatible shared libultraship. Avoid globally loading engine symbols; default to RTLD_LOCAL with the engine's intended linker isolation flags.
- Do not mix one game's ResourceManager, factories, settings or caches into the other. The game engines have colliding names and asset paths. No ABI bypasses to make tests pass.
- Restrict platform-specific APIs to guarded/isolated implementations. Never remove Android or Windows functionality just to compile Linux. Avoid introducing Electron, Flutter or runtime frameworks into the game host.
- Never ship ROMs, O2R archives containing game assets, credentials or copyrighted game data in builds, tests, commits or releases. ROM-dependent tests run only locally with legally obtained inputs.
- Save files are user data: never silently replace or migrate destructively. Separate debug/test configurations and back up before changes.
- Mark changes as *implemented*, *compiled*, *tested*, or *gameplay verified* accurately. An ELF loader probe is not proof of a playable native host.
- For every phase: reference its GitHub issue, write acceptance evidence and known blockers, and prefer small reviewable commits. No merging an unfinished Linux host into main.
