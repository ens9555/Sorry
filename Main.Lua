--====================================================================--
--          MASENSDEV MOUNT SORRY V1.3 PREMIUM EDITION                --
--====================================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MainParent = PlayerGui
if gethui then
    MainParent = gethui()
end

--====================================================================--
--                          DATA CHECKPOINT                           --
--====================================================================--
local Checkpoints = {
    ["CP 0 (Basecamp)"] = Vector3.new(-1562.01, 1232.02, -5826.63),
    ["CP 1"] = Vector3.new(-1581.77, 1245.75, -5047.03),
    ["CP 2"] = Vector3.new(-1454.30, 1324.00, -4513.14),
    ["CP 3"] = Vector3.new(-1403.00, 1222.21, -3738.00),
    ["CP 4"] = Vector3.new(-1464.00, 1350.93, -3112.00),
    ["CP 5"] = Vector3.new(-1399.12, 1230.93, -2657.14),
    ["CP 6"] = Vector3.new(-1360.00, 1230.93, -2230.00),
    ["CP 7"] = Vector3.new(-1488.00, 1294.93, -2048.00),
    ["CP 8"] = Vector3.new(-1428.00, 1274.93, -1402.00),
    ["CP 9"] = Vector3.new(-1384.14, 1274.00, -985.84),
    ["CP 10"] = Vector3.new(-1486.00, 1274.94, -374.00),
    ["CP 11"] = Vector3.new(-1260.00, 1398.00, 252.00),
    ["CP 12"] = Vector3.new(-1387.94, 1557.33, 1171.00),
    ["CP 13"] = Vector3.new(-1138.00, 1831.00, 1638.00),
    ["CP 14"] = Vector3.new(-764.51, 1830.77, 1865.88),
    ["CP 15"] = Vector3.new(-313.40, 1702.86, 2313.35),
    ["CP 16"] = Vector3.new(-18.68, 2018.00, 1678.29),
    ["CP 17"] = Vector3.new(547.33, 2033.45, 1988.93),
    ["CP 18"] = Vector3.new(1204.50, 1778.00, 1815.00),
    ["CP 19"] = Vector3.new(1806.00, 2026.00, 1760.94),
    ["CP 20"] = Vector3.new(2613.90, 2089.70, 2101.90),
    ["CP 21"] = Vector3.new(2474.00, 2140.00, 2435.00),
    ["CP 22"] = Vector3.new(2814.02, 2170.11, 2804.10),
    ["CP 23"] = Vector3.new(3400.94, 2129.96, 3189.90),
    ["CP 24"] = Vector3.new(4302.00, 2566.87, 3980.00),
    ["CP 25"] = Vector3.new(5424.50, 2554.77, 4781.00),
    ["CP 26"] = Vector3.new(7168.00, 3989.90, 8614.00),
    ["CP 27"] = Vector3.new(6855.76, 4014.42, 8878.72),
    ["CP 28"] = Vector3.new(6703.70, 4001.32, 9497.36),
    ["CP 29"] = Vector3.new(6362.45, 4057.64, 10214.62),
    ["CP 30"] = Vector3.new(6185.95, 4160.06, 10926.75),
    ["CP 31"] = Vector3.new(6061.63, 4224.59, 11640.25),
    ["Summit Utama"] = Vector3.new(5565.88, 4275.94, 12533.79)
}

local CP_Name_Order = {
    "CP 0 (Basecamp)", "CP 1", "CP 2", "CP 3", "CP 4", "CP 5", "CP 6", "CP 7",
    "CP 8", "CP 9", "CP 10", "CP 11", "CP 12", "CP 13", "CP 14", "CP 15",
    "CP 16", "CP 17", "CP 18", "CP 19", "CP 20", "CP 21", "CP 22", "CP 23",
    "CP 24", "CP 25", "CP 26", "CP 27", "CP 28", "CP 29", "CP 30", "CP 31",
    "Summit Utama"
}

-- CP n berada di index n+1
local CP_Ordered = {}
for i, name in ipairs(CP_Name_Order) do
    CP_Ordered[i] = Checkpoints[name]
end

--====================================================================--
--                         STATES & SETTINGS                          --
--====================================================================--
local FlySpeed = 100
local SkipStep = 3
local SkipDelay = 0.05 -- jeda antar lompatan Auto Skip (detik)
local AutoSummitActive = false
local AutoSkipActive = false
local NoclipActive = false
local InfiniteJumpActive = false
local AntiAfkActive = false
local FollowTarget = nil
local CurrentTween = nil
local ManualIdx = 0

-- Hapus GUI lama
for _, n in ipairs({"MasensDevGUI", "MasensDevIntro"}) do
    local old = MainParent:FindFirstChild(n)
    if old then old:Destroy() end
end

--====================================================================--
--                            THEME                                   --
--====================================================================--
local Theme = {
    BG        = Color3.fromRGB(11, 11, 15),
    Panel     = Color3.fromRGB(17, 17, 23),
    Elevated  = Color3.fromRGB(25, 25, 33),
    Hover     = Color3.fromRGB(34, 34, 44),
    Stroke    = Color3.fromRGB(44, 44, 58),
    Accent    = Color3.fromRGB(225, 29, 72),
    Accent2   = Color3.fromRGB(245, 180, 80),
    Text      = Color3.fromRGB(240, 240, 246),
    Muted     = Color3.fromRGB(140, 140, 158),
    Success   = Color3.fromRGB(52, 211, 153),
}

local function New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Round(obj, r)
    return New("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function Stroke(obj, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

local function Tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function AccentGradient(obj, rotation)
    return New("UIGradient", {
        Color = ColorSequence.new(Theme.Accent, Theme.Accent2),
        Rotation = rotation or 0
    }, obj)
end

--====================================================================--
--                          SCREEN GUI                                --
--====================================================================--
local ScreenGui = New("ScreenGui", {
    Name = "MasensDevGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, MainParent)

local function MakeDraggable(handle, target)
    target = target or handle
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--====================================================================--
--                       NOTIFICATION (TOAST)                         --
--====================================================================--
local function Notify(title, text, duration)
    duration = duration or 2.5
    local toast = New("Frame", {
        Size = UDim2.new(0, 250, 0, 56),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 270, 1, -20),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, ScreenGui)
    Round(toast, 10)
    Stroke(toast, Theme.Stroke, 1)

    local bar = New("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, toast)
    Round(bar, 2)
    AccentGradient(bar, 90)

    New("TextLabel", {
        Size = UDim2.new(1, -28, 0, 20),
        Position = UDim2.new(0, 20, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 51,
    }, toast)
    New("TextLabel", {
        Size = UDim2.new(1, -28, 0, 18),
        Position = UDim2.new(0, 20, 0, 28),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 51,
    }, toast)

    Tween(toast, 0.4, {Position = UDim2.new(1, -20, 1, -20)}, Enum.EasingStyle.Back)
    task.delay(duration, function()
        if toast and toast.Parent then
            local t = Tween(toast, 0.3, {Position = UDim2.new(1, 270, 1, -20)})
            t.Completed:Wait()
            toast:Destroy()
        end
    end)
end

--====================================================================--
--                   DETEKSI STATS & RESET                            --
--====================================================================--
local function GetCheckpointObject()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        return leaderstats:FindFirstChild("Checkpoint") or leaderstats:FindFirstChild("CP")
    end
    return nil
end

local function GetCurrentCPIndex()
    local cpObj = GetCheckpointObject()
    if cpObj then
        local val = cpObj.Value
        if type(val) == "number" then
            return math.clamp(val, 0, 32)
        elseif type(val) == "string" then
            local low = string.lower(val)
            if string.find(low, "basecamp") or string.find(low, "cp 0") then
                return 0
            elseif string.find(low, "summit") then
                return 32
            else
                local num = tonumber(string.match(val, "%d+"))
                if num then return math.clamp(num, 0, 32) end
            end
        end
    end
    return ManualIdx
end

local function IsAtSummit()
    local cpObj = GetCheckpointObject()
    if cpObj and string.find(string.lower(tostring(cpObj.Value)), "summit") then
        return true
    end
    return GetCurrentCPIndex() >= 32
end

local function TriggerGameResetGUI()
    pcall(function()
        local lavaKit = ReplicatedStorage:FindFirstChild("LavaSummitKit")
        if lavaKit and lavaKit:FindFirstChild("Remotes") then
            local resetRemote = lavaKit.Remotes:FindFirstChild("ResetCheckpoint")
            if resetRemote then
                resetRemote:FireServer()
            end
        end
    end)
    ManualIdx = 0
end

--====================================================================--
--                  MOVEMENT HELPERS                                  --
--====================================================================--
local function TeleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

local function SmoothFlyTo(targetPos, speed)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then humanoid.PlatformStand = true end

    local dist = (hrp.Position - targetPos).Magnitude
    local duration = dist / math.max(speed, 10)

    CurrentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})

    local noclipConn = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)

    CurrentTween:Play()
    CurrentTween.Completed:Wait()
    noclipConn:Disconnect()

    if humanoid then humanoid.PlatformStand = false end
    return true
end

--====================================================================--
--                    MAIN WINDOW (dibuat dulu, hidden)               --
--====================================================================--
local MainFrame = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 560, 0, 360),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 2,
    ClipsDescendants = true,
}, ScreenGui)
Round(MainFrame, 14)
Stroke(MainFrame, Theme.Stroke, 1)

-- Skala otomatis sesuai layar (aman untuk HP)
local WinScale = New("UIScale", {Scale = 1}, MainFrame)
local function ComputeScale()
    local cam = workspace.CurrentCamera
    if not cam then return 1 end
    local vp = cam.ViewportSize
    return math.clamp(math.min(vp.X / 640, vp.Y / 420), 0.55, 1)
end
local BaseScale = ComputeScale()
WinScale.Scale = BaseScale

-- Glow garis atas
local TopLine = New("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 6,
}, MainFrame)
AccentGradient(TopLine, 0)

-- Header
local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ZIndex = 3,
}, MainFrame)

local Logo = New("Frame", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, 14, 0.5, -12),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 4,
}, Header)
Round(Logo, 7)
AccentGradient(Logo, 45)
New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "M",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
    ZIndex = 5,
}, Logo)

New("TextLabel", {
    Size = UDim2.new(0, 200, 0, 18),
    Position = UDim2.new(0, 46, 0, 6),
    BackgroundTransparency = 1,
    Text = "MASENSDEV",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, Header)
New("TextLabel", {
    Size = UDim2.new(0, 220, 0, 14),
    Position = UDim2.new(0, 46, 0, 24),
    BackgroundTransparency = 1,
    Text = "Mount Sorry  •  Premium V1.3",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, Header)

local function HeaderButton(text, offset, hoverColor)
    local b = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, offset, 0.5, -14),
        BackgroundColor3 = Theme.Elevated,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, Header)
    Round(b, 8)
    b.MouseEnter:Connect(function() Tween(b, 0.15, {BackgroundColor3 = hoverColor}) end)
    b.MouseLeave:Connect(function() Tween(b, 0.15, {BackgroundColor3 = Theme.Elevated}) end)
    return b
end

local CloseBtn = HeaderButton("X", -38, Theme.Accent)
local MinBtn = HeaderButton("-", -72, Theme.Hover)

MakeDraggable(Header, MainFrame)

-- Sidebar
local Sidebar = New("Frame", {
    Size = UDim2.new(0, 132, 1, -44),
    Position = UDim2.new(0, 0, 0, 44),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ZIndex = 3,
}, MainFrame)

New("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = Theme.Stroke,
    BorderSizePixel = 0,
    ZIndex = 4,
}, Sidebar)

New("TextLabel", {
    Size = UDim2.new(1, -16, 0, 14),
    Position = UDim2.new(0, 14, 1, -26),
    BackgroundTransparency = 1,
    Text = "MasensDev  |  Premium",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, Sidebar)

-- Content
local ContentFrame = New("Frame", {
    Size = UDim2.new(1, -144, 1, -56),
    Position = UDim2.new(0, 138, 0, 50),
    BackgroundTransparency = 1,
    ZIndex = 3,
}, MainFrame)

local Tabs = {}
local TabBtns = {}
local TabOrder = {"Main", "Misc", "Settings"}

for _, name in ipairs(TabOrder) do
    local frame = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = (name == "Main"),
        ZIndex = 4,
    }, ContentFrame)
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7)}, frame)
    New("UIPadding", {PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)}, frame)
    Tabs[name] = frame
end

local function SetTab(tabName)
    for name, frame in pairs(Tabs) do
        frame.Visible = (name == tabName)
    end
    for name, data in pairs(TabBtns) do
        local active = (name == tabName)
        Tween(data.btn, 0.2, {
            BackgroundTransparency = active and 0 or 1,
            TextColor3 = active and Theme.Text or Theme.Muted
        })
        Tween(data.bar, 0.2, {BackgroundTransparency = active and 0 or 1})
    end
end

for i, tabName in ipairs(TabOrder) do
    local btn = New("TextButton", {
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.new(0, 10, 0, 12 + (i - 1) * 40),
        BackgroundColor3 = Theme.Elevated,
        BackgroundTransparency = 1,
        Text = "   " .. tabName,
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, Sidebar)
    Round(btn, 8)

    local bar = New("Frame", {
        Size = UDim2.new(0, 3, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, btn)
    Round(bar, 2)

    TabBtns[tabName] = {btn = btn, bar = bar}
    btn.MouseButton1Click:Connect(function() SetTab(tabName) end)
end
SetTab("Main")

--====================================================================--
--                        UI COMPONENTS                               --
--====================================================================--
local function CreateSection(parent, text)
    local lbl = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, parent)
    New("UIPadding", {PaddingLeft = UDim.new(0, 2)}, lbl)
    return lbl
end

local function CreateButton(parent, text, callback)
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Elevated,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, parent)
    Round(btn, 8)
    local st = Stroke(btn, Theme.Stroke, 1)

    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = Theme.Hover})
        Tween(st, 0.15, {Color = Theme.Accent})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, {BackgroundColor3 = Theme.Elevated})
        Tween(st, 0.15, {Color = Theme.Stroke})
    end)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

local function CreateInput(parent, placeholder, callback)
    local box = New("TextBox", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Panel,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.Muted,
        Text = "",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, parent)
    Round(box, 8)
    local st = Stroke(box, Theme.Stroke, 1)
    box.Focused:Connect(function() Tween(st, 0.15, {Color = Theme.Accent}) end)
    box.FocusLost:Connect(function()
        Tween(st, 0.15, {Color = Theme.Stroke})
        callback(box.Text)
    end)
    return box
end

-- Toggle switch premium
local function CreateToggle(parent, title, desc, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Elevated,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, parent)
    Round(row, 8)
    Stroke(row, Theme.Stroke, 1)

    New("TextLabel", {
        Size = UDim2.new(1, -70, 0, 18),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, row)
    New("TextLabel", {
        Size = UDim2.new(1, -70, 0, 14),
        Position = UDim2.new(0, 12, 0, 26),
        BackgroundTransparency = 1,
        Text = desc or "",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, row)

    local track = New("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = Theme.Hover,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, row)
    Round(track, 11)
    local knob = New("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, track)
    Round(knob, 8)

    local state = false
    local obj = {}

    function obj.Set(v, silent)
        state = v and true or false
        Tween(track, 0.2, {BackgroundColor3 = state and Theme.Accent or Theme.Hover})
        Tween(knob, 0.2, {Position = state and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        if not silent and callback then callback(state) end
    end
    function obj.Get() return state end

    local hit = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 8,
    }, row)
    hit.MouseButton1Click:Connect(function() obj.Set(not state) end)

    return obj
end

--====================================================================--
--                         TAB MAIN                                   --
--====================================================================--
CreateSection(Tabs.Main, "Auto Farm")

local SummitToggle, SkipToggle

SummitToggle = CreateToggle(Tabs.Main, "Auto Checkpoint To Summit", "Terbang CP demi CP sampai puncak", function(on)
    AutoSummitActive = on
    if on then
        if SkipToggle.Get() then SkipToggle.Set(false) end
        Notify("Auto Summit", "Aktif - terbang ke puncak", 2)

        task.spawn(function()
            while AutoSummitActive do
                local ok, err = pcall(function()
                    if IsAtSummit() then
                        repeat
                            TriggerGameResetGUI()
                            task.wait(1)
                        until not IsAtSummit() or not AutoSummitActive
                    else
                        local currentCP = GetCurrentCPIndex()
                        local nextIndex = currentCP + 2
                        if nextIndex <= #CP_Ordered then
                            local arrived = SmoothFlyTo(CP_Ordered[nextIndex], FlySpeed)
                            if arrived and AutoSummitActive then
                                ManualIdx = nextIndex - 1
                                -- tunggu server mencatat CP (maks 1 detik)
                                local t = 0
                                while t < 1 and AutoSummitActive do
                                    if GetCheckpointObject() and GetCurrentCPIndex() >= nextIndex - 1 then
                                        break
                                    end
                                    task.wait(0.05)
                                    t = t + 0.05
                                end
                            end
                        end
                    end
                end)
                if not ok then warn("[MasensDev] AutoSummit error:", err) end
                task.wait(0.05)
            end
        end)
    else
        if CurrentTween then CurrentTween:Cancel() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

SkipToggle = CreateToggle(Tabs.Main, "Auto Skip Checkpoint", "Teleport lompat super cepat (tanpa jeda server)", function(on)
    AutoSkipActive = on
    if on then
        if SummitToggle.Get() then SummitToggle.Set(false) end
        if CurrentTween then CurrentTween:Cancel() end
        Notify("Auto Skip", "Aktif - lompat " .. SkipStep .. " CP per teleport", 2)

        task.spawn(function()
            -- Indeks internal sendiri: tidak menunggu leaderstats/server sama sekali
            local idx = GetCurrentCPIndex()
            while AutoSkipActive do
                local ok, err = pcall(function()
                    if idx >= 32 then
                        TriggerGameResetGUI()
                        idx = 0
                        task.wait(1)
                        return
                    end

                    local target = (idx < 1) and 1 or math.min(idx + SkipStep, 32)
                    if TeleportTo(CP_Ordered[target + 1] + Vector3.new(0, 3, 0)) then
                        idx = target
                        ManualIdx = target
                        if SkipDelay > 0 then task.wait(SkipDelay) end
                    else
                        task.wait(0.2) -- karakter belum ada (respawn)
                    end
                end)
                if not ok then warn("[MasensDev] AutoSkip error:", err) end
                task.wait()
            end
        end)
    end
end)

CreateSection(Tabs.Main, "Pengaturan")

CreateInput(Tabs.Main, "Kecepatan Terbang (Def: 100)", function(val)
    local num = tonumber(val)
    if num then FlySpeed = num end
end)

CreateInput(Tabs.Main, "Lompat Berapa CP (Def: 3)", function(val)
    local num = tonumber(val)
    if num and num >= 1 then SkipStep = math.floor(num) end
end)

CreateInput(Tabs.Main, "Delay Auto Skip detik (Def: 0.05)", function(val)
    local num = tonumber(val)
    if num and num >= 0 then SkipDelay = num end
end)

CreateSection(Tabs.Main, "Teleport")

local SelectedCPPos = Checkpoints["CP 0 (Basecamp)"]
local DropdownBtn = CreateButton(Tabs.Main, "Lokasi: CP 0 (Basecamp)  v")

local DropdownList = New("Frame", {
    Size = UDim2.new(1, 0, 0, 150),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 15,
}, Tabs.Main)
Round(DropdownList, 8)
Stroke(DropdownList, Theme.Accent, 1, 0.5)

local DropdownScroll = New("ScrollingFrame", {
    Size = UDim2.new(1, -8, 1, -8),
    Position = UDim2.new(0, 4, 0, 4),
    CanvasSize = UDim2.new(0, 0, 0, #CP_Name_Order * 28),
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 16,
}, DropdownList)
New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, DropdownScroll)

for index, name in ipairs(CP_Name_Order) do
    local pos = Checkpoints[name]
    if pos then
        local item = New("TextButton", {
            Size = UDim2.new(1, -6, 0, 26),
            LayoutOrder = index,
            BackgroundColor3 = Theme.Elevated,
            Text = name,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 17,
        }, DropdownScroll)
        Round(item, 6)
        item.MouseEnter:Connect(function() Tween(item, 0.12, {BackgroundColor3 = Theme.Accent}) end)
        item.MouseLeave:Connect(function() Tween(item, 0.12, {BackgroundColor3 = Theme.Elevated}) end)
        item.MouseButton1Click:Connect(function()
            SelectedCPPos = pos
            DropdownBtn.Text = "Lokasi: " .. name .. "  v"
            DropdownList.Visible = false
        end)
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

CreateButton(Tabs.Main, "Teleport Ke Lokasi Pilihan", function()
    TeleportTo(SelectedCPPos)
    Notify("Teleport", "Berhasil menuju lokasi pilihan", 1.8)
end)

CreateSection(Tabs.Main, "Pemain")

local TargetPlayerName = ""
CreateInput(Tabs.Main, "Nama Pemain Target...", function(val)
    TargetPlayerName = val
end)

local function FindPlayerByPrefix(prefix)
    prefix = string.lower(prefix)
    if prefix == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (
            string.sub(string.lower(p.Name), 1, #prefix) == prefix or
            string.sub(string.lower(p.DisplayName), 1, #prefix) == prefix
        ) then
            return p
        end
    end
    return nil
end

CreateButton(Tabs.Main, "Teleport Ke Pemain", function()
    local p = FindPlayerByPrefix(TargetPlayerName)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
    else
        Notify("Teleport", "Pemain tidak ditemukan", 1.8)
    end
end)

local FollowToggle
FollowToggle = CreateToggle(Tabs.Main, "Follow Pemain", "Ikuti pemain target", function(on)
    if on then
        local p = FindPlayerByPrefix(TargetPlayerName)
        if p then
            FollowTarget = p
            Notify("Follow", "Mengikuti " .. p.DisplayName, 1.8)
        else
            FollowTarget = nil
            FollowToggle.Set(false, true)
            Notify("Follow", "Pemain tidak ditemukan", 1.8)
        end
    else
        FollowTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if FollowTarget and FollowTarget.Character and FollowTarget.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = FollowTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

--====================================================================--
--                          TAB MISC                                  --
--====================================================================--
CreateSection(Tabs.Misc, "Karakter")

CreateInput(Tabs.Misc, "Atur Speed (Contoh: 50)", function(val)
    local num = tonumber(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if num and hum then hum.WalkSpeed = num end
end)

CreateInput(Tabs.Misc, "Atur Jump Power (Contoh: 100)", function(val)
    local num = tonumber(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if num and hum then
        hum.UseJumpPower = true
        hum.JumpPower = num
    end
end)

CreateToggle(Tabs.Misc, "NoClip", "Tembus dinding", function(on)
    NoclipActive = on
end)

CreateToggle(Tabs.Misc, "Infinite Jump", "Lompat tanpa batas di udara", function(on)
    InfiniteJumpActive = on
end)

RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if InfiniteJumpActive and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

CreateSection(Tabs.Misc, "Lainnya")

local SellAllBtn
SellAllBtn = CreateButton(Tabs.Misc, "Sell All Fish", function()
    SellAllBtn.Text = "Selling..."
    pcall(function()
        local fishingSys = ReplicatedStorage:FindFirstChild("FishingSystem")
        if fishingSys and fishingSys:FindFirstChild("InventoryEvents") then
            local sellRemote = fishingSys.InventoryEvents:FindFirstChild("Inventory_SellAll")
            if sellRemote then
                local coinsEarned = sellRemote:InvokeServer()
                if coinsEarned then
                    SellAllBtn.Text = "Sold! +" .. tostring(coinsEarned) .. " Coins"
                else
                    SellAllBtn.Text = "Inventory Empty / Sold!"
                end
            else
                SellAllBtn.Text = "Sell Remote Not Found"
            end
        else
            SellAllBtn.Text = "FishingSystem Not Found"
        end
    end)
    task.delay(2, function()
        if SellAllBtn and SellAllBtn.Parent then
            SellAllBtn.Text = "Sell All Fish"
        end
    end)
end)

--====================================================================--
--                        TAB SETTINGS                                --
--====================================================================--
CreateSection(Tabs.Settings, "Utilitas")

CreateToggle(Tabs.Settings, "Anti AFK", "Cegah kick karena idle", function(on)
    AntiAfkActive = on
end)

LocalPlayer.Idled:Connect(function()
    if AntiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

CreateSection(Tabs.Settings, "Server")

CreateButton(Tabs.Settings, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(Tabs.Settings, "Hop Server (Pemain Sedikit)", function()
    pcall(function()
        local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local result = HttpService:JSONDecode(game:HttpGet(api))
        if result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

CreateSection(Tabs.Settings, "Komunitas")

CreateButton(Tabs.Settings, "Copy Discord Link", function()
    pcall(function()
        local link = "https://discord.gg/8epSRHUXG"
        if setclipboard then
            setclipboard(link)
        elseif toclipboard then
            toclipboard(link)
        end
    end)
    Notify("Discord", "Link berhasil disalin", 1.8)
end)

CreateButton(Tabs.Settings, "Close GUI Permanently", function()
    AutoSummitActive = false
    AutoSkipActive = false
    FollowTarget = nil
    if CurrentTween then CurrentTween:Cancel() end
    ScreenGui:Destroy()
end)

--====================================================================--
--                  FLOATING TOGGLE & WINDOW CONTROLS                 --
--====================================================================--
local ToggleBtn = New("TextButton", {
    Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0.02, 0, 0.2, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    Text = "M",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBlack,
    TextSize = 20,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
}, ScreenGui)
Round(ToggleBtn, 23)
AccentGradient(ToggleBtn, 45)
Stroke(ToggleBtn, Theme.Text, 1, 0.7)
MakeDraggable(ToggleBtn)

local function ShowWindow()
    MainFrame.Visible = true
    WinScale.Scale = BaseScale * 0.9
    Tween(WinScale, 0.3, {Scale = BaseScale}, Enum.EasingStyle.Back)
end

local function HideWindow()
    local t = Tween(WinScale, 0.2, {Scale = BaseScale * 0.9})
    t.Completed:Wait()
    MainFrame.Visible = false
end

ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then HideWindow() else ShowWindow() end
end)
MinBtn.MouseButton1Click:Connect(HideWindow)
CloseBtn.MouseButton1Click:Connect(function()
    AutoSummitActive = false
    AutoSkipActive = false
    FollowTarget = nil
    if CurrentTween then CurrentTween:Cancel() end
    ScreenGui:Destroy()
end)

--====================================================================--
--              INTRO PREMIUM (FULL LAYAR, SINEMATIK)                 --
--====================================================================--
local IntroGui = New("ScreenGui", {
    Name = "MasensDevIntro",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, MainParent)

local IntroBG = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(4, 4, 7),
    BorderSizePixel = 0,
    ZIndex = 10,
}, IntroGui)

-- Vignette merah halus di tengah
local Glow = New("Frame", {
    Size = UDim2.new(0, 700, 0, 700),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 10,
}, IntroBG)
Round(Glow, 350)
New("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.82),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 0,
}, Glow)

local IntroCenter = New("Frame", {
    Size = UDim2.new(0, 560, 0, 220),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, -20),
    BackgroundTransparency = 1,
    ZIndex = 11,
}, IntroBG)

local LettersRow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 72),
    Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
    ZIndex = 12,
}, IntroCenter)
New("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 4),
}, LettersRow)

local Word = "MASENSDEV"
local Letters = {}
for i = 1, #Word do
    local alpha = (i - 1) / (#Word - 1)
    local lbl = New("TextLabel", {
        Size = UDim2.new(0, 46, 0, 72),
        BackgroundTransparency = 1,
        Text = string.sub(Word, i, i),
        TextColor3 = Theme.Accent:Lerp(Theme.Accent2, alpha),
        Font = Enum.Font.GothamBlack,
        TextSize = 40,
        TextTransparency = 1,
        LayoutOrder = i,
        ZIndex = 12,
    }, LettersRow)
    Letters[i] = lbl
end

local IntroLine = New("Frame", {
    Size = UDim2.new(0, 0, 0, 2),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 104),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 12,
}, IntroCenter)
AccentGradient(IntroLine, 0)

local IntroSub = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 118),
    BackgroundTransparency = 1,
    Text = "P R E M I U M   S C R I P T   H U B",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextTransparency = 1,
    ZIndex = 12,
}, IntroCenter)

local IntroSub2 = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 144),
    BackgroundTransparency = 1,
    Text = "Mount Sorry Edition   •   V1.3",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextTransparency = 1,
    ZIndex = 12,
}, IntroCenter)

-- Progress bar + status
local BarTrack = New("Frame", {
    Size = UDim2.new(0, 260, 0, 3),
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -70),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 12,
}, IntroBG)
Round(BarTrack, 2)
local BarFill = New("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 13,
}, BarTrack)
Round(BarFill, 2)
AccentGradient(BarFill, 0)

local StatusLbl = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -44),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextTransparency = 1,
    ZIndex = 12,
}, IntroBG)

task.spawn(function()
    pcall(function()
        -- Fade in glow
        Tween(Glow, 1.2, {BackgroundTransparency = 0})

        -- Huruf muncul satu per satu + membesar
        for i, lbl in ipairs(Letters) do
            Tween(lbl, 0.45, {TextTransparency = 0, TextSize = 58}, Enum.EasingStyle.Back)
            task.wait(0.07)
        end

        -- Garis melebar
        Tween(IntroLine, 0.7, {Size = UDim2.new(0, 360, 0, 2)}, Enum.EasingStyle.Quart)
        task.wait(0.25)
        Tween(IntroSub, 0.6, {TextTransparency = 0})
        task.wait(0.2)
        Tween(IntroSub2, 0.6, {TextTransparency = 0})

        -- Loading bar
        Tween(BarTrack, 0.4, {BackgroundTransparency = 0})
        Tween(StatusLbl, 0.4, {TextTransparency = 0})
        Tween(BarFill, 2.2, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

        local statuses = {
            "Menginisialisasi sistem...",
            "Memuat data checkpoint...",
            "Menyiapkan antarmuka premium...",
            "Selamat datang, " .. LocalPlayer.DisplayName,
        }
        for _, s in ipairs(statuses) do
            StatusLbl.Text = s
            task.wait(0.55)
        end
        task.wait(0.2)

        -- Fade out semua
        local fade = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        for _, d in ipairs(IntroGui:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, fade, {TextTransparency = 1}):Play()
            elseif d:IsA("Frame") then
                TweenService:Create(d, fade, {BackgroundTransparency = 1}):Play()
            end
        end
        task.wait(0.95)
    end)

    if IntroGui then IntroGui:Destroy() end
    ToggleBtn.Visible = true
    ShowWindow()
    Notify("MasensDev Premium", "Script berhasil dimuat", 3)
end)
