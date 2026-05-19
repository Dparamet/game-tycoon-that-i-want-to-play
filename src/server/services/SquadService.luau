local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Id = require(ReplicatedStorage.Shared.util.Id)
local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)

local SquadService = {}

local FIRETEAM_IDS = {
	"Alpha",
	"Bravo",
}

function SquadService:Init(services)
	self.services = services
end

function SquadService:Start()
	print("[SquadService] ready")
end

function SquadService:CreateSquad(player: Player, name: string?)
	local squadId = Id.create("squad")
	local squadName = name or "1st Squad"

	local squad = {
		id = squadId,
		name = squadName,
		branch = "Army",
		echelon = "Squad",
		commanderUnitId = nil,
		tactic = "FrontalAssault",
		fireteams = {
			Alpha = {
				id = "Alpha",
				name = "Alpha Fireteam",
				leaderUnitId = nil,
				memberUnitIds = {},
				currentCommand = "Follow",
			},
			Bravo = {
				id = "Bravo",
				name = "Bravo Fireteam",
				leaderUnitId = nil,
				memberUnitIds = {},
				currentCommand = "Follow",
			},
		},
		memberUnitIds = {},
		readiness = 0,
	}

	self.services.DataService:Update(player, function(data)
		data.squads[squadId] = squad
	end)

	return squad
end

function SquadService:GetSquad(player: Player, squadId: string)
	local data = self.services.DataService:Get(player)
	return data.squads[squadId]
end

function SquadService:IsValidFireteam(fireteamId: string): boolean
	for _, validFireteamId in ipairs(FIRETEAM_IDS) do
		if validFireteamId == fireteamId then
			return true
		end
	end

	return false
end

function SquadService:HasMember(squad, unitId: string): boolean
	for _, memberUnitId in ipairs(squad.memberUnitIds) do
		if memberUnitId == unitId then
			return true
		end
	end

	return false
end

function SquadService:CalculateReadiness(player: Player, squad): number
	local total = 0
	local ready = 0

	for _, unitId in ipairs(squad.memberUnitIds) do
		total += 1
		local unit = self.services.UnitService:GetUnit(player, unitId)
		if unit and unit.status == Statuses.Assigned then
			ready += 1
		end
	end

	if total == 0 then
		return 0
	end

	return math.floor((ready / total) * 100)
end

function SquadService:AssignUnit(player: Player, squadId: string, fireteamId: string, unitId: string): boolean
	if not self:IsValidFireteam(fireteamId) then
		return false
	end

	local squad = self:GetSquad(player, squadId)
	local unit = self.services.UnitService:GetUnit(player, unitId)
	if not squad or not unit or unit.status ~= Statuses.Available then
		return false
	end

	if self:HasMember(squad, unitId) then
		return false
	end

	self.services.DataService:Update(player, function(data)
		local targetSquad = data.squads[squadId]
		local targetFireteam = targetSquad.fireteams[fireteamId]
		local targetUnit = data.units[unitId]

		table.insert(targetSquad.memberUnitIds, unitId)
		table.insert(targetFireteam.memberUnitIds, unitId)

		if not targetFireteam.leaderUnitId then
			targetFireteam.leaderUnitId = unitId
		end

		if not targetSquad.commanderUnitId then
			targetSquad.commanderUnitId = unitId
		end

		targetUnit.status = Statuses.Assigned
		targetUnit.squadId = squadId
		targetUnit.fireteamId = fireteamId
		targetUnit.updatedAt = os.time()

		targetSquad.readiness = self:CalculateReadiness(player, targetSquad)
	end)

	return true
end

function SquadService:SetCommander(player: Player, squadId: string, unitId: string): boolean
	local squad = self:GetSquad(player, squadId)
	if not squad or not self:HasMember(squad, unitId) then
		return false
	end

	self.services.DataService:Update(player, function(data)
		data.squads[squadId].commanderUnitId = unitId
	end)

	return true
end

function SquadService:GetReadiness(player: Player, squadId: string): number
	local squad = self:GetSquad(player, squadId)
	if not squad then
		return 0
	end

	return self:CalculateReadiness(player, squad)
end

return SquadService
