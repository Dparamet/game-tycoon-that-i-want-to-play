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

## First Flow

Use the left-side GUI:

1. `Recruit Citizen`
2. `Buy Training Ground`
3. `Start Basic Training`
4. Wait `60` seconds.
5. `Process Training`
6. `Create Squad`
7. `Assign To Alpha`
8. `Run Auto Mission`

Expected:

- Cash and Supplies update.
- Roster shows unit rank/status/XP.
- Territory owner can change to `Player` after victory.
- Unit may become `Wounded` or `KIA`.

## Recovery Flow

If a unit becomes `Wounded`:

1. Upgrade Command Center until Medical Tent unlocks.
2. `Buy Medical Tent`
3. `Start Recovery`

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
- Alpha / Bravo markers change color when commands are issued.
- Better command score improves mission odds.
- Completing the field mission clears the arena and applies rewards/injuries/KIA.

## UI Toggle

- Use `Hide UI` on the top bar to hide action panels.
- Use `Show UI` to bring them back.

## Current Limits

- GUI is MVP/debug UI, not final art.
- Base models are blockout placeholders.
- DataStore is not enabled yet.
- Field Command uses blockout dummy movement and simple enemy reactions, not full combat AI/pathfinding yet.
