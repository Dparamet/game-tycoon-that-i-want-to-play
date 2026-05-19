# Implementation Plan: Military Strategy Tycoon MVP

## Overview

Build the MVP in thin slices: foundation first, then economy/base, permanent units/training, squads/fireteams, territory missions, recovery, and finally a thin Field Command slice.

## Current Status

```text
Done:
- Task 1: Shared Config Skeleton
- Task 2: Server Service Skeleton
- Task 3: Client Controller Skeleton
- Task 4: Default PlayerData And Session Cache
- Task 5: EconomyService Cash And Supplies
- Task 6: Base Building Purchase
- Task 7: Unit Creation And Lifecycle
- Task 8: Passive Training Queue
- Task 9: Offline Training
- Task 10: Squad Creation
- Task 11: Unit Assignment To Fireteams
- Task 12: Territory State
- Task 13: Auto Resolve Mission
- Task 14: Recovery Queue
- Task 15: Offline Recovery
- Task 16: Field Command Remotes
- Task 17: Simple Field Mission

Next:
- MVP product polish
- Save/load playtest
- Mission/balance pass
- Tycoon conversion later
```

## Architecture Decisions

- Server owns all permanent game state.
- Client sends requests only; server validates and mutates state.
- Gameplay numbers live in `src/shared/config`.
- DataStore access is isolated to `DataService`.
- Combat math starts as pure Auto Resolve before real-time AI expands it.
- MVP supports Army only, but every unit keeps `branch`.

## Phase 1: Foundation

### Task 1: Create Shared Config Skeleton

**Description:** Add data-driven config modules for ranks, roles, buildings, training courses, territories, enemies, combat, statuses, and remotes.

**Acceptance criteria:**
- [ ] Config modules return plain tables.
- [ ] Army-only MVP data exists.
- [ ] Future branch expansion does not require schema rewrite.

**Verification:**
- [ ] Build succeeds: `rojo build -o "game tycoon that i want to play.rbxlx"`
- [ ] Manual check: modules appear under `ReplicatedStorage.Shared`.

**Dependencies:** None

**Files likely touched:**
- `src/shared/config/*.luau`
- `src/shared/constants/*.luau`
- `src/shared/types/*.luau`

**Estimated scope:** Medium

### Task 2: Create Server Service Skeleton

**Description:** Add service modules and a `ServiceRegistry` that starts services in dependency order.

**Acceptance criteria:**
- [ ] `init.server.luau` boots `ServiceRegistry`.
- [ ] Each MVP service exposes `Init` and `Start`.
- [ ] No service writes DataStore except `DataService`.

**Verification:**
- [ ] Build succeeds: `rojo build -o "game tycoon that i want to play.rbxlx"`
- [ ] Studio Play Solo shows service boot logs.

**Dependencies:** Task 1

**Files likely touched:**
- `src/server/bootstrap/ServiceRegistry.luau`
- `src/server/services/*.luau`
- `src/server/init.server.luau`

**Estimated scope:** Medium

### Task 3: Create Client Controller Skeleton

**Description:** Add controller modules for HUD, base UI, roster, training, territory map, and field commands.

**Acceptance criteria:**
- [ ] `init.client.luau` starts controllers.
- [ ] Controllers have `Init` and `Start`.
- [ ] No client module mutates permanent state directly.

**Verification:**
- [ ] Build succeeds: `rojo build -o "game tycoon that i want to play.rbxlx"`
- [ ] Studio Play Solo shows controller boot logs.

**Dependencies:** Task 1

**Files likely touched:**
- `src/client/controllers/*.luau`
- `src/client/init.client.luau`

**Estimated scope:** Small

### Checkpoint: Foundation

- [ ] Rojo build succeeds.
- [ ] Server boots services.
- [ ] Client boots controllers.
- [ ] No gameplay state is client-authoritative.

## Phase 2: Economy And Base

### Task 4: Default PlayerData And Session Cache

**Description:** Implement default `PlayerData`, session cache, and safe mutation path through `DataService:Update`.

**Acceptance criteria:**
- [ ] New player gets default resources, base, units, squads, territories, queues, and `lastLogoutTime`.
- [ ] Other services read data through `DataService:Get`.
- [ ] Mutations go through `DataService:Update`.

**Verification:**
- [ ] Studio Play Solo logs default data.
- [ ] No DataStore save required yet.

**Dependencies:** Task 2

**Files likely touched:**
- `src/server/services/DataService.luau`
- `src/shared/types/PlayerDataTypes.luau`

**Estimated scope:** Small

### Task 5: EconomyService Cash And Supplies

**Description:** Add server-side resource spending and rewards.

**Acceptance criteria:**
- [ ] `CanAfford`, `Spend`, and `Add` work.
- [ ] Resources never go negative.
- [ ] Client cannot directly change resources.

**Verification:**
- [ ] Manual server log test.

**Dependencies:** Task 4

**Files likely touched:**
- `src/server/services/EconomyService.luau`

**Estimated scope:** Small

### Task 6: Base Building Purchase

**Description:** Implement tycoon-style functional building purchases using config costs and unlock requirements.

**Acceptance criteria:**
- [ ] Player can buy `TrainingGround`.
- [ ] Cost is deducted server-side.
- [ ] Duplicate purchase is rejected.

**Verification:**
- [ ] Studio Play Solo test through server call or temporary debug command.

**Dependencies:** Task 5

**Files likely touched:**
- `src/server/services/BaseService.luau`
- `src/shared/config/Buildings.luau`

**Estimated scope:** Medium

## Phase 3: Units And Training

### Task 7: Unit Creation And Lifecycle

**Description:** Implement Citizen creation, statuses, XP, rank checks, injury assignment, and KIA.

**Acceptance criteria:**
- [ ] Player can create a `Citizen`.
- [ ] Unit has stable `id`, `branch`, `rank`, `role`, `status`, `xp`, `health`.
- [ ] `KIA` units cannot be assigned later.

**Verification:**
- [ ] Manual server log test.

**Dependencies:** Task 4

**Files likely touched:**
- `src/server/services/UnitService.luau`
- `src/shared/config/Ranks.luau`
- `src/shared/constants/Statuses.luau`

**Estimated scope:** Medium

### Task 8: Passive Training Queue

**Description:** Implement `Citizen → Recruit` passive training with cost, duration, and completion.

**Acceptance criteria:**
- [ ] Training requires `TrainingGround`.
- [ ] Training spends configured cost.
- [ ] Completed unit becomes `Recruit`.

**Verification:**
- [ ] Studio Play Solo: start training and wait for completion.

**Dependencies:** Tasks 6, 7

**Files likely touched:**
- `src/server/services/TrainingService.luau`
- `src/shared/config/TrainingCourses.luau`

**Estimated scope:** Medium

### Task 9: Offline Training

**Description:** Process training progress using `lastLogoutTime` and capped elapsed time.

**Acceptance criteria:**
- [ ] Offline cap defaults to `8 hours`.
- [ ] Eligible jobs complete on rejoin.
- [ ] Future jobs remain queued.

**Verification:**
- [ ] Simulate `lastLogoutTime` in Studio.

**Dependencies:** Task 8

**Files likely touched:**
- `src/server/services/DataService.luau`
- `src/server/services/TrainingService.luau`
- `src/shared/util/Time.luau`

**Estimated scope:** Medium

## Phase 4: Squads And Fireteams

### Task 10: Squad Creation

**Description:** Create squad data with Alpha and Bravo fireteams.

**Acceptance criteria:**
- [ ] Player can create one Army squad.
- [ ] Squad has Alpha and Bravo fireteams.
- [ ] Squad has `echelon = "Squad"`.

**Verification:**
- [ ] Manual server log test.

**Dependencies:** Task 7

**Files likely touched:**
- `src/server/services/SquadService.luau`

**Estimated scope:** Small

### Task 11: Unit Assignment To Fireteams

**Description:** Assign Available units into Alpha or Bravo with status checks.

**Acceptance criteria:**
- [ ] Available unit can be assigned.
- [ ] Wounded, Recovering, InMission, and KIA units are rejected.
- [ ] Unit records `squadId` and `fireteamId`.

**Verification:**
- [ ] Manual server log test.

**Dependencies:** Task 10

**Files likely touched:**
- `src/server/services/SquadService.luau`
- `src/server/services/UnitService.luau`

**Estimated scope:** Medium

## Phase 5: Territory And Auto Mission

### Task 12: Territory State

**Description:** Initialize territory ownership and unlock state from config.

**Acceptance criteria:**
- [ ] New player has territory states.
- [ ] Territory 1 is available.
- [ ] Later territories are locked or higher threat.

**Verification:**
- [ ] Manual server log test.

**Dependencies:** Task 4

**Files likely touched:**
- `src/server/services/TerritoryService.luau`
- `src/shared/config/Territories.luau`

**Estimated scope:** Small

### Task 13: Auto Resolve Mission

**Description:** Launch one mission and resolve it with CombatService.

**Acceptance criteria:**
- [ ] Mission requires available squad.
- [ ] Combat result applies rewards, XP, injuries, KIA, and territory capture.
- [ ] Squad units are released or updated after result.

**Verification:**
- [ ] Studio Play Solo: run one mission end-to-end.

**Dependencies:** Tasks 10, 11, 12

**Files likely touched:**
- `src/server/services/MissionService.luau`
- `src/server/services/CombatService.luau`
- `src/server/services/UnitService.luau`
- `src/server/services/EconomyService.luau`
- `src/server/services/TerritoryService.luau`

**Estimated scope:** Medium

## Phase 6: Recovery

### Task 14: Recovery Queue

**Description:** Move Wounded units through recovery into Available.

**Acceptance criteria:**
- [ ] Recovery requires `MedicalTent`.
- [ ] Recovery uses configured duration by severity.
- [ ] Completed recovery sets status to `Available`.

**Verification:**
- [ ] Studio Play Solo: wounded unit recovers.

**Dependencies:** Task 13

**Files likely touched:**
- `src/server/services/RecoveryService.luau`
- `src/shared/config/Combat.luau`

**Estimated scope:** Medium

### Task 15: Offline Recovery

**Description:** Process recovery queue on rejoin with offline cap.

**Acceptance criteria:**
- [ ] Eligible recovery completes on rejoin.
- [ ] KIA units are not recovered.

**Verification:**
- [ ] Simulate `lastLogoutTime` in Studio.

**Dependencies:** Task 14

**Files likely touched:**
- `src/server/services/DataService.luau`
- `src/server/services/RecoveryService.luau`

**Estimated scope:** Small

## Phase 7: Field Command Thin Slice

### Task 16: Field Command Remotes

**Description:** Add remote action routing for Alpha and Bravo commands.

**Acceptance criteria:**
- [ ] Server validates active mission ownership.
- [ ] Alpha / Bravo command state updates server-side.
- [ ] Invalid commands are rejected.

**Verification:**
- [ ] Studio Play Solo: command requests log on server.

**Dependencies:** Task 13

**Files likely touched:**
- `src/server/services/RemoteService.luau`
- `src/client/controllers/FieldCommandController.luau`
- `src/shared/constants/Remotes.luau`

**Estimated scope:** Medium

### Task 17: Simple Field Mission

**Description:** Create a minimal field mission where command choices influence final Auto Resolve modifiers.

**Acceptance criteria:**
- [ ] Player can start field mission.
- [ ] Alpha and Bravo can receive commands.
- [ ] Extract/completion resolves mission with command modifiers.

**Verification:**
- [ ] Studio Play Solo: field mission starts, accepts commands, resolves.

**Dependencies:** Task 16

**Files likely touched:**
- `src/server/services/MissionService.luau`
- `src/server/services/CombatService.luau`
- `src/client/controllers/FieldCommandController.luau`

**Estimated scope:** Medium

## Final Checkpoint

- [ ] New player can progress from Citizen to Recruit.
- [ ] Player can form one squad with Alpha and Bravo.
- [ ] Player can run one Auto Resolve mission.
- [ ] Mission can reward, wound, kill, or capture territory.
- [ ] Wounded units recover.
- [ ] KIA units remain permanently unavailable.
- [ ] Data persists across rejoin.
- [ ] `rojo build -o "game tycoon that i want to play.rbxlx"` succeeds.

## Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---:|---|
| DataStore bugs delete permanent soldiers | High | Versioned schema, UpdateAsync, service-only writes |
| Scope expands into full RTS too early | High | Auto Resolve first, Field Command thin slice later |
| Client exploit changes resources | High | Server validates all actions |
| Combat feels unfair | Medium | Low early KIA rate, clear mission risk later |
| UI slows backend progress | Medium | Debug/server slices first, UI after core state works |

## Open Questions

- First active training mini-game: target shooting, timing drill, or checkpoint run?
- First territory name and theme?
- Visual style: low-poly military, stylized Roblox toy soldiers, or semi-realistic base?
- Save system: use Roblox DataStore directly first, or add ProfileStore later?
