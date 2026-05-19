local CombatService = {}

function CombatService:Init(services)
	self.services = services
end

function CombatService:Start()
	print("[CombatService] ready")
end

return CombatService
