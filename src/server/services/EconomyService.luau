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

function EconomyService:GetIncomeRates(player: Player)
	local data = self.services.DataService:Get(player)
	local ccLevel = data.base.commandCenterLevel or 1

	local otherBuildingCount = 0
	for buildingId in pairs(data.base.buildings) do
		if buildingId ~= "CommandCenter" and buildingId ~= "CashGenerator" and buildingId ~= "SupplyDepot" then
			otherBuildingCount += 1
		end
	end

	local cashRate = 1
	if data.base.buildings.CashGenerator then
		cashRate += 5
	end
	cashRate += ccLevel * 1
	cashRate += otherBuildingCount * 0.5

	local supplyRate = 0.1
	if data.base.buildings.SupplyDepot then
		supplyRate += 1.5
	end
	supplyRate += ccLevel * 0.2

	return {
		cash = cashRate,
		supplies = supplyRate,
	}
end

function EconomyService:GetIncomeCaps(player: Player)
	local data = self.services.DataService:Get(player)
	local ccLevel = data.base.commandCenterLevel or 1

	return {
		cash = 200 + ccLevel * 300,
		supplies = 50 + ccLevel * 50,
	}
end

function EconomyService:GetAccruedIncome(player: Player)
	local data = self.services.DataService:Get(player)
	local now = os.time()
	local lastClaim = data.lastIncomeClaimTime or data.lastLogoutTime or now
	local elapsed = math.clamp(now - lastClaim, 0, 28800) -- Capped at 8 hours

	local rates = self:GetIncomeRates(player)
	local caps = self:GetIncomeCaps(player)

	local accruedCash = math.min(math.floor(elapsed * rates.cash), caps.cash)
	local accruedSupplies = math.min(math.floor(elapsed * rates.supplies), caps.supplies)

	return accruedCash, accruedSupplies, elapsed
end

function EconomyService:GetPassiveIncome(player: Player)
	return self:GetIncomeRates(player)
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

function EconomyService:ClaimIncome(player: Player)
	local accruedCash, accruedSupplies, elapsed = self:GetAccruedIncome(player)
	if elapsed < 2 then
		return false, "Vault has nothing to claim yet"
	end

	self.services.DataService:Update(player, function(data)
		data.resources.cash += accruedCash
		data.resources.supplies += accruedSupplies
		data.lastIncomeClaimTime = os.time()
	end)

	return true, string.format("Claimed $%d Cash and %d Supplies!", accruedCash, accruedSupplies)
end

return EconomyService
