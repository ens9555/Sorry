--====================================================================--
--            MASENSDEV MOUNT SORRY V1.0 (FINAL FULL FIX)             --
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

-- Safe Parent Selection untuk Xeno / Mobile / PC
local MainParent = PlayerGui
if gethui then
    MainParent = gethui()
end

-- Data Koordinat Checkpoints
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

-- Array Terurut untuk Dropdown dan Pergerakan Auto
local CP_Name_Order = {
    "CP 0 (Basecamp)", "CP 1", "CP 2", "CP 3", "CP 4", "CP 5", "CP 6", "CP 7",
    "CP 8", "CP 9", "CP 10", "CP 11", "CP 12", "CP 13", "CP 14", "CP 15",
    "CP 16", "CP 17", "CP 18", "CP 19", "CP 20", "CP 21", "CP 22", "CP 23",
    "CP 24", "CP 25", "CP 26", "CP 27", "CP 28", "CP 29", "CP 30", "CP 31",
    "Summit Utama"
}

local CP_Ordered = {
    Checkpoints["CP 0 (Basecamp)"], Checkpoints["CP 1"], Checkpoints["CP 2"], Checkpoints["CP 3"],
    Checkpoints["CP 4"], Checkpoints["CP 5"], Checkpoints["CP 6"], Checkpoints["CP 7"],
    Checkpoints["CP 8"], Checkpoints["CP 9"], Checkpoints["CP 10"], Checkpoints["CP 11"],
    Checkpoints["CP 12"], Checkpoints["CP 13"], Checkpoints["CP 14"], Checkpoints["CP 15"],
    Checkpoints["CP 16"], Checkpoints["CP 17"], Checkpoints["CP 18"], Checkpoints["CP 19"],
    Checkpoints["CP 20"], Checkpoints["CP 21"], Checkpoints["CP 22"], Checkpoints["CP 23"],
    Checkpoints["CP 24"], Checkpoints["CP 25"], Checkpoints["CP 26"], Checkpoints["CP 27"],
    Checkpoints["CP 28"], Checkpoints["CP 29"], Checkpoints["CP 30"], Checkpoints["CP 31"],
    Checkpoints["Summit Utama"]
}

-- States & Settings
local FlySpeed = 100
local AutoSummitActive = false
local AutoSkipActive = false
local NoclipActive = false
local InfiniteJumpActive = false
local AntiAfkActive = false
local FollowTarget = nil
local CurrentTween = nil

-- Clean old instances
if MainParent:FindFirstChild("MasensDevGUI") then
    MainParent.MasensDevGUI:Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasensDevGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = MainParent

-- Drag Function
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--====================================================================--
--        1. DETEKSI STATS & DIRECT REMOTEEVENT RESET BYPASS          --
--====================================================================--

local function IsAtSummit()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local cpObj = leaderstats:FindFirstChild("Checkpoint") or leaderstats:FindFirstChild("CP")
        if cpObj then
            local val = tostring(cpObj.Value)
            local low = string.lower(val)
            if string.find(low, "summit") then
                return true
            end
        end
    end
    return false
end

local function GetCurrentCPIndex()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local cpObj = leaderstats:FindFirstChild("Checkpoint") or leaderstats:FindFirstChild("CP")
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
                    if num then return num end
                end
            end
        end
    end
    return 0
end

local function TriggerGameResetGUI()
    pcall(function()
        -- Direct RemoteEvent Trigger
        local lavaKit = ReplicatedStorage:FindFirstChild("LavaSummitKit")
        if lavaKit and lavaKit:FindFirstChild("Remotes") then
            local resetRemote = lavaKit.Remotes:FindFirstChild("ResetCheckpoint")
            if resetRemote then
                resetRemote:FireServer()
            end
        end
    end)
end

--====================================================================--
--                      2. ANIMASI INTRO SCREEN                       --
--====================================================================--
local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
IntroFrame.BackgroundTransparency = 0
IntroFrame.ZIndex = 10
IntroFrame.Parent = ScreenGui

local IntroText = Instance.new("TextLabel")
IntroText.Size = UDim2.new(0, 500, 0, 100)
IntroText.Position = UDim2.new(0.5, -250, 0.5, -50)
IntroText.BackgroundTransparency = 1
IntroText.Text = "MasensDevHub"
IntroText.TextColor3 = Color3.fromRGB(255, 30, 30)
IntroText.TextSize = 1
IntroText.Font = Enum.Font.GothamBold
IntroText.ZIndex = 11
IntroText.Parent = IntroFrame

task.spawn(function()
    pcall(function()
        local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(IntroText, tweenInfo, {TextSize = 48, TextTransparency = 0}):Play()
        task.wait(1.8)
        
        local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(IntroText, fadeInfo, {TextTransparency = 1}):Play()
        TweenService:Create(IntroFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
        task.wait(1)
    end)
    if IntroFrame then IntroFrame:Destroy() end
end)

--====================================================================--
--                     3. MINI TOGGLE BUTTON                          --
--====================================================================--
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleBtn.Text = "MD"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.ZIndex = 5
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

MakeDraggable(ToggleBtn)

--====================================================================--
--                        4. MAIN FRAME GUI                           --
--====================================================================--
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
MainFrame.BackgroundTransparency = 0.4
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

MakeDraggable(MainFrame)

-- Title Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.ZIndex = 3
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "MasensDev Mount Sorry V1.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 4
TitleText.Parent = Header

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -125, 1, -40)
ContentFrame.Position = UDim2.new(0, 125, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 3
ContentFrame.Parent = MainFrame

-- Tab Frames
local Tabs = {
    Main = Instance.new("ScrollingFrame", ContentFrame),
    Misc = Instance.new("ScrollingFrame", ContentFrame),
    Settings = Instance.new("ScrollingFrame", ContentFrame)
}

for name, frame in pairs(Tabs) do
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.CanvasSize = UDim2.new(0, 0, 2, 0)
    frame.ScrollBarThickness = 4
    frame.Visible = (name == "Main")
    frame.ZIndex = 4
    
    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)
    UIList.Parent = frame
end

-- Sidebar Buttons Generator
local TabButtons = {"Main", "Misc", "Settings"}
for i, tabName in ipairs(TabButtons) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
    TabBtn.Position = UDim2.new(0.05, 0, 0, (i - 1) * 35 + 10)
    TabBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.ZIndex = 4
    TabBtn.Parent = Sidebar
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        for name, frame in pairs(Tabs) do
            frame.Visible = (name == tabName)
        end
    end)
end

-- UI Component Creators
local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.ZIndex = 5
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateInput(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.95, 0, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    box.BackgroundTransparency = 0.3
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.ZIndex = 5
    box.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = box
    
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
    return box
end

--====================================================================--
--                       5. TAB MAIN LOGIC                            --
--====================================================================--

local function TeleportTo(pos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function SmoothFlyTo(targetPos, speed)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then humanoid.PlatformStand = true end

    local dist = (hrp.Position - targetPos).Magnitude
    local duration = dist / math.max(speed, 10)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    
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
end

-- 1. AUTO CHECKPOINT TO SUMMIT
local AutoSummitBtn = CreateButton(Tabs.Main, "AUTO CHECKPOINT TO SUMMIT: OFF", function() end)
AutoSummitBtn.MouseButton1Click:Connect(function()
    AutoSummitActive = not AutoSummitActive
    AutoSummitBtn.Text = "AUTO CHECKPOINT TO SUMMIT: " .. (AutoSummitActive and "ON" or "OFF")
    
    if AutoSummitActive then
        AutoSkipActive = false
        AutoSkipBtn.Text = "AUTO SKIP CHECKPOINT: OFF"
        
        task.spawn(function()
            while AutoSummitActive do
                if IsAtSummit() or GetCurrentCPIndex() >= 32 then
                    repeat
                        TriggerGameResetGUI()
                        task.wait(1)
                    until not IsAtSummit() or not AutoSummitActive
                else
                    local currentCP = GetCurrentCPIndex()
                    local nextIndex = currentCP + 2
                    if nextIndex <= #CP_Ordered then
                        SmoothFlyTo(CP_Ordered[nextIndex], FlySpeed)
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if CurrentTween then CurrentTween:Cancel() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end
end)

-- 2. AUTO SKIP CHECKPOINT
local AutoSkipBtn = CreateButton(Tabs.Main, "AUTO SKIP CHECKPOINT: OFF", function() end)
AutoSkipBtn.MouseButton1Click:Connect(function()
    AutoSkipActive = not AutoSkipActive
    AutoSkipBtn.Text = "AUTO SKIP CHECKPOINT: " .. (AutoSkipActive and "ON" or "OFF")

    if AutoSkipActive then
        AutoSummitActive = false
        AutoSummitBtn.Text = "AUTO CHECKPOINT TO SUMMIT: OFF"
        
        task.spawn(function()
            while AutoSkipActive do
                if IsAtSummit() or GetCurrentCPIndex() >= 32 then
                    repeat
                        TriggerGameResetGUI()
                        task.wait(1)
                    until not IsAtSummit() or not AutoSkipActive
                end
                
                if not AutoSkipActive then break end
                
                TeleportTo(Checkpoints["CP 1"])
                task.wait(0.5)
                if not AutoSkipActive then break end
                
                TeleportTo(Checkpoints["Summit Utama"])
                task.wait(1)
            end
        end)
    end
end)

CreateInput(Tabs.Main, "Kecepatan Terbang (Def: 100)", function(val)
    local num = tonumber(val)
    if num then FlySpeed = num end
end)

-- Teleport Dropdown (Fixed Ordered List)
local SelectedCPPos = Checkpoints["CP 0 (Basecamp)"]
local DropdownBtn = CreateButton(Tabs.Main, "Lokasi: CP 0 (Basecamp)", function() end)
local DropdownList = Instance.new("Frame")
DropdownList.Size = UDim2.new(0.95, 0, 0, 120)
DropdownList.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
DropdownList.Visible = false
DropdownList.ZIndex = 15
DropdownList.Parent = Tabs.Main

local DropdownScroll = Instance.new("ScrollingFrame", DropdownList)
DropdownScroll.Size = UDim2.new(1, 0, 1, 0)
DropdownScroll.CanvasSize = UDim2.new(0, 0, 10, 0)
DropdownScroll.BackgroundTransparency = 1
DropdownScroll.ZIndex = 16

local DropLayout = Instance.new("UIListLayout", DropdownScroll)
DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Loop menggunakan ipairs pada array agar terurut dari CP 0 - Summit
for index, name in ipairs(CP_Name_Order) do
    local pos = Checkpoints[name]
    if pos then
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 22)
        item.LayoutOrder = index
        item.Text = name
        item.TextColor3 = Color3.fromRGB(255, 255, 255)
        item.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        item.Font = Enum.Font.Gotham
        item.TextSize = 11
        item.ZIndex = 17
        item.Parent = DropdownScroll
        
        item.MouseButton1Click:Connect(function()
            SelectedCPPos = pos
            DropdownBtn.Text = "Lokasi: " .. name
            DropdownList.Visible = false
        end)
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

CreateButton(Tabs.Main, "Teleport Ke Lokasi Pilihan", function()
    TeleportTo(SelectedCPPos)
end)

local TargetPlayerName = ""
CreateInput(Tabs.Main, "Nama Pemain Target...", function(val)
    TargetPlayerName = val
end)

CreateButton(Tabs.Main, "Teleport Ke Pemain", function()
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #TargetPlayerName) == string.lower(TargetPlayerName) or 
           string.sub(string.lower(p.DisplayName), 1, #TargetPlayerName) == string.lower(TargetPlayerName) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
            end
            break
        end
    end
end)

local FollowBtn = CreateButton(Tabs.Main, "Follow Pemain: OFF", function() end)
FollowBtn.MouseButton1Click:Connect(function()
    if FollowTarget then
        FollowTarget = nil
        FollowBtn.Text = "Follow Pemain: OFF"
    else
        for _, p in pairs(Players:GetPlayers()) do
            if (string.sub(string.lower(p.Name), 1, #TargetPlayerName) == string.lower(TargetPlayerName) or 
               string.sub(string.lower(p.DisplayName), 1, #TargetPlayerName) == string.lower(TargetPlayerName)) and p ~= LocalPlayer then
                FollowTarget = p
                FollowBtn.Text = "Follow: " .. p.DisplayName
                break
            end
        end
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
--                       6. TAB MISC LOGIC                            --
--====================================================================--

-- Tombol Sell All Fish (Ditambahkan)
local SellAllBtn = CreateButton(Tabs.Misc, "🐟 Sell All Fish", function() end)
SellAllBtn.MouseButton1Click:Connect(function()
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
            SellAllBtn.Text = "🐟 Sell All Fish"
        end
    end)
end)

CreateInput(Tabs.Misc, "Atur Speed (Contoh: 50)", function(val)
    local num = tonumber(val)
    if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = num
    end
end)

CreateInput(Tabs.Misc, "Atur Jump Power (Contoh: 100)", function(val)
    local num = tonumber(val)
    if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = num
    end
end)

local NoclipBtn = CreateButton(Tabs.Misc, "NoClip: OFF", function() end)
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NoclipBtn.Text = "NoClip: " .. (NoclipActive and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local InfJumpBtn = CreateButton(Tabs.Misc, "Infinite Jump: OFF", function() end)
InfJumpBtn.MouseButton1Click:Connect(function()
    InfiniteJumpActive = not InfiniteJumpActive
    InfJumpBtn.Text = "Infinite Jump: " .. (InfiniteJumpActive and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

--====================================================================--
--                     7. TAB SETTINGS LOGIC                          --
--====================================================================--

local AntiAfkBtn = CreateButton(Tabs.Settings, "Anti AFK: OFF", function() end)
AntiAfkBtn.MouseButton1Click:Connect(function()
    AntiAfkActive = not AntiAfkActive
    AntiAfkBtn.Text = "Anti AFK: " .. (AntiAfkActive and "ON" or "OFF")
end)

LocalPlayer.Idled:Connect(function()
    if AntiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

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

CreateButton(Tabs.Settings, "Copy Discord Link", function()
    pcall(function()
        if setclipboard then
            setclipboard("https://discord.gg/8epSRHUXG")
        elseif toclipboard then
            toclipboard("https://discord.gg/8epSRHUXG")
        end
    end)
end)

CreateButton(Tabs.Settings, "Close GUI Permanently", function()
    ScreenGui:Destroy()
end)
