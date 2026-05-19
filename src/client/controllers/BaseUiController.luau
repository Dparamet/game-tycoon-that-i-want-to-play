local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteRegistry = require(ReplicatedStorage.Shared.net.RemoteRegistry)
local Remotes = require(ReplicatedStorage.Shared.constants.Remotes)

local BaseUiController = {}

local function createText(parent: Instance, name: string, text: string, size: UDim2, position: UDim2)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextColor3 = Color3.fromRGB(232, 236, 226)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function createButton(parent: Instance, text: string, order: number, callback)
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%s+", "") .. "Button"
	button.BackgroundColor3 = Color3.fromRGB(66, 82, 72)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 34)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(246, 248, 240)
	button.TextSize = 13
	button.AutoButtonColor = true
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.Activated:Connect(callback)
	return button
end

function BaseUiController:Init()
	self.player = Players.LocalPlayer
	self.requestRemote = RemoteRegistry.waitForRemoteEvent(Remotes.RequestAction)
	self.snapshotRemote = RemoteRegistry.waitForRemoteEvent(Remotes.StateSnapshot)
	self.resultRemote = RemoteRegistry.waitForRemoteEvent(Remotes.MissionResult)
	self.state = nil
end

function BaseUiController:Start()
	self:BuildGui()
	self.snapshotRemote.OnClientEvent:Connect(function(snapshot)
		self.state = snapshot
		self:Render()
	end)
	self.resultRemote.OnClientEvent:Connect(function(result)
		self:ShowMissionResult(result)
	end)
	self:Request("GetSnapshot")
	print("[BaseUiController] ready")
end

function BaseUiController:Request(action: string, payload)
	self.requestRemote:FireServer({
		action = action,
		payload = payload or {},
	})
end

function BaseUiController:BuildGui()
	local playerGui = self.player:WaitForChild("PlayerGui")
	local oldGui = playerGui:FindFirstChild("MvpCommandGui")
	if oldGui then
		oldGui:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "MvpCommandGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = playerGui
	self.gui = gui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui

	local top = Instance.new("Frame")
	top.Name = "TopBar"
	top.BackgroundColor3 = Color3.fromRGB(28, 34, 34)
	top.BorderSizePixel = 0
	top.Position = UDim2.fromOffset(12, 8)
	top.Size = UDim2.new(1, -24, 0, 46)
	top.Parent = root

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 8)
	topCorner.Parent = top

	self.titleLabel = createText(top, "Title", "Army Command MVP", UDim2.new(0.5, 0, 0, 22), UDim2.fromOffset(12, 4))
	self.resourceLabel = createText(top, "Resources", "Cash 0 | Supplies 0", UDim2.new(0.5, -100, 0, 22), UDim2.new(0.5, 0, 0, 4))
	self.resourceLabel.TextXAlignment = Enum.TextXAlignment.Right

	local toggle = Instance.new("TextButton")
	toggle.Name = "ToggleUiButton"
	toggle.AnchorPoint = Vector2.new(1, 0)
	toggle.BackgroundColor3 = Color3.fromRGB(64, 72, 76)
	toggle.BorderSizePixel = 0
	toggle.Font = Enum.Font.GothamBold
	toggle.Position = UDim2.new(1, -10, 0, 8)
	toggle.Size = UDim2.fromOffset(74, 30)
	toggle.Text = "Hide UI"
	toggle.TextColor3 = Color3.fromRGB(246, 248, 240)
	toggle.TextSize = 12
	toggle.Parent = top
	self.toggleButton = toggle

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleCorner.Parent = toggle

	toggle.Activated:Connect(function()
		self:SetPanelsVisible(not self.panelsVisible)
	end)

	local panel = Instance.new("Frame")
	panel.Name = "ActionPanel"
	panel.BackgroundColor3 = Color3.fromRGB(34, 40, 38)
	panel.BorderSizePixel = 0
	panel.Position = UDim2.fromOffset(12, 64)
	panel.Size = UDim2.fromOffset(220, 334)
	panel.Parent = root
	self.actionPanel = panel

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 8)
	panelCorner.Parent = panel

	createText(panel, "PanelTitle", "Base Actions", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(12, 10))

	local buttons = Instance.new("ScrollingFrame")
	buttons.Name = "Buttons"
	buttons.BackgroundTransparency = 1
	buttons.BorderSizePixel = 0
	buttons.AutomaticCanvasSize = Enum.AutomaticSize.Y
	buttons.CanvasSize = UDim2.fromScale(0, 0)
	buttons.ScrollBarThickness = 4
	buttons.Position = UDim2.fromOffset(12, 42)
	buttons.Size = UDim2.new(1, -24, 1, -50)
	buttons.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = buttons

	createButton(buttons, "Refresh", 1, function()
		self:Request("GetSnapshot")
	end)
	createButton(buttons, "Recruit Citizen", 2, function()
		self:Request("CreateCitizen")
	end)
	createButton(buttons, "Buy Training Ground", 3, function()
		self:Request("BuyBuilding", { buildingId = "TrainingGround" })
	end)
	createButton(buttons, "Upgrade Command", 4, function()
		self:Request("UpgradeCommandCenter")
	end)
	createButton(buttons, "Start Basic Training", 5, function()
		local unit = self:FindUnit(function(candidate)
			return candidate.rank == "Citizen" and candidate.status == "Available"
		end)
		if unit then
			self:Request("StartTraining", { unitId = unit.id, courseId = "BasicArmyTraining", mode = "Passive" })
		end
	end)
	createButton(buttons, "Process Training", 6, function()
		self:Request("ProcessTraining")
	end)
	createButton(buttons, "Buy Barracks", 7, function()
		self:Request("BuyBuilding", { buildingId = "Barracks" })
	end)
	createButton(buttons, "Buy Supply Depot", 8, function()
		self:Request("BuyBuilding", { buildingId = "SupplyDepot" })
	end)
	createButton(buttons, "Buy Medical Tent", 9, function()
		self:Request("BuyBuilding", { buildingId = "MedicalTent" })
	end)
	createButton(buttons, "Buy Armory", 10, function()
		self:Request("BuyBuilding", { buildingId = "Armory" })
	end)
	createButton(buttons, "Create Squad", 11, function()
		self:Request("CreateSquad", { name = "1st Squad" })
	end)
	createButton(buttons, "Assign To Alpha", 12, function()
		self:AssignFirstAvailable("Alpha")
	end)
	createButton(buttons, "Assign To Bravo", 13, function()
		self:AssignFirstAvailable("Bravo")
	end)
	createButton(buttons, "Run Auto Mission", 14, function()
		local squadId = self:GetFirstSquadId()
		if squadId then
			self:Request("StartAutoMission", { territoryId = "Outskirts", squadId = squadId, tactic = "FrontalAssault" })
		end
	end)
	createButton(buttons, "Start Recovery", 15, function()
		local unit = self:FindUnit(function(candidate)
			return candidate.status == "Wounded"
		end)
		if unit then
			self:Request("StartRecovery", { unitId = unit.id })
		end
	end)

	local roster = Instance.new("Frame")
	roster.Name = "Roster"
	roster.BackgroundColor3 = Color3.fromRGB(30, 34, 34)
	roster.BorderSizePixel = 0
	roster.Position = UDim2.fromOffset(244, 64)
	roster.Size = UDim2.fromOffset(390, 334)
	roster.Parent = root
	self.rosterPanel = roster

	local rosterCorner = Instance.new("UICorner")
	rosterCorner.CornerRadius = UDim.new(0, 8)
	rosterCorner.Parent = roster

	self.summaryLabel = createText(roster, "Summary", "Loading...", UDim2.new(1, -24, 0, 46), UDim2.fromOffset(12, 8))
	self.rosterText = createText(roster, "RosterText", "", UDim2.new(1, -24, 1, -64), UDim2.fromOffset(12, 58))
	self.rosterText.TextYAlignment = Enum.TextYAlignment.Top

	local resultPanel = Instance.new("Frame")
	resultPanel.Name = "MissionResultPanel"
	resultPanel.AnchorPoint = Vector2.new(0.5, 0)
	resultPanel.BackgroundColor3 = Color3.fromRGB(28, 34, 34)
	resultPanel.BorderSizePixel = 0
	resultPanel.Position = UDim2.new(0.5, 0, 0, 64)
	resultPanel.Size = UDim2.fromOffset(330, 190)
	resultPanel.Visible = false
	resultPanel.Parent = root
	self.resultPanel = resultPanel

	local resultCorner = Instance.new("UICorner")
	resultCorner.CornerRadius = UDim.new(0, 8)
	resultCorner.Parent = resultPanel

	self.resultTitle = createText(resultPanel, "ResultTitle", "Mission Result", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 10))
	self.resultTitle.Font = Enum.Font.GothamBold
	self.resultTitle.TextSize = 16

	self.resultText = createText(resultPanel, "ResultText", "", UDim2.new(1, -24, 1, -66), UDim2.fromOffset(12, 42))
	self.resultText.TextYAlignment = Enum.TextYAlignment.Top

	local close = Instance.new("TextButton")
	close.Name = "CloseResultButton"
	close.BackgroundColor3 = Color3.fromRGB(66, 82, 72)
	close.BorderSizePixel = 0
	close.Font = Enum.Font.GothamBold
	close.Position = UDim2.new(1, -104, 1, -42)
	close.Size = UDim2.fromOffset(92, 30)
	close.Text = "Close"
	close.TextColor3 = Color3.fromRGB(246, 248, 240)
	close.TextSize = 13
	close.Parent = resultPanel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close

	close.Activated:Connect(function()
		resultPanel.Visible = false
	end)

	self.panelsVisible = true
end

function BaseUiController:SetPanelsVisible(visible: boolean)
	self.panelsVisible = visible

	if self.actionPanel then
		self.actionPanel.Visible = visible
	end
	if self.rosterPanel then
		self.rosterPanel.Visible = visible
	end
	if self.resultPanel then
		self.resultPanel.Visible = false
	end

	local fieldPanel = self.gui and self.gui:FindFirstChild("FieldCommandPanel")
	if fieldPanel and fieldPanel:IsA("GuiObject") then
		fieldPanel.Visible = visible
	end

	if self.toggleButton then
		self.toggleButton.Text = if visible then "Hide UI" else "Show UI"
	end
end

function BaseUiController:ShowMissionResult(result)
	if not self.resultPanel then
		return
	end

	local title = if result.victory then "Mission Victory" else "Mission Failed"
	local rewards = result.rewards or { cash = 0, supplies = 0 }
	local unitLines = {}
	local wounded = 0
	local kia = 0
	local xpTotal = 0

	for unitId, unitResult in pairs(result.unitResults or {}) do
		xpTotal += unitResult.xp or 0
		if unitResult.status == "Wounded" then
			wounded += 1
		elseif unitResult.status == "KIA" then
			kia += 1
		end
		table.insert(unitLines, string.format("%s: %s +%d XP", unitId, unitResult.status, unitResult.xp or 0))
	end

	self.resultTitle.Text = title
	self.resultText.Text = table.concat({
		string.format("Rewards: Cash %d | Supplies %d", rewards.cash or 0, rewards.supplies or 0),
		string.format("XP gained: %d", xpTotal),
		string.format("Wounded: %d | KIA: %d", wounded, kia),
		string.format("Territory captured: %s", tostring(result.territoryCaptured == true)),
		"",
		table.concat(unitLines, "\n"),
	}, "\n")
	self.resultPanel.Visible = true
end

function BaseUiController:FindUnit(predicate)
	if not self.state then
		return nil
	end

	for _, unit in pairs(self.state.units) do
		if predicate(unit) then
			return unit
		end
	end

	return nil
end

function BaseUiController:GetFirstSquadId()
	if not self.state then
		return nil
	end

	for squadId in pairs(self.state.squads) do
		return squadId
	end

	return nil
end

function BaseUiController:AssignFirstAvailable(fireteamId: string)
	local squadId = self:GetFirstSquadId()
	local unit = self:FindUnit(function(candidate)
		return candidate.status == "Available"
	end)

	if squadId and unit then
		self:Request("AssignUnit", {
			squadId = squadId,
			fireteamId = fireteamId,
			unitId = unit.id,
		})
	end
end

function BaseUiController:Render()
	if not self.state then
		return
	end

	local resources = self.state.resources
	self.resourceLabel.Text = string.format("Cash %d | Supplies %d", resources.cash, resources.supplies)

	local unitCount = 0
	local squadCount = 0
	local buildingCount = 0
	for _ in pairs(self.state.units) do
		unitCount += 1
	end
	for _ in pairs(self.state.squads) do
		squadCount += 1
	end
	for _ in pairs(self.state.base.buildings) do
		buildingCount += 1
	end

	self.summaryLabel.Text = string.format(
		"Command Center Lv%d | Buildings %d | Units %d | Squads %d",
		self.state.base.commandCenterLevel,
		buildingCount,
		unitCount,
		squadCount
	)

	local lines = {}
	table.insert(lines, "ROSTER")
	for _, unit in pairs(self.state.units) do
		table.insert(lines, string.format("- %s | %s | %s | XP %d", unit.name, unit.rank, unit.status, unit.xp))
	end

	table.insert(lines, "")
	table.insert(lines, "SQUADS")
	for _, squad in pairs(self.state.squads) do
		table.insert(lines, string.format("- %s | readiness %d | members %d", squad.name, squad.readiness, #squad.memberUnitIds))
	end

	table.insert(lines, "")
	table.insert(lines, "TERRITORIES")
	for _, territory in pairs(self.state.territories) do
		table.insert(lines, string.format("- %s | owner %s | threat %d", territory.id, territory.owner, territory.threatLevel))
	end

	self.rosterText.Text = table.concat(lines, "\n")
end

return BaseUiController
