-- Phantom GUI V5 (Premium Edition)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

if _G.PhantomGui then _G.PhantomGui:Destroy() end

local connections = {}

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "PhantomLoader"
loadingGui.Parent = player:WaitForChild("PlayerGui")

local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(1, 0, 1, 0)
loadingBg.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
loadingBg.BorderSizePixel = 0
loadingBg.Parent = loadingGui

local loadingCenter = Instance.new("Frame")
loadingCenter.Size = UDim2.new(0, 300, 0, 200)
loadingCenter.Position = UDim2.new(0.5, -150, 0.5, -100)
loadingCenter.BackgroundTransparency = 1
loadingCenter.Parent = loadingBg

local loadingLogo = Instance.new("TextLabel")
loadingLogo.Size = UDim2.new(1, 0, 0, 60)
loadingLogo.Position = UDim2.new(0, 0, 0, 20)
loadingLogo.BackgroundTransparency = 1
loadingLogo.Text = "👻"
loadingLogo.TextColor3 = Color3.fromRGB(140, 60, 220)
loadingLogo.TextSize = 50
loadingLogo.TextTransparency = 1
loadingLogo.Parent = loadingCenter

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(1, 0, 0, 40)
loadingTitle.Position = UDim2.new(0, 0, 0, 70)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "PHANTOM"
loadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingTitle.TextSize = 32
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextTransparency = 1
loadingTitle.Parent = loadingCenter

local loadingSubtitle = Instance.new("TextLabel")
loadingSubtitle.Size = UDim2.new(1, 0, 0, 20)
loadingSubtitle.Position = UDim2.new(0, 0, 0, 105)
loadingSubtitle.BackgroundTransparency = 1
loadingSubtitle.Text = "by Mishka"
loadingSubtitle.TextColor3 = Color3.fromRGB(140, 60, 220)
loadingSubtitle.TextSize = 14
loadingSubtitle.Font = Enum.Font.GothamSemibold
loadingSubtitle.TextTransparency = 1
loadingSubtitle.Parent = loadingCenter

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(0.8, 0, 0, 4)
loadingBarBg.Position = UDim2.new(0.1, 0, 0, 150)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
loadingBarBg.BorderSizePixel = 0
loadingBarBg.Parent = loadingCenter
Instance.new("UICorner", loadingBarBg).CornerRadius = UDim.new(1, 0)

local loadingBarFill = Instance.new("Frame")
loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
loadingBarFill.BackgroundColor3 = Color3.fromRGB(140, 60, 220)
loadingBarFill.BorderSizePixel = 0
loadingBarFill.Parent = loadingBarBg
Instance.new("UICorner", loadingBarFill).CornerRadius = UDim.new(1, 0)

local loadingStatus = Instance.new("TextLabel")
loadingStatus.Size = UDim2.new(1, 0, 0, 16)
loadingStatus.Position = UDim2.new(0, 0, 0, 165)
loadingStatus.BackgroundTransparency = 1
loadingStatus.Text = "Initializing..."
loadingStatus.TextColor3 = Color3.fromRGB(100, 95, 120)
loadingStatus.TextSize = 11
loadingStatus.Font = Enum.Font.Gotham
loadingStatus.TextTransparency = 1
loadingStatus.Parent = loadingCenter

-- Animate loading
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(loadingLogo, tweenInfo, {TextTransparency = 0}):Play()
task.wait(0.1)
TweenService:Create(loadingTitle, tweenInfo, {TextTransparency = 0}):Play()
task.wait(0.1)
TweenService:Create(loadingSubtitle, tweenInfo, {TextTransparency = 0}):Play()
task.wait(0.1)
TweenService:Create(loadingStatus, tweenInfo, {TextTransparency = 0}):Play()

local loadSteps = {"Initializing...", "Loading modules...", "Setting up ESP...", "Configuring aim...", "Applying settings...", "Ready!"}
for i, step in ipairs(loadSteps) do
	loadingStatus.Text = step
	TweenService:Create(loadingBarFill, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Size = UDim2.new(i / #loadSteps, 0, 1, 0)}):Play()
	task.wait(0.15)
end

task.wait(0.3)
TweenService:Create(loadingBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadingCenter, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0.5, -150, 0.4, -100)}):Play()
for _, v in pairs(loadingCenter:GetChildren()) do
	if v:IsA("TextLabel") then TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play() end
end
task.wait(0.4)
loadingGui:Destroy()

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════
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

local Settings = {
	espEnabled = false, showName = false, showTeam = false, showDistance = false, showHealth = false, showBox = false, espTeams = {},
	aimEnabled = false, aimSmoothness = 0.35, aimFOV = 90, aimPart = "Head", aimHoldKey = "Q", showFOV = false, fovSize = 90, wallCheck = false, stickyAim = false, aimTeams = {},
	crosshairEnabled = false, crosshairStyle = "Cross", crosshairColor = {255, 255, 255}, targetInfoEnabled = false,
	bhop = false, infJump = false, infStamina = false, fly = false, noclip = false, flySpeed = 50, jumpPower = 50, walkSpeed = 16,
	noPepper = false, antiCuff = false, noStun = false, spinbot = false, spinSpeed = 10,
	infZoom = false, autoPickup = false, fullBright = false, noFog = false, fov = 70, noRecoil = false, noSpread = false,
	toggleGuiKey = "M"
}

for tn, _ in pairs(TEAM_COLORS) do Settings.espTeams[tn] = false Settings.aimTeams[tn] = false end

pcall(function()
	if readfile then
		local l = HttpService:JSONDecode(readfile("PhantomSettings.json"))
		for k, v in pairs(l) do Settings[k] = v end
	end
end)

local function saveSettings()
	pcall(function() if writefile then writefile("PhantomSettings.json", HttpService:JSONEncode(Settings)) end end)
end

-- Colors
local C = {
	bg = Color3.fromRGB(10, 8, 14),
	bgSecondary = Color3.fromRGB(16, 14, 22),
	card = Color3.fromRGB(20, 18, 28),
	cardHover = Color3.fromRGB(28, 24, 38),
	accent = Color3.fromRGB(130, 50, 200),
	accentDark = Color3.fromRGB(90, 35, 140),
	accentBright = Color3.fromRGB(170, 90, 255),
	text = Color3.fromRGB(245, 245, 250),
	textDim = Color3.fromRGB(130, 125, 150),
	success = Color3.fromRGB(70, 200, 110),
	danger = Color3.fromRGB(230, 60, 80),
	warning = Color3.fromRGB(255, 160, 50)
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PhantomGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
_G.PhantomGui = gui

local function destroyGui()
	saveSettings()
	for _, c in pairs(connections) do if c and typeof(c) == "RBXScriptConnection" and c.Connected then c:Disconnect() end end
	_G.PhantomGui = nil
	gui:Destroy()
end

-- Tween helper
local function tween(obj, props, duration, style, dir)
	TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN FRAME
-- ═══════════════════════════════════════════════════════════════
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 580, 0, 420)
main.Position = UDim2.new(0.5, -290, 0.5, -210)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = C.accentDark
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4

-- Intro animation
main.Size = UDim2.new(0, 580, 0, 0)
main.BackgroundTransparency = 1
tween(main, {Size = UDim2.new(0, 580, 0, 420), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = C.bgSecondary
header.BorderSizePixel = 0
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 10)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 15)
headerFix.Position = UDim2.new(0, 0, 1, -15)
headerFix.BackgroundColor3 = C.bgSecondary
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Accent bar
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 2)
accentBar.Position = UDim2.new(0, 0, 1, -2)
accentBar.BorderSizePixel = 0
accentBar.Parent = header
local accentGrad = Instance.new("UIGradient", accentBar)
accentGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.accentDark),
	ColorSequenceKeypoint.new(0.5, C.accentBright),
	ColorSequenceKeypoint.new(1, C.accentDark)
})

-- Logo
local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 12, 0.5, -16)
logo.BackgroundColor3 = C.accent
logo.BorderSizePixel = 0
logo.Parent = header
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "👻"
logoText.TextSize = 16
logoText.Parent = logo

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 120, 0, 22)
titleLabel.Position = UDim2.new(0, 52, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PHANTOM"
titleLabel.TextColor3 = C.text
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 100, 0, 14)
versionLabel.Position = UDim2.new(0, 52, 0, 28)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v5.0 Premium"
versionLabel.TextColor3 = C.accent
versionLabel.TextSize = 10
versionLabel.Font = Enum.Font.GothamSemibold
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Parent = header

-- Header buttons
local function createHeaderBtn(pos, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 28, 0, 28)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.9
	btn.Text = text
	btn.TextColor3 = color
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = header
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.7}) end)
	btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0.9}) end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

createHeaderBtn(UDim2.new(1, -38, 0.5, -14), "✕", C.danger, destroyGui)
local minBtn = createHeaderBtn(UDim2.new(1, -72, 0.5, -14), "─", C.warning, function() end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
table.insert(connections, header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end))
table.insert(connections, header.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 50, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = C.bgSecondary
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 8)

-- Content
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -54, 1, -54)
contentArea.Position = UDim2.new(0, 52, 0, 50)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.Parent = main

-- Minimize
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		tween(main, {Size = UDim2.new(0, 580, 0, 48)}, 0.3, Enum.EasingStyle.Quint)
		minBtn.Text = "+"
	else
		tween(main, {Size = UDim2.new(0, 580, 0, 420)}, 0.3, Enum.EasingStyle.Back)
		minBtn.Text = "─"
	end
end)

-- Tab system
local tabs = {}
local currentTab = nil

local function createTab(icon, name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.BackgroundColor3 = C.card
	btn.BackgroundTransparency = 1
	btn.Text = icon
	btn.TextSize = 18
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0.5, 0)
	indicator.Position = UDim2.new(0, 0, 0.25, 0)
	indicator.BackgroundColor3 = C.accent
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Parent = btn
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.ScrollBarThickness = 3
	frame.ScrollBarImageColor3 = C.accent
	frame.ScrollBarImageTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	frame.Parent = contentArea

	local layout = Instance.new("UIListLayout", frame)
	layout.Padding = UDim.new(0, 6)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	local pad = Instance.new("UIPadding", frame)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)

	tabs[name] = {btn = btn, frame = frame, indicator = indicator}

	btn.MouseEnter:Connect(function()
		if currentTab ~= tabs[name] then tween(btn, {BackgroundTransparency = 0.7}) end
	end)
	btn.MouseLeave:Connect(function()
		if currentTab ~= tabs[name] then tween(btn, {BackgroundTransparency = 1}) end
	end)

	btn.MouseButton1Click:Connect(function()
		if currentTab then
			tween(currentTab.btn, {BackgroundTransparency = 1})
			tween(currentTab.indicator, {BackgroundTransparency = 1})
			currentTab.frame.Visible = false
		end
		currentTab = tabs[name]
		tween(btn, {BackgroundTransparency = 0.5})
		tween(indicator, {BackgroundTransparency = 0})
		frame.Visible = true
	end)

	return frame
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════

local function createSection(parent, text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 24)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "  " .. text:upper()
	label.TextColor3 = C.textDim
	label.TextSize = 10
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.text
	label.TextSize = 11
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 38, 0, 20)
	toggleBg.Position = UDim2.new(1, -48, 0.5, -10)
	toggleBg.BackgroundColor3 = default and C.success or Color3.fromRGB(45, 40, 55)
	toggleBg.Text = ""
	toggleBg.BorderSizePixel = 0
	toggleBg.AutoButtonColor = false
	toggleBg.Parent = frame
	Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	knob.BackgroundColor3 = C.text
	knob.BorderSizePixel = 0
	knob.Parent = toggleBg
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isOn = default

	frame.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = C.cardHover}) end)
	frame.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = C.card}) end)

	toggleBg.MouseButton1Click:Connect(function()
		isOn = not isOn
		tween(toggleBg, {BackgroundColor3 = isOn and C.success or Color3.fromRGB(45, 40, 55)})
		tween(knob, {Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
		callback(isOn)
	end)

	return {setOn = function(on)
		isOn = on
		toggleBg.BackgroundColor3 = isOn and C.success or Color3.fromRGB(45, 40, 55)
		knob.Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	end}
end

local function createButton(parent, text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = color or C.accent
	btn.Text = text
	btn.TextColor3 = C.text
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.2}) end)
	btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0}) end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 46)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 18)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.text
	label.TextSize = 11
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.4, -12, 0, 18)
	valueLabel.Position = UDim2.new(0.6, 0, 0, 4)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(math.floor(default))
	valueLabel.TextColor3 = C.accent
	valueLabel.TextSize = 11
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.new(0, 12, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
	track.BorderSizePixel = 0
	track.Parent = frame
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = C.accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	knob.BackgroundColor3 = C.text
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false
	local sliderConn = nil

	local function update(pos)
		local p = math.clamp(pos, 0, 1)
		local value = min + p * (max - min)
		tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05)
		tween(knob, {Position = UDim2.new(p, -7, 0.5, -7)}, 0.05)
		valueLabel.Text = tostring(math.floor(value))
		callback(value)
	end

	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			sliderConn = UserInputService.InputChanged:Connect(function(inp)
				if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
					update(math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
				end
			end)
		end
	end)

	knob.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
			if sliderConn then sliderConn:Disconnect() end
		end
	end)

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			update(math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
		end
	end)

	return frame
end

local function createLocBtn(parent, loc)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 3, 0, 18)
	icon.Position = UDim2.new(0, 8, 0.5, -9)
	icon.BackgroundColor3 = loc.autoGrab and C.warning or C.accent
	icon.BorderSizePixel = 0
	icon.Parent = frame
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 2)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.Position = UDim2.new(0, 18, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = loc.name
	label.TextColor3 = C.text
	label.TextSize = 11
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	frame.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = C.cardHover}) end)
	frame.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = C.card}) end)

	local btnColor = loc.autoGrab and C.warning or C.accent
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 48, 0, 22)
	btn.Position = UDim2.new(1, -56, 0.5, -11)
	btn.BackgroundColor3 = btnColor
	btn.Text = loc.autoGrab and "GRAB" or "GO"
	btn.TextColor3 = C.text
	btn.TextSize = 9
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local isBusy = false
	btn.MouseButton1Click:Connect(function()
		if isBusy then return end
		local c = player.Character
		if not c or not c:FindFirstChild("HumanoidRootPart") then return end
		isBusy = true
		local origText = btn.Text

		if loc.autoGrab then
			local origCF = c.HumanoidRootPart.CFrame
			local before = 0
			local bp = player:FindFirstChild("Backpack")
			if bp then before = #bp:GetChildren() end
			for _, v in pairs(c:GetChildren()) do if v:IsA("Tool") then before = before + 1 end end

			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "⏳"

			for i = 1, 25 do
				for _, v in pairs(workspace:GetDescendants()) do
					if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
						if (v.Parent.Position - c.HumanoidRootPart.Position).Magnitude < 15 then
							pcall(fireproximityprompt, v)
						end
					end
				end
				task.wait(0.1)
				local after = 0
				if bp then after = #bp:GetChildren() end
				for _, v in pairs(c:GetChildren()) do if v:IsA("Tool") then after = after + 1 end end
				if after > before then
					c.HumanoidRootPart.CFrame = origCF
					btn.Text = "✓"
					tween(btn, {BackgroundColor3 = C.success})
					task.wait(0.3)
					btn.Text = origText
					tween(btn, {BackgroundColor3 = btnColor})
					isBusy = false
					return
				end
			end
			c.HumanoidRootPart.CFrame = origCF
			btn.Text = "✗"
			tween(btn, {BackgroundColor3 = C.danger})
		else
			btn.Text = "⏳"
			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "✓"
			tween(btn, {BackgroundColor3 = C.success})
		end

		task.wait(0.3)
		btn.Text = origText
		tween(btn, {BackgroundColor3 = btnColor})
		isBusy = false
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════════════════════════════════
local fovCircle = nil

local function updateFOVCircle()
	if fovCircle then fovCircle:Destroy() end
	if not Settings.showFOV or not Settings.aimEnabled then return end

	fovCircle = Instance.new("Frame")
	fovCircle.Size = UDim2.new(0, Settings.fovSize * 2, 0, Settings.fovSize * 2)
	fovCircle.Position = UDim2.new(0.5, -Settings.fovSize, 0.5, -Settings.fovSize)
	fovCircle.BackgroundTransparency = 1
	fovCircle.Parent = gui

	local stroke = Instance.new("UIStroke", fovCircle)
	stroke.Color = C.accent
	stroke.Thickness = 1.5
	stroke.Transparency = 0.5
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
end

-- ═══════════════════════════════════════════════════════════════
-- TABS SETUP
-- ═══════════════════════════════════════════════════════════════

-- TELEPORTS
local tpFrame = createTab("📍", "TP")
createSection(tpFrame, "Locations")
for _, loc in ipairs(LOCATIONS) do createLocBtn(tpFrame, loc) end

-- PLAYERS
local playersFrame = createTab("👥", "Players")
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, 0, 0, 0)
playerListFrame.BackgroundTransparency = 1
playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
playerListFrame.Parent = playersFrame
Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 4)

local function refreshPlayers()
	for _, c in pairs(playerListFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 34)
			f.BackgroundColor3 = C.card
			f.BorderSizePixel = 0
			f.Parent = playerListFrame
			Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

			local tn = p.Team and p.Team.Name or "Civilian"
			local tc = TEAM_COLORS[tn] or C.textDim

			local dot = Instance.new("Frame", f)
			dot.Size = UDim2.new(0, 6, 0, 6)
			dot.Position = UDim2.new(0, 10, 0.5, -3)
			dot.BackgroundColor3 = tc
			dot.BorderSizePixel = 0
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

			local nl = Instance.new("TextLabel", f)
			nl.Size = UDim2.new(1, -80, 1, 0)
			nl.Position = UDim2.new(0, 22, 0, 0)
			nl.BackgroundTransparency = 1
			nl.Text = p.Name
			nl.TextColor3 = C.text
			nl.TextSize = 11
			nl.Font = Enum.Font.GothamSemibold
			nl.TextXAlignment = Enum.TextXAlignment.Left

			local tb = Instance.new("TextButton", f)
			tb.Size = UDim2.new(0, 40, 0, 22)
			tb.Position = UDim2.new(1, -50, 0.5, -11)
			tb.BackgroundColor3 = C.accent
			tb.Text = "TP"
			tb.TextColor3 = C.text
			tb.TextSize = 9
			tb.Font = Enum.Font.GothamBold
			tb.BorderSizePixel = 0
			Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)

			tb.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
				end
			end)
		end
	end
end

createSection(playersFrame, "Players")
createButton(playersFrame, "🔄 Refresh", Color3.fromRGB(40, 38, 50), refreshPlayers)
refreshPlayers()

-- MOVEMENT
local moveFrame = createTab("🏃", "Move")
createSection(moveFrame, "Movement")
createToggle(moveFrame, "Bhop", Settings.bhop, function(on) Settings.bhop = on saveSettings() end)
createToggle(moveFrame, "Infinite Jump", Settings.infJump, function(on) Settings.infJump = on saveSettings() end)
createToggle(moveFrame, "Infinite Stamina", Settings.infStamina, function(on) Settings.infStamina = on saveSettings() end)
createToggle(moveFrame, "Fly", Settings.fly, function(on) Settings.fly = on saveSettings() end)
createToggle(moveFrame, "Noclip", Settings.noclip, function(on) Settings.noclip = on saveSettings() end)
createSection(moveFrame, "Speed")
createSlider(moveFrame, "Fly Speed", 10, 200, Settings.flySpeed, function(v) Settings.flySpeed = v end)
createSlider(moveFrame, "Walk Speed", 16, 100, Settings.walkSpeed, function(v)
	Settings.walkSpeed = v
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = v
	end
end)
createSlider(moveFrame, "Jump Power", 50, 200, Settings.jumpPower, function(v)
	Settings.jumpPower = v
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.JumpPower = v
	end
end)

-- Movement logic
local flying, flyBV, flyBG = false, nil, nil

table.insert(connections, RunService.RenderStepped:Connect(function()
	local c = player.Character
	if not c then return end
	local hum = c:FindFirstChild("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if Settings.infStamina then
		for _, v in pairs(c:GetDescendants()) do
			if v.Name == "Stamina" and v:IsA("NumberValue") then v.Value = 100 end
		end
	end

	if Settings.noclip then
		for _, p in pairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end

	if Settings.fly then
		if not flying then
			flying = true
			flyBV = Instance.new("BodyVelocity", hrp)
			flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			flyBV.Velocity = Vector3.zero
			flyBG = Instance.new("BodyGyro", hrp)
			flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			flyBG.P = 9e4
		end
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.flySpeed or Vector3.zero
		flyBG.CFrame = cam.CFrame
	else
		if flying then
			flying = false
			if flyBV then flyBV:Destroy() end
			if flyBG then flyBG:Destroy() end
		end
	end

	if Settings.spinbot then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.spinSpeed), 0)
	end
end))

table.insert(connections, UserInputService.JumpRequest:Connect(function()
	if Settings.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

table.insert(connections, RunService.Heartbeat:Connect(function()
	if Settings.bhop and player.Character and player.Character:FindFirstChild("Humanoid") then
		if player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
			player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end))

-- ESP TAB with Preview
local espFrame = createTab("👁", "ESP")

-- ESP Preview Panel
local espPreviewContainer = Instance.new("Frame")
espPreviewContainer.Size = UDim2.new(1, 0, 0, 100)
espPreviewContainer.BackgroundColor3 = C.card
espPreviewContainer.BorderSizePixel = 0
espPreviewContainer.Parent = espFrame
Instance.new("UICorner", espPreviewContainer).CornerRadius = UDim.new(0, 8)

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, 0, 0, 20)
previewTitle.Position = UDim2.new(0, 0, 0, 4)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "ESP PREVIEW"
previewTitle.TextColor3 = C.textDim
previewTitle.TextSize = 9
previewTitle.Font = Enum.Font.GothamBold
previewTitle.Parent = espPreviewContainer

local previewBox = Instance.new("Frame")
previewBox.Size = UDim2.new(0, 50, 0, 60)
previewBox.Position = UDim2.new(0.5, -25, 0.5, -20)
previewBox.BackgroundTransparency = 1
previewBox.Parent = espPreviewContainer

local previewOutline = Instance.new("Frame")
previewOutline.Size = UDim2.new(1, 0, 1, 0)
previewOutline.BackgroundTransparency = 1
previewOutline.Visible = false
previewOutline.Parent = previewBox
local previewStroke = Instance.new("UIStroke", previewOutline)
previewStroke.Color = C.danger
previewStroke.Thickness = 1.5
Instance.new("UICorner", previewOutline).CornerRadius = UDim.new(0, 4)

local previewName = Instance.new("TextLabel")
previewName.Size = UDim2.new(0, 80, 0, 12)
previewName.Position = UDim2.new(0.5, -40, 0, -18)
previewName.BackgroundTransparency = 1
previewName.Text = "PlayerName"
previewName.TextColor3 = C.text
previewName.TextSize = 10
previewName.Font = Enum.Font.GothamBold
previewName.Visible = false
previewName.Parent = previewBox

local previewTeam = Instance.new("TextLabel")
previewTeam.Size = UDim2.new(0, 80, 0, 10)
previewTeam.Position = UDim2.new(0.5, -40, 0, -6)
previewTeam.BackgroundTransparency = 1
previewTeam.Text = "Max Security"
previewTeam.TextColor3 = C.danger
previewTeam.TextSize = 8
previewTeam.Font = Enum.Font.GothamSemibold
previewTeam.Visible = false
previewTeam.Parent = previewBox

local previewDist = Instance.new("TextLabel")
previewDist.Size = UDim2.new(0, 80, 0, 10)
previewDist.Position = UDim2.new(0.5, -40, 1, 2)
previewDist.BackgroundTransparency = 1
previewDist.Text = "[45m]"
previewDist.TextColor3 = C.textDim
previewDist.TextSize = 8
previewDist.Font = Enum.Font.Gotham
previewDist.Visible = false
previewDist.Parent = previewBox

local previewHealthBg = Instance.new("Frame")
previewHealthBg.Size = UDim2.new(0, 40, 0, 3)
previewHealthBg.Position = UDim2.new(0.5, -20, 1, 14)
previewHealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
previewHealthBg.BorderSizePixel = 0
previewHealthBg.Visible = false
previewHealthBg.Parent = previewBox
Instance.new("UICorner", previewHealthBg).CornerRadius = UDim.new(1, 0)

local previewHealthFill = Instance.new("Frame")
previewHealthFill.Size = UDim2.new(0.7, 0, 1, 0)
previewHealthFill.BackgroundColor3 = C.success
previewHealthFill.BorderSizePixel = 0
previewHealthFill.Parent = previewHealthBg
Instance.new("UICorner", previewHealthFill).CornerRadius = UDim.new(1, 0)

local function updatePreview()
	previewName.Visible = Settings.showName
	previewTeam.Visible = Settings.showTeam
	previewDist.Visible = Settings.showDistance
	previewHealthBg.Visible = Settings.showHealth
	previewOutline.Visible = Settings.showBox
end

-- ESP Functions
local function updateESP(plr)
	if plr == player then return end
	local c = plr.Character
	if not c then return end
	local head = c:FindFirstChild("Head")
	local hum = c:FindFirstChild("Humanoid")
	if not head then return end

	local tn = plr.Team and plr.Team.Name or "Civilian"
	local tc = TEAM_COLORS[tn] or C.textDim
	local show = Settings.espEnabled and Settings.espTeams[tn]

	local old = head:FindFirstChild("PhantomESP")
	local oldH = c:FindFirstChild("PhantomHighlight")
	if old then old:Destroy() end
	if oldH then oldH:Destroy() end
	if not show then return end

	local bb = Instance.new("BillboardGui", head)
	bb.Name = "PhantomESP"
	bb.Size = UDim2.new(0, 100, 0, 50)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.AlwaysOnTop = true

	local y = 0
	if Settings.showName then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 12)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = plr.Name
		l.TextColor3 = C.text
		l.TextSize = 10
		l.Font = Enum.Font.GothamBold
		l.TextStrokeTransparency = 0
		y = y + 12
	end
	if Settings.showTeam then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 10)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = tn
		l.TextColor3 = tc
		l.TextSize = 8
		l.Font = Enum.Font.GothamSemibold
		l.TextStrokeTransparency = 0
		y = y + 11
	end
	if Settings.showDistance then
		local l = Instance.new("TextLabel", bb)
		l.Name = "Distance"
		l.Size = UDim2.new(1, 0, 0, 10)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = "[0m]"
		l.TextColor3 = C.textDim
		l.TextSize = 8
		l.Font = Enum.Font.Gotham
		l.TextStrokeTransparency = 0
		y = y + 10
	end
	if Settings.showHealth and hum then
		local bg = Instance.new("Frame", bb)
		bg.Size = UDim2.new(0.6, 0, 0, 3)
		bg.Position = UDim2.new(0.2, 0, 0, y + 2)
		bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		bg.BorderSizePixel = 0
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
		local fill = Instance.new("Frame", bg)
		fill.Name = "HealthFill"
		fill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
		fill.BackgroundColor3 = C.success
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	end
	if Settings.showBox then
		local hl = Instance.new("Highlight", c)
		hl.Name = "PhantomHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = tc
		hl.OutlineTransparency = 0.3
	end
end

local function refreshESP() for _, p in pairs(Players:GetPlayers()) do updateESP(p) end updatePreview() end
local function clearESP()
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
	if on then refreshESP() startDistLoop() else clearESP() end
	saveSettings()
end)

createSection(espFrame, "Visuals")
createToggle(espFrame, "Show Name", Settings.showName, function(on) Settings.showName = on refreshESP() saveSettings() end)
createToggle(espFrame, "Show Team", Settings.showTeam, function(on) Settings.showTeam = on refreshESP() saveSettings() end)
createToggle(espFrame, "Show Distance", Settings.showDistance, function(on) Settings.showDistance = on refreshESP() saveSettings() end)
createToggle(espFrame, "Show Health", Settings.showHealth, function(on) Settings.showHealth = on refreshESP() saveSettings() end)
createToggle(espFrame, "Show Outline", Settings.showBox, function(on) Settings.showBox = on refreshESP() saveSettings() end)

createSection(espFrame, "Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(espFrame, tn, Settings.espTeams[tn], function(on) Settings.espTeams[tn] = on refreshESP() saveSettings() end)
end

for _, p in pairs(Players:GetPlayers()) do
	if p ~= player then
		table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.5) if Settings.espEnabled then updateESP(p) end end))
	end
end
table.insert(connections, Players.PlayerAdded:Connect(function(p)
	table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.5) if Settings.espEnabled then updateESP(p) end end))
end))

updatePreview()

-- AIM TAB
local aimFrame = createTab("🎯", "Aim")

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
							if sd <= Settings.fovSize and sd < closestD then
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
createToggle(aimFrame, "Enable Aim Assist", Settings.aimEnabled, function(on) Settings.aimEnabled = on updateFOVCircle() saveSettings() end)
createToggle(aimFrame, "Show FOV Circle", Settings.showFOV, function(on) Settings.showFOV = on updateFOVCircle() saveSettings() end)
createToggle(aimFrame, "Wall Check", Settings.wallCheck, function(on) Settings.wallCheck = on saveSettings() end)
createToggle(aimFrame, "Sticky Aim", Settings.stickyAim, function(on) Settings.stickyAim = on stickyTarget = nil saveSettings() end)

createSection(aimFrame, "Settings")
createSlider(aimFrame, "Smoothness", 5, 100, Settings.aimSmoothness * 100, function(v) Settings.aimSmoothness = v / 100 end)
createSlider(aimFrame, "FOV Size", 30, 300, Settings.fovSize, function(v) Settings.fovSize = v updateFOVCircle() end)

createSection(aimFrame, "Hold Key")
local hkFrame = Instance.new("Frame")
hkFrame.Size = UDim2.new(1, 0, 0, 36)
hkFrame.BackgroundColor3 = C.card
hkFrame.BorderSizePixel = 0
hkFrame.Parent = aimFrame
Instance.new("UICorner", hkFrame).CornerRadius = UDim.new(0, 6)

local hkLabel = Instance.new("TextLabel", hkFrame)
hkLabel.Size = UDim2.new(0.6, 0, 1, 0)
hkLabel.Position = UDim2.new(0, 12, 0, 0)
hkLabel.BackgroundTransparency = 1
hkLabel.Text = "Hold Key: " .. Settings.aimHoldKey
hkLabel.TextColor3 = C.text
hkLabel.TextSize = 11
hkLabel.Font = Enum.Font.GothamSemibold
hkLabel.TextXAlignment = Enum.TextXAlignment.Left

local hkBtn = Instance.new("TextButton", hkFrame)
hkBtn.Size = UDim2.new(0, 50, 0, 22)
hkBtn.Position = UDim2.new(1, -58, 0.5, -11)
hkBtn.BackgroundColor3 = C.accent
hkBtn.Text = "Set"
hkBtn.TextColor3 = C.text
hkBtn.TextSize = 9
hkBtn.Font = Enum.Font.GothamBold
hkBtn.BorderSizePixel = 0
Instance.new("UICorner", hkBtn).CornerRadius = UDim.new(0, 4)

hkBtn.MouseButton1Click:Connect(function()
	hkBtn.Text = "..."
	local c
	c = UserInputService.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode ~= Enum.KeyCode.Unknown then
			aimHoldKey = i.KeyCode
			Settings.aimHoldKey = i.KeyCode.Name
			hkLabel.Text = "Hold Key: " .. i.KeyCode.Name
			hkBtn.Text = "Set"
			c:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(aimFrame, "Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(aimFrame, tn, Settings.aimTeams[tn], function(on) Settings.aimTeams[tn] = on saveSettings() end)
end

-- GUNS TAB
local gunsFrame = createTab("🔫", "Guns")
createSection(gunsFrame, "Modifications")
createToggle(gunsFrame, "No Recoil", Settings.noRecoil, function(on) Settings.noRecoil = on saveSettings() end)
createToggle(gunsFrame, "No Spread", Settings.noSpread, function(on) Settings.noSpread = on saveSettings() end)

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.noRecoil and not Settings.noSpread then return end
	local c = player.Character
	if not c then return end
	for _, t in pairs(c:GetChildren()) do
		if t:IsA("Tool") then
			for _, d in pairs(t:GetDescendants()) do
				if Settings.noRecoil and d.Name:lower():find("recoil") and (d:IsA("NumberValue") or d:IsA("IntValue")) then d.Value = 0 end
				if Settings.noSpread and (d.Name:lower():find("spread") or d.Name:lower():find("accuracy")) and (d:IsA("NumberValue") or d:IsA("IntValue")) then d.Value = 0 end
			end
		end
	end
end))

-- VISUALS TAB
local visualsFrame = createTab("🎨", "Visual")
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
	local old = gui:FindFirstChild("Crosshair")
	if old then old:Destroy() end
	if not on then saveSettings() return end

	local cg = Instance.new("ScreenGui", gui)
	cg.Name = "Crosshair"
	local col = Color3.fromRGB(Settings.crosshairColor[1], Settings.crosshairColor[2], Settings.crosshairColor[3])

	for _, d in ipairs({
		{UDim2.new(0, 2, 0, 12), UDim2.new(0.5, -1, 0.5, -18)},
		{UDim2.new(0, 2, 0, 12), UDim2.new(0.5, -1, 0.5, 6)},
		{UDim2.new(0, 12, 0, 2), UDim2.new(0.5, -18, 0.5, -1)},
		{UDim2.new(0, 12, 0, 2), UDim2.new(0.5, 6, 0.5, -1)}
	}) do
		local l = Instance.new("Frame", cg)
		l.Size = d[1]
		l.Position = d[2]
		l.BackgroundColor3 = col
		l.BorderSizePixel = 0
	end
	saveSettings()
end)

-- SETTINGS TAB
local setFrame = createTab("⚙️", "Settings")

createSection(setFrame, "Keybind")
local tkFrame = Instance.new("Frame")
tkFrame.Size = UDim2.new(1, 0, 0, 36)
tkFrame.BackgroundColor3 = C.card
tkFrame.BorderSizePixel = 0
tkFrame.Parent = setFrame
Instance.new("UICorner", tkFrame).CornerRadius = UDim.new(0, 6)

local tkLabel = Instance.new("TextLabel", tkFrame)
tkLabel.Size = UDim2.new(0.6, 0, 1, 0)
tkLabel.Position = UDim2.new(0, 12, 0, 0)
tkLabel.BackgroundTransparency = 1
tkLabel.Text = "Toggle GUI: " .. Settings.toggleGuiKey
tkLabel.TextColor3 = C.text
tkLabel.TextSize = 11
tkLabel.Font = Enum.Font.GothamSemibold
tkLabel.TextXAlignment = Enum.TextXAlignment.Left

local tkBtn = Instance.new("TextButton", tkFrame)
tkBtn.Size = UDim2.new(0, 50, 0, 22)
tkBtn.Position = UDim2.new(1, -58, 0.5, -11)
tkBtn.BackgroundColor3 = C.accent
tkBtn.Text = "Set"
tkBtn.TextColor3 = C.text
tkBtn.TextSize = 9
tkBtn.Font = Enum.Font.GothamBold
tkBtn.BorderSizePixel = 0
Instance.new("UICorner", tkBtn).CornerRadius = UDim.new(0, 4)

tkBtn.MouseButton1Click:Connect(function()
	tkBtn.Text = "..."
	local c
	c = UserInputService.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode ~= Enum.KeyCode.Unknown then
			Settings.toggleGuiKey = i.KeyCode.Name
			tkLabel.Text = "Toggle GUI: " .. i.KeyCode.Name
			tkBtn.Text = "Set"
			c:Disconnect()
			saveSettings()
		end
	end)
end)

createSection(setFrame, "Actions")
createButton(setFrame, "💾 Save Settings", C.success, saveSettings)
createButton(setFrame, "💀 Force Reset", C.warning, function()
	if player.Character then player.Character:BreakJoints() end
end)
createButton(setFrame, "🗑 Destroy GUI", C.danger, destroyGui)

-- CREDITS TAB
local creditsFrame = createTab("ℹ️", "Info")

local creditsCard = Instance.new("Frame")
creditsCard.Size = UDim2.new(1, 0, 0, 180)
creditsCard.BackgroundColor3 = C.card
creditsCard.BorderSizePixel = 0
creditsCard.Parent = creditsFrame
Instance.new("UICorner", creditsCard).CornerRadius = UDim.new(0, 10)

local cLogo = Instance.new("TextLabel", creditsCard)
cLogo.Size = UDim2.new(1, 0, 0, 50)
cLogo.Position = UDim2.new(0, 0, 0, 15)
cLogo.BackgroundTransparency = 1
cLogo.Text = "👻 PHANTOM"
cLogo.TextColor3 = C.accent
cLogo.TextSize = 24
cLogo.Font = Enum.Font.GothamBlack

local cVer = Instance.new("TextLabel", creditsCard)
cVer.Size = UDim2.new(1, 0, 0, 16)
cVer.Position = UDim2.new(0, 0, 0, 60)
cVer.BackgroundTransparency = 1
cVer.Text = "Version 5.0 Premium"
cVer.TextColor3 = C.textDim
cVer.TextSize = 11
cVer.Font = Enum.Font.GothamSemibold

local cDiv = Instance.new("Frame", creditsCard)
cDiv.Size = UDim2.new(0.5, 0, 0, 1)
cDiv.Position = UDim2.new(0.25, 0, 0, 90)
cDiv.BackgroundColor3 = C.accent
cDiv.BackgroundTransparency = 0.5
cDiv.BorderSizePixel = 0

local cRole = Instance.new("TextLabel", creditsCard)
cRole.Size = UDim2.new(1, 0, 0, 14)
cRole.Position = UDim2.new(0, 0, 0, 105)
cRole.BackgroundTransparency = 1
cRole.Text = "Developer / Founder"
cRole.TextColor3 = C.textDim
cRole.TextSize = 10
cRole.Font = Enum.Font.Gotham

local cName = Instance.new("TextLabel", creditsCard)
cName.Size = UDim2.new(1, 0, 0, 26)
cName.Position = UDim2.new(0, 0, 0, 120)
cName.BackgroundTransparency = 1
cName.Text = "Mishka"
cName.TextColor3 = C.accentBright
cName.TextSize = 20
cName.Font = Enum.Font.GothamBold

local cThank = Instance.new("TextLabel", creditsCard)
cThank.Size = UDim2.new(1, 0, 0, 14)
cThank.Position = UDim2.new(0, 0, 0, 150)
cThank.BackgroundTransparency = 1
cThank.Text = "Thank you for using Phantom! 💜"
cThank.TextColor3 = C.textDim
cThank.TextSize = 10
cThank.Font = Enum.Font.Gotham

-- Keybind handler
table.insert(connections, UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode.Name == Settings.toggleGuiKey then
		main.Visible = not main.Visible
	end
end))

-- Select first tab
tabs["TP"].btn.MouseButton1Click:Fire()

print("👻 Phantom V5 by Mishka | Press " .. Settings.toggleGuiKey .. " to toggle")
