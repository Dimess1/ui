local QuantomLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewportSize = workspace.CurrentCamera.ViewportSize

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
    NotificationContainer.Name = "QuantomNotifications"
    NotificationContainer.Size = UDim2.new(0, isMobile and 280 or 320, 0, 0)
    NotificationContainer.Position = UDim2.new(1, -(isMobile and 290 or 330), 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 9999
    NotificationContainer.Parent = PlayerGui:FindFirstChild("QuantomUI") or PlayerGui

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
    LeftAccent.Size = UDim2.new(0, 4, 1, 0)
    LeftAccent.Position = UDim2.new(0, 0, 0, 0)
    LeftAccent.BackgroundColor3 = notifColor
    LeftAccent.BorderSizePixel = 0
    LeftAccent.ZIndex = 10001
    LeftAccent.Parent = NotificationFrame

    local IconFrame = Instance.new("Frame")
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
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = notifIcon
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = isMobile and 16 or 18
    IconLabel.TextColor3 = notifColor
    IconLabel.ZIndex = 10002
    IconLabel.Parent = IconFrame

    local TitleLabel = Instance.new("TextLabel")
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

function QuantomLib:CreateWindow(config)
    local Window = {}
    Window.Name = config.Name or "QUANTOM.GG"
    Window.Version = config.Version or "v1.0.0"
    Window.Categories = {}

    if PlayerGui:FindFirstChild("QuantomUI") then
        PlayerGui:FindFirstChild("QuantomUI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "QuantomUI"
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
    MainContainer.Name = "MainContainer"
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

    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = "FloatingButton"
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

    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
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
            FloatingButton.Position = UDim2.new(
                floatStartPos.X.Scale,
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale,
                floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

    FloatingButton.MouseButton1Click:Connect(function()
        MainContainer.Visible = not MainContainer.Visible
        if MainContainer.Visible then
            FloatingButton.Visible = false
        end
    end)

    local BackgroundEffects = Instance.new("Frame")
    BackgroundEffects.Name = "BackgroundEffects"
    BackgroundEffects.Size = UDim2.new(1, 0, 1, 0)
    BackgroundEffects.BackgroundTransparency = 1
    BackgroundEffects.ClipsDescendants = true
    BackgroundEffects.ZIndex = 0
    BackgroundEffects.Parent = MainContainer

    for i = 1, isMobile and 8 or 15 do
        local particle = Instance.new("Frame")
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
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Header.Parent = MainContainer

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
    HeaderCorner.Parent = Header

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 6)
    HeaderFix.Position = UDim2.new(0, 0, 1, -6)
    HeaderFix.BackgroundColor3 = Theme.Sidebar
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 2
    HeaderFix.Parent = Header

    local LogoText = Instance.new("TextLabel")
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
    Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -headerHeight)
    Sidebar.Position = UDim2.new(0, 0, 0, headerHeight)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.Parent = MainContainer

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
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

    function Window:CreateTab(config)
        local Tab = {}
        Tab.Name = config.Name or "Tab"
        Tab.Icon = config.Icon or "📁"

        local catHeight = isMobile and 36 or 38

        local CategoryButton = Instance.new("TextButton")
        CategoryButton.Name = Tab.Name
        CategoryButton.Size = UDim2.new(1, 0, 0, catHeight)
        CategoryButton.BackgroundColor3 = Theme.Surface
        CategoryButton.BackgroundTransparency = 1
        CategoryButton.BorderSizePixel = 0
        CategoryButton.Text = ""
        CategoryButton.AutoButtonColor = false
        CategoryButton.LayoutOrder = #Window.Categories + 1
        CategoryButton.ZIndex = 3
        CategoryButton.Parent = Sidebar

        local iconSize = isMobile and 14 or 18
        local Icon = Instance.new("TextLabel")
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
        Indicator.Size = UDim2.new(0, 0, 0, catHeight)
        Indicator.Position = UDim2.new(0, 0, 0, 0)
        Indicator.BackgroundColor3 = Theme.Primary
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 3
        Indicator.Parent = CategoryButton

        local contentPadding = isMobile and 8 or 10
        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Name = Tab.Name .. "Content"
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
        ContentFrame.Name = Tab.Name .. "Inner"
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
                local btn = Sidebar:FindFirstChild(cat.Name)
                if btn then
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    for _, child in pairs(btn:GetChildren()) do
                        if child:IsA("TextLabel") then
                            TweenService:Create(child, TweenInfo.new(0.2), {
                                TextColor3 = child.Text:match("[A-Z]") and Theme.TextSecondary or Theme.TextMuted
                            }):Play()
                        end
                    end
                    local ind = btn:FindFirstChild("Frame")
                    if ind then
                        TweenService:Create(ind, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, catHeight)}):Play()
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
            ToggleFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ToggleFrame.BackgroundColor3 = Theme.Surface
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 3
            ToggleFrame.Parent = ContentFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
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
            ButtonFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ButtonFrame.BackgroundColor3 = Theme.Surface
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.ZIndex = 3
            ButtonFrame.Parent = ContentFrame

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonFrame

            local ButtonClickable = Instance.new("TextButton")
            ButtonClickable.Size = UDim2.new(1, 0, 1, 0)
            ButtonClickable.BackgroundTransparency = 1
            ButtonClickable.Text = ""
            ButtonClickable.ZIndex = 5
            ButtonClickable.Parent = ButtonFrame

            local ButtonLabel = Instance.new("TextLabel")
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
            SliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 46)
            SliderFrame.BackgroundColor3 = Theme.Surface
            SliderFrame.BorderSizePixel = 0
            SliderFrame.ZIndex = 3
            SliderFrame.Parent = ContentFrame

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
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
            TextboxFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            TextboxFrame.BackgroundColor3 = Theme.Surface
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.ZIndex = 3
            TextboxFrame.Parent = ContentFrame

            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 4)
            TextboxCorner.Parent = TextboxFrame

            local TextboxLabel = Instance.new("TextLabel")
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
            local selectedOption = config.Default or config.Options[1] or ""
            local dropdownOpen = false

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            DropdownFrame.BackgroundColor3 = Theme.Surface
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ZIndex = 3
            DropdownFrame.Parent = ContentFrame

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownFrame

            local DropdownLabel = Instance.new("TextLabel")
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

            for _, option in ipairs(config.Options or {}) do
                local OptionButton = Instance.new("TextButton")
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

                    dropdownOpen = false
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, -120, 0, 0)}):Play()
                    task.wait(0.2)
                    OptionsList.Visible = false

                    if config.Callback then
                        config.Callback(option)
                    end
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

            return {
                SetValue = function(self, value)
                    selectedOption = value
                    DropdownButton.Text = value
                end
            }
        end


        function Tab:AddColorPicker(config)
            local currentColor = config.Default or Color3.fromRGB(255, 255, 255)

            local ColorPickerFrame = Instance.new("Frame")
            ColorPickerFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ColorPickerFrame.BackgroundColor3 = Theme.Surface
            ColorPickerFrame.BorderSizePixel = 0
            ColorPickerFrame.ZIndex = 3
            ColorPickerFrame.Parent = ContentFrame

            local ColorPickerCorner = Instance.new("UICorner")
            ColorPickerCorner.CornerRadius = UDim.new(0, 4)
            ColorPickerCorner.Parent = ColorPickerFrame

            local ColorLabel = Instance.new("TextLabel")
            ColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
            ColorLabel.Position = UDim2.new(0, 12, 0, 0)
            ColorLabel.BackgroundTransparency = 1
            ColorLabel.Text = config.Name or "Color Picker"
            ColorLabel.Font = Enum.Font.Gotham
            ColorLabel.TextSize = isMobile and 11 or 12
            ColorLabel.TextColor3 = Theme.Text
            ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
            ColorLabel.ZIndex = 4
            ColorLabel.Parent = ColorPickerFrame

            local ColorDisplay = Instance.new("TextButton")
            ColorDisplay.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 26 or 22)
            ColorDisplay.Position = UDim2.new(1, isMobile and -70 or -60, 0.5, isMobile and -13 or -11)
            ColorDisplay.BackgroundColor3 = currentColor
            ColorDisplay.Text = ""
            ColorDisplay.AutoButtonColor = false
            ColorDisplay.ZIndex = 4
            ColorDisplay.Parent = ColorPickerFrame

            local DisplayCorner = Instance.new("UICorner")
            DisplayCorner.CornerRadius = UDim.new(0, 4)
            DisplayCorner.Parent = ColorDisplay

            local DisplayStroke = Instance.new("UIStroke")
            DisplayStroke.Color = Theme.Border
            DisplayStroke.Thickness = 1
            DisplayStroke.Transparency = 0.5
            DisplayStroke.Parent = ColorDisplay

            local ColorPickerPopup = Instance.new("Frame")
            ColorPickerPopup.Size = UDim2.new(0, isMobile and 200 or 220, 0, isMobile and 200 or 220)
            ColorPickerPopup.Position = UDim2.new(1, -10, 0, 0)
            ColorPickerPopup.BackgroundColor3 = Theme.Surface
            ColorPickerPopup.BorderSizePixel = 0
            ColorPickerPopup.Visible = false
            ColorPickerPopup.ZIndex = 100
            ColorPickerPopup.Parent = ColorPickerFrame

            local PopupCorner = Instance.new("UICorner")
            PopupCorner.CornerRadius = UDim.new(0, 6)
            PopupCorner.Parent = ColorPickerPopup

            local PopupStroke = Instance.new("UIStroke")
            PopupStroke.Color = Theme.Border
            PopupStroke.Thickness = 1
            PopupStroke.Transparency = 0.3
            PopupStroke.Parent = ColorPickerPopup

            local ColorCanvas = Instance.new("ImageButton")
            ColorCanvas.Size = UDim2.new(1, -20, 1, -60)
            ColorCanvas.Position = UDim2.new(0, 10, 0, 10)
            ColorCanvas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ColorCanvas.BorderSizePixel = 0
            ColorCanvas.ZIndex = 101
            ColorCanvas.Parent = ColorPickerPopup

            local CanvasCorner = Instance.new("UICorner")
            CanvasCorner.CornerRadius = UDim.new(0, 4)
            CanvasCorner.Parent = ColorCanvas

            local WhiteGradient = Instance.new("Frame")
            WhiteGradient.Size = UDim2.new(1, 0, 1, 0)
            WhiteGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            WhiteGradient.BackgroundTransparency = 0
            WhiteGradient.BorderSizePixel = 0
            WhiteGradient.ZIndex = 102
            WhiteGradient.Parent = ColorCanvas

            local WhiteCorner = Instance.new("UICorner")
            WhiteCorner.CornerRadius = UDim.new(0, 4)
            WhiteCorner.Parent = WhiteGradient

            local WhiteGrad = Instance.new("UIGradient")
            WhiteGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            }
            WhiteGrad.Rotation = 0
            WhiteGrad.Parent = WhiteGradient

            local BlackGradient = Instance.new("Frame")
            BlackGradient.Size = UDim2.new(1, 0, 1, 0)
            BlackGradient.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BlackGradient.BackgroundTransparency = 0
            BlackGradient.BorderSizePixel = 0
            BlackGradient.ZIndex = 103
            BlackGradient.Parent = ColorCanvas

            local BlackCorner = Instance.new("UICorner")
            BlackCorner.CornerRadius = UDim.new(0, 4)
            BlackCorner.Parent = BlackGradient

            local BlackGrad = Instance.new("UIGradient")
            BlackGrad.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            }
            BlackGrad.Rotation = 90
            BlackGrad.Parent = BlackGradient

            local HueSlider = Instance.new("ImageButton")
            HueSlider.Size = UDim2.new(1, -20, 0, isMobile and 20 or 16)
            HueSlider.Position = UDim2.new(0, 10, 1, isMobile and -35 or -30)
            HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueSlider.BorderSizePixel = 0
            HueSlider.ZIndex = 101
            HueSlider.Parent = ColorPickerPopup

            local HueCorner = Instance.new("UICorner")
            HueCorner.CornerRadius = UDim.new(0, 4)
            HueCorner.Parent = HueSlider

            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
            HueGradient.Rotation = 0
            HueGradient.Parent = HueSlider

            local currentHue = 0
            local currentSat = 1
            local currentVal = 1

            local function updateColor()
                local color = Color3.fromHSV(currentHue, currentSat, currentVal)
                currentColor = color
                ColorDisplay.BackgroundColor3 = color

                if config.Callback then
                    config.Callback(color)
                end
            end

            local function rgbToHsv(color)
                local r, g, b = color.R, color.G, color.B
                local max = math.max(r, g, b)
                local min = math.min(r, g, b)
                local delta = max - min

                local h, s, v = 0, 0, max

                if delta > 0 then
                    if max == r then
                        h = ((g - b) / delta) % 6
                    elseif max == g then
                        h = (b - r) / delta + 2
                    else
                        h = (r - g) / delta + 4
                    end
                    h = h / 6
                    s = delta / max
                end

                return h, s, v
            end

            currentHue, currentSat, currentVal = rgbToHsv(currentColor)
            ColorCanvas.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)

            local canvasDragging = false
            ColorCanvas.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    canvasDragging = true
                    local pos = ColorCanvas.AbsolutePosition
                    local size = ColorCanvas.AbsoluteSize
                    local mousePos = input.Position

                    local x = math.clamp(mousePos.X - pos.X, 0, size.X) / size.X
                    local y = math.clamp(mousePos.Y - pos.Y, 0, size.Y) / size.Y

                    currentSat = x
                    currentVal = 1 - y
                    updateColor()
                end
            end)

            ColorCanvas.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    canvasDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if canvasDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = ColorCanvas.AbsolutePosition
                    local size = ColorCanvas.AbsoluteSize
                    local mousePos = input.Position

                    local x = math.clamp(mousePos.X - pos.X, 0, size.X) / size.X
                    local y = math.clamp(mousePos.Y - pos.Y, 0, size.Y) / size.Y

                    currentSat = x
                    currentVal = 1 - y
                    updateColor()
                end
            end)

            local hueDragging = false
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    local pos = HueSlider.AbsolutePosition.X
                    local size = HueSlider.AbsoluteSize.X
                    local mousePos = input.Position.X

                    currentHue = math.clamp((mousePos - pos) / size, 0, 1)
                    ColorCanvas.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                    updateColor()
                end
            end)

            HueSlider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = HueSlider.AbsolutePosition.X
                    local size = HueSlider.AbsoluteSize.X
                    local mousePos = input.Position.X

                    currentHue = math.clamp((mousePos - pos) / size, 0, 1)
                    ColorCanvas.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                    updateColor()
                end
            end)

            ColorDisplay.MouseButton1Click:Connect(function()
                ColorPickerPopup.Visible = not ColorPickerPopup.Visible
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if ColorPickerPopup.Visible then
                        local mousePos = input.Position
                        local popupPos = ColorPickerPopup.AbsolutePosition
                        local popupSize = ColorPickerPopup.AbsoluteSize

                        if mousePos.X < popupPos.X or mousePos.X > popupPos.X + popupSize.X or
                           mousePos.Y < popupPos.Y or mousePos.Y > popupPos.Y + popupSize.Y then
                            local displayPos = ColorDisplay.AbsolutePosition
                            local displaySize = ColorDisplay.AbsoluteSize

                            if not (mousePos.X >= displayPos.X and mousePos.X <= displayPos.X + displaySize.X and
                                   mousePos.Y >= displayPos.Y and mousePos.Y <= displayPos.Y + displaySize.Y) then
                                ColorPickerPopup.Visible = false
                            end
                        end
                    end
                end
            end)

            return {
                SetValue = function(self, color)
                    currentColor = color
                    ColorDisplay.BackgroundColor3 = color
                    currentHue, currentSat, currentVal = rgbToHsv(color)
                    ColorCanvas.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                end
            }
        end

        
        -- ═══════════════════════════════════════════════════════════
        --                    NOVOS COMPONENTES (7)
        -- ═══════════════════════════════════════════════════════════

        function Tab:AddLabel(config)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.ZIndex = 3
            LabelFrame.Parent = ContentFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -24, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = config.Text or "Label"
            Label.Font = Enum.Font.Gotham
            Label.TextSize = isMobile and 11 or 12
            Label.TextColor3 = config.Color or Theme.TextSecondary
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.ZIndex = 4
            Label.Parent = LabelFrame

            return {
                SetText = function(self, text)
                    Label.Text = text
                end,
                SetColor = function(self, color)
                    Label.TextColor3 = color
                end
            }
        end

        function Tab:AddParagraph(config)
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Size = UDim2.new(1, 0, 0, isMobile and 70 or 65)
            ParagraphFrame.BackgroundColor3 = Theme.Surface
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.ZIndex = 3
            ParagraphFrame.Parent = ContentFrame

            local ParagraphCorner = Instance.new("UICorner")
            ParagraphCorner.CornerRadius = UDim.new(0, 6)
            ParagraphCorner.Parent = ParagraphFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -24, 0, 18)
            TitleLabel.Position = UDim2.new(0, 12, 0, 8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = config.Title or "Paragraph"
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = isMobile and 11 or 12
            TitleLabel.TextColor3 = Theme.Text
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 4
            TitleLabel.Parent = ParagraphFrame

            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Size = UDim2.new(1, -24, 1, -32)
            ContentLabel.Position = UDim2.new(0, 12, 0, 26)
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Text = config.Content or ""
            ContentLabel.Font = Enum.Font.Gotham
            ContentLabel.TextSize = isMobile and 10 or 11
            ContentLabel.TextColor3 = Theme.TextSecondary
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            ContentLabel.TextWrapped = true
            ContentLabel.ZIndex = 4
            ContentLabel.Parent = ParagraphFrame

            return {
                SetTitle = function(self, title)
                    TitleLabel.Text = title
                end,
                SetContent = function(self, content)
                    ContentLabel.Text = content
                end
            }
        end

        function Tab:AddDivider()
            local DividerFrame = Instance.new("Frame")
            DividerFrame.Size = UDim2.new(1, 0, 0, isMobile and 12 or 10)
            DividerFrame.BackgroundTransparency = 1
            DividerFrame.ZIndex = 3
            DividerFrame.Parent = ContentFrame

            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, -24, 0, 1)
            Divider.Position = UDim2.new(0, 12, 0.5, 0)
            Divider.BackgroundColor3 = Theme.Border
            Divider.BackgroundTransparency = 0.7
            Divider.BorderSizePixel = 0
            Divider.ZIndex = 4
            Divider.Parent = DividerFrame
        end

        function Tab:AddInput(config)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            InputFrame.BackgroundColor3 = Theme.Surface
            InputFrame.BorderSizePixel = 0
            InputFrame.ZIndex = 3
            InputFrame.Parent = ContentFrame

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 6)
            InputCorner.Parent = InputFrame

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(0.5, 0, 1, 0)
            InputLabel.Position = UDim2.new(0, 12, 0, 0)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = config.Name or "Input"
            InputLabel.Font = Enum.Font.GothamMedium
            InputLabel.TextSize = isMobile and 11 or 12
            InputLabel.TextColor3 = Theme.Text
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.ZIndex = 4
            InputLabel.Parent = InputFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0, isMobile and 80 or 75, 0, isMobile and 26 or 22)
            InputBox.Position = UDim2.new(1, isMobile and -90 or -85, 0.5, isMobile and -13 or -11)
            InputBox.BackgroundColor3 = Theme.SurfaceLight
            InputBox.Text = tostring(config.Default or 0)
            InputBox.PlaceholderText = config.Placeholder or "0"
            InputBox.Font = Enum.Font.GothamBold
            InputBox.TextSize = isMobile and 10 or 11
            InputBox.TextColor3 = Theme.Text
            InputBox.PlaceholderColor3 = Theme.TextMuted
            InputBox.ClearButtonMode = Enum.ClearButtonMode.Never
            InputBox.ZIndex = 4
            InputBox.Parent = InputFrame

            local InputCorner2 = Instance.new("UICorner")
            InputCorner2.CornerRadius = UDim.new(0, 6)
            InputCorner2.Parent = InputBox

            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color = Theme.Border
            InputStroke.Thickness = 1
            InputStroke.Transparency = 0.5
            InputStroke.Parent = InputBox

            InputBox.Focused:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                    Color = Theme.Primary,
                    Thickness = 2,
                    Transparency = 0.3
                }):Play()
            end)

            InputBox.FocusLost:Connect(function()
                TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                    Color = Theme.Border,
                    Thickness = 1,
                    Transparency = 0.5
                }):Play()

                local value = tonumber(InputBox.Text)
                if value then
                    if config.Min and value < config.Min then
                        value = config.Min
                    end
                    if config.Max and value > config.Max then
                        value = config.Max
                    end
                    InputBox.Text = tostring(value)

                    if config.Callback then
                        config.Callback(value)
                    end
                else
                    InputBox.Text = tostring(config.Default or 0)
                end
            end)

            return {
                SetValue = function(self, value)
                    InputBox.Text = tostring(value)
                end
            }
        end

        function Tab:AddMultiDropdown(config)
            local selectedOptions = {}
            local dropdownOpen = false

            local MultiDropdownFrame = Instance.new("Frame")
            MultiDropdownFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            MultiDropdownFrame.BackgroundColor3 = Theme.Surface
            MultiDropdownFrame.BorderSizePixel = 0
            MultiDropdownFrame.ZIndex = 3
            MultiDropdownFrame.Parent = ContentFrame

            local MultiDropdownCorner = Instance.new("UICorner")
            MultiDropdownCorner.CornerRadius = UDim.new(0, 6)
            MultiDropdownCorner.Parent = MultiDropdownFrame

            local MultiDropdownLabel = Instance.new("TextLabel")
            MultiDropdownLabel.Size = UDim2.new(0, 100, 1, 0)
            MultiDropdownLabel.Position = UDim2.new(0, 12, 0, 0)
            MultiDropdownLabel.BackgroundTransparency = 1
            MultiDropdownLabel.Text = config.Name or "Multi Dropdown"
            MultiDropdownLabel.Font = Enum.Font.GothamMedium
            MultiDropdownLabel.TextSize = isMobile and 11 or 12
            MultiDropdownLabel.TextColor3 = Theme.Text
            MultiDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            MultiDropdownLabel.ZIndex = 4
            MultiDropdownLabel.Parent = MultiDropdownFrame

            local MultiDropdownButton = Instance.new("TextButton")
            MultiDropdownButton.Size = UDim2.new(1, -120, 0, isMobile and 26 or 22)
            MultiDropdownButton.Position = UDim2.new(0, 110, 0.5, isMobile and -13 or -11)
            MultiDropdownButton.BackgroundColor3 = Theme.SurfaceLight
            MultiDropdownButton.Text = "0 selected"
            MultiDropdownButton.Font = Enum.Font.Gotham
            MultiDropdownButton.TextSize = isMobile and 10 or 11
            MultiDropdownButton.TextColor3 = Theme.Text
            MultiDropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            MultiDropdownButton.AutoButtonColor = false
            MultiDropdownButton.ZIndex = 4
            MultiDropdownButton.Parent = MultiDropdownFrame

            local MultiDropdownBtnCorner = Instance.new("UICorner")
            MultiDropdownBtnCorner.CornerRadius = UDim.new(0, 6)
            MultiDropdownBtnCorner.Parent = MultiDropdownButton

            local MultiDropdownPadding = Instance.new("UIPadding")
            MultiDropdownPadding.PaddingLeft = UDim.new(0, 8)
            MultiDropdownPadding.Parent = MultiDropdownButton

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -24, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = isMobile and 8 or 9
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.ZIndex = 5
            Arrow.Parent = MultiDropdownButton

            local OptionsList = Instance.new("ScrollingFrame")
            OptionsList.Size = UDim2.new(1, -120, 0, 0)
            OptionsList.Position = UDim2.new(0, 110, 1, 4)
            OptionsList.BackgroundColor3 = Theme.SurfaceLight
            OptionsList.BorderSizePixel = 0
            OptionsList.Visible = false
            OptionsList.ZIndex = 10
            OptionsList.ClipsDescendants = true
            OptionsList.ScrollBarThickness = 4
            OptionsList.ScrollBarImageColor3 = Theme.Primary
            OptionsList.Parent = MultiDropdownFrame

            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 6)
            OptionsCorner.Parent = OptionsList

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Parent = OptionsList

            for _, option in ipairs(config.Options or {}) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
                OptionButton.BackgroundColor3 = Theme.SurfaceLight
                OptionButton.Text = ""
                OptionButton.AutoButtonColor = false
                OptionButton.ZIndex = 11
                OptionButton.Parent = OptionsList

                local Checkbox = Instance.new("TextLabel")
                Checkbox.Size = UDim2.new(0, 16, 0, 16)
                Checkbox.Position = UDim2.new(0, 8, 0.5, -8)
                Checkbox.BackgroundColor3 = Theme.Surface
                Checkbox.Text = ""
                Checkbox.Font = Enum.Font.GothamBold
                Checkbox.TextSize = 12
                Checkbox.TextColor3 = Theme.Success
                Checkbox.ZIndex = 12
                Checkbox.Parent = OptionButton

                local CheckboxCorner = Instance.new("UICorner")
                CheckboxCorner.CornerRadius = UDim.new(0, 4)
                CheckboxCorner.Parent = Checkbox

                local CheckboxStroke = Instance.new("UIStroke")
                CheckboxStroke.Color = Theme.Border
                CheckboxStroke.Thickness = 1
                CheckboxStroke.Parent = Checkbox

                local OptionLabel = Instance.new("TextLabel")
                OptionLabel.Size = UDim2.new(1, -32, 1, 0)
                OptionLabel.Position = UDim2.new(0, 28, 0, 0)
                OptionLabel.BackgroundTransparency = 1
                OptionLabel.Text = option
                OptionLabel.Font = Enum.Font.Gotham
                OptionLabel.TextSize = isMobile and 10 or 11
                OptionLabel.TextColor3 = Theme.Text
                OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptionLabel.ZIndex = 12
                OptionLabel.Parent = OptionButton

                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Theme.Surface
                    }):Play()
                end)

                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Theme.SurfaceLight
                    }):Play()
                end)

                OptionButton.MouseButton1Click:Connect(function()
                    local isSelected = table.find(selectedOptions, option)

                    if isSelected then
                        table.remove(selectedOptions, isSelected)
                        Checkbox.Text = ""
                        CheckboxStroke.Color = Theme.Border
                    else
                        table.insert(selectedOptions, option)
                        Checkbox.Text = "✓"
                        CheckboxStroke.Color = Theme.Success
                    end

                    MultiDropdownButton.Text = #selectedOptions .. " selected"

                    if config.Callback then
                        config.Callback(selectedOptions)
                    end
                end)
            end

            OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OptionsList.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y)
            end)

            MultiDropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen

                if dropdownOpen then
                    OptionsList.Visible = true
                    local optionCount = #(config.Options or {})
                    local maxHeight = math.min(optionCount * (isMobile and 28 or 24), isMobile and 140 or 120)
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, -120, 0, maxHeight)
                    }):Play()
                else
                    TweenService:Create(OptionsList, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, -120, 0, 0)
                    }):Play()
                    task.wait(0.2)
                    OptionsList.Visible = false
                end
            end)

            return {
                GetSelected = function(self)
                    return selectedOptions
                end
            }
        end

        function Tab:AddToggleKeybind(config)
            local toggleState = config.Default or false
            local currentKey = config.Key or Enum.KeyCode.E
            local blacklistedKeys = {
                Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl
            }
            local keybindChanging = false

            local ToggleKeybindFrame = Instance.new("Frame")
            ToggleKeybindFrame.Size = UDim2.new(1, 0, 0, isMobile and 36 or 32)
            ToggleKeybindFrame.BackgroundColor3 = Theme.Surface
            ToggleKeybindFrame.BorderSizePixel = 0
            ToggleKeybindFrame.ZIndex = 3
            ToggleKeybindFrame.Parent = ContentFrame

            local ToggleKeybindCorner = Instance.new("UICorner")
            ToggleKeybindCorner.CornerRadius = UDim.new(0, 6)
            ToggleKeybindCorner.Parent = ToggleKeybindFrame

            local ToggleKeybindLabel = Instance.new("TextLabel")
            ToggleKeybindLabel.Size = UDim2.new(0.45, 0, 1, 0)
            ToggleKeybindLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleKeybindLabel.BackgroundTransparency = 1
            ToggleKeybindLabel.Text = config.Name or "Toggle"
            ToggleKeybindLabel.Font = Enum.Font.GothamMedium
            ToggleKeybindLabel.TextSize = isMobile and 11 or 12
            ToggleKeybindLabel.TextColor3 = Theme.Text
            ToggleKeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleKeybindLabel.ZIndex = 4
            ToggleKeybindLabel.Parent = ToggleKeybindFrame

            -- Keybind Button
            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Size = UDim2.new(0, isMobile and 50 or 45, 0, isMobile and 22 or 18)
            KeybindButton.Position = UDim2.new(1, isMobile and -60 or -55, 0.5, isMobile and -11 or -9)
            KeybindButton.BackgroundColor3 = Theme.SurfaceLight
            KeybindButton.Text = currentKey.Name
            KeybindButton.Font = Enum.Font.GothamBold
            KeybindButton.TextSize = isMobile and 9 or 10
            KeybindButton.TextColor3 = Theme.Primary
            KeybindButton.AutoButtonColor = false
            KeybindButton.ZIndex = 4
            KeybindButton.Parent = ToggleKeybindFrame

            local KeybindBtnCorner = Instance.new("UICorner")
            KeybindBtnCorner.CornerRadius = UDim.new(0, 4)
            KeybindBtnCorner.Parent = KeybindButton

            -- Toggle Button
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, isMobile and 38 or 34, 0, isMobile and 20 or 16)
            ToggleButton.Position = UDim2.new(1, isMobile and -105 or -95, 0.5, isMobile and -10 or -8)
            ToggleButton.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.ZIndex = 4
            ToggleButton.Parent = ToggleKeybindFrame

            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleButton

            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, isMobile and 16 or 12, 0, isMobile and 16 or 12)
            ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -18 or -14, 0.5, isMobile and -8 or -6) or UDim2.new(0, 2, 0.5, isMobile and -8 or -6)
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
                local endPos = toggleState and UDim2.new(1, isMobile and -18 or -14, 0.5, isMobile and -8 or -6) or UDim2.new(0, 2, 0.5, isMobile and -8 or -6)
                TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Position = endPos
                }):Play()

                if config.Callback then
                    config.Callback(toggleState)
                end
            end)

            KeybindButton.MouseButton1Click:Connect(function()
                if keybindChanging then return end

                keybindChanging = true
                KeybindButton.Text = "..."
                KeybindButton.TextColor3 = Theme.Warning

                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        local isBlacklisted = table.find(blacklistedKeys, key)

                        if not isBlacklisted then
                            currentKey = key
                            KeybindButton.Text = key.Name
                        end

                        KeybindButton.TextColor3 = Theme.Primary
                        keybindChanging = false
                        connection:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey and toggleState then
                    if config.Callback then
                        config.Callback(toggleState)
                    end
                end
            end)

            return {
                SetState = function(self, state)
                    toggleState = state
                    ToggleButton.BackgroundColor3 = toggleState and Theme.Toggle or Theme.Border
                    ToggleCircle.Position = toggleState and UDim2.new(1, isMobile and -18 or -14, 0.5, isMobile and -8 or -6) or UDim2.new(0, 2, 0.5, isMobile and -8 or -6)
                end,
                SetKey = function(self, key)
                    currentKey = key
                    KeybindButton.Text = key.Name
                end
            }
        end

        
    -- ═══════════════════════════════════════════════════════════
    --                      WATERMARK SYSTEM
    -- ═══════════════════════════════════════════════════════════

    function Window:CreateWatermark(config)
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Size = UDim2.new(0, isMobile and 200 or 220, 0, isMobile and 80 or 75)
        WatermarkFrame.Position = UDim2.new(1, isMobile and -210 or -230, 0, 10)
        WatermarkFrame.BackgroundColor3 = Theme.Surface
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.ZIndex = 1000
        WatermarkFrame.Parent = ScreenGui

        local WatermarkCorner = Instance.new("UICorner")
        WatermarkCorner.CornerRadius = UDim.new(0, 8)
        WatermarkCorner.Parent = WatermarkFrame

        local WatermarkStroke = Instance.new("UIStroke")
        WatermarkStroke.Color = Theme.Primary
        WatermarkStroke.Thickness = 2
        WatermarkStroke.Transparency = 0.5
        WatermarkStroke.Parent = WatermarkFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -16, 0, 20)
        Title.Position = UDim2.new(0, 8, 0, 8)
        Title.BackgroundTransparency = 1
        Title.Text = config.Title or "QUANTOM.GG"
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = isMobile and 12 or 13
        Title.TextColor3 = Theme.Primary
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 1001
        Title.Parent = WatermarkFrame

        local FPSLabel = Instance.new("TextLabel")
        FPSLabel.Size = UDim2.new(1, -16, 0, 16)
        FPSLabel.Position = UDim2.new(0, 8, 0, 30)
        FPSLabel.BackgroundTransparency = 1
        FPSLabel.Text = "FPS: 0"
        FPSLabel.Font = Enum.Font.Gotham
        FPSLabel.TextSize = isMobile and 10 or 11
        FPSLabel.TextColor3 = Theme.Text
        FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
        FPSLabel.ZIndex = 1001
        FPSLabel.Parent = WatermarkFrame

        local PingLabel = Instance.new("TextLabel")
        PingLabel.Size = UDim2.new(1, -16, 0, 16)
        PingLabel.Position = UDim2.new(0, 8, 0, 46)
        PingLabel.BackgroundTransparency = 1
        PingLabel.Text = "Ping: 0ms"
        PingLabel.Font = Enum.Font.Gotham
        PingLabel.TextSize = isMobile and 10 or 11
        PingLabel.TextColor3 = Theme.Text
        PingLabel.TextXAlignment = Enum.TextXAlignment.Left
        PingLabel.ZIndex = 1001
        PingLabel.Parent = WatermarkFrame

        -- Dragging
        local dragging = false
        local dragInput, dragStart, startPos

        WatermarkFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = WatermarkFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        WatermarkFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                WatermarkFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        -- FPS Counter
        local lastUpdate = tick()
        local fps = 0
        RunService.RenderStepped:Connect(function()
            local now = tick()
            fps = math.floor(1 / (now - lastUpdate))
            lastUpdate = now
            FPSLabel.Text = "FPS: " .. fps
        end)

        -- Ping
        task.spawn(function()
            while WatermarkFrame.Parent do
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                PingLabel.Text = "Ping: " .. ping .. "ms"
                task.wait(1)
            end
        end)

        return WatermarkFrame
    end

    
    -- ═══════════════════════════════════════════════════════════
    --                CONFIG SYSTEM (AUTO TAB - SEMPRE ÚLTIMA)
    -- ═══════════════════════════════════════════════════════════

    local HttpService = game:GetService("HttpService")
    local ConfigFolder = "QuantomConfigs"

    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end

    local function GetAllFlags()
        local flags = {}
        for flag, element in pairs(Window.Flags) do
            if element.GetValue then
                local value = element:GetValue()
                flags[flag] = {
                    Value = value,
                    Type = typeof(value)
                }
            end
        end
        return flags
    end

    local function LoadConfig(configName)
        local path = ConfigFolder .. "/" .. configName .. ".json"
        if not isfile(path) then
            print("[Config Error] Config não encontrado!")
            return false
        end

        local content = readfile(path)
        local success, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)

        if not success then
            print("[Config Error] Erro ao ler config!")
            return false
        end

        for flag, flagData in pairs(data.Flags or {}) do
            if Window.Flags[flag] and Window.Flags[flag].SetValue then
                pcall(function()
                    Window.Flags[flag]:SetValue(flagData.Value)
                end)
            end
        end

        print("[✅ Config] Loaded: " .. configName)
        return true
    end

    local function SaveConfig(configName)
        if configName == "" or not configName then
            print("[Config Error] Nome inválido!")
            return false
        end

        local flags = GetAllFlags()
        local configData = {
            Name = configName,
            Author = game.Players.LocalPlayer.Name,
            Date = os.date("%d/%m/%Y %H:%M"),
            Flags = flags
        }

        local path = ConfigFolder .. "/" .. configName .. ".json"
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(configData)
        end)

        if not success then
            print("[Config Error] Erro ao salvar!")
            return false
        end

        writefile(path, encoded)
        print("[✅ Config] Saved: " .. configName)
        return true
    end

    local function DeleteConfig(configName)
        local path = ConfigFolder .. "/" .. configName .. ".json"
        if not isfile(path) then
            print("[Config Error] Config não encontrado!")
            return false
        end

        delfile(path)
        print("[⚠️ Config] Deleted: " .. configName)
        return true
    end

    local function GetConfigs()
        local configs = {}
        if not isfolder(ConfigFolder) then
            return configs
        end

        local files = listfiles(ConfigFolder)
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                local content = readfile(file)
                local success, data = pcall(function()
                    return HttpService:JSONDecode(content)
                end)

                if success then
                    table.insert(configs, {
                        Name = name,
                        Author = data.Author or "Unknown",
                        Date = data.Date or "Unknown"
                    })
                end
            end
        end

        return configs
    end

    task.defer(function()
        task.wait(0.5)

        local ConfigTab = Window:CreateTab({
            Name = "Config",
            Icon = "💾"
        })

        ConfigTab:AddSection("SAVE CONFIG")

        local configNameInput = "MyConfig"
        ConfigTab:AddTextbox({
            Name = "Config Name",
            Default = "MyConfig",
            Placeholder = "Enter name",
            Callback = function(value)
                configNameInput = value
            end
        })

        ConfigTab:AddButton({
            Name = "💾 Save Config",
            Callback = function()
                SaveConfig(configNameInput)
                task.wait(0.1)
                RefreshConfigList()
            end
        })

        ConfigTab:AddDivider()

        ConfigTab:AddSection("LOAD & DELETE")

        local configListFrame = Instance.new("Frame")
        configListFrame.Size = UDim2.new(1, 0, 0, isMobile and 240 or 220)
        configListFrame.BackgroundColor3 = Theme.SurfaceLight
        configListFrame.BorderSizePixel = 0
        configListFrame.ZIndex = 3
        configListFrame.Parent = ConfigTab.ContentFrame

        local configListCorner = Instance.new("UICorner")
        configListCorner.CornerRadius = UDim.new(0, 8)
        configListCorner.Parent = configListFrame

        local configScroll = Instance.new("ScrollingFrame")
        configScroll.Size = UDim2.new(1, -12, 1, -12)
        configScroll.Position = UDim2.new(0, 6, 0, 6)
        configScroll.BackgroundTransparency = 1
        configScroll.BorderSizePixel = 0
        configScroll.ScrollBarThickness = 4
        configScroll.ScrollBarImageColor3 = Theme.Primary
        configScroll.ZIndex = 4
        configScroll.Parent = configListFrame

        local configLayout = Instance.new("UIListLayout")
        configLayout.Padding = UDim.new(0, 6)
        configLayout.SortOrder = Enum.SortOrder.LayoutOrder
        configLayout.Parent = configScroll

        configLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            configScroll.CanvasSize = UDim2.new(0, 0, 0, configLayout.AbsoluteContentSize.Y + 10)
        end)

        function RefreshConfigList()
            for _, child in ipairs(configScroll:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                    child:Destroy()
                end
            end

            local configs = GetConfigs()

            if #configs == 0 then
                local noConfigLabel = Instance.new("TextLabel")
                noConfigLabel.Size = UDim2.new(1, 0, 0, 50)
                noConfigLabel.BackgroundTransparency = 1
                noConfigLabel.Text = "📂 No configs found\n\nCreate one above!"
                noConfigLabel.Font = Enum.Font.Gotham
                noConfigLabel.TextSize = isMobile and 10 or 11
                noConfigLabel.TextColor3 = Theme.TextMuted
                noConfigLabel.ZIndex = 5
                noConfigLabel.Parent = configScroll
                return
            end

            for _, config in ipairs(configs) do
                local configItem = Instance.new("Frame")
                configItem.Size = UDim2.new(1, -5, 0, isMobile and 70 or 65)
                configItem.BackgroundColor3 = Theme.Surface
                configItem.BorderSizePixel = 0
                configItem.ZIndex = 5
                configItem.Parent = configScroll

                local configItemCorner = Instance.new("UICorner")
                configItemCorner.CornerRadius = UDim.new(0, 6)
                configItemCorner.Parent = configItem

                local configNameLabel = Instance.new("TextLabel")
                configNameLabel.Size = UDim2.new(1, -115, 0, 22)
                configNameLabel.Position = UDim2.new(0, 10, 0, 8)
                configNameLabel.BackgroundTransparency = 1
                configNameLabel.Text = "📁 " .. config.Name
                configNameLabel.Font = Enum.Font.GothamBold
                configNameLabel.TextSize = isMobile and 11 or 12
                configNameLabel.TextColor3 = Theme.Text
                configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
                configNameLabel.ZIndex = 6
                configNameLabel.Parent = configItem

                local configInfoLabel = Instance.new("TextLabel")
                configInfoLabel.Size = UDim2.new(1, -115, 0, 18)
                configInfoLabel.Position = UDim2.new(0, 10, 0, 30)
                configInfoLabel.BackgroundTransparency = 1
                configInfoLabel.Text = "👤 " .. config.Author
                configInfoLabel.Font = Enum.Font.Gotham
                configInfoLabel.TextSize = isMobile and 9 or 10
                configInfoLabel.TextColor3 = Theme.TextSecondary
                configInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
                configInfoLabel.ZIndex = 6
                configInfoLabel.Parent = configItem

                local configDateLabel = Instance.new("TextLabel")
                configDateLabel.Size = UDim2.new(1, -115, 0, 16)
                configDateLabel.Position = UDim2.new(0, 10, 0, 46)
                configDateLabel.BackgroundTransparency = 1
                configDateLabel.Text = "📅 " .. config.Date
                configDateLabel.Font = Enum.Font.Gotham
                configDateLabel.TextSize = isMobile and 8 or 9
                configDateLabel.TextColor3 = Theme.TextMuted
                configDateLabel.TextXAlignment = Enum.TextXAlignment.Left
                configDateLabel.ZIndex = 6
                configDateLabel.Parent = configItem

                local loadButton = Instance.new("TextButton")
                loadButton.Size = UDim2.new(0, isMobile and 45 or 48, 0, isMobile and 60 or 55)
                loadButton.Position = UDim2.new(1, isMobile and -100 or -103, 0, 5)
                loadButton.BackgroundColor3 = Theme.Success
                loadButton.Text = "📥\nLoad"
                loadButton.Font = Enum.Font.GothamBold
                loadButton.TextSize = isMobile and 9 or 10
                loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                loadButton.AutoButtonColor = false
                loadButton.ZIndex = 6
                loadButton.Parent = configItem

                local loadCorner = Instance.new("UICorner")
                loadCorner.CornerRadius = UDim.new(0, 6)
                loadCorner.Parent = loadButton

                loadButton.MouseEnter:Connect(function()
                    TweenService:Create(loadButton, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(0, 190, 110)
                    }):Play()
                end)

                loadButton.MouseLeave:Connect(function()
                    TweenService:Create(loadButton, TweenInfo.new(0.15), {
                        BackgroundColor3 = Theme.Success
                    }):Play()
                end)

                loadButton.MouseButton1Click:Connect(function()
                    LoadConfig(config.Name)
                end)

                local deleteButton = Instance.new("TextButton")
                deleteButton.Size = UDim2.new(0, isMobile and 45 or 48, 0, isMobile and 60 or 55)
                deleteButton.Position = UDim2.new(1, isMobile and -50 or -50, 0, 5)
                deleteButton.BackgroundColor3 = Theme.Error
                deleteButton.Text = "🗑️\nDel"
                deleteButton.Font = Enum.Font.GothamBold
                deleteButton.TextSize = isMobile and 9 or 10
                deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                deleteButton.AutoButtonColor = false
                deleteButton.ZIndex = 6
                deleteButton.Parent = configItem

                local deleteCorner = Instance.new("UICorner")
                deleteCorner.CornerRadius = UDim.new(0, 6)
                deleteCorner.Parent = deleteButton

                deleteButton.MouseEnter:Connect(function()
                    TweenService:Create(deleteButton, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(230, 60, 60)
                    }):Play()
                end)

                deleteButton.MouseLeave:Connect(function()
                    TweenService:Create(deleteButton, TweenInfo.new(0.15), {
                        BackgroundColor3 = Theme.Error
                    }):Play()
                end)

                deleteButton.MouseButton1Click:Connect(function()
                    DeleteConfig(config.Name)
                    task.wait(0.1)
                    RefreshConfigList()
                end)
            end
        end

        ConfigTab:AddButton({
            Name = "🔄 Refresh List",
            Callback = function()
                RefreshConfigList()
            end
        })

        ConfigTab:AddDivider()

        ConfigTab:AddSection("AUTO-LOAD")

        local autoLoadConfig = ""
        ConfigTab:AddTextbox({
            Name = "Auto-Load Config",
            Default = "",
            Placeholder = "Config name",
            Callback = function(value)
                autoLoadConfig = value
                if value ~= "" then
                    writefile(ConfigFolder .. "/_autoload.txt", value)
                end
            end
        })

        ConfigTab:AddButton({
            Name = "⚡ Load Now",
            Callback = function()
                if autoLoadConfig ~= "" then
                    LoadConfig(autoLoadConfig)
                else
                    print("[Config] No config name set!")
                end
            end
        })

        if isfile(ConfigFolder .. "/_autoload.txt") then
            local autoName = readfile(ConfigFolder .. "/_autoload.txt")
            if autoName ~= "" and isfile(ConfigFolder .. "/" .. autoName .. ".json") then
                task.wait(1)
                LoadConfig(autoName)
                autoLoadConfig = autoName
            end
        end

        task.wait(0.2)
        RefreshConfigList()
    end)

    table.insert(Window.Categories, Tab)

        if #Window.Categories == 1 then
            task.wait(0.1)
            activateTab()
        end

        return Tab
    end

    function Window:Show()
        MainContainer.Visible = true
    end

    function Window:Hide()
        MainContainer.Visible = false
        if isMobile then
            FloatingButton.Visible = true
        end
    end

    function Window:Toggle()
        MainContainer.Visible = not MainContainer.Visible
        if isMobile and not MainContainer.Visible then
            FloatingButton.Visible = true
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            Window:Toggle()
        end
    end)

    return Window
end

return QuantomLib
