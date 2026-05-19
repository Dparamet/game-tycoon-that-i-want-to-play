local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Combat = require(ReplicatedStorage.Shared.config.Combat)
local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)

local RecoveryService = {}

function RecoveryService:Init(services)
	self.services = services
end

function RecoveryService:Start()
	print("[RecoveryService] ready")
end

function RecoveryService:StartRecovery(player: Player, unitId: string): boolean
	if not self.services.BaseService:HasBuilding(player, "MedicalTent") then
		return false
	end

	local unit = self.services.UnitService:GetUnit(player, unitId)
	if not unit or unit.status ~= Statuses.Wounded or not unit.injury then
		return false
	end

	local severity = unit.injury.severity
	local recoverySeconds = Combat.injuryRecoverySeconds[severity]
	if not recoverySeconds then
		return false
	end

	local now = os.time()
	local recoveryEndsAt = now + recoverySeconds

	self.services.DataService:Update(player, function(data)
		local target = data.units[unitId]
		target.status = Statuses.Recovering
		target.injury.recoveryEndsAt = recoveryEndsAt
		target.updatedAt = now

		data.recoveryQueue[unitId] = {
			unitId = unitId,
			startedAt = now,
			endsAt = recoveryEndsAt,
			severity = severity,
		}
	end)

	return true
end

function RecoveryService:CompleteRecovery(player: Player, unitId: string, now: number): boolean
	local data = self.services.DataService:Get(player)
	local job = data.recoveryQueue[unitId]
	local unit = data.units[unitId]

	if not job or not unit or unit.status ~= Statuses.Recovering or job.endsAt > now then
		return false
	end

	self.services.DataService:Update(player, function(updatedData)
		local target = updatedData.units[unitId]
		target.status = Statuses.Available
		target.health = 100
		target.injury = nil
		target.updatedAt = now
		updatedData.recoveryQueue[unitId] = nil
	end)

	return true
end

function RecoveryService:Process(player: Player, now: number?)
	local processTime = now or os.time()
	local data = self.services.DataService:Get(player)
	local completed = 0

	for unitId in pairs(data.recoveryQueue) do
		if self:CompleteRecovery(player, unitId, processTime) then
			completed += 1
		end
	end

	return completed
end

return RecoveryService
