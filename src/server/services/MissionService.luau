local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)

local MissionService = {}

function MissionService:Init(services)
	self.services = services
	self.activeFieldMissions = {}
end

function MissionService:Start()
	print("[MissionService] ready")
end

function MissionService:GetSquadUnits(player: Player, squad)
	local units = {}

	for _, unitId in ipairs(squad.memberUnitIds) do
		local unit = self.services.UnitService:GetUnit(player, unitId)
		if unit then
			table.insert(units, unit)
		end
	end

	return units
end

function MissionService:CanLaunchSquad(units): boolean
	if #units == 0 then
		return false
	end

	for _, unit in ipairs(units) do
		if unit.status ~= Statuses.Assigned then
			return false
		end
	end

	return true
end

function MissionService:SetUnitsStatus(player: Player, units, status: string)
	self.services.DataService:Update(player, function(data)
		for _, unit in ipairs(units) do
			local target = data.units[unit.id]
			if target and target.status ~= Statuses.KIA then
				target.status = status
				target.updatedAt = os.time()
			end
		end
	end)
end

function MissionService:ApplyUnitResults(player: Player, result)
	local now = os.time()

	for unitId, unitResult in pairs(result.unitResults) do
		self.services.UnitService:AddXP(player, unitId, unitResult.xp)

		if unitResult.status == Statuses.KIA then
			self.services.UnitService:MarkKIA(player, unitId)
		elseif unitResult.status == Statuses.Wounded then
			local injury = unitResult.injury
			self.services.UnitService:ApplyInjury(player, unitId, {
				severity = injury.severity,
				startedAt = now,
				recoveryEndsAt = now + injury.recoverySeconds,
				health = 50,
			})
		else
			self.services.UnitService:SetStatus(player, unitId, Statuses.Assigned)
		end
	end
end

function MissionService:StartAutoMission(player: Player, territoryId: string, squadId: string, tactic: string)
	if not self.services.TerritoryService:IsAvailable(player, territoryId) then
		return nil
	end

	local squad = self.services.SquadService:GetSquad(player, squadId)
	local territory = self.services.TerritoryService:GetConfig(territoryId)
	if not squad or not territory then
		return nil
	end

	local units = self:GetSquadUnits(player, squad)
	if not self:CanLaunchSquad(units) then
		return nil
	end

	self:SetUnitsStatus(player, units, Statuses.InMission)

	local result = self.services.CombatService:ResolveAuto({
		territory = territory,
		squad = squad,
		units = units,
		tactic = tactic or squad.tactic,
	})

	self:ApplyUnitResults(player, result)

	if result.victory then
		self.services.EconomyService:Add(player, result.rewards)
		self.services.TerritoryService:Capture(player, territoryId)
	end

	return result
end

function MissionService:StartFieldMission(player: Player, territoryId: string, squadId: string, tactic: string)
	if self.activeFieldMissions[player.UserId] then
		return nil
	end

	if not self.services.TerritoryService:IsAvailable(player, territoryId) then
		return nil
	end

	local squad = self.services.SquadService:GetSquad(player, squadId)
	local territory = self.services.TerritoryService:GetConfig(territoryId)
	if not squad or not territory then
		return nil
	end

	local units = self:GetSquadUnits(player, squad)
	if not self:CanLaunchSquad(units) then
		return nil
	end

	self:SetUnitsStatus(player, units, Statuses.InMission)

	local session = {
		id = string.format("field_%d_%d", player.UserId, os.time()),
		territoryId = territoryId,
		squadId = squadId,
		tactic = tactic or squad.tactic,
		startedAt = os.time(),
		commands = {
			Alpha = "Follow",
			Bravo = "Follow",
		},
		commandScore = 0,
	}

	self.activeFieldMissions[player.UserId] = session
	self.services.WorldService:BuildFieldArena(player, session, units)

	return session
end

function MissionService:IssueFieldCommand(player: Player, fireteamId: string, command: string): boolean
	local session = self.activeFieldMissions[player.UserId]
	if not session then
		return false
	end

	if fireteamId ~= "Alpha" and fireteamId ~= "Bravo" then
		return false
	end

	local validCommands = {
		Move = 1,
		Attack = 2,
		Hold = 1,
		Suppress = 2,
		Retreat = -1,
		Rally = 1,
	}

	local score = validCommands[command]
	if not score then
		return false
	end

	session.commands[fireteamId] = command
	session.commandScore += score
	self.services.WorldService:UpdateFieldCommandMarker(player, fireteamId, command)

	return true
end

function MissionService:CompleteFieldMission(player: Player)
	local session = self.activeFieldMissions[player.UserId]
	if not session then
		return nil
	end

	local squad = self.services.SquadService:GetSquad(player, session.squadId)
	local territory = self.services.TerritoryService:GetConfig(session.territoryId)
	if not squad or not territory then
		return nil
	end

	local units = self:GetSquadUnits(player, squad)
	local result = self.services.CombatService:ResolveAuto({
		territory = territory,
		squad = squad,
		units = units,
		tactic = session.tactic,
		commandScore = session.commandScore,
	})

	self:ApplyUnitResults(player, result)

	if result.victory then
		self.services.EconomyService:Add(player, result.rewards)
		self.services.TerritoryService:Capture(player, session.territoryId)
	end

	self.activeFieldMissions[player.UserId] = nil
	self.services.WorldService:ClearFieldArena(player)

	return result
end

return MissionService
