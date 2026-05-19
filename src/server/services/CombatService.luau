local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Combat = require(ReplicatedStorage.Shared.config.Combat)
local Enemies = require(ReplicatedStorage.Shared.config.Enemies)
local Ranks = require(ReplicatedStorage.Shared.config.Ranks)
local Roles = require(ReplicatedStorage.Shared.config.Roles)
local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)

local CombatService = {}

function CombatService:Init(services)
	self.services = services
end

function CombatService:Start()
	print("[CombatService] ready")
end

function CombatService:GetUnitPower(unit): number
	local role = Roles[unit.role] or Roles.Rifleman
	local rank = Ranks[unit.rank] or Ranks.Citizen
	local rankBonus = rank.order or 0

	return (role.combatPower or 1) + rankBonus
end

function CombatService:GetSquadPower(context): number
	local power = 0

	for _, unit in ipairs(context.units) do
		if unit.status == Statuses.Assigned or unit.status == Statuses.InMission then
			power += self:GetUnitPower(unit)
		end
	end

	local tactic = Combat.tactics[context.tactic] or Combat.tactics.FrontalAssault
	local terrainBonus = 1
	if tactic.terrainBonus and context.territory then
		terrainBonus = tactic.terrainBonus[context.territory.terrain] or 1
	end

	local commandBonus = 1 + math.clamp(context.commandScore or 0, -3, 8) * 0.04

	return power * (tactic.powerMultiplier or 1) * terrainBonus * commandBonus
end

function CombatService:GetEnemyPower(context): number
	local enemy = Enemies.Raider
	if context.territory and context.territory.enemyTier and context.territory.enemyTier >= 2 then
		enemy = Enemies.OrganizedRaider
	end

	local difficulty = if context.territory then context.territory.difficulty else 1
	local unitCount = math.max(1, #context.units)

	return (enemy.power + difficulty) * unitCount
end

function CombatService:GetWinChance(squadPower: number, enemyPower: number): number
	local rawChance = squadPower / math.max(1, squadPower + enemyPower)
	return math.clamp(rawChance, Combat.winChance.min, Combat.winChance.max)
end

function CombatService:RollUnitResult(victory: boolean, tacticId: string)
	local tactic = Combat.tactics[tacticId] or Combat.tactics.FrontalAssault
	local casualtyMultiplier = tactic.casualtyMultiplier or 1
	local injuryChance = (if victory then 0.15 else 0.35) * casualtyMultiplier
	local kiaChance = (if victory then 0.03 else 0.12) * casualtyMultiplier
	local roll = math.random()

	if roll <= kiaChance then
		return {
			xp = if victory then 12 else 6,
			status = Statuses.KIA,
			injury = {
				severity = "KIA",
			},
		}
	end

	if roll <= injuryChance then
		local severity = if victory then "Light" else "Moderate"
		return {
			xp = if victory then 10 else 5,
			status = Statuses.Wounded,
			injury = {
				severity = severity,
				recoverySeconds = Combat.injuryRecoverySeconds[severity],
			},
		}
	end

	return {
		xp = if victory then 12 else 4,
		status = Statuses.Assigned,
		injury = nil,
	}
end

function CombatService:ResolveAuto(context)
	local squadPower = self:GetSquadPower(context)
	local enemyPower = self:GetEnemyPower(context)
	local winChance = self:GetWinChance(squadPower, enemyPower)
	local victory = math.random() <= winChance
	local unitResults = {}

	for _, unit in ipairs(context.units) do
		unitResults[unit.id] = self:RollUnitResult(victory, context.tactic)
	end

	return {
		victory = victory,
		rewards = if victory and context.territory then context.territory.rewards else {
			cash = 0,
			supplies = 0,
		},
		unitResults = unitResults,
		territoryCaptured = victory,
		stats = {
			squadPower = squadPower,
			enemyPower = enemyPower,
			winChance = winChance,
		},
	}
end

return CombatService
