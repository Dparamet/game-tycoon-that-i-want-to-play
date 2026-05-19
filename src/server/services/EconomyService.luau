local EconomyService = {}

local function getAmount(container, key: string): number
	if type(container) ~= "table" then
		return 0
	end

	local value = container[key]
	if type(value) ~= "number" then
		return 0
	end

	return math.max(0, value)
end

function EconomyService:Init(services)
	self.services = services
end

function EconomyService:Start()
	print("[EconomyService] ready")
end

function EconomyService:CanAfford(player: Player, cost): boolean
	local data = self.services.DataService:Get(player)
	return data.resources.cash >= getAmount(cost, "cash") and data.resources.supplies >= getAmount(cost, "supplies")
end

function EconomyService:Spend(player: Player, cost): boolean
	if not self:CanAfford(player, cost) then
		return false
	end

	self.services.DataService:Update(player, function(data)
		data.resources.cash -= getAmount(cost, "cash")
		data.resources.supplies -= getAmount(cost, "supplies")
	end)

	return true
end

function EconomyService:Add(player: Player, rewards)
	self.services.DataService:Update(player, function(data)
		data.resources.cash += getAmount(rewards, "cash")
		data.resources.supplies += getAmount(rewards, "supplies")
	end)
end

return EconomyService
