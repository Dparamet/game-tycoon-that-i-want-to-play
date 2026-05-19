local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Territories = require(ReplicatedStorage.Shared.config.Territories)

local TerritoryService = {}

function TerritoryService:Init(services)
	self.services = services
end

function TerritoryService:Start()
	print("[TerritoryService] ready")
end

function TerritoryService:GetAvailable(player: Player): {string}
	local data = self.services.DataService:Get(player)
	local available = {}

	for territoryId, state in pairs(data.territories) do
		if state.unlocked then
			table.insert(available, territoryId)
		end
	end

	return available
end

function TerritoryService:GetConfig(territoryId: string)
	return Territories[territoryId]
end

function TerritoryService:IsAvailable(player: Player, territoryId: string): boolean
	local data = self.services.DataService:Get(player)
	local state = data.territories[territoryId]

	return state ~= nil and state.unlocked == true
end

function TerritoryService:Capture(player: Player, territoryId: string): boolean
	if not Territories[territoryId] then
		return false
	end

	self.services.DataService:Update(player, function(data)
		local state = data.territories[territoryId]
		if not state then
			return
		end

		state.owner = "Player"
		state.capturedAt = os.time()
		state.threatLevel = 0
	end)

	return true
end

function TerritoryService:SetThreat(player: Player, territoryId: string, threatLevel: number): boolean
	if not Territories[territoryId] then
		return false
	end

	self.services.DataService:Update(player, function(data)
		local state = data.territories[territoryId]
		if state then
			state.threatLevel = math.max(0, threatLevel)
		end
	end)

	return true
end

return TerritoryService
