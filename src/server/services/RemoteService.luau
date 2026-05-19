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
	self.resultRemote = RemoteRegistry.ensureRemoteEvent(Remotes.MissionResult)
	self.actionResultRemote = RemoteRegistry.ensureRemoteEvent(Remotes.ActionResult)

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

function RemoteService:GetFailureReason(player: Player, action: string, payload): string
	if action == "CreateCitizen" then
		if not self.services.BaseService:HasBuilding(player, "RecruitmentOffice") then
			return "Need Recruitment Office"
		end
		return "Need Cash 25"
	elseif action == "BuyBuilding" then
		return "Cannot buy building yet"
	elseif action == "UpgradeCommandCenter" then
		return "Need more Cash/Supplies or max level reached"
	elseif action == "StartTraining" then
		return "Need available Citizen, Training Ground, and Cash 50"
	elseif action == "CreateSquad" then
		return "Cannot create squad"
	elseif action == "AssignUnit" then
		return "Need available unit and squad"
	elseif action == "StartAutoMission" or action == "StartFieldMission" then
		return "Need assigned squad and available territory"
	elseif action == "CompleteFieldMission" then
		return "No active field mission"
	elseif action == "StartRecovery" then
		return "Need Wounded unit and Medical Tent"
	elseif action == "ProcessRecovery" then
		return "No recovery progress ready"
	elseif action == "ProcessAll" then
		return "No timers ready"
	elseif action == "ManualSave" then
		return "Save failed"
	end

	return "Action failed"
end

function RemoteService:SendActionResult(player: Player, action: string, ok: boolean, message: string?)
	local resultMessage = message
	if not resultMessage then
		resultMessage = if ok then "Done" else "Failed"
	end

	self.actionResultRemote:FireClient(player, {
		action = action,
		ok = ok,
		message = resultMessage,
	})
end

function RemoteService:HandleRequest(player: Player, request)
	if type(request) ~= "table" or type(request.action) ~= "string" then
		return
	end

	local payload = if type(request.payload) == "table" then request.payload else {}
	local action = request.action
	local ok = false
	local result = nil

	if action == "GetSnapshot" then
		ok = true
	elseif action == "ManualSave" then
		ok = self.services.DataService:Save(player)
	elseif action == "ClaimIncome" then
		ok = self.services.EconomyService:ClaimIncome(player)
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
	elseif action == "ProcessRecovery" then
		ok = self.services.RecoveryService:Process(player) >= 0
	elseif action == "ProcessAll" then
		self.services.TrainingService:Process(player)
		self.services.RecoveryService:Process(player)
		ok = true
	elseif action == "CreateSquad" then
		ok = self.services.SquadService:CreateSquad(player, payload.name) ~= nil
	elseif action == "AssignUnit" then
		ok = self.services.SquadService:AssignUnit(player, payload.squadId, payload.fireteamId or "Alpha", payload.unitId)
	elseif action == "StartAutoMission" then
		result = self.services.MissionService:StartAutoMission(player, payload.territoryId or "Outskirts", payload.squadId, payload.tactic or "FrontalAssault")
		ok = result ~= nil
	elseif action == "StartFieldMission" then
		ok = self.services.MissionService:StartFieldMission(player, payload.territoryId or "Outskirts", payload.squadId, payload.tactic or "FrontalAssault") ~= nil
	elseif action == "FieldCommand" then
		ok = self.services.MissionService:IssueFieldCommand(player, payload.fireteamId or "Alpha", payload.command or "Move")
	elseif action == "CompleteFieldMission" then
		result = self.services.MissionService:CompleteFieldMission(player)
		ok = result ~= nil
	elseif action == "StartRecovery" then
		ok = self.services.RecoveryService:StartRecovery(player, payload.unitId)
	end

	if not ok then
		warn(string.format("[RemoteService] rejected action %s for %s", action, player.Name))
		self:SendActionResult(player, action, false, self:GetFailureReason(player, action, payload))
	elseif result then
		self:SendActionResult(player, action, true, "Mission resolved")
		self.resultRemote:FireClient(player, result)
	else
		self:SendActionResult(player, action, true, "Done")
	end

	if ok and self.services.WorldService then
		self.services.WorldService:RefreshBase(player)
	end

	self:SendSnapshot(player)
end

return RemoteService
