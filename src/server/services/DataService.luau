local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Combat = require(ReplicatedStorage.Shared.config.Combat)
local Territories = require(ReplicatedStorage.Shared.config.Territories)

local DataService = {}

DataService.VERSION = 1

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[key] = deepCopy(child)
	end

	return copy
end

function DataService:Init(services)
	self.services = services
	self.profiles = {}
	self.dirty = {}
end

function DataService:Start()
	Players.PlayerAdded:Connect(function(player)
		self:Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:Release(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:Load(player)
	end

	print("[DataService] ready")
end

function DataService:CreateTerritoryStates()
	local states = {}

	for territoryId, territory in pairs(Territories) do
		states[territoryId] = {
			id = territory.id,
			owner = territory.owner,
			unlocked = territory.difficulty == 1,
			capturedAt = nil,
			threatLevel = territory.difficulty,
		}
	end

	return states
end

function DataService:CreateDefaultData()
	return {
		version = self.VERSION,
		resources = {
			cash = 500,
			supplies = 100,
		},
		base = {
			commandCenterLevel = 1,
			buildings = {
				CommandCenter = {
					id = "CommandCenter",
					level = 1,
					purchasedAt = os.time(),
				},
				CashGenerator = {
					id = "CashGenerator",
					level = 1,
					purchasedAt = os.time(),
				},
			},
		},
		units = {},
		squads = {},
		territories = self:CreateTerritoryStates(),
		trainingQueue = {},
		recoveryQueue = {},
		lastLogoutTime = os.time(),
	}
end

function DataService:Load(player: Player)
	if self.profiles[player.UserId] then
		return self.profiles[player.UserId]
	end

	local data = self:CreateDefaultData()
	self.profiles[player.UserId] = data
	self.dirty[player.UserId] = false

	self:ProcessOfflineProgress(player, data, os.time())

	print(string.format("[DataService] loaded default profile for %s", player.Name))

	return data
end

function DataService:Get(player: Player)
	return self.profiles[player.UserId] or self:Load(player)
end

function DataService:Update(player: Player, mutator)
	local data = self:Get(player)
	mutator(data)
	self.dirty[player.UserId] = true
	return data
end

function DataService:GetSnapshot(player: Player)
	return deepCopy(self:Get(player))
end

function DataService:IsDirty(player: Player): boolean
	return self.dirty[player.UserId] == true
end

function DataService:MarkClean(player: Player)
	self.dirty[player.UserId] = false
end

function DataService:ProcessOfflineProgress(player: Player, data, now: number)
	local elapsed = math.clamp(now - (data.lastLogoutTime or now), 0, Combat.offlineCapSeconds)
	if elapsed <= 0 then
		return
	end

	if self.services and self.services.TrainingService then
		self.services.TrainingService:Process(player, now)
	end

	if self.services and self.services.RecoveryService then
		self.services.RecoveryService:Process(player, now)
	end
end

function DataService:Release(player: Player)
	local data = self.profiles[player.UserId]
	if not data then
		return
	end

	data.lastLogoutTime = os.time()
	self.profiles[player.UserId] = nil
	self.dirty[player.UserId] = nil

	print(string.format("[DataService] released profile for %s", player.Name))
end

return DataService
