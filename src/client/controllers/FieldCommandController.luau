local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteRegistry = require(ReplicatedStorage.Shared.net.RemoteRegistry)
local Remotes = require(ReplicatedStorage.Shared.constants.Remotes)

local FieldCommandController = {}

local function makeButton(parent: Instance, text: string, order: number, callback)
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%s+", "") .. "Button"
	button.BackgroundColor3 = Color3.fromRGB(52, 58, 62)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(240, 244, 236)
	button.TextSize = 12
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.Activated:Connect(callback)
	return button
end

function FieldCommandController:Init()
	self.player = Players.LocalPlayer
	self.requestRemote = RemoteRegistry.waitForRemoteEvent(Remotes.RequestAction)
	self.snapshotRemote = RemoteRegistry.waitForRemoteEvent(Remotes.StateSnapshot)
	self.state = nil
end

function FieldCommandController:Start()
	task.defer(function()
		self:BuildGui()
	end)
	self.snapshotRemote.OnClientEvent:Connect(function(snapshot)
		self.state = snapshot
	end)
	print("[FieldCommandController] ready")
end

function FieldCommandController:Request(action: string, payload)
	self.requestRemote:FireServer({
		action = action,
		payload = payload or {},
	})
end

function FieldCommandController:GetFirstSquadId()
	if not self.state then
		return nil
	end

	for squadId in pairs(self.state.squads) do
		return squadId
	end

	return nil
end

function FieldCommandController:BuildGui()
	local playerGui = self.player:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("MvpCommandGui")
	while not gui do
		task.wait()
		gui = playerGui:FindFirstChild("MvpCommandGui")
	end

	local oldPanel = gui:FindFirstChild("FieldCommandPanel")
	if oldPanel then
		oldPanel:Destroy()
	end

	local panel = Instance.new("Frame")
	panel.Name = "FieldCommandPanel"
	panel.BackgroundColor3 = Color3.fromRGB(30, 34, 38)
	panel.BorderSizePixel = 0
	panel.Position = UDim2.new(1, -236, 1, -344)
	panel.Size = UDim2.fromOffset(220, 328)
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Position = UDim2.fromOffset(12, 8)
	title.Size = UDim2.new(1, -24, 0, 22)
	title.Text = "Field Command"
	title.TextColor3 = Color3.fromRGB(236, 240, 232)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local list = Instance.new("Frame")
	list.BackgroundTransparency = 1
	list.Position = UDim2.fromOffset(12, 40)
	list.Size = UDim2.new(1, -24, 1, -52)
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	makeButton(list, "Start Field Mission", 1, function()
		local squadId = self:GetFirstSquadId()
		if squadId then
			self:Request("StartFieldMission", { territoryId = "Outskirts", squadId = squadId, tactic = "FrontalAssault" })
		end
	end)

	local commands = { "Move", "Attack", "Hold", "Suppress", "Retreat", "Rally" }
	local order = 2
	for _, command in ipairs(commands) do
		makeButton(list, "Alpha " .. command, order, function()
			self:Request("FieldCommand", { fireteamId = "Alpha", command = command })
		end)
		order += 1
	end

	for _, command in ipairs(commands) do
		makeButton(list, "Bravo " .. command, order, function()
			self:Request("FieldCommand", { fireteamId = "Bravo", command = command })
		end)
		order += 1
	end

	makeButton(list, "Complete Field Mission", order, function()
		self:Request("CompleteFieldMission")
	end)
end

return FieldCommandController
