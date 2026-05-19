local TerritoryService = {}

function TerritoryService:Init(services)
	self.services = services
end

function TerritoryService:Start()
	print("[TerritoryService] ready")
end

return TerritoryService
