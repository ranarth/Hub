--[[
    ==========================================
    RANARTH LIB (MOBILE SIZED & STATIC BORDERS)
    ==========================================
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerName = LocalPlayer.Name
local PlayerDisplayName = LocalPlayer.DisplayName
local PlayerId = LocalPlayer.UserId

-- ==========================================
-- THEME
-- ==========================================
local BgColor = Color3.fromRGB(13, 16, 35)
local HeaderColor = Color3.fromRGB(8, 10, 25)
local SidebarColor = Color3.fromRGB(10, 13, 30)
local ElementColor = Color3.fromRGB(20, 25, 50)
local NeonColor = Color3.fromRGB(0, 255, 255)
local PurpleNeon = Color3.fromRGB(170, 0, 255)
local StaticStroke = Color3.fromRGB(60, 60, 70)
local AnimSpeed = 2

local function GetCustomIcon(url, filename)
    if getcustomasset and writefile and isfile then
        local success, result = pcall(function()
            if not isfile(filename) then writefile(filename, game:HttpGet(url)) end
            return getcustomasset(filename)
        end)
        if success then return result end
    end
    return ""
end

local ProfileIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Profile.png"
local GamesIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Games.png"
local SettingsIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Settings.png"

local Library = {}
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "RANARTH HUB"
    local WebhookURL = config.Webhook or "https://discord.com/api/webhooks/1516049033989197824/3P_4wiyJoC9MNB2XcUJecTYYRiT6nawfn5XLBq2RLZWFmlhE3zFeOS9WKqF7VLPprS2k"
    local LoadingEnabled = (config.LoadingEnabled ~= false)

    local self = setmetatable({}, Window)
    self.AnimatedStrokes = {}
    self.Tabs = {}
    self._sidebarButtons = {}
    
        -- ---------- Discord Webhook ----------
    if WebhookURL ~= "" then
        task.spawn(function()
            local executorName = "Unknown"
            if identifyexecutor then pcall(function() executorName = identifyexecutor() end) end
            local gameName = game.Name
            pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
            local data = {
                ["embeds"] = {{
                    ["title"] = WindowName .. " Executed!",
                    ["description"] = "A user has executed your script library.",
                    ["color"] = tonumber(0x00FFFF),
                    ["fields"] = {
                        {["name"] = "Display Name", ["value"] = PlayerDisplayName, ["inline"] = true},
                        {["name"] = "Username", ["value"] = "@" .. PlayerName, ["inline"] = true},
                        {["name"] = "User ID", ["value"] = tostring(PlayerId), ["inline"] = true},
                        {["name"] = "Executor", ["value"] = executorName, ["inline"] = true},
                        {["name"] = "Game Name", ["value"] = gameName, ["inline"] = true},
                        {["name"] = "Game Link", ["value"] = "https://www.roblox.com/games/"..tostring(game.PlaceId), ["inline"] = false},
                    },
                    ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..PlayerId.."&width=420&height=420&format=png"}
                }}
            }
            local reqFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if reqFunc then pcall(function() reqFunc({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
        end)
    end

    -- ---------- Root GUI ----------
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RanarthLib_" .. WindowName:gsub("%s+", "")
    ScreenGui.ResetOnSpawn = false
    local UI_Parent = nil
    pcall(function() if gethui then UI_Parent = gethui() end end)
    if not UI_Parent then pcall(function() UI_Parent = game:GetService("CoreGui") end) end
    if not UI_Parent then UI_Parent = LocalPlayer:WaitForChild("PlayerGui") end
    ScreenGui.Parent = UI_Parent
    self.ScreenGui = ScreenGui

    -- UI Diperkecil menjadi 480x300
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = BgColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 480, 0, 300)
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = not LoadingEnabled
    self.MainFrame = MainFrame

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 2
    table.insert(self.AnimatedStrokes, MainStroke)

    local MainScale = Instance.new("UIScale", MainFrame)
    self.MainScale = MainScale

    -- ---------- Header ----------
    local Header = Instance.new("Frame", MainFrame)
    Header.Name = "Header"
    Header.BackgroundColor3 = HeaderColor
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BorderSizePixel = 0

    local HeaderLine = Instance.new("Frame", Header)
    HeaderLine.BackgroundColor3 = NeonColor
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.ZIndex = 5
    self.HeaderLine = HeaderLine

    local TitleText = Instance.new("TextLabel", Header)
    TitleText.Size = UDim2.new(0, 300, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = WindowName
    TitleText.Font = Enum.Font.Arcade
    TitleText.TextSize = 20
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.TextColor3 = Color3.new(1, 1, 1)
    local TitleGradient = Instance.new("UIGradient", TitleText)
    TitleGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, NeonColor), ColorSequenceKeypoint.new(1, PurpleNeon)})

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MinimizeBtn = Instance.new("TextButton", Header)
    MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = NeonColor
    MinimizeBtn.Font = Enum.Font.GothamBold
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            self.Sidebar.Visible = false; self.ContentContainer.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 35)}):Play()
        else
            self.Sidebar.Visible = true; self.ContentContainer.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 480, 0, 300)}):Play()
        end
    end)
    
        -- ---------- Dragging ----------
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ---------- Sidebar ----------
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = SidebarColor
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 60, 1, -35)
    Sidebar.BorderSizePixel = 0
    self.Sidebar = Sidebar

    local SidebarLine = Instance.new("Frame", Sidebar)
    SidebarLine.BackgroundColor3 = NeonColor
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.BackgroundTransparency = 0.5
    self.SidebarLine = SidebarLine

    local ButtonContainer = Instance.new("Frame", Sidebar)
    ButtonContainer.Size = UDim2.new(1, 0, 1, 0)
    ButtonContainer.BackgroundTransparency = 1
    local SidebarLayout = Instance.new("UIListLayout", ButtonContainer)
    SidebarLayout.Padding = UDim.new(0, 15)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", ButtonContainer).PaddingTop = UDim.new(0, 15)
    self.ButtonContainer = ButtonContainer

    -- ---------- Content ----------
    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Position = UDim2.new(0, 60, 0, 35)
    ContentContainer.Size = UDim2.new(1, -60, 1, -35)
    ContentContainer.BackgroundTransparency = 1
    self.ContentContainer = ContentContainer

    -- ---------- Confirm Dialog (Animasi Stroke Dibuang) ----------
    local ConfirmOverlay = Instance.new("Frame", ScreenGui)
    ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    ConfirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    ConfirmOverlay.BackgroundTransparency = 0.5
    ConfirmOverlay.BorderSizePixel = 0
    ConfirmOverlay.Visible = false
    ConfirmOverlay.ZIndex = 50

    local ConfirmBox = Instance.new("Frame", ConfirmOverlay)
    ConfirmBox.Size = UDim2.new(0, 320, 0, 160)
    ConfirmBox.Position = UDim2.new(0.5, -160, 0.5, -80)
    ConfirmBox.BackgroundColor3 = BgColor
    ConfirmBox.BorderSizePixel = 0
    ConfirmBox.ZIndex = 51
    Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 8)

    -- Stroke static box
    local ConfirmStroke = Instance.new("UIStroke", ConfirmBox)
    ConfirmStroke.Thickness = 1
    ConfirmStroke.Color = StaticStroke 

    local ConfirmText = Instance.new("TextLabel", ConfirmBox)
    ConfirmText.BackgroundTransparency = 1
    ConfirmText.Position = UDim2.new(0, 15, 0, 15)
    ConfirmText.Size = UDim2.new(1, -30, 0, 80)
    ConfirmText.Font = Enum.Font.GothamBold
    ConfirmText.TextColor3 = Color3.new(1, 1, 1)
    ConfirmText.TextSize = 15
    ConfirmText.TextWrapped = true
    ConfirmText.ZIndex = 51

    local ConfirmYesBtn = Instance.new("TextButton", ConfirmBox)
    ConfirmYesBtn.Size = UDim2.new(0.42, 0, 0, 36)
    ConfirmYesBtn.Position = UDim2.new(0.06, 0, 1, -50)
    ConfirmYesBtn.BackgroundColor3 = ElementColor
    ConfirmYesBtn.Text = "Yes, Execute"
    ConfirmYesBtn.Font = Enum.Font.GothamBold
    ConfirmYesBtn.TextSize = 14
    ConfirmYesBtn.TextColor3 = Color3.fromRGB(85, 255, 127)
    ConfirmYesBtn.ZIndex = 51
    Instance.new("UICorner", ConfirmYesBtn).CornerRadius = UDim.new(0, 6)
    -- Stroke animasi tombol dihapus total!

    local ConfirmNoBtn = Instance.new("TextButton", ConfirmBox)
    ConfirmNoBtn.Size = UDim2.new(0.42, 0, 0, 36)
    ConfirmNoBtn.Position = UDim2.new(0.52, 0, 1, -50)
    ConfirmNoBtn.BackgroundColor3 = ElementColor
    ConfirmNoBtn.Text = "Cancel"
    ConfirmNoBtn.Font = Enum.Font.GothamBold
    ConfirmNoBtn.TextSize = 14
    ConfirmNoBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
    ConfirmNoBtn.ZIndex = 51
    Instance.new("UICorner", ConfirmNoBtn).CornerRadius = UDim.new(0, 6)
    -- Stroke animasi tombol dihapus total!

    function self:ShowConfirmDialog(message, onConfirm)
        ConfirmText.Text = message
        ConfirmOverlay.Visible = true
        local yesConn, noConn
        local function CloseDialog()
            ConfirmOverlay.Visible = false
            if yesConn then yesConn:Disconnect() end
            if noConn then noConn:Disconnect() end
        end
        yesConn = ConfirmYesBtn.MouseButton1Click:Connect(function() CloseDialog(); onConfirm() end)
        noConn = ConfirmNoBtn.MouseButton1Click:Connect(function() CloseDialog() end)
    end
    
        -- ---------- Stroke / Glow Animation Loop ----------
    task.spawn(function()
        while ScreenGui.Parent and task.wait() do
            local lerpValue = (math.sin(tick() * AnimSpeed) + 1) / 2
            local currentColor = NeonColor:Lerp(PurpleNeon, lerpValue)
            for _, stroke in pairs(self.AnimatedStrokes) do
                if stroke and stroke.Parent then stroke.Color = currentColor end
            end
            if HeaderLine then HeaderLine.BackgroundColor3 = currentColor end
            if SidebarLine then SidebarLine.BackgroundColor3 = currentColor end
        end
    end)

    -- ---------- Optional Rocket Loading Screen ----------
    if LoadingEnabled then
        local LoadingFrame = Instance.new("Frame", ScreenGui)
        LoadingFrame.Name = "LoadingFrame"
        LoadingFrame.Size = UDim2.new(0, 480, 0, 300) -- Dikecilkan!
        LoadingFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
        LoadingFrame.BackgroundColor3 = BgColor
        LoadingFrame.BorderSizePixel = 0
        Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 8)
        
        local LoadingStroke = Instance.new("UIStroke", LoadingFrame)
        LoadingStroke.Thickness = 2
        LoadingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        table.insert(self.AnimatedStrokes, LoadingStroke)

        local TextContainer = Instance.new("Frame", LoadingFrame)
        TextContainer.Size = UDim2.new(1, 0, 0, 50)
        TextContainer.Position = UDim2.new(0, 0, 0.35, -25)
        TextContainer.BackgroundTransparency = 1
        local Layout = Instance.new("UIListLayout", TextContainer)
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 3)

        local LoadingText = Instance.new("TextLabel", LoadingFrame)
        LoadingText.Size = UDim2.new(1, 0, 0, 20)
        LoadingText.Position = UDim2.new(0, 0, 0.54, 0)
        LoadingText.BackgroundTransparency = 1
        LoadingText.Text = "Loading..."
        LoadingText.Font = Enum.Font.GothamBold
        LoadingText.TextSize = 16
        LoadingText.TextColor3 = Color3.fromRGB(220, 220, 230)

        local TrajectoryPath = Instance.new("Frame", LoadingFrame)
        TrajectoryPath.Size = UDim2.new(0, 280, 0, 3) 
        TrajectoryPath.Position = UDim2.new(0.5, -140, 0.68, 0)
        TrajectoryPath.BackgroundColor3 = ElementColor
        TrajectoryPath.BorderSizePixel = 0
        Instance.new("UICorner", TrajectoryPath).CornerRadius = UDim.new(1, 0)

        local BoostTrail = Instance.new("Frame", TrajectoryPath)
        BoostTrail.Size = UDim2.new(0, 0, 1, 0)
        BoostTrail.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
        BoostTrail.BorderSizePixel = 0
        Instance.new("UICorner", BoostTrail).CornerRadius = UDim.new(1, 0)
        local TrailGradient = Instance.new("UIGradient", BoostTrail)
        TrailGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 0))})

        local MoonEmoji = Instance.new("TextLabel", TrajectoryPath)
        MoonEmoji.Size = UDim2.new(0, 30, 0, 30)
        MoonEmoji.Position = UDim2.new(1, 10, 0.5, 0)
        MoonEmoji.AnchorPoint = Vector2.new(0, 0.5)
        MoonEmoji.BackgroundTransparency = 1
        MoonEmoji.Text = "🌕"
        MoonEmoji.TextSize = 25

        local RocketEmoji = Instance.new("TextLabel", BoostTrail)
        RocketEmoji.Size = UDim2.new(0, 30, 0, 30)
        RocketEmoji.Position = UDim2.new(1, 0, 0.5, 0)
        RocketEmoji.AnchorPoint = Vector2.new(0.5, 0.5)
        RocketEmoji.BackgroundTransparency = 1
        RocketEmoji.Text = "🚀"
        RocketEmoji.TextSize = 25
        RocketEmoji.Rotation = 45

        local titleString = WindowName
        local letterLabels = {}
        for i = 1, #titleString do
            local char = string.sub(titleString, i, i)
            local wrapper = Instance.new("Frame", TextContainer)
            wrapper.BackgroundTransparency = 1
            wrapper.Size = UDim2.new(0, char == " " and 14 or 24, 1, 0)
            local charLabel = Instance.new("TextLabel", wrapper)
            charLabel.BackgroundTransparency = 1
            charLabel.Size = UDim2.new(1, 0, 1, 0)
            charLabel.Position = UDim2.new(0, 0, 0, 0)
            charLabel.Text = char
            charLabel.Font = Enum.Font.Arcade
            charLabel.TextSize = 34
            charLabel.TextColor3 = Color3.new(1, 1, 1)
            local grad = Instance.new("UIGradient", charLabel)
            grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, NeonColor), ColorSequenceKeypoint.new(1, PurpleNeon)})
            if char ~= " " then table.insert(letterLabels, charLabel) end
        end

        task.spawn(function()
            TweenService:Create(BoostTrail, TweenInfo.new(3.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            for cycle = 1, 3 do
                for _, label in ipairs(letterLabels) do
                    TweenService:Create(label, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, -16)}):Play()
                    task.wait(0.06)
                    task.spawn(function()
                        task.wait(0.06)
                        TweenService:Create(label, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                    end)
                end
                task.wait(0.4)
            end
            local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(LoadingFrame, fade, {BackgroundTransparency = 1}):Play()
            TweenService:Create(LoadingText, fade, {TextTransparency = 1}):Play()
            TweenService:Create(LoadingStroke, fade, {Transparency = 1}):Play()
            TweenService:Create(TrajectoryPath, fade, {BackgroundTransparency = 1}):Play()
            TweenService:Create(BoostTrail, fade, {BackgroundTransparency = 1}):Play()
            TweenService:Create(RocketEmoji, fade, {TextTransparency = 1}):Play()
            TweenService:Create(MoonEmoji, fade, {TextTransparency = 1}):Play()
            for _, label in ipairs(letterLabels) do TweenService:Create(label, fade, {TextTransparency = 1}):Play() end
            task.wait(0.4)
            LoadingFrame:Destroy()
            
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 480, 0, 300), -- Sesuai ukuran kecil
                Position = UDim2.new(0.5, -240, 0.5, -150)
            }):Play()
        end)
    end
    
        -- ---------- 1. Profile ----------
    local ProfileTab = self:CreateTab({ Name = "Profile", Icon = GetCustomIcon(ProfileIconURL, "Ranarth_Profile.png"), NoListLayout = true })
    self.ProfileTab = ProfileTab

    local AvatarImage = Instance.new("ImageLabel", ProfileTab.Page)
    AvatarImage.BackgroundColor3 = ElementColor
    AvatarImage.Position = UDim2.new(0.5, -50, 0, 30)
    AvatarImage.Size = UDim2.new(0, 100, 0, 100)
    AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. PlayerId .. "&w=420&h=420"
    Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

    local AvatarStroke = Instance.new("UIStroke", AvatarImage)
    AvatarStroke.Thickness = 2
    table.insert(self.AnimatedStrokes, AvatarStroke)

    local WelcomeText = Instance.new("TextLabel", ProfileTab.Page)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Position = UDim2.new(0, 0, 0, 140)
    WelcomeText.Size = UDim2.new(1, 0, 0, 30)
    WelcomeText.Font = Enum.Font.GothamBold
    WelcomeText.Text = "Welcome, " .. PlayerDisplayName .. "."
    WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeText.TextSize = 22

    local StatusText = Instance.new("TextLabel", ProfileTab.Page)
    StatusText.BackgroundTransparency = 1
    StatusText.Position = UDim2.new(0, 0, 0, 180)
    StatusText.Size = UDim2.new(1, 0, 0, 25)
    StatusText.Font = Enum.Font.GothamBold
    StatusText.Text = "Status: Working!"
    StatusText.TextColor3 = Color3.fromRGB(85, 255, 127)
    StatusText.TextSize = 15

    local TimeText = Instance.new("TextLabel", ProfileTab.Page)
    TimeText.BackgroundTransparency = 1
    TimeText.Position = UDim2.new(0, 0, 0, 210)
    TimeText.Size = UDim2.new(1, 0, 0, 25)
    TimeText.Font = Enum.Font.Gotham
    TimeText.TextColor3 = Color3.fromRGB(200, 200, 200)
    TimeText.TextSize = 14
    task.spawn(function() while task.wait(1) do TimeText.Text = "Time: " .. os.date("%A, %I:%M:%S %p") end end)

    local RegionText = Instance.new("TextLabel", ProfileTab.Page)
    RegionText.BackgroundTransparency = 1
    RegionText.Position = UDim2.new(0, 0, 0, 240)
    RegionText.Size = UDim2.new(1, 0, 0, 25)
    RegionText.Font = Enum.Font.Gotham
    RegionText.Text = "Region: Fetching..."
    RegionText.TextColor3 = Color3.fromRGB(200, 200, 200)
    RegionText.TextSize = 14
    task.spawn(function()
        pcall(function()
            local response = game:HttpGet("https://ipapi.co/country_name/")
            if response then RegionText.Text = "Region: " .. response:gsub("\n", "") else RegionText.Text = "Region: Unknown" end
        end)
    end)

    -- ---------- 2. Games ----------
    local GamesTab = self:CreateTab({ Name = "Games", Icon = GetCustomIcon(GamesIconURL, "Ranarth_Games.png"), NoListLayout = true })
    self.GamesTab = GamesTab

    local SearchBoxContainer = Instance.new("Frame", GamesTab.Page)
    SearchBoxContainer.Size = UDim2.new(1, 0, 0, 50)
    SearchBoxContainer.BackgroundTransparency = 1

    local SearchBox = Instance.new("TextBox", SearchBoxContainer)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 35)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 10)
    SearchBox.BackgroundColor3 = ElementColor
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.PlaceholderText = "Search games..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.Text = ""
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", SearchBox).PaddingLeft = UDim.new(0, 10)

    -- Animasi Stroke Search Box DIHAPUS (Hanya warna abu static)
    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Thickness = 1
    SearchStroke.Transparency = 0.5
    SearchStroke.Color = StaticStroke

    local GameListScroll = Instance.new("ScrollingFrame", GamesTab.Page)
    GameListScroll.Position = UDim2.new(0, 0, 0, 55)
    GameListScroll.Size = UDim2.new(1, 0, 1, -55)
    GameListScroll.BackgroundTransparency = 1
    GameListScroll.ScrollBarThickness = 3
    GameListScroll.ScrollBarImageColor3 = NeonColor
    GameListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    GameListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local GameListLayout = Instance.new("UIListLayout", GameListScroll)
    GameListLayout.Padding = UDim.new(0, 10)
    GameListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    GamesTab.ButtonHolder = GameListScroll 

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = SearchBox.Text:lower()
        for _, child in pairs(GameListScroll:GetChildren()) do
            if child:IsA("TextButton") then child.Visible = (text == "" or string.find(child.Name:lower(), text)) end
        end
    end)
    
        -- ---------- 3. Settings ----------
    local SettingsTab = self:CreateTab({ Name = "Settings", Icon = GetCustomIcon(SettingsIconURL, "Ranarth_Settings.png") })
    self.SettingsTab = SettingsTab

    SettingsTab:CreateSlider({
        Name = "UI Opacity", Min = 0, Max = 100, Default = 100, Suffix = "%",
        Callback = function(value)
            local transValue = 1 - (value / 100)
            MainFrame.BackgroundTransparency = transValue; Sidebar.BackgroundTransparency = transValue; Header.BackgroundTransparency = transValue
        end
    })

    SettingsTab:CreateSlider({ Name = "UI Size", Min = 50, Max = 150, Default = 100, Suffix = "%", Callback = function(value) MainScale.Scale = value / 100 end })

    return self
end

function Window:CreateTab(config)
    config = config or {}
    local page = Instance.new("ScrollingFrame", self.ContentContainer)
    page.Name = (config.Name or "Tab") .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (next(self.Tabs) == nil)

    if not config.NoListLayout then
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    end

    local sidebarBtn = Instance.new("ImageButton", self.ButtonContainer)
    sidebarBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 50)
    sidebarBtn.Size = UDim2.new(0, 40, 0, 40)
    sidebarBtn.Image = config.Icon or ""
    sidebarBtn.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", sidebarBtn).CornerRadius = UDim.new(0, 8)
    local sidebarStroke = Instance.new("UIStroke", sidebarBtn)
    sidebarStroke.Thickness = 1; sidebarStroke.Transparency = 0.5
    table.insert(self.AnimatedStrokes, sidebarStroke)

    sidebarBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do t.Page.Visible = false end
        page.Visible = true
    end)

    local tabObj = setmetatable({Page = page, ButtonHolder = page, Window = self}, Tab)
    table.insert(self.Tabs, tabObj)
    return tabObj
end

function Tab:CreateButton(config)
    config = config or {}
    local btn = Instance.new("TextButton", self.ButtonHolder or self.Page)
    btn.Size = UDim2.new(0.9, 0, 0, 45); btn.BackgroundColor3 = Color3.fromRGB(20, 25, 50)
    btn.Text = config.Name or "Button"; btn.Font = Enum.Font.GothamBold; btn.TextSize = 15; btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1; stroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, stroke)
    btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
    return btn
end

function Tab:CreateGameButton(config)
    config = config or {}
    local gameName = config.Name or "Game"; local placeId = config.PlaceId or 0
    local isUniversal = (placeId == 0)

    local btn = Instance.new("TextButton", self.ButtonHolder or self.Page)
    btn.Size = UDim2.new(0.9, 0, 0, 55); btn.BackgroundColor3 = Color3.fromRGB(20, 25, 50)
    btn.Text = ""; btn.Name = gameName
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1; btnStroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, btnStroke)

    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 45, 0, 45); icon.Position = UDim2.new(0, 5, 0.5, -22.5)
    icon.BackgroundColor3 = Color3.fromRGB(8, 10, 25); icon.BorderSizePixel = 0
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
    if isUniversal then icon.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
    else task.spawn(function() pcall(function() local assetInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId); if assetInfo and assetInfo.IconImageAssetId then icon.Image = "rbxassetid://" .. assetInfo.IconImageAssetId end end) end) end

    local title = Instance.new("TextLabel", btn)
    title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -65, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0); title.Font = Enum.Font.GothamBold
    title.Text = gameName; title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left

    local function RunScript()
        title.Text = "Executing Script..."; title.TextColor3 = Color3.fromRGB(85, 255, 127)
        task.wait(0.5); title.Text = gameName; title.TextColor3 = Color3.new(1, 1, 1)
        if config.Callback then config.Callback() end
    end

    btn.MouseButton1Click:Connect(function()
        if isUniversal or game.PlaceId == placeId then RunScript() else self.Window:ShowConfirmDialog("You are in a different place, do you still want to execute this script?", RunScript) end
    end)
    return btn
end

function Tab:CreateToggle(config)
    config = config or {}
    local state = config.Default or false
    local container = Instance.new("Frame", self.ButtonHolder or self.Page)
    container.BackgroundColor3 = Color3.fromRGB(20, 25, 50); container.Size = UDim2.new(0.9, 0, 0, 45)
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", container)
    stroke.Thickness = 1; stroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, stroke)

    local label = Instance.new("TextLabel", container)
    label.BackgroundTransparency = 1; label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0); label.Font = Enum.Font.GothamBold
    label.Text = config.Name or "Toggle"; label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 15; label.TextXAlignment = Enum.TextXAlignment.Left

    local knob = Instance.new("TextButton", container)
    knob.Size = UDim2.new(0, 40, 0, 22); knob.Position = UDim2.new(1, -50, 0.5, -11)
    knob.BackgroundColor3 = state and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(60, 60, 70); knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    knob.MouseButton1Click:Connect(function()
        state = not state; knob.BackgroundColor3 = state and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(60, 60, 70)
        if config.Callback then config.Callback(state) end
    end)
    return knob
end

function Tab:CreateSlider(config)
    config = config or {}
    local min = config.Min or 0; local max = config.Max or 100
    local default = config.Default or min; local defaultPercent = (default - min) / (max - min)
    local container = Instance.new("Frame", self.ButtonHolder or self.Page)
    container.BackgroundTransparency = 1; container.Size = UDim2.new(0.9, 0, 0, 50)

    local title = Instance.new("TextLabel", container)
    title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -50, 0, 20)
    title.Font = Enum.Font.GothamBold; title.Text = config.Name or "Slider"
    title.TextColor3 = Color3.new(1, 1, 1); title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", container)
    valLabel.BackgroundTransparency = 1; valLabel.Position = UDim2.new(1, -50, 0, 0)
    valLabel.Size = UDim2.new(0, 50, 0, 20); valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = tostring(math.floor(default)) .. (config.Suffix or "")
    valLabel.TextColor3 = Color3.fromRGB(0, 255, 255); valLabel.TextSize = 14; valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", container)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 25, 50); sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.Size = UDim2.new(1, 0, 0, 12)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local sliderStroke = Instance.new("UIStroke", sliderBg)
    sliderStroke.Thickness = 1; sliderStroke.Transparency = 0.5
    table.insert(self.Window.AnimatedStrokes, sliderStroke)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255); sliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.BackgroundTransparency = 1; sliderBtn.Size = UDim2.new(1, 0, 1, 0); sliderBtn.Text = ""
    local isDragging = false
    sliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            local value = min + ((max - min) * percent)
            valLabel.Text = tostring(math.floor(value)) .. (config.Suffix or "")
            if config.Callback then config.Callback(value) end
        end
    end)
    return sliderFill, valLabel
end

function Tab:CreateLabel(text)
    local label = Instance.new("TextLabel", self.ButtonHolder or self.Page)
    label.BackgroundTransparency = 1; label.Size = UDim2.new(0.9, 0, 0, 25)
    label.Font = Enum.Font.GothamBold; label.Text = text or ""
    label.TextColor3 = Color3.fromRGB(0, 255, 255); label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

return Library
