local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local WorldService = {}

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

local function makeTrooper(parent: Instance, name: string, position: Vector3, color: Color3)
	local model = Instance.new("Model")
	model.Name = name
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

function WorldService:Init(services)
	self.services = services
end

function WorldService:Start()
	self:BuildBase()
	print("[WorldService] ready")
end

function WorldService:BuildBase()
	if Workspace:FindFirstChild("MilitaryBase") then
		return
	end

	local base = Instance.new("Folder")
	base.Name = "MilitaryBase"
	base.Parent = Workspace

	makePart(base, "Base Ground", Vector3.new(180, 2, 140), Vector3.new(0, -8, 0), Color3.fromRGB(68, 82, 64))
	makePart(base, "Command Center", Vector3.new(28, 16, 22), Vector3.new(0, 1, -42), Color3.fromRGB(72, 82, 92))
	makePart(base, "Recruitment Office Pad", Vector3.new(22, 1, 18), Vector3.new(-55, -6.5, -20), Color3.fromRGB(83, 104, 76))
	makePart(base, "Training Ground Pad", Vector3.new(34, 1, 24), Vector3.new(-52, -6.5, 25), Color3.fromRGB(92, 88, 70))
	makePart(base, "Barracks Pad", Vector3.new(28, 1, 20), Vector3.new(42, -6.5, -18), Color3.fromRGB(88, 82, 72))
	makePart(base, "Medical Tent Pad", Vector3.new(24, 1, 18), Vector3.new(48, -6.5, 24), Color3.fromRGB(88, 72, 72))
	makePart(base, "Armory Pad", Vector3.new(22, 1, 18), Vector3.new(0, -6.5, 42), Color3.fromRGB(60, 64, 70))
	makePart(base, "Cash Generator", Vector3.new(12, 8, 12), Vector3.new(-76, -3, -55), Color3.fromRGB(92, 124, 76))
	makePart(base, "Supply Depot", Vector3.new(14, 8, 14), Vector3.new(74, -3, -54), Color3.fromRGB(112, 96, 64))
	makePart(base, "Mission Table", Vector3.new(20, 3, 12), Vector3.new(0, -5.5, -12), Color3.fromRGB(42, 48, 54))

	makeLabel(base, "COMMAND CENTER", Vector3.new(0, 13, -30))
	makeLabel(base, "RECRUIT", Vector3.new(-55, 0, -9))
	makeLabel(base, "TRAINING", Vector3.new(-52, 0, 40))
	makeLabel(base, "BARRACKS", Vector3.new(42, 0, -6))
	makeLabel(base, "MEDICAL", Vector3.new(48, 0, 36))
	makeLabel(base, "MISSION MAP", Vector3.new(0, 0, 0))
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
	makePart(field, "Field Ground", Vector3.new(140, 1, 100), Vector3.new(240, -7, 0), Color3.fromRGB(76, 86, 62))
	makePart(field, "Alpha Marker", Vector3.new(8, 8, 8), Vector3.new(210, -2.5, -18), Color3.fromRGB(68, 118, 190))
	makePart(field, "Bravo Marker", Vector3.new(8, 8, 8), Vector3.new(210, -2.5, 18), Color3.fromRGB(76, 148, 118))
	makeEnemy(field, "Enemy A", Vector3.new(278, -2, -22))
	makeEnemy(field, "Enemy B", Vector3.new(286, -2, 18))
	makePart(field, "Cover Wall 1", Vector3.new(5, 8, 28), Vector3.new(242, -2, -28), Color3.fromRGB(70, 72, 70))
	makePart(field, "Cover Wall 2", Vector3.new(5, 8, 28), Vector3.new(254, -2, 28), Color3.fromRGB(70, 72, 70))
	makeLabel(field, "FIELD MISSION", Vector3.new(240, 5, -48))
	makeLabel(field, "ALPHA: Follow", Vector3.new(210, 6, -30))
	makeLabel(field, "BRAVO: Follow", Vector3.new(210, 6, 30))

	local alphaIndex = 0
	local bravoIndex = 0

	for _, unit in ipairs(units) do
		local fireteamId = unit.fireteamId or "Alpha"
		local color = if fireteamId == "Bravo" then Color3.fromRGB(76, 148, 118) else Color3.fromRGB(68, 118, 190)
		local startPosition

		if fireteamId == "Bravo" then
			bravoIndex += 1
			startPosition = Vector3.new(202, -2, 12 + bravoIndex * 5)
		else
			alphaIndex += 1
			startPosition = Vector3.new(202, -2, -12 - alphaIndex * 5)
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
			Move = Vector3.new(238, -2, -18),
			Attack = Vector3.new(270, -2, -22),
			Hold = Vector3.new(224, -2, -18),
			Suppress = Vector3.new(250, -2, -25),
			Retreat = Vector3.new(204, -2, -18),
			Rally = Vector3.new(218, -2, -8),
		},
		Bravo = {
			Move = Vector3.new(238, -2, 18),
			Attack = Vector3.new(276, -2, 18),
			Hold = Vector3.new(224, -2, 18),
			Suppress = Vector3.new(252, -2, 25),
			Retreat = Vector3.new(204, -2, 18),
			Rally = Vector3.new(218, -2, 8),
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

	if command == "Attack" or command == "Suppress" then
		for _, child in ipairs(field:GetChildren()) do
			if child:IsA("Model") and child.Name:find("Enemy") then
				self:DamageEnemy(child, if command == "Suppress" then 8 else 14)
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
