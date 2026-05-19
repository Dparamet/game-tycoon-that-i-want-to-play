local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local WorldService = {}

local BUILDING_LAYOUT = {
	CommandCenter = {
		label = "COMMAND CENTER",
		size = Vector3.new(28, 16, 22),
		position = Vector3.new(0, 10, -42),
		color = Color3.fromRGB(72, 82, 92),
		padSize = Vector3.new(30, 1, 24),
		padPosition = Vector3.new(0, 2.5, -42),
	},
	RecruitmentOffice = {
		label = "RECRUITMENT OFFICE",
		size = Vector3.new(20, 10, 16),
		position = Vector3.new(-55, 7, -20),
		color = Color3.fromRGB(83, 104, 76),
		padSize = Vector3.new(22, 1, 18),
		padPosition = Vector3.new(-55, 2.5, -20),
	},
	TrainingGround = {
		label = "TRAINING GROUND",
		size = Vector3.new(34, 2, 24),
		position = Vector3.new(-52, 3.5, 25),
		color = Color3.fromRGB(92, 88, 70),
		padSize = Vector3.new(34, 1, 24),
		padPosition = Vector3.new(-52, 2.5, 25),
	},
	Barracks = {
		label = "BARRACKS",
		size = Vector3.new(28, 10, 20),
		position = Vector3.new(42, 7, -18),
		color = Color3.fromRGB(88, 82, 72),
		padSize = Vector3.new(28, 1, 20),
		padPosition = Vector3.new(42, 2.5, -18),
	},
	MedicalTent = {
		label = "MEDICAL TENT",
		size = Vector3.new(24, 9, 18),
		position = Vector3.new(48, 6.5, 24),
		color = Color3.fromRGB(88, 72, 72),
		padSize = Vector3.new(24, 1, 18),
		padPosition = Vector3.new(48, 2.5, 24),
	},
	Armory = {
		label = "ARMORY",
		size = Vector3.new(22, 10, 18),
		position = Vector3.new(0, 7, 42),
		color = Color3.fromRGB(60, 64, 70),
		padSize = Vector3.new(22, 1, 18),
		padPosition = Vector3.new(0, 2.5, 42),
	},
	CashGenerator = {
		label = "CASH GENERATOR",
		size = Vector3.new(12, 8, 12),
		position = Vector3.new(-76, 6, -55),
		color = Color3.fromRGB(92, 124, 76),
		padSize = Vector3.new(14, 1, 14),
		padPosition = Vector3.new(-76, 2.5, -55),
	},
	SupplyDepot = {
		label = "SUPPLY DEPOT",
		size = Vector3.new(14, 8, 14),
		position = Vector3.new(74, 6, -54),
		color = Color3.fromRGB(112, 96, 64),
		padSize = Vector3.new(14, 1, 14),
		padPosition = Vector3.new(74, 2.5, -54),
	},
}

local BUILDING_ORDER = {
	"RecruitmentOffice",
	"TrainingGround",
	"Barracks",
	"SupplyDepot",
	"MedicalTent",
	"Armory",
}

local TYCOON_PATHS = {
	{ name = "Main Road", size = Vector3.new(14, 0.4, 118), position = Vector3.new(0, 2.25, -1) },
	{ name = "West Road", size = Vector3.new(112, 0.4, 10), position = Vector3.new(-28, 2.3, -20) },
	{ name = "East Road", size = Vector3.new(106, 0.4, 10), position = Vector3.new(30, 2.3, 24) },
	{ name = "Command Road", size = Vector3.new(58, 0.4, 10), position = Vector3.new(0, 2.35, -42) },
	{ name = "Generator Road", size = Vector3.new(158, 0.4, 8), position = Vector3.new(0, 2.4, -55) },
}

local ZONE_LAYOUT = {
	{ name = "Recruit Wing", position = Vector3.new(-55, 2.6, -20), size = Vector3.new(30, 0.4, 26), color = Color3.fromRGB(54, 82, 58) },
	{ name = "Training Yard", position = Vector3.new(-52, 2.6, 25), size = Vector3.new(44, 0.4, 34), color = Color3.fromRGB(82, 78, 58) },
	{ name = "Barracks Block", position = Vector3.new(42, 2.6, -18), size = Vector3.new(38, 0.4, 30), color = Color3.fromRGB(74, 68, 60) },
	{ name = "Support Block", position = Vector3.new(48, 2.6, 24), size = Vector3.new(34, 0.4, 28), color = Color3.fromRGB(76, 58, 58) },
	{ name = "Armory Block", position = Vector3.new(0, 2.6, 42), size = Vector3.new(34, 0.4, 28), color = Color3.fromRGB(52, 56, 62) },
	{ name = "Generator Block", position = Vector3.new(-76, 2.6, -55), size = Vector3.new(24, 0.4, 24), color = Color3.fromRGB(62, 92, 58) },
	{ name = "Supply Block", position = Vector3.new(74, 2.6, -54), size = Vector3.new(26, 0.4, 26), color = Color3.fromRGB(88, 76, 50) },
}

local function makePart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeLabel(parent: Instance, text: string, position: Vector3)
	local part = makePart(parent, text .. " Sign", Vector3.new(10, 4, 0.4), position, Color3.fromRGB(28, 32, 36))
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 239, 232)
	label.TextScaled = true
	label.Parent = gui
end

local function makeGroundLabel(parent: Instance, text: string, position: Vector3, size: Vector3)
	local part = makePart(parent, text .. " Ground Label", size, position, Color3.fromRGB(34, 40, 36))
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 16
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(218, 224, 210)
	label.TextScaled = true
	label.Parent = gui
end

local function makeFence(parent: Instance, name: string, position: Vector3, size: Vector3)
	local fence = makePart(parent, name, size, position, Color3.fromRGB(42, 48, 44))
	fence.Material = Enum.Material.WoodPlanks
	return fence
end

local function makeTrooper(parent: Instance, name: string, position: Vector3, color: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("Health", 100)
	model:SetAttribute("MaxHealth", 100)
	model.Parent = parent

	local body = makePart(model, "Root", Vector3.new(3, 5, 2), position, color)
	makePart(model, "Head", Vector3.new(2, 2, 2), position + Vector3.new(0, 3.5, 0), Color3.fromRGB(184, 154, 118))
	makePart(model, "Pack", Vector3.new(1, 3, 0.6), position + Vector3.new(0, 0.2, 1.3), Color3.fromRGB(42, 48, 40))

	model.PrimaryPart = body

	local gui = Instance.new("BillboardGui")
	gui.Name = "Nameplate"
	gui.Size = UDim2.fromOffset(120, 28)
	gui.StudsOffset = Vector3.new(0, 5.8, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.25
	label.BackgroundColor3 = Color3.fromRGB(20, 24, 24)
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = name
	label.TextColor3 = Color3.fromRGB(240, 244, 236)
	label.TextScaled = true
	label.Parent = gui

	local healthGui = Instance.new("BillboardGui")
	healthGui.Name = "HealthGui"
	healthGui.Size = UDim2.fromOffset(100, 12)
	healthGui.StudsOffset = Vector3.new(0, 4.5, 0)
	healthGui.AlwaysOnTop = true
	healthGui.Parent = body

	local back = Instance.new("Frame")
	back.Name = "Back"
	back.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	back.BorderSizePixel = 0
	back.Size = UDim2.fromScale(1, 1)
	back.Parent = healthGui

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(78, 168, 122)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.Parent = back

	return model
end

local function makeEnemy(parent: Instance, name: string, position: Vector3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("Health", 100)
	model:SetAttribute("MaxHealth", 100)
	model.Parent = parent

	local body = makePart(model, "Root", Vector3.new(5, 7, 4), position, Color3.fromRGB(140, 58, 52))
	makePart(model, "Head", Vector3.new(3, 3, 3), position + Vector3.new(0, 5, 0), Color3.fromRGB(98, 64, 54))
	model.PrimaryPart = body

	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthGui"
	gui.Size = UDim2.fromOffset(120, 20)
	gui.StudsOffset = Vector3.new(0, 8, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body

	local back = Instance.new("Frame")
	back.Name = "Back"
	back.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	back.BorderSizePixel = 0
	back.Size = UDim2.fromScale(1, 1)
	back.Parent = gui

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(190, 70, 58)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.Parent = back

	return model
end

function WorldService:MoveTrooper(model: Model, targetPosition: Vector3)
	local root = model.PrimaryPart
	if not root then
		return
	end

	local offset = targetPosition - root.Position
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") then
			local tween = TweenService:Create(child, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = child.Position + offset,
			})
			tween:Play()
		end
	end
end

function WorldService:MoveModel(model: Model, targetPosition: Vector3)
	local root = model.PrimaryPart
	if not root then
		return
	end

	local offset = targetPosition - root.Position
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") then
			TweenService:Create(child, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = child.Position + offset,
			}):Play()
		end
	end
end

function WorldService:DamageEnemy(enemy: Model, amount: number)
	local maxHealth = enemy:GetAttribute("MaxHealth") or 100
	local health = math.max(0, (enemy:GetAttribute("Health") or maxHealth) - amount)
	enemy:SetAttribute("Health", health)

	local root = enemy.PrimaryPart
	if root then
		root.Color = Color3.fromRGB(220, 90, 70)
		task.delay(0.18, function()
			if root.Parent then
				root.Color = if health <= 0 then Color3.fromRGB(44, 44, 44) else Color3.fromRGB(140, 58, 52)
			end
		end)
	end

	local healthGui = root and root:FindFirstChild("HealthGui")
	local fill = healthGui and healthGui:FindFirstChild("Back") and healthGui.Back:FindFirstChild("Fill")
	if fill and fill:IsA("Frame") then
		fill.Size = UDim2.fromScale(health / maxHealth, 1)
	end
end

function WorldService:DamageTrooper(trooper: Model, amount: number)
	local maxHealth = trooper:GetAttribute("MaxHealth") or 100
	local health = math.max(0, (trooper:GetAttribute("Health") or maxHealth) - amount)
	trooper:SetAttribute("Health", health)

	local root = trooper.PrimaryPart
	if root then
		root.Color = if health <= 0 then Color3.fromRGB(54, 58, 58) else Color3.fromRGB(196, 160, 74)
		task.delay(0.2, function()
			if root.Parent and health > 0 then
				local fireteamId = trooper:GetAttribute("FireteamId")
				root.Color = if fireteamId == "Bravo" then Color3.fromRGB(76, 148, 118) else Color3.fromRGB(68, 118, 190)
			end
		end)
	end

	local healthGui = root and root:FindFirstChild("HealthGui")
	local fill = healthGui and healthGui:FindFirstChild("Back") and healthGui.Back:FindFirstChild("Fill")
	if fill and fill:IsA("Frame") then
		fill.Size = UDim2.fromScale(health / maxHealth, 1)
		fill.BackgroundColor3 = if health <= 35 then Color3.fromRGB(190, 82, 68) else Color3.fromRGB(78, 168, 122)
	end

	local nameplate = root and root:FindFirstChild("Nameplate")
	local label = nameplate and nameplate:FindFirstChildOfClass("TextLabel")
	if label and health <= 0 then
		label.Text = "DOWN"
		label.TextColor3 = Color3.fromRGB(255, 190, 160)
	end
end

function WorldService:EnemyCounterFire(field: Folder, fireteamId: string, command: string)
	local damageByCommand = {
		Move = 6,
		Attack = 12,
		Hold = 4,
		Suppress = 5,
		Retreat = 2,
		Rally = 3,
	}
	local damage = damageByCommand[command] or 4

	for _, child in ipairs(field:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("FireteamId") == fireteamId then
			self:DamageTrooper(child, damage)
		end
	end
end

function WorldService:Init(services)
	self.services = services
end

function WorldService:Start()
	print("[WorldService] ready")
end

function WorldService:NotifyPlayer(player: Player, action: string, ok: boolean, message: string)
	if self.services.RemoteService then
		self.services.RemoteService:SendActionResult(player, action, ok, message)
		self.services.RemoteService:SendSnapshot(player)
	end
end

function WorldService:GetBaseName(player: Player): string
	return "MilitaryBase_" .. player.UserId
end

function WorldService:ClearBase(player: Player)
	local oldBase = Workspace:FindFirstChild(self:GetBaseName(player))
	if oldBase then
		oldBase:Destroy()
	end
end

function WorldService:MakeBuilding(parent: Instance, buildingId: string)
	local layout = BUILDING_LAYOUT[buildingId]
	if not layout then
		return
	end

	makePart(parent, buildingId, layout.size, layout.position, layout.color)
	makeLabel(parent, layout.label, layout.position + Vector3.new(0, layout.size.Y / 2 + 5, layout.size.Z / 2 + 1))
end

function WorldService:MakeTycoonMap(parent: Instance, player: Player)
	for _, zone in ipairs(ZONE_LAYOUT) do
		local zonePart = makePart(parent, zone.name, zone.size, zone.position, zone.color)
		zonePart.Material = Enum.Material.Concrete
		makeGroundLabel(parent, zone.name:upper(), zone.position + Vector3.new(0, 0.25, 0), Vector3.new(zone.size.X - 4, 0.2, 5))
	end

	for _, path in ipairs(TYCOON_PATHS) do
		local road = makePart(parent, path.name, path.size, path.position, Color3.fromRGB(52, 56, 54))
		road.Material = Enum.Material.Asphalt
	end

	makeFence(parent, "North Fence", Vector3.new(0, 5, -70), Vector3.new(184, 8, 2))
	makeFence(parent, "South Fence", Vector3.new(0, 5, 70), Vector3.new(184, 8, 2))
	makeFence(parent, "West Fence", Vector3.new(-92, 5, 0), Vector3.new(2, 8, 140))
	makeFence(parent, "East Fence", Vector3.new(92, 5, 0), Vector3.new(2, 8, 140))

	makePart(parent, "Front Gate Left", Vector3.new(2, 10, 20), Vector3.new(-12, 6, 70), Color3.fromRGB(60, 66, 62))
	makePart(parent, "Front Gate Right", Vector3.new(2, 10, 20), Vector3.new(12, 6, 70), Color3.fromRGB(60, 66, 62))
	makeGroundLabel(parent, "MISSION GATE", Vector3.new(0, 2.8, 58), Vector3.new(26, 0.2, 6))

	local collector = makePart(parent, "Cash Collector Pad", Vector3.new(18, 0.8, 14), Vector3.new(-58, 2.8, -55), Color3.fromRGB(40, 150, 86))
	collector.Material = Enum.Material.Neon
	makeGroundLabel(parent, "COLLECT CASH", Vector3.new(-58, 3.3, -55), Vector3.new(16, 0.2, 5))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = "Cash Generator"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = collector

	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer ~= player then
			return
		end

		local ok = self.services.EconomyService:ClaimIncome(player)
		local message = if ok then "Income claimed" else "No income ready"
		self:NotifyPlayer(player, "ClaimIncome", ok, message)
	end)

	for index = 1, 5 do
		local arrow = makePart(parent, "Progress Arrow " .. index, Vector3.new(6, 0.25, 2), Vector3.new(-45 + index * 15, 2.9, -2), Color3.fromRGB(90, 130, 95))
		arrow.Material = Enum.Material.Neon
	end
end

function WorldService:MakeLockedPad(parent: Instance, buildingId: string)
	local layout = BUILDING_LAYOUT[buildingId]
	if not layout then
		return
	end

	local ghost = makePart(parent, "Locked " .. buildingId, layout.padSize, layout.padPosition, Color3.fromRGB(54, 58, 58))
	ghost.Transparency = 0.35
	makeGroundLabel(parent, "LOCKED\n" .. layout.label, layout.padPosition + Vector3.new(0, 0.45, 0), Vector3.new(layout.padSize.X - 2, 0.2, 6))
end

function WorldService:MakePurchasePad(parent: Instance, player: Player, buildingId: string)
	local layout = BUILDING_LAYOUT[buildingId]
	if not layout then
		return
	end

	local building = self.services and self.services.BaseService and self.services.BaseService:GetBuildingConfig(buildingId)
	local cost = building and building.cost or { cash = 0, supplies = 0 }
	local pad = makePart(parent, "Buy " .. buildingId, layout.padSize, layout.padPosition, Color3.fromRGB(38, 120, 86))
	pad.Material = Enum.Material.Neon

	makeLabel(parent, string.format("BUY %s\n$%d | S%d", layout.label, cost.cash or 0, cost.supplies or 0), layout.padPosition + Vector3.new(0, 6, 0))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Buy"
	prompt.ObjectText = layout.label
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = pad

	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer ~= player then
			return
		end

		if self.services.BaseService:BuyBuilding(player, buildingId) then
			self:RefreshBase(player)
			self:NotifyPlayer(player, "BuyBuilding", true, "Purchased " .. layout.label)
		else
			self:NotifyPlayer(player, "BuyBuilding", false, "Cannot buy " .. layout.label)
		end
	end)
end

function WorldService:MakeCommandUpgradePad(parent: Instance, player: Player)
	local data = self.services.DataService:Get(player)
	if data.base.commandCenterLevel >= 5 then
		return
	end

	local nextLevel = data.base.commandCenterLevel + 1
	local costCash = 100 * nextLevel
	local costSupplies = 25 * (nextLevel - 1)
	local pad = makePart(parent, "Upgrade Command Center", Vector3.new(18, 1, 12), Vector3.new(24, 2.5, -42), Color3.fromRGB(70, 105, 150))
	pad.Material = Enum.Material.Neon
	makeLabel(parent, string.format("UPGRADE COMMAND\nLV %d\n$%d | S%d", nextLevel, costCash, costSupplies), Vector3.new(24, 9, -34))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Upgrade"
	prompt.ObjectText = "Command Center"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = pad

	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer ~= player then
			return
		end

		if self.services.BaseService:UpgradeCommandCenter(player) then
			self:RefreshBase(player)
			self:NotifyPlayer(player, "UpgradeCommandCenter", true, "Command Center upgraded")
		else
			self:NotifyPlayer(player, "UpgradeCommandCenter", false, "Cannot upgrade Command Center")
		end
	end)
end

function WorldService:RefreshBase(player: Player)
	self:ClearBase(player)

	local data = self.services.DataService:Get(player)
	local base = Instance.new("Folder")
	base.Name = self:GetBaseName(player)
	base.Parent = Workspace

	makePart(base, "Base Ground", Vector3.new(180, 2, 140), Vector3.new(0, 1, 0), Color3.fromRGB(68, 82, 64))
	self:MakeTycoonMap(base, player)
	makePart(base, "Mission Table", Vector3.new(20, 3, 12), Vector3.new(0, 3.5, -12), Color3.fromRGB(42, 48, 54))
	makeLabel(base, "MISSION MAP", Vector3.new(0, 7, 0))

	for buildingId in pairs(data.base.buildings) do
		self:MakeBuilding(base, buildingId)
	end

	for _, buildingId in ipairs(BUILDING_ORDER) do
		if not data.base.buildings[buildingId] then
			if self.services.BaseService:CanBuyBuilding(player, buildingId) then
				self:MakePurchasePad(base, player, buildingId)
			else
				self:MakeLockedPad(base, buildingId)
			end
		end
	end

	self:MakeCommandUpgradePad(base, player)
end

function WorldService:BuildBase(player: Player)
	self:RefreshBase(player)
end

function WorldService:GetFieldFolder(player: Player)
	local name = "FieldMission_" .. player.UserId
	local folder = Workspace:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = Workspace
	end

	return folder
end

function WorldService:BuildFieldArena(player: Player, session, units)
	self:ClearFieldArena(player)

	local field = self:GetFieldFolder(player)
	makePart(field, "Field Ground", Vector3.new(140, 1, 100), Vector3.new(240, 1, 0), Color3.fromRGB(76, 86, 62))
	makePart(field, "Alpha Marker", Vector3.new(8, 8, 8), Vector3.new(210, 6, -18), Color3.fromRGB(68, 118, 190))
	makePart(field, "Bravo Marker", Vector3.new(8, 8, 8), Vector3.new(210, 6, 18), Color3.fromRGB(76, 148, 118))
	makeEnemy(field, "Enemy A", Vector3.new(278, 5.5, -22))
	makeEnemy(field, "Enemy B", Vector3.new(286, 5.5, 18))
	makePart(field, "Cover Wall 1", Vector3.new(5, 8, 28), Vector3.new(242, 6, -28), Color3.fromRGB(70, 72, 70))
	makePart(field, "Cover Wall 2", Vector3.new(5, 8, 28), Vector3.new(254, 6, 28), Color3.fromRGB(70, 72, 70))
	makeLabel(field, "FIELD MISSION", Vector3.new(240, 13, -48))
	makeLabel(field, "ALPHA: Follow", Vector3.new(210, 14, -30))
	makeLabel(field, "BRAVO: Follow", Vector3.new(210, 14, 30))

	local alphaIndex = 0
	local bravoIndex = 0

	for _, unit in ipairs(units) do
		local fireteamId = unit.fireteamId or "Alpha"
		local color = if fireteamId == "Bravo" then Color3.fromRGB(76, 148, 118) else Color3.fromRGB(68, 118, 190)
		local startPosition

		if fireteamId == "Bravo" then
			bravoIndex += 1
			startPosition = Vector3.new(202, 5, 12 + bravoIndex * 5)
		else
			alphaIndex += 1
			startPosition = Vector3.new(202, 5, -12 - alphaIndex * 5)
		end

		local trooper = makeTrooper(field, string.format("%s_%s", fireteamId, unit.id), startPosition, color)
		trooper:SetAttribute("UnitId", unit.id)
		trooper:SetAttribute("FireteamId", fireteamId)
	end
end

function WorldService:UpdateFieldCommandMarker(player: Player, fireteamId: string, command: string)
	local field = self:GetFieldFolder(player)
	local marker = field:FindFirstChild(fireteamId .. " Marker")
	if marker and marker:IsA("BasePart") then
		local colors = {
			Move = Color3.fromRGB(88, 132, 190),
			Attack = Color3.fromRGB(190, 82, 68),
			Hold = Color3.fromRGB(196, 160, 74),
			Suppress = Color3.fromRGB(150, 92, 184),
			Retreat = Color3.fromRGB(96, 100, 106),
			Rally = Color3.fromRGB(78, 168, 122),
		}
		marker.Color = colors[command] or marker.Color
	end

	local targets = {
		Alpha = {
			Move = Vector3.new(238, 5, -18),
			Attack = Vector3.new(270, 5, -22),
			Hold = Vector3.new(224, 5, -18),
			Suppress = Vector3.new(250, 5, -25),
			Retreat = Vector3.new(204, 5, -18),
			Rally = Vector3.new(218, 5, -8),
		},
		Bravo = {
			Move = Vector3.new(238, 5, 18),
			Attack = Vector3.new(276, 5, 18),
			Hold = Vector3.new(224, 5, 18),
			Suppress = Vector3.new(252, 5, 25),
			Retreat = Vector3.new(204, 5, 18),
			Rally = Vector3.new(218, 5, 8),
		},
	}

	local target = targets[fireteamId] and targets[fireteamId][command]
	if not target then
		return
	end

	local index = 0
	for _, child in ipairs(field:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("FireteamId") == fireteamId then
			index += 1
			self:MoveTrooper(child, target + Vector3.new(0, 0, (index - 1) * 4))
		end
	end

	self:EnemyCounterFire(field, fireteamId, command)

	if command == "Attack" or command == "Suppress" then
		for _, child in ipairs(field:GetChildren()) do
			if child:IsA("Model") and child.Name:find("Enemy") then
				local damage = if command == "Suppress" then 8 else 14
				self:DamageEnemy(child, damage)
				local root = child.PrimaryPart
				if root then
					local coverOffset = if root.Position.Z < 0 then Vector3.new(-10, 0, -4) else Vector3.new(-10, 0, 4)
					self:MoveModel(child, root.Position + coverOffset)
				end
			end
		end
	elseif command == "Move" or command == "Rally" then
		for _, child in ipairs(field:GetChildren()) do
			if child:IsA("Model") and child.Name:find("Enemy") then
				local root = child.PrimaryPart
				if root then
					self:MoveModel(child, root.Position + Vector3.new(-4, 0, 0))
				end
			end
		end
	end
end

function WorldService:ClearFieldArena(player: Player)
	local field = Workspace:FindFirstChild("FieldMission_" .. player.UserId)
	if field then
		field:Destroy()
	end
end

return WorldService
