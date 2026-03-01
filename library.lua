local QuantomLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewportSize = workspace.CurrentCamera.ViewportSize

if isMobile and viewportSize.X > 1200 then
    isMobile = false
end

local function randomName(length)
    length = length or 16
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

local STEALTH_NAMES = {
    ScreenGui = randomName(12),
    MainContainer = randomName(14),
    Header = randomName(10),
    Sidebar = randomName(11),
    ContentArea = randomName(13),
    FloatingButton = randomName(15),
    Watermark = randomName(13),
    SearchBar = randomName(12),
    TooltipFrame = randomName(11),
    ConsoleFrame = randomName(12),
    ColorPicker = randomName(13),
    ProfileManager = randomName(14),
    KeybindList = randomName(13)
}

local DefaultThemes = {
    Dark = {
        Background = Color3.fromRGB(12, 12, 14),
        Surface = Color3.fromRGB(18, 18, 22),
        SurfaceLight = Color3.fromRGB(24, 24, 28),
        SurfaceHover = Color3.fromRGB(30, 30, 36),
        Sidebar = Color3.fromRGB(15, 15, 18),
        Primary = Color3.fromRGB(66, 135, 245),
        PrimaryDark = Color3.fromRGB(50, 110, 220),
        Accent = Color3.fromRGB(80, 150, 255),
        Text = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(160, 160, 170),
        TextMuted = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(35, 35, 42),
        Divider = Color3.fromRGB(40, 40, 48),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(80, 150, 255),
        Toggle = Color3.fromRGB(70, 140, 230)
    },
    Purple = {
        Background = Color3.fromRGB(12, 10, 18),
        Surface = Color3.fromRGB(20, 16, 28),
        SurfaceLight = Color3.fromRGB(28, 22, 38),
        SurfaceHover = Color3.fromRGB(36, 28, 48),
        Sidebar = Color3.fromRGB(16, 12, 22),
        Primary = Color3.fromRGB(140, 80, 255),
        PrimaryDark = Color3.fromRGB(110, 60, 220),
        Accent = Color3.fromRGB(170, 100, 255),
        Text = Color3.fromRGB(240, 238, 245),
        TextSecondary = Color3.fromRGB(160, 155, 175),
        TextMuted = Color3.fromRGB(100, 95, 115),
        Border = Color3.fromRGB(40, 32, 55),
        Divider = Color3.fromRGB(45, 38, 60),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(140, 80, 255),
        Toggle = Color3.fromRGB(130, 75, 240)
    },
    Red = {
        Background = Color3.fromRGB(14, 10, 10),
        Surface = Color3.fromRGB(22, 16, 16),
        SurfaceLight = Color3.fromRGB(30, 22, 22),
        SurfaceHover = Color3.fromRGB(40, 28, 28),
        Sidebar = Color3.fromRGB(18, 12, 12),
        Primary = Color3.fromRGB(220, 60, 60),
        PrimaryDark = Color3.fromRGB(180, 45, 45),
        Accent = Color3.fromRGB(255, 80, 80),
        Text = Color3.fromRGB(245, 240, 240),
        TextSecondary = Color3.fromRGB(170, 155, 155),
        TextMuted = Color3.fromRGB(115, 100, 100),
        Border = Color3.fromRGB(50, 32, 32),
        Divider = Color3.fromRGB(55, 38, 38),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(220, 60, 60),
        Toggle = Color3.fromRGB(200, 55, 55)
    },
    Green = {
        Background = Color3.fromRGB(8, 14, 10),
        Surface = Color3.fromRGB(14, 22, 16),
        SurfaceLight = Color3.fromRGB(20, 30, 22),
        SurfaceHover = Color3.fromRGB(26, 40, 28),
        Sidebar = Color3.fromRGB(10, 18, 12),
        Primary = Color3.fromRGB(50, 200, 100),
        PrimaryDark = Color3.fromRGB(40, 170, 80),
        Accent = Color3.fromRGB(70, 230, 120),
        Text = Color3.fromRGB(238, 245, 240),
        TextSecondary = Color3.fromRGB(150, 170, 158),
        TextMuted = Color3.fromRGB(90, 115, 100),
        Border = Color3.fromRGB(28, 48, 32),
        Divider = Color3.fromRGB(32, 52, 36),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(50, 200, 100),
        Toggle = Color3.fromRGB(45, 185, 90)
    },
    Rose = {
        Background = Color3.fromRGB(16, 10, 14),
        Surface = Color3.fromRGB(24, 16, 22),
        SurfaceLight = Color3.fromRGB(34, 22, 30),
        SurfaceHover = Color3.fromRGB(44, 28, 38),
        Sidebar = Color3.fromRGB(20, 12, 18),
        Primary = Color3.fromRGB(235, 80, 140),
        PrimaryDark = Color3.fromRGB(200, 60, 115),
        Accent = Color3.fromRGB(255, 100, 160),
        Text = Color3.fromRGB(245, 238, 242),
        TextSecondary = Color3.fromRGB(175, 155, 168),
        TextMuted = Color3.fromRGB(120, 95, 110),
        Border = Color3.fromRGB(55, 32, 45),
        Divider = Color3.fromRGB(60, 36, 50),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(235, 80, 140),
        Toggle = Color3.fromRGB(220, 70, 130)
    }
}

local Theme = {}
for k, v in pairs(DefaultThemes.Dark) do
    Theme[k] = v
end

function QuantomLib:SetTheme(themeName)
    local t = DefaultThemes[themeName]
    if t then
        for k, v in pairs(t) do
            Theme[k] = v
        end
    end
end

function QuantomLib:SetCustomTheme(custom)
    for k, v in pairs(custom) do
        Theme[k] = v
    end
end

local NotificationQueue = {}
local NotificationContainer = nil

local function CreateNotificationContainer()
    if NotificationContainer then return end
    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = randomName(16)
    NotificationContainer.Size = UDim2.new(0, isMobile and 280 or 320, 0, 0)
    NotificationContainer.Position = UDim2.new(1, -(isMobile and 290 or 330), 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 9999
    local screenGui = PlayerGui:FindFirstChild(STEALTH_NAMES.ScreenGui)
    if not screenGui then
        screenGui = PlayerGui:GetChildren()[#PlayerGui:GetChildren()]
    end
    NotificationContainer.Parent = screenGui or PlayerGui
    local NotificationList = Instance.new("UIListLayout")
    NotificationList.Padding = UDim.new(0, 8)
    NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotificationList.Parent = NotificationContainer
    NotificationList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NotificationContainer.Size = UDim2.new(0, isMobile and 280 or 320, 0, NotificationList.AbsoluteContentSize.Y)
    end)
end

local function CreateNotification(config)
    CreateNotificationContainer()
    local notifType = config.Type or "Info"
    local notifColor = Theme.Info
    local notifIcon = "ℹ"
    if notifType == "Success" then
        notifColor = Theme.Success
        notifIcon = "✓"
    elseif notifType == "Warning" then
        notifColor = Theme.Warning
        notifIcon = "⚠"
    elseif notifType == "Error" then
        notifColor = Theme.Error
        notifIcon = "✕"
    end
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = randomName(12)
    NotificationFrame.Size = UDim2.new(1, 0, 0, isMobile and 70 or 65)
    NotificationFrame.BackgroundColor3 = Theme.Surface
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.ClipsDescendants = true
    NotificationFrame.ZIndex = 10000
    NotificationFrame.LayoutOrder = #NotificationQueue + 1
    NotificationFrame.Parent = NotificationContainer
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 6)
    NotifCorner.Parent = NotificationFrame
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = notifColor
    NotifStroke.Thickness = 2
    NotifStroke.Transparency = 0.3
    NotifStroke.Parent = NotificationFrame
    local LeftAccent = Instance.new("Frame")
    LeftAccent.Name = randomName(8)
    LeftAccent.Size = UDim2.new(0, 4, 1, 0)
    LeftAccent.Position = UDim2.new(0, 0, 0, 0)
    LeftAccent.BackgroundColor3 = notifColor
    LeftAccent.BorderSizePixel = 0
    LeftAccent.ZIndex = 10001
    LeftAccent.Parent = NotificationFrame
    local IconFrame = Instance.new("Frame")
    IconFrame.Name = randomName(10)
    IconFrame.Size = UDim2.new(0, isMobile and 32 or 36, 0, isMobile and 32 or 36)
    IconFrame.Position = UDim2.new(0, 12, 0.5, -(isMobile and 16 or 18))
    IconFrame.BackgroundColor3 = notifColor
    IconFrame.BackgroundTransparency = 0.9
    IconFrame.BorderSizePixel = 0
    IconFrame.ZIndex = 10001
    IconFrame.Parent = NotificationFrame
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = IconFrame
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = randomName(9)
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = notifIcon
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = isMobile and 16 or 18
    IconLabel.TextColor3 = notifColor
    IconLabel.ZIndex = 10002
    IconLabel.Parent = IconFrame
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = randomName(11)
    TitleLabel.Size = UDim2.new(1, -(isMobile and 90 or 95), 0, 18)
    TitleLabel.Position = UDim2.new(0, isMobile and 52 or 56, 0, isMobile and 12 or 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Title or "Notification"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = isMobile and 12 or 13
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TitleLabel.ZIndex = 10001
    TitleLabel.Parent = NotificationFrame
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = randomName(13)
    MessageLabel.Size = UDim2.new(1, -(isMobile and 90 or 95), 0, isMobile and 32 or 30)
    MessageLabel.Position = UDim2.new(0, isMobile and 52 or 56, 0, isMobile and 28 or 26)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = config.Message or ""
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = isMobile and 10 or 11
    MessageLabel.TextColor3 = Theme.TextSecondary
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.TextWrapped = true
    MessageLabel.ZIndex = 10001
    MessageLabel.Parent = NotificationFrame
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = randomName(10)
    CloseButton.Size = UDim2.new(0, isMobile and 28 or 24, 0, isMobile and 28 or 24)
    CloseButton.Position = UDim2.new(1, -(isMobile and 34 or 30), 0, isMobile and 6 or 6)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = isMobile and 18 or 16
    CloseButton.TextColor3 = Theme.TextMuted
    CloseButton.ZIndex = 10002
    CloseButton.Parent = NotificationFrame
    local TimeBar = Instance.new("Frame")
    TimeBar.Name = randomName(8)
    TimeBar.Size = UDim2.new(1, 0, 0, 2)
    TimeBar.Position = UDim2.new(0, 0, 1, -2)
    TimeBar.BackgroundColor3 = notifColor
    TimeBar.BorderSizePixel = 0
    TimeBar.ZIndex = 10001
    TimeBar.Parent = NotificationFrame
    table.insert(NotificationQueue, NotificationFrame)
    NotificationFrame.Position = UDim2.new(1, 50, 0, 0)
    NotificationFrame.BackgroundTransparency = 1
    TitleLabel.TextTransparency = 1
    MessageLabel.TextTransparency = 1
    IconLabel.TextTransparency = 1
    CloseButton.TextTransparency = 1
    TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MessageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(IconLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(CloseButton, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    local duration = config.Duration or 5
    local timeBarTween = TweenService:Create(TimeBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
    timeBarTween:Play()
    local function closeNotification()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(MessageLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(IconLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        task.wait(0.3)
        for i, notif in ipairs(NotificationQueue) do
            if notif == NotificationFrame then
                table.remove(NotificationQueue, i)
                break
            end
        end
        NotificationFrame:Destroy()
    end
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Theme.Error}):Play()
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
    end)
    CloseButton.MouseButton1Click:Connect(function()
        timeBarTween:Cancel()
        closeNotification()
    end)
    task.delay(duration, function()
        if NotificationFrame and NotificationFrame.Parent then
            closeNotification()
        end
    end)
end

local WatermarkData = {
    Frame = nil,
    Connection = nil,
    Visible = false,
    FPS = 0,
    Ping = 0,
    FrameCount = 0,
    LastFPSUpdate = 0,
}

local function CreateWatermark(screenGui)
    if WatermarkData.Frame then return WatermarkData.Frame end
    local wmHeight = isMobile and 28 or 26
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = STEALTH_NAMES.Watermark
    WatermarkFrame.Size = UDim2.new(0, isMobile and 260 or 320, 0, wmHeight)
    WatermarkFrame.Position = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 6 or 8)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    WatermarkFrame.BackgroundTransparency = 0.15
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Visible = false
    WatermarkFrame.ZIndex = 9990
    WatermarkFrame.Parent = screenGui
    local WmCorner = Instance.new("UICorner")
    WmCorner.CornerRadius = UDim.new(0, isMobile and 6 or 5)
    WmCorner.Parent = WatermarkFrame
    local WmStroke = Instance.new("UIStroke")
    WmStroke.Color = Theme.Primary
    WmStroke.Thickness = 1
    WmStroke.Transparency = 0.6
    WmStroke.Parent = WatermarkFrame
    local TopAccent = Instance.new("Frame")
    TopAccent.Name = randomName(8)
    TopAccent.Size = UDim2.new(1, 0, 0, 2)
    TopAccent.Position = UDim2.new(0, 0, 0, 0)
    TopAccent.BackgroundColor3 = Theme.Primary
    TopAccent.BorderSizePixel = 0
    TopAccent.ZIndex = 9992
    TopAccent.Parent = WatermarkFrame
    local TopAccentCorner = Instance.new("UICorner")
    TopAccentCorner.CornerRadius = UDim.new(0, isMobile and 6 or 5)
    TopAccentCorner.Parent = TopAccent
    local AccentGradient = Instance.new("UIGradient")
    AccentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Primary)
    }
    AccentGradient.Parent = TopAccent
    local WmPadding = Instance.new("UIPadding")
    WmPadding.PaddingLeft = UDim.new(0, isMobile and 8 or 10)
    WmPadding.PaddingRight = UDim.new(0, isMobile and 8 or 10)
    WmPadding.Parent = WatermarkFrame
    local BrandLabel = Instance.new("TextLabel")
    BrandLabel.Name = randomName(10)
    BrandLabel.Size = UDim2.new(0, isMobile and 62 or 72, 1, 0)
    BrandLabel.Position = UDim2.new(0, 0, 0, 0)
    BrandLabel.BackgroundTransparency = 1
    BrandLabel.Text = "Quantom.gg"
    BrandLabel.Font = Enum.Font.GothamBold
    BrandLabel.TextSize = isMobile and 10 or 11
    BrandLabel.TextColor3 = Theme.Primary
    BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
    BrandLabel.ZIndex = 9993
    BrandLabel.Parent = WatermarkFrame
    local Sep1 = Instance.new("Frame")
    Sep1.Name = randomName(6)
    Sep1.Size = UDim2.new(0, 1, 0, isMobile and 12 or 14)
    Sep1.Position = UDim2.new(0, isMobile and 66 or 78, 0.5, isMobile and -6 or -7)
    Sep1.BackgroundColor3 = Theme.Border
    Sep1.BorderSizePixel = 0
    Sep1.ZIndex = 9993
    Sep1.Parent = WatermarkFrame
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = randomName(11)
    NameLabel.Size = UDim2.new(0, isMobile and 70 or 100, 1, 0)
    NameLabel.Position = UDim2.new(0, isMobile and 72 or 86, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.DisplayName
    NameLabel.Font = Enum.Font.GothamMedium
    NameLabel.TextSize = isMobile and 9 or 10
    NameLabel.TextColor3 = Theme.Text
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.ZIndex = 9993
    NameLabel.Parent = WatermarkFrame
    local Sep2 = Instance.new("Frame")
    Sep2.Name = randomName(6)
    Sep2.Size = UDim2.new(0, 1, 0, isMobile and 12 or 14)
    Sep2.Position = UDim2.new(0, isMobile and 146 or 192, 0.5, isMobile and -6 or -7)
    Sep2.BackgroundColor3 = Theme.Border
    Sep2.BorderSizePixel = 0
    Sep2.ZIndex = 9993
    Sep2.Parent = WatermarkFrame
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Name = randomName(10)
    FPSLabel.Size = UDim2.new(0, isMobile and 42 or 48, 1, 0)
    FPSLabel.Position = UDim2.new(0, isMobile and 152 or 200, 0, 0)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "0 FPS"
    FPSLabel.Font = Enum.Font.GothamMedium
    FPSLabel.TextSize = isMobile and 9 or 10
    FPSLabel.TextColor3 = Theme.Success
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.ZIndex = 9993
    FPSLabel.Parent = WatermarkFrame
    local Sep3 = Instance.new("Frame")
    Sep3.Name = randomName(6)
    Sep3.Size = UDim2.new(0, 1, 0, isMobile and 12 or 14)
    Sep3.Position = UDim2.new(0, isMobile and 198 or 254, 0.5, isMobile and -6 or -7)
    Sep3.BackgroundColor3 = Theme.Border
    Sep3.BorderSizePixel = 0
    Sep3.ZIndex = 9993
    Sep3.Parent = WatermarkFrame
    local PingLabel = Instance.new("TextLabel")
    PingLabel.Name = randomName(10)
    PingLabel.Size = UDim2.new(0, isMobile and 50 or 52, 1, 0)
    PingLabel.Position = UDim2.new(0, isMobile and 204 or 262, 0, 0)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "0ms"
    PingLabel.Font = Enum.Font.GothamMedium
    PingLabel.TextSize = isMobile and 9 or 10
    PingLabel.TextColor3 = Theme.Info
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.ZIndex = 9993
    PingLabel.Parent = WatermarkFrame
    local wmDragging = false
    local wmDragStart, wmStartPos
    WatermarkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wmDragging = true
            wmDragStart = input.Position
            wmStartPos = WatermarkFrame.Position
        end
    end)
    WatermarkFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wmDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - wmDragStart
            WatermarkFrame.Position = UDim2.new(wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X, wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y)
        end
    end)
    WatermarkData.Connection = RunService.Heartbeat:Connect(function(dt)
        if not WatermarkFrame or not WatermarkFrame.Parent then
            if WatermarkData.Connection then
                WatermarkData.Connection:Disconnect()
            end
            return
        end
        WatermarkData.FrameCount = WatermarkData.FrameCount + 1
        WatermarkData.LastFPSUpdate = WatermarkData.LastFPSUpdate + dt
        if WatermarkData.LastFPSUpdate >= 0.5 then
            WatermarkData.FPS = math.floor(WatermarkData.FrameCount / WatermarkData.LastFPSUpdate)
            WatermarkData.FrameCount = 0
            WatermarkData.LastFPSUpdate = 0
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            WatermarkData.Ping = ping
            FPSLabel.Text = WatermarkData.FPS .. " FPS"
            if WatermarkData.FPS >= 55 then
                FPSLabel.TextColor3 = Theme.Success
            elseif WatermarkData.FPS >= 30 then
                FPSLabel.TextColor3 = Theme.Warning
            else
                FPSLabel.TextColor3 = Theme.Error
            end
            PingLabel.Text = ping .. "ms"
            if ping <= 80 then
                PingLabel.TextColor3 = Theme.Success
            elseif ping <= 150 then
                PingLabel.TextColor3 = Theme.Warning
            else
                PingLabel.TextColor3 = Theme.Error
            end
        end
    end)
    WatermarkData.Frame = WatermarkFrame
    return WatermarkFrame
end

local function ShowWatermark(screenGui)
    if not WatermarkData.Frame then
        CreateWatermark(screenGui)
    end
    WatermarkData.Frame.Visible = true
    WatermarkData.Visible = true
    WatermarkData.Frame.BackgroundTransparency = 1
    TweenService:Create(WatermarkData.Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
    for _, child in ipairs(WatermarkData.Frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            child.TextTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
        elseif child:IsA("Frame") and child.BackgroundTransparency < 0.5 then
            local target = child.BackgroundTransparency
            child.BackgroundTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.35), {BackgroundTransparency = target}):Play()
        end
    end
end

local function HideWatermark()
    if not WatermarkData.Frame then return end
    WatermarkData.Visible = false
    TweenService:Create(WatermarkData.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(WatermarkData.Frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child.BackgroundTransparency < 0.5 then
            TweenService:Create(child, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
    end
    task.delay(0.25, function()
        if WatermarkData.Frame and not WatermarkData.Visible then
            WatermarkData.Frame.Visible = false
        end
    end)
end

local KeybindListData = {
    Frame = nil,
    Visible = false,
    Entries = {},
    Labels = {},
}

local function CreateKeybindList(screenGui)
    if KeybindListData.Frame then return KeybindListData.Frame end

    local listWidth = isMobile and 180 or 220
    local KBListFrame = Instance.new("Frame")
    KBListFrame.Name = STEALTH_NAMES.KeybindList
    KBListFrame.Size = UDim2.new(0, listWidth, 0, 30)
    KBListFrame.Position = UDim2.new(0, isMobile and 8 or 12, 1, -(isMobile and 50 or 60))
    KBListFrame.AnchorPoint = Vector2.new(0, 1)
    KBListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    KBListFrame.BackgroundTransparency = 0.15
    KBListFrame.BorderSizePixel = 0
    KBListFrame.Visible = false
    KBListFrame.ZIndex = 9980
    KBListFrame.AutomaticSize = Enum.AutomaticSize.Y
    KBListFrame.Parent = screenGui

    local KBCorner = Instance.new("UICorner")
    KBCorner.CornerRadius = UDim.new(0, isMobile and 6 or 5)
    KBCorner.Parent = KBListFrame

    local KBStroke = Instance.new("UIStroke")
    KBStroke.Color = Theme.Primary
    KBStroke.Thickness = 1
    KBStroke.Transparency = 0.6
    KBStroke.Parent = KBListFrame

    local TopAccent = Instance.new("Frame")
    TopAccent.Name = randomName(8)
    TopAccent.Size = UDim2.new(1, 0, 0, 2)
    TopAccent.Position = UDim2.new(0, 0, 0, 0)
    TopAccent.BackgroundColor3 = Theme.Primary
    TopAccent.BorderSizePixel = 0
    TopAccent.ZIndex = 9982
    TopAccent.Parent = KBListFrame

    local TopAccentCorner = Instance.new("UICorner")
    TopAccentCorner.CornerRadius = UDim.new(0, isMobile and 6 or 5)
    TopAccentCorner.Parent = TopAccent

    local KBPadding = Instance.new("UIPadding")
    KBPadding.PaddingTop = UDim.new(0, 6)
    KBPadding.PaddingBottom = UDim.new(0, 6)
    KBPadding.PaddingLeft = UDim.new(0, isMobile and 8 or 10)
    KBPadding.PaddingRight = UDim.new(0, isMobile and 8 or 10)
    KBPadding.Parent = KBListFrame

    local KBLayout = Instance.new("UIListLayout")
    KBLayout.Padding = UDim.new(0, 2)
    KBLayout.SortOrder = Enum.SortOrder.LayoutOrder
    KBLayout.Parent = KBListFrame

    local TitleRow = Instance.new("TextLabel")
    TitleRow.Name = randomName(10)
    TitleRow.Size = UDim2.new(1, 0, 0, isMobile and 16 or 14)
    TitleRow.BackgroundTransparency = 1
    TitleRow.Text = "Keybinds Ativos"
    TitleRow.Font = Enum.Font.GothamBold
    TitleRow.TextSize = isMobile and 10 or 9
    TitleRow.TextColor3 = Theme.Primary
    TitleRow.TextXAlignment = Enum.TextXAlignment.Left
    TitleRow.ZIndex = 9983
    TitleRow.LayoutOrder = 0
    TitleRow.Parent = KBListFrame

    local kbDragging = false
    local kbDragStart, kbStartPos

    KBListFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = true
            kbDragStart = input.Position
            kbStartPos = KBListFrame.Position
        end
    end)

    KBListFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if kbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - kbDragStart
            KBListFrame.Position = UDim2.new(kbStartPos.X.Scale, kbStartPos.X.Offset + delta.X, kbStartPos.Y.Scale, kbStartPos.Y.Offset + delta.Y)
        end
    end)

    KeybindListData.Frame = KBListFrame
    return KBListFrame
end

local function UpdateKeybindList()
    if not KeybindListData.Frame then return end

    for _, label in pairs(KeybindListData.Labels) do
        label:Destroy()
    end
    KeybindListData.Labels = {}

    local hasActive = false
    local order = 1

    for _, entry in ipairs(KeybindListData.Entries) do
        if entry.GetState() then
            hasActive = true
            order = order + 1

            local Row = Instance.new("Frame")
            Row.Name = randomName(8)
            Row.Size = UDim2.new(1, 0, 0, isMobile and 18 or 16)
            Row.BackgroundTransparency = 1
            Row.ZIndex = 9983
            Row.LayoutOrder = order
            Row.Parent = KeybindListData.Frame

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Name = randomName(7)
            NameLabel.Size = UDim2.new(1, -(isMobile and 40 or 45), 1, 0)
            NameLabel.Position = UDim2.new(0, 0, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = entry.Name
            NameLabel.Font = Enum.Font.GothamMedium
            NameLabel.TextSize = isMobile and 9 or 10
            NameLabel.TextColor3 = Theme.Text
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            NameLabel.ZIndex = 9984
            NameLabel.Parent = Row

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Name = randomName(7)
            KeyLabel.Size = UDim2.new(0, isMobile and 36 or 40, 0, isMobile and 14 or 13)
            KeyLabel.Position = UDim2.new(1, -(isMobile and 36 or 40), 0.5, -(isMobile and 7 or 6.5))
            KeyLabel.BackgroundColor3 = Theme.Primary
            KeyLabel.BackgroundTransparency = 0.8
            KeyLabel.Text = entry.GetKey().Name
            KeyLabel.Font = Enum.Font.GothamBold
            KeyLabel.TextSize = isMobile and 8 or 9
            KeyLabel.TextColor3 = Theme.Primary
            KeyLabel.ZIndex = 9984
            KeyLabel.Parent = Row

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 3)
            KeyCorner.Parent = KeyLabel

            table.insert(KeybindListData.Labels, Row)
        end
    end

    if not hasActive then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Name = randomName(8)
        EmptyLabel.Size = UDim2.new(1, 0, 0, isMobile and 14 or 12)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "Nenhum ativo"
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.TextSize = isMobile and 8 or 9
        EmptyLabel.TextColor3 = Theme.TextMuted
        EmptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        EmptyLabel.ZIndex = 9983
        EmptyLabel.LayoutOrder = 1
        EmptyLabel.Parent = KeybindListData.Frame
        table.insert(KeybindListData.Labels, EmptyLabel)
    end
end

local function RegisterKeybindEntry(name, getState, getKey)
    table.insert(KeybindListData.Entries, {
        Name = name,
        GetState = getState,
        GetKey = getKey,
    })
    UpdateKeybindList()
end

local function ShowKeybindList(screenGui)
    if not KeybindListData.Frame then
        CreateKeybindList(screenGui)
    end
    KeybindListData.Frame.Visible = true
    KeybindListData.Visible = true
    UpdateKeybindList()

    KeybindListData.Frame.BackgroundTransparency = 1
    TweenService:Create(KeybindListData.Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
    for _, child in ipairs(KeybindListData.Frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            child.TextTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
        elseif child:IsA("Frame") and child.BackgroundTransparency < 0.5 then
            local target = child.BackgroundTransparency
            child.BackgroundTransparency = 1
            TweenService:Create(child, TweenInfo.new(0.35), {BackgroundTransparency = target}):Play()
        end
    end
end

local function HideKeybindList()
    if not KeybindListData.Frame then return end
    KeybindListData.Visible = false
    TweenService:Create(KeybindListData.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(KeybindListData.Frame:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") and child.BackgroundTransparency < 0.5 then
            TweenService:Create(child, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
    end
    task.delay(0.25, function()
        if KeybindListData.Frame and not KeybindListData.Visible then
            KeybindListData.Frame.Visible = false
        end
    end)
end

function QuantomLib:CreateWindow(config)
    local Window = {}
    Window.Name = config.Name or "QUANTOM.GG"
    Window.Version = config.Version or "v1.0.0"
    Window.Categories = {}
    Window.Flags = {}
    Window._connections = {}
    Window._alive = true
    Window._elements = {}
    Window._globalKeybinds = {}
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

    if config.Theme then
        if type(config.Theme) == "string" then
            QuantomLib:SetTheme(config.Theme)
        elseif type(config.Theme) == "table" then
            QuantomLib:SetCustomTheme(config.Theme)
        end
    end

    local function addConnection(conn)
        table.insert(Window._connections, conn)
        return conn
    end

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == STEALTH_NAMES.ScreenGui then
            gui:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = STEALTH_NAMES.ScreenGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local uiWidth, uiHeight
    if isMobile then
        uiWidth = math.min(viewportSize.X * 0.95, 500)
        uiHeight = math.min(viewportSize.Y * 0.85, 600)
    else
        uiWidth = 900
        uiHeight = 580
    end

    local MainContainer = Instance.new("Frame")
    MainContainer.Name = STEALTH_NAMES.MainContainer
    MainContainer.Size = UDim2.new(0, uiWidth, 0, uiHeight)
    MainContainer.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
    MainContainer.BackgroundColor3 = Theme.Background
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true
    MainContainer.Visible = false
    MainContainer.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
    MainCorner.Parent = MainContainer

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainContainer

    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = STEALTH_NAMES.TooltipFrame
    TooltipFrame.Size = UDim2.new(0, 200, 0, 30)
    TooltipFrame.BackgroundColor3 = Theme.Surface
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 99999
    TooltipFrame.Parent = ScreenGui

    local TooltipCorner = Instance.new("UICorner")
    TooltipCorner.CornerRadius = UDim.new(0, 4)
    TooltipCorner.Parent = TooltipFrame

    local TooltipStroke = Instance.new("UIStroke")
    TooltipStroke.Color = Theme.Border
    TooltipStroke.Thickness = 1
    TooltipStroke.Parent = TooltipFrame

    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Name = randomName(10)
    TooltipLabel.Size = UDim2.new(1, -12, 1, 0)
    TooltipLabel.Position = UDim2.new(0, 6, 0, 0)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.Text = ""
    TooltipLabel.Font = Enum.Font.Gotham
    TooltipLabel.TextSize = 10
    TooltipLabel.TextColor3 = Theme.TextSecondary
    TooltipLabel.TextWrapped = true
    TooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
    TooltipLabel.ZIndex = 99999
    TooltipLabel.Parent = TooltipFrame

    local function showTooltip(text, guiObject)
        if not text or text == "" then return end
        TooltipLabel.Text = text
        local textBounds = TooltipLabel.TextBounds
        TooltipFrame.Size = UDim2.new(0, math.min(textBounds.X + 16, 250), 0, math.max(textBounds.Y + 8, 24))
        TooltipFrame.Visible = true
        local absPos = guiObject.AbsolutePosition
        local absSize = guiObject.AbsoluteSize
        TooltipFrame.Position = UDim2.new(0, absPos.X + absSize.X / 2 - TooltipFrame.AbsoluteSize.X / 2, 0, absPos.Y - TooltipFrame.AbsoluteSize.Y - 4)
    end

    local function hideTooltip()
        TooltipFrame.Visible = false
    end

    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = STEALTH_NAMES.FloatingButton
    FloatingButton.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 60 or 50)
    FloatingButton.Position = UDim2.new(1, -70, 0, 100)
    FloatingButton.BackgroundColor3 = Theme.Primary
    FloatingButton.BorderSizePixel = 0
    FloatingButton.Visible = isMobile
    FloatingButton.ZIndex = 1000
    FloatingButton.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatingButton

    local FloatIcon = Instance.new("TextLabel")
    FloatIcon.Name = randomName(10)
    FloatIcon.Size = UDim2.new(1, 0, 1, 0)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Text = "Q"
    FloatIcon.Font = Enum.Font.GothamBold
    FloatIcon.TextSize = isMobile and 28 or 24
    FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatIcon.ZIndex = 1001
    FloatIcon.Parent = FloatingButton

    local floatTween = TweenService:Create(FloatingButton, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, (isMobile and 60 or 50) + 5, 0, (isMobile and 60 or 50) + 5)})
    floatTween:Play()

    local floatDragging = false
    local floatDragStart
    local floatStartPos
    local floatDragMoved = false

    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
            floatDragMoved = false
            floatDragStart = input.Position
            floatStartPos = FloatingButton.Position
        end
    end)

    FloatingButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = false
        end
    end)

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if not Window._alive then return end
        if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            if delta.Magnitude > 5 then
                floatDragMoved = true
            end
            FloatingButton.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
        end
    end))

    FloatingButton.MouseButton1Click:Connect(function()
        if floatDragMoved then return end
        MainContainer.Visible = true
        FloatingButton.Visible = false
    end)

    local BackgroundEffects = Instance.new("Frame")
    BackgroundEffects.Name = randomName(12)
    BackgroundEffects.Size = UDim2.new(1, 0, 1, 0)
    BackgroundEffects.BackgroundTransparency = 1
    BackgroundEffects.ClipsDescendants = true
    BackgroundEffects.ZIndex = 0
    BackgroundEffects.Parent = MainContainer

    for i = 1, isMobile and 8 or 15 do
        local particle = Instance.new("Frame")
        particle.Name = randomName(8)
        particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Theme.Primary
        particle.BackgroundTransparency = math.random(70, 90) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = 0
        particle.Parent = BackgroundEffects
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        TweenService:Create(particle, TweenInfo.new(math.random(8, 15), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(math.random(), 0, math.random(), 0), BackgroundTransparency = math.random(85, 95) / 100}):Play()
    end

    local BackgroundGradient = Instance.new("Frame")
    BackgroundGradient.Name = randomName(14)
    BackgroundGradient.Size = UDim2.new(1, 0, 1, 0)
    BackgroundGradient.BackgroundColor3 = Theme.Primary
    BackgroundGradient.BackgroundTransparency = 0.97
    BackgroundGradient.BorderSizePixel = 0
    BackgroundGradient.ZIndex = 0
    BackgroundGradient.Parent = BackgroundEffects

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Primary)
    }
    bgGradient.Rotation = 45
    bgGradient.Parent = BackgroundGradient

    task.spawn(function()
        while Window._alive and MainContainer.Parent do
            TweenService:Create(bgGradient, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = bgGradient.Rotation + 180}):Play()
            task.wait(8)
        end
    end)

    local headerHeight = isMobile and 50 or 45
    local Header = Instance.new("Frame")
    Header.Name = STEALTH_NAMES.Header
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Header.Parent = MainContainer

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
    HeaderCorner.Parent = Header

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Name = randomName(10)
    HeaderFix.Size = UDim2.new(1, 0, 0, 6)
    HeaderFix.Position = UDim2.new(0, 0, 1, -6)
    HeaderFix.BackgroundColor3 = Theme.Sidebar
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 2
    HeaderFix.Parent = Header

    local LogoText = Instance.new("TextLabel")
    LogoText.Name = randomName(12)
    LogoText.Size = UDim2.new(0, 120, 1, 0)
    LogoText.Position = UDim2.new(0, 15, 0, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = Window.Name
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = isMobile and 13 or 14
    LogoText.TextColor3 = Theme.Text
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.ZIndex = 3
    LogoText.Parent = Header

    local StatusText = Instance.new("TextLabel")
    StatusText.Name = randomName(11)
    StatusText.Size = UDim2.new(0, 80, 1, 0)
    StatusText.Position = UDim2.new(1, isMobile and -155 or -165, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = Window.Version
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextSize = isMobile and 10 or 11
    StatusText.TextColor3 = Theme.Success
    StatusText.TextXAlignment = Enum.TextXAlignment.Right
    StatusText.ZIndex = 3
    StatusText.Parent = Header

    if not isMobile then
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainContainer.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        Header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        addConnection(UserInputService.InputChanged:Connect(function(input)
            if not Window._alive then return end
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
    end

    local buttonSize = isMobile and 35 or 30

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = randomName(14)
    MinimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    MinimizeButton.Position = UDim2.new(1, isMobile and -80 or -76, 0.5, -buttonSize/2)
    MinimizeButton.BackgroundColor3 = Theme.Surface
    MinimizeButton.Text = "−"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = isMobile and 20 or 18
    MinimizeButton.TextColor3 = Theme.TextMuted
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.ZIndex = 3
    MinimizeButton.Parent = Header

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = MinimizeButton

    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text}):Play()
    end)

    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}):Play()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        if isMobile then
            FloatingButton.Visible = true
        end
    end)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = randomName(13)
    CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    CloseButton.Position = UDim2.new(1, isMobile and -38 or -38, 0.5, -buttonSize/2)
    CloseButton.BackgroundColor3 = Theme.Surface
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = isMobile and 20 or 18
    CloseButton.TextColor3 = Theme.TextMuted
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 3
    CloseButton.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50), TextColor3 = Theme.Text}):Play()
    end)

    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}):Play()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        if isMobile then
            FloatingButton.Visible = true
        end
    end)

    local sidebarWidth = isMobile and 100 or 160
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = STEALTH_NAMES.Sidebar
    Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -headerHeight)
    Sidebar.Position = UDim2.new(0, 0, 0, headerHeight)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.ClipsDescendants = true
    Sidebar.Parent = MainContainer

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = STEALTH_NAMES.SearchBar
    SearchFrame.Size = UDim2.new(1, -12, 0, isMobile and 26 or 24)
    SearchFrame.Position = UDim2.new(0, 6, 0, 6)
    SearchFrame.BackgroundColor3 = Theme.Surface
    SearchFrame.BorderSizePixel = 0
    SearchFrame.ZIndex = 3
    SearchFrame.Parent = Sidebar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 4)
    SearchCorner.Parent = SearchFrame

    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Name = randomName(8)
    SearchIcon.Size = UDim2.new(0, 20, 1, 0)
    SearchIcon.Position = UDim2.new(0, 4, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.Font = Enum.Font.Gotham
    SearchIcon.TextSize = isMobile and 10 or 11
    SearchIcon.TextColor3 = Theme.TextMuted
    SearchIcon.ZIndex = 4
    SearchIcon.Parent = SearchFrame

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = randomName(10)
    SearchInput.Size = UDim2.new(1, -28, 1, 0)
    SearchInput.Position = UDim2.new(0, 24, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Buscar..."
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = isMobile and 9 or 10
    SearchInput.TextColor3 = Theme.Text
    SearchInput.PlaceholderColor3 = Theme.TextMuted
    SearchInput.ZIndex = 4
    SearchInput.Parent = SearchFrame

    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Name = randomName(12)
    SidebarScroll.Size = UDim2.new(1, 0, 1, -(isMobile and 38 or 36))
    SidebarScroll.Position = UDim2.new(0, 0, 0, isMobile and 36 or 34)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.BorderSizePixel = 0
    SidebarScroll.ScrollBarThickness = 2
    SidebarScroll.ScrollBarImageColor3 = Theme.Primary
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarScroll.ZIndex = 2
    SidebarScroll.Parent = Sidebar

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = SidebarScroll

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 4)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)
    SidebarPadding.Parent = SidebarScroll

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 12)
    end)

    local allCategoryButtons = {}

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, data in ipairs(allCategoryButtons) do
            if query == "" then
                data.Button.Visible = true
            else
                data.Button.Visible = data.Name:lower():find(query, 1, true) ~= nil
            end
        end
    end)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = STEALTH_NAMES.ContentArea
    ContentArea.Size = UDim2.new(1, -sidebarWidth, 1, -headerHeight)
    ContentArea.Position = UDim2.new(0, sidebarWidth, 0, headerHeight)
    ContentArea.BackgroundColor3 = Theme.Background
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainContainer

    local currentTab = nil

    function Window:Notify(config)
        CreateNotification(config)
    end

    function Window:AddGlobalKeybind(config)
        local currentKey = config.Key or Enum.KeyCode.H
        addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not Window._alive then return end
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                if config.Callback then
                    task.spawn(config.Callback)
                end
            end
        end))
        return {
            SetKey = function(self, key) currentKey = key end,
            GetKey = function(self) return currentKey end
        }
    end

    function Window:SetFlag(flag, value)
        Window.Flags[flag] = value
    end

    function Window:GetFlag(flag)
        return Window.Flags[flag]
    end

    function Window:SaveConfig(name)
        local configData = {}
        for flag, value in pairs(Window.Flags) do
            if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
                configData[flag] = value
            elseif type(value) == "table" then
                configData[flag] = value
            elseif typeof(value) == "Color3" then
                configData[flag] = {_type = "Color3", R = value.R, G = value.G, B = value.B}
            elseif typeof(value) == "EnumItem" then
                configData[flag] = {_type = "EnumItem", EnumType = tostring(value.EnumType), Name = value.Name}
            end
        end
        local encoded = HttpService:JSONEncode(configData)
        local fileName = "QuantomGG_" .. (name or "default") .. ".json"
        if writefile then
            writefile(fileName, encoded)
            CreateNotification({Title = "Config Salva", Message = "Perfil: " .. (name or "default"), Type = "Success", Duration = 3})
        end
    end

    function Window:LoadConfig(name)
        local fileName = "QuantomGG_" .. (name or "default") .. ".json"
        if readfile and isfile and isfile(fileName) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(fileName))
            end)
            if success and data then
                for flag, value in pairs(data) do
                    if type(value) == "table" and value._type == "Color3" then
                        Window.Flags[flag] = Color3.new(value.R, value.G, value.B)
                    elseif type(value) == "table" and value._type == "EnumItem" then
                        pcall(function()
                            Window.Flags[flag] = Enum[value.EnumType][value.Name]
                        end)
                    else
                        Window.Flags[flag] = value
                    end
                    if Window._elements[flag] and Window._elements[flag].SetValue then
                        pcall(function()
                            Window._elements[flag]:SetValue(Window.Flags[flag])
                        end)
                    end
                end
                CreateNotification({Title = "Config Carregada", Message = "Perfil: " .. (name or "default"), Type = "Success", Duration = 3})
            else
                CreateNotification({Title = "Erro", Message = "Falha ao carregar config", Type = "Error", Duration = 3})
            end
        else
            CreateNotification({Title = "Erro", Message = "Config nao encontrada", Type = "Error", Duration = 3})
        end
    end

    function Window:DeleteConfig(name)
        local fileName = "QuantomGG_" .. (name or "default") .. ".json"
        if delfile and isfile and isfile(fileName) then
            delfile(fileName)
            CreateNotification({Title = "Config Deletada", Message = "Perfil: " .. (name or "default"), Type = "Warning", Duration = 3})
        end
    end

    function Window:GetConfigs()
        local configs = {}
        if listfiles then
            for _, file in ipairs(listfiles("")) do
                local name = file:match("QuantomGG_(.+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
        return configs
    end

    function Window:CreateTab(config)
        local Tab = {}
        Tab.Name = config.Name or "Tab"
        Tab.Icon = config.Icon or "📁"
        Tab._badge = 0

        local catHeight = isMobile and 36 or 38

        local CategoryButton = Instance.new("TextButton")
        CategoryButton.Name = randomName(15)
        CategoryButton.Size = UDim2.new(1, 0, 0, catHeight)
        CategoryButton.BackgroundColor3 = Theme.Surface
        CategoryButton.BackgroundTransparency = 1
        CategoryButton.BorderSizePixel = 0
        CategoryButton.Text = ""
        CategoryButton.AutoButtonColor = false
        CategoryButton.LayoutOrder = config._settingsTab and 9999 or (#Window.Categories + 1)
        CategoryButton.ZIndex = 3
        CategoryButton.Parent = SidebarScroll

        table.insert(allCategoryButtons, {Button = CategoryButton, Name = Tab.Name})

        local iconSize = isMobile and 14 or 18
        local Icon = Instance.new("TextLabel")
        Icon.Name = randomName(10)
        Icon.Size = UDim2.new(0, iconSize, 0, iconSize)
        Icon.Position = UDim2.new(0, isMobile and 10 or 15, 0.5, -iconSize/2)
        Icon.BackgroundTransparency = 1
        Icon.Text = Tab.Icon
        Icon.Font = Enum.Font.GothamBold
        Icon.TextSize = isMobile and 11 or 13
        Icon.TextColor3 = Theme.TextMuted
        Icon.ZIndex = 4
        Icon.Parent = CategoryButton

        local Label = Instance.new("TextLabel")
        Label.Name = randomName(11)
        Label.Size = UDim2.new(1, isMobile and -32 or -45, 1, 0)
        Label.Position = UDim2.new(0, isMobile and 28 or 40, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = isMobile and Tab.Name:sub(1, 6) or Tab.Name
        Label.Font = Enum.Font.Gotham
        Label.TextSize = isMobile and 10 or 12
        Label.TextColor3 = Theme.TextSecondary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 4
        Label.Parent = CategoryButton

        local BadgeLabel = Instance.new("TextLabel")
        BadgeLabel.Name = randomName(9)
        BadgeLabel.Size = UDim2.new(0, 18, 0, 18)
        BadgeLabel.Position = UDim2.new(1, -24, 0.5, -9)
        BadgeLabel.BackgroundColor3 = Theme.Primary
        BadgeLabel.Text = ""
        BadgeLabel.Font = Enum.Font.GothamBold
        BadgeLabel.TextSize = 9
        BadgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        BadgeLabel.Visible = false
        BadgeLabel.ZIndex = 5
        BadgeLabel.Parent = CategoryButton

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(1, 0)
        BadgeCorner.Parent = BadgeLabel

        local Indicator = Instance.new("Frame")
        Indicator.Name = randomName(9)
        Indicator.Size = UDim2.new(0, 0, 0, catHeight)
        Indicator.Position = UDim2.new(0, 0, 0, 0)
        Indicator.BackgroundColor3 = Theme.Primary
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 3
        Indicator.Parent = CategoryButton

        local contentPadding = isMobile and 8 or 10
        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Name = randomName(16)
        ContentScroll.Size = UDim2.new(1, -contentPadding*2, 1, -contentPadding*2)
        ContentScroll.Position = UDim2.new(0, contentPadding, 0, contentPadding)
        ContentScroll.BackgroundTransparency = 1
        ContentScroll.BorderSizePixel = 0
        ContentScroll.ScrollBarThickness = isMobile and 6 or 4
        ContentScroll.ScrollBarImageColor3 = Theme.Primary
        ContentScroll.ScrollBarImageTransparency = 0.5
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentScroll.Visible = false
        ContentScroll.ZIndex = 3
        ContentScroll.Parent = ContentArea

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = randomName(14)
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.ZIndex = 3
        ContentFrame.Parent = ContentScroll

        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, isMobile and 8 or 10)
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Parent = ContentFrame

        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
        end)

        Tab.ContentScroll = ContentScroll
        Tab.ContentFrame = ContentFrame

        CategoryButton.MouseEnter:Connect(function()
            if currentTab ~= Tab then
                TweenService:Create(CategoryButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
            end
        end)

        CategoryButton.MouseLeave:Connect(function()
            if currentTab ~= Tab then
                TweenService:Create(CategoryButton, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary}):Play()
            end
        end)

        local function activateTab()
            for _, cat in pairs(Window.Categories) do
                cat.ContentScroll.Visible = false
            end
            for _, child in pairs(SidebarScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    for _, subChild in pairs(child:GetChildren()) do
                        if subChild:IsA("TextLabel") and subChild ~= BadgeLabel then
                            TweenService:Create(subChild, TweenInfo.new(0.2), {TextColor3 = subChild.Text:match("[A-Z]") and Theme.TextSecondary or Theme.TextMuted}):Play()
                        elseif subChild:IsA("Frame") and not subChild:FindFirstChildOfClass("UICorner") then
                            TweenService:Create(subChild, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, catHeight)}):Play()
                        end
                    end
                end
            end
            ContentScroll.Visible = true
            currentTab = Tab
            TweenService:Create(CategoryButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = Theme.Primary}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, catHeight)}):Play()
        end

        CategoryButton.MouseButton1Click:Connect(activateTab)

        function Tab:SetBadge(count)
            Tab._badge = count
            if count > 0 then
                BadgeLabel.Text = tostring(count)
                BadgeLabel.Visible = true
            else
                BadgeLabel.Visible = false
            end
        end

        function Tab:AddSection(title)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = randomName(13)
            SectionLabel.Size = UDim2.new(1, 0, 0, isMobile and 20 or 22)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = title:upper()
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = isMobile and 10 or 11
            SectionLabel.TextColor3 = Theme.TextMuted
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.ZIndex = 3
            SectionLabel.Parent = ContentFrame
        end

        function Tab:AddSeparator()
            local SepFrame = Instance.new("Frame")
            SepFrame.Name = randomName(10)
            SepFrame.Size = UDim2.new(1, 0, 0, 1)
            SepFrame.BackgroundColor3 = Theme.Divider
            SepFrame.BorderSizePixel = 0
            SepFrame.ZIndex = 3
            SepFrame.Parent = ContentFrame
        end

        function Tab:AddLabel(config)
            local text = type(config) == "string" and config or (config.Text or "Label")
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = randomName(12)
            LabelFrame.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
            LabelFrame.BackgroundColor3 = Theme.Surface
            LabelFrame.BorderSizePixel = 0
            LabelFrame.ZIndex = 3
            LabelFrame.Parent = ContentFrame
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 4)
            LabelCorner.Parent = LabelFrame
            local LabelText = Instance.new("TextLabel")
            LabelText.Name = randomName(11)
            LabelText.Size = UDim2.new(1, -24, 1, 0)
            LabelText.Position = UDim2.new(0, 12, 0, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = text
            LabelText.Font = Enum.Font.Gotham
            LabelText.TextSize = isMobile and 11 or 12
            LabelText.TextColor3 = Theme.TextSecondary
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.ZIndex = 4
            LabelText.Parent = LabelFrame
            return {
                SetText = function(self, newText) LabelText.Text = newText end,
                GetText = function(self) return LabelText.Text end
            }
        end

        function Tab:AddParagraph(config)
            local title = config.Title or "Info"
            local content = config.Content or ""
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Name = randomName(14)
            ParagraphFrame.Size = UDim2.new(1, 0, 0, isMobile and 70 or 65)
            ParagraphFrame.BackgroundColor3 = Theme.Surface
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.ZIndex = 3
            ParagraphFrame.Parent = ContentFrame
            local ParagraphCorner = Instance.new("UICorner")
            ParagraphCorner.CornerRadius = UDim.new(0, 4)
            ParagraphCorner.Parent = ParagraphFrame
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = randomName(11)
            TitleLabel.Size = UDim2.new(1, -24, 0, 20)
            TitleLabel.Position = UDim2.new(0, 12, 0, 6)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = isMobile and 11 or 12
            TitleLabel.TextColor3 = Theme.Text
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 4
            TitleLabel.Parent = ParagraphFrame
            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Name = randomName(13)
            ContentLabel.Size = UDim2.new(1, -24, 0, 0)
            ContentLabel.Position = UDim2.new(0, 12, 0, 26)
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Text = content
            ContentLabel.Font = Enum.Font.Gotham
            ContentLabel.TextSize = isMobile and 10 or 11
            ContentLabel.TextColor3 = Theme.TextSecondary
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            ContentLabel.TextWrapped = true
            ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
            ContentLabel.ZIndex = 4
            ContentLabel.Parent = ParagraphFrame
            task.defer(function()
                local textHeight = ContentLabel.TextBounds.Y
                ParagraphFrame.Size = UDim2.new(1, 0, 0, 32 + textHeight)
            end)
            ContentLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                ParagraphFrame.Size = UDim2.new(1, 0, 0, 32 + ContentLabel.TextBounds.Y)
            end)
            return {
                SetTitle = function(self, t) TitleLabel.Text = t end,
                SetContent = function(self, c) ContentLabel.Text = c end
            }
        end

        function Tab:AddImage(config)
            local ImageFrame = Instance.new("Frame")
            ImageFrame.Name = randomName(12)
            ImageFrame.Size = UDim2.new(1, 0, 0, config.Height or (isMobile and 120 or 150))
            ImageFrame.BackgroundColor3 = Theme.Surface
            ImageFrame.BorderSizePixel = 0
            ImageFrame.ZIndex = 3
            ImageFrame.Parent = ContentFrame
            local ImageCorner = Instance.new("UICorner")
            ImageCorner.CornerRadius = UDim.new(0, 4)
            ImageCorner.Parent = ImageFrame
            local ImageLabel = Instance.new("ImageLabel")
            ImageLabel.Name = randomName(10)
            ImageLabel.Size = UDim2.new(1, -8, 1, -8)
            ImageLabel.Position = UDim2.new(0, 4, 0, 4)
            ImageLabel.BackgroundTransparency = 1
            ImageLabel.Image = config.Image or ""
            ImageLabel.ScaleType = Enum.ScaleType.Fit
            ImageLabel.ZIndex = 4
            ImageLabel.Parent = ImageFrame
            local ImgCorner = Instance.new("UICorner")
            ImgCorner.CornerRadius = UDim.new(0, 4)
            ImgCorner.Parent = ImageLabel
            return {
                SetImage = function(self, img) ImageLabel.Image = img end
            }
        end

        function Tab:AddProgressBar(config)
            local progress = config.Default or 0
            local flag = config.Flag
            local ProgressFrame = Instance.new("Frame")
            ProgressFrame.Name = randomName(14)
            ProgressFrame.Size = UDim2.new(1, 0, 0, isMobile and 40 or 36)
            ProgressFrame.BackgroundColor3 = Theme.Surface
            ProgressFrame.BorderSizePixel = 0
            ProgressFrame.ZIndex = 3
            ProgressFrame.Parent = ContentFrame
            local ProgressCorner = Instance.new("UICorner")
            ProgressCorner.CornerRadius = UDim.new(0, 4)
            ProgressCorner.Parent = ProgressFrame
            local ProgressLabel = Instance.new("TextLabel")
            ProgressLabel.Name = randomName(11)
            ProgressLabel.Size = UDim2.new(0.5, 0, 0, 16)
            ProgressLabel.Position = UDim2.new(0, 12, 0, 4)
            ProgressLabel.BackgroundTransparency = 1
            ProgressLabel.Text = config.Name or "Progress"
            ProgressLabel.Font = Enum.Font.Gotham
            ProgressLabel.TextSize = isMobile and 10 or 11
            ProgressLabel.TextColor3 = Theme.TextSecondary
            ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
            ProgressLabel.ZIndex = 4
            ProgressLabel.Parent = ProgressFrame
            local PercentLabel = Instance.new("TextLabel")
            PercentLabel.Name = randomName(10)
            PercentLabel.Size = UDim2.new(0, 40, 0, 16)
            PercentLabel.Position = UDim2.new(1, -52, 0, 4)
            PercentLabel.BackgroundTransparency = 1
            PercentLabel.Text = progress .. "%"
            PercentLabel.Font = Enum.Font.GothamBold
            PercentLabel.TextSize = isMobile and 10 or 11
            PercentLabel.TextColor3 = Theme.Primary
            PercentLabel.TextXAlignment = Enum.TextXAlignment.Right
            PercentLabel.ZIndex = 4
            PercentLabel.Parent = ProgressFrame
            local BarTrack = Instance.new("Frame")
            BarTrack.Name = randomName(10)
            BarTrack.Size = UDim2.new(1, -24, 0, isMobile and 6 or 5)
            BarTrack.Position = UDim2.new(0, 12, 1, -10)
            BarTrack.BackgroundColor3 = Theme.Border
            BarTrack.BorderSizePixel = 0
            BarTrack.ZIndex = 4
            BarTrack.Parent = ProgressFrame
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = BarTrack
            local BarFill = Instance.new("Frame")
            BarFill.Name = randomName(9)
            BarFill.Size = UDim2.new(progress / 100, 0, 1, 0)
            BarFill.BackgroundColor3 = Theme.Primary
            BarFill.BorderSizePixel = 0
            BarFill.ZIndex = 5
            BarFill.Parent = BarTrack
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = BarFill
            local FillGradient = Instance.new("UIGradient")
            FillGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Theme.PrimaryDark),
                ColorSequenceKeypoint.new(1, Theme.Accent)
            }
            FillGradient.Parent = BarFill
            if flag then
                Window.Flags[flag] = progress
            end
            local element = {
                SetValue = function(self, value)
                    progress = math.clamp(value, 0, 100)
                    PercentLabel.Text = math.floor(progress) .. "%"
                    TweenService:Create(BarFill, TweenInfo.new(0.3), {Size = UDim2.new(progress / 100, 0, 1, 0)}):Play()
                    if flag then Window.Flags[flag] = progress end
                end,
                GetValue = function(self) return progress end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddConsole(config)
            local maxLines = config.MaxLines or 50
            local logs = {}
            local ConsoleFrame = Instance.new("Frame")
            ConsoleFrame.Name = STEALTH_NAMES.ConsoleFrame
            ConsoleFrame.Size = UDim2.new(1, 0, 0, config.Height or (isMobile and 140 or 160))
            ConsoleFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            ConsoleFrame.BorderSizePixel = 0
            ConsoleFrame.ZIndex = 3
            ConsoleFrame.Parent = ContentFrame
            local ConsoleCorner = Instance.new("UICorner")
            ConsoleCorner.CornerRadius = UDim.new(0, 4)
            ConsoleCorner.Parent = ConsoleFrame
            local ConsoleHeader = Instance.new("Frame")
            ConsoleHeader.Name = randomName(10)
            ConsoleHeader.Size = UDim2.new(1, 0, 0, 22)
            ConsoleHeader.BackgroundColor3 = Theme.Surface
            ConsoleHeader.BorderSizePixel = 0
            ConsoleHeader.ZIndex = 4
            ConsoleHeader.Parent = ConsoleFrame
            local ConsoleHeaderCorner = Instance.new("UICorner")
            ConsoleHeaderCorner.CornerRadius = UDim.new(0, 4)
            ConsoleHeaderCorner.Parent = ConsoleHeader
            local ConsoleTitle = Instance.new("TextLabel")
            ConsoleTitle.Name = randomName(9)
            ConsoleTitle.Size = UDim2.new(1, -8, 1, 0)
            ConsoleTitle.Position = UDim2.new(0, 8, 0, 0)
            ConsoleTitle.BackgroundTransparency = 1
            ConsoleTitle.Text = config.Name or "Console"
            ConsoleTitle.Font = Enum.Font.GothamBold
            ConsoleTitle.TextSize = 10
            ConsoleTitle.TextColor3 = Theme.TextMuted
            ConsoleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ConsoleTitle.ZIndex = 5
            ConsoleTitle.Parent = ConsoleHeader
            local ConsoleScroll = Instance.new("ScrollingFrame")
            ConsoleScroll.Name = randomName(12)
            ConsoleScroll.Size = UDim2.new(1, -8, 1, -28)
            ConsoleScroll.Position = UDim2.new(0, 4, 0, 24)
            ConsoleScroll.BackgroundTransparency = 1
            ConsoleScroll.BorderSizePixel = 0
            ConsoleScroll.ScrollBarThickness = 3
            ConsoleScroll.ScrollBarImageColor3 = Theme.Primary
            ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ConsoleScroll.ZIndex = 4
            ConsoleScroll.Parent = ConsoleFrame
            local ConsoleList = Instance.new("UIListLayout")
            ConsoleList.Padding = UDim.new(0, 1)
            ConsoleList.SortOrder = Enum.SortOrder.LayoutOrder
            ConsoleList.Parent = ConsoleScroll
            ConsoleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, ConsoleList.AbsoluteContentSize.Y)
                ConsoleScroll.CanvasPosition = Vector2.new(0, ConsoleList.AbsoluteContentSize.Y)
            end)
            local function addLog(text, logType)
                local color = Theme.TextSecondary
                local prefix = ""
                if logType == "warn" then
                    color = Theme.Warning
                    prefix = "[WARN] "
                elseif logType == "error" then
                    color = Theme.Error
                    prefix = "[ERR] "
                elseif logType == "success" then
                    color = Theme.Success
                    prefix = "[OK] "
                else
                    prefix = "[LOG] "
                end
                local LogLabel = Instance.new("TextLabel")
                LogLabel.Name = randomName(8)
                LogLabel.Size = UDim2.new(1, 0, 0, 14)
                LogLabel.BackgroundTransparency = 1
                LogLabel.Text = prefix .. text
                LogLabel.Font = Enum.Font.Code
                LogLabel.TextSize = isMobile and 9 or 10
                LogLabel.TextColor3 = color
                LogLabel.TextXAlignment = Enum.TextXAlignment.Left
                LogLabel.TextTruncate = Enum.TextTruncate.AtEnd
                LogLabel.ZIndex = 5
                LogLabel.LayoutOrder = #logs + 1
                LogLabel.Parent = ConsoleScroll
                table.insert(logs, LogLabel)
                if #logs > maxLines then
                    logs[1]:Destroy()
                    table.remove(logs, 1)
                end
            end
            return {
                Log = function(self, text) addLog(text, "log") end,
                Warn = function(self, text) addLog(text, "warn") end,
                Error = function(self, text) addLog(text, "error") end,
                Success = function(self, text) addLog(text, "success") end,
                Clear = function(self)
                    for _, l in ipairs(logs) do l:Destroy() end
                    logs = {}
                end
            }
        end

        function Tab:AddToggle(config)
            local toggleState = config.Default or false
            local flag = config.Flag
            local dependsOn = config.DependsOn

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = randomName(14)
            ToggleFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ToggleFrame.BackgroundColor3 = Theme.Surface
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 3
            ToggleFrame.Parent = ContentFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = randomName(12)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = config.Name or "Toggle"
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextSize = isMobile and 11 or 12
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.ZIndex = 4
            ToggleLabel.Parent = ToggleFrame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = randomName(13)
            ToggleButton.Size = UDim2.new(0, isMobile and 42 or 38, 0, isMobile and 22 or 18)
            ToggleButton.Position = UDim2.new(1, isMobile and -52 or -48, 0.5, isMobile and -11 or -9)
            ToggleButton.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.ZIndex = 4
            ToggleButton.Parent = ToggleFrame

            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleButton

            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = randomName(10)
            ToggleCircle.Size = UDim2.new(0, isMobile and 18 or 14, 0, isMobile and 18 or 14)
            ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
            ToggleCircle.BackgroundColor3 = Theme.Text
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.ZIndex = 5
            ToggleCircle.Parent = ToggleButton

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle

            if config.Tooltip then
                ToggleFrame.MouseEnter:Connect(function() showTooltip(config.Tooltip, ToggleFrame) end)
                ToggleFrame.MouseLeave:Connect(function() hideTooltip() end)
            end

            if flag then
                Window.Flags[flag] = toggleState
            end

            local function updateVisual()
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border}):Play()
                local endPos = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = endPos}):Play()
            end

            local function checkDependency()
                if dependsOn then
                    return Window.Flags[dependsOn] == true
                end
                return true
            end

            ToggleButton.MouseButton1Click:Connect(function()
                if not checkDependency() then
                    CreateNotification({Title = "Bloqueado", Message = "Ative '" .. dependsOn .. "' primeiro", Type = "Warning", Duration = 2})
                    return
                end
                toggleState = not toggleState
                if flag then Window.Flags[flag] = toggleState end
                updateVisual()
                if config.Callback then config.Callback(toggleState) end
            end)

            local element = {
                SetValue = function(self, value)
                    toggleState = value
                    if flag then Window.Flags[flag] = toggleState end
                    ToggleButton.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
                    ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
                    if config.Callback then config.Callback(toggleState) end
                end,
                GetValue = function(self) return toggleState end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddButton(config)
            local isPressed = false
            local dependsOn = config.DependsOn

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = randomName(14)
            ButtonFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ButtonFrame.BackgroundColor3 = Theme.Surface
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.ZIndex = 3
            ButtonFrame.Parent = ContentFrame

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonFrame

            local ButtonClickable = Instance.new("TextButton")
            ButtonClickable.Name = randomName(15)
            ButtonClickable.Size = UDim2.new(1, 0, 1, 0)
            ButtonClickable.BackgroundTransparency = 1
            ButtonClickable.Text = ""
            ButtonClickable.ZIndex = 5
            ButtonClickable.Parent = ButtonFrame

            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Name = randomName(12)
            ButtonLabel.Size = UDim2.new(1, -24, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 12, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = config.Name or "Button"
            ButtonLabel.Font = Enum.Font.Gotham
            ButtonLabel.TextSize = isMobile and 11 or 12
            ButtonLabel.TextColor3 = Theme.Text
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.ZIndex = 4
            ButtonLabel.Parent = ButtonFrame

            local ButtonIcon = Instance.new("TextLabel")
            ButtonIcon.Name = randomName(10)
            ButtonIcon.Size = UDim2.new(0, 16, 0, 16)
            ButtonIcon.Position = UDim2.new(1, -28, 0.5, -8)
            ButtonIcon.BackgroundTransparency = 1
            ButtonIcon.Text = "›"
            ButtonIcon.Font = Enum.Font.GothamBold
            ButtonIcon.TextSize = 20
            ButtonIcon.TextColor3 = Theme.Primary
            ButtonIcon.ZIndex = 4
            ButtonIcon.Parent = ButtonFrame

            if config.Tooltip then
                ButtonFrame.MouseEnter:Connect(function() showTooltip(config.Tooltip, ButtonFrame) end)
                ButtonFrame.MouseLeave:Connect(function() hideTooltip() end)
            end

            ButtonClickable.MouseEnter:Connect(function()
                if not isPressed then
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover}):Play()
                    TweenService:Create(ButtonIcon, TweenInfo.new(0.15), {TextColor3 = Theme.Accent}):Play()
                end
            end)

            ButtonClickable.MouseLeave:Connect(function()
                if not isPressed then
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Surface}):Play()
                    TweenService:Create(ButtonIcon, TweenInfo.new(0.15), {TextColor3 = Theme.Primary}):Play()
                end
            end)

            ButtonClickable.MouseButton1Down:Connect(function()
                isPressed = true
                TweenService:Create(ButtonFrame, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Primary}):Play()
                TweenService:Create(ButtonLabel, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(ButtonIcon, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)

            ButtonClickable.MouseButton1Up:Connect(function()
                isPressed = false
                TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Surface}):Play()
                TweenService:Create(ButtonLabel, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
                TweenService:Create(ButtonIcon, TweenInfo.new(0.15), {TextColor3 = Theme.Primary}):Play()
            end)

            local confirmPending = false
            ButtonClickable.MouseButton1Click:Connect(function()
                if dependsOn and not Window.Flags[dependsOn] then
                    CreateNotification({Title = "Bloqueado", Message = "Ative '" .. dependsOn .. "' primeiro", Type = "Warning", Duration = 2})
                    return
                end
                if config.Confirm then
                    if not confirmPending then
                        confirmPending = true
                        local origText = ButtonLabel.Text
                        ButtonLabel.Text = "Clique novamente p/ confirmar"
                        ButtonLabel.TextColor3 = Theme.Warning
                        task.delay(3, function()
                            if confirmPending then
                                confirmPending = false
                                ButtonLabel.Text = origText
                                ButtonLabel.TextColor3 = Theme.Text
                            end
                        end)
                        return
                    else
                        confirmPending = false
                        ButtonLabel.Text = config.Name or "Button"
                        ButtonLabel.TextColor3 = Theme.Text
                    end
                end
                if config.Callback then
                    task.spawn(config.Callback)
                end
            end)
        end

        function Tab:AddSlider(config)
            local sliderValue = config.Default or config.Min or 0
            local flag = config.Flag
            local dependsOn = config.DependsOn

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = randomName(14)
            SliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 46)
            SliderFrame.BackgroundColor3 = Theme.Surface
            SliderFrame.BorderSizePixel = 0
            SliderFrame.ZIndex = 3
            SliderFrame.Parent = ContentFrame

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = randomName(12)
            SliderLabel.Size = UDim2.new(0.6, 0, 0, 18)
            SliderLabel.Position = UDim2.new(0, 12, 0, 8)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = config.Name or "Slider"
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextSize = isMobile and 10 or 11
            SliderLabel.TextColor3 = Theme.TextSecondary
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.ZIndex = 4
            SliderLabel.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = randomName(11)
            ValueLabel.Size = UDim2.new(0, 40, 0, 18)
            ValueLabel.Position = UDim2.new(1, -52, 0, 8)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(sliderValue)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = isMobile and 10 or 11
            ValueLabel.TextColor3 = Theme.Primary
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.ZIndex = 4
            ValueLabel.Parent = SliderFrame

            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = randomName(13)
            SliderTrack.Size = UDim2.new(1, -24, 0, isMobile and 5 or 4)
            SliderTrack.Position = UDim2.new(0, 12, 1, -12)
            SliderTrack.BackgroundColor3 = Theme.Border
            SliderTrack.BorderSizePixel = 0
            SliderTrack.ZIndex = 4
            SliderTrack.Parent = SliderFrame

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = SliderTrack

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = randomName(11)
            SliderFill.Size = UDim2.new((sliderValue - config.Min) / (config.Max - config.Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Primary
            SliderFill.BorderSizePixel = 0
            SliderFill.ZIndex = 5
            SliderFill.Parent = SliderTrack

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill

            if config.Tooltip then
                SliderFrame.MouseEnter:Connect(function() showTooltip(config.Tooltip, SliderFrame) end)
                SliderFrame.MouseLeave:Connect(function() hideTooltip() end)
            end

            if flag then Window.Flags[flag] = sliderValue end

            local dragging = false

            local function updateSlider(input)
                local mouse = input.Position
                local pos = SliderTrack.AbsolutePosition.X
                local size = SliderTrack.AbsoluteSize.X
                local relativePos = math.clamp(mouse.X - pos, 0, size)
                local percentage = relativePos / size
                local step = config.Step or 1
                sliderValue = math.floor((config.Min + ((config.Max - config.Min) * percentage)) / step + 0.5) * step
                sliderValue = math.clamp(sliderValue, config.Min, config.Max)
                ValueLabel.Text = tostring(sliderValue)
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new((sliderValue - config.Min) / (config.Max - config.Min), 0, 1, 0)}):Play()
                if flag then Window.Flags[flag] = sliderValue end
                if config.Callback then config.Callback(sliderValue) end
            end

            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dependsOn and not Window.Flags[dependsOn] then
                        CreateNotification({Title = "Bloqueado", Message = "Ative '" .. dependsOn .. "' primeiro", Type = "Warning", Duration = 2})
                        return
                    end
                    dragging = true
                    updateSlider(input)
                end
            end)

            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            addConnection(UserInputService.InputChanged:Connect(function(input)
                if not Window._alive then return end
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end))

            local element = {
                SetValue = function(self, value)
                    sliderValue = math.clamp(value, config.Min, config.Max)
                    ValueLabel.Text = tostring(sliderValue)
                    local percentage = (sliderValue - config.Min) / (config.Max - config.Min)
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    if flag then Window.Flags[flag] = sliderValue end
                end,
                GetValue = function(self) return sliderValue end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddTextbox(config)
            local flag = config.Flag
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Name = randomName(14)
            TextboxFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            TextboxFrame.BackgroundColor3 = Theme.Surface
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.ZIndex = 3
            TextboxFrame.Parent = ContentFrame

            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 4)
            TextboxCorner.Parent = TextboxFrame

            local TextboxLabel = Instance.new("TextLabel")
            TextboxLabel.Name = randomName(12)
            TextboxLabel.Size = UDim2.new(0, 80, 1, 0)
            TextboxLabel.Position = UDim2.new(0, 12, 0, 0)
            TextboxLabel.BackgroundTransparency = 1
            TextboxLabel.Text = config.Name or "Textbox"
            TextboxLabel.Font = Enum.Font.Gotham
            TextboxLabel.TextSize = isMobile and 11 or 12
            TextboxLabel.TextColor3 = Theme.Text
            TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextboxLabel.ZIndex = 4
            TextboxLabel.Parent = TextboxFrame

            local TextboxInput = Instance.new("TextBox")
            TextboxInput.Name = randomName(13)
            TextboxInput.Size = UDim2.new(1, -110, 0, isMobile and 26 or 22)
            TextboxInput.Position = UDim2.new(0, 95, 0.5, isMobile and -13 or -11)
            TextboxInput.BackgroundColor3 = Theme.SurfaceLight
            TextboxInput.BorderSizePixel = 0
            TextboxInput.Text = config.Default or ""
            TextboxInput.PlaceholderText = config.Placeholder or "Digite aqui..."
            TextboxInput.Font = Enum.Font.Gotham
            TextboxInput.TextSize = isMobile and 10 or 11
            TextboxInput.TextColor3 = Theme.Text
            TextboxInput.PlaceholderColor3 = Theme.TextMuted
            TextboxInput.ZIndex = 4
            TextboxInput.Parent = TextboxFrame

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = TextboxInput

            if flag then Window.Flags[flag] = config.Default or "" end

            TextboxInput.FocusLost:Connect(function(enterPressed)
                if flag then Window.Flags[flag] = TextboxInput.Text end
                if config.FireOnFocusLost then
                    if config.Callback then config.Callback(TextboxInput.Text) end
                elseif enterPressed and config.Callback then
                    config.Callback(TextboxInput.Text)
                end
            end)

            local element = {
                SetValue = function(self, value)
                    TextboxInput.Text = value
                    if flag then Window.Flags[flag] = value end
                end,
                GetValue = function(self) return TextboxInput.Text end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddDropdown(config)
            local selectedOption = config.Default or (config.Options and config.Options[1]) or ""
            local dropdownOpen = false
            local flag = config.Flag

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = randomName(14)
            DropdownFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            DropdownFrame.BackgroundColor3 = Theme.Surface
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ZIndex = 3
            DropdownFrame.Parent = ContentFrame

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownFrame

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = randomName(12)
            DropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = config.Name or "Dropdown"
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextSize = isMobile and 11 or 12
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.ZIndex = 4
            DropdownLabel.Parent = DropdownFrame

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = randomName(13)
            DropdownButton.Size = UDim2.new(1, -120, 0, isMobile and 26 or 22)
            DropdownButton.Position = UDim2.new(0, 110, 0.5, isMobile and -13 or -11)
            DropdownButton.BackgroundColor3 = Theme.SurfaceLight
            DropdownButton.Text = selectedOption
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.TextSize = isMobile and 10 or 11
            DropdownButton.TextColor3 = Theme.Text
            DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            DropdownButton.AutoButtonColor = false
            DropdownButton.ZIndex = 4
            DropdownButton.Parent = DropdownFrame

            local DropdownBtnCorner = Instance.new("UICorner")
            DropdownBtnCorner.CornerRadius = UDim.new(0, 4)
            DropdownBtnCorner.Parent = DropdownButton

            local DropdownPadding = Instance.new("UIPadding")
            DropdownPadding.PaddingLeft = UDim.new(0, 8)
            DropdownPadding.Parent = DropdownButton

            local Arrow = Instance.new("TextLabel")
            Arrow.Name = randomName(8)
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -24, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = isMobile and 8 or 9
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.ZIndex = 5
            Arrow.Parent = DropdownButton

            local OptionsList = Instance.new("Frame")
            OptionsList.Name = randomName(13)
            OptionsList.Size = UDim2.new(1, -120, 0, 0)
            OptionsList.Position = UDim2.new(0, 110, 1, 4)
            OptionsList.BackgroundColor3 = Theme.SurfaceLight
            OptionsList.BorderSizePixel = 0
            OptionsList.Visible = false
            OptionsList.ZIndex = 10
            OptionsList.ClipsDescendants = true
            OptionsList.Parent = DropdownFrame

            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 4)
            OptionsCorner.Parent = OptionsList

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Parent = OptionsList

            if flag then Window.Flags[flag] = selectedOption end

            for _, option in ipairs(config.Options or {}) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = randomName(12)
                OptionButton.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
                OptionButton.BackgroundColor3 = Theme.SurfaceLight
                OptionButton.Text = option
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.TextSize = isMobile and 10 or 11
                OptionButton.TextColor3 = Theme.Text
                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                OptionButton.AutoButtonColor = false
                OptionButton.ZIndex = 11
                OptionButton.Parent = OptionsList
                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.PaddingLeft = UDim.new(0, 8)
                OptionPadding.Parent = OptionButton
                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Surface}):Play()
                end)
                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                end)
                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    DropdownButton.Text = option
                    if flag then Window.Flags[flag] = option end
                    dropdownOpen = false
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, 0)}):Play()
                    task.wait(0.2)
                    OptionsList.Visible = false
                    if config.Callback then config.Callback(option) end
                end)
            end

            DropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                if dropdownOpen then
                    OptionsList.Visible = true
                    local optionCount = #(config.Options or {})
                    local maxHeight = math.min(optionCount * (isMobile and 28 or 24), isMobile and 140 or 120)
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, maxHeight)}):Play()
                else
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, 0)}):Play()
                    task.wait(0.2)
                    OptionsList.Visible = false
                end
            end)

            local element = {
                SetValue = function(self, value)
                    selectedOption = value
                    DropdownButton.Text = value
                    if flag then Window.Flags[flag] = value end
                end,
                GetValue = function(self) return selectedOption end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddColorPicker(config)
            local currentColor = config.Default or Color3.fromRGB(255, 0, 0)
            local flag = config.Flag
            local pickerOpen = false
            local currentH, currentS, currentV = Color3.toHSV(currentColor)

            local ColorFrame = Instance.new("Frame")
            ColorFrame.Name = randomName(14)
            ColorFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ColorFrame.BackgroundColor3 = Theme.Surface
            ColorFrame.BorderSizePixel = 0
            ColorFrame.ZIndex = 3
            ColorFrame.ClipsDescendants = false
            ColorFrame.Parent = ContentFrame

            local ColorCorner = Instance.new("UICorner")
            ColorCorner.CornerRadius = UDim.new(0, 4)
            ColorCorner.Parent = ColorFrame

            local ColorLabel = Instance.new("TextLabel")
            ColorLabel.Name = randomName(11)
            ColorLabel.Size = UDim2.new(1, -60, 1, 0)
            ColorLabel.Position = UDim2.new(0, 12, 0, 0)
            ColorLabel.BackgroundTransparency = 1
            ColorLabel.Text = config.Name or "Color"
            ColorLabel.Font = Enum.Font.Gotham
            ColorLabel.TextSize = isMobile and 11 or 12
            ColorLabel.TextColor3 = Theme.Text
            ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
            ColorLabel.ZIndex = 4
            ColorLabel.Parent = ColorFrame

            local PreviewBtn = Instance.new("TextButton")
            PreviewBtn.Name = randomName(10)
            PreviewBtn.Size = UDim2.new(0, isMobile and 30 or 26, 0, isMobile and 22 or 18)
            PreviewBtn.Position = UDim2.new(1, isMobile and -40 or -36, 0.5, isMobile and -11 or -9)
            PreviewBtn.BackgroundColor3 = currentColor
            PreviewBtn.Text = ""
            PreviewBtn.AutoButtonColor = false
            PreviewBtn.ZIndex = 4
            PreviewBtn.Parent = ColorFrame

            local PreviewCorner = Instance.new("UICorner")
            PreviewCorner.CornerRadius = UDim.new(0, 4)
            PreviewCorner.Parent = PreviewBtn

            local PreviewStroke = Instance.new("UIStroke")
            PreviewStroke.Color = Theme.Border
            PreviewStroke.Thickness = 1
            PreviewStroke.Parent = PreviewBtn

            local PickerPanel = Instance.new("Frame")
            PickerPanel.Name = STEALTH_NAMES.ColorPicker
            PickerPanel.Size = UDim2.new(0, isMobile and 180 or 200, 0, isMobile and 180 or 200)
            PickerPanel.Position = UDim2.new(1, isMobile and -190 or -210, 1, 4)
            PickerPanel.BackgroundColor3 = Theme.Surface
            PickerPanel.BorderSizePixel = 0
            PickerPanel.Visible = false
            PickerPanel.ZIndex = 100
            PickerPanel.Parent = ColorFrame

            local PanelCorner = Instance.new("UICorner")
            PanelCorner.CornerRadius = UDim.new(0, 6)
            PanelCorner.Parent = PickerPanel

            local PanelStroke = Instance.new("UIStroke")
            PanelStroke.Color = Theme.Border
            PanelStroke.Thickness = 1
            PanelStroke.Parent = PickerPanel

            local svSize = isMobile and 150 or 170
            local SVField = Instance.new("ImageLabel")
            SVField.Name = randomName(10)
            SVField.Size = UDim2.new(0, svSize, 0, svSize)
            SVField.Position = UDim2.new(0, 8, 0, 8)
            SVField.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            SVField.BorderSizePixel = 0
            SVField.Image = "rbxassetid://4155801252"
            SVField.ZIndex = 101
            SVField.Parent = PickerPanel

            local SVCorner = Instance.new("UICorner")
            SVCorner.CornerRadius = UDim.new(0, 4)
            SVCorner.Parent = SVField

            local SVCursor = Instance.new("Frame")
            SVCursor.Name = randomName(8)
            SVCursor.Size = UDim2.new(0, 10, 0, 10)
            SVCursor.Position = UDim2.new(currentS, -5, 1 - currentV, -5)
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderSizePixel = 0
            SVCursor.ZIndex = 102
            SVCursor.Parent = SVField

            local SVCursorCorner = Instance.new("UICorner")
            SVCursorCorner.CornerRadius = UDim.new(1, 0)
            SVCursorCorner.Parent = SVCursor

            local SVCursorStroke = Instance.new("UIStroke")
            SVCursorStroke.Color = Color3.fromRGB(0, 0, 0)
            SVCursorStroke.Thickness = 1
            SVCursorStroke.Parent = SVCursor

            local HueBar = Instance.new("ImageLabel")
            HueBar.Name = randomName(9)
            HueBar.Size = UDim2.new(0, 14, 0, svSize)
            HueBar.Position = UDim2.new(1, -22, 0, 8)
            HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueBar.BorderSizePixel = 0
            HueBar.Image = "rbxassetid://3641079629"
            HueBar.ZIndex = 101
            HueBar.Parent = PickerPanel

            local HueCorner = Instance.new("UICorner")
            HueCorner.CornerRadius = UDim.new(0, 4)
            HueCorner.Parent = HueBar

            local HueCursor = Instance.new("Frame")
            HueCursor.Name = randomName(8)
            HueCursor.Size = UDim2.new(1, 4, 0, 4)
            HueCursor.Position = UDim2.new(0, -2, currentH, -2)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderSizePixel = 0
            HueCursor.ZIndex = 102
            HueCursor.Parent = HueBar

            local HueCursorStroke = Instance.new("UIStroke")
            HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
            HueCursorStroke.Thickness = 1
            HueCursorStroke.Parent = HueCursor

            if flag then Window.Flags[flag] = currentColor end

            local function updateColor()
                currentColor = Color3.fromHSV(currentH, currentS, currentV)
                PreviewBtn.BackgroundColor3 = currentColor
                SVField.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                SVCursor.Position = UDim2.new(currentS, -5, 1 - currentV, -5)
                HueCursor.Position = UDim2.new(0, -2, currentH, -2)
                if flag then Window.Flags[flag] = currentColor end
                if config.Callback then config.Callback(currentColor) end
            end

            local svDragging = false
            local hueDragging = false

            SVField.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                    local rel = Vector2.new(input.Position.X - SVField.AbsolutePosition.X, input.Position.Y - SVField.AbsolutePosition.Y)
                    currentS = math.clamp(rel.X / SVField.AbsoluteSize.X, 0, 1)
                    currentV = 1 - math.clamp(rel.Y / SVField.AbsoluteSize.Y, 0, 1)
                    updateColor()
                end
            end)

            SVField.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                end
            end)

            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    currentH = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    updateColor()
                end
            end)

            HueBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)

            addConnection(UserInputService.InputChanged:Connect(function(input)
                if not Window._alive then return end
                if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    if svDragging then
                        local rel = Vector2.new(input.Position.X - SVField.AbsolutePosition.X, input.Position.Y - SVField.AbsolutePosition.Y)
                        currentS = math.clamp(rel.X / SVField.AbsoluteSize.X, 0, 1)
                        currentV = 1 - math.clamp(rel.Y / SVField.AbsoluteSize.Y, 0, 1)
                        updateColor()
                    elseif hueDragging then
                        currentH = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                        updateColor()
                    end
                end
            end))

            PreviewBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                PickerPanel.Visible = pickerOpen
            end)

            local element = {
                SetValue = function(self, color)
                    currentColor = color
                    currentH, currentS, currentV = Color3.toHSV(color)
                    updateColor()
                end,
                GetValue = function(self) return currentColor end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddToggleKeybind(config)
            local toggleState = config.Default or false
            local currentKey = config.Key or Enum.KeyCode.E
            local keybindChanging = false
            local flag = config.Flag
            local blacklistedKeys = {
                Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl
            }

            local RowFrame = Instance.new("Frame")
            RowFrame.Name = randomName(14)
            RowFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            RowFrame.BackgroundColor3 = Theme.Surface
            RowFrame.BorderSizePixel = 0
            RowFrame.ZIndex = 3
            RowFrame.Parent = ContentFrame

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 4)
            RowCorner.Parent = RowFrame

            local RowLabel = Instance.new("TextLabel")
            RowLabel.Name = randomName(12)
            RowLabel.Size = UDim2.new(0.45, -12, 1, 0)
            RowLabel.Position = UDim2.new(0, 12, 0, 0)
            RowLabel.BackgroundTransparency = 1
            RowLabel.Text = config.Name or "Toggle Keybind"
            RowLabel.Font = Enum.Font.Gotham
            RowLabel.TextSize = isMobile and 11 or 12
            RowLabel.TextColor3 = Theme.Text
            RowLabel.TextXAlignment = Enum.TextXAlignment.Left
            RowLabel.TextTruncate = Enum.TextTruncate.AtEnd
            RowLabel.ZIndex = 4
            RowLabel.Parent = RowFrame

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = randomName(13)
            ToggleBtn.Size = UDim2.new(0, isMobile and 42 or 38, 0, isMobile and 22 or 18)
            ToggleBtn.Position = UDim2.new(0.5, isMobile and -21 or -19, 0.5, isMobile and -11 or -9)
            ToggleBtn.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.ZIndex = 4
            ToggleBtn.Parent = RowFrame

            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleBtn

            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = randomName(10)
            ToggleCircle.Size = UDim2.new(0, isMobile and 18 or 14, 0, isMobile and 18 or 14)
            ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
            ToggleCircle.BackgroundColor3 = Theme.Text
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.ZIndex = 5
            ToggleCircle.Parent = ToggleBtn

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Name = randomName(13)
            KeyBtn.Size = UDim2.new(0, isMobile and 72 or 68, 0, isMobile and 26 or 22)
            KeyBtn.Position = UDim2.new(1, isMobile and -82 or -78, 0.5, isMobile and -13 or -11)
            KeyBtn.BackgroundColor3 = Theme.SurfaceLight
            KeyBtn.Text = currentKey.Name
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.TextSize = isMobile and 10 or 11
            KeyBtn.TextColor3 = Theme.Primary
            KeyBtn.AutoButtonColor = false
            KeyBtn.ZIndex = 4
            KeyBtn.Parent = RowFrame

            local KeyBtnCorner = Instance.new("UICorner")
            KeyBtnCorner.CornerRadius = UDim.new(0, 6)
            KeyBtnCorner.Parent = KeyBtn

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = Theme.Primary
            KeyStroke.Thickness = 0
            KeyStroke.Transparency = 0.5
            KeyStroke.Parent = KeyBtn

            if flag then Window.Flags[flag] = toggleState end

            local function fireToggle(newState)
                toggleState = newState
                if flag then Window.Flags[flag] = toggleState end
                TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border}):Play()
                local endPos = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = endPos}):Play()
                if config.Callback then config.Callback(toggleState) end
                UpdateKeybindList()
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                fireToggle(not toggleState)
            end)

            KeyBtn.MouseEnter:Connect(function()
                if not keybindChanging then
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceHover}):Play()
                    TweenService:Create(KeyStroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
                end
            end)

            KeyBtn.MouseLeave:Connect(function()
                if not keybindChanging then
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                    TweenService:Create(KeyStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
                end
            end)

            KeyBtn.MouseButton1Click:Connect(function()
                if keybindChanging then return end
                keybindChanging = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = Theme.Warning
                TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
                TweenService:Create(KeyStroke, TweenInfo.new(0.2), {Thickness = 2, Color = Theme.Warning}):Play()
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    local key = input.KeyCode
                    local isBlacklisted = false
                    for _, bl in ipairs(blacklistedKeys) do
                        if key == bl then isBlacklisted = true; break end
                    end
                    if isBlacklisted then
                        CreateNotification({Title = "Keybind Invalido", Message = "Essa tecla nao pode ser usada!", Type = "Error", Duration = 2})
                        KeyBtn.Text = currentKey.Name
                    else
                        currentKey = key
                        KeyBtn.Text = key.Name
                        KeyBtn.TextColor3 = Theme.Success
                        CreateNotification({Title = "Keybind Alterado", Message = "Nova tecla: " .. key.Name, Type = "Success", Duration = 2})
                        if config.KeyChanged then config.KeyChanged(key) end
                        task.wait(0.5)
                    end
                    KeyBtn.TextColor3 = Theme.Primary
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                    TweenService:Create(KeyStroke, TweenInfo.new(0.2), {Thickness = 0, Color = Theme.Primary}):Play()
                    keybindChanging = false
                    conn:Disconnect()
                end)
            end)

            addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not Window._alive then return end
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    TweenService:Create(KeyBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, (isMobile and 72 or 68) + 5, 0, (isMobile and 26 or 22) + 5)}):Play()
                    task.wait(0.1)
                    TweenService:Create(KeyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, isMobile and 72 or 68, 0, isMobile and 26 or 22)}):Play()
                    fireToggle(not toggleState)
                end
            end))

            local element = {
                SetValue = function(self, value)
                    fireToggle(value)
                end,
                SetToggle = function(self, value) fireToggle(value) end,
                SetKey = function(self, key)
                    currentKey = key
                    KeyBtn.Text = key.Name
                    UpdateKeybindList()
                end,
                GetValue = function(self) return toggleState end,
                GetState = function(self) return toggleState end,
                GetKey = function(self) return currentKey end,
            }
            if flag then Window._elements[flag] = element end
            RegisterKeybindEntry(
                config.Name or "Toggle Keybind",
                function() return toggleState end,
                function() return currentKey end
            )
            return element
        end

        function Tab:AddMultiDropdown(config)
            local selectedOptions = {}
            local dropdownOpen = false
            local flag = config.Flag

            if config.Default then
                for _, v in ipairs(config.Default) do
                    selectedOptions[v] = true
                end
            end

            local function getSelectedText()
                local count, lastName = 0, ""
                for k in pairs(selectedOptions) do count = count + 1; lastName = k end
                if count == 0 then return config.Placeholder or "Selecionar..." end
                if count == 1 then return lastName end
                return count .. " selecionados"
            end

            local function getSelectedList()
                local result = {}
                for k in pairs(selectedOptions) do table.insert(result, k) end
                return result
            end

            local MultiFrame = Instance.new("Frame")
            MultiFrame.Name = randomName(14)
            MultiFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            MultiFrame.BackgroundColor3 = Theme.Surface
            MultiFrame.BorderSizePixel = 0
            MultiFrame.ZIndex = 3
            MultiFrame.Parent = ContentFrame

            local MultiCorner = Instance.new("UICorner")
            MultiCorner.CornerRadius = UDim.new(0, 4)
            MultiCorner.Parent = MultiFrame

            local MultiLabel = Instance.new("TextLabel")
            MultiLabel.Name = randomName(12)
            MultiLabel.Size = UDim2.new(0, 100, 1, 0)
            MultiLabel.Position = UDim2.new(0, 12, 0, 0)
            MultiLabel.BackgroundTransparency = 1
            MultiLabel.Text = config.Name or "Multi"
            MultiLabel.Font = Enum.Font.Gotham
            MultiLabel.TextSize = isMobile and 11 or 12
            MultiLabel.TextColor3 = Theme.Text
            MultiLabel.TextXAlignment = Enum.TextXAlignment.Left
            MultiLabel.ZIndex = 4
            MultiLabel.Parent = MultiFrame

            local MultiBtn = Instance.new("TextButton")
            MultiBtn.Name = randomName(13)
            MultiBtn.Size = UDim2.new(1, -120, 0, isMobile and 26 or 22)
            MultiBtn.Position = UDim2.new(0, 110, 0.5, isMobile and -13 or -11)
            MultiBtn.BackgroundColor3 = Theme.SurfaceLight
            MultiBtn.Text = getSelectedText()
            MultiBtn.Font = Enum.Font.Gotham
            MultiBtn.TextSize = isMobile and 10 or 11
            MultiBtn.TextColor3 = Theme.Text
            MultiBtn.TextXAlignment = Enum.TextXAlignment.Left
            MultiBtn.AutoButtonColor = false
            MultiBtn.ZIndex = 4
            MultiBtn.Parent = MultiFrame

            local MultiBtnCorner = Instance.new("UICorner")
            MultiBtnCorner.CornerRadius = UDim.new(0, 4)
            MultiBtnCorner.Parent = MultiBtn

            local MultiBtnPadding = Instance.new("UIPadding")
            MultiBtnPadding.PaddingLeft = UDim.new(0, 8)
            MultiBtnPadding.Parent = MultiBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Name = randomName(8)
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -24, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = isMobile and 8 or 9
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.ZIndex = 5
            Arrow.Parent = MultiBtn

            local OptionsList = Instance.new("Frame")
            OptionsList.Name = randomName(13)
            OptionsList.Size = UDim2.new(1, -120, 0, 0)
            OptionsList.Position = UDim2.new(0, 110, 1, 4)
            OptionsList.BackgroundColor3 = Theme.SurfaceLight
            OptionsList.BorderSizePixel = 0
            OptionsList.Visible = false
            OptionsList.ZIndex = 10
            OptionsList.ClipsDescendants = true
            OptionsList.Parent = MultiFrame

            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 4)
            OptionsCorner.Parent = OptionsList

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Parent = OptionsList

            if flag then Window.Flags[flag] = getSelectedList() end

            local optionBtns = {}

            local function updateOptionBtn(option, btn)
                local sel = selectedOptions[option]
                btn.Text = (sel and "✓  " or "    ") .. option
                TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = sel and Theme.Primary or Theme.Text, BackgroundColor3 = sel and Theme.SurfaceHover or Theme.SurfaceLight}):Play()
            end

            for _, option in ipairs(config.Options or {}) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Name = randomName(12)
                OptionBtn.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
                OptionBtn.BackgroundColor3 = selectedOptions[option] and Theme.SurfaceHover or Theme.SurfaceLight
                OptionBtn.Text = (selectedOptions[option] and "✓  " or "    ") .. option
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.TextSize = isMobile and 10 or 11
                OptionBtn.TextColor3 = selectedOptions[option] and Theme.Primary or Theme.Text
                OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptionBtn.AutoButtonColor = false
                OptionBtn.ZIndex = 11
                OptionBtn.Parent = OptionsList
                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.PaddingLeft = UDim.new(0, 8)
                OptionPadding.Parent = OptionBtn
                optionBtns[option] = OptionBtn
                OptionBtn.MouseButton1Click:Connect(function()
                    if selectedOptions[option] then selectedOptions[option] = nil else selectedOptions[option] = true end
                    updateOptionBtn(option, OptionBtn)
                    MultiBtn.Text = getSelectedText()
                    if flag then Window.Flags[flag] = getSelectedList() end
                    if config.Callback then config.Callback(getSelectedList()) end
                end)
            end

            MultiBtn.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                if dropdownOpen then
                    OptionsList.Visible = true
                    local optionCount = #(config.Options or {})
                    local maxHeight = math.min(optionCount * (isMobile and 28 or 24), isMobile and 140 or 120)
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, maxHeight)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                else
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, 0)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    task.wait(0.2)
                    OptionsList.Visible = false
                end
            end)

            local element = {
                SetValue = function(self, values)
                    selectedOptions = {}
                    for _, v in ipairs(values) do selectedOptions[v] = true end
                    MultiBtn.Text = getSelectedText()
                    for opt, btn in pairs(optionBtns) do updateOptionBtn(opt, btn) end
                    if flag then Window.Flags[flag] = getSelectedList() end
                end,
                SetValues = function(self, values)
                    selectedOptions = {}
                    for _, v in ipairs(values) do selectedOptions[v] = true end
                    MultiBtn.Text = getSelectedText()
                    for opt, btn in pairs(optionBtns) do updateOptionBtn(opt, btn) end
                    if flag then Window.Flags[flag] = getSelectedList() end
                end,
                GetValue = function(self) return getSelectedList() end,
                GetValues = function(self) return getSelectedList() end,
                AddOption = function(self, option)
                    if not optionBtns[option] then
                        table.insert(config.Options, option)
                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Name = randomName(12)
                        OptionBtn.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
                        OptionBtn.BackgroundColor3 = Theme.SurfaceLight
                        OptionBtn.Text = "    " .. option
                        OptionBtn.Font = Enum.Font.Gotham
                        OptionBtn.TextSize = isMobile and 10 or 11
                        OptionBtn.TextColor3 = Theme.Text
                        OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptionBtn.AutoButtonColor = false
                        OptionBtn.ZIndex = 11
                        OptionBtn.Parent = OptionsList
                        local OptionPadding = Instance.new("UIPadding")
                        OptionPadding.PaddingLeft = UDim.new(0, 8)
                        OptionPadding.Parent = OptionBtn
                        optionBtns[option] = OptionBtn
                        OptionBtn.MouseButton1Click:Connect(function()
                            if selectedOptions[option] then selectedOptions[option] = nil else selectedOptions[option] = true end
                            updateOptionBtn(option, OptionBtn)
                            MultiBtn.Text = getSelectedText()
                            if flag then Window.Flags[flag] = getSelectedList() end
                            if config.Callback then config.Callback(getSelectedList()) end
                        end)
                    end
                end,
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        function Tab:AddKeybind(config)
            local currentKey = config.Default or Enum.KeyCode.E
            local flag = config.Flag
            local blacklistedKeys = {
                Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl
            }
            local keybindChanging = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = randomName(14)
            KeybindFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            KeybindFrame.BackgroundColor3 = Theme.Surface
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.ZIndex = 3
            KeybindFrame.Parent = ContentFrame

            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 6)
            KeybindCorner.Parent = KeybindFrame

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Name = randomName(12)
            KeybindLabel.Size = UDim2.new(0.55, 0, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 12, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = config.Name or "Keybind"
            KeybindLabel.Font = Enum.Font.GothamMedium
            KeybindLabel.TextSize = isMobile and 11 or 12
            KeybindLabel.TextColor3 = Theme.Text
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.ZIndex = 4
            KeybindLabel.Parent = KeybindFrame

            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Name = randomName(13)
            KeybindButton.Size = UDim2.new(0, isMobile and 75 or 70, 0, isMobile and 26 or 22)
            KeybindButton.Position = UDim2.new(1, isMobile and -85 or -80, 0.5, isMobile and -13 or -11)
            KeybindButton.BackgroundColor3 = Theme.SurfaceLight
            KeybindButton.Text = currentKey.Name
            KeybindButton.Font = Enum.Font.GothamBold
            KeybindButton.TextSize = isMobile and 10 or 11
            KeybindButton.TextColor3 = Theme.Primary
            KeybindButton.AutoButtonColor = false
            KeybindButton.ZIndex = 4
            KeybindButton.Parent = KeybindFrame

            local KeybindBtnCorner = Instance.new("UICorner")
            KeybindBtnCorner.CornerRadius = UDim.new(0, 6)
            KeybindBtnCorner.Parent = KeybindButton

            local KeybindStroke = Instance.new("UIStroke")
            KeybindStroke.Color = Theme.Primary
            KeybindStroke.Thickness = 0
            KeybindStroke.Transparency = 0.5
            KeybindStroke.Parent = KeybindButton

            KeybindButton.MouseEnter:Connect(function()
                if not keybindChanging then
                    TweenService:Create(KeybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceHover}):Play()
                    TweenService:Create(KeybindStroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
                end
            end)

            KeybindButton.MouseLeave:Connect(function()
                if not keybindChanging then
                    TweenService:Create(KeybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                    TweenService:Create(KeybindStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
                end
            end)

            KeybindButton.MouseButton1Click:Connect(function()
                if keybindChanging then return end
                keybindChanging = true
                KeybindButton.Text = "..."
                KeybindButton.TextColor3 = Theme.Warning
                TweenService:Create(KeybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
                TweenService:Create(KeybindStroke, TweenInfo.new(0.2), {Thickness = 2, Color = Theme.Warning}):Play()
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        local isBlacklisted = false
                        for _, blacklisted in ipairs(blacklistedKeys) do
                            if key == blacklisted then isBlacklisted = true; break end
                        end
                        if isBlacklisted then
                            CreateNotification({Title = "Keybind Invalido", Message = "Essa tecla nao pode ser usada!", Type = "Error", Duration = 2})
                            KeybindButton.Text = currentKey.Name
                            KeybindButton.TextColor3 = Theme.Primary
                        else
                            currentKey = key
                            KeybindButton.Text = key.Name
                            if config.KeyChanged then config.KeyChanged(key) end
                            KeybindButton.TextColor3 = Theme.Success
                            CreateNotification({Title = "Keybind Alterado", Message = "Nova tecla: " .. key.Name, Type = "Success", Duration = 2})
                            task.wait(0.5)
                            KeybindButton.TextColor3 = Theme.Primary
                        end
                        TweenService:Create(KeybindButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                        TweenService:Create(KeybindStroke, TweenInfo.new(0.2), {Thickness = 0, Color = Theme.Primary}):Play()
                        keybindChanging = false
                        connection:Disconnect()
                    end
                end)
            end)

            addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not Window._alive then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    if not gameProcessed and config.Callback then
                        TweenService:Create(KeybindButton, TweenInfo.new(0.1), {Size = UDim2.new(0, (isMobile and 75 or 70) + 5, 0, (isMobile and 26 or 22) + 5)}):Play()
                        task.wait(0.1)
                        TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, isMobile and 75 or 70, 0, isMobile and 26 or 22)}):Play()
                        config.Callback()
                    end
                end
            end))

            local element = {
                SetValue = function(self, key) currentKey = key; KeybindButton.Text = key.Name end,
                SetKey = function(self, key) currentKey = key; KeybindButton.Text = key.Name end,
                GetValue = function(self) return currentKey end,
                GetKey = function(self) return currentKey end
            }
            if flag then Window._elements[flag] = element end
            return element
        end

        table.insert(Window.Categories, Tab)

        if #Window.Categories == 1 then
            task.wait(0.1)
            activateTab()
        end

        return Tab
    end

    function Window:Show()
        MainContainer.Visible = true
        MainContainer.Size = UDim2.new(0, uiWidth * 0.9, 0, uiHeight * 0.9)
        MainContainer.BackgroundTransparency = 0.5
        TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, uiWidth, 0, uiHeight),
            BackgroundTransparency = 0
        }):Play()
        if isMobile then FloatingButton.Visible = false end
    end

    function Window:Hide()
        TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, uiWidth * 0.9, 0, uiHeight * 0.9),
            BackgroundTransparency = 0.5
        }):Play()
        task.wait(0.2)
        MainContainer.Visible = false
        if isMobile then FloatingButton.Visible = true end
    end

    function Window:Toggle()
        if MainContainer.Visible then
            Window:Hide()
        else
            Window:Show()
        end
    end

    function Window:Destroy()
        Window._alive = false
        for _, conn in ipairs(Window._connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        Window._connections = {}
        if WatermarkData.Connection then
            WatermarkData.Connection:Disconnect()
            WatermarkData.Connection = nil
        end
        if WatermarkData.Frame then
            WatermarkData.Frame:Destroy()
            WatermarkData.Frame = nil
        end
        if NotificationContainer then
            NotificationContainer:Destroy()
            NotificationContainer = nil
        end
        NotificationQueue = {}
        if KeybindListData.Frame then
            KeybindListData.Frame:Destroy()
            KeybindListData.Frame = nil
        end
        KeybindListData.Entries = {}
        KeybindListData.Labels = {}
        ScreenGui:Destroy()
    end

    addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not Window._alive then return end
        if not gameProcessed and input.KeyCode == minimizeKey then
            Window:Toggle()
        end
    end))

    task.defer(function()
        local SettingsTab = Window:CreateTab({Name = "Config", Icon = "⚙", _settingsTab = true})

        SettingsTab:AddSection("Watermark")
        SettingsTab:AddToggle({
            Name = "Mostrar Watermark",
            Default = false,
            Flag = "watermark_visible",
            Callback = function(state)
                if state then
                    ShowWatermark(ScreenGui)
                else
                    HideWatermark()
                end
            end
        })

        SettingsTab:AddSection("Keybind List")
        SettingsTab:AddToggle({
            Name = "Mostrar Keybinds Ativos",
            Default = false,
            Flag = "keybindlist_visible",
            Tooltip = "Mostra um painel com todos os toggles ativos e suas teclas",
            Callback = function(state)
                if state then
                    ShowKeybindList(ScreenGui)
                else
                    HideKeybindList()
                end
            end
        })

        SettingsTab:AddSection("Aparencia")
        SettingsTab:AddDropdown({
            Name = "Tema",
            Options = {"Dark", "Purple", "Red", "Green", "Rose"},
            Default = "Dark",
            Flag = "ui_theme",
            Callback = function(theme)
                QuantomLib:SetTheme(theme)
                CreateNotification({Title = "Tema Alterado", Message = "Reinicie a UI para aplicar: " .. theme, Type = "Info", Duration = 3})
            end
        })

        SettingsTab:AddSection("Atalhos")
        SettingsTab:AddKeybind({
            Name = "Minimizar / Abrir",
            Default = minimizeKey,
            KeyChanged = function(newKey)
                minimizeKey = newKey
            end,
        })

        SettingsTab:AddSection("Perfis")

        local profileInput = ""
        SettingsTab:AddTextbox({
            Name = "Nome",
            Placeholder = "Nome do perfil...",
            FireOnFocusLost = true,
            Callback = function(text) profileInput = text end
        })

        SettingsTab:AddButton({
            Name = "Salvar Config",
            Callback = function()
                if profileInput ~= "" then
                    Window:SaveConfig(profileInput)
                else
                    Window:SaveConfig("default")
                end
            end
        })

        SettingsTab:AddButton({
            Name = "Carregar Config",
            Callback = function()
                if profileInput ~= "" then
                    Window:LoadConfig(profileInput)
                else
                    Window:LoadConfig("default")
                end
            end
        })

        SettingsTab:AddButton({
            Name = "Deletar Config",
            Confirm = true,
            Callback = function()
                if profileInput ~= "" then
                    Window:DeleteConfig(profileInput)
                else
                    Window:DeleteConfig("default")
                end
            end
        })

        SettingsTab:AddSeparator()

        SettingsTab:AddButton({
            Name = "Destruir UI",
            Confirm = true,
            Callback = function()
                Window:Destroy()
            end
        })
    end)

    return Window
end

return QuantomLib
