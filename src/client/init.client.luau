local ControllersFolder = script.controllers

local controllers = {
	"HudController",
	"BaseUiController",
	"RosterController",
	"TrainingController",
	"TerritoryMapController",
	"FieldCommandController",
}

for _, controllerName in ipairs(controllers) do
	local controller = require(ControllersFolder[controllerName])
	if controller.Init then
		controller:Init()
	end
	if controller.Start then
		controller:Start()
	end
end
