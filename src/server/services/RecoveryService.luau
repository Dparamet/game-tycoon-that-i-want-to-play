local RecoveryService = {}

function RecoveryService:Init(services)
	self.services = services
end

function RecoveryService:Start()
	print("[RecoveryService] ready")
end

return RecoveryService
