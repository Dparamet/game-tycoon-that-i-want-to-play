local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteRegistry = require(ReplicatedStorage.Shared.net.RemoteRegistry)
local Remotes = require(ReplicatedStorage.Shared.constants.Remotes)

local RemoteService = {}

function RemoteService:Init(services)
	self.services = services
end

function RemoteService:Start()
	RemoteRegistry.ensureAll()
	self.requestRemote = RemoteRegistry.ensureRemoteEvent(Remotes.RequestAction)
	self.snapshotRemote = RemoteRegistry.ensureRemoteEvent(Remotes.StateSnapshot)

	self.requestRemote.OnServerEvent:Connect(function(player, request)
		self:HandleRequest(player, request)
	end)

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self:SendSnapshot(player)
		end)
	end)

	print("[RemoteService] ready")
end

function RemoteService:SendSnapshot(player: Player)
	local snapshot = self.services.DataService:GetSnapshot(player)
	self.snapshotRemote:FireClient(player, snapshot)
end

function RemoteService:HandleRequest(player: Player, request)
	if type(request) ~= "table" or type(request.action) ~= "string" then
		return
	end

	local payload = if type(request.payload) == "table" then request.payload else {}
	local action = request.action
	local ok = false

	if action == "GetSnapshot" then
		ok = true
	elseif action == "CreateCitizen" then
		ok = self.services.UnitService:CreateCitizen(player) ~= nil
	elseif action == "BuyBuilding" then
		ok = self.services.BaseService:BuyBuilding(player, payload.buildingId)
	elseif action == "UpgradeCommandCenter" then
		ok = self.services.BaseService:UpgradeCommandCenter(player)
	elseif action == "StartTraining" then
		ok = self.services.TrainingService:StartTraining(player, payload.unitId, payload.courseId or "BasicArmyTraining", payload.mode or "Passive")
	elseif action == "ProcessTraining" then
		ok = self.services.TrainingService:Process(player) >= 0
	elseif action == "CreateSquad" then
		ok = self.services.SquadService:CreateSquad(player, payload.name) ~= nil
	elseif action == "AssignUnit" then
		ok = self.services.SquadService:AssignUnit(player, payload.squadId, payload.fireteamId or "Alpha", payload.unitId)
	elseif action == "StartAutoMission" then
		ok = self.services.MissionService:StartAutoMission(player, payload.territoryId or "Outskirts", payload.squadId, payload.tactic or "FrontalAssault") ~= nil
	elseif action == "StartFieldMission" then
		ok = self.services.MissionService:StartFieldMission(player, payload.territoryId or "Outskirts", payload.squadId, payload.tactic or "FrontalAssault") ~= nil
	elseif action == "FieldCommand" then
		ok = self.services.MissionService:IssueFieldCommand(player, payload.fireteamId or "Alpha", payload.command or "Move")
	elseif action == "CompleteFieldMission" then
		ok = self.services.MissionService:CompleteFieldMission(player) ~= nil
	elseif action == "StartRecovery" then
		ok = self.services.RecoveryService:StartRecovery(player, payload.unitId)
	end

	if not ok then
		warn(string.format("[RemoteService] rejected action %s for %s", action, player.Name))
	end

	self:SendSnapshot(player)
end

return RemoteService
