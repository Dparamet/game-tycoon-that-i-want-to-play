local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Id = require(ReplicatedStorage.Shared.util.Id)
local Ranks = require(ReplicatedStorage.Shared.config.Ranks)
local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)

local UnitService = {}

local blockedStatuses = {
	[Statuses.InMission] = true,
	[Statuses.Wounded] = true,
	[Statuses.Recovering] = true,
	[Statuses.KIA] = true,
}

function UnitService:Init(services)
	self.services = services
end

function UnitService:Start()
	print("[UnitService] ready")
end

function UnitService:GetUnit(player: Player, unitId: string)
	local data = self.services.DataService:Get(player)
	return data.units[unitId]
end

function UnitService:CanUseUnit(player: Player, unitId: string): boolean
	local unit = self:GetUnit(player, unitId)
	if not unit then
		return false
	end

	return not blockedStatuses[unit.status]
end

function UnitService:CreateCitizen(player: Player)
	local unitId = Id.create("unit")
	local now = os.time()
	local unit = {
		id = unitId,
		name = "Citizen",
		branch = "Army",
		rank = "Citizen",
		role = "Rifleman",
		status = Statuses.Available,
		xp = 0,
		health = 100,
		injury = nil,
		createdAt = now,
		updatedAt = now,
	}

	self.services.DataService:Update(player, function(data)
		data.units[unitId] = unit
	end)

	return unit
end

function UnitService:SetStatus(player: Player, unitId: string, status: string): boolean
	local unit = self:GetUnit(player, unitId)
	if not unit or unit.status == Statuses.KIA then
		return false
	end

	self.services.DataService:Update(player, function(data)
		local target = data.units[unitId]
		target.status = status
		target.updatedAt = os.time()
	end)

	return true
end

function UnitService:GetRankAfterXP(rank: string, xp: number): string
	local currentRank = rank

	while true do
		local rankConfig = Ranks[currentRank]
		if not rankConfig or not rankConfig.nextRank then
			return currentRank
		end

		local nextConfig = Ranks[rankConfig.nextRank]
		if not nextConfig or xp < nextConfig.minXP then
			return currentRank
		end

		currentRank = rankConfig.nextRank
	end
end

function UnitService:AddXP(player: Player, unitId: string, amount: number): boolean
	local unit = self:GetUnit(player, unitId)
	if not unit or unit.status == Statuses.KIA then
		return false
	end

	local safeAmount = math.max(0, amount)

	self.services.DataService:Update(player, function(data)
		local target = data.units[unitId]
		target.xp += safeAmount
		target.rank = self:GetRankAfterXP(target.rank, target.xp)
		target.updatedAt = os.time()
	end)

	return true
end

function UnitService:ApplyInjury(player: Player, unitId: string, injury): boolean
	local unit = self:GetUnit(player, unitId)
	if not unit or unit.status == Statuses.KIA then
		return false
	end

	if injury.severity == "KIA" then
		return self:MarkKIA(player, unitId)
	end

	self.services.DataService:Update(player, function(data)
		local target = data.units[unitId]
		target.status = Statuses.Wounded
		target.health = math.max(1, injury.health or target.health or 1)
		target.injury = {
			severity = injury.severity,
			startedAt = injury.startedAt or os.time(),
			recoveryEndsAt = injury.recoveryEndsAt,
			statPenalty = injury.statPenalty,
		}
		target.updatedAt = os.time()
	end)

	return true
end

function UnitService:MarkKIA(player: Player, unitId: string): boolean
	local unit = self:GetUnit(player, unitId)
	if not unit then
		return false
	end

	self.services.DataService:Update(player, function(data)
		local target = data.units[unitId]
		target.status = Statuses.KIA
		target.health = 0
		target.injury = {
			severity = "KIA",
			startedAt = os.time(),
			recoveryEndsAt = nil,
		}
		target.squadId = nil
		target.fireteamId = nil
		target.updatedAt = os.time()
	end)

	return true
end

return UnitService
