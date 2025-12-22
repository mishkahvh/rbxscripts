-- Phantom GUI V4 (Full Featured)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

if _G.PhantomGui then _G.PhantomGui:Destroy() end

local connections = {}

-- Teleport Locations
local LOCATIONS = {
	{name = "Gun Place", x = 192.16, y = 23.24, z = -212.87, autoGrab = true},
	{name = "Keycard", x = -14.41, y = 22.13, z = -27.27, autoGrab = true},
	{name = "Outside", x = 197.83, y = 9.74, z = 83.40},
	{name = "Prison Cell", x = 24.98, y = 22.13, z = -50.68},
	{name = "Cafe", x = 99.83, y = 11.23, z = 28.35},
	{name = "Directors Office", x = 123.79, y = 23.08, z = -99.76},
	{name = "Booking", x = 187.83, y = 11.22, z = -135.26},
	{name = "Tunnels", x = 96.06, y = -8.88, z = -216.29},
	{name = "Min/Med Block", x = -7.21, y = 11.22, z = -63.56},
	{name = "Gym", x = 24.51, y = 22.17, z = 3.36},
	{name = "Barnside", x = 18.26, y = 10.02, z = 41.34},
	{name = "Front Gate", x = 20.34, y = 7.61, z = 45.57}
}

local TEAM_COLORS = {
	["Booking"] = Color3.fromRGB(100, 100, 255),
	["Civilian"] = Color3.fromRGB(180, 180, 180),
	["Department of Corrections"] = Color3.fromRGB(70, 130, 220),
	["Escapee"] = Color3.fromRGB(255, 140, 0),
	["Maximum Security"] = Color3.fromRGB(255, 70, 70),
	["Medium Security"] = Color3.fromRGB(255, 110, 110),
	["Mental Patient"] = Color3.fromRGB(180, 70, 180),
	["Menu"] = Color3.fromRGB(128, 128, 128),
	["Minimum Security"] = Color3.fromRGB(255, 150, 150),
	["Sheriff's Office"] = Color3.fromRGB(255, 200, 70),
	["State Police"] = Color3.fromRGB(70, 150, 255),
	["VCSO-SWAT"] = Color3.fromRGB(50, 70, 170),
	["WeaponsTester"] = Color3.fromRGB(70, 255, 70)
}

local TARGET_TEAMS = {"Minimum Security", "Medium Security", "Maximum Security", "Escapee", "State Police", "Department of Corrections"}

-- Settings
local Settings = {
	-- ESP
	espEnabled = false, showName = false, showTeam = false, showDistance = false, showHealth = false, showBox = false, espTeams = {},
	-- Aim
	aimEnabled = false, aimSmoothness = 0.35, aimFOV = 90, aimPart = "Head", aimHoldKey = "Q", showFOV = false, wallCheck = false, stickyAim = false, aimTeams = {},
	-- Visual
	crosshairEnabled = false, crosshairStyle = "Cross", crosshairColor = {255, 255, 255}, targetInfoEnabled = false,
	-- Movement
	bhop = false, infJump = false, infStamina = false, fly = false, noclip = false, flySpeed = 50, jumpPower = 50, walkSpeed = 16,
	-- Cops
	noPepper = false, antiCuff = false, noStun = false,
	-- Fun
	spinbot = false, spinSpeed = 10,
	-- Extra
	infZoom = false, autoPickup = false,
	-- Effects
	fullBright = false, noFog = false, fov = 70,
	-- Gun
	noRecoil = false, noSpread = false,
	-- GUI
	toggleGuiKey = "M"
}

for teamName, _ in pairs(TEAM_COLORS) do
	Settings.espTeams[teamName] = false
	Settings.aimTeams[teamName] = false
end

pcall(function()
	if readfile then
		local loaded = HttpService:JSONDecode(readfile("PhantomSettings.json"))
		for k, v in pairs(loaded) do Settings[k] = v end
	end
end)

local function saveSettings()
	pcall(function()
		if writefile then writefile("PhantomSettings.json", HttpService:JSONEncode(Settings)) end
	end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PhantomGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
_G.PhantomGui = gui

local function destroyGui()
	saveSettings()
	for _, conn in pairs(connections) do
		if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then conn:Disconnect() end
	end
	_G.PhantomGui = nil
	gui:Destroy()
end

-- Colors
local Colors = {
	bg = Color3.fromRGB(12, 10, 16),
	card = Color3.fromRGB(20, 18, 26),
	cardHover = Color3.fromRGB(28, 24, 36),
	accent = Color3.fromRGB(130, 50, 200),
	accentBright = Color3.fromRGB(160, 80, 255),
	text = Color3.fromRGB(240, 240, 245),
	textDim = Color3.fromRGB(140, 135, 160),
	success = Color3.fromRGB(80, 200, 120),
	danger = Color3.fromRGB(220, 60, 80),
	warning = Color3.fromRGB(255, 160, 50)
}

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 620)
main.Position = UDim2.new(0.5, -260, 0.5, -310)
main.BackgroundColor3 = Colors.bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Colors.accent
mainStroke.Thickness = 2
mainStroke.Transparency = 0.5

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = Colors.card
header.BorderSizePixel = 0
header.Active = true
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Colors.card
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Accent line
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.Position = UDim2.new(0, 0, 1, -3)
accent.BorderSizePixel = 0
accent.Parent = header
local accentGrad = Instance.new("UIGradient", accent)
accentGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 30, 180)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 80, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 30, 180))
})

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0, 14, 0.5, -18)
logo.BackgroundColor3 = Colors.accent
logo.Text = "👻"
logo.TextSize = 18
logo.Parent = header
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 0, 26)
title.Position = UDim2.new(0, 58, 0, 10)
title.BackgroundTransparency = 1
title.Text = "PHANTOM"
title.TextColor3 = Colors.text
title.TextSize = 22
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 200, 0, 14)
subtitle.Position = UDim2.new(0, 58, 0, 34)
subtitle.BackgroundTransparency = 1
subtitle.Text = "v4.0 • by Mishka"
subtitle.TextColor3 = Colors.accent
subtitle.TextSize = 11
subtitle.Font = Enum.Font.GothamSemibold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Header buttons
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -44, 0.5, -16)
closeBtn.BackgroundColor3 = Colors.danger
closeBtn.BackgroundTransparency = 0.85
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.danger
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(destroyGui)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -82, 0.5, -16)
minBtn.BackgroundColor3 = Colors.warning
minBtn.BackgroundTransparency = 0.85
minBtn.Text = "─"
minBtn.TextColor3 = Colors.warning
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 44)
tabContainer.Position = UDim2.new(0, 12, 0, 62)
tabContainer.BackgroundColor3 = Colors.card
tabContainer.BorderSizePixel = 0
tabContainer.Parent = main
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, -8, 1, -8)
tabBar.Position = UDim2.new(0, 4, 0, 4)
tabBar.BackgroundTransparency = 1
tabBar.ScrollBarThickness = 0
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
tabBar.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -122)
content.Position = UDim2.new(0, 12, 0, 112)
content.BackgroundColor3 = Colors.card
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		content.Visible = false
		tabContainer.Visible = false
		main.Size = UDim2.new(0, 520, 0, 56)
		minBtn.Text = "+"
	else
		main.Size = UDim2.new(0, 520, 0, 620)
		content.Visible = true
		tabContainer.Visible = true
		minBtn.Text = "─"
	end
end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
table.insert(connections, header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end))
table.insert(connections, header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))

-- Tab system
local tabs = {}
local currentTab = nil

local function createTab(name, icon)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 70, 0, 36)
	btn.BackgroundColor3 = Colors.cardHover
	btn.BackgroundTransparency = 0.6
	btn.Text = icon .. " " .. name
	btn.TextColor3 = Colors.textDim
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = tabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, -16, 1, -16)
	frame.Position = UDim2.new(0, 8, 0, 8)
	frame.BackgroundTransparency = 1
	frame.ScrollBarThickness = 3
	frame.ScrollBarImageColor3 = Colors.accent
	frame.ScrollBarImageTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	frame.Parent = content

	local layout = Instance.new("UIListLayout", frame)
	layout.Padding = UDim.new(0, 8)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	tabs[name] = {btn = btn, frame = frame}

	btn.MouseButton1Click:Connect(function()
		if currentTab then
			currentTab.btn.BackgroundColor3 = Colors.cardHover
			currentTab.btn.BackgroundTransparency = 0.6
			currentTab.btn.TextColor3 = Colors.textDim
			currentTab.frame.Visible = false
		end
		currentTab = tabs[name]
		btn.BackgroundColor3 = Colors.accent
		btn.BackgroundTransparency = 0
		btn.TextColor3 = Colors.text
		frame.Visible = true
	end)

	return frame
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════

local function createSection(parent, text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 26)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local line1 = Instance.new("Frame")
	line1.Size = UDim2.new(0.2, 0, 0, 1)
	line1.Position = UDim2.new(0, 0, 0.5, 0)
	line1.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
	line1.BorderSizePixel = 0
	line1.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0.2, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.accent
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.Parent = container

	local line2 = Instance.new("Frame")
	line2.Size = UDim2.new(0.2, 0, 0, 1)
	line2.Position = UDim2.new(0.8, 0, 0.5, 0)
	line2.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
	line2.BorderSizePixel = 0
	line2.Parent = container
end

local function createToggle(parent, text, default, callback, keybindSetting)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -120, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.text
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	-- Keybind button (if applicable)
	local keyBtn = nil
	if keybindSetting then
		keyBtn = Instance.new("TextButton")
		keyBtn.Size = UDim2.new(0, 44, 0, 24)
		keyBtn.Position = UDim2.new(1, -106, 0.5, -12)
		keyBtn.BackgroundColor3 = Color3.fromRGB(40, 36, 50)
		keyBtn.Text = Settings[keybindSetting] or "None"
		keyBtn.TextColor3 = Colors.textDim
		keyBtn.TextSize = 9
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.BorderSizePixel = 0
		keyBtn.Parent = frame
		Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)

		keyBtn.MouseButton1Click:Connect(function()
			keyBtn.Text = "..."
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp then return end
				if input.KeyCode ~= Enum.KeyCode.Unknown then
					Settings[keybindSetting] = input.KeyCode.Name
					keyBtn.Text = input.KeyCode.Name
					conn:Disconnect()
					saveSettings()
				end
			end)
		end)
	end

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 44, 0, 24)
	toggleBg.Position = UDim2.new(1, -56, 0.5, -12)
	toggleBg.BackgroundColor3 = default and Colors.success or Color3.fromRGB(50, 46, 60)
	toggleBg.Text = ""
	toggleBg.BorderSizePixel = 0
	toggleBg.AutoButtonColor = false
	toggleBg.Parent = frame
	Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = Colors.text
	knob.BorderSizePixel = 0
	knob.Parent = toggleBg
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isOn = default
	toggleBg.MouseButton1Click:Connect(function()
		isOn = not isOn
		toggleBg.BackgroundColor3 = isOn and Colors.success or Color3.fromRGB(50, 46, 60)
		knob.Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		callback(isOn)
	end)

	return {setOn = function(on)
		isOn = on
		toggleBg.BackgroundColor3 = isOn and Colors.success or Color3.fromRGB(50, 46, 60)
		knob.Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	end}
end

local function createButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = color or Colors.accent
	btn.Text = text
	btn.TextColor3 = Colors.text
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 54)
	frame.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 0, 22)
	label.Position = UDim2.new(0, 14, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.text
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.35, -14, 0, 22)
	valueLabel.Position = UDim2.new(0.65, 0, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(math.floor(default))
	valueLabel.TextColor3 = Colors.accent
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -28, 0, 8)
	track.Position = UDim2.new(0, 14, 0, 34)
	track.BackgroundColor3 = Color3.fromRGB(40, 36, 50)
	track.BorderSizePixel = 0
	track.Parent = frame
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Colors.accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
	knob.BackgroundColor3 = Colors.text
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false
	local sliderConn = nil

	local function update(pos)
		local p = math.clamp(pos, 0, 1)
		local value = min + p * (max - min)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, -8, 0.5, -8)
		valueLabel.Text = tostring(math.floor(value))
		callback(value)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			sliderConn = UserInputService.InputChanged:Connect(function(inp)
				if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
					update(math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
				end
			end)
		end
	end)

	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
			if sliderConn then sliderConn:Disconnect() end
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			update(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
		end
	end)

	return frame
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO GRAB
-- ═══════════════════════════════════════════════════════════════

local isBusy = false
local function getItemCount()
	local n = 0
	local bp = player:FindFirstChild("Backpack")
	if bp then n = #bp:GetChildren() end
	local c = player.Character
	if c then for _, v in pairs(c:GetChildren()) do if v:IsA("Tool") then n = n + 1 end end end
	return n
end

local function autoGrab(loc, btn, cb)
	local c = player.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then cb(false) return end
	local root = c.HumanoidRootPart
	local origCF = root.CFrame
	local before = getItemCount()
	root.CFrame = CFrame.new(loc.x, loc.y, loc.z)
	btn.Text = "⏳"
	for i = 1, 25 do
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
				if (v.Parent.Position - root.Position).Magnitude < 15 then
					pcall(fireproximityprompt, v)
				end
			end
		end
		task.wait(0.1)
		if getItemCount() > before then
			root.CFrame = origCF
			cb(true)
			return
		end
	end
	root.CFrame = origCF
	cb(false)
end

local function createLocBtn(parent, loc)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 4, 0, 22)
	icon.Position = UDim2.new(0, 10, 0.5, -11)
	icon.BackgroundColor3 = loc.autoGrab and Colors.warning or Colors.accent
	icon.BorderSizePixel = 0
	icon.Parent = frame
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 2)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -90, 1, 0)
	label.Position = UDim2.new(0, 22, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = loc.name
	label.TextColor3 = Colors.text
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btnColor = loc.autoGrab and Colors.warning or Colors.accent
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 54, 0, 26)
	btn.Position = UDim2.new(1, -66, 0.5, -13)
	btn.BackgroundColor3 = btnColor
	btn.Text = loc.autoGrab and "GRAB" or "GO"
	btn.TextColor3 = Colors.text
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		if isBusy then return end
		local c = player.Character
		if not c or not c:FindFirstChild("HumanoidRootPart") then return end
		isBusy = true
		local origText = btn.Text
		if loc.autoGrab then
			autoGrab(loc, btn, function(ok)
				btn.Text = ok and "✓" or "✗"
				btn.BackgroundColor3 = ok and Colors.success or Colors.danger
				task.wait(0.3)
				btn.Text = origText
				btn.BackgroundColor3 = btnColor
				isBusy = false
			end)
		else
			btn.Text = "⏳"
			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "✓"
			btn.BackgroundColor3 = Colors.success
			task.wait(0.3)
			btn.Text = origText
			btn.BackgroundColor3 = btnColor
			isBusy = false
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- TELEPORTS TAB
-- ═══════════════════════════════════════════════════════════════
local tpFrame = createTab("TP", "📍")
createSection(tpFrame, "Locations")
for _, loc in ipairs(LOCATIONS) do createLocBtn(tpFrame, loc) end

-- ═══════════════════════════════════════════════════════════════
-- PLAYERS TAB
-- ═══════════════════════════════════════════════════════════════
local playersFrame = createTab("Players", "👥")
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, 0, 0, 0)
playerListFrame.BackgroundTransparency = 1
playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
playerListFrame.Parent = playersFrame
Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 6)

local function refreshPlayerList()
	for _, child in pairs(playerListFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 40)
			frame.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
			frame.BorderSizePixel = 0
			frame.Parent = playerListFrame
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

			local teamName = p.Team and p.Team.Name or "Civilian"
			local teamColor = TEAM_COLORS[teamName] or Colors.textDim

			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0, 12, 0.5, -4)
			dot.BackgroundColor3 = teamColor
			dot.BorderSizePixel = 0
			dot.Parent = frame
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, -100, 0, 18)
			nameLabel.Position = UDim2.new(0, 28, 0, 4)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = p.Name
			nameLabel.TextColor3 = Colors.text
			nameLabel.TextSize = 11
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = frame

			local teamLabel = Instance.new("TextLabel")
			teamLabel.Size = UDim2.new(1, -100, 0, 12)
			teamLabel.Position = UDim2.new(0, 28, 0, 22)
			teamLabel.BackgroundTransparency = 1
			teamLabel.Text = teamName
			teamLabel.TextColor3 = teamColor
			teamLabel.TextSize = 9
			teamLabel.Font = Enum.Font.Gotham
			teamLabel.TextXAlignment = Enum.TextXAlignment.Left
			teamLabel.Parent = frame

			local tpBtn = Instance.new("TextButton")
			tpBtn.Size = UDim2.new(0, 48, 0, 24)
			tpBtn.Position = UDim2.new(1, -60, 0.5, -12)
			tpBtn.BackgroundColor3 = Colors.accent
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Colors.text
			tpBtn.TextSize = 10
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.BorderSizePixel = 0
			tpBtn.Parent = frame
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

			tpBtn.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
				end
			end)
		end
	end
end

createSection(playersFrame, "Player List")
createButton(playersFrame, "🔄  Refresh List", Color3.fromRGB(50, 46, 65), refreshPlayerList)
refreshPlayerList()
table.insert(connections, Players.PlayerAdded:Connect(refreshPlayerList))
table.insert(connections, Players.PlayerRemoving:Connect(refreshPlayerList))

-- ═══════════════════════════════════════════════════════════════
-- MOVEMENT TAB
-- ═══════════════════════════════════════════════════════════════
local moveFrame = createTab("Move", "🏃")

createSection(moveFrame, "Movement")
createToggle(moveFrame, "Bhop", Settings.bhop, function(on) Settings.bhop = on saveSettings() end)
createToggle(moveFrame, "Infinite Jump", Settings.infJump, function(on) Settings.infJump = on saveSettings() end)
createToggle(moveFrame, "Infinite Stamina", Settings.infStamina, function(on) Settings.infStamina = on saveSettings() end)
createToggle(moveFrame, "Fly", Settings.fly, function(on) Settings.fly = on saveSettings() end)
createToggle(moveFrame, "Noclip", Settings.noclip, function(on) Settings.noclip = on saveSettings() end)

createSection(moveFrame, "Speed Settings")
createSlider(moveFrame, "Fly Speed", 10, 200, Settings.flySpeed, function(v) Settings.flySpeed = v end)
createSlider(moveFrame, "Walk Speed", 16, 100, Settings.walkSpeed, function(v)
	Settings.walkSpeed = v
	local c = player.Character
	if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
end)
createSlider(moveFrame, "Jump Power", 50, 200, Settings.jumpPower, function(v)
	Settings.jumpPower = v
	local c = player.Character
	if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
end)

-- Movement loops
local flying = false
local flyBV, flyBG = nil, nil

table.insert(connections, RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end

	-- Infinite Stamina
	if Settings.infStamina then
		for _, v in pairs(char:GetDescendants()) do
			if v.Name == "Stamina" and v:IsA("NumberValue") then v.Value = 100 end
		end
	end

	-- Noclip
	if Settings.noclip then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end

	-- Fly
	if Settings.fly then
		if not flying then
			flying = true
			flyBV = Instance.new("BodyVelocity")
			flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			flyBV.Velocity = Vector3.zero
			flyBV.Parent = hrp
			flyBG = Instance.new("BodyGyro")
			flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			flyBG.P = 9e4
			flyBG.Parent = hrp
		end
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.flySpeed or Vector3.zero
		flyBG.CFrame = cam.CFrame
	else
		if flying then
			flying = false
			if flyBV then flyBV:Destroy() end
			if flyBG then flyBG:Destroy() end
		end
	end
end))

-- Infinite Jump
table.insert(connections, UserInputService.JumpRequest:Connect(function()
	if Settings.infJump then
		local c = player.Character
		if c and c:FindFirstChild("Humanoid") then
			c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end))

-- Bhop
table.insert(connections, RunService.Heartbeat:Connect(function()
	if Settings.bhop then
		local c = player.Character
		if c and c:FindFirstChild("Humanoid") then
			if c.Humanoid.FloorMaterial ~= Enum.Material.Air then
				c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end))

-- ═══════════════════════════════════════════════════════════════
-- COPS TAB
-- ═══════════════════════════════════════════════════════════════
local copsFrame = createTab("Cops", "🚔")

createSection(copsFrame, "Anti-Cop")
createToggle(copsFrame, "No Pepper Effect", Settings.noPepper, function(on) Settings.noPepper = on saveSettings() end)
createToggle(copsFrame, "Anti Cuff", Settings.antiCuff, function(on) Settings.antiCuff = on saveSettings() end)
createToggle(copsFrame, "No Stun", Settings.noStun, function(on) Settings.noStun = on saveSettings() end)

createSection(copsFrame, "Fun")
createToggle(copsFrame, "Spinbot", Settings.spinbot, function(on) Settings.spinbot = on saveSettings() end)
createSlider(copsFrame, "Spin Speed", 1, 50, Settings.spinSpeed, function(v) Settings.spinSpeed = v end)

-- Cops loops
table.insert(connections, RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	-- No Pepper
	if Settings.noPepper then
		local pepper = char:FindFirstChild("PepperEffect") or char:FindFirstChild("Peppered")
		if pepper then pepper:Destroy() end
		for _, v in pairs(char:GetDescendants()) do
			if v.Name:lower():find("pepper") then pcall(function() v:Destroy() end) end
		end
	end

	-- Anti Cuff
	if Settings.antiCuff then
		if humanoid then
			if humanoid.PlatformStand then humanoid.PlatformStand = false end
		end
		local cuffs = char:FindFirstChild("Cuffs") or char:FindFirstChild("Handcuffs")
		if cuffs then pcall(function() cuffs:Destroy() end) end
	end

	-- No Stun
	if Settings.noStun then
		local stun = char:FindFirstChild("Stun") or char:FindFirstChild("Stunned")
		if stun then pcall(function() stun:Destroy() end) end
		if humanoid then
			if humanoid.WalkSpeed < 10 then humanoid.WalkSpeed = Settings.walkSpeed end
		end
	end

	-- Spinbot
	if Settings.spinbot and hrp then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.spinSpeed), 0)
	end
end))

-- ═══════════════════════════════════════════════════════════════
-- EXTRA TAB
-- ═══════════════════════════════════════════════════════════════
local extraFrame = createTab("Extra", "⚡")

createSection(extraFrame, "Extra Features")
createToggle(extraFrame, "Infinite Zoom", Settings.infZoom, function(on)
	Settings.infZoom = on
	player.CameraMaxZoomDistance = on and 9999 or 128
	saveSettings()
end)
createToggle(extraFrame, "Auto Pickup", Settings.autoPickup, function(on) Settings.autoPickup = on saveSettings() end)

createSection(extraFrame, "Actions")
createButton(extraFrame, "💀  Suicide", Colors.danger, function()
	if player.Character then player.Character:BreakJoints() end
end)
createButton(extraFrame, "🔄  Respawn", Color3.fromRGB(60, 55, 80), function()
	if player.Character then player.Character:BreakJoints() end
end)

-- Auto Pickup loop
table.insert(connections, RunService.Heartbeat:Connect(function()
	if not Settings.autoPickup then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local pos = char.HumanoidRootPart.Position
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
			if (v.Parent.Position - pos).Magnitude < 10 then
				pcall(fireproximityprompt, v)
			end
		end
	end
end))

-- ═══════════════════════════════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════════════════════════════
local espFrame = createTab("ESP", "👁")

local function updateESP(plr)
	if plr == player then return end
	local char = plr.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	local humanoid = char:FindFirstChild("Humanoid")
	if not head then return end

	local teamName = plr.Team and plr.Team.Name or "Civilian"
	local teamColor = TEAM_COLORS[teamName] or Colors.textDim
	local shouldShow = Settings.espEnabled and (Settings.espTeams[teamName] == true)

	local old = head:FindFirstChild("PhantomESP")
	local oldH = char:FindFirstChild("PhantomHighlight")
	if old then old:Destroy() end
	if oldH then oldH:Destroy() end
	if not shouldShow then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "PhantomESP"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 100, 0, 50)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head

	local y = 0
	if Settings.showName then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 14)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = plr.Name
		l.TextColor3 = Colors.text
		l.TextSize = 11
		l.Font = Enum.Font.GothamBold
		l.TextStrokeTransparency = 0
		y = y + 14
	end
	if Settings.showTeam then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 12)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = teamName
		l.TextColor3 = teamColor
		l.TextSize = 9
		l.Font = Enum.Font.GothamSemibold
		l.TextStrokeTransparency = 0
		y = y + 13
	end
	if Settings.showDistance then
		local l = Instance.new("TextLabel", bb)
		l.Name = "Distance"
		l.Size = UDim2.new(1, 0, 0, 10)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = "[0m]"
		l.TextColor3 = Colors.textDim
		l.TextSize = 9
		l.Font = Enum.Font.Gotham
		l.TextStrokeTransparency = 0
		y = y + 12
	end
	if Settings.showHealth and humanoid then
		local bg = Instance.new("Frame", bb)
		bg.Size = UDim2.new(0.7, 0, 0, 4)
		bg.Position = UDim2.new(0.15, 0, 0, y + 2)
		bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		bg.BorderSizePixel = 0
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
		local fill = Instance.new("Frame", bg)
		fill.Name = "HealthFill"
		fill.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)
		fill.BackgroundColor3 = Colors.success
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	end
	if Settings.showBox then
		local hl = Instance.new("Highlight", char)
		hl.Name = "PhantomHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = teamColor
		hl.OutlineTransparency = 0.3
	end
end

local function refreshAllESP() for _, p in pairs(Players:GetPlayers()) do updateESP(p) end end
local function clearAllESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local h = p.Character:FindFirstChild("Head")
			if h then local e = h:FindFirstChild("PhantomESP") if e then e:Destroy() end end
			local hl = p.Character:FindFirstChild("PhantomHighlight") if hl then hl:Destroy() end
		end
	end
end

local distLoop = nil
local function startDistLoop()
	if distLoop then return end
	distLoop = task.spawn(function()
		while Settings.espEnabled and gui.Parent do
			local mc = player.Character
			if mc and mc:FindFirstChild("HumanoidRootPart") then
				local mp = mc.HumanoidRootPart.Position
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= player and p.Character then
						local h = p.Character:FindFirstChild("Head")
						local hrp = p.Character:FindFirstChild("HumanoidRootPart")
						if h and hrp then
							local esp = h:FindFirstChild("PhantomESP")
							if esp then
								local dl = esp:FindFirstChild("Distance")
								if dl then dl.Text = "[" .. math.floor((hrp.Position - mp).Magnitude) .. "m]" end
							end
						end
					end
				end
			end
			task.wait(0.2)
		end
		distLoop = nil
	end)
end

createSection(espFrame, "Main")
createToggle(espFrame, "Enable ESP", Settings.espEnabled, function(on)
	Settings.espEnabled = on
	if on then refreshAllESP() startDistLoop() else clearAllESP() end
	saveSettings()
end)

createSection(espFrame, "Visuals")
createToggle(espFrame, "Show Name", Settings.showName, function(on) Settings.showName = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)
createToggle(espFrame, "Show Team", Settings.showTeam, function(on) Settings.showTeam = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)
createToggle(espFrame, "Show Distance", Settings.showDistance, function(on) Settings.showDistance = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)
createToggle(espFrame, "Show Health", Settings.showHealth, function(on) Settings.showHealth = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)
createToggle(espFrame, "Show Outline", Settings.showBox, function(on) Settings.showBox = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)

createSection(espFrame, "Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(espFrame, tn, Settings.espTeams[tn] == true, function(on) Settings.espTeams[tn] = on if Settings.espEnabled then refreshAllESP() end saveSettings() end)
end

for _, p in pairs(Players:GetPlayers()) do
	if p ~= player then
		table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.5) if Settings.espEnabled then updateESP(p) end end))
	end
end
table.insert(connections, Players.PlayerAdded:Connect(function(p)
	table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.5) if Settings.espEnabled then updateESP(p) end end))
end))

-- ═══════════════════════════════════════════════════════════════
-- AIM TAB
-- ═══════════════════════════════════════════════════════════════
local aimFrame = createTab("Aim", "🎯")

local aimHoldKey = Enum.KeyCode[Settings.aimHoldKey] or Enum.KeyCode.Q
local isHolding = false
local stickyTarget = nil

local function isVisible(part)
	if not Settings.wallCheck then return true end
	local mc = player.Character
	if not mc then return false end
	local mh = mc:FindFirstChild("Head")
	if not mh then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {mc}
	local result = workspace:Raycast(mh.Position, (part.Position - mh.Position), params)
	if result then
		local tc = part:FindFirstAncestorOfClass("Model")
		return tc and result.Instance:IsDescendantOf(tc)
	end
	return true
end

local function getTarget()
	if Settings.stickyAim and stickyTarget then
		local c = stickyTarget.Character
		if c then
			local h = c:FindFirstChild("Humanoid")
			local p = c:FindFirstChild(Settings.aimPart) or c:FindFirstChild("Head")
			if h and h.Health > 0 and p and isVisible(p) then return p end
		end
		stickyTarget = nil
	end

	local cam = workspace.CurrentCamera
	local mc = player.Character
	if not cam or not mc or not mc:FindFirstChild("HumanoidRootPart") then return nil end
	local mp = mc.HumanoidRootPart.Position
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local closest, closestP, closestD = nil, nil, math.huge

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local tn = p.Team and p.Team.Name or "Civilian"
			if Settings.aimTeams[tn] then
				local c = p.Character
				local hrp = c:FindFirstChild("HumanoidRootPart")
				local h = c:FindFirstChild("Humanoid")
				if hrp and h and h.Health > 0 then
					local part = c:FindFirstChild(Settings.aimPart) or c:FindFirstChild("Head")
					if part and isVisible(part) and (hrp.Position - mp).Magnitude <= 200 then
						local sp, os = cam:WorldToScreenPoint(part.Position)
						if os then
							local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
							if sd <= Settings.aimFOV * 2 and sd < closestD then
								closestD = sd
								closest = part
								closestP = p
							end
						end
					end
				end
			end
		end
	end
	if Settings.stickyAim and closestP then stickyTarget = closestP end
	return closest
end

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.aimEnabled or not isHolding then
		if not isHolding then stickyTarget = nil end
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local t = getTarget()
	if t then
		cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, t.Position), Settings.aimSmoothness)
	end
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == aimHoldKey then isHolding = true end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode == aimHoldKey then isHolding = false end
end))

createSection(aimFrame, "Main")
createToggle(aimFrame, "Enable Aim Assist", Settings.aimEnabled, function(on) Settings.aimEnabled = on saveSettings() end)
createToggle(aimFrame, "Wall Check", Settings.wallCheck, function(on) Settings.wallCheck = on saveSettings() end)
createToggle(aimFrame, "Sticky Aim", Settings.stickyAim, function(on) Settings.stickyAim = on stickyTarget = nil saveSettings() end)

createSection(aimFrame, "Smoothness")
createSlider(aimFrame, "Aim Smoothness", 5, 100, Settings.aimSmoothness * 100, function(v) Settings.aimSmoothness = v / 100 end)

createSection(aimFrame, "Hold Key")
local kf = Instance.new("Frame")
kf.Size = UDim2.new(1, 0, 0, 40)
kf.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
kf.BorderSizePixel = 0
kf.Parent = aimFrame
Instance.new("UICorner", kf).CornerRadius = UDim.new(0, 8)

local kl = Instance.new("TextLabel", kf)
kl.Size = UDim2.new(0.6, 0, 1, 0)
kl.Position = UDim2.new(0, 14, 0, 0)
kl.BackgroundTransparency = 1
kl.Text = "Hold Key: " .. Settings.aimHoldKey
kl.TextColor3 = Colors.text
kl.TextSize = 12
kl.Font = Enum.Font.GothamSemibold
kl.TextXAlignment = Enum.TextXAlignment.Left

local kb = Instance.new("TextButton", kf)
kb.Size = UDim2.new(0, 60, 0, 26)
kb.Position = UDim2.new(1, -72, 0.5, -13)
kb.BackgroundColor3 = Colors.accent
kb.Text = "Set Key"
kb.TextColor3 = Colors.text
kb.TextSize = 10
kb.Font = Enum.Font.GothamBold
kb.BorderSizePixel = 0
Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 6)

kb.MouseButton1Click:Connect(function()
	kb.Text = "..."
	local c
	c = UserInputService.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode ~= Enum.KeyCode.Unknown then
			aimHoldKey = i.KeyCode
			Settings.aimHoldKey = i.KeyCode.Name
			kl.Text = "Hold Key: " .. i.KeyCode.Name
			kb.Text = "Set Key"
			c:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(aimFrame, "Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(aimFrame, tn, Settings.aimTeams[tn] == true, function(on) Settings.aimTeams[tn] = on saveSettings() end)
end

-- ═══════════════════════════════════════════════════════════════
-- GUN MODS TAB
-- ═══════════════════════════════════════════════════════════════
local gunsFrame = createTab("Guns", "🔫")

createSection(gunsFrame, "Gun Modifications")
createToggle(gunsFrame, "No Recoil", Settings.noRecoil, function(on) Settings.noRecoil = on saveSettings() end)
createToggle(gunsFrame, "No Spread", Settings.noSpread, function(on) Settings.noSpread = on saveSettings() end)

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.noRecoil and not Settings.noSpread then return end
	local c = player.Character
	if not c then return end
	for _, t in pairs(c:GetChildren()) do
		if t:IsA("Tool") then
			for _, d in pairs(t:GetDescendants()) do
				if Settings.noRecoil and (d.Name:lower():find("recoil")) then
					if d:IsA("NumberValue") or d:IsA("IntValue") then d.Value = 0 end
				end
				if Settings.noSpread and (d.Name:lower():find("spread") or d.Name:lower():find("accuracy")) then
					if d:IsA("NumberValue") or d:IsA("IntValue") then d.Value = 0 end
				end
			end
		end
	end
end))

-- ═══════════════════════════════════════════════════════════════
-- VISUALS TAB
-- ═══════════════════════════════════════════════════════════════
local visualsFrame = createTab("Visual", "🎨")

createSection(visualsFrame, "Effects")
createToggle(visualsFrame, "Full Bright", Settings.fullBright, function(on)
	Settings.fullBright = on
	if on then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
	saveSettings()
end)

createToggle(visualsFrame, "No Fog", Settings.noFog, function(on)
	Settings.noFog = on
	Lighting.FogEnd = on and 100000 or 1000
	saveSettings()
end)

createSection(visualsFrame, "Camera")
createSlider(visualsFrame, "Field of View", 30, 120, Settings.fov, function(v)
	Settings.fov = v
	workspace.CurrentCamera.FieldOfView = v
end)

createSection(visualsFrame, "Crosshair")
createToggle(visualsFrame, "Enable Crosshair", Settings.crosshairEnabled, function(on)
	Settings.crosshairEnabled = on
	local old = gui:FindFirstChild("PhantomCrosshair")
	if old then old:Destroy() end
	if not on then return end

	local cg = Instance.new("ScreenGui", gui)
	cg.Name = "PhantomCrosshair"
	local col = Color3.fromRGB(Settings.crosshairColor[1], Settings.crosshairColor[2], Settings.crosshairColor[3])

	if Settings.crosshairStyle == "Cross" then
		for _, d in ipairs({
			{UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, -20)},
			{UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, 6)},
			{UDim2.new(0, 14, 0, 2), UDim2.new(0.5, -20, 0.5, -1)},
			{UDim2.new(0, 14, 0, 2), UDim2.new(0.5, 6, 0.5, -1)}
		}) do
			local l = Instance.new("Frame", cg)
			l.Size = d[1]
			l.Position = d[2]
			l.BackgroundColor3 = col
			l.BorderSizePixel = 0
		end
	elseif Settings.crosshairStyle == "Dot" then
		local dot = Instance.new("Frame", cg)
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.Position = UDim2.new(0.5, -3, 0.5, -3)
		dot.BackgroundColor3 = col
		dot.BorderSizePixel = 0
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	end
	saveSettings()
end)

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════
local setFrame = createTab("Set", "⚙️")

createSection(setFrame, "GUI Settings")

local tkf = Instance.new("Frame")
tkf.Size = UDim2.new(1, 0, 0, 40)
tkf.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
tkf.BorderSizePixel = 0
tkf.Parent = setFrame
Instance.new("UICorner", tkf).CornerRadius = UDim.new(0, 8)

local tkl = Instance.new("TextLabel", tkf)
tkl.Size = UDim2.new(0.6, 0, 1, 0)
tkl.Position = UDim2.new(0, 14, 0, 0)
tkl.BackgroundTransparency = 1
tkl.Text = "Toggle GUI: " .. Settings.toggleGuiKey
tkl.TextColor3 = Colors.text
tkl.TextSize = 12
tkl.Font = Enum.Font.GothamSemibold
tkl.TextXAlignment = Enum.TextXAlignment.Left

local tkb = Instance.new("TextButton", tkf)
tkb.Size = UDim2.new(0, 60, 0, 26)
tkb.Position = UDim2.new(1, -72, 0.5, -13)
tkb.BackgroundColor3 = Colors.accent
tkb.Text = "Set Key"
tkb.TextColor3 = Colors.text
tkb.TextSize = 10
tkb.Font = Enum.Font.GothamBold
tkb.BorderSizePixel = 0
Instance.new("UICorner", tkb).CornerRadius = UDim.new(0, 6)

tkb.MouseButton1Click:Connect(function()
	tkb.Text = "..."
	local c
	c = UserInputService.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode ~= Enum.KeyCode.Unknown then
			Settings.toggleGuiKey = i.KeyCode.Name
			tkl.Text = "Toggle GUI: " .. i.KeyCode.Name
			tkb.Text = "Set Key"
			c:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(setFrame, "Data")
createButton(setFrame, "💾  Save Settings", Colors.success, function() saveSettings() end)
createButton(setFrame, "🗑  Destroy GUI", Colors.danger, destroyGui)

-- ═══════════════════════════════════════════════════════════════
-- CREDITS TAB
-- ═══════════════════════════════════════════════════════════════
local creditsFrame = createTab("Info", "ℹ️")

local creditsCard = Instance.new("Frame")
creditsCard.Size = UDim2.new(1, 0, 0, 200)
creditsCard.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
creditsCard.BorderSizePixel = 0
creditsCard.Parent = creditsFrame
Instance.new("UICorner", creditsCard).CornerRadius = UDim.new(0, 12)

local logoCredit = Instance.new("TextLabel")
logoCredit.Size = UDim2.new(1, 0, 0, 50)
logoCredit.Position = UDim2.new(0, 0, 0, 15)
logoCredit.BackgroundTransparency = 1
logoCredit.Text = "👻 PHANTOM"
logoCredit.TextColor3 = Colors.accent
logoCredit.TextSize = 28
logoCredit.Font = Enum.Font.GothamBlack
logoCredit.Parent = creditsCard

local verCredit = Instance.new("TextLabel")
verCredit.Size = UDim2.new(1, 0, 0, 20)
verCredit.Position = UDim2.new(0, 0, 0, 60)
verCredit.BackgroundTransparency = 1
verCredit.Text = "Version 4.0"
verCredit.TextColor3 = Colors.textDim
verCredit.TextSize = 14
verCredit.Font = Enum.Font.GothamSemibold
verCredit.Parent = creditsCard

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.6, 0, 0, 1)
divider.Position = UDim2.new(0.2, 0, 0, 95)
divider.BackgroundColor3 = Colors.accent
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = creditsCard

local devTitle = Instance.new("TextLabel")
devTitle.Size = UDim2.new(1, 0, 0, 20)
devTitle.Position = UDim2.new(0, 0, 0, 110)
devTitle.BackgroundTransparency = 1
devTitle.Text = "Developer / Founder"
devTitle.TextColor3 = Colors.textDim
devTitle.TextSize = 11
devTitle.Font = Enum.Font.Gotham
devTitle.Parent = creditsCard

local devName = Instance.new("TextLabel")
devName.Size = UDim2.new(1, 0, 0, 30)
devName.Position = UDim2.new(0, 0, 0, 130)
devName.BackgroundTransparency = 1
devName.Text = "Mishka"
devName.TextColor3 = Colors.accent
devName.TextSize = 22
devName.Font = Enum.Font.GothamBold
devName.Parent = creditsCard

local thankYou = Instance.new("TextLabel")
thankYou.Size = UDim2.new(1, 0, 0, 20)
thankYou.Position = UDim2.new(0, 0, 0, 165)
thankYou.BackgroundTransparency = 1
thankYou.Text = "Thank you for using Phantom! 💜"
thankYou.TextColor3 = Colors.textDim
thankYou.TextSize = 11
thankYou.Font = Enum.Font.Gotham
thankYou.Parent = creditsCard

-- ═══════════════════════════════════════════════════════════════
-- KEYBIND HANDLER
-- ═══════════════════════════════════════════════════════════════
table.insert(connections, UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode.Name == Settings.toggleGuiKey then
		main.Visible = not main.Visible
	end
end))

-- Select first tab
tabs["TP"].btn.MouseButton1Click:Fire()

print("👻 Phantom V4 by Mishka | Press " .. Settings.toggleGuiKey .. " to toggle")
