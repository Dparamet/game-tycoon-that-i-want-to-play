local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Combat = require(ReplicatedStorage.Shared.config.Combat)
local Territories = require(ReplicatedStorage.Shared.config.Territories)

local DataService = {}

DataService.VERSION = 1
DataService.STORE_NAME = "MilitaryStrategyTycoon_v1"
DataService.AUTOSAVE_SECONDS = 60

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
	self.store = DataStoreService:GetDataStore(self.STORE_NAME)
	self.profiles = {}
	self.dirty = {}
	self.loadFailed = {}
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

	task.spawn(function()
		while true do
			task.wait(self.AUTOSAVE_SECONDS)
			self:Autosave()
		end
	end)

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
			cash = 220,
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

function DataService:GetKey(player: Player): string
	return "player_" .. player.UserId
end

function DataService:MergeDefaults(data)
	local defaultData = self:CreateDefaultData()

	for key, value in pairs(defaultData) do
		if data[key] == nil or (type(value) == "table" and type(data[key]) ~= "table") then
			data[key] = deepCopy(value)
		end
	end

	for key, value in pairs(defaultData.resources) do
		if data.resources[key] == nil then
			data.resources[key] = value
		end
	end

	for key, value in pairs(defaultData.base) do
		if data.base[key] == nil then
			data.base[key] = deepCopy(value)
		end
	end

	for territoryId, territoryState in pairs(defaultData.territories) do
		if data.territories[territoryId] == nil then
			data.territories[territoryId] = territoryState
		end
	end

	data.version = self.VERSION
	return data
end

function DataService:Load(player: Player)
	if self.profiles[player.UserId] then
		return self.profiles[player.UserId]
	end

	local key = self:GetKey(player)
	local success, savedData = pcall(function()
		return self.store:GetAsync(key)
	end)

	local data
	if success and type(savedData) == "table" then
		data = self:MergeDefaults(savedData)
		print(string.format("[DataService] loaded saved profile for %s", player.Name))
	elseif success then
		data = self:CreateDefaultData()
		print(string.format("[DataService] created new profile for %s", player.Name))
	else
		data = self:CreateDefaultData()
		self.loadFailed[player.UserId] = true
		warn(string.format("[DataService] load failed for %s: %s", player.Name, tostring(savedData)))
	end

	self.profiles[player.UserId] = data
	self.dirty[player.UserId] = false

	self:ProcessOfflineProgress(player, data, os.time())

	task.defer(function()
		if self.services and self.services.WorldService then
			self.services.WorldService:BuildBase(player)
		end
	end)

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

function DataService:Save(player: Player): boolean
	local data = self.profiles[player.UserId]
	if not data then
		return false
	end

	local key = self:GetKey(player)
	local payload = deepCopy(data)
	payload.lastLogoutTime = os.time()

	local success, err = pcall(function()
		self.store:UpdateAsync(key, function()
			return payload
		end)
	end)

	if not success then
		warn(string.format("[DataService] save failed for %s: %s", player.Name, tostring(err)))
		return false
	end

	self:MarkClean(player)
	return true
end

function DataService:Autosave()
	for _, player in ipairs(Players:GetPlayers()) do
		if self:IsDirty(player) then
			self:Save(player)
		end
	end
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
	self:Save(player)
	self.profiles[player.UserId] = nil
	self.dirty[player.UserId] = nil
	self.loadFailed[player.UserId] = nil

	print(string.format("[DataService] released profile for %s", player.Name))
end

return DataService
