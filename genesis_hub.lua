-- [[ GENESIS HUB V2: SOL'S RNG PREMIUM EDITION ]] --
-- UI Name: Genesis Hub | Icon: GS | Theme: Dark | Platform: Delta Executor

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- [[ CONFIGURATION ]] --
getgenv().GenesisHub = {
    AutoCollect = false,
    AutoFish = false,
    AutoPotion = false,
    AdminDetector = true,
    PowerSaving = false,
    AutoCraftItem = "None",
    WalkSpeed = 22,
    AntiAFK = true
}

-- [[ UI CREATION ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GenesisHubUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ResetOnSpawn = false

-- GS Floating Icon
local GSToggle = Instance.new("TextButton")
GSToggle.Name = "GSToggle"
GSToggle.Parent = ScreenGui
GSToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
GSToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
GSToggle.Size = UDim2.new(0, 60, 0, 60)
GSToggle.Font = Enum.Font.GothamBold
GSToggle.Text = "GS"
GSToggle.TextColor3 = Color3.fromRGB(0, 170, 255)
GSToggle.TextSize = 24

local UICorner_GS = Instance.new("UICorner")
UICorner_GS.CornerRadius = UDim.new(1, 0)
UICorner_GS.Parent = GSToggle

local UIStroke_GS = Instance.new("UIStroke")
UIStroke_GS.Thickness = 3
UIStroke_GS.Color = Color3.fromRGB(45, 45, 45)
UIStroke_GS.Parent = GSToggle

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Visible = true

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 15)
UICorner_Main.Parent = MainFrame

local UIStroke_Main = Instance.new("UIStroke")
UIStroke_Main.Thickness = 2
UIStroke_Main.Color = Color3.fromRGB(35, 35, 35)
UIStroke_Main.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "GENESIS HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1

-- Scrolling Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 70)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
Scroll.ScrollBarThickness = 3

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Toggle UI Logic
GSToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- UI Helpers
local function CreateToggle(text, configKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Parent = Scroll
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        getgenv().GenesisHub[configKey] = not getgenv().GenesisHub[configKey]
        local state = getgenv().GenesisHub[configKey]
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(25, 25, 25)
    end)
end

local function CreateHeader(text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.9, 0, 0, 35)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = color
    l.TextSize = 16
    l.Parent = Scroll
end

-- [[ BUILD UI CONTENT ]] --
CreateHeader("--- MAIN FARMING ---", Color3.fromRGB(0, 170, 255))
CreateToggle("Auto Collect Items", "AutoCollect")
CreateToggle("Auto Fishing & Sell", "AutoFish")
CreateToggle("Auto Use Potions", "AutoPotion")

CreateHeader("--- BIOME FINDER ---", Color3.fromRGB(0, 255, 150))
local BiomeLabel = Instance.new("TextLabel")
BiomeLabel.Size = UDim2.new(0.9, 0, 0, 30)
BiomeLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BiomeLabel.Text = "Biome: Detecting..."
BiomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BiomeLabel.Font = Enum.Font.Gotham
BiomeLabel.Parent = Scroll
Instance.new("UICorner").Parent = BiomeLabel

CreateHeader("--- AUTO CRAFT ALL ---", Color3.fromRGB(255, 200, 0))
local items = {
    "Exo Gauntlet", "Windstorm", "Volcanic", "Galactic", 
    "Eclipse", "Universal", "Gravitational", "Heavenly"
}
for _, itemName in pairs(items) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = "Target: " .. itemName
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.Gotham
    b.Parent = Scroll
    Instance.new("UICorner").Parent = b
    
    b.MouseButton1Click:Connect(function()
        getgenv().GenesisHub.AutoCraftItem = itemName
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Genesis Hub",
            Text = "Target Set: " .. itemName,
            Duration = 3
        })
    end)
end

CreateHeader("--- SECURITY & SYSTEM ---", Color3.fromRGB(255, 80, 80))
CreateToggle("Admin Detector", "AdminDetector")
CreateToggle("Power Saving Mode", "PowerSaving")

-- [[ LOGIC SYSTEMS ]] --

-- 1. Power Saving (Feature 2)
local SaveFrame = Instance.new("Frame")
SaveFrame.Size = UDim2.new(1, 0, 1, 0)
SaveFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SaveFrame.Visible = false
SaveFrame.Parent = ScreenGui
SaveFrame.ZIndex = 999
local SaveText = Instance.new("TextLabel")
SaveText.Size = UDim2.new(1, 0, 1, 0)
SaveText.Text = "POWER SAVING ACTIVE\nClick to Resume"
SaveText.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveText.BackgroundTransparency = 1
SaveText.Parent = SaveFrame

task.spawn(function()
    while task.wait(1) do
        if getgenv().GenesisHub.PowerSaving then
            SaveFrame.Visible = true
            RunService:Set3dRenderingEnabled(false)
            setfpscap(5)
        else
            SaveFrame.Visible = false
            RunService:Set3dRenderingEnabled(true)
            setfpscap(60)
        end
    end
end)

SaveFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        getgenv().GenesisHub.PowerSaving = false
    end
end)

-- 2. Admin Detector (Feature 3)
task.spawn(function()
    while task.wait(3) do
        if getgenv().GenesisHub.AdminDetector then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player then
                    local n = p.Name:lower()
                    if n:find("admin") or n:find("mod") or n:find("staff") then
                        TeleportService:Teleport(game.PlaceId, Player)
                    end
                end
            end
        end
    end
end)

-- 3. Biome Finder & Craft Logic
local function WalkTo(pos)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = getgenv().GenesisHub.WalkSpeed
        Player.Character.Humanoid:MoveTo(pos)
        Player.Character.Humanoid.MoveToFinished:Wait()
    end
end

task.spawn(function()
    while task.wait(1) do
        -- Biome Detection
        pcall(function()
            local b = "Normal"
            if Lighting:FindFirstChild("Biome") then b = Lighting.Biome.Value end
            BiomeLabel.Text = "Biome: " .. b
        end)

        -- Auto Collect
        if getgenv().GenesisHub.AutoCollect then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:find("Coin") or obj.Name:find("Clover") or obj.Name:find("Potion")) then
                    if obj.PrimaryPart then
                        WalkTo(obj.PrimaryPart.Position)
                        task.wait(0.5)
                    end
                end
            end
        end

        -- Auto Craft
        if getgenv().GenesisHub.AutoCraftItem ~= "None" then
            local jake = workspace:FindFirstChild("Jake", true)
            if jake then
                WalkTo(jake:GetPivot().Position)
                -- Interaction logic here
            end
        end
    end
end)

-- 4. Anti-AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("Genesis Hub V2 Activated")
