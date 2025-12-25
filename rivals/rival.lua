-- PHANTOM RIVALS v1
-- Fixed Aimbot, Self Features, User Detection
-- by Mishka

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Destroy old GUI
if game.CoreGui:FindFirstChild("PhantomRivalsGUI") then
	game.CoreGui:FindFirstChild("PhantomRivalsGUI"):Destroy()
end

-- Script user identifier
local SCRIPT_TAG = "_PhantomUser"
local SCRIPT_ID = "PR_" .. player.UserId

-- Settings
local Settings = {
	toggleGuiKey = "RightShift",
	toggleEspKey = "F4",
	aimKey = "MouseButton2",
	flyKey = "G",
	noclipKey = "N",
	
	-- Aimbot
	aimEnabled = false,
	aimMode = "Hold",
	lockOn = true,
	aimSmoothing = 0.3,
	aimPart = "Head",
	fovSize = 120,
	showFOV = true,
	maxAimDistance = 60,
	wallCheck = true,
	stickyAim = true,
	prediction = false,
	
	-- Self
	flyEnabled = false,
	flySpeed = 50,
	noclipEnabled = false,
	infiniteJump = false,
	speedEnabled = false,
	speedValue = 22,
	
	-- ESP
	espEnabled = false,
	espMaxDistance = 250,
	espBoxes = true,
	espNames = true,
	espHealth = true,
	espDistance = true,
	espTracers = false,
	espColor = {255, 50, 150},
	
	fullBright = false,
	cameraFOV = 70,
}

-- Save/Load
local function saveSettings()
	if writefile then
		pcall(function()
			writefile("PhantomRivalsv1.json", HttpService:JSONEncode(Settings))
		end)
	end
end

local function loadSettings()
	if isfile and isfile("PhantomRivalsv1.json") then
		pcall(function()
			local data = HttpService:JSONDecode(readfile("PhantomRivalsv1.json"))
			for k, v in pairs(data) do
				if Settings[k] ~= nil then Settings[k] = v end
			end
		end)
	end
end

loadSettings()

-- Colors
local C = {
	bg = Color3.fromRGB(18, 18, 24),
	card = Color3.fromRGB(25, 25, 35),
	cardHover = Color3.fromRGB(35, 35, 48),
	accent = Color3.fromRGB(155, 89, 182),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(130, 130, 145),
	success = Color3.fromRGB(46, 204, 113),
	danger = Color3.fromRGB(231, 76, 60),
	warning = Color3.fromRGB(241, 196, 15),
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PhantomRivalsGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

-- Variables
local connections = {}
local espObjects = {}
local toggles = {}
local currentTarget = nil
local fovCircle = nil
local aimToggled, aimHeld = false, false
local flying = false
local flyBody, flyGyro = nil, nil
local noclipParts = {}

-- ============== UTILITIES ==============

local function getScreenCenter()
	return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function isAlive(plr)
	if not plr or not plr.Character then return false end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function getAimPart(char)
	if not char then return nil end
	if Settings.aimPart == "Head" then
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function isVisible(origin, part, char)
	if not Settings.wallCheck or not part then return true end
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {player.Character, Camera}
	
	local result = workspace:Raycast(origin, (part.Position - origin).Unit * (part.Position - origin).Magnitude, params)
	return not result or result.Instance:IsDescendantOf(char)
end

local function isAiming()
	return Settings.aimMode == "Toggle" and aimToggled or aimHeld
end

-- ============== SELF ==============

local function startFly()
	if flying or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	
	flying = true
	hum.PlatformStand = true
	
	flyBody = Instance.new("BodyVelocity")
	flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyBody.Velocity = Vector3.new()
	flyBody.Parent = hrp
	
	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyGyro.P = 9e4
	flyGyro.Parent = hrp
end

local function stopFly()
	flying = false
	if flyBody then flyBody:Destroy() flyBody = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	if player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
end

local function updateFly()
	if not flying or not flyBody then return end
	local dir = Vector3.new()
	
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
	
	flyBody.Velocity = flyBody.Velocity:Lerp(dir.Magnitude > 0 and dir.Unit * Settings.flySpeed or Vector3.new(), 0.25)
	if flyGyro then flyGyro.CFrame = Camera.CFrame end
end

local function enableNoclip()
	if not player.Character then return end
	noclipParts = {}
	for _, p in pairs(player.Character:GetDescendants()) do
		if p:IsA("BasePart") then noclipParts[p] = p.CanCollide end
	end
end

local function disableNoclip()
	for p, v in pairs(noclipParts) do
		if p and p.Parent then p.CanCollide = v end
	end
	noclipParts = {}
end

local function updateNoclip()
	if not Settings.noclipEnabled then return end
	for p in pairs(noclipParts) do
		if p and p.Parent then p.CanCollide = false end
	end
end

local function updateSpeed()
	if not player.Character then return end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = Settings.speedEnabled and Settings.speedValue or 16 end
end

-- Script user marking
local function markSelf()
	pcall(function()
		if player.Character then
			player.Character:SetAttribute(SCRIPT_TAG, SCRIPT_ID)
		end
	end)
end

player.CharacterAdded:Connect(function()
	task.wait(1)
	markSelf()
	if Settings.noclipEnabled then enableNoclip() end
	if Settings.speedEnabled then task.wait(0.5) updateSpeed() end
end)
if player.Character then markSelf() end

-- ============== AIMBOT ==============

local function getClosestPlayer()
	local closest, best = nil, math.huge
	local center = getScreenCenter()
	local camPos = Camera.CFrame.Position
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and isAlive(plr) then
			local part = getAimPart(plr.Character)
			if part then
				local dist = (camPos - part.Position).Magnitude
				if dist <= Settings.maxAimDistance then
					local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local fovDist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
						if fovDist < Settings.fovSize and isVisible(camPos, part, plr.Character) then
							if fovDist < best then
								best = fovDist
								closest = plr
							end
						end
					end
				end
			end
		end
	end
	return closest
end

local function aimAt(target)
	if not target or not isAlive(target) then return end
	
	local part = getAimPart(target.Character)
	if not part then return end
	
	local camPos = Camera.CFrame.Position
	if (camPos - part.Position).Magnitude > Settings.maxAimDistance then return end
	if Settings.wallCheck and not isVisible(camPos, part, target.Character) then return end
	
	local targetPos = part.Position
	
	-- Prediction
	if Settings.prediction then
		local root = target.Character:FindFirstChild("HumanoidRootPart")
		if root and root.AssemblyLinearVelocity.Magnitude > 1 then
			targetPos = targetPos + root.AssemblyLinearVelocity * 0.08
		end
	end
	
	local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
	if not onScreen then return end
	
	local center = getScreenCenter()
	local deltaX = screenPos.X - center.X
	local deltaY = screenPos.Y - center.Y
	local dist = math.sqrt(deltaX^2 + deltaY^2)
	
	-- Dead zone
	if dist < 2 then return end
	
	local moveX, moveY
	if Settings.lockOn then
		-- Cap max movement to prevent flicking
		local cap = math.min(1, 100 / dist)
		moveX, moveY = deltaX * cap, deltaY * cap
	else
		local speed = 0.15 + (1 - Settings.aimSmoothing) * 0.3
		moveX, moveY = deltaX * speed, deltaY * speed
	end
	
	if mousemoverel then mousemoverel(moveX, moveY) end
end

-- FOV
local function createFOV()
	if fovCircle then pcall(function() fovCircle:Remove() end) end
	if not Drawing then return end
	fovCircle = Drawing.new("Circle")
	fovCircle.Radius = Settings.fovSize
	fovCircle.Color = C.accent
	fovCircle.Thickness = 1.5
	fovCircle.Filled = false
	fovCircle.Visible = false
end
createFOV()

-- ============== ESP ==============

local function clearESP()
	for _, esp in pairs(espObjects) do
		for _, o in pairs(esp) do pcall(function() o:Remove() end) end
	end
	espObjects = {}
end

local function createESP(plr)
	if not Drawing or plr == player then return end
	
	local esp = {
		box = Drawing.new("Square"),
		outline = Drawing.new("Square"),
		name = Drawing.new("Text"),
		hpBg = Drawing.new("Line"),
		hp = Drawing.new("Line"),
		dist = Drawing.new("Text"),
		tracer = Drawing.new("Line"),
		tag = Drawing.new("Text"),
	}
	
	esp.outline.Color = Color3.new(0, 0, 0)
	esp.outline.Thickness = 3
	esp.outline.Filled = false
	
	esp.box.Thickness = 1
	esp.box.Filled = false
	
	esp.name.Size = 13
	esp.name.Center = true
	esp.name.Outline = true
	
	esp.hpBg.Color = Color3.new(0, 0, 0)
	esp.hpBg.Thickness = 4
	
	esp.hp.Thickness = 2
	
	esp.dist.Size = 11
	esp.dist.Center = true
	esp.dist.Outline = true
	esp.dist.Color = C.textDim
	
	esp.tracer.Thickness = 1
	
	esp.tag.Size = 11
	esp.tag.Center = true
	esp.tag.Outline = true
	esp.tag.Color = C.warning
	esp.tag.Text = "[PHANTOM]"
	
	for _, o in pairs(esp) do o.Visible = false end
	espObjects[plr] = esp
end

local function refreshESP()
	clearESP()
	if Settings.espEnabled then
		for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
	end
end

local function updateESP()
	local camPos = Camera.CFrame.Position
	local viewSize = Camera.ViewportSize
	
	for plr, esp in pairs(espObjects) do
		local show = false
		
		if plr and plr.Parent and isAlive(plr) then
			local char = plr.Character
			local hum = char:FindFirstChildOfClass("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")
			
			if hum and root then
				local dist = (camPos - root.Position).Magnitude
				if dist <= Settings.espMaxDistance then
					local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
					if onScreen then
						show = true
						
						local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
						local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
						local h = math.abs(top.Y - bot.Y)
						local w = h * 0.5
						local x, y = pos.X - w/2, pos.Y - h/2
						
						local isUser = char:GetAttribute(SCRIPT_TAG) ~= nil
						local color = isUser and C.warning or Color3.fromRGB(Settings.espColor[1], Settings.espColor[2], Settings.espColor[3])
						
						if Settings.espBoxes then
							esp.outline.Size = Vector2.new(w, h)
							esp.outline.Position = Vector2.new(x, y)
							esp.outline.Visible = true
							esp.box.Size = Vector2.new(w, h)
							esp.box.Position = Vector2.new(x, y)
							esp.box.Color = color
							esp.box.Visible = true
						else
							esp.box.Visible = false
							esp.outline.Visible = false
						end
						
						if Settings.espNames then
							esp.name.Text = plr.Name
							esp.name.Position = Vector2.new(pos.X, y - 15)
							esp.name.Color = color
							esp.name.Visible = true
						else
							esp.name.Visible = false
						end
						
						esp.tag.Position = Vector2.new(pos.X, y - 28)
						esp.tag.Visible = isUser
						
						if Settings.espHealth then
							local pct = hum.Health / hum.MaxHealth
							esp.hpBg.From = Vector2.new(x - 5, y + h)
							esp.hpBg.To = Vector2.new(x - 5, y)
							esp.hpBg.Visible = true
							esp.hp.From = Vector2.new(x - 5, y + h)
							esp.hp.To = Vector2.new(x - 5, y + h - h * pct)
							esp.hp.Color = Color3.fromRGB(255 * (1-pct), 255 * pct, 0)
							esp.hp.Visible = true
						else
							esp.hpBg.Visible = false
							esp.hp.Visible = false
						end
						
						if Settings.espDistance then
							esp.dist.Text = math.floor(dist) .. "m"
							esp.dist.Position = Vector2.new(pos.X, y + h + 2)
							esp.dist.Visible = true
						else
							esp.dist.Visible = false
						end
						
						if Settings.espTracers then
							esp.tracer.From = Vector2.new(viewSize.X/2, viewSize.Y)
							esp.tracer.To = Vector2.new(pos.X, pos.Y)
							esp.tracer.Color = color
							esp.tracer.Visible = true
						else
							esp.tracer.Visible = false
						end
					end
				end
			end
		end
		
		if not show then
			for _, o in pairs(esp) do o.Visible = false end
		end
	end
end

-- ============== GUI ==============

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 320)
main.Position = UDim2.new(0.5, -180, 0.5, -160)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = C.accent
stroke.Thickness = 2
stroke.Transparency = 0.5

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PHANTOM RIVALS v1"
title.TextColor3 = C.text
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 4)
closeBtn.BackgroundColor3 = C.danger
closeBtn.Text = "×"
closeBtn.TextColor3 = C.text
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Drag
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = main.Position end end)
header.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)

-- Tabs
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, -12, 0, 24)
tabBar.Position = UDim2.new(0, 6, 0, 34)
tabBar.BackgroundColor3 = C.card
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 4)
Instance.new("UIListLayout", tabBar).FillDirection = Enum.FillDirection.Horizontal

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -12, 1, -66)
content.Position = UDim2.new(0, 6, 0, 62)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

local tabs = {}
local tabNames = {"Aimbot", "Self", "ESP", "Users"}

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", tabBar)
	btn.Size = UDim2.new(1/#tabNames, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = i == 1 and C.accent or C.textDim
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamSemibold
	
	local page = Instance.new("ScrollingFrame", content)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = C.accent
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = i == 1
	Instance.new("UIListLayout", page).Padding = UDim.new(0, 3)
	
	tabs[name] = {btn = btn, page = page}
	
	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(tabs) do t.page.Visible = false; t.btn.TextColor3 = C.textDim end
		page.Visible = true
		btn.TextColor3 = C.accent
	end)
end

-- UI Components
local function section(p, t) local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -6, 0, 16); f.BackgroundTransparency = 1; local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = C.accent; l.TextSize = 9; l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left end

local function toggle(p, t, k, cb)
	local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -6, 0, 22); f.BackgroundColor3 = C.card; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
	local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -40, 1, 0); l.Position = UDim2.new(0, 6, 0, 0); l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = C.text; l.TextSize = 10; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
	local s = Instance.new("Frame", f); s.Size = UDim2.new(0, 26, 0, 12); s.Position = UDim2.new(1, -32, 0.5, -6); s.BackgroundColor3 = C.cardHover; Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
	local kn = Instance.new("Frame", s); kn.Size = UDim2.new(0, 8, 0, 8); kn.Position = UDim2.new(0, 2, 0.5, -4); kn.BackgroundColor3 = C.textDim; Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
	
	local on = Settings[k]
	local function upd(v, skip) on = v; if on then TweenService:Create(s, TweenInfo.new(0.1), {BackgroundColor3 = C.accent}):Play(); TweenService:Create(kn, TweenInfo.new(0.1), {Position = UDim2.new(1, -10, 0.5, -4), BackgroundColor3 = C.text}):Play() else TweenService:Create(s, TweenInfo.new(0.1), {BackgroundColor3 = C.cardHover}):Play(); TweenService:Create(kn, TweenInfo.new(0.1), {Position = UDim2.new(0, 2, 0.5, -4), BackgroundColor3 = C.textDim}):Play() end; if not skip then Settings[k] = on; saveSettings() end end
	upd(on, true)
	
	local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""
	b.MouseButton1Click:Connect(function() on = not on; upd(on); if cb then cb(on) end end)
	toggles[k] = {set = upd}
end

local function slider(p, t, k, mn, mx, cb)
	local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -6, 0, 30); f.BackgroundColor3 = C.card; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
	local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 0, 12); l.Position = UDim2.new(0, 6, 0, 2); l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = C.text; l.TextSize = 9; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
	local v = Instance.new("TextLabel", f); v.Size = UDim2.new(0.35, 0, 0, 12); v.Position = UDim2.new(0.65, -6, 0, 2); v.BackgroundTransparency = 1; v.Text = tostring(Settings[k]); v.TextColor3 = C.accent; v.TextSize = 9; v.Font = Enum.Font.GothamBold; v.TextXAlignment = Enum.TextXAlignment.Right
	local tr = Instance.new("Frame", f); tr.Size = UDim2.new(1, -12, 0, 4); tr.Position = UDim2.new(0, 6, 0, 18); tr.BackgroundColor3 = C.cardHover; Instance.new("UICorner", tr).CornerRadius = UDim.new(1, 0)
	local fl = Instance.new("Frame", tr); fl.Size = UDim2.new((Settings[k] - mn) / (mx - mn), 0, 1, 0); fl.BackgroundColor3 = C.accent; Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
	
	local sliding = false
	tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end end)
	table.insert(connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end))
	table.insert(connections, UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then local pct = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1); local val = mn + (mx - mn) * pct; val = mx <= 1 and math.floor(val * 100) / 100 or math.floor(val); Settings[k] = val; v.Text = tostring(val); fl.Size = UDim2.new(pct, 0, 1, 0); saveSettings(); if cb then cb(val) end end end))
end

local function dropdown(p, t, k, opts)
	local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -6, 0, 22); f.BackgroundColor3 = C.card; f.ClipsDescendants = true; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
	local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 0, 22); l.Position = UDim2.new(0, 6, 0, 0); l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = C.text; l.TextSize = 10; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
	local sel = Instance.new("TextButton", f); sel.Size = UDim2.new(0.45, -8, 0, 16); sel.Position = UDim2.new(0.55, 0, 0, 3); sel.BackgroundColor3 = C.cardHover; sel.Text = Settings[k] .. " ▼"; sel.TextColor3 = C.textDim; sel.TextSize = 9; sel.Font = Enum.Font.Gotham; Instance.new("UICorner", sel).CornerRadius = UDim.new(0, 3)
	local of = Instance.new("Frame", f); of.Size = UDim2.new(0.45, -8, 0, #opts * 16); of.Position = UDim2.new(0.55, 0, 0, 20); of.BackgroundColor3 = C.cardHover; of.Visible = false; of.ZIndex = 5; Instance.new("UICorner", of).CornerRadius = UDim.new(0, 3); Instance.new("UIListLayout", of)
	local open = false
	for _, o in ipairs(opts) do local ob = Instance.new("TextButton", of); ob.Size = UDim2.new(1, 0, 0, 16); ob.BackgroundTransparency = 1; ob.Text = o; ob.TextColor3 = C.textDim; ob.TextSize = 9; ob.Font = Enum.Font.Gotham; ob.ZIndex = 5; ob.MouseEnter:Connect(function() ob.TextColor3 = C.accent end); ob.MouseLeave:Connect(function() ob.TextColor3 = C.textDim end); ob.MouseButton1Click:Connect(function() Settings[k] = o; sel.Text = o .. " ▼"; open = false; of.Visible = false; f.Size = UDim2.new(1, -6, 0, 22); saveSettings() end) end
	sel.MouseButton1Click:Connect(function() open = not open; of.Visible = open; f.Size = open and UDim2.new(1, -6, 0, 24 + #opts * 16) or UDim2.new(1, -6, 0, 22) end)
end

local function keybind(p, t, k)
	local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -6, 0, 22); f.BackgroundColor3 = C.card; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
	local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Position = UDim2.new(0, 6, 0, 0); l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = C.text; l.TextSize = 10; l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
	local b = Instance.new("TextButton", f); b.Size = UDim2.new(0.35, -8, 0, 16); b.Position = UDim2.new(0.65, 0, 0, 3); b.BackgroundColor3 = C.cardHover; b.Text = Settings[k]; b.TextColor3 = C.textDim; b.TextSize = 9; b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
	local listening = false
	b.MouseButton1Click:Connect(function() listening = true; b.Text = "..."; b.TextColor3 = C.accent end)
	table.insert(connections, UserInputService.InputBegan:Connect(function(i) if listening then local kn; if i.UserInputType == Enum.UserInputType.MouseButton1 then kn = "MouseButton1" elseif i.UserInputType == Enum.UserInputType.MouseButton2 then kn = "MouseButton2" elseif i.KeyCode ~= Enum.KeyCode.Unknown then kn = i.KeyCode.Name end; if kn then Settings[k] = kn; b.Text = kn; b.TextColor3 = C.textDim; listening = false; saveSettings() end end end))
end

-- AIMBOT TAB
local ap = tabs["Aimbot"].page
section(ap, "AIMBOT")
toggle(ap, "Enable", "aimEnabled", function(on) if fovCircle then fovCircle.Visible = on and Settings.showFOV end; if not on then currentTarget = nil; aimToggled = false end end)
dropdown(ap, "Mode", "aimMode", {"Hold", "Toggle"})
keybind(ap, "Aim Key", "aimKey")
dropdown(ap, "Target", "aimPart", {"Head", "Body"})
section(ap, "SETTINGS")
toggle(ap, "Lock On", "lockOn")
slider(ap, "Smoothing", "aimSmoothing", 0, 1)
slider(ap, "Max Distance", "maxAimDistance", 10, 150)
toggle(ap, "Wall Check", "wallCheck")
toggle(ap, "Sticky Aim", "stickyAim")
toggle(ap, "Prediction", "prediction")
section(ap, "FOV")
toggle(ap, "Show FOV", "showFOV", function(on) if fovCircle then fovCircle.Visible = on and Settings.aimEnabled end end)
slider(ap, "FOV Size", "fovSize", 30, 300, function(v) if fovCircle then fovCircle.Radius = v end end)

-- SELF TAB
local sp = tabs["Self"].page
section(sp, "MOVEMENT")
toggle(sp, "Fly", "flyEnabled", function(on) if on then startFly() else stopFly() end end)
slider(sp, "Fly Speed", "flySpeed", 10, 150)
keybind(sp, "Fly Key", "flyKey")
toggle(sp, "Noclip", "noclipEnabled", function(on) if on then enableNoclip() else disableNoclip() end end)
keybind(sp, "Noclip Key", "noclipKey")
toggle(sp, "Infinite Jump", "infiniteJump")
section(sp, "SPEED")
toggle(sp, "Speed Hack", "speedEnabled", updateSpeed)
slider(sp, "Speed", "speedValue", 16, 100, function() if Settings.speedEnabled then updateSpeed() end end)

-- ESP TAB
local ep = tabs["ESP"].page
section(ep, "ESP")
toggle(ep, "Enable", "espEnabled", function(on) if on then refreshESP() else clearESP() end end)
slider(ep, "Max Distance", "espMaxDistance", 50, 500)
section(ep, "DISPLAY")
toggle(ep, "Boxes", "espBoxes")
toggle(ep, "Names", "espNames")
toggle(ep, "Health", "espHealth")
toggle(ep, "Distance", "espDistance")
toggle(ep, "Tracers", "espTracers")

-- USERS TAB
local up = tabs["Users"].page
section(up, "SCRIPT USERS")
local ul = Instance.new("Frame", up); ul.Size = UDim2.new(1, -6, 0, 100); ul.BackgroundColor3 = C.card; Instance.new("UICorner", ul).CornerRadius = UDim.new(0, 4)
local us = Instance.new("ScrollingFrame", ul); us.Size = UDim2.new(1, -6, 1, -6); us.Position = UDim2.new(0, 3, 0, 3); us.BackgroundTransparency = 1; us.ScrollBarThickness = 2; us.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UIListLayout", us).Padding = UDim.new(0, 2)
local noUsers = Instance.new("TextLabel", us); noUsers.Size = UDim2.new(1, 0, 0, 25); noUsers.BackgroundTransparency = 1; noUsers.Text = "No other users found"; noUsers.TextColor3 = C.textDim; noUsers.TextSize = 10; noUsers.Font = Enum.Font.Gotham

local function refreshUsers()
	for _, c in pairs(us:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	local found = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:GetAttribute(SCRIPT_TAG) then
			table.insert(found, plr)
		end
	end
	noUsers.Visible = #found == 0
	for _, plr in ipairs(found) do
		local e = Instance.new("Frame", us); e.Size = UDim2.new(1, 0, 0, 20); e.BackgroundColor3 = C.cardHover; Instance.new("UICorner", e).CornerRadius = UDim.new(0, 3)
		local n = Instance.new("TextLabel", e); n.Size = UDim2.new(1, -6, 1, 0); n.Position = UDim2.new(0, 6, 0, 0); n.BackgroundTransparency = 1; n.Text = "⚡ " .. plr.Name; n.TextColor3 = C.warning; n.TextSize = 10; n.Font = Enum.Font.GothamSemibold; n.TextXAlignment = Enum.TextXAlignment.Left
	end
end

local rb = Instance.new("TextButton", up); rb.Size = UDim2.new(1, -6, 0, 24); rb.BackgroundColor3 = C.accent; rb.Text = "🔄 Refresh"; rb.TextColor3 = C.text; rb.TextSize = 10; rb.Font = Enum.Font.GothamBold; Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 4)
rb.MouseButton1Click:Connect(refreshUsers)

local info = Instance.new("TextLabel", up); info.Size = UDim2.new(1, -6, 0, 35); info.BackgroundColor3 = C.card; info.Text = "Other Phantom users show\nwith yellow ESP + [PHANTOM] tag"; info.TextColor3 = C.textDim; info.TextSize = 9; info.Font = Enum.Font.Gotham; info.TextWrapped = true; Instance.new("UICorner", info).CornerRadius = UDim.new(0, 4)

-- ============== LOOPS ==============

local lastESP, lastRefresh = 0, 0

table.insert(connections, UserInputService.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	local k; if i.UserInputType == Enum.UserInputType.MouseButton2 then k = "MouseButton2" elseif i.UserInputType == Enum.UserInputType.MouseButton1 then k = "MouseButton1" elseif i.KeyCode ~= Enum.KeyCode.Unknown then k = i.KeyCode.Name end
	
	if k == Settings.aimKey then if Settings.aimMode == "Toggle" then aimToggled = not aimToggled; if aimToggled and Settings.stickyAim then currentTarget = getClosestPlayer() end; if not aimToggled then currentTarget = nil end else aimHeld = true; if Settings.stickyAim then currentTarget = getClosestPlayer() end end end
	if k == Settings.toggleGuiKey then main.Visible = not main.Visible end
	if k == Settings.toggleEspKey then Settings.espEnabled = not Settings.espEnabled; if toggles.espEnabled then toggles.espEnabled.set(Settings.espEnabled, true) end; if Settings.espEnabled then refreshESP() else clearESP() end; saveSettings() end
	if k == Settings.flyKey then Settings.flyEnabled = not Settings.flyEnabled; if toggles.flyEnabled then toggles.flyEnabled.set(Settings.flyEnabled, true) end; if Settings.flyEnabled then startFly() else stopFly() end; saveSettings() end
	if k == Settings.noclipKey then Settings.noclipEnabled = not Settings.noclipEnabled; if toggles.noclipEnabled then toggles.noclipEnabled.set(Settings.noclipEnabled, true) end; if Settings.noclipEnabled then enableNoclip() else disableNoclip() end; saveSettings() end
	if Settings.infiniteJump and i.KeyCode == Enum.KeyCode.Space then if player.Character then local h = player.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(i)
	local k; if i.UserInputType == Enum.UserInputType.MouseButton2 then k = "MouseButton2" elseif i.UserInputType == Enum.UserInputType.MouseButton1 then k = "MouseButton1" elseif i.KeyCode ~= Enum.KeyCode.Unknown then k = i.KeyCode.Name end
	if k == Settings.aimKey and Settings.aimMode == "Hold" then aimHeld = false; currentTarget = nil end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
	if fovCircle then fovCircle.Position = getScreenCenter(); fovCircle.Radius = Settings.fovSize; fovCircle.Visible = Settings.showFOV and Settings.aimEnabled end
	if Settings.flyEnabled then updateFly() end
	if Settings.aimEnabled and isAiming() then
		local target = currentTarget
		if Settings.stickyAim and currentTarget and isAlive(currentTarget) then
			local part = getAimPart(currentTarget.Character)
			if part and (Camera.CFrame.Position - part.Position).Magnitude <= Settings.maxAimDistance then
				local _, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen and (not Settings.wallCheck or isVisible(Camera.CFrame.Position, part, currentTarget.Character)) then target = currentTarget end
			end
			if target ~= currentTarget then currentTarget = getClosestPlayer(); target = currentTarget end
		else
			target = getClosestPlayer()
			if Settings.stickyAim then currentTarget = target end
		end
		if target then aimAt(target) end
	end
end))

table.insert(connections, RunService.Heartbeat:Connect(function()
	local now = tick()
	if Settings.espEnabled and now - lastESP >= 1/30 then lastESP = now; updateESP() end
	if Settings.espEnabled and now - lastRefresh >= 2 then lastRefresh = now; for _, plr in pairs(Players:GetPlayers()) do if plr ~= player and not espObjects[plr] then createESP(plr) end end end
	if Settings.noclipEnabled then updateNoclip() end
end))

table.insert(connections, Players.PlayerAdded:Connect(function(plr) if Settings.espEnabled then createESP(plr) end end))
table.insert(connections, Players.PlayerRemoving:Connect(function(plr) if espObjects[plr] then for _, o in pairs(espObjects[plr]) do pcall(function() o:Remove() end) end; espObjects[plr] = nil end end))

closeBtn.MouseButton1Click:Connect(function()
	for _, c in pairs(connections) do pcall(function() c:Disconnect() end) end
	clearESP(); stopFly(); disableNoclip()
	if fovCircle then pcall(function() fovCircle:Remove() end) end
	gui:Destroy()
end)

task.defer(function() if Settings.espEnabled then refreshESP() end; refreshUsers() end)
