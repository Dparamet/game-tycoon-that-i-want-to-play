# Playtest Guide: MVP Command Shell

## Build

```powershell
rojo build -o "game tycoon that i want to play.rbxlx"
```

## Run

```powershell
rojo serve
```

Open Roblox Studio, connect Rojo, then start Play Solo.

For save/load testing, enable Studio API access:

```text
Game Settings
→ Security
→ Enable Studio Access to API Services
```

## First Flow

Start like a tycoon:

1. Walk around the base.
2. Follow the roads and labeled zones.
3. Use green `BUY` pads with `ProximityPrompt`.
4. Grey pads are locked until Command Center level is high enough.
5. Start with `Recruitment Office` or `Training Ground`.
6. Use the blue `UPGRADE COMMAND` pad to unlock higher-tier buildings.
7. Use GUI actions for debug/control while the world pads drive tycoon progression.

Suggested first test:

1. Buy `Recruitment Office`.
2. Buy `Training Ground`.
3. Use the `COLLECT CASH` pad or `Claim Income` if short on Cash.
4. `Recruit Citizen`
5. `Start Basic Training`
6. Wait `60` seconds.
7. `Process Training` or `Process All Timers`
8. Buy/upgrade toward `Barracks`.
9. `Create Squad`
10. `Assign To Alpha`
11. `Run Auto Mission`

Expected:

- Cash and Supplies update.
- Roster shows unit rank/status/XP.
- Top bar shows `OK` / `NO` action feedback.
- Territory owner can change to `Player` after victory.
- Unit may become `Wounded` or `KIA`.
- Purchased buildings appear in the world.
- Unpurchased unlocked buildings show green tycoon buy pads.
- Locked buildings show grey tycoon pads.
- The base has roads, fences, zones, a mission gate, and a cash collector platform.
- The cash collector platform can be triggered with `ProximityPrompt`.
- Capturing a territory unlocks the next difficulty territory.

## Recovery Flow

If a unit becomes `Wounded`:

1. Upgrade Command Center until Medical Tent unlocks.
2. `Buy Medical Tent`
3. `Start Recovery`
4. Wait for recovery time, then use `Process Recovery` or `Process All Timers`

Expected:

- Wounded unit changes to `Recovering`.
- Later recovery processing returns unit to `Available`.

## Field Command Flow

After creating a squad and assigning units:

1. `Start Field Mission`
2. Use Alpha / Bravo buttons:
   - `Move`
   - `Attack`
   - `Hold`
   - `Suppress`
   - `Retreat`
   - `Rally`
3. `Complete Field Mission`

Expected:

- A field arena appears to the side of the base.
- Dummy soldier models spawn for assigned Alpha / Bravo units.
- Soldier models move when fireteam commands are issued.
- Enemy dummy models have health bars.
- Enemy dummy models take damage and move toward cover on `Attack` / `Suppress`.
- Soldier dummy models have health bars.
- Enemy counter-fire damages commanded fireteams.
- Alpha / Bravo markers change color when commands are issued.
- Better command score improves mission odds.
- Completing the field mission clears the arena, applies rewards/injuries/KIA, and opens a result panel.

## Mission Result Panel

After `Run Auto Mission` or `Complete Field Mission`, the UI shows:

- victory / failure.
- Cash and Supplies rewards.
- total XP.
- Wounded / KIA count.
- territory capture status.
- per-unit result summary.

## UI Toggle

- Use `Hide UI` on the top bar to hide action panels.
- Use `Show UI` to bring them back.
- Action and Field Command panels are scrollable.
- Panels are compact so the center of the screen stays playable.

## Save Test

1. Enable API Services in Studio.
2. Make progress.
3. Click `Manual Save`.
4. Stop Play Solo.
5. Start Play Solo again.

Expected:

- Top bar shows save feedback.
- Resources, buildings, units, squads, territories, training, and recovery data load back.

## Current Limits

- GUI is MVP/debug UI, not final art.
- Base models are blockout placeholders.
- Blockout objects are positioned above the default `Baseplate`.
- DataStore is enabled, but Studio save/load needs API Services enabled.
- Field Command uses blockout dummy movement, simple health bars, and enemy reactions, not full combat AI/pathfinding yet.
- Tycoon map/blockout exists, but product priority is now MVP systems first.
