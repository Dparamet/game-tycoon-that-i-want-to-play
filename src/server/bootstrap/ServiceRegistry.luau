local ServicesFolder = script.Parent.Parent.services

local serviceModules = {
	"DataService",
	"EconomyService",
	"BaseService",
	"UnitService",
	"TrainingService",
	"RecoveryService",
	"SquadService",
	"TerritoryService",
	"CombatService",
	"MissionService",
	"RemoteService",
}

local ServiceRegistry = {
	services = {},
}

function ServiceRegistry:Init()
	for _, serviceName in ipairs(serviceModules) do
		local service = require(ServicesFolder[serviceName])
		self.services[serviceName] = service

		if service.Init then
			service:Init(self.services)
		end
	end
end

function ServiceRegistry:Start()
	for _, serviceName in ipairs(serviceModules) do
		local service = self.services[serviceName]
		if service.Start then
			service:Start()
		end
	end
end

return ServiceRegistry
