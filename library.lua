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
    Watermark = randomName(13)
}

local Theme = {
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
}

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

    TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    }):Play()

    TweenService:Create(TitleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MessageLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(IconLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(CloseButton, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    local duration = config.Duration or 5

    local timeBarTween = TweenService:Create(TimeBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    })
    timeBarTween:Play()

    local function closeNotification()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0, 0),
            BackgroundTransparency = 1
        }):Play()

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

    task.spawn(function()
        while WatermarkFrame and WatermarkFrame.Parent do
            TweenService:Create(AccentGradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(1, 0)
            }):Play()
            task.wait(3)
            TweenService:Create(AccentGradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Offset = Vector2.new(-1, 0)
            }):Play()
            task.wait(3)
        end
    end)

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
            WatermarkFrame.Position = UDim2.new(
                wmStartPos.X.Scale,
                wmStartPos.X.Offset + delta.X,
                wmStartPos.Y.Scale,
                wmStartPos.Y.Offset + delta.Y
            )
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
    TweenService:Create(WatermarkData.Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15
    }):Play()

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

    TweenService:Create(WatermarkData.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()

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

function QuantomLib:CreateWindow(config)
    local Window = {}
    Window.Name = config.Name or "QUANTOM.GG"
    Window.Version = config.Version or "v1.0.0"
    Window.Categories = {}
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

    local RegisteredKeybinds = {}
    local KeybindListVisible = false
    local KeybindListFrame = nil
    local KeybindListRowContainer = nil

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
    MainContainer.ClipsDescendants = false
    MainContainer.Visible = false
    MainContainer.Parent = ScreenGui

    local ClipFrame = Instance.new("Frame")
    ClipFrame.Name = randomName(10)
    ClipFrame.Size = UDim2.new(1, 0, 1, 0)
    ClipFrame.BackgroundColor3 = Theme.Background
    ClipFrame.BorderSizePixel = 0
    ClipFrame.ClipsDescendants = true
    ClipFrame.ZIndex = 1
    ClipFrame.Parent = MainContainer

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
    MainCorner.Parent = ClipFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainContainer

    local MainOuterCorner = Instance.new("UICorner")
    MainOuterCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
    MainOuterCorner.Parent = MainContainer

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

    local floatTween = TweenService:Create(FloatingButton,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.new(0, (isMobile and 60 or 50) + 5, 0, (isMobile and 60 or 50) + 5)}
    )
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

    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            if delta.Magnitude > 5 then
                floatDragMoved = true
            end
            FloatingButton.Position = UDim2.new(
                floatStartPos.X.Scale,
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale,
                floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

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
    BackgroundEffects.Parent = ClipFrame

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

        local floatTime = math.random(8, 15)
        local endPos = UDim2.new(math.random(), 0, math.random(), 0)
        local tween = TweenService:Create(particle,
            TweenInfo.new(floatTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Position = endPos, BackgroundTransparency = math.random(85, 95) / 100}
        )
        tween:Play()
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
        while MainContainer.Parent do
            TweenService:Create(bgGradient, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = bgGradient.Rotation + 180
            }):Play()
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
    Header.Parent = ClipFrame

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

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                MainContainer.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
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
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.SurfaceHover,
            TextColor3 = Theme.Text
        }):Play()
    end)

    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Surface,
            TextColor3 = Theme.TextMuted
        }):Play()
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
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 50, 50),
            TextColor3 = Theme.Text
        }):Play()
    end)

    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Surface,
            TextColor3 = Theme.TextMuted
        }):Play()
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
    Sidebar.Parent = ClipFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = STEALTH_NAMES.ContentArea
    ContentArea.Size = UDim2.new(1, -sidebarWidth, 1, -headerHeight)
    ContentArea.Position = UDim2.new(0, sidebarWidth, 0, headerHeight)
    ContentArea.BackgroundColor3 = Theme.Background
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ZIndex = 2
    ContentArea.Parent = ClipFrame

    local DropdownOverlay = Instance.new("Frame")
    DropdownOverlay.Name = randomName(12)
    DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
    DropdownOverlay.BackgroundTransparency = 1
    DropdownOverlay.BorderSizePixel = 0
    DropdownOverlay.ZIndex = 50
    DropdownOverlay.Parent = MainContainer

    local currentOpenDropdown = nil

    local currentTab = nil

    local function BuildKeybindListUI()
        if KeybindListFrame then
            KeybindListFrame:Destroy()
            KeybindListFrame = nil
        end

        local kw = isMobile and math.min(uiWidth - 20, 340) or 420
        local kh = isMobile and 320 or 380

        local Overlay = Instance.new("Frame")
        Overlay.Name = randomName(12)
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.BorderSizePixel = 0
        Overlay.ZIndex = 200
        Overlay.Parent = MainContainer

        local KBFrame = Instance.new("Frame")
        KBFrame.Name = randomName(14)
        KBFrame.Size = UDim2.new(0, kw, 0, kh)
        KBFrame.Position = UDim2.new(0.5, -kw/2, 0.5, -kh/2)
        KBFrame.BackgroundColor3 = Theme.Surface
        KBFrame.BorderSizePixel = 0
        KBFrame.ZIndex = 201
        KBFrame.Parent = MainContainer

        local KBCorner = Instance.new("UICorner")
        KBCorner.CornerRadius = UDim.new(0, 8)
        KBCorner.Parent = KBFrame

        local KBStroke = Instance.new("UIStroke")
        KBStroke.Color = Theme.Primary
        KBStroke.Thickness = 1
        KBStroke.Transparency = 0.4
        KBStroke.Parent = KBFrame

        local KBAccent = Instance.new("Frame")
        KBAccent.Size = UDim2.new(1, 0, 0, 2)
        KBAccent.BackgroundColor3 = Theme.Primary
        KBAccent.BorderSizePixel = 0
        KBAccent.ZIndex = 202
        KBAccent.Parent = KBFrame
        local KBAccentCorner = Instance.new("UICorner")
        KBAccentCorner.CornerRadius = UDim.new(0, 8)
        KBAccentCorner.Parent = KBAccent

        local KBHeader = Instance.new("Frame")
        KBHeader.Name = randomName(10)
        KBHeader.Size = UDim2.new(1, 0, 0, isMobile and 44 or 42)
        KBHeader.BackgroundColor3 = Theme.Sidebar
        KBHeader.BorderSizePixel = 0
        KBHeader.ZIndex = 202
        KBHeader.Parent = KBFrame

        local KBHeaderCorner = Instance.new("UICorner")
        KBHeaderCorner.CornerRadius = UDim.new(0, 8)
        KBHeaderCorner.Parent = KBHeader

        local KBHeaderFix = Instance.new("Frame")
        KBHeaderFix.Size = UDim2.new(1, 0, 0, 8)
        KBHeaderFix.Position = UDim2.new(0, 0, 1, -8)
        KBHeaderFix.BackgroundColor3 = Theme.Sidebar
        KBHeaderFix.BorderSizePixel = 0
        KBHeaderFix.ZIndex = 202
        KBHeaderFix.Parent = KBHeader

        local KBIconBadge = Instance.new("Frame")
        KBIconBadge.Size = UDim2.new(0, 26, 0, 26)
        KBIconBadge.Position = UDim2.new(0, 14, 0.5, -13)
        KBIconBadge.BackgroundColor3 = Theme.Primary
        KBIconBadge.BackgroundTransparency = 0.7
        KBIconBadge.BorderSizePixel = 0
        KBIconBadge.ZIndex = 203
        KBIconBadge.Parent = KBHeader
        local KBIconBadgeCorner = Instance.new("UICorner")
        KBIconBadgeCorner.CornerRadius = UDim.new(0, 5)
        KBIconBadgeCorner.Parent = KBIconBadge
        local KBIconLabel = Instance.new("TextLabel")
        KBIconLabel.Size = UDim2.new(1, 0, 1, 0)
        KBIconLabel.BackgroundTransparency = 1
        KBIconLabel.Text = "⌨"
        KBIconLabel.Font = Enum.Font.GothamBold
        KBIconLabel.TextSize = isMobile and 13 or 14
        KBIconLabel.TextColor3 = Theme.Primary
        KBIconLabel.ZIndex = 204
        KBIconLabel.Parent = KBIconBadge

        local KBTitle = Instance.new("TextLabel")
        KBTitle.Size = UDim2.new(1, -100, 1, 0)
        KBTitle.Position = UDim2.new(0, 48, 0, 0)
        KBTitle.BackgroundTransparency = 1
        KBTitle.Text = "KEYBIND LIST"
        KBTitle.Font = Enum.Font.GothamBold
        KBTitle.TextSize = isMobile and 12 or 13
        KBTitle.TextColor3 = Theme.Text
        KBTitle.TextXAlignment = Enum.TextXAlignment.Left
        KBTitle.ZIndex = 203
        KBTitle.Parent = KBHeader

        local KBCount = Instance.new("TextLabel")
        KBCount.Size = UDim2.new(0, 60, 0, 20)
        KBCount.Position = UDim2.new(0, 48, 0.5, -10)
        KBCount.BackgroundTransparency = 1
        KBCount.Text = #RegisteredKeybinds .. " atalhos"
        KBCount.Font = Enum.Font.Gotham
        KBCount.TextSize = isMobile and 9 or 10
        KBCount.TextColor3 = Theme.TextMuted
        KBCount.TextXAlignment = Enum.TextXAlignment.Left
        KBCount.ZIndex = 203
        KBCount.Parent = KBHeader

        KBTitle.Size = UDim2.new(1, -100, 0, 18)
        KBTitle.Position = UDim2.new(0, 48, 0, 8)
        KBCount.Position = UDim2.new(0, 48, 0, 26)

        local KBClose = Instance.new("TextButton")
        KBClose.Size = UDim2.new(0, 28, 0, 28)
        KBClose.Position = UDim2.new(1, -38, 0.5, -14)
        KBClose.BackgroundColor3 = Theme.Surface
        KBClose.Text = "×"
        KBClose.Font = Enum.Font.GothamBold
        KBClose.TextSize = isMobile and 18 or 16
        KBClose.TextColor3 = Theme.TextMuted
        KBClose.AutoButtonColor = false
        KBClose.ZIndex = 203
        KBClose.Parent = KBHeader

        local KBCloseCorner = Instance.new("UICorner")
        KBCloseCorner.CornerRadius = UDim.new(0, 4)
        KBCloseCorner.Parent = KBClose

        KBClose.MouseEnter:Connect(function()
            TweenService:Create(KBClose, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,50,50), TextColor3 = Theme.Text}):Play()
        end)
        KBClose.MouseLeave:Connect(function()
            TweenService:Create(KBClose, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextMuted}):Play()
        end)

        local ColHeader = Instance.new("Frame")
        ColHeader.Name = randomName(10)
        ColHeader.Size = UDim2.new(1, 0, 0, isMobile and 26 or 24)
        ColHeader.Position = UDim2.new(0, 0, 0, isMobile and 44 or 42)
        ColHeader.BackgroundColor3 = Theme.Background
        ColHeader.BackgroundTransparency = 0.3
        ColHeader.BorderSizePixel = 0
        ColHeader.ZIndex = 202
        ColHeader.Parent = KBFrame

        local ColPad = Instance.new("UIPadding")
        ColPad.PaddingLeft = UDim.new(0, 16)
        ColPad.PaddingRight = UDim.new(0, 16)
        ColPad.Parent = ColHeader

        local ColFunction = Instance.new("TextLabel")
        ColFunction.Size = UDim2.new(0.6, 0, 1, 0)
        ColFunction.BackgroundTransparency = 1
        ColFunction.Text = "FUNÇÃO"
        ColFunction.Font = Enum.Font.GothamBold
        ColFunction.TextSize = isMobile and 9 or 10
        ColFunction.TextColor3 = Theme.TextMuted
        ColFunction.TextXAlignment = Enum.TextXAlignment.Left
        ColFunction.ZIndex = 203
        ColFunction.Parent = ColHeader

        local ColKey = Instance.new("TextLabel")
        ColKey.Size = UDim2.new(0.4, 0, 1, 0)
        ColKey.Position = UDim2.new(0.6, 0, 0, 0)
        ColKey.BackgroundTransparency = 1
        ColKey.Text = "TECLA"
        ColKey.Font = Enum.Font.GothamBold
        ColKey.TextSize = isMobile and 9 or 10
        ColKey.TextColor3 = Theme.TextMuted
        ColKey.TextXAlignment = Enum.TextXAlignment.Right
        ColKey.ZIndex = 203
        ColKey.Parent = ColHeader

        local ColDiv = Instance.new("Frame")
        ColDiv.Size = UDim2.new(1, -32, 0, 1)
        ColDiv.Position = UDim2.new(0, 16, 1, 0)
        ColDiv.BackgroundColor3 = Theme.Divider
        ColDiv.BorderSizePixel = 0
        ColDiv.ZIndex = 202
        ColDiv.Parent = ColHeader

        local topOffset = (isMobile and 44 or 42) + (isMobile and 26 or 24) + 1
        local KBScroll = Instance.new("ScrollingFrame")
        KBScroll.Name = randomName(13)
        KBScroll.Size = UDim2.new(1, 0, 1, -topOffset - (isMobile and 44 or 42))
        KBScroll.Position = UDim2.new(0, 0, 0, topOffset)
        KBScroll.BackgroundTransparency = 1
        KBScroll.BorderSizePixel = 0
        KBScroll.ScrollBarThickness = isMobile and 4 or 3
        KBScroll.ScrollBarImageColor3 = Theme.Primary
        KBScroll.ScrollBarImageTransparency = 0.4
        KBScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        KBScroll.ZIndex = 202
        KBScroll.Parent = KBFrame

        local KBList = Instance.new("UIListLayout")
        KBList.SortOrder = Enum.SortOrder.LayoutOrder
        KBList.Parent = KBScroll

        KBList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            KBScroll.CanvasSize = UDim2.new(0, 0, 0, KBList.AbsoluteContentSize.Y)
        end)

        KeybindListRowContainer = KBScroll

        for i, kb in ipairs(RegisteredKeybinds) do
            local rowH = isMobile and 38 or 34
            local Row = Instance.new("Frame")
            Row.Name = randomName(10)
            Row.Size = UDim2.new(1, 0, 0, rowH)
            Row.BackgroundColor3 = i % 2 == 0 and Theme.Surface or Theme.Background
            Row.BackgroundTransparency = i % 2 == 0 and 0 or 0.5
            Row.BorderSizePixel = 0
            Row.LayoutOrder = i
            Row.ZIndex = 203
            Row.Parent = KBScroll

            local RowPad = Instance.new("UIPadding")
            RowPad.PaddingLeft = UDim.new(0, 16)
            RowPad.PaddingRight = UDim.new(0, 16)
            RowPad.Parent = Row

            local RowName = Instance.new("TextLabel")
            RowName.Size = UDim2.new(0.55, 0, 1, 0)
            RowName.BackgroundTransparency = 1
            RowName.Text = kb.Name
            RowName.Font = Enum.Font.Gotham
            RowName.TextSize = isMobile and 10 or 11
            RowName.TextColor3 = Theme.TextSecondary
            RowName.TextXAlignment = Enum.TextXAlignment.Left
            RowName.TextTruncate = Enum.TextTruncate.AtEnd
            RowName.ZIndex = 204
            RowName.Parent = Row

            local KeyBadge = Instance.new("Frame")
            KeyBadge.Name = randomName(8)
            KeyBadge.Size = UDim2.new(0, isMobile and 70 or 80, 0, isMobile and 22 or 20)
            KeyBadge.Position = UDim2.new(1, -(isMobile and 70 or 80), 0.5, isMobile and -11 or -10)
            KeyBadge.BackgroundColor3 = Theme.SurfaceLight
            KeyBadge.BorderSizePixel = 0
            KeyBadge.ZIndex = 204
            KeyBadge.Parent = Row

            local KeyBadgeCorner = Instance.new("UICorner")
            KeyBadgeCorner.CornerRadius = UDim.new(0, 4)
            KeyBadgeCorner.Parent = KeyBadge

            local KeyBadgeStroke = Instance.new("UIStroke")
            KeyBadgeStroke.Color = Theme.Border
            KeyBadgeStroke.Thickness = 1
            KeyBadgeStroke.Parent = KeyBadge

            local KeyText = Instance.new("TextLabel")
            KeyText.Name = randomName(9)
            KeyText.Size = UDim2.new(1, 0, 1, 0)
            KeyText.BackgroundTransparency = 1
            KeyText.Font = Enum.Font.GothamBold
            KeyText.TextSize = isMobile and 9 or 10
            KeyText.TextColor3 = Theme.Primary
            KeyText.ZIndex = 205
            KeyText.Parent = KeyBadge

            local function refreshKey()
                local keyName = kb.GetKey and kb.GetKey() or "?"
                KeyText.Text = keyName
                if keyName:find("Shift") or keyName:find("Alt") or keyName:find("Control") then
                    KeyText.TextColor3 = Theme.Warning
                elseif keyName:find("Mouse") then
                    KeyText.TextColor3 = Theme.Info
                else
                    KeyText.TextColor3 = Theme.Primary
                end
            end
            refreshKey()
            task.spawn(function()
                while KeyBadge and KeyBadge.Parent do
                    refreshKey()
                    task.wait(0.5)
                end
            end)

            if i < #RegisteredKeybinds then
                local RowDiv = Instance.new("Frame")
                RowDiv.Size = UDim2.new(1, -32, 0, 1)
                RowDiv.Position = UDim2.new(0, 16, 1, -1)
                RowDiv.BackgroundColor3 = Theme.Divider
                RowDiv.BackgroundTransparency = 0.5
                RowDiv.BorderSizePixel = 0
                RowDiv.ZIndex = 204
                RowDiv.Parent = Row
            end
        end

        if #RegisteredKeybinds == 0 then
            local EmptyLabel = Instance.new("TextLabel")
            EmptyLabel.Size = UDim2.new(1, 0, 0, 60)
            EmptyLabel.Position = UDim2.new(0, 0, 0, 10)
            EmptyLabel.BackgroundTransparency = 1
            EmptyLabel.Text = "Nenhum keybind registrado"
            EmptyLabel.Font = Enum.Font.Gotham
            EmptyLabel.TextSize = isMobile and 10 or 11
            EmptyLabel.TextColor3 = Theme.TextMuted
            EmptyLabel.ZIndex = 203
            EmptyLabel.Parent = KBScroll
        end

        local KBFooter = Instance.new("Frame")
        KBFooter.Name = randomName(10)
        KBFooter.Size = UDim2.new(1, 0, 0, isMobile and 38 or 36)
        KBFooter.Position = UDim2.new(0, 0, 1, -(isMobile and 38 or 36))
        KBFooter.BackgroundColor3 = Theme.Sidebar
        KBFooter.BorderSizePixel = 0
        KBFooter.ZIndex = 202
        KBFooter.Parent = KBFrame

        local KBFooterCorner = Instance.new("UICorner")
        KBFooterCorner.CornerRadius = UDim.new(0, 8)
        KBFooterCorner.Parent = KBFooter

        local KBFooterFix = Instance.new("Frame")
        KBFooterFix.Size = UDim2.new(1, 0, 0, 8)
        KBFooterFix.BackgroundColor3 = Theme.Sidebar
        KBFooterFix.BorderSizePixel = 0
        KBFooterFix.ZIndex = 202
        KBFooterFix.Parent = KBFooter

        local KBTip = Instance.new("TextLabel")
        KBTip.Size = UDim2.new(1, -20, 1, 0)
        KBTip.Position = UDim2.new(0, 10, 0, 0)
        KBTip.BackgroundTransparency = 1
        KBTip.Text = "💡 Clique em um keybind no Config para alterar a tecla"
        KBTip.Font = Enum.Font.Gotham
        KBTip.TextSize = isMobile and 9 or 10
        KBTip.TextColor3 = Theme.TextMuted
        KBTip.TextXAlignment = Enum.TextXAlignment.Left
        KBTip.ZIndex = 203
        KBTip.Parent = KBFooter

        KBFrame.BackgroundTransparency = 1
        KBFrame.Position = UDim2.new(0.5, -kw/2, 0.5, -kh/2 + 20)
        Overlay.BackgroundTransparency = 1
        TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(KBFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -kw/2, 0.5, -kh/2)
        }):Play()

        local function closeKeybindList()
            KeybindListVisible = false
            TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(KBFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -kw/2, 0.5, -kh/2 + 15)
            }):Play()
            task.delay(0.2, function()
                Overlay:Destroy()
                KBFrame:Destroy()
                KeybindListFrame = nil
            end)
        end

        KBClose.MouseButton1Click:Connect(closeKeybindList)
        Overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                closeKeybindList()
            end
        end)

        KeybindListFrame = KBFrame
    end

    function Window:Notify(config)
        CreateNotification(config)
    end

    function Window:CreateTab(config)
        local Tab = {}
        Tab.Name = config.Name or "Tab"
        Tab.Icon = config.Icon or "📁"

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
        CategoryButton.Parent = Sidebar

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
            if currentOpenDropdown then
                currentOpenDropdown()
                currentOpenDropdown = nil
            end

            for _, cat in pairs(Window.Categories) do
                cat.ContentScroll.Visible = false
            end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    for _, subChild in pairs(child:GetChildren()) do
                        if subChild:IsA("TextLabel") then
                            TweenService:Create(subChild, TweenInfo.new(0.2), {
                                TextColor3 = subChild.Text:match("[A-Z]") and Theme.TextSecondary or Theme.TextMuted
                            }):Play()
                        elseif subChild:IsA("Frame") then
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

        function Tab:AddToggle(config)
            local toggleState = config.Default or false

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

            ToggleButton.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
                }):Play()

                local endPos = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = endPos}):Play()

                if config.Callback then
                    config.Callback(toggleState)
                end
            end)

            return {
                SetValue = function(self, value)
                    toggleState = value
                    ToggleButton.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
                    ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
                end
            }
        end

        function Tab:AddButton(config)
            local isPressed = false

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

            ButtonClickable.MouseButton1Click:Connect(function()
                if config.Callback then
                    task.spawn(config.Callback)
                end
            end)
        end

        function Tab:AddSlider(config)
            local sliderValue = config.Default or config.Min or 0

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

            local dragging = false

            local function updateSlider(input)
                local mouse = input.Position
                local pos = SliderTrack.AbsolutePosition.X
                local size = SliderTrack.AbsoluteSize.X
                local relativePos = math.clamp(mouse.X - pos, 0, size)
                local percentage = relativePos / size
                sliderValue = math.floor(config.Min + ((config.Max - config.Min) * percentage))

                ValueLabel.Text = tostring(sliderValue)
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()

                if config.Callback then
                    config.Callback(sliderValue)
                end
            end

            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)

            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            return {
                SetValue = function(self, value)
                    sliderValue = math.clamp(value, config.Min, config.Max)
                    ValueLabel.Text = tostring(sliderValue)
                    local percentage = (sliderValue - config.Min) / (config.Max - config.Min)
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                end
            }
        end

        function Tab:AddTextbox(config)
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

            TextboxInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and config.Callback then
                    config.Callback(TextboxInput.Text)
                end
            end)

            return {
                SetValue = function(self, value)
                    TextboxInput.Text = value
                end
            }
        end

        function Tab:AddDropdown(config)
            local selectedOption = config.Default or (config.Options and config.Options[1]) or ""
            local dropdownOpen = false
            local optionsListFrame = nil

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

            DropdownButton.MouseEnter:Connect(function()
                TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover}):Play()
            end)
            DropdownButton.MouseLeave:Connect(function()
                if not dropdownOpen then
                    TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                end
            end)

            local function closeDropdown()
                if not dropdownOpen then return end
                dropdownOpen = false
                TweenService:Create(Arrow, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
                TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceLight}):Play()
                if optionsListFrame then
                    TweenService:Create(optionsListFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundTransparency = 1
                    }):Play()
                    for _, c in ipairs(optionsListFrame:GetDescendants()) do
                        if c:IsA("TextLabel") or c:IsA("TextButton") then
                            TweenService:Create(c, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
                        end
                    end
                    task.delay(0.15, function()
                        if optionsListFrame then
                            optionsListFrame:Destroy()
                            optionsListFrame = nil
                        end
                    end)
                end
                if currentOpenDropdown == closeDropdown then
                    currentOpenDropdown = nil
                end
            end

            local function openDropdown()
                if currentOpenDropdown and currentOpenDropdown ~= closeDropdown then
                    currentOpenDropdown()
                end

                dropdownOpen = true
                currentOpenDropdown = closeDropdown

                TweenService:Create(Arrow, TweenInfo.new(0.2), {TextColor3 = Theme.Primary}):Play()
                TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover}):Play()

                local optionCount = #(config.Options or {})
                local optionH = isMobile and 28 or 26
                local maxVisible = isMobile and 4 or 5
                local listH = math.min(optionCount, maxVisible) * optionH + 2

                local abs = DropdownButton.AbsolutePosition
                local mainAbs = MainContainer.AbsolutePosition
                local relX = abs.X - mainAbs.X
                local relY = abs.Y - mainAbs.Y + (isMobile and 26 or 22) + 4
                local listW = DropdownButton.AbsoluteSize.X

                local spaceBelow = uiHeight - (relY)
                if spaceBelow < listH + 10 then
                    relY = (abs.Y - mainAbs.Y) - listH - 4
                end

                optionsListFrame = Instance.new("Frame")
                optionsListFrame.Name = randomName(13)
                optionsListFrame.Size = UDim2.new(0, listW, 0, listH)
                optionsListFrame.Position = UDim2.new(0, relX, 0, relY)
                optionsListFrame.BackgroundColor3 = Theme.SurfaceLight
                optionsListFrame.BorderSizePixel = 0
                optionsListFrame.BackgroundTransparency = 1
                optionsListFrame.ZIndex = 51
                optionsListFrame.ClipsDescendants = true
                optionsListFrame.Parent = DropdownOverlay

                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 5)
                OptionsCorner.Parent = optionsListFrame

                local OptionsStroke = Instance.new("UIStroke")
                OptionsStroke.Color = Theme.Border
                OptionsStroke.Thickness = 1
                OptionsStroke.Transparency = 0.3
                OptionsStroke.Parent = optionsListFrame

                local OptionsScroll = Instance.new("ScrollingFrame")
                OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
                OptionsScroll.BackgroundTransparency = 1
                OptionsScroll.BorderSizePixel = 0
                OptionsScroll.ScrollBarThickness = optionCount > maxVisible and (isMobile and 4 or 3) or 0
                OptionsScroll.ScrollBarImageColor3 = Theme.Primary
                OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionCount * optionH)
                OptionsScroll.ZIndex = 52
                OptionsScroll.Parent = optionsListFrame

                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsScroll

                for idx, option in ipairs(config.Options or {}) do
                    local isSelected = option == selectedOption

                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = randomName(12)
                    OptionButton.Size = UDim2.new(1, 0, 0, optionH)
                    OptionButton.BackgroundColor3 = isSelected and Theme.Primary or Theme.SurfaceLight
                    OptionButton.BackgroundTransparency = isSelected and 0.7 or 0
                    OptionButton.Text = ""
                    OptionButton.AutoButtonColor = false
                    OptionButton.LayoutOrder = idx
                    OptionButton.ZIndex = 53
                    OptionButton.Parent = OptionsScroll

                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 10)
                    OptionPadding.PaddingRight = UDim.new(0, 8)
                    OptionPadding.Parent = OptionButton

                    local OptionText = Instance.new("TextLabel")
                    OptionText.Size = UDim2.new(1, isSelected and -20 or 0, 1, 0)
                    OptionText.BackgroundTransparency = 1
                    OptionText.Text = option
                    OptionText.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                    OptionText.TextSize = isMobile and 10 or 11
                    OptionText.TextColor3 = isSelected and Theme.Primary or Theme.Text
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.TextTransparency = 1
                    OptionText.ZIndex = 54
                    OptionText.Parent = OptionButton

                    if isSelected then
                        local CheckMark = Instance.new("TextLabel")
                        CheckMark.Size = UDim2.new(0, 16, 1, 0)
                        CheckMark.Position = UDim2.new(1, -20, 0, 0)
                        CheckMark.BackgroundTransparency = 1
                        CheckMark.Text = "✓"
                        CheckMark.Font = Enum.Font.GothamBold
                        CheckMark.TextSize = isMobile and 10 or 11
                        CheckMark.TextColor3 = Theme.Primary
                        CheckMark.TextTransparency = 1
                        CheckMark.ZIndex = 54
                        CheckMark.Parent = OptionButton
                        TweenService:Create(CheckMark, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
                    end

                    if idx < optionCount then
                        local Divider = Instance.new("Frame")
                        Divider.Size = UDim2.new(1, -16, 0, 1)
                        Divider.Position = UDim2.new(0, 8, 1, -1)
                        Divider.BackgroundColor3 = Theme.Border
                        Divider.BackgroundTransparency = 0.5
                        Divider.BorderSizePixel = 0
                        Divider.ZIndex = 53
                        Divider.Parent = OptionButton
                    end

                    TweenService:Create(OptionText, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

                    OptionButton.MouseEnter:Connect(function()
                        if option ~= selectedOption then
                            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SurfaceHover, BackgroundTransparency = 0}):Play()
                        end
                    end)
                    OptionButton.MouseLeave:Connect(function()
                        if option ~= selectedOption then
                            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.SurfaceLight, BackgroundTransparency = 0}):Play()
                        end
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        DropdownButton.Text = option
                        closeDropdown()
                        if config.Callback then
                            config.Callback(option)
                        end
                    end)
                end

                TweenService:Create(optionsListFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0
                }):Play()
            end

            DropdownButton.MouseButton1Click:Connect(function()
                if dropdownOpen then
                    closeDropdown()
                else
                    openDropdown()
                end
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownOpen then
                    task.wait()
                    if optionsListFrame and not optionsListFrame:IsAncestorOf(UserInputService:GetFocusedTextBox() or Instance.new("Part")) then
                        local mousePos = UserInputService:GetMouseLocation()
                        if optionsListFrame then
                            local abs = optionsListFrame.AbsolutePosition
                            local sz  = optionsListFrame.AbsoluteSize
                            if mousePos.X < abs.X or mousePos.X > abs.X + sz.X or
                               mousePos.Y < abs.Y or mousePos.Y > abs.Y + sz.Y then
                                closeDropdown()
                            end
                        end
                    end
                end
            end)

            return {
                SetValue = function(self, value)
                    selectedOption = value
                    DropdownButton.Text = value
                end,
                GetValue = function(self)
                    return selectedOption
                end
            }
        end

        function Tab:AddKeybind(config)
            local currentKey = config.Default or Enum.KeyCode.E
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
                            CreateNotification({Title = "Keybind Inválido", Message = "Essa tecla não pode ser usada!", Type = "Error", Duration = 2})
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

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    if not gameProcessed and config.Callback then
                        TweenService:Create(KeybindButton, TweenInfo.new(0.1), {
                            Size = UDim2.new(0, (isMobile and 75 or 70) + 5, 0, (isMobile and 26 or 22) + 5)
                        }):Play()
                        task.wait(0.1)
                        TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {
                            Size = UDim2.new(0, isMobile and 75 or 70, 0, isMobile and 26 or 22)
                        }):Play()
                        config.Callback()
                    end
                end
            end)

            if not config._internal then
                table.insert(RegisteredKeybinds, {
                    Name = config.Name or "Keybind",
                    GetKey = function()
                        return currentKey.Name
                    end
                })
            end

            return {
                SetKey = function(self, key)
                    currentKey = key
                    KeybindButton.Text = key.Name
                end,
                GetKey = function(self)
                    return currentKey
                end
            }
        end

        function Tab:AddColorPicker(config)
            local h, s, v = (config.Default or Color3.fromRGB(255,255,255)):ToHSV()
            local a = config.Alpha or 1
            local pickerOpen = false
            local draggingSV = false
            local draggingHue = false
            local draggingAlpha = false

            local PickerRow = Instance.new("Frame")
            PickerRow.Name = randomName(14)
            PickerRow.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            PickerRow.BackgroundColor3 = Theme.Surface
            PickerRow.BorderSizePixel = 0
            PickerRow.ZIndex = 3
            PickerRow.Parent = ContentFrame

            local PickerRowCorner = Instance.new("UICorner")
            PickerRowCorner.CornerRadius = UDim.new(0, 4)
            PickerRowCorner.Parent = PickerRow

            local PickerLabel = Instance.new("TextLabel")
            PickerLabel.Name = randomName(12)
            PickerLabel.Size = UDim2.new(1, -60, 1, 0)
            PickerLabel.Position = UDim2.new(0, 12, 0, 0)
            PickerLabel.BackgroundTransparency = 1
            PickerLabel.Text = config.Name or "Color"
            PickerLabel.Font = Enum.Font.Gotham
            PickerLabel.TextSize = isMobile and 11 or 12
            PickerLabel.TextColor3 = Theme.Text
            PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
            PickerLabel.ZIndex = 4
            PickerLabel.Parent = PickerRow

            local ColorBtn = Instance.new("TextButton")
            ColorBtn.Name = randomName(13)
            ColorBtn.Size = UDim2.new(0, isMobile and 42 or 36, 0, isMobile and 22 or 18)
            ColorBtn.Position = UDim2.new(1, isMobile and -52 or -46, 0.5, isMobile and -11 or -9)
            ColorBtn.BackgroundColor3 = Color3.fromHSV(h, s, v)
            ColorBtn.Text = ""
            ColorBtn.AutoButtonColor = false
            ColorBtn.ZIndex = 4
            ColorBtn.Parent = PickerRow

            local ColorBtnCorner = Instance.new("UICorner")
            ColorBtnCorner.CornerRadius = UDim.new(0, 4)
            ColorBtnCorner.Parent = ColorBtn

            local ColorBtnStroke = Instance.new("UIStroke")
            ColorBtnStroke.Color = Theme.Border
            ColorBtnStroke.Thickness = 1
            ColorBtnStroke.Parent = ColorBtn

            local pickerW = isMobile and 220 or 240
            local pickerH = isMobile and 230 or 245

            local PickerPopup = Instance.new("Frame")
            PickerPopup.Name = randomName(15)
            PickerPopup.Size = UDim2.new(0, pickerW, 0, pickerH)
            PickerPopup.BackgroundColor3 = Theme.Surface
            PickerPopup.BorderSizePixel = 0
            PickerPopup.Visible = false
            PickerPopup.ZIndex = 100
            PickerPopup.Parent = ContentScroll

            local PopupCorner = Instance.new("UICorner")
            PopupCorner.CornerRadius = UDim.new(0, 6)
            PopupCorner.Parent = PickerPopup

            local PopupStroke = Instance.new("UIStroke")
            PopupStroke.Color = Theme.Border
            PopupStroke.Thickness = 1
            PopupStroke.Transparency = 0.3
            PopupStroke.Parent = PickerPopup

            local svSize = isMobile and 160 or 175
            local SVBox = Instance.new("Frame")
            SVBox.Name = randomName(12)
            SVBox.Size = UDim2.new(0, svSize, 0, svSize)
            SVBox.Position = UDim2.new(0, 10, 0, 10)
            SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVBox.BorderSizePixel = 0
            SVBox.ZIndex = 101
            SVBox.ClipsDescendants = true
            SVBox.Parent = PickerPopup

            local SVCorner = Instance.new("UICorner")
            SVCorner.CornerRadius = UDim.new(0, 4)
            SVCorner.Parent = SVBox

            local WhiteGrad = Instance.new("UIGradient")
            WhiteGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
            }
            WhiteGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            }
            WhiteGrad.Rotation = 0
            WhiteGrad.Parent = SVBox

            local BlackLayer = Instance.new("Frame")
            BlackLayer.Name = randomName(10)
            BlackLayer.Size = UDim2.new(1, 0, 1, 0)
            BlackLayer.BackgroundColor3 = Color3.fromRGB(0,0,0)
            BlackLayer.BorderSizePixel = 0
            BlackLayer.ZIndex = 102
            BlackLayer.Parent = SVBox

            local BlackGrad = Instance.new("UIGradient")
            BlackGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
            }
            BlackGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            }
            BlackGrad.Rotation = 270
            BlackGrad.Parent = BlackLayer

            local SVHandle = Instance.new("Frame")
            SVHandle.Name = randomName(9)
            SVHandle.Size = UDim2.new(0, 10, 0, 10)
            SVHandle.AnchorPoint = Vector2.new(0.5, 0.5)
            SVHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            SVHandle.BorderSizePixel = 0
            SVHandle.ZIndex = 103
            SVHandle.Parent = SVBox

            local SVHandleCorner = Instance.new("UICorner")
            SVHandleCorner.CornerRadius = UDim.new(1, 0)
            SVHandleCorner.Parent = SVHandle

            local SVHandleStroke = Instance.new("UIStroke")
            SVHandleStroke.Color = Color3.fromRGB(0,0,0)
            SVHandleStroke.Thickness = 1
            SVHandleStroke.Parent = SVHandle

            local hueBarW = isMobile and 16 or 18
            local HueBar = Instance.new("Frame")
            HueBar.Name = randomName(11)
            HueBar.Size = UDim2.new(0, hueBarW, 0, svSize)
            HueBar.Position = UDim2.new(0, svSize + 16, 0, 10)
            HueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
            HueBar.BorderSizePixel = 0
            HueBar.ZIndex = 101
            HueBar.ClipsDescendants = true
            HueBar.Parent = PickerPopup

            local HueCorner = Instance.new("UICorner")
            HueCorner.CornerRadius = UDim.new(0, 4)
            HueCorner.Parent = HueBar

            local HueGrad = Instance.new("UIGradient")
            HueGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   0)),
            }
            HueGrad.Rotation = 90
            HueGrad.Parent = HueBar

            local HueHandle = Instance.new("Frame")
            HueHandle.Name = randomName(9)
            HueHandle.Size = UDim2.new(1, 4, 0, 4)
            HueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
            HueHandle.Position = UDim2.new(0.5, 0, 1 - h, 0)
            HueHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            HueHandle.BorderSizePixel = 0
            HueHandle.ZIndex = 102
            HueHandle.Parent = HueBar

            local HueHandleCorner = Instance.new("UICorner")
            HueHandleCorner.CornerRadius = UDim.new(0, 2)
            HueHandleCorner.Parent = HueHandle

            local alphaBarY = svSize + 20
            local AlphaBar = Instance.new("Frame")
            AlphaBar.Name = randomName(11)
            AlphaBar.Size = UDim2.new(0, svSize + hueBarW + 6, 0, hueBarW)
            AlphaBar.Position = UDim2.new(0, 10, 0, alphaBarY)
            AlphaBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
            AlphaBar.BorderSizePixel = 0
            AlphaBar.ZIndex = 101
            AlphaBar.ClipsDescendants = true
            AlphaBar.Parent = PickerPopup

            local AlphaCorner = Instance.new("UICorner")
            AlphaCorner.CornerRadius = UDim.new(0, 4)
            AlphaCorner.Parent = AlphaBar

            local CheckerLabel = Instance.new("TextLabel")
            CheckerLabel.Size = UDim2.new(1,0,1,0)
            CheckerLabel.BackgroundTransparency = 1
            CheckerLabel.Text = ""
            CheckerLabel.ZIndex = 101
            CheckerLabel.Parent = AlphaBar

            local AlphaColor = Instance.new("Frame")
            AlphaColor.Size = UDim2.new(1,0,1,0)
            AlphaColor.BackgroundColor3 = Color3.fromHSV(h,s,v)
            AlphaColor.BorderSizePixel = 0
            AlphaColor.ZIndex = 102
            AlphaColor.Parent = AlphaBar

            local AlphaGrad = Instance.new("UIGradient")
            AlphaGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            }
            AlphaGrad.Parent = AlphaColor

            local AlphaHandle = Instance.new("Frame")
            AlphaHandle.Name = randomName(9)
            AlphaHandle.Size = UDim2.new(0, 4, 1, 4)
            AlphaHandle.AnchorPoint = Vector2.new(0.5, 0.5)
            AlphaHandle.Position = UDim2.new(a, 0, 0.5, 0)
            AlphaHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            AlphaHandle.BorderSizePixel = 0
            AlphaHandle.ZIndex = 103
            AlphaHandle.Parent = AlphaBar

            local AlphaHandleCorner = Instance.new("UICorner")
            AlphaHandleCorner.CornerRadius = UDim.new(0, 2)
            AlphaHandleCorner.Parent = AlphaHandle

            local previewY = alphaBarY + hueBarW + 10
            local PreviewRow = Instance.new("Frame")
            PreviewRow.Name = randomName(10)
            PreviewRow.Size = UDim2.new(1, -20, 0, isMobile and 22 or 20)
            PreviewRow.Position = UDim2.new(0, 10, 0, previewY)
            PreviewRow.BackgroundTransparency = 1
            PreviewRow.ZIndex = 101
            PreviewRow.Parent = PickerPopup

            local PreviewSwatch = Instance.new("Frame")
            PreviewSwatch.Name = randomName(10)
            PreviewSwatch.Size = UDim2.new(0, isMobile and 36 or 32, 1, 0)
            PreviewSwatch.BackgroundColor3 = Color3.fromHSV(h,s,v)
            PreviewSwatch.BorderSizePixel = 0
            PreviewSwatch.ZIndex = 102
            PreviewSwatch.Parent = PreviewRow

            local PreviewSwatchCorner = Instance.new("UICorner")
            PreviewSwatchCorner.CornerRadius = UDim.new(0, 4)
            PreviewSwatchCorner.Parent = PreviewSwatch

            local HexLabel = Instance.new("TextLabel")
            HexLabel.Name = randomName(11)
            HexLabel.Size = UDim2.new(1, -(isMobile and 46 or 42), 1, 0)
            HexLabel.Position = UDim2.new(0, isMobile and 42 or 38, 0, 0)
            HexLabel.BackgroundTransparency = 1
            HexLabel.Font = Enum.Font.GothamBold
            HexLabel.TextSize = isMobile and 10 or 11
            HexLabel.TextColor3 = Theme.TextSecondary
            HexLabel.TextXAlignment = Enum.TextXAlignment.Left
            HexLabel.ZIndex = 102
            HexLabel.Parent = PreviewRow

            local function getColor()
                return Color3.fromHSV(h, s, v)
            end

            local function updateAll()
                local col = getColor()
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVHandle.Position = UDim2.new(s, 0, 1 - v, 0)
                HueHandle.Position = UDim2.new(0.5, 0, 1 - h, 0)
                AlphaHandle.Position = UDim2.new(a, 0, 0.5, 0)
                AlphaColor.BackgroundColor3 = col
                ColorBtn.BackgroundColor3 = col
                PreviewSwatch.BackgroundColor3 = col
                HexLabel.Text = "#" .. col:ToHex():upper() .. string.format("  A:%.0f%%", a * 100)
                if config.Callback then config.Callback(col, a) end
            end

            updateAll()

            local function updateFromSVInput(input)
                local rel = input.Position - SVBox.AbsolutePosition
                s = math.clamp(rel.X / SVBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp(rel.Y / SVBox.AbsoluteSize.Y, 0, 1)
                updateAll()
            end

            local function updateFromHueInput(input)
                local rel = input.Position.Y - HueBar.AbsolutePosition.Y
                h = 1 - math.clamp(rel / HueBar.AbsoluteSize.Y, 0, 1)
                updateAll()
            end

            local function updateFromAlphaInput(input)
                local rel = input.Position.X - AlphaBar.AbsolutePosition.X
                a = math.clamp(rel / AlphaBar.AbsoluteSize.X, 0, 1)
                updateAll()
            end

            BlackLayer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = true
                    updateFromSVInput(input)
                end
            end)

            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                    updateFromHueInput(input)
                end
            end)

            AlphaBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingAlpha = true
                    updateFromAlphaInput(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = false
                    draggingHue = false
                    draggingAlpha = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingSV then updateFromSVInput(input)
                    elseif draggingHue then updateFromHueInput(input)
                    elseif draggingAlpha then updateFromAlphaInput(input) end
                end
            end)

            ColorBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    local abs = ColorBtn.AbsolutePosition
                    local scrollAbs = ContentScroll.AbsolutePosition
                    local relX = abs.X - scrollAbs.X
                    local relY = abs.Y - scrollAbs.Y + ContentScroll.CanvasPosition.Y + (isMobile and 36 or 32) + 4
                    PickerPopup.Position = UDim2.new(0, math.clamp(relX, 0, ContentScroll.AbsoluteSize.X - pickerW - 4), 0, relY)
                    PickerPopup.Visible = true
                    TweenService:Create(PickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
                else
                    TweenService:Create(PickerPopup, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                    task.wait(0.15)
                    PickerPopup.Visible = false
                end
            end)

            return {
                SetValue = function(self, color, alpha)
                    if color then h, s, v = color:ToHSV() end
                    if alpha then a = alpha end
                    updateAll()
                end,
                GetValue = function(self)
                    return getColor(), a
                end
            }
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
        if isMobile then
            FloatingButton.Visible = false
        end
    end

    function Window:Hide()
        MainContainer.Visible = false
        if isMobile then
            FloatingButton.Visible = true
        end
    end

    function Window:Toggle()
        MainContainer.Visible = not MainContainer.Visible
        if isMobile then
            FloatingButton.Visible = not MainContainer.Visible
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == minimizeKey then
            Window:Toggle()
        end
    end)

    task.defer(function()
        local SettingsTab = Window:CreateTab({Name = "Config", Icon = "⚙", _settingsTab = true})

        SettingsTab:AddSection("Watermark")
        SettingsTab:AddToggle({
            Name = "Mostrar Watermark",
            Default = false,
            Callback = function(state)
                if state then
                    ShowWatermark(ScreenGui)
                else
                    HideWatermark()
                end
            end
        })

        SettingsTab:AddSection("Atalhos do Script")
        SettingsTab:AddKeybind({
            Name = "Minimizar / Abrir",
            Default = minimizeKey,
            _internal = true,
            KeyChanged = function(newKey)
                minimizeKey = newKey
            end,
        })

        SettingsTab:AddSection("Lista de Keybinds")
        SettingsTab:AddButton({
            Name = "Ver Keybind List",
            Callback = function()
                if KeybindListVisible then return end
                KeybindListVisible = true
                BuildKeybindListUI()
            end
        })
    end)

    return Window
end

return QuantomLib
