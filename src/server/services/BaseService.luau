local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Buildings = require(ReplicatedStorage.Shared.config.Buildings)

local BaseService = {}

function BaseService:Init(services)
	self.services = services
end

function BaseService:Start()
	print("[BaseService] ready")
end

function BaseService:HasBuilding(player: Player, buildingId: string): boolean
	local data = self.services.DataService:Get(player)
	return data.base.buildings[buildingId] ~= nil
end

function BaseService:MeetsRequirements(player: Player, building): boolean
	local requirements = building.requires
	if not requirements then
		return true
	end

	local data = self.services.DataService:Get(player)
	local requiredCommandLevel = requirements.commandCenterLevel or 1

	return data.base.commandCenterLevel >= requiredCommandLevel
end

function BaseService:BuyBuilding(player: Player, buildingId: string): boolean
	local building = Buildings[buildingId]
	if not building or self:HasBuilding(player, buildingId) then
		return false
	end

	if not self:MeetsRequirements(player, building) then
		return false
	end

	if not self.services.EconomyService:Spend(player, building.cost) then
		return false
	end

	self.services.DataService:Update(player, function(data)
		data.base.buildings[buildingId] = {
			id = buildingId,
			level = 1,
			purchasedAt = os.time(),
		}
	end)

	return true
end

function BaseService:UpgradeCommandCenter(player: Player): boolean
	local data = self.services.DataService:Get(player)
	local commandCenter = Buildings.CommandCenter
	local currentLevel = data.base.commandCenterLevel

	if currentLevel >= commandCenter.maxLevel then
		return false
	end

	local nextLevel = currentLevel + 1
	local cost = {
		cash = 100 * nextLevel,
		supplies = 25 * (nextLevel - 1),
	}

	if not self.services.EconomyService:Spend(player, cost) then
		return false
	end

	self.services.DataService:Update(player, function(updatedData)
		updatedData.base.commandCenterLevel = nextLevel
		updatedData.base.buildings.CommandCenter.level = nextLevel
	end)

	return true
end

return BaseService
