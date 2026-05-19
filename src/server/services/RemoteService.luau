local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.Shared.net.RemoteRegistry)

local RemoteService = {}

function RemoteService:Init(services)
	self.services = services
end

function RemoteService:Start()
	RemoteRegistry.ensureAll()
	print("[RemoteService] ready")
end

return RemoteService
