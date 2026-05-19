local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Id = require(ReplicatedStorage.Shared.util.Id)
local Statuses = require(ReplicatedStorage.Shared.constants.Statuses)
local TrainingCourses = require(ReplicatedStorage.Shared.config.TrainingCourses)

local TrainingService = {}

function TrainingService:Init(services)
	self.services = services
end

function TrainingService:Start()
	print("[TrainingService] ready")
end

function TrainingService:StartTraining(player: Player, unitId: string, courseId: string, mode: string): boolean
	local course = TrainingCourses[courseId]
	if not course then
		return false
	end

	if not self.services.BaseService:HasBuilding(player, "TrainingGround") then
		return false
	end

	local unit = self.services.UnitService:GetUnit(player, unitId)
	if not unit or unit.rank ~= course.inputRank or unit.status ~= Statuses.Available then
		return false
	end

	if not self.services.EconomyService:Spend(player, course.cost) then
		return false
	end

	local now = os.time()
	local jobId = Id.create("training")

	self.services.DataService:Update(player, function(data)
		data.trainingQueue[jobId] = {
			id = jobId,
			unitId = unitId,
			courseId = courseId,
			mode = mode or "Passive",
			startedAt = now,
			endsAt = now + course.durationSeconds,
			boostMultiplier = 1,
		}

		data.units[unitId].status = Statuses.Training
		data.units[unitId].updatedAt = now
	end)

	return true
end

function TrainingService:CompleteJob(player: Player, jobId: string, now: number): boolean
	local data = self.services.DataService:Get(player)
	local job = data.trainingQueue[jobId]
	if not job or job.endsAt > now then
		return false
	end

	local course = TrainingCourses[job.courseId]
	local unit = data.units[job.unitId]
	if not course or not unit or unit.status ~= Statuses.Training then
		return false
	end

	self.services.DataService:Update(player, function(updatedData)
		local target = updatedData.units[job.unitId]
		target.rank = course.outputRank
		target.status = Statuses.Available
		target.updatedAt = now
		updatedData.trainingQueue[jobId] = nil
	end)

	self.services.UnitService:AddXP(player, job.unitId, course.rewardXP)

	return true
end

function TrainingService:Process(player: Player, now: number?)
	local processTime = now or os.time()
	local data = self.services.DataService:Get(player)
	local completed = 0

	for jobId in pairs(data.trainingQueue) do
		if self:CompleteJob(player, jobId, processTime) then
			completed += 1
		end
	end

	return completed
end

return TrainingService
