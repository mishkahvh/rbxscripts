-- Phantom GUI V3 (Clean UI Redesign)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

if _G.PhantomGui then _G.PhantomGui:Destroy() end

local connections = {}

-- Teleport Locations
local LOCATIONS = {
	{name = "Gun Place", x = 192.16075134277344, y = 23.23805809020996, z = -212.8652801513672, autoGrab = true},
	{name = "Keycard", x = -14.410970687866211, y = 22.125398635864258, z = -27.26800537109375, autoGrab = true},
	{name = "Outside", x = 197.8267822265625, y = 9.74256610870361, z = 83.4042053222562},
	{name = "Prison Cell", x = 24.979963302612305, y = 22.125404357910156, z = -50.68348693847656},
	{name = "Cafe", x = 99.8274154663086, y = 11.2254056930542, z = 28.34731101989746},
	{name = "Directors Office", x = 98.7244873046875, y = 11.2254056930542, z = 32.67652893066406},
	{name = "Booking", x = 98.7244873046875, y = 11.2254056930542, z = 32.67652893066406},
	{name = "Tunnels", x = 98.7244873046875, y = 11.2254056930542, z = 32.67652893066406}
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

-- Teams for ESP and Aim
local TARGET_TEAMS = {
	"Minimum Security",
	"Medium Security", 
	"Maximum Security",
	"Escapee",
	"State Police",
	"Department of Corrections"
}

-- Settings (ALL OFF by default)
local Settings = {
	espEnabled = false,
	showDistance = false,
	showHealth = false,
	showBox = false,
	espTeams = {},
	aimEnabled = false,
	aimSmoothness = 0.35,
	aimFOV = 90,
	aimPart = "Head",
	aimHoldKey = "Q",
	showFOV = false,
	wallCheck = false,
	stickyAim = false,
	aimTeams = {},
	crosshairEnabled = false,
	crosshairStyle = "Cross",
	crosshairColor = {255, 255, 255},
	targetInfoEnabled = false,
	toggleGuiKey = "M",
	noRecoil = false,
	noSpread = false
}

for teamName, _ in pairs(TEAM_COLORS) do
	Settings.espTeams[teamName] = false
	Settings.aimTeams[teamName] = false
end

pcall(function()
	if readfile then
		local data = readfile("PhantomSettings.json")
		local loaded = HttpService:JSONDecode(data)
		for k, v in pairs(loaded) do Settings[k] = v end
	end
end)

local function saveSettings()
	pcall(function()
		if writefile then
			writefile("PhantomSettings.json", HttpService:JSONEncode(Settings))
		end
	end)
end

-- GUI Setup
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
	connections = {}
	_G.PhantomGui = nil
	gui:Destroy()
end

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 580)
main.Position = UDim2.new(0.5, -250, 0.5, -290)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(80, 40, 140)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3

-- Glow effect
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 60, 1, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = Color3.fromRGB(100, 50, 180)
glow.ImageTransparency = 0.85
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.Parent = main
glow.ZIndex = 0

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
header.BorderSizePixel = 0
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 12)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Accent line
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.Position = UDim2.new(0, 0, 1, -3)
accent.BorderSizePixel = 0
accent.Parent = header

local accentGradient = Instance.new("UIGradient", accent)
accentGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 60, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 60, 255))
})

-- Logo/Title
local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, 30, 0, 30)
logoIcon.Position = UDim2.new(0, 16, 0.5, -15)
logoIcon.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
logoIcon.Text = "👻"
logoIcon.TextSize = 16
logoIcon.Parent = header
Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 150, 0, 24)
title.Position = UDim2.new(0, 54, 0, 8)
title.BackgroundTransparency = 1
title.Text = "PHANTOM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 150, 0, 14)
subtitle.Position = UDim2.new(0, 54, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "v3.0 • Premium"
subtitle.TextColor3 = Color3.fromRGB(140, 60, 255)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamSemibold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -44, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BackgroundTransparency = 0.8
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(destroyGui)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -82, 0.5, -16)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
minBtn.BackgroundTransparency = 0.8
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		main.Size = UDim2.new(0, 500, 0, 50)
		minBtn.Text = "+"
	else
		main.Size = UDim2.new(0, 500, 0, 580)
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

-- Tab bar container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 40)
tabContainer.Position = UDim2.new(0, 12, 0, 58)
tabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = main
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -8, 1, -8)
tabBar.Position = UDim2.new(0, 4, 0, 4)
tabBar.BackgroundTransparency = 1
tabBar.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -116)
content.Position = UDim2.new(0, 12, 0, 104)
content.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

-- Tab system
local tabs = {}
local currentTab = nil

local function createTab(name, icon)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 62, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	btn.BackgroundTransparency = 0.5
	btn.Text = icon .. " " .. name
	btn.TextColor3 = Color3.fromRGB(120, 120, 140)
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
	frame.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 255)
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
			currentTab.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			currentTab.btn.BackgroundTransparency = 0.5
			currentTab.btn.TextColor3 = Color3.fromRGB(120, 120, 140)
			currentTab.frame.Visible = false
		end
		currentTab = tabs[name]
		btn.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
		btn.BackgroundTransparency = 0
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		frame.Visible = true
	end)

	return frame
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS (Clean & Spaced)
-- ═══════════════════════════════════════════════════════════════

local function createSection(parent, text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 28)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local line1 = Instance.new("Frame")
	line1.Size = UDim2.new(0.25, 0, 0, 1)
	line1.Position = UDim2.new(0, 0, 0.5, 0)
	line1.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	line1.BorderSizePixel = 0
	line1.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Position = UDim2.new(0.25, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(140, 60, 255)
	label.TextSize = 11
	label.Font = Enum.Font.GothamBold
	label.Parent = container

	local line2 = Instance.new("Frame")
	line2.Size = UDim2.new(0.25, 0, 0, 1)
	line2.Position = UDim2.new(0.75, 0, 0.5, 0)
	line2.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	line2.BorderSizePixel = 0
	line2.Parent = container
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 44, 0, 24)
	toggleBg.Position = UDim2.new(1, -56, 0.5, -12)
	toggleBg.BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)
	toggleBg.Text = ""
	toggleBg.BorderSizePixel = 0
	toggleBg.AutoButtonColor = false
	toggleBg.Parent = frame
	Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = toggleBg
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isOn = default
	toggleBg.MouseButton1Click:Connect(function()
		isOn = not isOn
		toggleBg.BackgroundColor3 = isOn and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)
		knob.Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		callback(isOn)
	end)

	return {frame = frame, setOn = function(on)
		isOn = on
		toggleBg.BackgroundColor3 = isOn and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(50, 50, 60)
		knob.Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	end}
end

local function createButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 42)
	btn.BackgroundColor3 = color or Color3.fromRGB(140, 60, 255)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	btn.MouseEnter:Connect(function()
		btn.BackgroundTransparency = 0.2
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundTransparency = 0
	end)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 56)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 0, 24)
	label.Position = UDim2.new(0, 14, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.3, -14, 0, 24)
	valueLabel.Position = UDim2.new(0.7, 0, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Color3.fromRGB(140, 60, 255)
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -28, 0, 8)
	track.Position = UDim2.new(0, 14, 0, 36)
	track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	track.BorderSizePixel = 0
	track.Parent = frame
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false
	local sliderConn = nil

	local function updateSlider(pos)
		local p = math.clamp(pos, 0, 1)
		local value = min + p * (max - min)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, -8, 0.5, -8)
		valueLabel.Text = string.format("%.2f", value)
		callback(value)
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			sliderConn = UserInputService.InputChanged:Connect(function(inp)
				if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
					local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					updateSlider(rel)
				end
			end)
		end
	end)

	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
			if sliderConn then sliderConn:Disconnect() sliderConn = nil end
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			updateSlider(rel)
		end
	end)

	return frame
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO GRAB FUNCTIONS
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
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 4, 0, 24)
	icon.Position = UDim2.new(0, 10, 0.5, -12)
	icon.BackgroundColor3 = loc.autoGrab and Color3.fromRGB(255, 160, 50) or Color3.fromRGB(140, 60, 255)
	icon.BorderSizePixel = 0
	icon.Parent = frame
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 2)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -90, 1, 0)
	label.Position = UDim2.new(0, 22, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = loc.name
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextSize = 12
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btnColor = loc.autoGrab and Color3.fromRGB(255, 160, 50) or Color3.fromRGB(140, 60, 255)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 56, 0, 28)
	btn.Position = UDim2.new(1, -68, 0.5, -14)
	btn.BackgroundColor3 = btnColor
	btn.Text = loc.autoGrab and "GRAB" or "GO"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
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
				btn.BackgroundColor3 = ok and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(220, 60, 60)
				task.wait(0.3)
				btn.Text = origText
				btn.BackgroundColor3 = btnColor
				isBusy = false
			end)
		else
			btn.Text = "⏳"
			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "✓"
			btn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
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
createSection(tpFrame, "LOCATIONS")
for _, loc in ipairs(LOCATIONS) do
	createLocBtn(tpFrame, loc)
end

-- ═══════════════════════════════════════════════════════════════
-- PLAYERS TAB
-- ═══════════════════════════════════════════════════════════════
local playersFrame = createTab("Players", "👥")

local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, 0, 0, 0)
playerListFrame.BackgroundTransparency = 1
playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
playerListFrame.Parent = playersFrame

local playerListLayout = Instance.new("UIListLayout", playerListFrame)
playerListLayout.Padding = UDim.new(0, 6)

local function refreshPlayerList()
	for _, child in pairs(playerListFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
			frame.BorderSizePixel = 0
			frame.Parent = playerListFrame
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

			local teamName = p.Team and p.Team.Name or "Civilian"
			local teamColor = TEAM_COLORS[teamName] or Color3.fromRGB(180, 180, 180)

			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0, 12, 0.5, -4)
			dot.BackgroundColor3 = teamColor
			dot.BorderSizePixel = 0
			dot.Parent = frame
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, -100, 0, 20)
			nameLabel.Position = UDim2.new(0, 28, 0, 4)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = p.Name
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextSize = 11
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = frame

			local teamLabel = Instance.new("TextLabel")
			teamLabel.Size = UDim2.new(1, -100, 0, 14)
			teamLabel.Position = UDim2.new(0, 28, 0, 22)
			teamLabel.BackgroundTransparency = 1
			teamLabel.Text = teamName
			teamLabel.TextColor3 = teamColor
			teamLabel.TextSize = 9
			teamLabel.Font = Enum.Font.Gotham
			teamLabel.TextXAlignment = Enum.TextXAlignment.Left
			teamLabel.Parent = frame

			local tpBtn = Instance.new("TextButton")
			tpBtn.Size = UDim2.new(0, 50, 0, 26)
			tpBtn.Position = UDim2.new(1, -62, 0.5, -13)
			tpBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
			tpBtn.Text = "TP"
			tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tpBtn.TextSize = 10
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.BorderSizePixel = 0
			tpBtn.Parent = frame
			Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

			tpBtn.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					tpBtn.Text = "✓"
					task.wait(0.3)
					tpBtn.Text = "TP"
				end
			end)
		end
	end
end

createSection(playersFrame, "PLAYER LIST")
createButton(playersFrame, "🔄  Refresh List", Color3.fromRGB(60, 60, 80), refreshPlayerList)

table.insert(connections, Players.PlayerAdded:Connect(refreshPlayerList))
table.insert(connections, Players.PlayerRemoving:Connect(refreshPlayerList))
refreshPlayerList()

-- ═══════════════════════════════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════════════════════════════
local espFrame = createTab("ESP", "👁")

local function updateESP(plr)
	if plr == player then return end
	local char = plr.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	if not head or not hrp then return end

	local teamName = plr.Team and plr.Team.Name or "Civilian"
	local teamColor = TEAM_COLORS[teamName] or Color3.fromRGB(180, 180, 180)
	local shouldShow = Settings.espEnabled and (Settings.espTeams[teamName] == true)

	local old = head:FindFirstChild("PhantomESP")
	local oldH = char:FindFirstChild("PhantomHighlight")
	if old then old:Destroy() end
	if oldH then oldH:Destroy() end

	if not shouldShow then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PhantomESP"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = billboard

	local teamLabel = Instance.new("TextLabel")
	teamLabel.Size = UDim2.new(1, 0, 0, 12)
	teamLabel.Position = UDim2.new(0, 0, 0, 13)
	teamLabel.BackgroundTransparency = 1
	teamLabel.Text = teamName
	teamLabel.TextColor3 = teamColor
	teamLabel.TextSize = 9
	teamLabel.Font = Enum.Font.GothamSemibold
	teamLabel.TextStrokeTransparency = 0
	teamLabel.Parent = billboard

	if Settings.showDistance then
		local distLabel = Instance.new("TextLabel")
		distLabel.Name = "Distance"
		distLabel.Size = UDim2.new(1, 0, 0, 10)
		distLabel.Position = UDim2.new(0, 0, 0, 26)
		distLabel.BackgroundTransparency = 1
		distLabel.Text = "[0m]"
		distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		distLabel.TextSize = 9
		distLabel.Font = Enum.Font.Gotham
		distLabel.TextStrokeTransparency = 0
		distLabel.Parent = billboard
	end

	if Settings.showHealth and humanoid then
		local healthBg = Instance.new("Frame")
		healthBg.Size = UDim2.new(0.7, 0, 0, 4)
		healthBg.Position = UDim2.new(0.15, 0, 0, 40)
		healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		healthBg.BorderSizePixel = 0
		healthBg.Parent = billboard
		Instance.new("UICorner", healthBg).CornerRadius = UDim.new(1, 0)

		local healthFill = Instance.new("Frame")
		healthFill.Name = "HealthFill"
		healthFill.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)
		healthFill.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
		healthFill.BorderSizePixel = 0
		healthFill.Parent = healthBg
		Instance.new("UICorner", healthFill).CornerRadius = UDim.new(1, 0)
	end

	if Settings.showBox then
		local highlight = Instance.new("Highlight")
		highlight.Name = "PhantomHighlight"
		highlight.FillTransparency = 1
		highlight.OutlineColor = teamColor
		highlight.OutlineTransparency = 0.3
		highlight.Parent = char
	end
end

local function refreshAllESP()
	for _, p in pairs(Players:GetPlayers()) do updateESP(p) end
end

local function clearAllESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head then local esp = head:FindFirstChild("PhantomESP") if esp then esp:Destroy() end end
			local hl = p.Character:FindFirstChild("PhantomHighlight") if hl then hl:Destroy() end
		end
	end
end

local distanceLoop = nil
local function startDistanceLoop()
	if distanceLoop then return end
	distanceLoop = task.spawn(function()
		while Settings.espEnabled and gui.Parent do
			local myChar = player.Character
			if myChar and myChar:FindFirstChild("HumanoidRootPart") then
				local myPos = myChar.HumanoidRootPart.Position
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= player and p.Character then
						local head = p.Character:FindFirstChild("Head")
						local hrp = p.Character:FindFirstChild("HumanoidRootPart")
						if head and hrp then
							local esp = head:FindFirstChild("PhantomESP")
							if esp then
								local distLabel = esp:FindFirstChild("Distance")
								if distLabel then
									distLabel.Text = "[" .. math.floor((hrp.Position - myPos).Magnitude) .. "m]"
								end
								local humanoid = p.Character:FindFirstChild("Humanoid")
								if humanoid then
									for _, child in pairs(esp:GetChildren()) do
										if child:IsA("Frame") then
											local fill = child:FindFirstChild("HealthFill")
											if fill then
												local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
												fill.Size = UDim2.new(hp, 0, 1, 0)
												fill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 200 * hp, 80)
											end
										end
									end
								end
							end
						end
					end
				end
			end
			task.wait(0.2)
		end
		distanceLoop = nil
	end)
end

createSection(espFrame, "MAIN")
createToggle(espFrame, "Enable ESP", Settings.espEnabled, function(on)
	Settings.espEnabled = on
	if on then refreshAllESP() startDistanceLoop() else clearAllESP() end
	saveSettings()
end)

createSection(espFrame, "VISUALS")
createToggle(espFrame, "Show Distance", Settings.showDistance, function(on)
	Settings.showDistance = on
	if Settings.espEnabled then refreshAllESP() end
	saveSettings()
end)
createToggle(espFrame, "Show Health Bar", Settings.showHealth, function(on)
	Settings.showHealth = on
	if Settings.espEnabled then refreshAllESP() end
	saveSettings()
end)
createToggle(espFrame, "Show Outline", Settings.showBox, function(on)
	Settings.showBox = on
	if Settings.espEnabled then refreshAllESP() end
	saveSettings()
end)

createSection(espFrame, "TEAMS")
for _, teamName in ipairs(TARGET_TEAMS) do
	createToggle(espFrame, teamName, Settings.espTeams[teamName] == true, function(on)
		Settings.espTeams[teamName] = on
		if Settings.espEnabled then refreshAllESP() end
		saveSettings()
	end)
end

local function setupPlayerESP(p)
	if p == player then return end
	table.insert(connections, p.CharacterAdded:Connect(function()
		task.wait(0.5)
		if Settings.espEnabled then updateESP(p) end
	end))
	if Settings.espEnabled and p.Character then updateESP(p) end
end
for _, p in pairs(Players:GetPlayers()) do setupPlayerESP(p) end
table.insert(connections, Players.PlayerAdded:Connect(setupPlayerESP))

-- ═══════════════════════════════════════════════════════════════
-- AIM TAB
-- ═══════════════════════════════════════════════════════════════
local aimFrame = createTab("Aim", "🎯")

local aimEnabled = Settings.aimEnabled
local aimSmoothness = Settings.aimSmoothness
local aimFOV = Settings.aimFOV
local aimPart = Settings.aimPart
local aimHoldKey = Enum.KeyCode[Settings.aimHoldKey] or Enum.KeyCode.Q
local showFOV = Settings.showFOV
local wallCheck = Settings.wallCheck
local stickyAim = Settings.stickyAim
local isHoldingAim = false
local stickyTarget = nil

local fovCircle = nil

local function createFOVCircle()
	if fovCircle then fovCircle:Destroy() end
	if not showFOV or not aimEnabled then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "AimFOV"
	sg.Parent = gui
	fovCircle = Instance.new("Frame")
	fovCircle.Size = UDim2.new(0, aimFOV * 4, 0, aimFOV * 4)
	fovCircle.Position = UDim2.new(0.5, -aimFOV * 2, 0.5, -aimFOV * 2)
	fovCircle.BackgroundTransparency = 1
	fovCircle.Parent = sg
	local stroke = Instance.new("UIStroke", fovCircle)
	stroke.Color = Color3.fromRGB(140, 60, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
end

local function destroyFOVCircle()
	if fovCircle and fovCircle.Parent then fovCircle.Parent:Destroy() end
	fovCircle = nil
end

local function isTargetVisible(targetPart)
	if not wallCheck then return true end
	local myChar = player.Character
	if not myChar then return false end
	local myHead = myChar:FindFirstChild("Head")
	if not myHead then return false end
	local origin = myHead.Position
	local direction = (targetPart.Position - origin)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {myChar}
	local result = workspace:Raycast(origin, direction, params)
	if result then
		local hitPart = result.Instance
		local targetChar = targetPart:FindFirstAncestorOfClass("Model")
		if targetChar and hitPart:IsDescendantOf(targetChar) then return true end
		return false
	end
	return true
end

local function getClosestTarget()
	if stickyAim and stickyTarget then
		local char = stickyTarget.Character
		if char then
			local humanoid = char:FindFirstChild("Humanoid")
			local part = char:FindFirstChild(aimPart) or char:FindFirstChild("Head")
			if humanoid and humanoid.Health > 0 and part and isTargetVisible(part) then
				return part
			end
		end
		stickyTarget = nil
	end

	local camera = workspace.CurrentCamera
	local myChar = player.Character
	if not camera or not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

	local myPos = myChar.HumanoidRootPart.Position
	local closest = nil
	local closestPlayer = nil
	local closestDist = math.huge
	local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local teamName = p.Team and p.Team.Name or "Civilian"
			if Settings.aimTeams[teamName] then
				local char = p.Character
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local humanoid = char:FindFirstChild("Humanoid")

				if hrp and humanoid and humanoid.Health > 0 then
					local partName = aimPart == "Random" and ({"Head", "UpperTorso", "HumanoidRootPart"})[math.random(3)] or aimPart
					local targetPart = char:FindFirstChild(partName) or char:FindFirstChild("Head")
					
					if targetPart and isTargetVisible(targetPart) then
						local dist = (hrp.Position - myPos).Magnitude
						if dist <= 200 then
							local screenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)
							if onScreen then
								local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
								if screenDist <= aimFOV * 2 and screenDist < closestDist then
									closestDist = screenDist
									closest = targetPart
									closestPlayer = p
								end
							end
						end
					end
				end
			end
		end
	end

	if stickyAim and closestPlayer then stickyTarget = closestPlayer end
	return closest
end

local aimConnection = nil
local function startAimLoop()
	if aimConnection then return end
	aimConnection = RunService.RenderStepped:Connect(function()
		if not aimEnabled or not isHoldingAim then
			if not isHoldingAim then stickyTarget = nil end
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local target = getClosestTarget()
		if target then
			local currentCF = camera.CFrame
			local targetCF = CFrame.lookAt(currentCF.Position, target.Position)
			camera.CFrame = currentCF:Lerp(targetCF, aimSmoothness)
		end
	end)
	table.insert(connections, aimConnection)
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == aimHoldKey then isHoldingAim = true end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == aimHoldKey then isHoldingAim = false end
end))

startAimLoop()

createSection(aimFrame, "MAIN")
createToggle(aimFrame, "Enable Aim Assist", aimEnabled, function(on)
	aimEnabled = on
	Settings.aimEnabled = on
	saveSettings()
end)

createToggle(aimFrame, "Show FOV Circle", showFOV, function(on)
	showFOV = on
	Settings.showFOV = on
	if on and aimEnabled then createFOVCircle() else destroyFOVCircle() end
	saveSettings()
end)

createToggle(aimFrame, "Wall Check", wallCheck, function(on)
	wallCheck = on
	Settings.wallCheck = on
	saveSettings()
end)

createToggle(aimFrame, "Sticky Aim", stickyAim, function(on)
	stickyAim = on
	Settings.stickyAim = on
	stickyTarget = nil
	saveSettings()
end)

createSection(aimFrame, "SMOOTHNESS")
createSlider(aimFrame, "Aim Smoothness", 0.05, 1, aimSmoothness, function(value)
	aimSmoothness = value
	Settings.aimSmoothness = value
end)

createSection(aimFrame, "HOLD KEY")
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(1, 0, 0, 42)
keyFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = aimFrame
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 8)

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0.6, 0, 1, 0)
keyLabel.Position = UDim2.new(0, 14, 0, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Hold Key: " .. Settings.aimHoldKey
keyLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
keyLabel.TextSize = 12
keyLabel.Font = Enum.Font.GothamSemibold
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyFrame

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0, 60, 0, 28)
keyBtn.Position = UDim2.new(1, -72, 0.5, -14)
keyBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
keyBtn.Text = "Set Key"
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBtn.TextSize = 10
keyBtn.Font = Enum.Font.GothamBold
keyBtn.BorderSizePixel = 0
keyBtn.Parent = keyFrame
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

local waitingKey = false
keyBtn.MouseButton1Click:Connect(function()
	if waitingKey then return end
	waitingKey = true
	keyBtn.Text = "..."
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			aimHoldKey = input.KeyCode
			Settings.aimHoldKey = input.KeyCode.Name
			keyLabel.Text = "Hold Key: " .. input.KeyCode.Name
			keyBtn.Text = "Set Key"
			waitingKey = false
			conn:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(aimFrame, "TEAMS")
for _, teamName in ipairs(TARGET_TEAMS) do
	createToggle(aimFrame, teamName, Settings.aimTeams[teamName] == true, function(on)
		Settings.aimTeams[teamName] = on
		saveSettings()
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- GUN MODS TAB
-- ═══════════════════════════════════════════════════════════════
local gunsFrame = createTab("Guns", "🔫")

createSection(gunsFrame, "GUN MODIFICATIONS")

createToggle(gunsFrame, "No Recoil", Settings.noRecoil, function(on)
	Settings.noRecoil = on
	saveSettings()
end)

createToggle(gunsFrame, "No Spread", Settings.noSpread, function(on)
	Settings.noSpread = on
	saveSettings()
end)

-- No recoil/spread loop
table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.noRecoil and not Settings.noSpread then return end
	
	local char = player.Character
	if not char then return end
	
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			for _, desc in pairs(tool:GetDescendants()) do
				if Settings.noRecoil then
					if desc.Name == "Recoil" or desc.Name == "RecoilForce" or desc.Name == "CameraRecoil" then
						if desc:IsA("NumberValue") or desc:IsA("IntValue") then
							desc.Value = 0
						end
					end
				end
				if Settings.noSpread then
					if desc.Name == "Spread" or desc.Name == "BulletSpread" or desc.Name == "Accuracy" then
						if desc:IsA("NumberValue") or desc:IsA("IntValue") then
							desc.Value = 0
						end
					end
				end
			end
		end
	end
end))

-- Info text
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 60)
infoLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
infoLabel.Text = "⚠️ Gun mods may not work on all games.\nThey modify weapon values if accessible."
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
infoLabel.TextSize = 10
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.Parent = gunsFrame
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 8)

-- ═══════════════════════════════════════════════════════════════
-- VISUALS TAB
-- ═══════════════════════════════════════════════════════════════
local visualsFrame = createTab("Visual", "🎨")

local crosshairGui = nil

local function updateCrosshair()
	if crosshairGui then crosshairGui:Destroy() crosshairGui = nil end
	if not Settings.crosshairEnabled then return end
	
	crosshairGui = Instance.new("ScreenGui")
	crosshairGui.Name = "PhantomCrosshair"
	crosshairGui.Parent = gui

	local color = Color3.fromRGB(Settings.crosshairColor[1], Settings.crosshairColor[2], Settings.crosshairColor[3])

	if Settings.crosshairStyle == "Cross" then
		for _, data in ipairs({
			{UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, -20)},
			{UDim2.new(0, 2, 0, 14), UDim2.new(0.5, -1, 0.5, 6)},
			{UDim2.new(0, 14, 0, 2), UDim2.new(0.5, -20, 0.5, -1)},
			{UDim2.new(0, 14, 0, 2), UDim2.new(0.5, 6, 0.5, -1)}
		}) do
			local line = Instance.new("Frame")
			line.Size = data[1]
			line.Position = data[2]
			line.BackgroundColor3 = color
			line.BorderSizePixel = 0
			line.Parent = crosshairGui
		end
	elseif Settings.crosshairStyle == "Dot" then
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 6, 0, 6)
		dot.Position = UDim2.new(0.5, -3, 0.5, -3)
		dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0
		dot.Parent = crosshairGui
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	elseif Settings.crosshairStyle == "Circle" then
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, 24, 0, 24)
		circle.Position = UDim2.new(0.5, -12, 0.5, -12)
		circle.BackgroundTransparency = 1
		circle.Parent = crosshairGui
		local s = Instance.new("UIStroke", circle)
		s.Color = color
		s.Thickness = 2
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	end
end

createSection(visualsFrame, "CROSSHAIR")
createToggle(visualsFrame, "Enable Crosshair", Settings.crosshairEnabled, function(on)
	Settings.crosshairEnabled = on
	updateCrosshair()
	saveSettings()
end)

local styleFrame = Instance.new("Frame")
styleFrame.Size = UDim2.new(1, 0, 0, 42)
styleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
styleFrame.BorderSizePixel = 0
styleFrame.Parent = visualsFrame
Instance.new("UICorner", styleFrame).CornerRadius = UDim.new(0, 8)

local styleLabel = Instance.new("TextLabel")
styleLabel.Size = UDim2.new(0.5, 0, 1, 0)
styleLabel.Position = UDim2.new(0, 14, 0, 0)
styleLabel.BackgroundTransparency = 1
styleLabel.Text = "Style: " .. Settings.crosshairStyle
styleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
styleLabel.TextSize = 12
styleLabel.Font = Enum.Font.GothamSemibold
styleLabel.TextXAlignment = Enum.TextXAlignment.Left
styleLabel.Parent = styleFrame

local styleBtn = Instance.new("TextButton")
styleBtn.Size = UDim2.new(0, 70, 0, 28)
styleBtn.Position = UDim2.new(1, -82, 0.5, -14)
styleBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
styleBtn.Text = "Change"
styleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
styleBtn.TextSize = 10
styleBtn.Font = Enum.Font.GothamBold
styleBtn.BorderSizePixel = 0
styleBtn.Parent = styleFrame
Instance.new("UICorner", styleBtn).CornerRadius = UDim.new(0, 6)

local styles = {"Cross", "Dot", "Circle"}
local styleIndex = 1
for i, s in ipairs(styles) do if s == Settings.crosshairStyle then styleIndex = i end end

styleBtn.MouseButton1Click:Connect(function()
	styleIndex = styleIndex + 1
	if styleIndex > #styles then styleIndex = 1 end
	Settings.crosshairStyle = styles[styleIndex]
	styleLabel.Text = "Style: " .. Settings.crosshairStyle
	updateCrosshair()
	saveSettings()
end)

createSection(visualsFrame, "CROSSHAIR COLOR")
local colorFrame = Instance.new("Frame")
colorFrame.Size = UDim2.new(1, 0, 0, 42)
colorFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
colorFrame.BorderSizePixel = 0
colorFrame.Parent = visualsFrame
Instance.new("UICorner", colorFrame).CornerRadius = UDim.new(0, 8)

local colorLayout = Instance.new("UIListLayout", colorFrame)
colorLayout.FillDirection = Enum.FillDirection.Horizontal
colorLayout.Padding = UDim.new(0, 8)
colorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
colorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local colors = {{255,255,255}, {255,60,60}, {60,255,60}, {60,255,255}, {140,60,255}, {255,255,60}}
for _, col in ipairs(colors) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 32, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(col[1], col[2], col[3])
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = colorFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function()
		Settings.crosshairColor = col
		updateCrosshair()
		saveSettings()
	end)
end

createSection(visualsFrame, "TARGET INFO")
createToggle(visualsFrame, "Show Target Info", Settings.targetInfoEnabled, function(on)
	Settings.targetInfoEnabled = on
	saveSettings()
end)

-- Target info display
local targetInfoFrame = Instance.new("Frame")
targetInfoFrame.Name = "TargetInfo"
targetInfoFrame.Size = UDim2.new(0, 160, 0, 50)
targetInfoFrame.Position = UDim2.new(0.5, -80, 0, 10)
targetInfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
targetInfoFrame.BackgroundTransparency = 0.1
targetInfoFrame.Visible = false
targetInfoFrame.Parent = gui
Instance.new("UICorner", targetInfoFrame).CornerRadius = UDim.new(0, 8)
local tiStroke = Instance.new("UIStroke", targetInfoFrame)
tiStroke.Color = Color3.fromRGB(140, 60, 255)
tiStroke.Transparency = 0.5

local targetName = Instance.new("TextLabel")
targetName.Size = UDim2.new(1, 0, 0, 22)
targetName.Position = UDim2.new(0, 0, 0, 6)
targetName.BackgroundTransparency = 1
targetName.Text = "No Target"
targetName.TextColor3 = Color3.fromRGB(255, 255, 255)
targetName.TextSize = 12
targetName.Font = Enum.Font.GothamBold
targetName.Parent = targetInfoFrame

local targetHealthBg = Instance.new("Frame")
targetHealthBg.Size = UDim2.new(0.8, 0, 0, 8)
targetHealthBg.Position = UDim2.new(0.1, 0, 0, 32)
targetHealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
targetHealthBg.BorderSizePixel = 0
targetHealthBg.Parent = targetInfoFrame
Instance.new("UICorner", targetHealthBg).CornerRadius = UDim.new(1, 0)

local targetHealthFill = Instance.new("Frame")
targetHealthFill.Size = UDim2.new(0, 0, 1, 0)
targetHealthFill.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
targetHealthFill.BorderSizePixel = 0
targetHealthFill.Parent = targetHealthBg
Instance.new("UICorner", targetHealthFill).CornerRadius = UDim.new(1, 0)

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.targetInfoEnabled then
		targetInfoFrame.Visible = false
		return
	end
	targetInfoFrame.Visible = true

	local camera = workspace.CurrentCamera
	if not camera then return end

	local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)

	if result and result.Instance then
		local char = result.Instance:FindFirstAncestorOfClass("Model")
		if char then
			local humanoid = char:FindFirstChild("Humanoid")
			local plr = Players:GetPlayerFromCharacter(char)
			if humanoid and plr then
				targetName.Text = plr.Name
				local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				targetHealthFill.Size = UDim2.new(hp, 0, 1, 0)
				targetHealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 200 * hp, 80)
				return
			end
		end
	end
	targetName.Text = "No Target"
	targetHealthFill.Size = UDim2.new(0, 0, 1, 0)
end))

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════
local setFrame = createTab("Set", "⚙️")

createSection(setFrame, "PLAYER")
createButton(setFrame, "💀  Force Reset", Color3.fromRGB(220, 120, 50), function()
	if player.Character then
		player.Character:BreakJoints()
	end
end)

createSection(setFrame, "GUI SETTINGS")
local toggleKeyFrame = Instance.new("Frame")
toggleKeyFrame.Size = UDim2.new(1, 0, 0, 42)
toggleKeyFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
toggleKeyFrame.BorderSizePixel = 0
toggleKeyFrame.Parent = setFrame
Instance.new("UICorner", toggleKeyFrame).CornerRadius = UDim.new(0, 8)

local toggleKeyLabel = Instance.new("TextLabel")
toggleKeyLabel.Size = UDim2.new(0.6, 0, 1, 0)
toggleKeyLabel.Position = UDim2.new(0, 14, 0, 0)
toggleKeyLabel.BackgroundTransparency = 1
toggleKeyLabel.Text = "Toggle GUI: " .. Settings.toggleGuiKey
toggleKeyLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
toggleKeyLabel.TextSize = 12
toggleKeyLabel.Font = Enum.Font.GothamSemibold
toggleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleKeyLabel.Parent = toggleKeyFrame

local toggleKeyBtn = Instance.new("TextButton")
toggleKeyBtn.Size = UDim2.new(0, 60, 0, 28)
toggleKeyBtn.Position = UDim2.new(1, -72, 0.5, -14)
toggleKeyBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 255)
toggleKeyBtn.Text = "Set Key"
toggleKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleKeyBtn.TextSize = 10
toggleKeyBtn.Font = Enum.Font.GothamBold
toggleKeyBtn.BorderSizePixel = 0
toggleKeyBtn.Parent = toggleKeyFrame
Instance.new("UICorner", toggleKeyBtn).CornerRadius = UDim.new(0, 6)

toggleKeyBtn.MouseButton1Click:Connect(function()
	toggleKeyBtn.Text = "..."
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			Settings.toggleGuiKey = input.KeyCode.Name
			toggleKeyLabel.Text = "Toggle GUI: " .. input.KeyCode.Name
			toggleKeyBtn.Text = "Set Key"
			conn:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(setFrame, "DATA")
createButton(setFrame, "💾  Save Settings", Color3.fromRGB(80, 200, 120), function()
	saveSettings()
end)

createButton(setFrame, "🗑  Destroy GUI", Color3.fromRGB(220, 60, 60), destroyGui)

-- ═══════════════════════════════════════════════════════════════
-- KEYBIND HANDLER
-- ═══════════════════════════════════════════════════════════════
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode.Name == Settings.toggleGuiKey then
		main.Visible = not main.Visible
	end
end))

-- Select first tab
tabs["TP"].btn.MouseButton1Click:Fire()

print("👻 Phantom V3 loaded | Press " .. Settings.toggleGuiKey .. " to toggle")
