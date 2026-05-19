local SquadService = {}

function SquadService:Init(services)
	self.services = services
end

function SquadService:Start()
	print("[SquadService] ready")
end

return SquadService
