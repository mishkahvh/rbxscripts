local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

if _G.PhantomGui then _G.PhantomGui:Destroy() end

local connections = {}
local originalCameraShake = nil
local cameraShaker = nil

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
local PRISONER_TEAMS = {"Minimum Security", "Medium Security", "Maximum Security", "Escapee"}
local COP_TEAMS = {"State Police", "Department of Corrections"}

local Settings = {
	espEnabled = false, showName = false, showTeam = false, showDistance = false, showHealth = false, showBox = false, showTracer = false, showTool = false, espTeams = {},
	aimEnabled = false, aimSmoothness = 0.35, aimFOV = 90, aimPart = "Head", aimHoldKey = "Q", showFOV = false, fovSize = 90, wallCheck = false, stickyAim = false, aimTeams = {}, triggerbot = false, hitChance = 100,
	crosshairEnabled = false, crosshairStyle = "Cross", crosshairColor = {255, 255, 255},
	bhop = false, infJump = false, infStamina = false, fly = false, noclip = false, flySpeed = 50, jumpPower = 50, walkSpeed = 16, cframeWalk = false, cframeSpeed = 1,
	noPepper = false, antiCuff = false, noStun = false, spinbot = false, spinSpeed = 10, desync = false,
	infZoom = false, autoPickup = false, fullBright = false, noFog = false, fov = 70,
	noRecoil = false, noSpread = false,
	fogDensity = 0, contrast = 0, saturation = 0,
	chatLogs = false, joinLogs = false,
	toggleGuiKey = "M", toggleEspKey = "J",
	autoTeamEsp = true
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

local C = {
	bg = Color3.fromRGB(13, 13, 18),
	bgAlt = Color3.fromRGB(18, 18, 24),
	card = Color3.fromRGB(22, 22, 30),
	cardHover = Color3.fromRGB(30, 30, 42),
	accent = Color3.fromRGB(138, 43, 226),
	accentDark = Color3.fromRGB(88, 28, 146),
	accentLight = Color3.fromRGB(180, 100, 255),
	text = Color3.fromRGB(250, 250, 255),
	textMid = Color3.fromRGB(180, 175, 195),
	textDim = Color3.fromRGB(100, 95, 120),
	success = Color3.fromRGB(45, 212, 121),
	danger = Color3.fromRGB(255, 71, 87),
	warning = Color3.fromRGB(255, 159, 67),
}

local gui = Instance.new("ScreenGui")
gui.Name = "PhantomGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
_G.PhantomGui = gui

local function tween(obj, props, duration, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function ripple(parent, x, y)
	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 0, 0, 0)
	circle.Position = UDim2.new(0, x, 0, y)
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.BackgroundTransparency = 0.7
	circle.BorderSizePixel = 0
	circle.ZIndex = 10
	circle.Parent = parent
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	tween(circle, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
	task.delay(0.5, function() circle:Destroy() end)
end

local function destroyGui()
	saveSettings()
	if originalCameraShake and cameraShaker then
		pcall(function()
			for name, val in pairs(originalCameraShake) do
				if cameraShaker:FindFirstChild(name) then
					cameraShaker[name].Value = val
				end
			end
		end)
	end
	for _, c in pairs(connections) do if c and typeof(c) == "RBXScriptConnection" and c.Connected then c:Disconnect() end end
	_G.PhantomGui = nil
	gui:Destroy()
end

local function getSprintFolder()
	local serverVars = player:FindFirstChild("ServerVariables")
	if serverVars then
		return serverVars:FindFirstChild("Sprint")
	end
	return nil
end

local function getCameraShaker()
	local playerScripts = player:FindFirstChild("PlayerScripts")
	if not playerScripts then return nil end
	local wc = playerScripts:FindFirstChild("WC")
	if not wc then return nil end
	local weaponClient = wc:FindFirstChild("WeaponClient")
	if not weaponClient then return nil end
	return weaponClient:FindFirstChild("CameraShaker")
end

local function setNoRecoil(enabled)
	local shaker = getCameraShaker()
	if not shaker then return end
	cameraShaker = shaker
	if enabled then
		if not originalCameraShake then
			originalCameraShake = {}
			for _, child in pairs(shaker:GetChildren()) do
				if child:IsA("ValueBase") then
					originalCameraShake[child.Name] = child.Value
				end
			end
		end
		for _, child in pairs(shaker:GetChildren()) do
			if child:IsA("NumberValue") or child:IsA("IntValue") then
				child.Value = 0
			end
		end
		local presets = shaker:FindFirstChild("CameraShakePresets")
		if presets then
			for _, preset in pairs(presets:GetChildren()) do
				for _, val in pairs(preset:GetChildren()) do
					if val:IsA("NumberValue") or val:IsA("IntValue") then
						val.Value = 0
					end
				end
			end
		end
	else
		if originalCameraShake then
			for name, val in pairs(originalCameraShake) do
				local child = shaker:FindFirstChild(name)
				if child then child.Value = val end
			end
		end
	end
end

local function setInfiniteStamina(enabled)
	local sprint = getSprintFolder()
	if not sprint then return end
	if enabled then
		local stamina = sprint:FindFirstChild("Stamina")
		local maxStamina = sprint:FindFirstChild("MaxStamina")
		local subPerM = sprint:FindFirstChild("SubPerM")
		if stamina and maxStamina then
			stamina.Value = maxStamina.Value
		end
		if subPerM then
			subPerM.Value = 0
		end
	end
end

local function removePepperEffect()
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui then
		for _, g in pairs(playerGui:GetDescendants()) do
			local name = g.Name:lower()
			if name:find("pepper") or name:find("blind") or name:find("spray") then
				pcall(function() g:Destroy() end)
			end
			if g:IsA("Frame") or g:IsA("ImageLabel") then
				if g.BackgroundColor3 == Color3.fromRGB(255, 165, 0) or 
				   g.BackgroundColor3 == Color3.fromRGB(255, 140, 0) or
				   g.BackgroundColor3 == Color3.fromRGB(255, 100, 0) or
				   (g.BackgroundTransparency < 0.9 and g.BackgroundColor3.R > 0.8 and g.BackgroundColor3.G > 0.3 and g.BackgroundColor3.G < 0.7 and g.BackgroundColor3.B < 0.2) then
					pcall(function() g.Visible = false g:Destroy() end)
				end
			end
			if g:IsA("ImageLabel") and g.ImageColor3 then
				if g.ImageColor3.R > 0.8 and g.ImageColor3.G > 0.3 and g.ImageColor3.G < 0.7 and g.ImageColor3.B < 0.2 then
					pcall(function() g.Visible = false g:Destroy() end)
				end
			end
		end
	end
	for _, effect in pairs(Lighting:GetChildren()) do
		if effect:IsA("ColorCorrectionEffect") then
			if effect.TintColor.R > 0.8 and effect.TintColor.G > 0.3 and effect.TintColor.G < 0.7 and effect.TintColor.B < 0.3 then
				pcall(function() effect:Destroy() end)
			end
		end
	end
	local character = player.Character
	if character then
		for _, v in pairs(character:GetDescendants()) do
			local name = v.Name:lower()
			if name:find("pepper") or name:find("blind") or name:find("spray") or name:find("effect") then
				pcall(function() v:Destroy() end)
			end
		end
	end
end

local chatLogWindow = nil
local chatLogList = nil
local joinLogWindow = nil
local joinLogList = nil

local function createLogWindow(title, posOffset)
	local window = Instance.new("Frame")
	window.Size = UDim2.new(0, 300, 0, 250)
	window.Position = UDim2.new(0.5, posOffset, 0.5, -125)
	window.AnchorPoint = Vector2.new(0.5, 0)
	window.BackgroundColor3 = C.bg
	window.BorderSizePixel = 0
	window.Visible = false
	window.Parent = gui
	Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
	local windowStroke = Instance.new("UIStroke", window)
	windowStroke.Color = C.accentDark
	windowStroke.Thickness = 1

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = C.bgAlt
	header.BorderSizePixel = 0
	header.Parent = window
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 10)
	headerFix.Position = UDim2.new(0, 0, 1, -10)
	headerFix.BackgroundColor3 = C.bgAlt
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = C.text
	titleLabel.TextSize = 12
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -25, 0.5, -10)
	closeBtn.BackgroundColor3 = C.danger
	closeBtn.BackgroundTransparency = 0.8
	closeBtn.Text = "×"
	closeBtn.TextColor3 = C.danger
	closeBtn.TextSize = 14
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = header
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

	closeBtn.MouseButton1Click:Connect(function()
		window.Visible = false
	end)

	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = window.Position
		end
	end)
	header.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	table.insert(connections, UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -40)
	scroll.Position = UDim2.new(0, 5, 0, 35)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = C.accent
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = window

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 3)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	return window, scroll
end

local function addLogEntry(list, text, color, order)
	local entry = Instance.new("TextLabel")
	entry.Size = UDim2.new(1, -5, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.BackgroundColor3 = C.card
	entry.BorderSizePixel = 0
	entry.Text = text
	entry.TextColor3 = color or C.text
	entry.TextSize = 10
	entry.Font = Enum.Font.Gotham
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entry.TextWrapped = true
	entry.LayoutOrder = order or 0
	entry.Parent = list
	Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)
	local pad = Instance.new("UIPadding", entry)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	return entry
end

chatLogWindow, chatLogList = createLogWindow("Chat Logs", -160)
joinLogWindow, joinLogList = createLogWindow("Join/Leave Logs", 160)

local chatOrder = 0
local joinOrder = 0

local function onPlayerChatted(plr, msg)
	if not Settings.chatLogs then return end
	chatOrder = chatOrder + 1
	local teamColor = TEAM_COLORS[plr.Team and plr.Team.Name or "Civilian"] or C.textMid
	local timestamp = os.date("%H:%M:%S")
	addLogEntry(chatLogList, "[" .. timestamp .. "] " .. plr.Name .. ": " .. msg, teamColor, chatOrder)
	if chatLogList.CanvasPosition.Y > chatLogList.AbsoluteCanvasSize.Y - 300 then
		chatLogList.CanvasPosition = Vector2.new(0, chatLogList.AbsoluteCanvasSize.Y)
	end
end

local function onPlayerJoined(plr)
	if not Settings.joinLogs then return end
	joinOrder = joinOrder + 1
	local timestamp = os.date("%H:%M:%S")
	addLogEntry(joinLogList, "[" .. timestamp .. "] + " .. plr.Name .. " joined", C.success, joinOrder)
	if joinLogList.CanvasPosition.Y > joinLogList.AbsoluteCanvasSize.Y - 300 then
		joinLogList.CanvasPosition = Vector2.new(0, joinLogList.AbsoluteCanvasSize.Y)
	end
end

local function onPlayerLeft(plr)
	if not Settings.joinLogs then return end
	joinOrder = joinOrder + 1
	local timestamp = os.date("%H:%M:%S")
	addLogEntry(joinLogList, "[" .. timestamp .. "] - " .. plr.Name .. " left", C.danger, joinOrder)
	if joinLogList.CanvasPosition.Y > joinLogList.AbsoluteCanvasSize.Y - 300 then
		joinLogList.CanvasPosition = Vector2.new(0, joinLogList.AbsoluteCanvasSize.Y)
	end
end

for _, plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.Chatted:Connect(function(msg)
			onPlayerChatted(plr, msg)
		end)
	end)
end

table.insert(connections, Players.PlayerAdded:Connect(function(plr)
	onPlayerJoined(plr)
	pcall(function()
		plr.Chatted:Connect(function(msg)
			onPlayerChatted(plr, msg)
		end)
	end)
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
	onPlayerLeft(plr)
end))

local loadScreen = Instance.new("Frame")
loadScreen.Size = UDim2.new(1, 0, 1, 0)
loadScreen.BackgroundColor3 = C.bg
loadScreen.BorderSizePixel = 0
loadScreen.Parent = gui

local loadCenter = Instance.new("Frame")
loadCenter.Size = UDim2.new(0, 280, 0, 160)
loadCenter.Position = UDim2.new(0.5, -140, 0.5, -80)
loadCenter.BackgroundTransparency = 1
loadCenter.Parent = loadScreen

local loadLogo = Instance.new("Frame")
loadLogo.Size = UDim2.new(0, 60, 0, 60)
loadLogo.Position = UDim2.new(0.5, -30, 0, 0)
loadLogo.BackgroundColor3 = C.accent
loadLogo.BackgroundTransparency = 1
loadLogo.BorderSizePixel = 0
loadLogo.Parent = loadCenter
Instance.new("UICorner", loadLogo).CornerRadius = UDim.new(0, 14)

local loadLogoStroke = Instance.new("UIStroke", loadLogo)
loadLogoStroke.Color = C.accent
loadLogoStroke.Thickness = 2
loadLogoStroke.Transparency = 1

local loadLogoText = Instance.new("TextLabel")
loadLogoText.Size = UDim2.new(1, 0, 1, 0)
loadLogoText.BackgroundTransparency = 1
loadLogoText.Text = "P"
loadLogoText.TextColor3 = C.text
loadLogoText.TextSize = 28
loadLogoText.Font = Enum.Font.GothamBlack
loadLogoText.TextTransparency = 1
loadLogoText.Parent = loadLogo

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1, 0, 0, 30)
loadTitle.Position = UDim2.new(0, 0, 0, 70)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "PHANTOM"
loadTitle.TextColor3 = C.text
loadTitle.TextSize = 26
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextTransparency = 1
loadTitle.Parent = loadCenter

local loadSub = Instance.new("TextLabel")
loadSub.Size = UDim2.new(1, 0, 0, 18)
loadSub.Position = UDim2.new(0, 0, 0, 98)
loadSub.BackgroundTransparency = 1
loadSub.Text = "Premium Edition"
loadSub.TextColor3 = C.accent
loadSub.TextSize = 12
loadSub.Font = Enum.Font.GothamSemibold
loadSub.TextTransparency = 1
loadSub.Parent = loadCenter

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0.7, 0, 0, 3)
loadBarBg.Position = UDim2.new(0.15, 0, 0, 130)
loadBarBg.BackgroundColor3 = C.bgAlt
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadCenter
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = C.accent
loadBarFill.BorderSizePixel = 0
loadBarFill.Parent = loadBarBg
Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(1, 0)

tween(loadLogo, {BackgroundTransparency = 0}, 0.4)
tween(loadLogoStroke, {Transparency = 0}, 0.4)
tween(loadLogoText, {TextTransparency = 0}, 0.4)
task.wait(0.15)
tween(loadTitle, {TextTransparency = 0}, 0.4)
task.wait(0.1)
tween(loadSub, {TextTransparency = 0}, 0.4)
task.wait(0.1)

for i = 1, 10 do
	tween(loadBarFill, {Size = UDim2.new(i / 10, 0, 1, 0)}, 0.08)
	task.wait(0.08)
end

task.wait(0.2)
tween(loadLogo, {Position = UDim2.new(0.5, -30, 0, -20), BackgroundTransparency = 1}, 0.3)
tween(loadLogoText, {TextTransparency = 1}, 0.3)
tween(loadLogoStroke, {Transparency = 1}, 0.3)
tween(loadTitle, {TextTransparency = 1}, 0.3)
tween(loadSub, {TextTransparency = 1}, 0.3)
tween(loadBarBg, {BackgroundTransparency = 1}, 0.3)
tween(loadBarFill, {BackgroundTransparency = 1}, 0.3)
tween(loadScreen, {BackgroundTransparency = 1}, 0.4)
task.wait(0.4)
loadScreen:Destroy()

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 0, 0, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = C.accentDark
mainStroke.Thickness = 1
mainStroke.Transparency = 0.5

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 50, 1, 50)
shadow.Position = UDim2.new(0, -25, 0, -25)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.ZIndex = 0
shadow.Parent = main

tween(main, {Size = UDim2.new(0, 640, 0, 420)}, 0.5, Enum.EasingStyle.Back)
task.wait(0.3)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = C.bgAlt
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = C.bgAlt
topFix.BorderSizePixel = 0
topFix.Parent = topBar

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, 0)
accentLine.BackgroundColor3 = C.accent
accentLine.BorderSizePixel = 0
accentLine.Parent = topBar

local accentGrad = Instance.new("UIGradient", accentLine)
accentGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.accentDark),
	ColorSequenceKeypoint.new(0.3, C.accent),
	ColorSequenceKeypoint.new(0.5, C.accentLight),
	ColorSequenceKeypoint.new(0.7, C.accent),
	ColorSequenceKeypoint.new(1, C.accentDark)
})

task.spawn(function()
	local offset = 0
	while gui.Parent do
		offset = (offset + 0.003) % 1
		accentGrad.Offset = Vector2.new(offset, 0)
		task.wait()
	end
end)

local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 28, 0, 28)
logoFrame.Position = UDim2.new(0, 10, 0.5, -14)
logoFrame.BackgroundColor3 = C.accent
logoFrame.BorderSizePixel = 0
logoFrame.Parent = topBar
Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 6)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "P"
logoText.TextColor3 = C.text
logoText.TextSize = 16
logoText.Font = Enum.Font.GothamBlack
logoText.Parent = logoFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 100, 0, 20)
titleText.Position = UDim2.new(0, 46, 0, 6)
titleText.BackgroundTransparency = 1
titleText.Text = "PHANTOM"
titleText.TextColor3 = C.text
titleText.TextSize = 15
titleText.Font = Enum.Font.GothamBlack
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = topBar

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(0, 100, 0, 12)
versionText.Position = UDim2.new(0, 46, 0, 25)
versionText.BackgroundTransparency = 1
versionText.Text = "v7.2 by Mishka"
versionText.TextColor3 = C.textDim
versionText.TextSize = 9
versionText.Font = Enum.Font.Gotham
versionText.TextXAlignment = Enum.TextXAlignment.Left
versionText.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = C.danger
closeBtn.BackgroundTransparency = 0.9
closeBtn.Text = "×"
closeBtn.TextColor3 = C.danger
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundTransparency = 0.5}) end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundTransparency = 0.9}) end)
closeBtn.MouseButton1Click:Connect(destroyGui)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0.5, -13)
minBtn.BackgroundColor3 = C.warning
minBtn.BackgroundTransparency = 0.9
minBtn.Text = "−"
minBtn.TextColor3 = C.warning
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

minBtn.MouseEnter:Connect(function() tween(minBtn, {BackgroundTransparency = 0.5}) end)
minBtn.MouseLeave:Connect(function() tween(minBtn, {BackgroundTransparency = 0.9}) end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		tween(main, {Size = UDim2.new(0, 640, 0, 44)}, 0.3, Enum.EasingStyle.Quint)
		minBtn.Text = "+"
	else
		tween(main, {Size = UDim2.new(0, 640, 0, 420)}, 0.35, Enum.EasingStyle.Back)
		minBtn.Text = "−"
	end
end)

local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)
topBar.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
table.insert(connections, UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))

local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, -20, 0, 32)
navBar.Position = UDim2.new(0, 10, 0, 52)
navBar.BackgroundColor3 = C.bgAlt
navBar.BorderSizePixel = 0
navBar.ClipsDescendants = true
navBar.Parent = main
Instance.new("UICorner", navBar).CornerRadius = UDim.new(0, 6)

local navScroll = Instance.new("ScrollingFrame")
navScroll.Size = UDim2.new(1, 0, 1, 0)
navScroll.BackgroundTransparency = 1
navScroll.ScrollBarThickness = 0
navScroll.ScrollingDirection = Enum.ScrollingDirection.X
navScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
navScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
navScroll.Parent = navBar

local navLayout = Instance.new("UIListLayout", navScroll)
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 2)
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local navPad = Instance.new("UIPadding", navScroll)
navPad.PaddingLeft = UDim.new(0, 4)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -94)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = main

local tabs = {}
local currentTab = nil

local function createTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 52, 0, 26)
	btn.BackgroundColor3 = C.card
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = C.textDim
	btn.TextSize = 9
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ClipsDescendants = true
	btn.Parent = navScroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.ScrollBarThickness = 2
	frame.ScrollBarImageColor3 = C.accent
	frame.ScrollBarImageTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	frame.Parent = contentFrame

	local layout = Instance.new("UIListLayout", frame)
	layout.Padding = UDim.new(0, 5)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
	end)

	local pad = Instance.new("UIPadding", frame)
	pad.PaddingRight = UDim.new(0, 6)

	tabs[name] = {btn = btn, frame = frame}

	btn.MouseEnter:Connect(function()
		if currentTab ~= tabs[name] then tween(btn, {BackgroundTransparency = 0.7, TextColor3 = C.textMid}) end
	end)
	btn.MouseLeave:Connect(function()
		if currentTab ~= tabs[name] then tween(btn, {BackgroundTransparency = 1, TextColor3 = C.textDim}) end
	end)
	btn.MouseButton1Click:Connect(function()
		ripple(btn, btn.AbsoluteSize.X / 2, btn.AbsoluteSize.Y / 2)
		if currentTab then
			tween(currentTab.btn, {BackgroundTransparency = 1, TextColor3 = C.textDim})
			currentTab.frame.Visible = false
		end
		currentTab = tabs[name]
		tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = C.accent, TextColor3 = C.text})
		frame.Visible = true
	end)

	return frame
end

local function createSection(parent, text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 20)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text:upper()
	label.TextColor3 = C.textDim
	label.TextSize = 9
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
end

local toggleRefs = {}

local function createToggle(parent, text, default, callback, settingKey)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 30)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -54, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.text
	label.TextSize = 10
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 34, 0, 16)
	toggleBg.Position = UDim2.new(1, -42, 0.5, -8)
	toggleBg.BackgroundColor3 = default and C.success or Color3.fromRGB(45, 42, 55)
	toggleBg.Text = ""
	toggleBg.BorderSizePixel = 0
	toggleBg.AutoButtonColor = false
	toggleBg.Parent = frame
	Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = C.text
	knob.BorderSizePixel = 0
	knob.Parent = toggleBg
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isOn = default

	frame.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = C.cardHover}) end)
	frame.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = C.card}) end)

	local function setOn(on, noCallback)
		isOn = on
		tween(toggleBg, {BackgroundColor3 = isOn and C.success or Color3.fromRGB(45, 42, 55)})
		tween(knob, {Position = isOn and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
		if not noCallback then callback(isOn) end
	end

	toggleBg.MouseButton1Click:Connect(function()
		setOn(not isOn)
	end)

	local ref = {setOn = setOn, getOn = function() return isOn end}
	if settingKey then toggleRefs[settingKey] = ref end
	return ref
end

local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, 0, 0, 16)
	label.Position = UDim2.new(0, 10, 0, 3)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.text
	label.TextSize = 10
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.45, -10, 0, 16)
	valueLabel.Position = UDim2.new(0.55, 0, 0, 3)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(math.floor(default))
	valueLabel.TextColor3 = C.accent
	valueLabel.TextSize = 10
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0, 26)
	track.BackgroundColor3 = Color3.fromRGB(35, 33, 45)
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
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
	knob.BackgroundColor3 = C.text
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = false
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false
	local sliderConn = nil

	local function update(pos)
		local p = math.clamp(pos, 0, 1)
		local value = min + p * (max - min)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, -6, 0.5, -6)
		valueLabel.Text = tostring(math.floor(value))
		callback(value)
	end

	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			sliderConn = UserInputService.InputChanged:Connect(function(inp)
				if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
					update((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
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
			update((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
		end
	end)
end

local function createButton(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 28)
	btn.BackgroundColor3 = C.accent
	btn.Text = text
	btn.TextColor3 = C.text
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ClipsDescendants = true
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.15}) end)
	btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0}) end)
	btn.MouseButton1Click:Connect(function()
		ripple(btn, btn.AbsoluteSize.X / 2, btn.AbsoluteSize.Y / 2)
		callback()
	end)
	return btn
end

local function createKeybind(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 30)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. default
	label.TextColor3 = C.text
	label.TextSize = 10
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 36, 0, 18)
	btn.Position = UDim2.new(1, -44, 0.5, -9)
	btn.BackgroundColor3 = C.accent
	btn.Text = "Set"
	btn.TextColor3 = C.text
	btn.TextSize = 8
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	frame.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = C.cardHover}) end)
	frame.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = C.card}) end)

	btn.MouseButton1Click:Connect(function()
		btn.Text = "..."
		local c
		c = UserInputService.InputBegan:Connect(function(i, g)
			if g then return end
			if i.KeyCode ~= Enum.KeyCode.Unknown then
				label.Text = text .. ": " .. i.KeyCode.Name
				btn.Text = "Set"
				callback(i.KeyCode.Name)
				c:Disconnect()
			end
		end)
	end)
end

local function createLocBtn(parent, loc)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 28)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 0, 14)
	accent.Position = UDim2.new(0, 6, 0.5, -7)
	accent.BackgroundColor3 = loc.autoGrab and C.warning or C.accent
	accent.BorderSizePixel = 0
	accent.Parent = frame
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -65, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = loc.name
	label.TextColor3 = C.text
	label.TextSize = 10
	label.Font = Enum.Font.GothamSemibold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	frame.MouseEnter:Connect(function() tween(frame, {BackgroundColor3 = C.cardHover}) end)
	frame.MouseLeave:Connect(function() tween(frame, {BackgroundColor3 = C.card}) end)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 18)
	btn.Position = UDim2.new(1, -48, 0.5, -9)
	btn.BackgroundColor3 = loc.autoGrab and C.warning or C.accent
	btn.Text = loc.autoGrab and "GRAB" or "GO"
	btn.TextColor3 = C.text
	btn.TextSize = 8
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local busy = false
	btn.MouseButton1Click:Connect(function()
		if busy then return end
		local c = player.Character
		if not c or not c:FindFirstChild("HumanoidRootPart") then return end
		busy = true
		local orig = btn.Text
		local origColor = btn.BackgroundColor3

		if loc.autoGrab then
			local origCF = c.HumanoidRootPart.CFrame
			local before = 0
			local bp = player:FindFirstChild("Backpack")
			if bp then before = #bp:GetChildren() end
			for _, v in pairs(c:GetChildren()) do if v:IsA("Tool") then before = before + 1 end end

			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "..."

			local startTime = tick()
			local timeout = 7

			while tick() - startTime < timeout do
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
					btn.Text = "OK"
					tween(btn, {BackgroundColor3 = C.success})
					task.wait(0.3)
					btn.Text = orig
					tween(btn, {BackgroundColor3 = origColor})
					busy = false
					return
				end
			end

			c.HumanoidRootPart.CFrame = origCF
			btn.Text = "X"
			tween(btn, {BackgroundColor3 = C.danger})
		else
			btn.Text = "..."
			c.HumanoidRootPart.CFrame = CFrame.new(loc.x, loc.y, loc.z)
			btn.Text = "OK"
			tween(btn, {BackgroundColor3 = C.success})
		end
		task.wait(0.3)
		btn.Text = orig
		tween(btn, {BackgroundColor3 = origColor})
		busy = false
	end)
end

local fovCircle = nil
local function updateFOV()
	if fovCircle then fovCircle:Destroy() fovCircle = nil end
	if not Settings.showFOV or not Settings.aimEnabled then return end
	fovCircle = Instance.new("Frame")
	fovCircle.Size = UDim2.new(0, Settings.fovSize * 2, 0, Settings.fovSize * 2)
	fovCircle.Position = UDim2.new(0.5, -Settings.fovSize, 0.5, -Settings.fovSize)
	fovCircle.BackgroundTransparency = 1
	fovCircle.Parent = gui
	local stroke = Instance.new("UIStroke", fovCircle)
	stroke.Color = C.accent
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
end

local function getCurrentTeam(plr)
	if plr and plr.Team then return plr.Team.Name end
	return "Civilian"
end

local function getMyTeam()
	return getCurrentTeam(player)
end

local function isInTable(tbl, val)
	for _, v in ipairs(tbl) do if v == val then return true end end
	return false
end

local function autoSetEspTeams()
	if not Settings.autoTeamEsp then return end
	local myTeam = getMyTeam()
	for tn, _ in pairs(Settings.espTeams) do Settings.espTeams[tn] = false end
	if isInTable(PRISONER_TEAMS, myTeam) then
		for _, tn in ipairs(COP_TEAMS) do Settings.espTeams[tn] = true end
	elseif isInTable(COP_TEAMS, myTeam) then
		for _, tn in ipairs(PRISONER_TEAMS) do Settings.espTeams[tn] = true end
	end
end

local tpFrame = createTab("Teleport")
createSection(tpFrame, "Locations")
for _, loc in ipairs(LOCATIONS) do createLocBtn(tpFrame, loc) end

local playersFrame = createTab("Players")
local playerList = Instance.new("Frame")
playerList.Size = UDim2.new(1, 0, 0, 0)
playerList.BackgroundTransparency = 1
playerList.AutomaticSize = Enum.AutomaticSize.Y
playerList.Parent = playersFrame
Instance.new("UIListLayout", playerList).Padding = UDim.new(0, 4)

local function refreshPlayers()
	for _, c in pairs(playerList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 28)
			f.BackgroundColor3 = C.card
			f.BorderSizePixel = 0
			f.Parent = playerList
			Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)

			local tn = getCurrentTeam(p)
			local tc = TEAM_COLORS[tn] or C.textDim

			local dot = Instance.new("Frame", f)
			dot.Size = UDim2.new(0, 6, 0, 6)
			dot.Position = UDim2.new(0, 8, 0.5, -3)
			dot.BackgroundColor3 = tc
			dot.BorderSizePixel = 0
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

			local nl = Instance.new("TextLabel", f)
			nl.Size = UDim2.new(1, -65, 1, 0)
			nl.Position = UDim2.new(0, 18, 0, 0)
			nl.BackgroundTransparency = 1
			nl.Text = p.Name
			nl.TextColor3 = C.text
			nl.TextSize = 10
			nl.Font = Enum.Font.GothamSemibold
			nl.TextXAlignment = Enum.TextXAlignment.Left

			f.MouseEnter:Connect(function() tween(f, {BackgroundColor3 = C.cardHover}) end)
			f.MouseLeave:Connect(function() tween(f, {BackgroundColor3 = C.card}) end)

			local tb = Instance.new("TextButton", f)
			tb.Size = UDim2.new(0, 32, 0, 18)
			tb.Position = UDim2.new(1, -40, 0.5, -9)
			tb.BackgroundColor3 = C.accent
			tb.Text = "TP"
			tb.TextColor3 = C.text
			tb.TextSize = 8
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
createSection(playersFrame, "Online Players")
createButton(playersFrame, "Refresh List", refreshPlayers)
refreshPlayers()

local mainFrame = createTab("Main")
createSection(mainFrame, "Movement")
createToggle(mainFrame, "Noclip", Settings.noclip, function(on) Settings.noclip = on saveSettings() end)
createToggle(mainFrame, "Fly", Settings.fly, function(on) Settings.fly = on saveSettings() end)
createToggle(mainFrame, "Infinite Jump", Settings.infJump, function(on) Settings.infJump = on saveSettings() end)
createToggle(mainFrame, "Infinite Stamina", Settings.infStamina, function(on) Settings.infStamina = on saveSettings() end)
createToggle(mainFrame, "Bhop", Settings.bhop, function(on) Settings.bhop = on saveSettings() end)
createToggle(mainFrame, "CFrame Walk", Settings.cframeWalk, function(on) Settings.cframeWalk = on saveSettings() end)
createSlider(mainFrame, "CFrame Speed", 0.5, 5, Settings.cframeSpeed, function(v) Settings.cframeSpeed = v end)

createSection(mainFrame, "Anti-Cop")
createToggle(mainFrame, "No Stun", Settings.noStun, function(on) Settings.noStun = on saveSettings() end)
createToggle(mainFrame, "No Pepper Effect", Settings.noPepper, function(on) Settings.noPepper = on saveSettings() end)
createToggle(mainFrame, "Anti Cuff", Settings.antiCuff, function(on) Settings.antiCuff = on saveSettings() end)

createSection(mainFrame, "Fun")
createToggle(mainFrame, "Spinbot", Settings.spinbot, function(on) Settings.spinbot = on saveSettings() end)
createSlider(mainFrame, "Spin Speed", 1, 50, Settings.spinSpeed, function(v) Settings.spinSpeed = v end)
createToggle(mainFrame, "Desync", Settings.desync, function(on) Settings.desync = on saveSettings() end)
createToggle(mainFrame, "Auto Pickup", Settings.autoPickup, function(on) Settings.autoPickup = on saveSettings() end)

createSection(mainFrame, "Speed Settings")
createSlider(mainFrame, "Fly Speed", 10, 200, Settings.flySpeed, function(v) Settings.flySpeed = v end)
createSlider(mainFrame, "Walk Speed", 16, 100, Settings.walkSpeed, function(v)
	Settings.walkSpeed = v
	if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end
end)
createSlider(mainFrame, "Jump Power", 50, 200, Settings.jumpPower, function(v)
	Settings.jumpPower = v
	if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end
end)

local flying, flyBV, flyBG = false, nil, nil
table.insert(connections, RunService.RenderStepped:Connect(function()
	local c = player.Character
	if not c then return end
	local hum = c:FindFirstChild("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if Settings.infStamina then
		setInfiniteStamina(true)
	end

	if Settings.noclip then
		for _, p in pairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end

	if Settings.noStun then
		local stun = c:FindFirstChild("Stun") or c:FindFirstChild("Stunned")
		if stun then pcall(function() stun:Destroy() end) end
		if hum.WalkSpeed < 10 then hum.WalkSpeed = Settings.walkSpeed end
	end

	if Settings.noPepper then
		removePepperEffect()
	end

	if Settings.antiCuff then
		if hum.PlatformStand then hum.PlatformStand = false end
		local cuffs = c:FindFirstChild("Cuffs") or c:FindFirstChild("Handcuffs")
		if cuffs then pcall(function() cuffs:Destroy() end) end
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

	if Settings.cframeWalk then
		local cam = workspace.CurrentCamera
		local moveDir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
		if moveDir.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + (moveDir.Unit * Settings.cframeSpeed)
		end
	end

	if Settings.desync then
		hrp.Velocity = Vector3.new(0, 0, 0)
	end

	if Settings.noRecoil then
		setNoRecoil(true)
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
	if Settings.autoPickup then
		local c = player.Character
		if c and c:FindFirstChild("HumanoidRootPart") then
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
					if (v.Parent.Position - c.HumanoidRootPart.Position).Magnitude < 8 then
						pcall(fireproximityprompt, v)
					end
				end
			end
		end
	end
end))

local espFrame = createTab("ESP")

local espPreview = Instance.new("Frame")
espPreview.Size = UDim2.new(1, 0, 0, 70)
espPreview.BackgroundColor3 = C.card
espPreview.BorderSizePixel = 0
espPreview.Parent = espFrame
Instance.new("UICorner", espPreview).CornerRadius = UDim.new(0, 6)

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(1, 0, 0, 14)
previewLabel.Position = UDim2.new(0, 0, 0, 3)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "PREVIEW"
previewLabel.TextColor3 = C.textDim
previewLabel.TextSize = 8
previewLabel.Font = Enum.Font.GothamBold
previewLabel.Parent = espPreview

local previewBox = Instance.new("Frame")
previewBox.Size = UDim2.new(0, 30, 0, 40)
previewBox.Position = UDim2.new(0.5, -15, 0.5, -12)
previewBox.BackgroundTransparency = 1
previewBox.Parent = espPreview

local pOutline = Instance.new("Frame", previewBox)
pOutline.Size = UDim2.new(1, 0, 1, 0)
pOutline.BackgroundTransparency = 1
pOutline.Visible = false
Instance.new("UIStroke", pOutline).Color = C.danger
Instance.new("UICorner", pOutline).CornerRadius = UDim.new(0, 3)

local pName = Instance.new("TextLabel", previewBox)
pName.Size = UDim2.new(0, 50, 0, 9)
pName.Position = UDim2.new(0.5, -25, 0, -12)
pName.BackgroundTransparency = 1
pName.Text = "Player"
pName.TextColor3 = C.text
pName.TextSize = 7
pName.Font = Enum.Font.GothamBold
pName.Visible = false

local pTeam = Instance.new("TextLabel", previewBox)
pTeam.Size = UDim2.new(0, 50, 0, 7)
pTeam.Position = UDim2.new(0.5, -25, 0, -3)
pTeam.BackgroundTransparency = 1
pTeam.Text = "Escapee"
pTeam.TextColor3 = C.warning
pTeam.TextSize = 6
pTeam.Font = Enum.Font.GothamSemibold
pTeam.Visible = false

local pDist = Instance.new("TextLabel", previewBox)
pDist.Size = UDim2.new(0, 50, 0, 7)
pDist.Position = UDim2.new(0.5, -25, 1, 2)
pDist.BackgroundTransparency = 1
pDist.Text = "[45m]"
pDist.TextColor3 = C.textDim
pDist.TextSize = 6
pDist.Font = Enum.Font.Gotham
pDist.Visible = false

local pHealthBg = Instance.new("Frame", previewBox)
pHealthBg.Size = UDim2.new(0, 24, 0, 2)
pHealthBg.Position = UDim2.new(0.5, -12, 1, 10)
pHealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
pHealthBg.BorderSizePixel = 0
pHealthBg.Visible = false
Instance.new("UICorner", pHealthBg).CornerRadius = UDim.new(1, 0)

local pHealthFill = Instance.new("Frame", pHealthBg)
pHealthFill.Size = UDim2.new(0.7, 0, 1, 0)
pHealthFill.BackgroundColor3 = C.success
pHealthFill.BorderSizePixel = 0
Instance.new("UICorner", pHealthFill).CornerRadius = UDim.new(1, 0)

local pTracer = Instance.new("Frame", espPreview)
pTracer.Size = UDim2.new(0, 1, 0, 15)
pTracer.Position = UDim2.new(0.5, 0, 1, -20)
pTracer.BackgroundColor3 = C.danger
pTracer.BorderSizePixel = 0
pTracer.Visible = false

local function updatePreview()
	pName.Visible = Settings.showName
	pTeam.Visible = Settings.showTeam
	pDist.Visible = Settings.showDistance
	pHealthBg.Visible = Settings.showHealth
	pOutline.Visible = Settings.showBox
	pTracer.Visible = Settings.showTracer
end

local function updateESP(plr)
	if plr == player then return end
	local c = plr.Character
	if not c then return end
	local head = c:FindFirstChild("Head")
	local hum = c:FindFirstChild("Humanoid")
	if not head then return end

	local currentTeam = getCurrentTeam(plr)
	local tc = TEAM_COLORS[currentTeam] or C.textDim
	local show = Settings.espEnabled and Settings.espTeams[currentTeam]

	local old = head:FindFirstChild("PhantomESP")
	local oldH = c:FindFirstChild("PhantomHL")
	if old then old:Destroy() end
	if oldH then oldH:Destroy() end
	if not show then return end

	local bb = Instance.new("BillboardGui", head)
	bb.Name = "PhantomESP"
	bb.Size = UDim2.new(0, 80, 0, 50)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = true

	local y = 0
	if Settings.showName then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 10)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = plr.Name
		l.TextColor3 = C.text
		l.TextSize = 9
		l.Font = Enum.Font.GothamBold
		l.TextStrokeTransparency = 0
		y = y + 10
	end
	if Settings.showTeam then
		local l = Instance.new("TextLabel", bb)
		l.Size = UDim2.new(1, 0, 0, 9)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = currentTeam
		l.TextColor3 = tc
		l.TextSize = 8
		l.Font = Enum.Font.GothamSemibold
		l.TextStrokeTransparency = 0
		y = y + 9
	end
	if Settings.showDistance then
		local l = Instance.new("TextLabel", bb)
		l.Name = "Dist"
		l.Size = UDim2.new(1, 0, 0, 9)
		l.Position = UDim2.new(0, 0, 0, y)
		l.BackgroundTransparency = 1
		l.Text = "[0m]"
		l.TextColor3 = C.textDim
		l.TextSize = 8
		l.Font = Enum.Font.Gotham
		l.TextStrokeTransparency = 0
		y = y + 9
	end
	if Settings.showTool then
		local tool = c:FindFirstChildOfClass("Tool")
		if tool then
			local l = Instance.new("TextLabel", bb)
			l.Name = "Tool"
			l.Size = UDim2.new(1, 0, 0, 8)
			l.Position = UDim2.new(0, 0, 0, y)
			l.BackgroundTransparency = 1
			l.Text = "[" .. tool.Name .. "]"
			l.TextColor3 = C.warning
			l.TextSize = 7
			l.Font = Enum.Font.Gotham
			l.TextStrokeTransparency = 0
			y = y + 8
		end
	end
	if Settings.showHealth and hum then
		local bg = Instance.new("Frame", bb)
		bg.Size = UDim2.new(0.5, 0, 0, 3)
		bg.Position = UDim2.new(0.25, 0, 0, y + 2)
		bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		bg.BorderSizePixel = 0
		Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
		local fill = Instance.new("Frame", bg)
		fill.Name = "HP"
		fill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
		fill.BackgroundColor3 = C.success
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	end
	if Settings.showBox then
		local hl = Instance.new("Highlight", c)
		hl.Name = "PhantomHL"
		hl.FillTransparency = 1
		hl.OutlineColor = tc
		hl.OutlineTransparency = 0.3
	end
end

local function refreshESP()
	for _, p in pairs(Players:GetPlayers()) do updateESP(p) end
	updatePreview()
end

local function clearESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local h = p.Character:FindFirstChild("Head")
			if h then local e = h:FindFirstChild("PhantomESP") if e then e:Destroy() end end
			local hl = p.Character:FindFirstChild("PhantomHL") if hl then hl:Destroy() end
		end
	end
end

local espLoop = nil
local function startESPLoop()
	if espLoop then return end
	espLoop = task.spawn(function()
		while Settings.espEnabled and gui.Parent do
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player then
					updateESP(p)
					if p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
						local esp = p.Character.Head:FindFirstChild("PhantomESP")
						if esp then
							local dl = esp:FindFirstChild("Dist")
							if dl and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
								local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
								dl.Text = "[" .. math.floor(dist) .. "m]"
							end
						end
					end
				end
			end
			task.wait(0.1)
		end
		espLoop = nil
	end)
end

createSection(espFrame, "Main Settings")
local espToggle = createToggle(espFrame, "Enable ESP", Settings.espEnabled, function(on)
	Settings.espEnabled = on
	if on then
		autoSetEspTeams()
		refreshESP()
		startESPLoop()
	else
		clearESP()
	end
	saveSettings()
end, "espEnabled")

createToggle(espFrame, "Auto Team ESP", Settings.autoTeamEsp, function(on)
	Settings.autoTeamEsp = on
	if on and Settings.espEnabled then autoSetEspTeams() refreshESP() end
	saveSettings()
end)

createSection(espFrame, "Display Options")
createToggle(espFrame, "Name ESP", Settings.showName, function(on) Settings.showName = on refreshESP() saveSettings() end)
createToggle(espFrame, "Team ESP", Settings.showTeam, function(on) Settings.showTeam = on refreshESP() saveSettings() end)
createToggle(espFrame, "Distance ESP", Settings.showDistance, function(on) Settings.showDistance = on refreshESP() saveSettings() end)
createToggle(espFrame, "Health ESP", Settings.showHealth, function(on) Settings.showHealth = on refreshESP() saveSettings() end)
createToggle(espFrame, "Box ESP", Settings.showBox, function(on) Settings.showBox = on refreshESP() saveSettings() end)
createToggle(espFrame, "Tracer ESP", Settings.showTracer, function(on) Settings.showTracer = on refreshESP() saveSettings() end)
createToggle(espFrame, "Tool ESP", Settings.showTool, function(on) Settings.showTool = on refreshESP() saveSettings() end)

createSection(espFrame, "Target Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(espFrame, tn, Settings.espTeams[tn], function(on) Settings.espTeams[tn] = on refreshESP() saveSettings() end)
end

for _, p in pairs(Players:GetPlayers()) do
	if p ~= player then
		table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.3) if Settings.espEnabled then updateESP(p) end end))
	end
end
table.insert(connections, Players.PlayerAdded:Connect(function(p)
	table.insert(connections, p.CharacterAdded:Connect(function() task.wait(0.3) if Settings.espEnabled then updateESP(p) end end))
	refreshPlayers()
end))
table.insert(connections, Players.PlayerRemoving:Connect(refreshPlayers))

table.insert(connections, player:GetPropertyChangedSignal("Team"):Connect(function()
	if Settings.autoTeamEsp and Settings.espEnabled then
		autoSetEspTeams()
		refreshESP()
	end
end))

updatePreview()

local aimFrame = createTab("Combat")

local aimKey = Enum.KeyCode[Settings.aimHoldKey] or Enum.KeyCode.Q
local holding = false
local sticky = nil

local function getTarget()
	if Settings.stickyAim and sticky then
		local c = sticky.Character
		if c then
			local h = c:FindFirstChild("Humanoid")
			local p = c:FindFirstChild(Settings.aimPart) or c:FindFirstChild("Head")
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if h and h.Health > 0 and p and hrp then
				local currentTeam = getCurrentTeam(sticky)
				if Settings.aimTeams[currentTeam] then
					if Settings.wallCheck then
						local mc = player.Character
						if mc then
							local mh = mc:FindFirstChild("Head")
							if mh then
								local params = RaycastParams.new()
								params.FilterType = Enum.RaycastFilterType.Exclude
								params.FilterDescendantsInstances = {mc}
								local result = workspace:Raycast(mh.Position, (p.Position - mh.Position), params)
								if result then
									local tc = p:FindFirstAncestorOfClass("Model")
									if tc and result.Instance:IsDescendantOf(tc) then return p end
								else
									return p
								end
							end
						end
					else
						return p
					end
				end
			end
		end
		sticky = nil
	end

	local cam = workspace.CurrentCamera
	local mc = player.Character
	if not cam or not mc or not mc:FindFirstChild("HumanoidRootPart") then return nil end
	local mp = mc.HumanoidRootPart.Position
	local mHead = mc:FindFirstChild("Head")
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local closest, closestP, closestD = nil, nil, math.huge

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local currentTeam = getCurrentTeam(p)
			if Settings.aimTeams[currentTeam] then
				local c = p.Character
				local hrp = c:FindFirstChild("HumanoidRootPart")
				local h = c:FindFirstChild("Humanoid")
				if hrp and h and h.Health > 0 then
					local part = c:FindFirstChild(Settings.aimPart) or c:FindFirstChild("Head")
					if part then
						local dist = (hrp.Position - mp).Magnitude
						if dist <= 500 then
							local canSee = true
							if Settings.wallCheck and mHead then
								local params = RaycastParams.new()
								params.FilterType = Enum.RaycastFilterType.Exclude
								params.FilterDescendantsInstances = {mc}
								local result = workspace:Raycast(mHead.Position, (part.Position - mHead.Position), params)
								if result then
									local tc = part:FindFirstAncestorOfClass("Model")
									if not (tc and result.Instance:IsDescendantOf(tc)) then canSee = false end
								end
							end
							if canSee then
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
		end
	end
	if Settings.stickyAim and closestP then sticky = closestP end
	return closest
end

table.insert(connections, RunService.RenderStepped:Connect(function()
	if not Settings.aimEnabled or not holding then
		if not holding then sticky = nil end
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end
	if Settings.hitChance < 100 then
		if math.random(1, 100) > Settings.hitChance then return end
	end
	local t = getTarget()
	if t then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, t.Position), Settings.aimSmoothness) end
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == aimKey then holding = true end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode == aimKey then holding = false end
end))

createSection(aimFrame, "Aimbot")
createToggle(aimFrame, "Aimbot", Settings.aimEnabled, function(on) Settings.aimEnabled = on updateFOV() saveSettings() end, "aimEnabled")
createToggle(aimFrame, "Show FOV", Settings.showFOV, function(on) Settings.showFOV = on updateFOV() saveSettings() end, "showFOV")
createToggle(aimFrame, "Wall Check", Settings.wallCheck, function(on) Settings.wallCheck = on saveSettings() end)
createToggle(aimFrame, "Sticky Aim", Settings.stickyAim, function(on) Settings.stickyAim = on sticky = nil saveSettings() end)
createToggle(aimFrame, "Triggerbot", Settings.triggerbot, function(on) Settings.triggerbot = on saveSettings() end)

createSection(aimFrame, "Aim Settings")
createSlider(aimFrame, "Smoothness", 5, 100, Settings.aimSmoothness * 100, function(v) Settings.aimSmoothness = v / 100 end)
createSlider(aimFrame, "FOV Size", 30, 300, Settings.fovSize, function(v) Settings.fovSize = v updateFOV() end)
createSlider(aimFrame, "Hit Chance", 1, 100, Settings.hitChance, function(v) Settings.hitChance = v end)

createSection(aimFrame, "Keybind")
createKeybind(aimFrame, "Aimbot Key", Settings.aimHoldKey, function(key)
	aimKey = Enum.KeyCode[key]
	Settings.aimHoldKey = key
	saveSettings()
end)

createSection(aimFrame, "Target Teams")
for _, tn in ipairs(TARGET_TEAMS) do
	createToggle(aimFrame, tn, Settings.aimTeams[tn], function(on) Settings.aimTeams[tn] = on saveSettings() end)
end

table.insert(connections, RunService.Heartbeat:Connect(function()
	if not Settings.triggerbot then return end
	local cam = workspace.CurrentCamera
	local mc = player.Character
	if not cam or not mc then return end
	local ray = cam:ViewportPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {mc}
	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
	if result then
		local char = result.Instance:FindFirstAncestorOfClass("Model")
		if char then
			local plr = Players:GetPlayerFromCharacter(char)
			if plr and plr ~= player then
				local tn = getCurrentTeam(plr)
				if Settings.aimTeams[tn] then
					local tool = mc:FindFirstChildOfClass("Tool")
					if tool then
						local click = tool:FindFirstChild("Click") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Activate")
						if click then pcall(function() click:FireServer() end) end
					end
				end
			end
		end
	end
end))

local gunFrame = createTab("Guns")
createSection(gunFrame, "Gun Mods")
createToggle(gunFrame, "No Recoil", Settings.noRecoil, function(on)
	Settings.noRecoil = on
	setNoRecoil(on)
	saveSettings()
end)
createToggle(gunFrame, "No Spread", Settings.noSpread, function(on) Settings.noSpread = on saveSettings() end)

local visualFrame = createTab("Visuals")
createSection(visualFrame, "World Effects")
createToggle(visualFrame, "Full Bright", Settings.fullBright, function(on)
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
createToggle(visualFrame, "No Fog", Settings.noFog, function(on)
	Settings.noFog = on
	Lighting.FogEnd = on and 100000 or 1000
	saveSettings()
end)

createSection(visualFrame, "Atmosphere")
createSlider(visualFrame, "Fog Density", 0, 100, Settings.fogDensity, function(v)
	Settings.fogDensity = v
	local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmo then atmo.Density = v / 100 end
end)
createSlider(visualFrame, "Contrast", -100, 100, Settings.contrast, function(v)
	Settings.contrast = v
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if cc then cc.Contrast = v / 100 end
end)
createSlider(visualFrame, "Saturation", -100, 100, Settings.saturation, function(v)
	Settings.saturation = v
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if cc then cc.Saturation = v / 100 end
end)

createSection(visualFrame, "Camera")
createSlider(visualFrame, "Field of View", 30, 120, Settings.fov, function(v)
	Settings.fov = v
	workspace.CurrentCamera.FieldOfView = v
end)
createToggle(visualFrame, "Infinite Zoom", Settings.infZoom, function(on)
	Settings.infZoom = on
	player.CameraMaxZoomDistance = on and 9999 or 128
	saveSettings()
end)

createSection(visualFrame, "Crosshair")
createToggle(visualFrame, "Enable Crosshair", Settings.crosshairEnabled, function(on)
	Settings.crosshairEnabled = on
	local old = gui:FindFirstChild("Crosshair")
	if old then old:Destroy() end
	if not on then saveSettings() return end
	local cg = Instance.new("ScreenGui", gui)
	cg.Name = "Crosshair"
	local col = Color3.fromRGB(Settings.crosshairColor[1], Settings.crosshairColor[2], Settings.crosshairColor[3])
	for _, d in ipairs({
		{UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, -16)},
		{UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, 6)},
		{UDim2.new(0, 10, 0, 2), UDim2.new(0.5, -16, 0.5, -1)},
		{UDim2.new(0, 10, 0, 2), UDim2.new(0.5, 6, 0.5, -1)}
	}) do
		local l = Instance.new("Frame", cg)
		l.Size = d[1]
		l.Position = d[2]
		l.BackgroundColor3 = col
		l.BorderSizePixel = 0
	end
	saveSettings()
end)

local configFrame = createTab("Config")
createSection(configFrame, "Log Windows")
createToggle(configFrame, "Chat Logs", Settings.chatLogs, function(on)
	Settings.chatLogs = on
	chatLogWindow.Visible = on
	saveSettings()
end)
createToggle(configFrame, "Join/Leave Logs", Settings.joinLogs, function(on)
	Settings.joinLogs = on
	joinLogWindow.Visible = on
	saveSettings()
end)

createSection(configFrame, "Keybinds")
createKeybind(configFrame, "Toggle GUI", Settings.toggleGuiKey, function(key)
	Settings.toggleGuiKey = key
	saveSettings()
end)
createKeybind(configFrame, "Toggle ESP", Settings.toggleEspKey, function(key)
	Settings.toggleEspKey = key
	saveSettings()
end)

createSection(configFrame, "Save / Load")
createButton(configFrame, "Save Config", saveSettings)
createButton(configFrame, "Reset Character", function()
	if player.Character then player.Character:BreakJoints() end
end)
createButton(configFrame, "Destroy GUI", destroyGui)

local credFrame = createTab("Credits")

local credCard = Instance.new("Frame")
credCard.Size = UDim2.new(1, 0, 0, 140)
credCard.BackgroundColor3 = C.card
credCard.BorderSizePixel = 0
credCard.Parent = credFrame
Instance.new("UICorner", credCard).CornerRadius = UDim.new(0, 8)

local credLogo = Instance.new("Frame")
credLogo.Size = UDim2.new(0, 45, 0, 45)
credLogo.Position = UDim2.new(0.5, -22, 0, 12)
credLogo.BackgroundColor3 = C.accent
credLogo.BorderSizePixel = 0
credLogo.Parent = credCard
Instance.new("UICorner", credLogo).CornerRadius = UDim.new(0, 10)

local credLogoText = Instance.new("TextLabel", credLogo)
credLogoText.Size = UDim2.new(1, 0, 1, 0)
credLogoText.BackgroundTransparency = 1
credLogoText.Text = "P"
credLogoText.TextColor3 = C.text
credLogoText.TextSize = 22
credLogoText.Font = Enum.Font.GothamBlack

local credTitle = Instance.new("TextLabel", credCard)
credTitle.Size = UDim2.new(1, 0, 0, 18)
credTitle.Position = UDim2.new(0, 0, 0, 62)
credTitle.BackgroundTransparency = 1
credTitle.Text = "PHANTOM"
credTitle.TextColor3 = C.text
credTitle.TextSize = 14
credTitle.Font = Enum.Font.GothamBlack

local credVer = Instance.new("TextLabel", credCard)
credVer.Size = UDim2.new(1, 0, 0, 12)
credVer.Position = UDim2.new(0, 0, 0, 78)
credVer.BackgroundTransparency = 1
credVer.Text = "v7.2 Premium"
credVer.TextColor3 = C.textDim
credVer.TextSize = 9
credVer.Font = Enum.Font.GothamSemibold

local credDiv = Instance.new("Frame", credCard)
credDiv.Size = UDim2.new(0.4, 0, 0, 1)
credDiv.Position = UDim2.new(0.3, 0, 0, 98)
credDiv.BackgroundColor3 = C.accent
credDiv.BackgroundTransparency = 0.5
credDiv.BorderSizePixel = 0

local credRole = Instance.new("TextLabel", credCard)
credRole.Size = UDim2.new(1, 0, 0, 10)
credRole.Position = UDim2.new(0, 0, 0, 105)
credRole.BackgroundTransparency = 1
credRole.Text = "Developer"
credRole.TextColor3 = C.textDim
credRole.TextSize = 8
credRole.Font = Enum.Font.Gotham

local credName = Instance.new("TextLabel", credCard)
credName.Size = UDim2.new(1, 0, 0, 16)
credName.Position = UDim2.new(0, 0, 0, 118)
credName.BackgroundTransparency = 1
credName.Text = "Mishka"
credName.TextColor3 = C.accentLight
credName.TextSize = 12
credName.Font = Enum.Font.GothamBold

table.insert(connections, UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode.Name == Settings.toggleGuiKey then
		main.Visible = not main.Visible
	end
	if i.KeyCode.Name == Settings.toggleEspKey then
		Settings.espEnabled = not Settings.espEnabled
		if toggleRefs["espEnabled"] then toggleRefs["espEnabled"].setOn(Settings.espEnabled, true) end
		if Settings.espEnabled then
			autoSetEspTeams()
			refreshESP()
			startESPLoop()
		else
			clearESP()
		end
		saveSettings()
	end
end))

tabs["Teleport"].btn.MouseButton1Click:Fire()

task.defer(function()
	if Settings.espEnabled then
		autoSetEspTeams()
		startESPLoop()
		refreshESP()
	end
	if Settings.showFOV and Settings.aimEnabled then
		updateFOV()
	end
	if Settings.crosshairEnabled then
		local old = gui:FindFirstChild("Crosshair")
		if old then old:Destroy() end
		local cg = Instance.new("ScreenGui", gui)
		cg.Name = "Crosshair"
		local col = Color3.fromRGB(Settings.crosshairColor[1], Settings.crosshairColor[2], Settings.crosshairColor[3])
		for _, d in ipairs({
			{UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, -16)},
			{UDim2.new(0, 2, 0, 10), UDim2.new(0.5, -1, 0.5, 6)},
			{UDim2.new(0, 10, 0, 2), UDim2.new(0.5, -16, 0.5, -1)},
			{UDim2.new(0, 10, 0, 2), UDim2.new(0.5, 6, 0.5, -1)}
		}) do
			local l = Instance.new("Frame", cg)
			l.Size = d[1]
			l.Position = d[2]
			l.BackgroundColor3 = col
			l.BorderSizePixel = 0
		end
	end
	if Settings.fullBright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	end
	if Settings.infZoom then
		player.CameraMaxZoomDistance = 9999
	end
	if Settings.noRecoil then
		setNoRecoil(true)
	end
	workspace.CurrentCamera.FieldOfView = Settings.fov
	if Settings.chatLogs then
		chatLogWindow.Visible = true
	end
	if Settings.joinLogs then
		joinLogWindow.Visible = true
	end
end)

print("PHANTOM v7.2 by Mishka | GUI: " .. Settings.toggleGuiKey .. " | ESP: " .. Settings.toggleEspKey)
