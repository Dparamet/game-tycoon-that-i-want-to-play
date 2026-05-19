# Spec: Military Strategy Tycoon MVP

## Objective

Build a Roblox strategy tycoon where the player starts as a base commander, grows an Army force from citizens, trains permanent AI soldiers, commands them in missions, and expands territory over time.

The first playable version must prove the core loop:

```text
Base
→ recruit Citizen
→ train Recruit
→ assign Squad / Fireteam
→ choose Territory
→ run Mission
→ gain Cash, Supplies, XP
→ handle Wounded / KIA
→ upgrade Base
```

The game should be easy to scale into more branches later, such as Marines, Navy, and Air Force, but MVP ships with Army only.

## Player Fantasy

The player has two roles:

- Base Commander: builds the base, manages soldiers, training, squads, resources, and territory.
- Field Officer: joins missions directly and commands AI fireteams.

The game should feel like a light military strategy combat game, not a realistic simulator or real-world training guide.

## MVP Scope

### Included

- Army branch only.
- Single-player private progression.
- Tycoon-style base with functional buildings.
- Cash and Supplies resources.
- Permanent AI soldiers with rank, role, XP, status, injury, and KIA.
- Passive training for AFK/offline progression.
- Active training as a gameplay mini-game.
- Boost training through in-game resources first.
- Territory map with mission-based battles.
- Hybrid combat:
  - Auto Resolve.
  - Field Command.
- Fireteam command from the first combat version.
- US Army inspired squad structure as a game abstraction.
- Raiders as early enemies, scaling later into an Enemy Faction.
- Data saving from MVP.

### Excluded From MVP

- Marines, Navy, Air Force.
- Multiplayer shared bases.
- Free placement base building.
- Full platoon/company/battalion simulation.
- Complex logistics.
- Robux monetization implementation.
- Real-world military doctrine accuracy.
- Graphic gore or overly realistic injury depiction.

## Core Loop

1. The player earns passive Cash from base systems.
2. The player buys functional buildings with tycoon-style unlocks.
3. The player recruits Citizens.
4. Citizens enter training and become Recruits.
5. Recruits gain roles and join squads.
6. Squads are split into Alpha and Bravo fireteams.
7. The player chooses a territory mission.
8. The mission is resolved by Auto Resolve or Field Command.
9. Units gain XP, become Wounded, Recovering, Available, or KIA.
10. Rewards upgrade the base and unlock harder territories.

## Progression

Primary progression is Command Center Level.

```text
Command Center Lv1
- Recruitment Office
- Training Ground
- Squad size 4
- Territory 1

Command Center Lv2
- Barracks
- Alpha / Bravo Fireteam
- Squad size 8
- Territory 2-3

Command Center Lv3
- Medical Tent
- injury / recovery
- harder missions

Command Center Lv4
- Armory
- Automatic Rifleman
- Grenadier
- tactic: Suppress

Command Center Lv5
- Platoon planning placeholder
- Enemy Faction teaser
```

Player Rank and Territory Control may become secondary progression later.

## Branches

MVP uses only:

```text
Army
```

All unit data must still include:

```lua
branch = "Army"
```

Future branches:

- Marines.
- Navy.
- Air Force.

## Ranks

MVP Army ranks:

```text
Citizen
Recruit
Private
Corporal
Sergeant
Lieutenant
Captain
Major
Commander
```

Rank should affect:

- command ability.
- morale bonus.
- mission performance.
- squad leadership eligibility.

## AI Unit Lifecycle

AI soldiers are permanent.

Normal flow:

```text
Citizen
→ Training
→ Available
→ Assigned
→ InMission
→ Wounded
→ Recovering
→ Available
```

Death flow:

```text
InMission
→ KIA
```

`KIA` units are removed from active roster permanently, but may remain in a memorial/history log later.

Unit statuses:

```text
Available
Training
Assigned
InMission
Wounded
Recovering
KIA
```

Injury severity:

```text
Light
Moderate
Severe
KIA
```

MVP injury rules:

- Light injury: short recovery.
- Moderate injury: longer recovery.
- Severe injury: long recovery and possible stat penalty later.
- KIA: permanent loss.

## Training

Training has three layers.

### Passive Training

- Works while AFK.
- Works while offline.
- Uses saved timestamps.
- Has an offline cap to prevent exploit.

Example:

```text
Citizen → Recruit
Cost: Cash 50
Duration: 60 seconds
RewardXP: 10
```

### Active Training

Active mini-game training gives faster progress.

Possible MVP mini-games:

- target shooting.
- timing drill.
- checkpoint run.

Active training rewards:

- training XP.
- reduced training time.
- small stat growth.

### Boost Training

Boosts should start with in-game resources.

MVP boost sources:

- Cash.
- Supplies.
- TrainingToken placeholder.

Robux boosts are not MVP.

## Squad And Fireteam Structure

MVP uses US Army inspired structure as a game abstraction.

```text
Squad
- Squad Leader
- Alpha Fireteam
- Bravo Fireteam
```

Fireteam roles:

```text
Team Leader
Rifleman
Automatic Rifleman
Grenadier
```

Role behavior:

```text
Team Leader
- command aura
- morale bonus

Rifleman
- balanced combat role

Automatic Rifleman
- suppression bonus
- slower movement

Grenadier
- area damage / cover break
- limited ammo
```

## Combat

Combat is hybrid.

### Auto Resolve

Auto Resolve is for AFK/offline-friendly strategy.

Inputs:

- squad strength.
- rank.
- training.
- morale.
- tactic.
- enemy level.
- territory difficulty.
- terrain modifier.
- supplies.

Outputs:

- victory / defeat.
- rewards.
- XP.
- injuries.
- KIA chance.
- territory state change.

### Field Command

The player can enter a mission directly.

Player commands:

```text
Alpha: Move / Attack / Hold / Suppress / Retreat
Bravo: Move / Attack / Hold / Suppress / Retreat
All: Follow / Rally / Extract
```

Field Command should reduce casualties and improve mission result when played well.

## Tactics

MVP tactics:

```text
Frontal Assault
Ambush / Guerrilla
Defend Position
Recon
Retreat
```

Guerrilla is a tactic, not a branch.

Guerrilla modifiers:

- bonus in forest / urban territory.
- bonus to ambush.
- lower supply need.
- penalty in open field.
- penalty against heavy enemy later.

## Force Scale

MVP gameplay starts at Squad and Fireteam level.

Future scale:

```text
Team        2-4
Squad       5-10
Platoon     20-40
Company     80-150
Battalion   300-800
```

Data model should support hierarchy:

```lua
ForceGroup = {
    id = "squad_001",
    name = "1st Squad",
    branch = "Army",
    echelon = "Squad",
    commanderUnitId = "unit_001",
    memberUnitIds = {},
    tactic = "FrontalAssault",
    readiness = 0,
}
```

## Enemies

MVP enemy type:

```text
Raiders
```

Enemy scaling:

```text
Tier 1: Raiders
- light weapons
- low morale
- small patrols
- tutorial / early territory

Tier 2: Organized Raiders
- squad leaders
- cover behavior
- support units

Tier 3: Enemy Faction
- ranks
- bases
- territory AI
- counterattacks
```

Enemy data:

```lua
EnemyUnit = {
    type = "Raider",
    level = 1,
    weaponClass = "Light",
    morale = 50,
    armor = 0,
    behavior = "Rush",
}
```

## Base Buildings

Base building style:

```text
Tycoon-style unlocks + functional systems
```

MVP buildings:

```text
Command Center
- unlock territory map
- manage squads
- launch missions
- upgrade progression

Recruitment Office
- generate Citizens
- manage recruit pool

Training Ground
- Citizen → Recruit
- passive training
- active training

Barracks
- unit capacity
- squad assignment

Medical Tent
- Wounded → Recovering → Available

Armory
- unlock role/loadout
- Rifleman / Automatic Rifleman / Grenadier

Cash Generator
- passive Cash

Supply Depot
- passive Supplies
```

## Economy

Resources:

```text
Cash
Supplies
```

Cash uses:

- buy buildings.
- training fee.
- healing fee.
- upgrades.

Supplies uses:

- launch missions.
- maintain squad.
- active training.
- medical recovery.

Resource sources:

- Cash Generator.
- Supply Depot.
- Mission Reward.
- Territory Income.
- Mission Loot.

## Territory And Missions

MVP territory model:

```lua
Territory = {
    id = "territory_001",
    name = "Outskirts",
    owner = "Raiders",
    difficulty = 1,
    terrain = "Urban",
    enemyTier = 1,
    rewards = {
        cash = 100,
        supplies = 25,
    },
}
```

Mission model:

```lua
Mission = {
    territoryId = "territory_001",
    squadId = "squad_001",
    mode = "AutoResolve",
    tactic = "FrontalAssault",
    objectives = {},
    result = nil,
}
```

MVP objective types:

- eliminate raiders.
- hold point.
- extract squad.
- secure supplies.

## Data Saving

Data saving is required from MVP.

Save data:

- resources.
- buildings.
- units.
- squads.
- territories.
- training queue.
- recovery queue.
- last logout time.

Schema:

```lua
PlayerData = {
    version = 1,

    resources = {
        cash = 0,
        supplies = 0,
    },

    base = {
        commandCenterLevel = 1,
        buildings = {},
    },

    units = {},
    squads = {},
    territories = {},
    trainingQueue = {},
    recoveryQueue = {},
    lastLogoutTime = 0,
}
```

Unit schema:

```lua
UnitData = {
    id = "unit_001",
    name = "Miller",
    branch = "Army",
    rank = "Recruit",
    role = "Rifleman",
    status = "Available",
    xp = 0,
    health = 100,
    injury = nil,
    createdAt = 0,
}
```

Offline processing:

- Save `lastLogoutTime`.
- On join, compare with `os.time()`.
- Progress training queue.
- Progress recovery queue.
- Apply offline cap, default `8 hours`.

## Commands

Rojo build:

```powershell
rojo build -o "game tycoon that i want to play.rbxlx"
```

Rojo serve:

```powershell
rojo serve
```

Git status:

```powershell
git status
```

Git commit example:

```powershell
git add docs/game-design.md
git commit -m "Add MVP game design spec"
```

## Project Structure

Current Rojo structure:

```text
default.project.json
src/client/
src/server/
src/shared/
docs/
```

Recommended future structure:

```text
src/shared/config/
- ranks, roles, buildings, territories, training courses

src/shared/types/
- shared Luau type definitions

src/server/services/
- data, units, training, squads, missions, economy

src/client/controllers/
- UI, input, field command controls

docs/
- specs and design notes
```

## Code Style

Use clear Luau modules with typed table data where useful.

Example style:

```lua
local Ranks = {
    Citizen = {
        order = 0,
        nextRank = "Recruit",
    },

    Recruit = {
        order = 1,
        nextRank = "Private",
    },
}

return Ranks
```

Conventions:

- Use PascalCase for module names.
- Use camelCase for fields and local variables.
- Keep config data in `src/shared/config`.
- Keep server authority on progression, combat result, DataStore, resources, and unit status.
- Keep client responsible for UI and input only.

## Testing Strategy

MVP verification should use:

- Rojo build for syntax/project mapping.
- Studio playtest for DataStore and Roblox services.
- Unit-style module checks where possible.
- Manual mission simulation logs before visual combat is complete.

Acceptance checks:

- New player receives default `PlayerData`.
- Cash and Supplies save/load.
- Citizen can become Recruit through passive training.
- Offline training progresses after rejoin.
- Squad can be created with Alpha and Bravo fireteams.
- Auto Resolve mission can produce rewards, injuries, or KIA.
- Wounded unit enters recovery and returns to Available.
- KIA unit cannot be assigned again.
- Territory can change owner after victory.

## Boundaries

Always:

- Keep MVP scope small.
- Preserve `branch` field even while Army is the only branch.
- Treat server as source of truth.
- Save before relying on permanent unit progression.
- Keep game systems data-driven where possible.
- Keep real military references abstracted for gameplay.

Ask first:

- Add paid Robux boosts.
- Add new branches.
- Add multiplayer shared bases.
- Add realistic weapon names or real unit names.
- Change DataStore schema after release.
- Add dependencies or external packages.

Never:

- Store secrets in repo.
- Make client authoritative for resources, ranks, mission results, or DataStore.
- Remove KIA permanence without changing the design.
- Build detailed real-world tactical instruction content.
- Commit `.rbxl` / `.rbxlx` as the main source of truth unless explicitly requested.

## Success Criteria

The MVP spec is satisfied when:

- A player can build a small base.
- A player can recruit and train permanent Army AI units.
- A player can form one squad with Alpha and Bravo fireteams.
- A player can launch one territory mission.
- Auto Resolve can complete the mission.
- Mission outcome updates resources, XP, injuries, KIA, and territory state.
- Data persists across leave/rejoin.
- The structure can add more branches without rewriting unit data.

## Open Questions

- What is the visual tone: realistic military base, stylized Roblox toy soldiers, or low-poly strategy map?
- Should Field Command be third-person shooter style, top-down command style, or mixed?
- Should injury reduce stats permanently later?
- Should KIA have a memorial/history UI?
- What should the first territory be called?
- What active training mini-game should be built first?
