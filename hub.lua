--[[
    ==========================================
    RANARTH LIB 

    CreateWindow otomatis membuat 3 halaman bawaan: Profile, Games, Settings
    (persis seperti Ranarth Hub asli, lengkap dengan icon & webhook Discord).

    Cara pakai:

    local Ranarth = loadstring(game:HttpGet("URL_KAMU_DISINI"))()

    local Window = Ranarth:CreateWindow({
        Name = "Ranarth Hub",
        Webhook = "https://discord.com/api/webhooks/1516049033989197824/3P_4wiyJoC9MNB2XcUJecTYYRiT6nawfn5XLBq2RLZWFmlhE3zFeOS9WKqF7VLPprS2k"
    })

    -- Tab Games sudah otomatis dibuat, tinggal isi daftar game:
    Window.GamesTab:CreateGameButton({
        Name = "Natural Disaster Survival",
        PlaceId = 189707,
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/.../NDS.lua"))()
        end
    })

    -- Mau tambah tab custom di luar Profile/Games/Settings? Masih bisa:
    local ExtraTab = Window:CreateTab({Name = "Extra", Icon = "rbxassetid://0"})
    ExtraTab:CreateButton({Name = "Contoh Tombol Biasa", Callback = function() print("klik") end})
    ExtraTab:CreateToggle({Name = "Contoh Toggle", Default = false, Callback = function(v) print(v) end})
    ExtraTab:CreateSlider({Name = "Contoh Slider", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end})
    ExtraTab:CreateLabel("Contoh label / section")
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
local AnimSpeed = 2

local function GetCustomIcon(url, filename)
    if getcustomasset and writefile and isfile then
        local success, result = pcall(function()
            if not isfile(filename) then
                writefile(filename, game:HttpGet(url))
            end
            return getcustomasset(filename)
        end)
        if success then return result end
    end
    return ""
end

local ProfileIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Profile.png"
local GamesIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Games.png"
local SettingsIconURL = "https://raw.githubusercontent.com/ranarth/Ranarth-hub/83bd1e82dbfad83d8de25919685307c902b50465/Settings.png"

-- ==========================================
-- LIBRARY / WINDOW / TAB
-- ==========================================
local Library = {}
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "RANARTH HUB"
    local WebhookURL = config.Webhook or ""
    local LoadingEnabled = (config.LoadingEnabled ~= false)

    local self = setmetatable({}, Window)
    self.AnimatedStrokes = {}
    self.Tabs = {}
    self._sidebarButtons = {}

    -- ---------- Optional Discord webhook ----------
    if WebhookURL ~= "" and not string.find(WebhookURL, "https://discord.com/api/webhooks/1516049033989197824/3P_4wiyJoC9MNB2XcUJecTYYRiT6nawfn5XLBq2RLZWFmlhE3zFeOS9WKqF7VLPprS2k") then
        task.spawn(function()
            local executorName = "Unknown"
            if identifyexecutor then pcall(function() executorName = identifyexecutor() end) end
            local gameName = game.Name
            pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
            local gameLink = "https://www.roblox.com/games/" .. tostring(game.PlaceId)
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
                        {["name"] = "Game ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                        {["name"] = "Game Link", ["value"] = gameLink, ["inline"] = false},
                    },
                    ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..PlayerId.."&width=420&height=420&format=png"}
                }}
            }
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
            if requestFunc then pcall(function() requestFunc({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
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

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = BgColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
    MainFrame.Size = UDim2.new(0, 540, 0, 360)
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
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, NeonColor),
        ColorSequenceKeypoint.new(1, PurpleNeon)
    })

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
            self.Sidebar.Visible = false
            self.ContentContainer.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 540, 0, 35)}):Play()
        else
            self.Sidebar.Visible = true
            self.ContentContainer.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 540, 0, 360)}):Play()
        end
    end)

    -- Dragging
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

    -- ---------- Confirm dialog (shared per window) ----------
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

    local ConfirmStroke = Instance.new("UIStroke", ConfirmBox)
    ConfirmStroke.Thickness = 2
    table.insert(self.AnimatedStrokes, ConfirmStroke)

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
    table.insert(self.AnimatedStrokes, Instance.new("UIStroke", ConfirmYesBtn))

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
    table.insert(self.AnimatedStrokes, Instance.new("UIStroke", ConfirmNoBtn))

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

    -- ---------- Stroke / glow animation loop ----------
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

    -- ---------- Optional rocket loading screen ----------
    if LoadingEnabled then
        local LoadingFrame = Instance.new("Frame", ScreenGui)
        LoadingFrame.Size = UDim2.new(0, 540, 0, 360)
        LoadingFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
        LoadingFrame.BackgroundColor3 = BgColor
        LoadingFrame.BorderSizePixel = 0
        Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 8)
        local LoadingStroke = Instance.new("UIStroke", LoadingFrame)
        LoadingStroke.Thickness = 2
        table.insert(self.AnimatedStrokes, LoadingStroke)

        local LoadingText = Instance.new("TextLabel", LoadingFrame)
        LoadingText.Size = UDim2.new(1, 0, 0, 20)
        LoadingText.Position = UDim2.new(0, 0, 0.6, 0)
        LoadingText.BackgroundTransparency = 1
        LoadingText.Text = "Loading..."
        LoadingText.Font = Enum.Font.GothamBold
        LoadingText.TextSize = 16
        LoadingText.TextColor3 = Color3.fromRGB(220, 220, 230)

        local TitleLabel = Instance.new("TextLabel", LoadingFrame)
        TitleLabel.Size = UDim2.new(1, 0, 0, 50)
        TitleLabel.Position = UDim2.new(0, 0, 0.35, -25)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = WindowName
        TitleLabel.Font = Enum.Font.Arcade
        TitleLabel.TextSize = 30
        TitleLabel.TextColor3 = Color3.new(1, 1, 1)
        local grad = Instance.new("UIGradient", TitleLabel)
        grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, NeonColor), ColorSequenceKeypoint.new(1, PurpleNeon)})

        task.spawn(function()
            task.wait(1.6)
            local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(LoadingFrame, fade, {BackgroundTransparency = 1}):Play()
            TweenService:Create(LoadingText, fade, {TextTransparency = 1}):Play()
            TweenService:Create(LoadingStroke, fade, {Transparency = 1}):Play()
            TweenService:Create(TitleLabel, fade, {TextTransparency = 1}):Play()
            task.wait(0.4)
            LoadingFrame:Destroy()

            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 540, 0, 360),
                Position = UDim2.new(0.5, -270, 0.5, -180)
            }):Play()
        end)
    end

    -- ==========================================
    -- MIAW
    -- ==========================================

    -- ---------- 1. Profile ----------
    local ProfileTab = self:CreateTab({
        Name = "Profile",
        Icon = GetCustomIcon(ProfileIconURL, "Ranarth_Profile.png"),
        NoListLayout = true,
    })
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
    task.spawn(function()
        while task.wait(1) do TimeText.Text = "Time: " .. os.date("%A, %I:%M:%S %p") end
    end)

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
    local GamesTab = self:CreateTab({
        Name = "Games",
        Icon = GetCustomIcon(GamesIconURL, "Ranarth_Games.png"),
        NoListLayout = true,
    })
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

    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Thickness = 1
    SearchStroke.Transparency = 0.5
    table.insert(self.AnimatedStrokes, SearchStroke)

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

    GamesTab.ButtonHolder = GameListScroll -- CreateGameButton/CreateButton dari tab ini masuk ke sini

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = SearchBox.Text:lower()
        for _, child in pairs(GameListScroll:GetChildren()) do
            if child:IsA("TextButton") then child.Visible = (text == "" or string.find(child.Name:lower(), text)) end
        end
    end)

    -- ---------- 3. Settings ----------
    local SettingsTab = self:CreateTab({
        Name = "Settings",
        Icon = GetCustomIcon(SettingsIconURL, "Ranarth_Settings.png"),
    })
    self.SettingsTab = SettingsTab

    SettingsTab:CreateSlider({
        Name = "UI Opacity", Min = 0, Max = 100, Default = 100, Suffix = "%",
        Callback = function(value)
            local transValue = 1 - (value / 100)
            MainFrame.BackgroundTransparency = transValue
            Sidebar.BackgroundTransparency = transValue
            Header.BackgroundTransparency = transValue
        end
    })

    SettingsTab:CreateSlider({
        Name = "UI Size", Min = 50, Max = 150, Default = 100, Suffix = "%",
        Callback = function(value) MainScale.Scale = value / 100 end
    })

    return self
end

-- ==========================================
-- Window:CreateTab
-- ==========================================
function Window:CreateTab(config)
    config = config or {}
    local tabName = config.Name or "Tab"
    local icon = config.Icon or ""

    local page = Instance.new("ScrollingFrame", self.ContentContainer)
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = NeonColor
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (next(self.Tabs) == nil) -- first tab created is visible by default

    if not config.NoListLayout then
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    end

    local sidebarBtn = Instance.new("ImageButton", self.ButtonContainer)
    sidebarBtn.BackgroundColor3 = ElementColor
    sidebarBtn.Size = UDim2.new(0, 40, 0, 40)
    sidebarBtn.Image = icon
    sidebarBtn.ScaleType = Enum.ScaleType.Fit
    Instance.new("UICorner", sidebarBtn).CornerRadius = UDim.new(0, 8)
    local sidebarStroke = Instance.new("UIStroke", sidebarBtn)
    sidebarStroke.Thickness = 1
    sidebarStroke.Transparency = 0.5
    table.insert(self.AnimatedStrokes, sidebarStroke)

    sidebarBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do t.Page.Visible = false end
        page.Visible = true
    end)

    local tabObj = setmetatable({
        Page = page,
        ButtonHolder = page, -- CreateButton/CreateGameButton parent here; Games tab overrides this to its GameListScroll
        Window = self,
    }, Tab)

    table.insert(self.Tabs, tabObj)
    return tabObj
end

-- ==========================================
-- Tab elements
-- ==========================================
function Tab:CreateButton(config)
    config = config or {}
    local btn = Instance.new("TextButton", self.ButtonHolder or self.Page)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = ElementColor
    btn.Text = config.Name or "Button"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, stroke)

    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    return btn
end

-- Tombol khusus daftar game: kalau PlaceId beda, munculkan warning (bukan auto-teleport).
function Tab:CreateGameButton(config)
    config = config or {}
    local gameName = config.Name or "Game"
    local placeId = config.PlaceId or 0
    local callback = config.Callback or function() end
    local isUniversal = (placeId == 0)

    local btn = Instance.new("TextButton", self.ButtonHolder or self.Page)
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.BackgroundColor3 = ElementColor
    btn.Text = ""
    btn.Name = gameName
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, btnStroke)

    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 45, 0, 45)
    icon.Position = UDim2.new(0, 5, 0.5, -22.5)
    icon.BackgroundColor3 = HeaderColor
    icon.BorderSizePixel = 0
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
    if isUniversal then
        icon.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
    else
        task.spawn(function()
            pcall(function()
                local assetInfo = MarketplaceService:GetProductInfo(placeId)
                if assetInfo and assetInfo.IconImageAssetId then
                    icon.Image = "rbxassetid://" .. assetInfo.IconImageAssetId
                end
            end)
        end)
    end

    local title = Instance.new("TextLabel", btn)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -65, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = gameName
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left

    local function RunScript()
        title.Text = "Executing Script..."
        title.TextColor3 = Color3.fromRGB(85, 255, 127)
        task.wait(0.5)
        title.Text = gameName
        title.TextColor3 = Color3.new(1, 1, 1)
        callback()
    end

    btn.MouseButton1Click:Connect(function()
        if isUniversal or game.PlaceId == placeId then
            RunScript()
        else
            self.Window:ShowConfirmDialog(
                "You are in a different place, do you still want to execute this script?",
                RunScript
            )
        end
    end)
    return btn
end

function Tab:CreateToggle(config)
    config = config or {}
    local state = config.Default or false
    local container = Instance.new("Frame", self.ButtonHolder or self.Page)
    container.BackgroundColor3 = ElementColor
    container.Size = UDim2.new(0.9, 0, 0, 45)
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", container)
    stroke.Thickness = 1; stroke.Transparency = 0.6
    table.insert(self.Window.AnimatedStrokes, stroke)

    local label = Instance.new("TextLabel", container)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = config.Name or "Toggle"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local knob = Instance.new("TextButton", container)
    knob.Size = UDim2.new(0, 40, 0, 22)
    knob.Position = UDim2.new(1, -50, 0.5, -11)
    knob.BackgroundColor3 = state and NeonColor or Color3.fromRGB(60, 60, 70)
    knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    knob.MouseButton1Click:Connect(function()
        state = not state
        knob.BackgroundColor3 = state and NeonColor or Color3.fromRGB(60, 60, 70)
        if config.Callback then config.Callback(state) end
    end)
    return knob
end

function Tab:CreateSlider(config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local defaultPercent = (default - min) / (max - min)

    local container = Instance.new("Frame", self.ButtonHolder or self.Page)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0.9, 0, 0, 50)

    local title = Instance.new("TextLabel", container)
    title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -50, 0, 20)
    title.Font = Enum.Font.GothamBold; title.Text = config.Name or "Slider"
    title.TextColor3 = Color3.new(1, 1, 1); title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", container)
    valLabel.BackgroundTransparency = 1; valLabel.Position = UDim2.new(1, -50, 0, 0)
    valLabel.Size = UDim2.new(0, 50, 0, 20); valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = tostring(math.floor(default)) .. (config.Suffix or "")
    valLabel.TextColor3 = NeonColor; valLabel.TextSize = 14
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", container)
    sliderBg.BackgroundColor3 = ElementColor; sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.Size = UDim2.new(1, 0, 0, 12)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local sliderStroke = Instance.new("UIStroke", sliderBg)
    sliderStroke.Thickness = 1; sliderStroke.Transparency = 0.5
    table.insert(self.Window.AnimatedStrokes, sliderStroke)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.BackgroundColor3 = NeonColor; sliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.BackgroundTransparency = 1; sliderBtn.Size = UDim2.new(1, 0, 1, 0); sliderBtn.Text = ""

    local isDragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
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
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.9, 0, 0, 25)
    label.Font = Enum.Font.GothamBold
    label.Text = text or ""
    label.TextColor3 = NeonColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

return Library
