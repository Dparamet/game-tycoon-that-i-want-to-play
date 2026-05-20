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

local function makeTouchPad(pad: Part, player: Player, onTouch: () -> ())
	local debounce = false
	pad.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local touchingPlayer = game.Players:GetPlayerFromCharacter(character)
			if touchingPlayer == player and not debounce then
				debounce = true
				task.delay(0.6, function()
					debounce = false
				end)
				onTouch()
			end
		end
	end)
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

	-- Create a model to group all the building parts
	local model = Instance.new("Model")
	model.Name = buildingId
	model.Parent = parent

	local pos = layout.position
	local size = layout.size
	local color = layout.color

	-- Helper to create parts parented to this model
	local function createBPart(name: string, pSize: Vector3, pPos: Vector3, pColor: Color3, material: Enum.Material?): Part
		local p = makePart(model, name, pSize, pPos, pColor)
		if material then
			p.Material = material
		end
		return p
	end

	-- Foundation: Standard base slab for all buildings
	local foundation = createBPart("Foundation", Vector3.new(size.X + 2, 0.8, size.Z + 2), pos - Vector3.new(0, size.Y/2 - 0.4, 0), Color3.fromRGB(44, 48, 52), Enum.Material.Concrete)

	if buildingId == "CommandCenter" then
		-- Command Center details:
		-- Main center block (first story)
		local baseBlock = createBPart("BaseBlock", Vector3.new(size.X - 2, size.Y - 6, size.Z - 2), pos - Vector3.new(0, 3, 0), color, Enum.Material.SmoothPlastic)
		-- Second story
		local upperBlock = createBPart("UpperBlock", Vector3.new(size.X - 8, 5, size.Z - 8), pos + Vector3.new(0, size.Y/2 - 2.5, 0), Color3.fromRGB(52, 60, 68), Enum.Material.SmoothPlastic)
		-- Command windows (neon light stripe in the front)
		createBPart("CommandWindow", Vector3.new(size.X - 12, 1.2, 0.4), pos + Vector3.new(0, size.Y/2 - 2, size.Z/2 - 4.2), Color3.fromRGB(120, 200, 255), Enum.Material.Neon)
		-- Four tall black corner pillars
		local pillarHeight = size.Y - 1
		local px = (size.X - 2)/2
		local pz = (size.Z - 2)/2
		local pColor = Color3.fromRGB(24, 28, 30)
		createBPart("PillarNW", Vector3.new(1.8, pillarHeight, 1.8), pos + Vector3.new(-px, 0.5, -pz), pColor, Enum.Material.Metal)
		createBPart("PillarNE", Vector3.new(1.8, pillarHeight, 1.8), pos + Vector3.new(px, 0.5, -pz), pColor, Enum.Material.Metal)
		createBPart("PillarSW", Vector3.new(1.8, pillarHeight, 1.8), pos + Vector3.new(-px, 0.5, pz), pColor, Enum.Material.Metal)
		createBPart("PillarSE", Vector3.new(1.8, pillarHeight, 1.8), pos + Vector3.new(px, 0.5, pz), pColor, Enum.Material.Metal)
		-- Helipad outline on roof
		createBPart("HelipadBorder", Vector3.new(size.X - 12, 0.25, size.Z - 12), pos + Vector3.new(0, size.Y/2 + 0.1, 0), Color3.fromRGB(196, 160, 74), Enum.Material.Concrete)
		createBPart("HelipadLine1", Vector3.new(1, 0.3, 8), pos + Vector3.new(0, size.Y/2 + 0.15, 0), Color3.fromRGB(196, 160, 74), Enum.Material.Neon)
		createBPart("HelipadLine2", Vector3.new(8, 0.3, 1), pos + Vector3.new(0, size.Y/2 + 0.15, 0), Color3.fromRGB(196, 160, 74), Enum.Material.Neon)

	elseif buildingId == "RecruitmentOffice" then
		-- Recruitment Office details:
		-- Main building block (rustic wood look)
		local cabin = createBPart("Cabin", Vector3.new(size.X - 2, size.Y - 1, size.Z - 2), pos, color, Enum.Material.WoodPlanks)
		-- Awning roof over porch
		local roof = createBPart("AwningRoof", Vector3.new(size.X, 1.2, size.Z - 2), pos + Vector3.new(0, size.Y/2 + 0.6, 0), Color3.fromRGB(64, 52, 44), Enum.Material.WoodPlanks)
		-- Porch supports
		createBPart("SupportL", Vector3.new(1, size.Y, 1), pos + Vector3.new(-size.X/2 + 1.5, 0, size.Z/2 - 1.5), Color3.fromRGB(92, 76, 60), Enum.Material.WoodPlanks)
		createBPart("SupportR", Vector3.new(1, size.Y, 1), pos + Vector3.new(size.X/2 - 1.5, 0, size.Z/2 - 1.5), Color3.fromRGB(92, 76, 60), Enum.Material.WoodPlanks)
		-- Flag pole with Faction banner
		local pole = createBPart("FlagPole", Vector3.new(0.6, size.Y + 8, 0.6), pos + Vector3.new(-size.X/2 + 2, 4, -size.Z/2 + 2), Color3.fromRGB(160, 164, 160), Enum.Material.Metal)
		createBPart("Banner", Vector3.new(4, 3, 0.3), pos + Vector3.new(-size.X/2 + 4, size.Y + 6, -size.Z/2 + 2), Color3.fromRGB(180, 50, 50), Enum.Material.Fabric)

	elseif buildingId == "TrainingGround" then
		-- Training Ground details:
		-- Dirt floor overlay
		local field = createBPart("DirtOverlay", Vector3.new(size.X - 1, 0.4, size.Z - 1), pos + Vector3.new(0, 0.2, 0), color, Enum.Material.Mud)
		-- Obstacle course crawl net
		createBPart("NetFrameL", Vector3.new(1, 4, 1), pos + Vector3.new(-size.X/4, 2, -size.Z/3), Color3.fromRGB(90, 76, 60), Enum.Material.WoodPlanks)
		createBPart("NetFrameR", Vector3.new(1, 4, 1), pos + Vector3.new(-size.X/4, 2, size.Z/3), Color3.fromRGB(90, 76, 60), Enum.Material.WoodPlanks)
		createBPart("CrawlNet", Vector3.new(0.25, 3.8, size.Z * 0.6), pos + Vector3.new(-size.X/4, 2, 0), Color3.fromRGB(44, 44, 44), Enum.Material.Fabric)
		-- Target shooting wooden dummies
		local function createDummy(dPos: Vector3)
			createBPart("DummyPost", Vector3.new(0.6, 3, 0.6), dPos + Vector3.new(0, 1.5, 0), Color3.fromRGB(112, 96, 76), Enum.Material.WoodPlanks)
			createBPart("DummyBody", Vector3.new(1.8, 2.2, 0.6), dPos + Vector3.new(0, 3, 0), Color3.fromRGB(140, 144, 140), Enum.Material.Fabric)
			createBPart("DummyHead", Vector3.new(1.1, 1.1, 1.1), dPos + Vector3.new(0, 4.4, 0), Color3.fromRGB(112, 96, 76), Enum.Material.WoodPlanks)
		end
		createDummy(pos + Vector3.new(size.X/4, 0, -size.Z/4))
		createDummy(pos + Vector3.new(size.X/4, 0, 0))
		createDummy(pos + Vector3.new(size.X/4, 0, size.Z/4))

	elseif buildingId == "Barracks" then
		-- Barracks details:
		-- Main concrete building block
		local mainHull = createBPart("MainHull", Vector3.new(size.X - 2, size.Y - 1, size.Z - 2), pos, color, Enum.Material.DiamondPlate)
		-- Concrete roof cap
		local roofCap = createBPart("RoofCap", Vector3.new(size.X + 0.8, 1, size.Z + 0.8), pos + Vector3.new(0, size.Y/2 + 0.5, 0), Color3.fromRGB(60, 64, 68), Enum.Material.Concrete)
		-- Row of lit neon windows on both sides
		for offsetZ = -size.Z/2 + 4, size.Z/2 - 4, 6 do
			createBPart("WindowL", Vector3.new(0.3, 2, 2.5), pos + Vector3.new(-size.X/2 + 0.9, 1.5, offsetZ), Color3.fromRGB(240, 220, 120), Enum.Material.Neon)
			createBPart("WindowR", Vector3.new(0.3, 2, 2.5), pos + Vector3.new(size.X/2 - 0.9, 1.5, offsetZ), Color3.fromRGB(240, 220, 120), Enum.Material.Neon)
		end

	elseif buildingId == "MedicalTent" then
		-- Medical Tent details:
		-- Canvas tent structures (using rotated WedgeParts or block/wedge combination)
		-- Main block foundation
		local mainBlock = createBPart("MainBlock", Vector3.new(size.X - 4, size.Y - 3, size.Z - 2), pos - Vector3.new(0, 1.5, 0), color, Enum.Material.Fabric)
		-- Left wedge roof
		local roofWedgeL = Instance.new("WedgePart")
		roofWedgeL.Name = "RoofWedgeL"
		roofWedgeL.Size = Vector3.new(size.X/2 - 1, 3, size.Z - 2)
		roofWedgeL.Position = pos + Vector3.new(-size.X/4 + 0.5, size.Y/2 - 1.5, 0)
		roofWedgeL.Color = color
		roofWedgeL.Material = Enum.Material.Fabric
		roofWedgeL.CFrame = roofWedgeL.CFrame * CFrame.Angles(0, math.pi/2, 0)
		roofWedgeL.Parent = model
		-- Right wedge roof
		local roofWedgeR = Instance.new("WedgePart")
		roofWedgeR.Name = "RoofWedgeR"
		roofWedgeR.Size = Vector3.new(size.X/2 - 1, 3, size.Z - 2)
		roofWedgeR.Position = pos + Vector3.new(size.X/4 - 0.5, size.Y/2 - 1.5, 0)
		roofWedgeR.Color = color
		roofWedgeR.Material = Enum.Material.Fabric
		roofWedgeR.CFrame = roofWedgeR.CFrame * CFrame.Angles(0, -math.pi/2, 0)
		roofWedgeR.Parent = model
		-- Red Cross symbol on the front face
		createBPart("CrossVert", Vector3.new(1.2, 4.5, 0.35), pos + Vector3.new(0, -0.5, size.Z/2 - 0.9), Color3.fromRGB(200, 44, 44), Enum.Material.SmoothPlastic)
		createBPart("CrossHoriz", Vector3.new(4.5, 1.2, 0.35), pos + Vector3.new(0, -0.5, size.Z/2 - 0.85), Color3.fromRGB(200, 44, 44), Enum.Material.SmoothPlastic)

	elseif buildingId == "Armory" then
		-- Armory details:
		-- Heavy metallic bunker block
		local bunker = createBPart("Bunker", Vector3.new(size.X - 2, size.Y - 2, size.Z - 2), pos - Vector3.new(0, 1, 0), color, Enum.Material.Metal)
		-- Sliding blast doors
		createBPart("BlastDoorL", Vector3.new(size.X * 0.35, size.Y - 3, 0.6), pos + Vector3.new(-size.X * 0.18, -1.5, size.Z/2 - 1.2), Color3.fromRGB(34, 38, 42), Enum.Material.Metal)
		createBPart("BlastDoorR", Vector3.new(size.X * 0.35, size.Y - 3, 0.6), pos + Vector3.new(size.X * 0.18, -1.5, size.Z/2 - 1.2), Color3.fromRGB(34, 38, 42), Enum.Material.Metal)
		-- Glowing active neon stripe on front wall
		createBPart("ActiveStripe", Vector3.new(size.X - 6, 0.6, 0.4), pos + Vector3.new(0, size.Y/2 - 2, size.Z/2 - 1.1), Color3.fromRGB(80, 220, 110), Enum.Material.Neon)

	elseif buildingId == "CashGenerator" then
		-- Cash Generator details:
		-- Mini industrial generator block
		local generator = createBPart("Generator", Vector3.new(size.X - 2, size.Y - 2, size.Z - 2), pos - Vector3.new(0, 1, 0), color, Enum.Material.CorrodedMetal)
		-- Transformer box Details:
		createBPart("TransformerBox", Vector3.new(size.X - 5, 2.5, size.Z - 5), pos + Vector3.new(0, size.Y/2 - 1.8, 0), Color3.fromRGB(30, 34, 38), Enum.Material.Metal)
		-- Safety warning stripes
		for i = -3, 3, 2 do
			createBPart("WarningStripe" .. i, Vector3.new(0.6, 2.3, 0.2), pos + Vector3.new(i * 1.5, size.Y/2 - 1.8, size.Z/2 - 1.2), Color3.fromRGB(196, 160, 74), Enum.Material.SmoothPlastic)
		end
		-- Solar panels tilted toward sun
		createBPart("PanelStem", Vector3.new(0.8, 3.5, 0.8), pos + Vector3.new(0, size.Y/2 + 0.75, 0), Color3.fromRGB(44, 44, 44), Enum.Material.Metal)
		local panelBoard = createBPart("PanelBoard", Vector3.new(size.X - 2, 0.4, size.Z - 2), pos + Vector3.new(0, size.Y/2 + 2.7, 0), Color3.fromRGB(24, 48, 88), Enum.Material.Glass)
		panelBoard.CFrame = panelBoard.CFrame * CFrame.Angles(math.rad(15), 0, 0)

		-- --- PHYSICAL TYCOON SYSTEM: Conveyor, Collector & Dropper Loop ---
		-- Spawn the physical Conveyor belt
		local conveyorPos = Vector3.new(-67.5, 2.6, -55)
		local conveyorSize = Vector3.new(13, 0.6, 4.5)
		local conveyor = makePart(parent, "GeneratorConveyor", conveyorSize, conveyorPos, Color3.fromRGB(28, 32, 35))
		conveyor.Material = Enum.Material.SmoothPlastic
		conveyor.Anchored = true
		conveyor.AssemblyLinearVelocity = Vector3.new(12, 0, 0) -- Pushes parts along positive X direction

		-- Conveyor guard rails
		makePart(parent, "ConveyorRailN", Vector3.new(13, 1, 0.4), conveyorPos + Vector3.new(0, 0.6, -2.45), Color3.fromRGB(60, 60, 60))
		makePart(parent, "ConveyorRailS", Vector3.new(13, 1, 0.4), conveyorPos + Vector3.new(0, 0.6, 2.45), Color3.fromRGB(60, 60, 60))

		-- Dropper Nozzle at Generator side
		local nozzle = makePart(model, "DropperNozzle", Vector3.new(2, 1.5, 2), pos + Vector3.new(size.X/2 - 0.5, size.Y/2 - 2, 0), Color3.fromRGB(24, 28, 30), Enum.Material.Metal)

		-- Collector hopper at the end of the conveyor
		local collectorPos = Vector3.new(-58, 2.6, -55)
		local collectorTrigger = makePart(parent, "CashCollectorTrigger", Vector3.new(4, 1.2, 5), collectorPos, Color3.fromRGB(50, 220, 110))
		collectorTrigger.Material = Enum.Material.Neon
		collectorTrigger.Transparency = 0.5
		collectorTrigger.CanCollide = false
		collectorTrigger.Anchored = true

		local player = game.Players:GetPlayerFromCharacter(parent.Parent) or game.Players:GetPlayerFromCharacter(parent)
		if not player then
			local userId = tonumber(parent.Name:match("%d+"))
			if userId then
				player = game.Players:GetPlayerByUserId(userId)
			end
		end

		if player then
			-- Connect touched event for the cash collector trigger
			collectorTrigger.Touched:Connect(function(otherPart)
				if otherPart.Name == "CashOre" and otherPart:GetAttribute("OwnerId") == player.UserId then
					otherPart:Destroy()
					
					-- Visual pulse effect on collector
					local originalColor = collectorTrigger.Color
					collectorTrigger.Color = Color3.fromRGB(255, 255, 255)
					task.delay(0.1, function()
						if collectorTrigger and collectorTrigger.Parent then
							collectorTrigger.Color = originalColor
						end
					end)

					-- Add cash to player
					self.services.EconomyService:Add(player, { cash = 10, supplies = 0 })
					self:NotifyPlayer(player, "CollectCashOre", true, "+$10 Cash generated!")
				end
			end)

			-- Active Dropper loop
			task.spawn(function()
				while generator and generator.Parent and parent and parent.Parent do
					task.wait(2.2)
					-- Spawn a physical Cash Ore box at nozzle position
					local ore = Instance.new("Part")
					ore.Name = "CashOre"
					ore.Size = Vector3.new(1.4, 1.2, 1.4)
					ore.Position = nozzle.Position - Vector3.new(0, 1.8, 0)
					ore.Color = Color3.fromRGB(80, 220, 110)
					ore.Material = Enum.Material.Neon
					ore.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.3, 0.4)
					ore:SetAttribute("OwnerId", player.UserId)
					ore.Parent = parent

					-- Cleanup after 10s if it falls off conveyor
					task.delay(10, function()
						if ore and ore.Parent then
							ore:Destroy()
						end
					end)
				end
			end)
		end

	elseif buildingId == "SupplyDepot" then
		-- Supply Depot details:
		-- Awning frame
		local depot = createBPart("DepotPostFL", Vector3.new(0.8, size.Y - 1, 0.8), pos + Vector3.new(-size.X/2 + 1.2, -0.5, size.Z/2 - 1.2), Color3.fromRGB(50, 50, 50), Enum.Material.Metal)
		createBPart("DepotPostFR", Vector3.new(0.8, size.Y - 1, 0.8), pos + Vector3.new(size.X/2 - 1.2, -0.5, size.Z/2 - 1.2), Color3.fromRGB(50, 50, 50), Enum.Material.Metal)
		createBPart("DepotPostBL", Vector3.new(0.8, size.Y - 1, 0.8), pos + Vector3.new(-size.X/2 + 1.2, -0.5, -size.Z/2 + 1.2), Color3.fromRGB(50, 50, 50), Enum.Material.Metal)
		createBPart("DepotPostBR", Vector3.new(0.8, size.Y - 1, 0.8), pos + Vector3.new(size.X/2 - 1.2, -0.5, -size.Z/2 + 1.2), Color3.fromRGB(50, 50, 50), Enum.Material.Metal)
		-- Awning roof canopy
		createBPart("Canopy", Vector3.new(size.X, 0.8, size.Z), pos + Vector3.new(0, size.Y/2 - 0.8, 0), color, Enum.Material.Fabric)
		-- Storage crates underneath awning
		createBPart("WoodenCrate1", Vector3.new(4, 4, 4), pos + Vector3.new(-3, -2, -2), Color3.fromRGB(150, 114, 76), Enum.Material.Wood)
		createBPart("WoodenCrate2", Vector3.new(3.5, 3.5, 3.5), pos + Vector3.new(3.2, -2.25, -2.2), Color3.fromRGB(130, 96, 60), Enum.Material.Wood)
		-- Barrel cylinders underneath awning
		createBPart("MetalBarrel1", Vector3.new(2.8, 4.2, 2.8), pos + Vector3.new(-2.8, -1.9, 3.2), Color3.fromRGB(80, 84, 88), Enum.Material.Metal)
		createBPart("MetalBarrel2", Vector3.new(2.8, 4.2, 2.8), pos + Vector3.new(2.8, -1.9, 3.2), Color3.fromRGB(80, 84, 88), Enum.Material.Metal)

		-- --- PHYSICAL TYCOON SYSTEM: Conveyor, Collector & Dropper Loop ---
		-- Spawn the physical Conveyor belt
		local conveyorPos = Vector3.new(65.5, 2.6, -54)
		local conveyorSize = Vector3.new(13, 0.6, 4.5)
		local conveyor = makePart(parent, "DepotConveyor", conveyorSize, conveyorPos, Color3.fromRGB(28, 32, 35))
		conveyor.Material = Enum.Material.SmoothPlastic
		conveyor.Anchored = true
		conveyor.AssemblyLinearVelocity = Vector3.new(-12, 0, 0) -- Pushes parts westbound (negative X direction)

		-- Conveyor guard rails
		makePart(parent, "ConveyorRailN_S", Vector3.new(13, 1, 0.4), conveyorPos + Vector3.new(0, 0.6, -2.45), Color3.fromRGB(60, 60, 60))
		makePart(parent, "ConveyorRailS_S", Vector3.new(13, 1, 0.4), conveyorPos + Vector3.new(0, 0.6, 2.45), Color3.fromRGB(60, 60, 60))

		-- Dropper Nozzle at Depot side
		local nozzle = makePart(model, "DropperNozzle_S", Vector3.new(2, 1.5, 2), pos + Vector3.new(-size.X/2 + 0.5, size.Y/2 - 2, 0), Color3.fromRGB(24, 28, 30), Enum.Material.Metal)

		-- Collector hopper at the end of the conveyor
		local collectorPos = Vector3.new(58, 2.6, -54)
		local collectorTrigger = makePart(parent, "SupplyCollectorTrigger", Vector3.new(4, 1.2, 5), collectorPos, Color3.fromRGB(70, 110, 160))
		collectorTrigger.Material = Enum.Material.Neon
		collectorTrigger.Transparency = 0.5
		collectorTrigger.CanCollide = false
		collectorTrigger.Anchored = true

		local player = game.Players:GetPlayerFromCharacter(parent.Parent) or game.Players:GetPlayerFromCharacter(parent)
		if not player then
			local userId = tonumber(parent.Name:match("%d+"))
			if userId then
				player = game.Players:GetPlayerByUserId(userId)
			end
		end

		if player then
			-- Connect touched event for the supply collector trigger
			collectorTrigger.Touched:Connect(function(otherPart)
				if otherPart.Name == "SupplyCrate" and otherPart:GetAttribute("OwnerId") == player.UserId then
					otherPart:Destroy()
					
					-- Visual pulse effect on collector
					local originalColor = collectorTrigger.Color
					collectorTrigger.Color = Color3.fromRGB(255, 255, 255)
					task.delay(0.1, function()
						if collectorTrigger and collectorTrigger.Parent then
							collectorTrigger.Color = originalColor
						end
					end)

					-- Add supplies to player
					self.services.EconomyService:Add(player, { cash = 0, supplies = 2 })
					self:NotifyPlayer(player, "CollectSupplyCrate", true, "+2 Supplies generated!")
				end
			end)

			-- Active Dropper loop
			task.spawn(function()
				while depot and depot.Parent and parent and parent.Parent do
					task.wait(2.5)
					-- Spawn a physical Supply Crate box at nozzle position
					local ore = Instance.new("Part")
					ore.Name = "SupplyCrate"
					ore.Size = Vector3.new(1.4, 1.2, 1.4)
					ore.Position = nozzle.Position - Vector3.new(0, 1.8, 0)
					ore.Color = Color3.fromRGB(70, 110, 160)
					ore.Material = Enum.Material.Neon
					ore.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.3, 0.4)
					ore:SetAttribute("OwnerId", player.UserId)
					ore.Parent = parent

					-- Cleanup after 10s if it falls off conveyor
					task.delay(10, function()
						if ore and ore.Parent then
							ore:Destroy()
						end
					end)
				end
			end)
		end
	end

	-- Make building label
	makeLabel(model, layout.label, pos + Vector3.new(0, size.Y/2 + 5, size.Z/2 + 1))
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

	makeTouchPad(collector, player, function()
		local ok, msg = self.services.EconomyService:ClaimIncome(player)
		self:NotifyPlayer(player, "ClaimIncome", ok, msg)
	end)

	local supplyCollector = makePart(parent, "Supply Collector Pad", Vector3.new(18, 0.8, 14), Vector3.new(58, 2.8, -54), Color3.fromRGB(70, 110, 160))
	supplyCollector.Material = Enum.Material.Neon
	makeGroundLabel(parent, "COLLECT SUPPLIES", Vector3.new(58, 3.3, -54), Vector3.new(16, 0.2, 5))

	makeTouchPad(supplyCollector, player, function()
		local ok, msg = self.services.EconomyService:ClaimIncome(player)
		self:NotifyPlayer(player, "ClaimIncome", ok, msg)
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

	makeTouchPad(pad, player, function()
		if self.services.BaseService:BuyBuilding(player, buildingId) then
			self:RefreshBase(player)
			self:NotifyPlayer(player, "BuyBuilding", true, "Purchased " .. layout.label)
		else
			self:NotifyPlayer(player, "BuyBuilding", false, "Cannot afford " .. layout.label)
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

	makeTouchPad(pad, player, function()
		if self.services.BaseService:UpgradeCommandCenter(player) then
			self:RefreshBase(player)
			self:NotifyPlayer(player, "UpgradeCommandCenter", true, "Command Center upgraded")
		else
			self:NotifyPlayer(player, "UpgradeCommandCenter", false, "Cannot afford Command Center upgrade")
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
