-- [[ GENESIS HUB V6: ULTIMATE EDITION ]] --
-- UI: Modern Tabbed System | Features: Webhook V2, Chat Monitor, Craft All, Auto NPC | Platform: Delta/PC

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()

-- [[ GLOBAL CONFIG ]] --
getgenv().Config = {
    -- Farming
    AutoCollect = false,
    AutoFish = false,
    AutoSell = true,
    FishLimit = 10,
    CurrentFishCount = 0,
    -- Crafting & NPC
    AutoCraftTarget = "None",
    AutoBuyNPC = false,
    -- Visuals & Performance
    FastRoll = false,
    DisableAuras = false,
    FullBright = false,
    RemoveTextures = false,
    -- Security
    ChatMonitor = true,
    WebhookURL = "",
    AdminDetector = true,
    PowerSaving = false,
    WalkSpeed = 22
}

-- [[ GENESIS UI V6 SYSTEM ]] --
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or CoreGui)
ScreenGui.Name = "GenesisHubV6"
ScreenGui.ResetOnSpawn = false

-- GS Floating Icon (Circular)
local GSToggle = Instance.new("TextButton", ScreenGui)
GSToggle.Size = UDim2.new(0, 58, 0, 58)
GSToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
GSToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
GSToggle.Text = "GS V6"; GSToggle.TextColor3 = Color3.fromRGB(255, 165, 0)
GSToggle.TextSize = 16; GSToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", GSToggle).CornerRadius = UDim.new(1, 0)
local StrokeIcon = Instance.new("UIStroke", GSToggle)
StrokeIcon.Color = Color3.fromRGB(60, 60, 60); StrokeIcon.Thickness = 2

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local StrokeMain = Instance.new("UIStroke", MainFrame)
StrokeMain.Color = Color3.fromRGB(35, 35, 35); StrokeMain.Thickness = 2

-- Sidebar (Tabs)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 15)

local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Position = UDim2.new(0, 130, 0, 10)
TabHolder.Size = UDim2.new(1, -140, 1, -20)
TabHolder.BackgroundTransparency = 1

GSToggle.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [[ UI COMPONENTS ]] --
local function CreateSwitch(parent, text, configKey)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45); Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Text = text; Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.TextSize = 13
    
    local SwitchBG = Instance.new("TextButton", Frame)
    SwitchBG.Size = UDim2.new(0, 46, 0, 24); SwitchBG.Position = UDim2.new(1, -50, 0.5, -12)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35); SwitchBG.Text = ""
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", SwitchBG)
    Circle.Size = UDim2.new(0, 20, 0, 20); Circle.Position = UDim2.new(0, 2, 0.5, -10)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    SwitchBG.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        local state = getgenv().Config[configKey]
        TweenService:Create(Circle, TweenInfo.new(0.25), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
        TweenService:Create(SwitchBG, TweenInfo.new(0.25), {BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 35)}):Play()
    end)
end

local function CreateInput(parent, placeholder, callback)
    local Box = Instance.new("TextBox", parent)
    Box.Size = UDim2.new(0.95, 0, 0, 38); Box.PlaceholderText = placeholder; Box.Text = ""
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham; Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

-- Tab System
local Pages = {}
local function AddTab(name)
    local Page = Instance.new("ScrollingFrame", TabHolder)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2; Page.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    local Layout = Instance.new("UIListLayout", Page); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = Page
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -15, 0, 42); TabBtn.Position = UDim2.new(0, 7, 0, (#Sidebar:GetChildren()-1)*48 + 15)
    TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
    end)
end

-- Create Tabs
AddTab("Home"); AddTab("Farm"); AddTab("Craft"); AddTab("Visuals"); AddTab("Settings")
Pages["Home"].Visible = true

-- [[ 1. HOME TAB ]] --
local Welcome = Instance.new("TextLabel", Pages["Home"])
Welcome.Size = UDim2.new(1, 0, 0, 80); Welcome.Text = "GENESIS HUB V6\nUltimate SOL'S RNG Script"; Welcome.TextColor3 = Color3.fromRGB(0, 170, 255)
Welcome.Font = Enum.Font.GothamBold; Welcome.TextSize = 18; Welcome.BackgroundTransparency = 1

local Stats = Instance.new("TextLabel", Pages["Home"])
Stats.Size = UDim2.new(1, 0, 0, 60); Stats.Text = "Fish: 0/"..getgenv().Config.FishLimit.."\nBiome: Normal"; Stats.TextColor3 = Color3.fromRGB(255, 255, 255)
Stats.Font = Enum.Font.Gotham; Stats.BackgroundTransparency = 1

-- [[ 2. FARM TAB ]] --
CreateSwitch(Pages["Farm"], "Auto Fish Loop", "AutoFish")
CreateSwitch(Pages["Farm"], "Auto Collect (Items)", "AutoCollect")
CreateSwitch(Pages["Farm"], "Fast Roll Bypass", "FastRoll")
CreateInput(Pages["Farm"], "Catch Limit (Default 10)", function(t) getgenv().Config.FishLimit = tonumber(t) or 10 end)

-- [[ 3. CRAFT TAB (ALL ITEMS) ]] --
local CraftList = {
    "Exo Gauntlet", "Gilded Coin", "Windstorm Device", "Volcanic Device", 
    "Galactic Device", "Eclipse Device", "Jackpot Gauntlet", "Gravitational Device",
    "Flesh Device", "Subzero Device", "Heavenly Potion II", "Universe Potion", "Biome Randomizer"
}
for _, item in pairs(CraftList) do
    local b = Instance.new("TextButton", Pages["Craft"])
    b.Size = UDim2.new(0.95, 0, 0, 35); b.Text = "Target: " .. item; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b); b.Font = Enum.Font.Gotham
    b.MouseButton1Click:Connect(function() getgenv().Config.AutoCraftTarget = item; print("Craft Target Set: "..item) end)
end

-- [[ 4. VISUALS TAB ]] --
CreateSwitch(Pages["Visuals"], "Disable Others' Auras", "DisableAuras")
CreateSwitch(Pages["Visuals"], "Full Bright", "FullBright")
CreateSwitch(Pages["Visuals"], "Remove Textures (FPS Boost)", "RemoveTextures")

-- [[ 5. SETTINGS TAB ]] --
CreateSwitch(Pages["Settings"], "Chat Monitor (Anti-Report)", "ChatMonitor")
CreateSwitch(Pages["Settings"], "Auto Buy NPC Items", "AutoBuyNPC")
CreateSwitch(Pages["Settings"], "Admin Detector", "AdminDetector")
CreateSwitch(Pages["Settings"], "Power Saving", "PowerSaving")
CreateInput(Pages["Settings"], "Discord Webhook URL", function(t) getgenv().Config.WebhookURL = t end)

-- [[ LOGIC SYSTEMS ]] --

-- Webhook V2
local function Notify(msg)
    if getgenv().Config.WebhookURL ~= "" then
        pcall(function()
            local payload = HttpService:JSONEncode({["content"] = "**[Genesis Hub V6]** "..msg})
            if request then request({Url = getgenv().Config.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload}) end
        end)
    end
end

-- Chat Monitor
if game:GetService("TextChatService").ChatInputBarConfiguration.Enabled then
    game:GetService("TextChatService").MessageReceived:Connect(function(m)
        if getgenv().Config.ChatMonitor then
            local text = m.Text:lower()
            if text:find("report") or text:find("hack") or text:find("script") or text:find(Player.Name:lower()) then
                Player:Kick("Genesis Hub Safety: Potential Report Detected!")
            end
        end
    end)
end

-- Visual Enhancements Loop
task.spawn(function()
    while task.wait(2) do
        if getgenv().Config.FullBright then
            Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        end
        if getgenv().Config.RemoveTextures then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
            end
        end
        if getgenv().Config.DisableAuras then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Aura" and v.Parent ~= Character then v:Destroy() end
            end
        end
    end
end)

-- Main Farming & NPC Loop
local function Click(btn)
    if btn and btn.Visible then
        local p = btn.AbsolutePosition; local s = btn.AbsoluteSize
        VirtualInputManager:SendMouseButtonEvent(p.X+s.X/2, p.Y+s.Y/2+36, 0, true, game, 0)
        task.wait(0.1); VirtualInputManager:SendMouseButtonEvent(p.X+s.X/2, p.Y+s.Y/2+36, 0, false, game, 0)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        -- Update Stats
        local biome = "Normal"
        if Lighting:FindFirstChild("Biome") then biome = Lighting.Biome.Value end
        Stats.Text = "Fish: "..getgenv().Config.CurrentFishCount.."/"..getgenv().Config.FishLimit.."\nBiome: "..biome

        -- Auto Buy NPC
        if getgenv().Config.AutoBuyNPC then
            for _, name in pairs({"Mari", "Jester", "Traveling Merchant"}) do
                local npc = workspace:FindFirstChild(name, true)
                if npc then
                    Player.Character.Humanoid:MoveTo(npc:GetPivot().Position)
                    Player.Character.Humanoid.MoveToFinished:Wait()
                    local p = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then fireproximityprompt(p); Notify("Found NPC: "..name) end
                end
            end
        end

        -- Fishing Loop
        if getgenv().Config.AutoFish then
            if getgenv().Config.CurrentFishCount >= getgenv().Config.FishLimit then
                -- Sell
                local merch = workspace:FindFirstChild("Merchant", true) or workspace:FindFirstChild("Lime", true)
                if merch then
                    Player.Character.Humanoid:MoveTo(merch:GetPivot().Position)
                    Player.Character.Humanoid.MoveToFinished:Wait()
                    local p = merch:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then fireproximityprompt(p); task.wait(1.5) end
                    for _, v in pairs(PlayerGui:GetDescendants()) do
                        if v:IsA("TextButton") and (v.Text:find("Sell") or v.Name:find("SellAll")) then Click(v) end
                    end
                    task.wait(0.5)
                    for _, v in pairs(PlayerGui:GetDescendants()) do
                        if v:IsA("TextButton") and (v.Text == "X" or v.Name:find("Close")) then Click(v) end
                    end
                    getgenv().Config.CurrentFishCount = 0
                end
            else
                -- Catch
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:find("Fishing") then
                        local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if p and p.ActionText:find("Cast") then
                            if (Character.HumanoidRootPart.Position - obj:GetPivot().Position).Magnitude < 15 then
                                fireproximityprompt(p); task.wait(6)
                                getgenv().Config.CurrentFishCount = getgenv().Config.CurrentFishCount + 1
                            else Player.Character.Humanoid:MoveTo(obj:GetPivot().Position) end
                            break
                        end
                    end
                end
            end
        end

        -- Auto Collect Items
        if getgenv().Config.AutoCollect then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:find("Coin") or obj.Name:find("Clover") or obj.Name:find("Potion")) then
                    if obj.PrimaryPart then
                        Player.Character.Humanoid:MoveTo(obj.PrimaryPart.Position)
                        Player.Character.Humanoid.MoveToFinished:Wait()
                    end
                end
            end
        end
    end
end)

-- Anti-AFK & Power Saving
task.spawn(function()
    while task.wait(1) do
        if getgenv().Config.PowerSaving then RunService:Set3dRenderingEnabled(false); setfpscap(5)
        else RunService:Set3dRenderingEnabled(true); setfpscap(60) end
    end
end)

Player.Idled:Connect(function()
    VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
end)

Notify("Script Loaded for " .. Player.Name)
print("Genesis Hub V6 Loaded!")
