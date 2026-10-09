local QuantomLib = {}
QuantomLib._version = "3.0.0"

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local viewportSize = workspace.CurrentCamera.ViewportSize

local QUANTOM_TAG = "_QuantomLib_Root"

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:GetAttribute(QUANTOM_TAG) then
        gui:Destroy()
    end
end

local function randomName(len)
    len = len or 14
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for i = 1, len do
        out[i] = chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return table.concat(out)
end

local Theme = {
    Background   = Color3.fromRGB(16, 18, 23),
    Panel        = Color3.fromRGB(20, 23, 29),
    PanelAlt     = Color3.fromRGB(24, 27, 34),
    Elevated     = Color3.fromRGB(28, 32, 40),
    Sidebar      = Color3.fromRGB(14, 16, 21),
    Border       = Color3.fromRGB(38, 42, 52),
    BorderSoft   = Color3.fromRGB(32, 35, 44),
    Primary      = Color3.fromRGB(80, 230, 210),
    PrimaryDark  = Color3.fromRGB(55, 165, 150),
    Accent       = Color3.fromRGB(110, 245, 225),
    Text         = Color3.fromRGB(226, 230, 236),
    TextSecondary= Color3.fromRGB(150, 155, 165),
    TextMuted    = Color3.fromRGB(100, 104, 114),
    Success      = Color3.fromRGB(95, 220, 140),
    Warning      = Color3.fromRGB(240, 190, 90),
    Error        = Color3.fromRGB(240, 100, 100),
    Info         = Color3.fromRGB(90, 180, 240),
    Toggle       = Color3.fromRGB(80, 230, 210),
    ToggleOff    = Color3.fromRGB(42, 46, 56),
    SliderTrack  = Color3.fromRGB(32, 35, 44),
}

local ThemeElements = {}
local function RegisterThemeElement(element, property)
    table.insert(ThemeElements, {Element = element, Property = property})
end
local function RefreshTheme()
    for _, data in ipairs(ThemeElements) do
        if data.Element and data.Element.Parent then
            data.Element[data.Property] = Theme.Primary
        end
    end
end

local Sounds = {
    ToggleOn  = "6026984224",
    ToggleOff = "6020793244",
    Click     = "4177953",
    Notify    = "5997023029",
    Keybind   = "3716451793",
}

local function PlaySound(id, vol, pitch)
    local ok, s = pcall(Instance.new, "Sound")
    if not ok then return end
    s.SoundId = "rbxassetid://" .. id
    s.Volume = vol or 0.35
    s.PlaybackSpeed = pitch or 1
    s.RollOffMaxDistance = 0
    s.Parent = SoundService
    pcall(function() s:Play() end)
    Debris:AddItem(s, 4)
end

local function corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, rotation, keypoints)
    local g = Instance.new("UIGradient")
    g.Rotation = rotation or 0
    g.Color = ColorSequence.new(keypoints)
    g.Parent = parent
    return g
end

local function pad(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local function frame(props)
    local f = Instance.new("Frame")
    f.Name = randomName(10)
    f.BackgroundColor3 = props.Color or Theme.Panel
    f.BackgroundTransparency = props.Transparency or 0
    f.BorderSizePixel = 0
    f.Size = props.Size or UDim2.new(1, 0, 0, 30)
    f.Position = props.Position or UDim2.new(0, 0, 0, 0)
    f.ZIndex = props.ZIndex or 1
    f.ClipsDescendants = props.Clip or false
    f.Visible = props.Visible ~= false
    f.Parent = props.Parent
    if props.Corner then corner(props.Corner, f) end
    return f
end

local function label(props)
    local t = Instance.new("TextLabel")
    t.Name = randomName(10)
    t.BackgroundTransparency = 1
    t.Size = props.Size or UDim2.new(1, 0, 1, 0)
    t.Position = props.Position or UDim2.new(0, 0, 0, 0)
    t.Font = props.Font or Enum.Font.Gotham
    t.Text = props.Text or ""
    t.TextSize = props.TextSize or 12
    t.TextColor3 = props.Color or Theme.Text
    t.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    t.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    t.TextTruncate = props.Truncate or Enum.TextTruncate.AtEnd
    t.TextWrapped = props.Wrapped or false
    t.ZIndex = props.ZIndex or 2
    t.Parent = props.Parent
    return t
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local EASE_OUT  = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_IN   = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local EASE_SNAP = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_POP  = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function dragify(handle, target, boundToMobile)
    if boundToMobile == false and isMobile then return end
    local dragging, dragStart, startPos = false, nil, nil
    local dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local NotificationQueue = {}
local NotificationContainer = nil

local function CreateNotificationContainer(screenGui)
    if NotificationContainer and NotificationContainer.Parent then return end
    NotificationContainer = frame({
        Parent = screenGui,
        Size = UDim2.new(0, isMobile and 280 or 320, 0, 0),
        Position = UDim2.new(1, -(isMobile and 290 or 330), 0, 10),
        Transparency = 1,
        ZIndex = 9999,
    })
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Parent = NotificationContainer
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NotificationContainer.Size = UDim2.new(0, isMobile and 280 or 320, 0, list.AbsoluteContentSize.Y)
    end)
end

local function CreateNotification(screenGui, config)
    CreateNotificationContainer(screenGui)
    PlaySound(Sounds.Notify, 0.4, 1)
    local notifType = config.Type or "Info"
    local notifColor = Theme.Info
    local notifIcon = "i"
    if notifType == "Success" then
        notifColor, notifIcon = Theme.Success, "+"
    elseif notifType == "Warning" then
        notifColor, notifIcon = Theme.Warning, "!"
    elseif notifType == "Error" then
        notifColor, notifIcon = Theme.Error, "x"
    end

    local NotificationFrame = frame({
        Parent = NotificationContainer,
        Size = UDim2.new(1, 0, 0, isMobile and 70 or 65),
        Color = Theme.Panel,
        Corner = 8,
        Clip = true,
        ZIndex = 10000,
    })
    NotificationFrame.LayoutOrder = #NotificationQueue + 1
    stroke(NotificationFrame, notifColor, 1, 0.35)

    frame({Parent = NotificationFrame, Size = UDim2.new(0, 3, 1, 0), Color = notifColor, ZIndex = 10001})

    local IconFrame = frame({
        Parent = NotificationFrame,
        Size = UDim2.new(0, isMobile and 32 or 36, 0, isMobile and 32 or 36),
        Position = UDim2.new(0, 12, 0.5, -(isMobile and 16 or 18)),
        Color = notifColor,
        Transparency = 0.88,
        Corner = 18,
        ZIndex = 10001,
    })
    label({Parent = IconFrame, Text = notifIcon, Font = Enum.Font.GothamBold, TextSize = isMobile and 16 or 18, Color = notifColor, XAlign = Enum.TextXAlignment.Center, ZIndex = 10002})

    local titleX = isMobile and 52 or 56
    local TitleLabel = label({
        Parent = NotificationFrame,
        Size = UDim2.new(1, -(titleX + 38), 0, 18),
        Position = UDim2.new(0, titleX, 0, isMobile and 12 or 10),
        Text = config.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = isMobile and 12 or 13,
        ZIndex = 10001,
    })
    local MessageLabel = label({
        Parent = NotificationFrame,
        Size = UDim2.new(1, -(titleX + 38), 0, isMobile and 32 or 30),
        Position = UDim2.new(0, titleX, 0, isMobile and 28 or 26),
        Text = config.Message or "",
        TextSize = isMobile and 10 or 11,
        Color = Theme.TextSecondary,
        YAlign = Enum.TextYAlignment.Top,
        Wrapped = true,
        ZIndex = 10001,
    })

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = randomName(10)
    CloseButton.Size = UDim2.new(0, isMobile and 28 or 24, 0, isMobile and 28 or 24)
    CloseButton.Position = UDim2.new(1, -(isMobile and 34 or 30), 0, 6)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "x"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = isMobile and 16 or 14
    CloseButton.TextColor3 = Theme.TextMuted
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 10002
    CloseButton.Parent = NotificationFrame

    local TimeBar = frame({Parent = NotificationFrame, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), Color = notifColor, ZIndex = 10001})

    table.insert(NotificationQueue, NotificationFrame)
    NotificationFrame.Position = UDim2.new(1, 50, 0, 0)
    NotificationFrame.BackgroundTransparency = 1
    tween(NotificationFrame, EASE_POP, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0})

    local duration = config.Duration or 5
    local timeBarTween = tween(TimeBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})

    local closed = false
    local function closeNotification()
        if closed then return end
        closed = true
        tween(NotificationFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        task.delay(0.25, function()
            for i, notif in ipairs(NotificationQueue) do
                if notif == NotificationFrame then table.remove(NotificationQueue, i) break end
            end
            if NotificationFrame then NotificationFrame:Destroy() end
        end)
    end

    CloseButton.MouseEnter:Connect(function() tween(CloseButton, EASE_SNAP, {TextColor3 = Theme.Error}) end)
    CloseButton.MouseLeave:Connect(function() tween(CloseButton, EASE_SNAP, {TextColor3 = Theme.TextMuted}) end)
    CloseButton.MouseButton1Click:Connect(function()
        timeBarTween:Cancel()
        closeNotification()
    end)
    task.delay(duration, closeNotification)
end

local WatermarkData = {Frame = nil, Connection = nil, TimeConnection = nil, Visible = false, FPS = 0, Ping = 0, FrameCount = 0, LastFPSUpdate = 0}

local function GetFormattedDate()
    local t = os.date("*t")
    return string.format("%02d/%02d/%04d", t.day, t.month, t.year)
end

local function GetFormattedTime()
    local t = os.date("*t")
    return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

local function CreateWatermark(screenGui)
    if WatermarkData.Frame then return WatermarkData.Frame end
    local wmHeight = isMobile and 34 or 30
    local wmWidth = isMobile and 340 or 430

    local WatermarkFrame = frame({
        Parent = screenGui,
        Size = UDim2.new(0, wmWidth, 0, wmHeight),
        Position = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 6 or 8),
        Color = Theme.Panel,
        Transparency = 1,
        Corner = 8,
        ZIndex = 9990,
        Visible = false,
    })
    stroke(WatermarkFrame, Theme.Primary, 1, 0.5)

    local TopAccent = frame({Parent = WatermarkFrame, Size = UDim2.new(1, 0, 0, 2), Color = Theme.Primary, ZIndex = 9992})
    local AccentGradient = gradient(TopAccent, 0, {
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Primary),
    })

    task.spawn(function()
        while WatermarkFrame and WatermarkFrame.Parent do
            tween(AccentGradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)})
            task.wait(3)
            tween(AccentGradient, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(-1, 0)})
            task.wait(3)
        end
    end)

    local iconSize = isMobile and 8 or 7
    local LogoDot = frame({Parent = WatermarkFrame, Size = UDim2.new(0, iconSize, 0, iconSize), Position = UDim2.new(0, 10, 0.5, -iconSize/2), Color = Theme.Primary, Corner = iconSize/2, ZIndex = 9993})
    RegisterThemeElement(LogoDot, "BackgroundColor3")
    tween(LogoDot, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.5})

    local sepX = 10 + iconSize + 8

    local function MakeSep(xOffset)
        return frame({Parent = WatermarkFrame, Size = UDim2.new(0, 1, 0, isMobile and 14 or 16), Position = UDim2.new(0, xOffset, 0.5, isMobile and -7 or -8), Color = Theme.Border, ZIndex = 9993})
    end

    local Sep1 = MakeSep(sepX)
    local nickW = isMobile and 80 or 100
    local NickLabel = label({Parent = WatermarkFrame, Size = UDim2.new(0, nickW, 1, 0), Position = UDim2.new(0, sepX + 8, 0, 0), Text = Player.DisplayName, Font = Enum.Font.GothamBold, TextSize = isMobile and 10 or 11, ZIndex = 9993})

    local sep2X = sepX + 8 + nickW + 4
    MakeSep(sep2X)
    local dateW = isMobile and 68 or 80
    local DateLabel = label({Parent = WatermarkFrame, Size = UDim2.new(0, dateW, 1, 0), Position = UDim2.new(0, sep2X + 8, 0, 0), Text = GetFormattedDate(), Font = Enum.Font.GothamMedium, TextSize = isMobile and 9 or 10, Color = Theme.TextSecondary, ZIndex = 9993})

    local sep3X = sep2X + 8 + dateW + 4
    MakeSep(sep3X)
    local timeW = isMobile and 56 or 66
    local TimeLabel = label({Parent = WatermarkFrame, Size = UDim2.new(0, timeW, 1, 0), Position = UDim2.new(0, sep3X + 8, 0, 0), Text = GetFormattedTime(), Font = Enum.Font.GothamMedium, TextSize = isMobile and 9 or 10, Color = Theme.Primary, ZIndex = 9993})
    RegisterThemeElement(TimeLabel, "TextColor3")

    local sep4X = sep3X + 8 + timeW + 4
    MakeSep(sep4X)
    local fpsW = isMobile and 48 or 54
    local FPSLabel = label({Parent = WatermarkFrame, Size = UDim2.new(0, fpsW, 1, 0), Position = UDim2.new(0, sep4X + 8, 0, 0), Text = "0 FPS", Font = Enum.Font.GothamMedium, TextSize = isMobile and 9 or 10, Color = Theme.Success, ZIndex = 9993})

    local sep5X = sep4X + 8 + fpsW + 4
    MakeSep(sep5X)
    local pingW = isMobile and 48 or 54
    local PingLabel = label({Parent = WatermarkFrame, Size = UDim2.new(0, pingW, 1, 0), Position = UDim2.new(0, sep5X + 8, 0, 0), Text = "0ms", Font = Enum.Font.GothamMedium, TextSize = isMobile and 9 or 10, Color = Theme.Info, ZIndex = 9993})

    dragify(WatermarkFrame, WatermarkFrame)

    WatermarkData.Connection = RunService.Heartbeat:Connect(function(dt)
        if not WatermarkFrame or not WatermarkFrame.Parent then
            if WatermarkData.Connection then WatermarkData.Connection:Disconnect() end
            return
        end
        WatermarkData.FrameCount = WatermarkData.FrameCount + 1
        WatermarkData.LastFPSUpdate = WatermarkData.LastFPSUpdate + dt
        if WatermarkData.LastFPSUpdate >= 0.5 then
            WatermarkData.FPS = math.floor(WatermarkData.FrameCount / WatermarkData.LastFPSUpdate)
            WatermarkData.FrameCount = 0
            WatermarkData.LastFPSUpdate = 0
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            WatermarkData.Ping = ping
            FPSLabel.Text = WatermarkData.FPS .. " FPS"
            FPSLabel.TextColor3 = WatermarkData.FPS >= 55 and Theme.Success or (WatermarkData.FPS >= 30 and Theme.Warning or Theme.Error)
            PingLabel.Text = ping .. "ms"
            PingLabel.TextColor3 = ping <= 80 and Theme.Success or (ping <= 150 and Theme.Warning or Theme.Error)
        end
    end)

    WatermarkData.TimeConnection = RunService.Heartbeat:Connect(function()
        if not WatermarkFrame or not WatermarkFrame.Parent then
            if WatermarkData.TimeConnection then WatermarkData.TimeConnection:Disconnect() end
            return
        end
        DateLabel.Text = GetFormattedDate()
        TimeLabel.Text = GetFormattedTime()
    end)

    WatermarkData.Frame = WatermarkFrame
    return WatermarkFrame
end

local function ShowWatermark(screenGui)
    if not WatermarkData.Frame then CreateWatermark(screenGui) end
    WatermarkData.Frame.Visible = true
    WatermarkData.Visible = true
    WatermarkData.Frame.BackgroundTransparency = 1
    tween(WatermarkData.Frame, EASE_OUT, {BackgroundTransparency = 0})
end

local function HideWatermark()
    if not WatermarkData.Frame then return end
    WatermarkData.Visible = false
    tween(WatermarkData.Frame, EASE_IN, {BackgroundTransparency = 1})
    task.delay(0.2, function()
        if WatermarkData.Frame and not WatermarkData.Visible then WatermarkData.Frame.Visible = false end
    end)
end

function QuantomLib:CreateWindow(config)
    config = config or {}
    local Window = {}
    Window.Name = config.Name or "QUANTOM.GG"
    Window.Version = config.Version or "v1.0.0"
    Window.Categories = {}
    Window.Flags = {}
    local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local HUDRegistry = {}
    local HUDFrame, HUDVisible, HUDConnection = nil, false, nil

    local floatBtnSize = isMobile and 60 or 50
    local floatBtnVisible = true

    local configDir = "QuantomLib"
    local configSubDir = configDir .. "/" .. Window.Name:gsub("[^%w]", "_")

    local function ensureConfigDir()
        pcall(function()
            if not isfolder(configDir) then makefolder(configDir) end
            if not isfolder(configSubDir) then makefolder(configSubDir) end
        end)
    end

    function Window:SaveConfig(name)
        if not name or name == "" then return false end
        ensureConfigDir()
        local data = {}
        for flag, info in pairs(Window.Flags) do
            local entry = {Flag = flag, Type = info.Type}
            if info.Type == "ColorPicker" then
                local vals = {info.GetValue()}
                local col, alp = vals[1], vals[2]
                entry.Value = {R = col.R, G = col.G, B = col.B, A = alp}
            elseif info.Type == "Keybind" then
                local val = info.GetValue()
                entry.Value = typeof(val) == "EnumItem" and val.Name or tostring(val)
            else
                entry.Value = info.GetValue()
            end
            table.insert(data, entry)
        end
        local ok = pcall(function()
            writefile(configSubDir .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        end)
        return ok
    end

    function Window:LoadConfig(name)
        local path = configSubDir .. "/" .. name .. ".json"
        local ok, content = pcall(readfile, path)
        if not ok or not content then return false end
        local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
        if not ok2 or not data then return false end
        for _, entry in ipairs(data) do
            local info = Window.Flags[entry.Flag]
            if info and entry.Value ~= nil then
                if entry.Type == "ColorPicker" then
                    local v = entry.Value
                    info.SetValue(Color3.new(v.R, v.G, v.B), v.A)
                elseif entry.Type == "Keybind" then
                    local key = Enum.KeyCode[entry.Value]
                    if key then info.SetValue(key) end
                else
                    info.SetValue(entry.Value)
                end
            end
        end
        return true
    end

    function Window:GetConfigList()
        local list = {}
        pcall(function()
            ensureConfigDir()
            for _, path in ipairs(listfiles(configSubDir)) do
                local name = path:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end)
        return list
    end

    function Window:DeleteConfig(name)
        pcall(delfile, configSubDir .. "/" .. name .. ".json")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = randomName(16)
    ScreenGui:SetAttribute(QUANTOM_TAG, true)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    local uiWidth, uiHeight
    if isMobile then
        uiWidth = math.min(viewportSize.X * 0.95, 500)
        uiHeight = math.min(viewportSize.Y * 0.85, 600)
    else
        uiWidth, uiHeight = 900, 580
    end

    local MainContainer = frame({
        Parent = ScreenGui,
        Size = UDim2.new(0, uiWidth, 0, uiHeight),
        Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2),
        Color = Theme.Background,
        Corner = 10,
        Visible = false,
        ZIndex = 10,
    })
    stroke(MainContainer, Theme.Border, 1, 0.25)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = randomName(10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.45
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Size = UDim2.new(1, 60, 1, 60)
    Shadow.Position = UDim2.new(0, -30, 0, -30)
    Shadow.ZIndex = 1
    Shadow.Parent = MainContainer

    local ClipFrame = frame({Parent = MainContainer, Size = UDim2.new(1, 0, 1, 0), Color = Theme.Background, Corner = 10, Clip = true, ZIndex = 2})

    local TopGlow = frame({Parent = ClipFrame, Size = UDim2.new(1, 0, 0, 2), Color = Theme.Primary, ZIndex = 15})
    gradient(TopGlow, 0, {
        ColorSequenceKeypoint.new(0, Theme.Background),
        ColorSequenceKeypoint.new(0.5, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Background),
    })

    local BackgroundEffects = frame({Parent = ClipFrame, Transparency = 1, Clip = true, ZIndex = 0})
    for i = 1, isMobile and 6 or 12 do
        local particle = frame({
            Parent = BackgroundEffects,
            Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            Color = Theme.Primary,
            Transparency = math.random(85, 95) / 100,
            Corner = 4,
            ZIndex = 0,
        })
        tween(particle, TweenInfo.new(math.random(8, 15), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundTransparency = math.random(90, 98) / 100,
        })
    end

    local headerHeight = isMobile and 50 or 46
    local Header = frame({Parent = ClipFrame, Size = UDim2.new(1, 0, 0, headerHeight), Color = Theme.Panel, ZIndex = 3})
    stroke(Header, Theme.BorderSoft, 1, 0.5)
    if not isMobile then dragify(Header, MainContainer) end

    local LogoDot = frame({Parent = Header, Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 16, 0.5, -4), Color = Theme.Primary, Corner = 4, ZIndex = 4})
    tween(LogoDot, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = Theme.Accent})

    label({Parent = Header, Size = UDim2.new(0, 220, 0, 16), Position = UDim2.new(0, 32, 0, isMobile and 10 or 8), Text = Window.Name, Font = Enum.Font.GothamBold, TextSize = isMobile and 13 or 14, ZIndex = 4})
    local StatusText = label({Parent = Header, Size = UDim2.new(0, 120, 0, 14), Position = UDim2.new(0, 32, 0, isMobile and 27 or 24), Text = Window.Version, Font = Enum.Font.Gotham, TextSize = 10, Color = Theme.Success, ZIndex = 4})

    local buttonSize = isMobile and 32 or 28
    local CloseButton = frame({Parent = Header, Size = UDim2.new(0, buttonSize, 0, buttonSize), Position = UDim2.new(1, -buttonSize - 10, 0.5, -buttonSize/2), Color = Theme.PanelAlt, Corner = 6, ZIndex = 4})
    label({Parent = CloseButton, Text = "x", Font = Enum.Font.GothamBold, TextSize = isMobile and 15 or 13, Color = Theme.TextMuted, XAlign = Enum.TextXAlignment.Center, ZIndex = 5})
    local CloseClick = Instance.new("TextButton")
    CloseClick.Size, CloseClick.BackgroundTransparency, CloseClick.Text, CloseClick.ZIndex, CloseClick.Parent = UDim2.new(1,0,1,0), 1, "", 6, CloseButton

    local MinimizeButton = frame({Parent = Header, Size = UDim2.new(0, buttonSize, 0, buttonSize), Position = UDim2.new(1, -(buttonSize*2 + 18), 0.5, -buttonSize/2), Color = Theme.PanelAlt, Corner = 6, ZIndex = 4})
    label({Parent = MinimizeButton, Text = "-", Font = Enum.Font.GothamBold, TextSize = isMobile and 16 or 14, Color = Theme.TextMuted, XAlign = Enum.TextXAlignment.Center, ZIndex = 5})
    local MinClick = Instance.new("TextButton")
    MinClick.Size, MinClick.BackgroundTransparency, MinClick.Text, MinClick.ZIndex, MinClick.Parent = UDim2.new(1,0,1,0), 1, "", 6, MinimizeButton

    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = randomName(14)
    FloatingButton.Size = UDim2.new(0, floatBtnSize, 0, floatBtnSize)
    FloatingButton.Position = UDim2.new(1, -70, 0, 100)
    FloatingButton.BackgroundColor3 = Theme.Primary
    FloatingButton.BorderSizePixel = 0
    FloatingButton.Visible = isMobile
    FloatingButton.Image = ""
    FloatingButton.ZIndex = 1000
    FloatingButton.Parent = ScreenGui
    corner(25, FloatingButton)
    local FloatIcon = label({Parent = FloatingButton, Text = "Q", Font = Enum.Font.GothamBold, TextSize = isMobile and 28 or 24, Color = Color3.fromRGB(10, 12, 15), XAlign = Enum.TextXAlignment.Center, ZIndex = 1001})

    local floatTween = tween(FloatingButton, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, floatBtnSize + 5, 0, floatBtnSize + 5)})

    local floatDragging, floatDragStart, floatStartPos, floatDragMoved = false, nil, nil, false
    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging, floatDragMoved = true, false
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
            if delta.Magnitude > 5 then floatDragMoved = true end
            FloatingButton.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
        end
    end)
    FloatingButton.MouseButton1Click:Connect(function()
        if floatDragMoved then return end
        MainContainer.Visible = true
        FloatingButton.Visible = false
    end)

    local sidebarWidth = isMobile and 100 or 160
    local playerCardHeight = isMobile and 68 or 62

    local Sidebar = frame({Parent = ClipFrame, Size = UDim2.new(0, sidebarWidth, 1, -headerHeight), Position = UDim2.new(0, 0, 0, headerHeight), Color = Theme.Sidebar, ZIndex = 2})
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = Sidebar
    pad(Sidebar, 0, 0, 8, playerCardHeight + 4)

    frame({Parent = ClipFrame, Size = UDim2.new(0, sidebarWidth, 0, 1), Position = UDim2.new(0, 0, 1, -(playerCardHeight + 1)), Color = Theme.BorderSoft, ZIndex = 3})

    local PlayerCard = frame({Parent = ClipFrame, Size = UDim2.new(0, sidebarWidth, 0, playerCardHeight), Position = UDim2.new(0, 0, 1, -playerCardHeight), Color = Theme.Sidebar, ZIndex = 3})

    local AvatarSize = isMobile and 38 or 36
    local AvatarBorder = frame({Parent = PlayerCard, Size = UDim2.new(0, AvatarSize + 4, 0, AvatarSize + 4), Position = UDim2.new(0, isMobile and 8 or 10, 0.5, -(AvatarSize/2 + 2)), Color = Theme.Primary, Transparency = 0.4, Corner = (AvatarSize+4)/2, ZIndex = 4})
    local AvatarFrame = frame({Parent = AvatarBorder, Size = UDim2.new(0, AvatarSize, 0, AvatarSize), Position = UDim2.new(0.5, -AvatarSize/2, 0.5, -AvatarSize/2), Color = Theme.Elevated, Corner = AvatarSize/2, Clip = true, ZIndex = 5})
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = randomName(11)
    AvatarImage.Size = UDim2.new(1, 0, 1, 0)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = ""
    AvatarImage.ScaleType = Enum.ScaleType.Crop
    AvatarImage.ZIndex = 6
    AvatarImage.Parent = AvatarFrame

    local realDisplayName = Player.DisplayName
    local realUserName = Player.Name
    local realAvatarImage = ""
    local robloxAvatarImage = ""
    local anonymousMode = false

    task.spawn(function()
        local ok, imgId = pcall(function()
            return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and imgId then
            realAvatarImage = imgId
            if not anonymousMode then AvatarImage.Image = imgId end
        end
    end)
    task.spawn(function()
        local ok, imgId = pcall(function()
            return Players:GetUserThumbnailAsync(1, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and imgId then robloxAvatarImage = imgId end
    end)

    local OnlineDot = frame({Parent = AvatarBorder, Size = UDim2.new(0, isMobile and 10 or 9, 0, isMobile and 10 or 9), Position = UDim2.new(1, -(isMobile and 10 or 9), 1, -(isMobile and 10 or 9)), Color = Theme.Success, Corner = 5, ZIndex = 7})
    stroke(OnlineDot, Theme.Sidebar, 2, 0)

    local textOffsetX = isMobile and (AvatarSize + 20) or (AvatarSize + 24)
    local PlayerDisplayName = label({Parent = PlayerCard, Size = UDim2.new(1, -(textOffsetX + 6), 0, isMobile and 14 or 13), Position = UDim2.new(0, textOffsetX, 0, isMobile and 14 or 13), Text = Player.DisplayName, Font = Enum.Font.GothamBold, TextSize = isMobile and 10 or 11, ZIndex = 4})
    local PlayerUserName = label({Parent = PlayerCard, Size = UDim2.new(1, -(textOffsetX + 6), 0, isMobile and 12 or 11), Position = UDim2.new(0, textOffsetX, 0, isMobile and 30 or 28), Text = "@" .. Player.Name, TextSize = isMobile and 9 or 10, Color = Theme.TextMuted, ZIndex = 4})

    local AnonBadge = frame({Parent = PlayerCard, Size = UDim2.new(0, isMobile and 38 or 42, 0, isMobile and 12 or 13), Position = UDim2.new(0, textOffsetX, 0, isMobile and 46 or 43), Color = Color3.fromRGB(80, 80, 100), Transparency = 1, Corner = 3, Visible = false, ZIndex = 5})
    label({Parent = AnonBadge, Text = "ANON", Font = Enum.Font.GothamBold, TextSize = isMobile and 7 or 8, Color = Color3.fromRGB(200, 200, 215), XAlign = Enum.TextXAlignment.Center, ZIndex = 6})

    local AvatarClickButton = Instance.new("TextButton")
    AvatarClickButton.Size, AvatarClickButton.BackgroundTransparency, AvatarClickButton.Text, AvatarClickButton.ZIndex, AvatarClickButton.Parent = UDim2.new(1,0,1,0), 1, "", 8, AvatarBorder

    local function applyAnonymousMode(state)
        anonymousMode = state
        local targetImg = state and robloxAvatarImage or realAvatarImage
        tween(AvatarImage, TweenInfo.new(0.2), {ImageTransparency = 1})
        task.delay(0.15, function()
            AvatarImage.Image = targetImg
            tween(AvatarImage, TweenInfo.new(0.2), {ImageTransparency = 0})
        end)
        tween(PlayerDisplayName, TweenInfo.new(0.2), {TextTransparency = 1})
        tween(PlayerUserName, TweenInfo.new(0.2), {TextTransparency = 1})
        task.delay(0.2, function()
            PlayerDisplayName.Text = state and "Roblox" or realDisplayName
            PlayerUserName.Text = state and "@Roblox" or ("@" .. realUserName)
            tween(PlayerDisplayName, TweenInfo.new(0.2), {TextTransparency = 0})
            tween(PlayerUserName, TweenInfo.new(0.2), {TextTransparency = 0})
        end)
        tween(AvatarBorder, TweenInfo.new(0.25), {BackgroundColor3 = state and Color3.fromRGB(80, 80, 100) or Theme.Primary})
        tween(OnlineDot, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(120, 120, 140) or Theme.Success})
        AnonBadge.Visible = true
        tween(AnonBadge, TweenInfo.new(0.2), {BackgroundTransparency = state and 0.3 or 1})
        if not state then task.delay(0.2, function() AnonBadge.Visible = false end) end
        PlaySound(state and Sounds.ToggleOff or Sounds.ToggleOn, 0.3, state and 0.85 or 1.1)
    end
    AvatarClickButton.MouseButton1Click:Connect(function() applyAnonymousMode(not anonymousMode) end)

    local ContentArea = frame({Parent = ClipFrame, Size = UDim2.new(1, -sidebarWidth, 1, -headerHeight), Position = UDim2.new(0, sidebarWidth, 0, headerHeight), Transparency = 1, ZIndex = 2})

    local Pop = Instance.new("Frame")
    Pop.Name = randomName(10)
    Pop.BackgroundTransparency = 1
    Pop.Size = UDim2.new(1, 0, 1, 0)
    Pop.ZIndex = 500
    Pop.Parent = MainContainer

    local currentOpenDropdown = nil
    local currentTab = nil

    CloseClick.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        if isMobile and floatBtnVisible then FloatingButton.Visible = true end
    end)
    CloseClick.MouseEnter:Connect(function() tween(CloseButton, EASE_SNAP, {BackgroundColor3 = Theme.Error}) end)
    CloseClick.MouseLeave:Connect(function() tween(CloseButton, EASE_SNAP, {BackgroundColor3 = Theme.PanelAlt}) end)
    MinClick.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        if isMobile and floatBtnVisible then FloatingButton.Visible = true end
    end)
    MinClick.MouseEnter:Connect(function() tween(MinimizeButton, EASE_SNAP, {BackgroundColor3 = Theme.Elevated}) end)
    MinClick.MouseLeave:Connect(function() tween(MinimizeButton, EASE_SNAP, {BackgroundColor3 = Theme.PanelAlt}) end)

    function Window:Notify(cfg)
        CreateNotification(ScreenGui, cfg)
    end

    local function CreateHUD()
        if HUDFrame then HUDFrame:Destroy() HUDFrame = nil end
        if HUDConnection then HUDConnection:Disconnect() HUDConnection = nil end
        local rowH = isMobile and 26 or 22
        local hudW = isMobile and 210 or 230
        local hHeaderH = isMobile and 30 or 28
        local count = #HUDRegistry
        local hudH = hHeaderH + math.max(count, 1) * rowH + 8

        local HUD = frame({Parent = ScreenGui, Size = UDim2.new(0, hudW, 0, hudH), Position = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 42 or 48), Color = Theme.Panel, Transparency = 1, Corner = 8, ZIndex = 8000})
        stroke(HUD, Theme.Primary, 1, 0.5)
        local HUDAccent = frame({Parent = HUD, Size = UDim2.new(1, 0, 0, 2), Color = Theme.Primary, ZIndex = 8001})
        gradient(HUDAccent, 0, {ColorSequenceKeypoint.new(0, Theme.Primary), ColorSequenceKeypoint.new(0.5, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.Primary)})

        local HUDHeader = frame({Parent = HUD, Size = UDim2.new(1, 0, 0, hHeaderH), Color = Theme.PanelAlt, ZIndex = 8001})
        frame({Parent = HUDHeader, Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 10, 0.5, -3), Color = Theme.Primary, Corner = 3, ZIndex = 8002})
        label({Parent = HUDHeader, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 22, 0, 0), Text = "KEYBIND LIST", Font = Enum.Font.GothamBold, TextSize = isMobile and 9 or 10, Color = Theme.TextMuted, ZIndex = 8002})

        local HUDHide = frame({Parent = HUDHeader, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -26, 0.5, -11), Color = Theme.Elevated, Corner = 5, ZIndex = 8002})
        label({Parent = HUDHide, Text = "-", Font = Enum.Font.GothamBold, TextSize = isMobile and 14 or 13, Color = Theme.TextMuted, XAlign = Enum.TextXAlignment.Center, ZIndex = 8003})
        local HUDHideClick = Instance.new("TextButton")
        HUDHideClick.Size, HUDHideClick.BackgroundTransparency, HUDHideClick.Text, HUDHideClick.ZIndex, HUDHideClick.Parent = UDim2.new(1,0,1,0), 1, "", 8004, HUDHide

        HUDHideClick.MouseButton1Click:Connect(function()
            HUDVisible = false
            tween(HUD, EASE_IN, {BackgroundTransparency = 1})
            task.delay(0.2, function() if HUD and HUD.Parent then HUD.Visible = false end end)
        end)
        dragify(HUDHeader, HUD)

        local HUDContent = frame({Parent = HUD, Size = UDim2.new(1, 0, 1, -hHeaderH), Position = UDim2.new(0, 0, 0, hHeaderH), Transparency = 1, ZIndex = 8001})
        local HUDList = Instance.new("UIListLayout")
        HUDList.SortOrder = Enum.SortOrder.LayoutOrder
        HUDList.Parent = HUDContent
        pad(HUDContent, 8, 8, 4, 4)

        local rowRefs = {}
        for i, entry in ipairs(HUDRegistry) do
            local Row = frame({Parent = HUDContent, Size = UDim2.new(1, 0, 0, 0), Transparency = 1, Clip = true, ZIndex = 8002})
            Row.LayoutOrder = i
            local Dot = frame({Parent = Row, Size = UDim2.new(0, isMobile and 7 or 6, 0, isMobile and 7 or 6), Position = UDim2.new(0, 0, 0.5, isMobile and -3.5 or -3), Color = Theme.Success, Corner = 3, ZIndex = 8003})
            local NameLabel = label({Parent = Row, Size = UDim2.new(1, -(isMobile and 70 or 80), 1, 0), Position = UDim2.new(0, isMobile and 13 or 12, 0, 0), Text = entry.Name, Font = Enum.Font.GothamMedium, TextSize = 10, ZIndex = 8003})
            local KeyTag = frame({Parent = Row, Size = UDim2.new(0, isMobile and 28 or 32, 0, isMobile and 16 or 14), Position = UDim2.new(1, -(isMobile and 62 or 72), 0.5, isMobile and -8 or -7), Color = Theme.Elevated, Corner = 3, ZIndex = 8004})
            stroke(KeyTag, Theme.Border, 1, 0.3)
            local KeyTagText = label({Parent = KeyTag, Font = Enum.Font.GothamBold, TextSize = isMobile and 7 or 8, Color = Theme.TextSecondary, XAlign = Enum.TextXAlignment.Center, ZIndex = 8005})
            local StateTag = frame({Parent = Row, Size = UDim2.new(0, isMobile and 28 or 34, 0, isMobile and 16 or 14), Position = UDim2.new(1, -(isMobile and 28 or 34), 0.5, isMobile and -8 or -7), Color = Theme.Success, Transparency = 0.5, Corner = 3, ZIndex = 8004})
            local StateText = label({Parent = StateTag, Font = Enum.Font.GothamBold, TextSize = isMobile and 7 or 8, XAlign = Enum.TextXAlignment.Center, ZIndex = 8005})
            rowRefs[i] = {Row = Row, Dot = Dot, KeyTagText = KeyTagText, StateTag = StateTag, StateText = StateText, NameLabel = NameLabel, Entry = entry, visible = false}
        end

        local lastVisibleCount = -1
        HUDConnection = RunService.Heartbeat:Connect(function()
            if not HUD or not HUD.Parent then
                if HUDConnection then HUDConnection:Disconnect() end
                return
            end
            local visibleCount = 0
            for _, ref in ipairs(rowRefs) do
                local entry = ref.Entry
                local state = entry.GetState and entry.GetState()
                local eType = entry.Type or "Toggle"
                local shouldShow = (eType == "Hold") or (eType == "Action") or (state == true)
                if shouldShow then
                    visibleCount = visibleCount + 1
                    if not ref.visible then
                        ref.visible = true
                        tween(ref.Row, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, rowH)})
                    end
                    local key = entry.GetKey and entry.GetKey() or "-"
                    ref.KeyTagText.Text = #key > 4 and key:sub(1,4) or key
                    local col = eType == "Hold" and Theme.Warning or (eType == "Action" and Theme.Info or Theme.Success)
                    local txt = eType == "Hold" and "HOLD" or (eType == "Action" and "ACT" or "ON")
                    ref.StateTag.BackgroundColor3 = col
                    ref.StateText.Text = txt
                    ref.StateText.TextColor3 = col
                    ref.Dot.BackgroundColor3 = col
                    ref.StateTag.BackgroundTransparency = 0.5
                elseif ref.visible then
                    ref.visible = false
                    tween(ref.Row, TweenInfo.new(0.12), {Size = UDim2.new(1, 0, 0, 0)})
                end
            end
            if visibleCount ~= lastVisibleCount then
                lastVisibleCount = visibleCount
                local newH = hHeaderH + math.max(visibleCount, 0) * rowH + (visibleCount > 0 and 8 or 4)
                tween(HUD, TweenInfo.new(0.2), {Size = UDim2.new(0, hudW, 0, newH)})
            end
        end)

        HUD.BackgroundTransparency = 1
        tween(HUD, EASE_POP, {BackgroundTransparency = 0.05})
        HUDFrame, HUDVisible = HUD, true
    end

    local function ShowHUD()
        if HUDFrame and HUDFrame.Parent then
            HUDFrame.Visible = true
            HUDVisible = true
            tween(HUDFrame, EASE_POP, {BackgroundTransparency = 0.05})
            return
        end
        CreateHUD()
    end

    local function HideHUD()
        if not HUDFrame or not HUDFrame.Parent then return end
        HUDVisible = false
        tween(HUDFrame, EASE_IN, {BackgroundTransparency = 1})
        task.delay(0.2, function() if HUDFrame and HUDFrame.Parent then HUDFrame.Visible = false end end)
    end

    function Window:CreateTab(cfg)
        cfg = cfg or {}
        local Tab = {}
        Tab.Name = cfg.Name or "Tab"
        Tab.Icon = cfg.Icon or "*"
        local catHeight = isMobile and 36 or 38

        local CategoryButton = frame({Parent = Sidebar, Size = UDim2.new(1, 0, 0, catHeight), Transparency = 1, ZIndex = 3})
        CategoryButton.LayoutOrder = cfg._order or (#Window.Categories + 1)

        local Icon = label({Parent = CategoryButton, Size = UDim2.new(0, isMobile and 14 or 18, 0, isMobile and 14 or 18), Position = UDim2.new(0, isMobile and 10 or 15, 0.5, -(isMobile and 7 or 9)), Text = Tab.Icon, Font = Enum.Font.GothamBold, TextSize = isMobile and 11 or 13, Color = Theme.TextMuted, XAlign = Enum.TextXAlignment.Center, ZIndex = 4})
        local Label = label({Parent = CategoryButton, Size = UDim2.new(1, isMobile and -32 or -45, 1, 0), Position = UDim2.new(0, isMobile and 28 or 40, 0, 0), Text = isMobile and Tab.Name:sub(1, 6) or Tab.Name, TextSize = isMobile and 10 or 12, Color = Theme.TextSecondary, ZIndex = 4})
        local Indicator = frame({Parent = CategoryButton, Size = UDim2.new(0, 0, 0, catHeight), Color = Theme.Primary, ZIndex = 3})

        local CategoryClick = Instance.new("TextButton")
        CategoryClick.Size, CategoryClick.BackgroundTransparency, CategoryClick.Text, CategoryClick.ZIndex, CategoryClick.Parent = UDim2.new(1,0,1,0), 1, "", 6, CategoryButton

        local contentPadding = isMobile and 8 or 10
        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Name = randomName(16)
        ContentScroll.Size = UDim2.new(1, -contentPadding*2, 1, -contentPadding*2)
        ContentScroll.Position = UDim2.new(0, contentPadding, 0, contentPadding)
        ContentScroll.BackgroundTransparency = 1
        ContentScroll.BorderSizePixel = 0
        ContentScroll.ScrollBarThickness = isMobile and 6 or 3
        ContentScroll.ScrollBarImageColor3 = Theme.Primary
        ContentScroll.ScrollBarImageTransparency = 0.4
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
        Tab._window = Window
        Tab._popLayer = Pop
        Tab._mainContainer = MainContainer

        CategoryClick.MouseEnter:Connect(function()
            if currentTab ~= Tab then
                tween(CategoryButton, EASE_SNAP, {BackgroundTransparency = 0.6})
                tween(Label, EASE_SNAP, {TextColor3 = Theme.Text})
            end
        end)
        CategoryClick.MouseLeave:Connect(function()
            if currentTab ~= Tab then
                tween(CategoryButton, EASE_SNAP, {BackgroundTransparency = 1})
                tween(Label, EASE_SNAP, {TextColor3 = Theme.TextSecondary})
            end
        end)

        local function activateTab()
            if currentOpenDropdown then currentOpenDropdown() currentOpenDropdown = nil end
            PlaySound(Sounds.Click, 0.25, 1.1)
            for _, cat in pairs(Window.Categories) do
                cat.ContentScroll.Visible = false
            end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("Frame") and child ~= CategoryButton then
                    for _, sub in pairs(child:GetChildren()) do
                        if sub:IsA("TextLabel") then
                            tween(sub, EASE_SNAP, {TextColor3 = Theme.TextSecondary})
                        elseif sub:IsA("Frame") and sub.Size.Y.Offset == catHeight and sub.Size.X.Offset <= 4 then
                            tween(sub, EASE_SNAP, {Size = UDim2.new(0, 0, 0, catHeight)})
                        end
                    end
                    tween(child, EASE_SNAP, {BackgroundTransparency = 1})
                end
            end
            ContentScroll.Visible = true
            currentTab = Tab
            tween(CategoryButton, EASE_SNAP, {BackgroundTransparency = 0.3})
            tween(Label, EASE_SNAP, {TextColor3 = Theme.Text})
            tween(Icon, EASE_SNAP, {TextColor3 = Theme.Primary})
            tween(Indicator, EASE_SNAP, {Size = UDim2.new(0, 3, 0, catHeight)})
            if Tab._onActivate then Tab._onActivate() end
        end
        Tab._activate = activateTab

        CategoryClick.MouseButton1Click:Connect(activateTab)

        function Tab:AddSection(title)
            label({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 20 or 22), Text = title:upper(), Font = Enum.Font.GothamBold, TextSize = isMobile and 10 or 11, Color = Theme.TextMuted, ZIndex = 3})
        end

        function Tab:AddToggle(cfg2)
            cfg2 = cfg2 or {}
            local toggleState = cfg2.Default or false
            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 36 or 32), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = cfg2.Name or "Toggle", TextSize = isMobile and 11 or 12, ZIndex = 4})

            local Track = frame({Parent = Row, Size = UDim2.new(0, isMobile and 42 or 38, 0, isMobile and 22 or 18), Position = UDim2.new(1, isMobile and -52 or -48, 0.5, isMobile and -11 or -9), Color = toggleState and Theme.Toggle or Theme.ToggleOff, Corner = 9, ZIndex = 4})
            local Knob = frame({Parent = Track, Size = UDim2.new(0, isMobile and 18 or 14, 0, isMobile and 18 or 14), Position = toggleState and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7), Color = Color3.fromRGB(255,255,255), Corner = 9, ZIndex = 5})

            local Click = Instance.new("TextButton")
            Click.Size, Click.BackgroundTransparency, Click.Text, Click.ZIndex, Click.Parent = UDim2.new(1,0,1,0), 1, "", 6, Row

            local function applyVisual(v)
                tween(Track, EASE_SNAP, {BackgroundColor3 = v and Theme.Toggle or Theme.ToggleOff})
                tween(Knob, EASE_SNAP, {Position = v and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)})
            end

            Click.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                applyVisual(toggleState)
                PlaySound(toggleState and Sounds.ToggleOn or Sounds.ToggleOff, 0.35, 1)
                if cfg2.Callback then task.spawn(cfg2.Callback, toggleState) end
            end)

            if not cfg2.HideFromHUD then
                table.insert(HUDRegistry, {Name = cfg2.Name or "Toggle", Type = "Toggle", GetState = function() return toggleState end, GetKey = function() return cfg2.HUDKey or "-" end})
            end
            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {
                    Type = "Toggle",
                    GetValue = function() return toggleState end,
                    SetValue = function(v)
                        toggleState = v
                        applyVisual(toggleState)
                        if cfg2.Callback then cfg2.Callback(toggleState) end
                    end,
                }
            end
            return {SetValue = function(_, v) toggleState = v applyVisual(toggleState) if cfg2.Callback then cfg2.Callback(toggleState) end end, GetValue = function() return toggleState end}
        end

        function Tab:AddButton(cfg2)
            cfg2 = cfg2 or {}
            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 36 or 32), Color = Theme.Elevated, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            local NameLabel = label({Parent = Row, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = cfg2.Name or "Button", TextSize = isMobile and 11 or 12, ZIndex = 4})
            local ArrowIcon = label({Parent = Row, Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -24, 0, 0), Text = ">", Font = Enum.Font.GothamBold, TextSize = 16, Color = Theme.Primary, XAlign = Enum.TextXAlignment.Center, ZIndex = 4})

            local Click = Instance.new("TextButton")
            Click.Size, Click.BackgroundTransparency, Click.Text, Click.ZIndex, Click.Parent = UDim2.new(1,0,1,0), 1, "", 6, Row

            Click.MouseEnter:Connect(function() tween(Row, EASE_SNAP, {BackgroundColor3 = Theme.PanelAlt}) tween(ArrowIcon, EASE_SNAP, {TextColor3 = Theme.Accent}) end)
            Click.MouseLeave:Connect(function() tween(Row, EASE_SNAP, {BackgroundColor3 = Theme.Elevated}) tween(ArrowIcon, EASE_SNAP, {TextColor3 = Theme.Primary}) end)
            Click.MouseButton1Down:Connect(function()
                PlaySound(Sounds.Click, 0.3, 1.2)
                tween(Row, TweenInfo.new(0.08), {BackgroundColor3 = Theme.Primary})
                tween(NameLabel, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(10,12,15)})
            end)
            Click.MouseButton1Up:Connect(function()
                tween(Row, EASE_SNAP, {BackgroundColor3 = Theme.Elevated})
                tween(NameLabel, EASE_SNAP, {TextColor3 = Theme.Text})
            end)
            Click.MouseButton1Click:Connect(function()
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end)
        end

        function Tab:AddSlider(cfg2)
            cfg2 = cfg2 or {}
            local min, max = cfg2.Min or 0, cfg2.Max or 100
            local sliderValue = cfg2.Default or min
            local dragging = false

            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 50 or 44), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(0.6, 0, 0, 16), Position = UDim2.new(0, 12, 0, 8), Text = cfg2.Name or "Slider", TextSize = isMobile and 10 or 11, Color = Theme.TextSecondary, ZIndex = 4})
            local ValueLabel = label({Parent = Row, Size = UDim2.new(0.4, -12, 0, 16), Position = UDim2.new(0.6, 0, 0, 8), Text = tostring(sliderValue), Font = Enum.Font.GothamBold, TextSize = isMobile and 10 or 11, Color = Theme.Primary, XAlign = Enum.TextXAlignment.Right, ZIndex = 4})

            local Track = frame({Parent = Row, Size = UDim2.new(1, -24, 0, isMobile and 5 or 4), Position = UDim2.new(0, 12, 1, -12), Color = Theme.SliderTrack, Corner = 2, ZIndex = 4})
            local Fill = frame({Parent = Track, Size = UDim2.new((sliderValue - min) / math.max(max - min, 0.0001), 0, 1, 0), Color = Theme.Primary, Corner = 2, ZIndex = 5})
            gradient(Fill, 0, {ColorSequenceKeypoint.new(0, Theme.PrimaryDark), ColorSequenceKeypoint.new(1, Theme.Primary)})

            local function updateSlider(input)
                local pos, size = Track.AbsolutePosition.X, Track.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - pos) / size, 0, 1)
                sliderValue = math.floor(min + ((max - min) * rel))
                ValueLabel.Text = tostring(sliderValue)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                if cfg2.Callback then task.spawn(cfg2.Callback, sliderValue) end
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    PlaySound(Sounds.Click, 0.2, 1.3)
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
            end)

            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {
                    Type = "Slider",
                    GetValue = function() return sliderValue end,
                    SetValue = function(v)
                        sliderValue = math.clamp(v, min, max)
                        ValueLabel.Text = tostring(sliderValue)
                        Fill.Size = UDim2.new((sliderValue - min) / math.max(max - min, 0.0001), 0, 1, 0)
                        if cfg2.Callback then cfg2.Callback(sliderValue) end
                    end,
                }
            end
            return {
                SetValue = function(_, v)
                    sliderValue = math.clamp(v, min, max)
                    ValueLabel.Text = tostring(sliderValue)
                    Fill.Size = UDim2.new((sliderValue - min) / math.max(max - min, 0.0001), 0, 1, 0)
                end,
                GetValue = function() return sliderValue end,
            }
        end

        function Tab:AddTextbox(cfg2)
            cfg2 = cfg2 or {}
            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 36 or 32), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = cfg2.Name or "Textbox", TextSize = isMobile and 11 or 12, ZIndex = 4})

            local Box = frame({Parent = Row, Size = UDim2.new(1, -110, 0, isMobile and 26 or 22), Position = UDim2.new(0, 95, 0.5, isMobile and -13 or -11), Color = Theme.Elevated, Corner = 5, ZIndex = 4})
            stroke(Box, Theme.BorderSoft, 1, 0.4)
            local Input = Instance.new("TextBox")
            Input.Name = randomName(12)
            Input.Size = UDim2.new(1, -16, 1, 0)
            Input.Position = UDim2.new(0, 8, 0, 0)
            Input.BackgroundTransparency = 1
            Input.Text = cfg2.Default or ""
            Input.PlaceholderText = cfg2.Placeholder or "Digite aqui..."
            Input.Font = Enum.Font.Gotham
            Input.TextSize = isMobile and 10 or 11
            Input.TextColor3 = Theme.Text
            Input.PlaceholderColor3 = Theme.TextMuted
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.ClearTextOnFocus = false
            Input.ZIndex = 5
            Input.Parent = Box

            Input.Focused:Connect(function() PlaySound(Sounds.Click, 0.2, 1.1) end)
            Input.FocusLost:Connect(function(enterPressed)
                if enterPressed and cfg2.Callback then
                    PlaySound(Sounds.ToggleOn, 0.25, 1.2)
                    cfg2.Callback(Input.Text)
                end
            end)

            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {Type = "Textbox", GetValue = function() return Input.Text end, SetValue = function(v) Input.Text = tostring(v) if cfg2.Callback then cfg2.Callback(Input.Text) end end}
            end
            return {SetValue = function(_, v) Input.Text = v end, GetValue = function() return Input.Text end}
        end

        function Tab:AddDropdown(cfg2)
            cfg2 = cfg2 or {}
            local options = cfg2.Options or {}
            local selected = cfg2.Default or options[1] or ""
            local open, transitioning = false, false
            local popFrame = nil

            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 46 or 40), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 0, 6), Text = cfg2.Name or "Dropdown", TextSize = 11, Color = Theme.TextMuted, ZIndex = 4})

            local Box = frame({Parent = Row, Size = UDim2.new(1, -20, 0, isMobile and 26 or 22), Position = UDim2.new(0, 10, 0, 20), Color = Theme.Elevated, Corner = 5, ZIndex = 4})
            stroke(Box, Theme.BorderSoft, 1, 0.4)
            pad(Box, 8, 8, 0, 0)
            local ValLabel = label({Parent = Box, Size = UDim2.new(1, -16, 1, 0), Text = tostring(selected), TextSize = 12, ZIndex = 5})
            local Arrow = label({Parent = Box, Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -14, 0, 0), Text = "v", TextSize = 11, Color = Theme.TextMuted, XAlign = Enum.TextXAlignment.Center, ZIndex = 5})

            local Click = Instance.new("TextButton")
            Click.Size, Click.BackgroundTransparency, Click.Text, Click.ZIndex, Click.Parent = UDim2.new(1,0,1,0), 1, "", 6, Box

            local function closePop()
                if not open then return end
                open, transitioning = false, true
                tween(Arrow, EASE_SNAP, {Rotation = 0})
                tween(Box, EASE_SNAP, {BackgroundColor3 = Theme.Elevated})
                local f = popFrame
                popFrame = nil
                if f then
                    tween(f, EASE_IN, {BackgroundTransparency = 1})
                    task.delay(0.16, function()
                        if f then f:Destroy() end
                        transitioning = false
                    end)
                else
                    transitioning = false
                end
                if currentOpenDropdown == closePop then currentOpenDropdown = nil end
            end

            local function openPop()
                if transitioning then return end
                if currentOpenDropdown and currentOpenDropdown ~= closePop then currentOpenDropdown() end
                PlaySound(Sounds.Click, 0.25, 0.95)
                open = true
                currentOpenDropdown = closePop
                tween(Arrow, EASE_SNAP, {Rotation = 180})
                tween(Box, EASE_SNAP, {BackgroundColor3 = Theme.PanelAlt})
                local optH = isMobile and 26 or 22
                local total = math.min(#options, 5) * optH + 2
                local abs = Box.AbsolutePosition
                local rootAbs = Tab._mainContainer.AbsolutePosition

                popFrame = frame({
                    Parent = Tab._popLayer,
                    Size = UDim2.new(0, Box.AbsoluteSize.X, 0, total),
                    Position = UDim2.new(0, abs.X - rootAbs.X, 0, abs.Y - rootAbs.Y + Box.AbsoluteSize.Y + 4),
                    Color = Theme.Elevated,
                    Corner = 6,
                    Clip = true,
                    Transparency = 1,
                    ZIndex = 510,
                })
                stroke(popFrame, Theme.Border, 1, 0.2)

                local OptScroll = Instance.new("ScrollingFrame")
                OptScroll.Size = UDim2.new(1, 0, 1, 0)
                OptScroll.BackgroundTransparency = 1
                OptScroll.BorderSizePixel = 0
                OptScroll.ScrollBarThickness = 2
                OptScroll.ScrollBarImageColor3 = Theme.Primary
                OptScroll.CanvasSize = UDim2.new(0, 0, 0, #options * optH)
                OptScroll.ZIndex = 511
                OptScroll.Parent = popFrame

                for i, opt in ipairs(options) do
                    local isSelected = opt == selected
                    local OptBtn = frame({Parent = OptScroll, Size = UDim2.new(1, 0, 0, optH), Position = UDim2.new(0, 0, 0, (i-1) * optH), Color = isSelected and Theme.Panel or Theme.Elevated, ZIndex = 512})
                    pad(OptBtn, 10, 8, 0, 0)
                    label({Parent = OptBtn, Text = tostring(opt), TextSize = 11, Color = isSelected and Theme.Primary or Theme.Text, ZIndex = 513})
                    local OptClick = Instance.new("TextButton")
                    OptClick.Size, OptClick.BackgroundTransparency, OptClick.Text, OptClick.ZIndex, OptClick.Parent = UDim2.new(1,0,1,0), 1, "", 514, OptBtn
                    OptClick.MouseEnter:Connect(function() tween(OptBtn, EASE_SNAP, {BackgroundColor3 = Theme.Panel}) end)
                    OptClick.MouseLeave:Connect(function() tween(OptBtn, EASE_SNAP, {BackgroundColor3 = isSelected and Theme.Panel or Theme.Elevated}) end)
                    OptClick.MouseButton1Click:Connect(function()
                        selected = opt
                        ValLabel.Text = tostring(opt)
                        PlaySound(Sounds.Click, 0.28, 1.15)
                        closePop()
                        if cfg2.Callback then task.spawn(cfg2.Callback, opt) end
                    end)
                end
                tween(popFrame, EASE_OUT, {BackgroundTransparency = 0})
            end

            Click.MouseButton1Click:Connect(function()
                if transitioning then return end
                if open then closePop() else openPop() end
            end)

            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {Type = "Dropdown", GetValue = function() return selected end, SetValue = function(v) selected = v ValLabel.Text = tostring(v) if cfg2.Callback then cfg2.Callback(v) end end}
            end
            return {SetValue = function(_, v) selected = v ValLabel.Text = tostring(v) end, GetValue = function() return selected end}
        end

        function Tab:AddKeybind(cfg2)
            cfg2 = cfg2 or {}
            local currentKey = cfg2.Default or Enum.KeyCode.E
            local blacklisted = {
                [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
                [Enum.KeyCode.Space] = true, [Enum.KeyCode.LeftShift] = true, [Enum.KeyCode.LeftControl] = true,
            }
            local listening = false

            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 36 or 32), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = cfg2.Name or "Keybind", TextSize = isMobile and 11 or 12, ZIndex = 4})

            local KeyBox = frame({Parent = Row, Size = UDim2.new(0, isMobile and 75 or 70, 0, isMobile and 26 or 22), Position = UDim2.new(1, isMobile and -85 or -80, 0.5, isMobile and -13 or -11), Color = Theme.Elevated, Corner = 5, ZIndex = 4})
            local KBStroke = stroke(KeyBox, Theme.Primary, 0, 0.5)
            local KeyLabel = label({Parent = KeyBox, Text = currentKey.Name, Font = Enum.Font.GothamBold, TextSize = isMobile and 10 or 11, Color = Theme.Primary, XAlign = Enum.TextXAlignment.Center, ZIndex = 5})

            local Click = Instance.new("TextButton")
            Click.Size, Click.BackgroundTransparency, Click.Text, Click.ZIndex, Click.Parent = UDim2.new(1,0,1,0), 1, "", 6, KeyBox

            Click.MouseEnter:Connect(function() if not listening then tween(KeyBox, EASE_SNAP, {BackgroundColor3 = Theme.PanelAlt}) tween(KBStroke, EASE_SNAP, {Thickness = 2}) end end)
            Click.MouseLeave:Connect(function() if not listening then tween(KeyBox, EASE_SNAP, {BackgroundColor3 = Theme.Elevated}) tween(KBStroke, EASE_SNAP, {Thickness = 0}) end end)
            Click.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                PlaySound(Sounds.Click, 0.3, 0.9)
                KeyLabel.Text = "..."
                KeyLabel.Color = Theme.Warning
                tween(KeyBox, EASE_SNAP, {BackgroundColor3 = Theme.Panel})
                tween(KBStroke, EASE_SNAP, {Thickness = 2, Color = Theme.Warning})
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if blacklisted[key] then
                            PlaySound(Sounds.ToggleOff, 0.4, 0.8)
                            CreateNotification(ScreenGui, {Title = "Keybind Invalido", Message = "Essa tecla nao pode ser usada!", Type = "Error", Duration = 2})
                            KeyLabel.Text = currentKey.Name
                            KeyLabel.Color = Theme.Primary
                        else
                            currentKey = key
                            KeyLabel.Text = key.Name
                            if cfg2.KeyChanged then cfg2.KeyChanged(key) end
                            PlaySound(Sounds.Keybind, 0.4, 1)
                            KeyLabel.Color = Theme.Success
                            CreateNotification(ScreenGui, {Title = "Keybind Alterado", Message = "Nova tecla: " .. key.Name, Type = "Success", Duration = 2})
                            task.delay(0.5, function() if KeyLabel then KeyLabel.Color = Theme.Primary end end)
                        end
                        tween(KeyBox, EASE_SNAP, {BackgroundColor3 = Theme.Elevated})
                        tween(KBStroke, EASE_SNAP, {Thickness = 0, Color = Theme.Primary})
                        listening = false
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if gp or listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey and cfg2.Callback then
                    tween(KeyBox, TweenInfo.new(0.1), {Size = UDim2.new(0, (isMobile and 75 or 70) + 5, 0, (isMobile and 26 or 22) + 5)})
                    task.delay(0.1, function()
                        tween(KeyBox, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, isMobile and 75 or 70, 0, isMobile and 26 or 22)})
                    end)
                    cfg2.Callback()
                end
            end)

            if not cfg2._internal and not cfg2.HideFromHUD then
                table.insert(HUDRegistry, {Name = cfg2.Name or "Keybind", Type = cfg2.HUDType or "Action", GetState = cfg2.GetState, GetKey = function() return currentKey.Name end})
            end
            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {Type = "Keybind", GetValue = function() return currentKey end, SetValue = function(key) currentKey = key KeyLabel.Text = key.Name end}
            end
            return {SetKey = function(_, key) currentKey = key KeyLabel.Text = key.Name end, GetKey = function() return currentKey end}
        end

        function Tab:AddColorPicker(cfg2)
            cfg2 = cfg2 or {}
            local h, s, v = (cfg2.Default or Color3.fromRGB(255,255,255)):ToHSV()
            local a = cfg2.Alpha or 1
            local open = false
            local draggingSV, draggingHue, draggingAlpha = false, false, false

            local Row = frame({Parent = ContentFrame, Size = UDim2.new(1, 0, 0, isMobile and 36 or 32), Color = Theme.Panel, Corner = 6, ZIndex = 3})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            label({Parent = Row, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = cfg2.Name or "Color", TextSize = isMobile and 11 or 12, ZIndex = 4})

            local ColorBtn = frame({Parent = Row, Size = UDim2.new(0, isMobile and 42 or 36, 0, isMobile and 22 or 18), Position = UDim2.new(1, isMobile and -52 or -46, 0.5, isMobile and -11 or -9), Color = Color3.fromHSV(h, s, v), Corner = 5, ZIndex = 4})
            stroke(ColorBtn, Theme.BorderSoft, 1, 0.2)

            local pickerW = isMobile and 220 or 240
            local pickerH = isMobile and 230 or 245

            local PickerPopup = frame({Parent = Tab._popLayer, Size = UDim2.new(0, pickerW, 0, pickerH), Color = Theme.Panel, Corner = 8, Visible = false, ZIndex = 520})
            stroke(PickerPopup, Theme.Border, 1, 0.2)

            local svSize = isMobile and 160 or 175
            local SVBox = frame({Parent = PickerPopup, Size = UDim2.new(0, svSize, 0, svSize), Position = UDim2.new(0, 10, 0, 10), Color = Color3.fromHSV(h, 1, 1), Corner = 6, Clip = true, ZIndex = 521})
            gradient(SVBox, 0, {ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}).Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}
            local BlackLayer = frame({Parent = SVBox, Size = UDim2.new(1, 0, 1, 0), Color = Color3.new(0,0,0), ZIndex = 522})
            local blackGrad = gradient(BlackLayer, 270, {ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))})
            blackGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}

            local SVHandle = frame({Parent = SVBox, Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(s, -5, 1-v, -5), Color = Color3.fromRGB(255,255,255), Corner = 5, ZIndex = 524})
            stroke(SVHandle, Color3.fromRGB(20,20,24), 2, 0)

            local hueW = isMobile and 18 or 16
            local HueBar = frame({Parent = PickerPopup, Size = UDim2.new(0, hueW, 0, svSize), Position = UDim2.new(0, svSize + 20, 0, 10), Corner = 6, Clip = true, ZIndex = 521})
            local hueKeys = {}
            for i = 0, 10 do
                hueKeys[#hueKeys+1] = ColorSequenceKeypoint.new(i/10, Color3.fromHSV(i/10, 1, 1))
            end
            gradient(HueBar, 90, hueKeys)
            local HueHandle = frame({Parent = HueBar, Size = UDim2.new(1, 4, 0, 4), Position = UDim2.new(0, -2, h, -2), Color = Color3.fromRGB(255,255,255), Corner = 2, ZIndex = 524})
            stroke(HueHandle, Color3.fromRGB(20,20,24), 1, 0)

            local alphaW = isMobile and 18 or 16
            local AlphaBar = frame({Parent = PickerPopup, Size = UDim2.new(0, alphaW, 0, svSize), Position = UDim2.new(0, svSize + 20 + hueW + 10, 0, 10), Color = Color3.fromRGB(255,255,255), Corner = 6, Clip = true, ZIndex = 521})
            local alphaGrad = gradient(AlphaBar, 90, {ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))})
            local AlphaHandle = frame({Parent = AlphaBar, Size = UDim2.new(1, 4, 0, 4), Position = UDim2.new(0, -2, 1-a, -2), Color = Color3.fromRGB(255,255,255), Corner = 2, ZIndex = 524})
            stroke(AlphaHandle, Color3.fromRGB(20,20,24), 1, 0)

            local HexLabel = label({Parent = PickerPopup, Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, svSize + 20), Text = "", Font = Enum.Font.GothamBold, TextSize = 11, Color = Theme.TextSecondary, ZIndex = 521})

            local function getColor() return Color3.fromHSV(h, s, v) end

            local function updateVisual()
                local col = getColor()
                ColorBtn.BackgroundColor3 = col
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVHandle.Position = UDim2.new(s, -5, 1-v, -5)
                HueHandle.Position = UDim2.new(0, -2, h, -2)
                AlphaHandle.Position = UDim2.new(0, -2, 1-a, -2)
                HexLabel.Text = string.format("#%02X%02X%02X", col.R*255, col.G*255, col.B*255)
            end
            updateVisual()

            local ColorClick = Instance.new("TextButton")
            ColorClick.Size, ColorClick.BackgroundTransparency, ColorClick.Text, ColorClick.ZIndex, ColorClick.Parent = UDim2.new(1,0,1,0), 1, "", 6, ColorBtn

            local function closePicker()
                if not open then return end
                open = false
                tween(PickerPopup, EASE_IN, {BackgroundTransparency = 1})
                task.delay(0.16, function() if PickerPopup then PickerPopup.Visible = false PickerPopup.BackgroundTransparency = 0 end end)
                if currentOpenDropdown == closePicker then currentOpenDropdown = nil end
            end

            local function openPicker()
                if currentOpenDropdown and currentOpenDropdown ~= closePicker then currentOpenDropdown() end
                open = true
                currentOpenDropdown = closePicker
                local abs = ColorBtn.AbsolutePosition
                local rootAbs = Tab._mainContainer.AbsolutePosition
                local relX = abs.X - rootAbs.X
                local relY = abs.Y - rootAbs.Y + ColorBtn.AbsoluteSize.Y + 4
                PickerPopup.Position = UDim2.new(0, relX - pickerW + ColorBtn.AbsoluteSize.X, 0, relY)
                PickerPopup.Visible = true
                PickerPopup.BackgroundTransparency = 1
                tween(PickerPopup, EASE_OUT, {BackgroundTransparency = 0})
            end

            ColorClick.MouseButton1Click:Connect(function()
                if open then closePicker() else openPicker() end
            end)

            SVBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true end
            end)
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true end
            end)
            AlphaBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingAlpha = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV, draggingHue, draggingAlpha = false, false, false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then return end
                if draggingSV then
                    local p = SVBox.AbsolutePosition
                    local sz = SVBox.AbsoluteSize
                    s = math.clamp((input.Position.X - p.X) / sz.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - p.Y) / sz.Y, 0, 1)
                    updateVisual()
                    if cfg2.Callback then task.spawn(cfg2.Callback, getColor(), a) end
                elseif draggingHue then
                    local p = HueBar.AbsolutePosition
                    local sz = HueBar.AbsoluteSize
                    h = math.clamp((input.Position.Y - p.Y) / sz.Y, 0, 1)
                    updateVisual()
                    if cfg2.Callback then task.spawn(cfg2.Callback, getColor(), a) end
                elseif draggingAlpha then
                    local p = AlphaBar.AbsolutePosition
                    local sz = AlphaBar.AbsoluteSize
                    a = 1 - math.clamp((input.Position.Y - p.Y) / sz.Y, 0, 1)
                    updateVisual()
                    if cfg2.Callback then task.spawn(cfg2.Callback, getColor(), a) end
                end
            end)

            if cfg2.Flag then
                Window.Flags[cfg2.Flag] = {
                    Type = "ColorPicker",
                    GetValue = function() return getColor(), a end,
                    SetValue = function(col, alp)
                        h, s, v = col:ToHSV()
                        a = alp or a
                        updateVisual()
                        if cfg2.Callback then cfg2.Callback(getColor(), a) end
                    end,
                }
            end
            return {
                SetValue = function(_, col, alp)
                    h, s, v = col:ToHSV()
                    a = alp or a
                    updateVisual()
                end,
                GetValue = function() return getColor(), a end,
            }
        end

        table.insert(Window.Categories, Tab)
        if #Window.Categories == 1 then activateTab() end

        return Tab
    end

    function Window:Show()
        MainContainer.Visible = true
        if isMobile then FloatingButton.Visible = false end
    end
    function Window:Hide()
        MainContainer.Visible = false
        if isMobile and floatBtnVisible then FloatingButton.Visible = true end
    end
    function Window:Toggle()
        MainContainer.Visible = not MainContainer.Visible
        if isMobile then FloatingButton.Visible = not MainContainer.Visible and floatBtnVisible end
    end
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == minimizeKey then
            Window:Toggle()
        end
    end)

    task.defer(function()
        local ConfigsTab = Window:CreateTab({Name = "Configs", Icon = "C", _order = 9998})
        local configListContainer, configListLayout, configNameInput = nil, nil, nil

        local function buildConfigRow(name, parentFrame)
            local rowH = isMobile and 36 or 32
            local Row = frame({Parent = parentFrame, Size = UDim2.new(1, 0, 0, rowH), Color = Theme.Panel, Corner = 5, ZIndex = 4})
            stroke(Row, Theme.BorderSoft, 1, 0.5)
            frame({Parent = Row, Size = UDim2.new(0, 3, 1, 0), Color = Theme.Primary, Corner = 2, ZIndex = 5})
            label({Parent = Row, Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = name, Font = Enum.Font.GothamMedium, TextSize = isMobile and 10 or 11, ZIndex = 5})

            local btnW, btnH = isMobile and 44 or 48, isMobile and 22 or 20
            local LoadBtn = frame({Parent = Row, Size = UDim2.new(0, btnW, 0, btnH), Position = UDim2.new(1, -(btnW*2 + 14), 0.5, -btnH/2), Color = Theme.Primary, Transparency = 0.8, Corner = 4, ZIndex = 5})
            local LoadLabel = label({Parent = LoadBtn, Text = "Carregar", Font = Enum.Font.GothamBold, TextSize = isMobile and 8 or 9, XAlign = Enum.TextXAlignment.Center, ZIndex = 6})
            local LoadClick = Instance.new("TextButton")
            LoadClick.Size, LoadClick.BackgroundTransparency, LoadClick.Text, LoadClick.ZIndex, LoadClick.Parent = UDim2.new(1,0,1,0), 1, "", 7, LoadBtn

            local DelBtn = frame({Parent = Row, Size = UDim2.new(0, btnW, 0, btnH), Position = UDim2.new(1, -(btnW + 6), 0.5, -btnH/2), Color = Theme.Error, Transparency = 0.75, Corner = 4, ZIndex = 5})
            local DelLabel = label({Parent = DelBtn, Text = "Deletar", Font = Enum.Font.GothamBold, TextSize = isMobile and 8 or 9, XAlign = Enum.TextXAlignment.Center, ZIndex = 6})
            local DelClick = Instance.new("TextButton")
            DelClick.Size, DelClick.BackgroundTransparency, DelClick.Text, DelClick.ZIndex, DelClick.Parent = UDim2.new(1,0,1,0), 1, "", 7, DelBtn

            LoadBtn.MouseEnter:Connect(function() tween(LoadBtn, EASE_SNAP, {BackgroundTransparency = 0.5}) end)
            LoadBtn.MouseLeave:Connect(function() tween(LoadBtn, EASE_SNAP, {BackgroundTransparency = 0.8}) end)
            DelBtn.MouseEnter:Connect(function() tween(DelBtn, EASE_SNAP, {BackgroundTransparency = 0.45}) end)
            DelBtn.MouseLeave:Connect(function() tween(DelBtn, EASE_SNAP, {BackgroundTransparency = 0.75}) end)
            return Row, LoadClick, DelClick
        end

        local function refreshConfigList()
            if not configListContainer then return end
            for _, child in ipairs(configListContainer:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            local configs = Window:GetConfigList()
            if #configs == 0 then
                label({Parent = configListContainer, Size = UDim2.new(1, 0, 0, isMobile and 32 or 28), Text = "Nenhum config salvo.", Color = Theme.TextMuted, TextSize = isMobile and 10 or 11, ZIndex = 4})
            else
                for _, cfgName in ipairs(configs) do
                    local Row, LoadClick, DelClick = buildConfigRow(cfgName, configListContainer)
                    LoadClick.MouseButton1Click:Connect(function()
                        PlaySound(Sounds.ToggleOn, 0.3, 1)
                        local ok = Window:LoadConfig(cfgName)
                        Window:Notify({Title = "Configs", Message = ok and ("Config \"" .. cfgName .. "\" carregado!") or ("Falha ao carregar \"" .. cfgName .. "\"."), Type = ok and "Success" or "Error", Duration = 3})
                    end)
                    DelClick.MouseButton1Click:Connect(function()
                        PlaySound(Sounds.ToggleOff, 0.3, 0.9)
                        Window:DeleteConfig(cfgName)
                        Window:Notify({Title = "Configs", Message = "Config \"" .. cfgName .. "\" deletado.", Type = "Warning", Duration = 3})
                        refreshConfigList()
                    end)
                end
            end
        end

        ConfigsTab._onActivate = refreshConfigList
        ConfigsTab:AddSection("Salvar Config")
        configNameInput = ConfigsTab:AddTextbox({Name = "Nome", Placeholder = "Nome do config...", Default = ""})
        ConfigsTab:AddButton({
            Name = "Salvar Config",
            Callback = function()
                local name = configNameInput:GetValue()
                if not name or name == "" then
                    Window:Notify({Title = "Configs", Message = "Digite um nome para o config.", Type = "Warning", Duration = 3})
                    return
                end
                local ok = Window:SaveConfig(name)
                Window:Notify({Title = "Configs", Message = ok and ("Config \"" .. name .. "\" salvo!") or "Falha ao salvar config.", Type = ok and "Success" or "Error", Duration = 3})
                if ok then refreshConfigList() end
            end,
        })
        ConfigsTab:AddSection("Configs Salvos")

        configListContainer = Instance.new("Frame")
        configListContainer.Name = randomName(14)
        configListContainer.Size = UDim2.new(1, 0, 0, 0)
        configListContainer.BackgroundTransparency = 1
        configListContainer.ZIndex = 3
        configListContainer.Parent = ConfigsTab.ContentFrame

        configListLayout = Instance.new("UIListLayout")
        configListLayout.Padding = UDim.new(0, isMobile and 6 or 8)
        configListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        configListLayout.Parent = configListContainer
        configListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            configListContainer.Size = UDim2.new(1, 0, 0, configListLayout.AbsoluteContentSize.Y)
        end)
        refreshConfigList()

        local SettingsTab = Window:CreateTab({Name = "Settings", Icon = "S", _order = 9999})

        SettingsTab:AddSection("Watermark")
        SettingsTab:AddToggle({
            Name = "Mostrar Watermark",
            Default = false,
            HideFromHUD = true,
            Callback = function(state)
                if state then ShowWatermark(ScreenGui) else HideWatermark() end
            end,
        })

        SettingsTab:AddSection("Cor de Destaque")
        SettingsTab:AddColorPicker({
            Name = "Cor Principal",
            Default = Theme.Primary,
            Alpha = 1,
            HideFromHUD = true,
            Callback = function(color, alpha)
                Theme.Primary = color
                local h2, s2, v2 = color:ToHSV()
                Theme.Accent = Color3.fromHSV(h2, s2, math.min(v2 + 0.1, 1))
                Theme.Toggle = color
                RefreshTheme()
            end,
        })

        SettingsTab:AddSection("Atalhos do Script")
        SettingsTab:AddKeybind({
            Name = "Minimizar / Abrir",
            Default = minimizeKey,
            _internal = true,
            KeyChanged = function(newKey) minimizeKey = newKey end,
        })

        SettingsTab:AddSection("Lista de Keybinds")
        SettingsTab:AddToggle({
            Name = "KeyBind List",
            Default = false,
            HideFromHUD = true,
            Callback = function(state)
                if state then ShowHUD() else HideHUD() end
            end,
        })

        SettingsTab:AddSection("Perfil")
        SettingsTab:AddToggle({
            Name = "Modo Anonimo",
            Default = false,
            HideFromHUD = true,
            Callback = function(state) applyAnonymousMode(state) end,
        })

        if isMobile then
            SettingsTab:AddSection("Botao Flutuante")
            SettingsTab:AddToggle({
                Name = "Visivel ao Minimizar",
                Default = true,
                HideFromHUD = true,
                Callback = function(state)
                    floatBtnVisible = state
                    if not state then
                        FloatingButton.Visible = false
                    elseif not MainContainer.Visible then
                        FloatingButton.Visible = true
                    end
                end,
            })
            SettingsTab:AddSlider({
                Name = "Tamanho da Bola",
                Min = 30,
                Max = 90,
                Default = floatBtnSize,
                HideFromHUD = true,
                Callback = function(value)
                    floatBtnSize = value
                    floatTween:Cancel()
                    FloatingButton.Size = UDim2.new(0, value, 0, value)
                    FloatIcon.TextSize = math.floor(value * 0.45)
                    floatTween = tween(FloatingButton, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, value + 5, 0, value + 5)})
                    if not MainContainer.Visible and floatBtnVisible then floatTween:Play() end
                end,
            })
        end

        MainContainer.Visible = true
        if isMobile then FloatingButton.Visible = false end
    end)

    return Window
end

return QuantomLib
