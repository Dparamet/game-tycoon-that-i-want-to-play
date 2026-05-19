# Technical Architecture: Military Strategy Tycoon MVP

## Architecture Goals

This project uses Rojo with Luau modules. The MVP must be small enough to ship, but strict enough to scale into more branches, larger force sizes, multiplayer, and deeper combat later.

Primary goals:

- Server-authoritative progression.
- Data-driven configs for ranks, roles, buildings, training, enemies, territories, and missions.
- Permanent AI soldiers with safe DataStore persistence.
- Clear service boundaries.
- Minimal client trust.
- MVP first, expansion-ready structure.

## Current Project

```text
default.project.json
src/client/
src/server/
src/shared/
docs/
```

Rojo mapping:

```text
src/shared → ReplicatedStorage.Shared
src/server → ServerScriptService.Server
src/client → StarterPlayer.StarterPlayerScripts.Client
```

## Target Structure

```text
src/
  shared/
    config/
      Buildings.luau
      Combat.luau
      Enemies.luau
      Ranks.luau
      Roles.luau
      Territories.luau
      TrainingCourses.luau
    constants/
      Remotes.luau
      Statuses.luau
    net/
      RemoteRegistry.luau
    types/
      CombatTypes.luau
      PlayerDataTypes.luau
      UnitTypes.luau
    util/
      Id.luau
      Time.luau

  server/
    bootstrap/
      ServiceRegistry.luau
    services/
      DataService.luau
      EconomyService.luau
      BaseService.luau
      UnitService.luau
      TrainingService.luau
      RecoveryService.luau
      SquadService.luau
      TerritoryService.luau
      MissionService.luau
      CombatService.luau
      RemoteService.luau
    init.server.luau

  client/
    controllers/
      HudController.luau
      BaseUiController.luau
      RosterController.luau
      TrainingController.luau
      TerritoryMapController.luau
      FieldCommandController.luau
    init.client.luau
```

## Runtime Layers

```text
Config Layer
→ Pure tables, no game state.

Domain Layer
→ Unit, training, economy, squad, territory, mission rules.

Persistence Layer
→ DataStore load/save, migration, default data, session cache.

Network Layer
→ RemoteEvents / RemoteFunctions, validation, client sync.

Presentation Layer
→ UI, input, field command controls.
```

## Server Authority

Server owns:

- resources.
- buildings.
- unit creation.
- training progress.
- recovery progress.
- squad membership.
- mission launch.
- combat results.
- injuries.
- KIA.
- territory state.
- DataStore.

Client can request:

- buy building.
- start training.
- claim training result.
- create squad.
- assign unit.
- launch mission.
- select tactic.
- issue field command.

Server validates every request.

Never trust client for:

- Cash.
- Supplies.
- XP.
- rank.
- health.
- injury.
- mission result.
- territory owner.
- timers.

## Data Model

### PlayerData

```lua
export type PlayerData = {
    version: number,
    resources: Resources,
    base: BaseData,
    units: {[string]: UnitData},
    squads: {[string]: SquadData},
    territories: {[string]: TerritoryState},
    trainingQueue: {[string]: TrainingJob},
    recoveryQueue: {[string]: RecoveryJob},
    lastLogoutTime: number,
}
```

### Resources

```lua
export type Resources = {
    cash: number,
    supplies: number,
}
```

### BaseData

```lua
export type BaseData = {
    commandCenterLevel: number,
    buildings: {[string]: BuildingState},
}

export type BuildingState = {
    id: string,
    level: number,
    purchasedAt: number,
}
```

### UnitData

```lua
export type UnitData = {
    id: string,
    name: string,
    branch: string,
    rank: string,
    role: string,
    status: string,
    xp: number,
    health: number,
    injury: InjuryData?,
    squadId: string?,
    fireteamId: string?,
    createdAt: number,
    updatedAt: number,
}

export type InjuryData = {
    severity: string,
    startedAt: number,
    recoveryEndsAt: number,
    statPenalty: number?,
}
```

### SquadData

```lua
export type SquadData = {
    id: string,
    name: string,
    branch: string,
    echelon: string,
    commanderUnitId: string?,
    tactic: string,
    fireteams: {[string]: FireteamData},
    memberUnitIds: {string},
    readiness: number,
}

export type FireteamData = {
    id: string,
    name: string,
    leaderUnitId: string?,
    memberUnitIds: {string},
    currentCommand: string,
}
```

### TrainingJob

```lua
export type TrainingJob = {
    id: string,
    unitId: string,
    courseId: string,
    mode: string,
    startedAt: number,
    endsAt: number,
    boostMultiplier: number,
}
```

### TerritoryState

```lua
export type TerritoryState = {
    id: string,
    owner: string,
    unlocked: boolean,
    capturedAt: number?,
    threatLevel: number,
}
```

## DataStore Strategy

Use one profile per player:

```text
DataStore name: MilitaryStrategyTycoon_v1
Key: player_<UserId>
```

Save triggers:

- `PlayerRemoving`.
- periodic autosave, default every `60` seconds.
- important state changes after debounce:
  - mission complete.
  - KIA.
  - building purchase.
  - squad assignment.

Load flow:

```text
PlayerAdded
→ DataService.load(player)
→ apply migrations
→ process offline progress
→ cache profile
→ sync initial state to client
```

Save flow:

```text
state mutation
→ markDirty(player)
→ debounce save
→ UpdateAsync
→ clear dirty flag
```

Failure policy:

- If load fails: do not give fake permanent progress.
- Show retry UI later.
- For MVP, kick with clear message after repeated load failure.
- If save fails: keep session data in memory and retry.

Migration rule:

```lua
if data.version < CURRENT_VERSION then
    data = migrate(data)
end
```

## Offline Progress

Use server time:

```lua
local now = os.time()
local elapsed = math.clamp(now - data.lastLogoutTime, 0, OFFLINE_CAP_SECONDS)
```

Default:

```text
OFFLINE_CAP_SECONDS = 28800 -- 8 hours
```

Offline processors:

- TrainingService completes eligible training jobs.
- RecoveryService completes eligible recovery jobs.
- EconomyService grants capped passive income later.

No offline combat in MVP unless explicitly added later.

## Services

### DataService

Responsibilities:

- default data.
- DataStore load/save.
- migration.
- session cache.
- dirty save queue.
- offline processing orchestration.

Public API:

```lua
DataService:Get(player): PlayerData
DataService:Update(player, mutator): PlayerData
DataService:Save(player): boolean
DataService:Release(player)
```

Rules:

- All mutations go through `DataService:Update`.
- No other service writes DataStore directly.

### EconomyService

Responsibilities:

- add/spend resources.
- validate affordability.
- passive resource ticks.

Public API:

```lua
EconomyService:CanAfford(player, cost): boolean
EconomyService:Spend(player, cost): boolean
EconomyService:Add(player, rewards)
```

### BaseService

Responsibilities:

- buy buildings.
- upgrade Command Center.
- calculate unlocks.
- expose available actions.

Public API:

```lua
BaseService:BuyBuilding(player, buildingId): boolean
BaseService:UpgradeCommandCenter(player): boolean
BaseService:HasBuilding(player, buildingId): boolean
```

### UnitService

Responsibilities:

- create units.
- update status.
- apply XP.
- rank-up checks.
- apply injury.
- mark KIA.

Public API:

```lua
UnitService:CreateCitizen(player): UnitData
UnitService:SetStatus(player, unitId, status)
UnitService:AddXP(player, unitId, amount)
UnitService:ApplyInjury(player, unitId, injury)
UnitService:MarkKIA(player, unitId)
```

### TrainingService

Responsibilities:

- start passive training.
- apply active training progress.
- apply boosts.
- process training completion.
- process offline training.

Public API:

```lua
TrainingService:StartTraining(player, unitId, courseId, mode): boolean
TrainingService:ApplyActiveProgress(player, unitId, score): boolean
TrainingService:Process(player, now)
```

### RecoveryService

Responsibilities:

- start recovery from injury.
- process recovery.
- process offline recovery.

Public API:

```lua
RecoveryService:StartRecovery(player, unitId): boolean
RecoveryService:Process(player, now)
```

### SquadService

Responsibilities:

- create squad.
- assign units.
- create Alpha / Bravo fireteams.
- validate roles.
- calculate readiness.

Public API:

```lua
SquadService:CreateSquad(player, name): SquadData
SquadService:AssignUnit(player, squadId, fireteamId, unitId): boolean
SquadService:SetCommander(player, squadId, unitId): boolean
SquadService:GetReadiness(player, squadId): number
```

### TerritoryService

Responsibilities:

- define territory unlock state.
- update owner.
- expose available missions.

Public API:

```lua
TerritoryService:GetAvailable(player): {string}
TerritoryService:Capture(player, territoryId)
TerritoryService:SetThreat(player, territoryId, threatLevel)
```

### MissionService

Responsibilities:

- validate mission launch.
- reserve squad.
- call CombatService.
- apply mission results.
- release / update units.

Public API:

```lua
MissionService:StartAutoMission(player, territoryId, squadId, tactic): MissionResult
MissionService:StartFieldMission(player, territoryId, squadId, tactic): MissionSession
MissionService:CompleteMission(player, missionId, result)
```

### CombatService

Responsibilities:

- pure combat calculations.
- no DataStore writes.
- returns deterministic result from inputs plus RNG.

Public API:

```lua
CombatService:ResolveAuto(context): MissionResult
CombatService:RollCasualties(context): CasualtyResult
CombatService:CalculateRewards(context): Rewards
```

### RemoteService

Responsibilities:

- create remotes.
- route client requests.
- validate payload shape.
- rate-limit spammy actions.

Public API:

```lua
RemoteService:Bind()
RemoteService:FireState(player)
RemoteService:FirePatch(player, patch)
```

## Remote Design

Use shared constants:

```lua
return {
    RequestAction = "RequestAction",
    StateSnapshot = "StateSnapshot",
    StatePatch = "StatePatch",
    FieldCommand = "FieldCommand",
}
```

Client request shape:

```lua
{
    action = "StartTraining",
    payload = {
        unitId = "unit_001",
        courseId = "basic_army_training",
        mode = "Passive",
    },
}
```

Server response:

```lua
{
    ok = true,
    error = nil,
    patch = {},
}
```

Validation:

- action exists.
- payload fields exist.
- player owns unit/squad.
- status allows action.
- required building exists.
- resource cost can be paid.
- action cooldown not exceeded.

## Config Modules

### Ranks.luau

```lua
return {
    Citizen = {
        order = 0,
        nextRank = "Recruit",
        minXP = 0,
        canCommand = false,
    },
    Recruit = {
        order = 1,
        nextRank = "Private",
        minXP = 10,
        canCommand = false,
    },
}
```

### Roles.luau

```lua
return {
    Rifleman = {
        unlockBuilding = "Armory",
        unlockLevel = 1,
        combatPower = 10,
        suppression = 0,
        movement = 1,
    },
    AutomaticRifleman = {
        unlockBuilding = "Armory",
        unlockLevel = 2,
        combatPower = 12,
        suppression = 2,
        movement = 0.85,
    },
}
```

### Buildings.luau

```lua
return {
    CommandCenter = {
        maxLevel = 5,
        cost = {
            cash = 0,
            supplies = 0,
        },
    },
    TrainingGround = {
        requires = {
            commandCenterLevel = 1,
        },
        cost = {
            cash = 100,
            supplies = 0,
        },
    },
}
```

### TrainingCourses.luau

```lua
return {
    BasicArmyTraining = {
        inputRank = "Citizen",
        outputRank = "Recruit",
        durationSeconds = 60,
        cost = {
            cash = 50,
            supplies = 0,
        },
        rewardXP = 10,
    },
}
```

## Combat Math MVP

Keep combat readable and tunable.

```text
squadPower =
  unit role power
  + rank bonus
  + readiness bonus
  + tactic modifier
  + morale modifier
```

```text
enemyPower =
  enemy level power
  + territory difficulty
  + terrain modifier
```

Win chance:

```text
chance = squadPower / (squadPower + enemyPower)
chance = clamp(chance, 0.1, 0.9)
```

Casualty chance depends on:

- win / loss.
- power gap.
- tactic.
- readiness.
- medic support later.
- extraction success later.

MissionResult:

```lua
{
    victory = true,
    rewards = {
        cash = 100,
        supplies = 25,
    },
    unitResults = {
        unit_001 = {
            xp = 12,
            status = "Available",
            injury = nil,
        },
        unit_002 = {
            xp = 8,
            status = "Wounded",
            injury = {
                severity = "Light",
                recoverySeconds = 300,
            },
        },
    },
    territoryCaptured = true,
}
```

## Field Command MVP

Field Command should reuse squad/mission data from Auto Resolve.

Initial commands:

```text
Alpha: Move / Attack / Hold / Suppress / Retreat
Bravo: Move / Attack / Hold / Suppress / Retreat
All: Follow / Rally / Extract
```

Implementation phases:

1. Command UI sends selected command.
2. Server validates player is in active mission.
3. Server updates mission session command state.
4. AI controller reads command state.
5. Mission outcome uses live combat events later.

For first MVP, Field Command may still produce a simplified combat result at extraction/completion.

## UI Architecture

Client controllers:

```text
HudController
- resources
- base level
- notifications

BaseUiController
- building purchases
- command center upgrade

RosterController
- units
- status
- rank
- injury
- assign to squad

TrainingController
- passive training queue
- active training entry

TerritoryMapController
- territory list/map
- mission launch

FieldCommandController
- Alpha / Bravo command buttons
- All command buttons
```

UI reads server snapshots and patches. UI does not calculate permanent outcomes.

## MVP Implementation Order

### Phase 1: Foundation

- Create shared config modules.
- Create shared type modules.
- Create DataService default profile.
- Wire service registry.
- Build Rojo successfully.

Acceptance:

- New player data can be generated in server logs.
- No UI required.

### Phase 2: Economy And Base

- EconomyService.
- BaseService.
- building purchase validation.
- basic HUD sync.

Acceptance:

- Player can buy `TrainingGround`.
- Cash changes server-side and syncs to client.

### Phase 3: Units And Training

- UnitService.
- TrainingService.
- passive training queue.
- offline training.

Acceptance:

- Player can create Citizen.
- Citizen can train into Recruit.
- Leave/rejoin completes eligible training.

### Phase 4: Squads And Fireteams

- SquadService.
- Alpha / Bravo fireteams.
- role assignment.
- readiness calculation.

Acceptance:

- Player can create one squad.
- Units can be assigned to Alpha / Bravo.

### Phase 5: Territory And Auto Mission

- TerritoryService.
- MissionService.
- CombatService Auto Resolve.
- rewards, injury, KIA, territory capture.

Acceptance:

- Player launches one mission.
- Mission updates resources, units, and territory.

### Phase 6: Recovery

- RecoveryService.
- Medical Tent requirement.
- offline recovery.

Acceptance:

- Wounded unit recovers into Available.
- KIA unit never returns to assignable roster.

### Phase 7: Field Command Thin Slice

- FieldCommandController.
- command remotes.
- mission command state.
- Alpha / Bravo command buttons.

Acceptance:

- Player enters a simple field mission.
- Alpha and Bravo accept commands.
- Mission can extract and resolve.

## Testing And Verification

Commands:

```powershell
rojo build -o "game tycoon that i want to play.rbxlx"
```

```powershell
rojo serve
```

```powershell
git status
```

Manual checks in Roblox Studio:

- start Play Solo.
- verify default data log.
- buy building.
- start training.
- save/rejoin test.
- run auto mission.
- verify injury/KIA.

Code checks:

- Config modules return plain tables.
- Services do not require client modules.
- Client does not mutate PlayerData.
- CombatService can be tested as pure module.

## Risk Register

### DataStore Corruption

Risk:

- Permanent units make bad saves painful.

Mitigation:

- versioned schema.
- default data validator.
- migrations.
- UpdateAsync.
- no client authority.

### Scope Explosion

Risk:

- Branches, platoons, vehicles, multiplayer, and Robux can explode scope.

Mitigation:

- Army only.
- Squad only.
- one territory chain.
- one enemy family.
- Robux later.

### Combat Complexity

Risk:

- Real-time AI can delay the whole game.

Mitigation:

- Auto Resolve first.
- Field Command thin slice later.
- shared mission data model.

### Exploits

Risk:

- Client fakes resources, mission wins, or training completion.

Mitigation:

- server validates all actions.
- server owns timers.
- server owns combat.
- remotes use action whitelist.

### Balance Pain

Risk:

- Permanent death can feel unfair.

Mitigation:

- early missions low KIA rate.
- injury more common than KIA.
- retreat/extract command reduces losses.
- clear mission risk preview later.

## Expansion Paths

### Branches

Add:

```text
Marines
Navy
AirForce
```

Required changes:

- config data.
- branch unlock rules.
- branch-specific training courses.
- branch-specific roles.
- territory requirements.

No unit schema rewrite should be needed.

### Force Scale

Add:

```text
Platoon
Company
Battalion
```

Required changes:

- `ForceGroup.echelon`.
- command hierarchy.
- mission scale.
- UI grouping.

No squad schema deletion should be needed.

### Enemy Faction

Add:

- enemy bases.
- counterattacks.
- enemy ranks.
- territory AI.

Use existing territory and mission state.

### Monetization

Possible later:

- cosmetic uniforms.
- training boost.
- extra save slots.
- VIP base decorations.

Avoid:

- selling direct unfair victory.
- paid-only essential recovery.
- paid-only KIA protection unless balanced carefully.

## Coding Boundaries

Always:

- Add config before hardcoding gameplay numbers.
- Keep server as source of truth.
- Keep DataStore writes in DataService.
- Keep CombatService pure where possible.
- Keep client UI thin.
- Build with Rojo after structural changes.

Ask first:

- New dependency.
- New branch.
- Robux feature.
- DataStore schema breaking change.
- Multiplayer shared server.
- Real-world weapon naming.

Never:

- Trust client resources.
- Trust client mission result.
- Trust client rank.
- Delete KIA from history silently later.
- Mix UI code into server services.
- Commit generated `.rbxlx` as source of truth unless requested.

## Definition Of Done For MVP Architecture

- `docs/game-design.md` and this file agree.
- `src/shared/config` exists and holds gameplay tables.
- `src/server/services` exists and owns game systems.
- `src/client/controllers` exists and owns UI/input.
- PlayerData can load/save.
- Unit lifecycle works.
- Training and recovery can process offline time.
- Auto Resolve mission works end-to-end.
- Fireteam command has a thin playable version.
