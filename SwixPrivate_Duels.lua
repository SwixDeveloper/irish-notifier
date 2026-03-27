-- SWIX HUB PRIVATE v2 - Full Cursed Hub Style UI + Mobile Optimized
-- Features: Float fixed, reduced lagback, clean dark/red theme matching Cursed Hub

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function S(desktop, mobile)
    return isMobile and mobile or desktop
end

-- Core Settings
local NORMAL_SPEED = 60
local CARRY_SPEED = 30
local FLOAT_HEIGHT = 10

local speedToggled = false
local guiVisible = true
local mobBtnsVisible = true
local mobLocked = false

-- Keybinds (desktop focused)
local floatKey = Enum.KeyCode.F
local guiToggleKey = Enum.KeyCode.RightAlt
local speedToggleKey = Enum.KeyCode.Q
local autoLeftKey = Enum.KeyCode.Z
local autoRightKey = Enum.KeyCode.C
local returnLKey = Enum.KeyCode.N
local returnRKey = Enum.KeyCode.M
local dropKey = Enum.KeyCode.H
local tpDownKey = Enum.KeyCode.G

local Enabled = {
    FloatEnabled = false,
    AutoLeftEnabled = false,
    AutoRightEnabled = false,
    ReturnL = false,
    ReturnR = false,
    DropBots = false,
    TPDown = false,
    SpeedLabel = true,
    AutoSteal = false,
}

-- Float System (Fixed - works with normal jumping)
local floatConn = nil
local function startFloat()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetY = root.Position.Y + FLOAT_HEIGHT
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not Enabled.FloatEnabled then return end
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Jumping then
                targetY = r.Position.Y + FLOAT_HEIGHT
            end
            local diff = targetY - r.Position.Y
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, diff * 13, r.AssemblyLinearVelocity.Z)
        end
    end)
end

local function stopFloat()
    if floatConn then floatConn:Disconnect() end
    floatConn = nil
end

-- Smooth Movement (Reduced Lagback)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if Enabled.AutoLeftEnabled or Enabled.AutoRightEnabled then return end

    local speed = speedToggled and CARRY_SPEED or NORMAL_SPEED
    local md = hum.MoveDirection
    if md.Magnitude > 0.1 then
        root.AssemblyLinearVelocity = Vector3.new(md.X * speed, root.AssemblyLinearVelocity.Y, md.Z * speed)
    end
end)

-- ==================== FULL MOBILE-OPTIMIZED CURSED UI ====================
if CoreGui:FindFirstChild("SwixHub") then CoreGui.SwixHub:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SwixHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = CoreGui

local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, S(295, 225), 0, S(535, 390))
win.Position = isMobile and UDim2.new(0.5, -S(147, 112), 0, 25) or UDim2.new(1, -325, 0.5, -275)
win.BackgroundColor3 = Color3.fromRGB(9, 9, 14)
win.BorderSizePixel = 0
win.Active = true
win.Draggable = not isMobile
win.ClipsDescendants = true
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)

-- Header (Cursed Hub Style - Red/Black)
local header = Instance.new("Frame", win)
header.Size = UDim2.new(1, 0, 0, S(52, 44))
header.BackgroundColor3 = Color3.fromRGB(22, 0, 0)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -70, 1, 0)
title.BackgroundTransparency = 1
title.Text = "SWIX HUB"
title.TextColor3 = Color3.fromRGB(255, 65, 65)
title.Font = Enum.Font.GothamBlack
title.TextSize = S(26, 19)
title.TextXAlignment = Enum.TextXAlignment.Center

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -70, 0, 16)
subtitle.Position = UDim2.new(0, 0, 0.58, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PRIVATE"
subtitle.TextColor3 = Color3.fromRGB(200, 50, 50)
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = S(13, 10)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, S(34, 28), 0, S(34, 28))
closeBtn.Position = UDim2.new(1, -S(40, 34), 0.5, -S(17, 14))
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = S(20, 16)
closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    win.Visible = false
end)

-- Tabs (Main / Move / Config)
local tabBar = Instance.new("Frame", win)
tabBar.Size = UDim2.new(1, -24, 0, S(36, 30))
tabBar.Position = UDim2.new(0, 12, 0, S(58, 50))
tabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

local function createTab(name, posX, active)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.Position = UDim2.new(posX, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = active and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(170, 170, 185)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = S(15, 12)
    return btn
end

local tabMain = createTab("Main", 0, true)
local tabMove = createTab("Move", 0.333, false)
local tabConfig = createTab("Config", 0.666, false)

-- Scrolling Frame (optimized for mobile)
local scroll = Instance.new("ScrollingFrame", win)
scroll.Size = UDim2.new(1, -24, 1, isMobile and -195 or -170)
scroll.Position = UDim2.new(0, 12, 0, S(105, 92))
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = S(4, 5)
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 70)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, S(8, 6))
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function addCategory(text)
    local cat = Instance.new("TextLabel", scroll)
    cat.Size = UDim2.new(1, 0, 0, S(32, 26))
    cat.BackgroundTransparency = 1
    cat.Text = " " .. text:upper()
    cat.TextColor3 = Color3.fromRGB(255, 75, 75)
    cat.Font = Enum.Font.GothamBold
    cat.TextSize = S(14, 11)
    cat.TextXAlignment = Enum.TextXAlignment.Left
end

local function addToggle(text, key, default, callback)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1, 0, 0, S(52, 46))
    row.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = S(16, 13)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local tog = Instance.new("Frame", row)
    tog.Size = UDim2.new(0, S(56, 48), 0, S(30, 26))
    tog.Position = UDim2.new(1, -S(68, 58), 0.5, -S(15, 13))
    tog.BackgroundColor3 = default and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(48, 48, 58)
    Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", tog)
    thumb.Size = UDim2.new(0, S(26, 22), 0, S(26, 22))
    thumb.Position = UDim2.new(0, default and S(28, 24) or 2, 0.5, -S(13, 11))
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    Enabled[key] = default

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            Enabled[key] = not Enabled[key]
            local on = Enabled[key]
            tog.BackgroundColor3 = on and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(48, 48, 58)
            TweenService:Create(thumb, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, on and S(28,24) or 2, 0.5, -S(13,11))
            }):Play()
            if callback then callback(on) end
        end
    end)
end

-- Content (matching your image style)
addCategory("TELEPORT")
addToggle("TP Mode: Manual", "TPMode", false, nil)

addCategory("RETURN")
addToggle("Brainrot Return L  [N]", "ReturnL", false, function(v) if v then task.spawn(function() LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,0) end) end end)
addToggle("Brainrot Return R  [M]", "ReturnR", false, nil)
addToggle("Drop Brainrot  [H]", "DropBots", false, nil)
addToggle("TP Down  [G]", "TPDown", false, nil)

addCategory("AUTO")
addToggle("Auto Left  [Z]", "AutoLeftEnabled", false, function(v) Enabled.AutoLeftEnabled = v end)
addToggle("Auto Right  [C]", "AutoRightEnabled", false, function(v) Enabled.AutoRightEnabled = v end)
addToggle("Float  [F]", "FloatEnabled", false, function(v)
    Enabled.FloatEnabled = v
    if v then startFloat() else stopFloat() end
end)

-- Mobile Buttons (larger, optimized drag)
local mobButtons = {}

local function createMobButton(name, text, defaultPos, action)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, S(72, 66), 0, S(56, 52))
    btn.Position = defaultPos
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    btn.BorderSizePixel = 0
    btn.ZIndex = 30
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 80, 80)
    stroke.Thickness = 2

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 230, 230)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = S(14, 12)
    label.TextWrapped = true

    local dragging = false
    local startPos, startMouse

    btn.InputBegan:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1) and not mobLocked then
            dragging = true
            startPos = btn.Position
            startMouse = inp.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = inp.Position - startMouse
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            if action then action() end
        end
    end)

    mobButtons[name] = btn
    return btn
end

-- Mobile Buttons (placed on right side)
createMobButton("MobFloat", "FLOAT", UDim2.new(1, -85, 0.55, -80), function()
    Enabled.FloatEnabled = not Enabled.FloatEnabled
    if Enabled.FloatEnabled then startFloat() else stopFloat() end
end)

createMobButton("MobAutoL", "AUTO L", UDim2.new(1, -170, 0.55, 10), function()
    Enabled.AutoLeftEnabled = not Enabled.AutoLeftEnabled
end)

createMobButton("MobReturnL", "RET L", UDim2.new(1, -85, 0.7, 20), function()
    print("Return L triggered")
end)

createMobButton("MobDrop", "DROP", UDim2.new(1, -170, 0.75, -60), function()
    print("Drop Brainrot triggered")
end)

-- Show all mobile buttons by default on mobile
for _, btn in pairs(mobButtons) do
    btn.Visible = isMobile and mobBtnsVisible
end

print("✅ SWIX HUB PRIVATE - Full Mobile Optimized Cursed UI Loaded Successfully")

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == guiToggleKey then
        guiVisible = not guiVisible
        win.Visible = guiVisible
    elseif input.KeyCode == floatKey then
        Enabled.FloatEnabled = not Enabled.FloatEnabled
        if Enabled.FloatEnabled then startFloat() else stopFloat() end
    elseif input.KeyCode == speedToggleKey then
        speedToggled = not speedToggled
    end
end)

win.Visible = true
