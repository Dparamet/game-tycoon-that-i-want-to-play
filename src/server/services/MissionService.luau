local MissionService = {}

function MissionService:Init(services)
	self.services = services
end

function MissionService:Start()
	print("[MissionService] ready")
end

return MissionService
