# AI collaboration rules — 2015: CODE ROT

This repository is edited by more than one AI assistant. Avoid overlapping ownership so visual work and gameplay work do not overwrite each other.

## Ownership

### Visual / level-design lane
Primary files:
- `src/ServerScriptService/Services/WorldService.lua`
- `src/ServerScriptService/Services/LevelDesign.lua`
- `src/StarterPlayer/StarterPlayerScripts/Client.client.lua`

Scope:
- lobby layout
- chapter geometry and POIs
- interiors and set dressing
- lighting / atmosphere / boundaries
- HUD / UI / localization presentation

### Gameplay / backend lane
Preferred files:
- `src/ServerScriptService/Services/RoundService.lua`
- `src/ServerScriptService/Services/EnemyService.lua`
- `src/ServerScriptService/Services/BuildService.lua`
- `src/ServerScriptService/Services/DataService.lua`
- `src/ServerScriptService/Services/MemoryService.lua`
- `src/ReplicatedStorage/Shared/Config.lua` when changing balance or mechanics

Scope:
- round flow
- objectives and chapter progression
- enemy behavior
- building mechanics
- persistence / DataStore
- rewards / classes / balance
- runtime bug fixes

## Branches

Do not have two assistants directly editing the same file on `main` at the same time.

Suggested branches:
- `art-ui/<task>`
- `gameplay/<task>`
- `fix/<task>`

Open a pull request to `main`. Keep a task focused enough that another assistant can review the diff.

## Integration contracts

- Preserve RemoteEvent names unless both client and server are updated in the same PR.
- Preserve Config chapter IDs 1–10.
- Do not rename `GeneratedWorld`, `Lobby`, or `Arena` without updating every service using them.
- New environment art should go into `LevelDesign.lua` instead of making `WorldService.lua` even larger.
- Keep decorative parts anchored. Avoid per-prop scripts.
- The game must remain usable on mobile, so prefer repeated lightweight Parts over thousands of unique objects.
- Keep player-facing text localized where practical; RU and EN are required, ES/PT/TR are supported by the client.
- Never commit Roblox API keys, tokens, cookies, or other credentials.

## Release

The GitHub Action on `main` builds the Rojo project and publishes the Start Place. Before merging, check for accidental file overlap and runtime assumptions. After merge, verify the Actions publish step succeeds.
