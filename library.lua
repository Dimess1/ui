local QuantomLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
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
local Sounds = {
	ToggleOn  = "6026984224",
	ToggleOff = "6020793244",
	Click     = "4177953",
	Notify    = "5997023029",
	Keybind   = "3716451793",
	Hover     = "6026984224",
}
local function PlaySound(id, vol, pitch)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = vol or 0.35
	s.PlaybackSpeed = pitch or 1
	s.RollOffMaxDistance = 0
	s.Parent = SoundService
	s:Play()
	game:GetService("Debris"):AddItem(s, 4)
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
	PlaySound(Sounds.Notify, 0.4, 1)
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
	Window.Flags = {}
	local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
	local HUDRegistry = {}
	local HUDFrame = nil
	local HUDVisible = false
	local HUDConnection = nil

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
				local vals = info.GetValue()
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
	local playerCardHeight = isMobile and 68 or 62
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
	SidebarPadding.PaddingBottom = UDim.new(0, playerCardHeight + 4)
	SidebarPadding.Parent = Sidebar
	local PlayerCardDivider = Instance.new("Frame")
	PlayerCardDivider.Name = randomName(10)
	PlayerCardDivider.Size = UDim2.new(0, sidebarWidth, 0, 1)
	PlayerCardDivider.Position = UDim2.new(0, 0, 1, -(playerCardHeight + 1))
	PlayerCardDivider.BackgroundColor3 = Theme.Divider
	PlayerCardDivider.BorderSizePixel = 0
	PlayerCardDivider.ZIndex = 3
	PlayerCardDivider.Parent = ClipFrame
	local PlayerCard = Instance.new("Frame")
	PlayerCard.Name = randomName(14)
	PlayerCard.Size = UDim2.new(0, sidebarWidth, 0, playerCardHeight)
	PlayerCard.Position = UDim2.new(0, 0, 1, -playerCardHeight)
	PlayerCard.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
	PlayerCard.BorderSizePixel = 0
	PlayerCard.ZIndex = 3
	PlayerCard.Parent = ClipFrame
	local AvatarSize = isMobile and 38 or 36
	local AvatarBorder = Instance.new("Frame")
	AvatarBorder.Name = randomName(10)
	AvatarBorder.Size = UDim2.new(0, AvatarSize + 4, 0, AvatarSize + 4)
	AvatarBorder.Position = UDim2.new(0, isMobile and 8 or 10, 0.5, -(AvatarSize/2 + 2))
	AvatarBorder.BackgroundColor3 = Theme.Primary
	AvatarBorder.BackgroundTransparency = 0.4
	AvatarBorder.BorderSizePixel = 0
	AvatarBorder.ZIndex = 4
	AvatarBorder.Parent = PlayerCard
	local AvatarBorderCorner = Instance.new("UICorner")
	AvatarBorderCorner.CornerRadius = UDim.new(1, 0)
	AvatarBorderCorner.Parent = AvatarBorder
	local AvatarFrame = Instance.new("Frame")
	AvatarFrame.Name = randomName(12)
	AvatarFrame.Size = UDim2.new(0, AvatarSize, 0, AvatarSize)
	AvatarFrame.Position = UDim2.new(0.5, -AvatarSize/2, 0.5, -AvatarSize/2)
	AvatarFrame.BackgroundColor3 = Theme.Surface
	AvatarFrame.BorderSizePixel = 0
	AvatarFrame.ZIndex = 5
	AvatarFrame.ClipsDescendants = true
	AvatarFrame.Parent = AvatarBorder
	local AvatarFrameCorner = Instance.new("UICorner")
	AvatarFrameCorner.CornerRadius = UDim.new(1, 0)
	AvatarFrameCorner.Parent = AvatarFrame
	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Name = randomName(11)
	AvatarImage.Size = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Image = "rbxassetid://7546875799"
	AvatarImage.ScaleType = Enum.ScaleType.Crop
	AvatarImage.ZIndex = 6
	AvatarImage.Parent = AvatarFrame
	task.spawn(function()
		local ok, imgId = pcall(function()
			return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and imgId then
			AvatarImage.Image = imgId
		end
	end)
	local OnlineDot = Instance.new("Frame")
	OnlineDot.Name = randomName(8)
	OnlineDot.Size = UDim2.new(0, isMobile and 10 or 9, 0, isMobile and 10 or 9)
	OnlineDot.Position = UDim2.new(1, -(isMobile and 10 or 9), 1, -(isMobile and 10 or 9))
	OnlineDot.BackgroundColor3 = Theme.Success
	OnlineDot.BorderSizePixel = 0
	OnlineDot.ZIndex = 7
	OnlineDot.Parent = AvatarBorder
	local OnlineDotCorner = Instance.new("UICorner")
	OnlineDotCorner.CornerRadius = UDim.new(1, 0)
	OnlineDotCorner.Parent = OnlineDot
	local OnlineDotStroke = Instance.new("UIStroke")
	OnlineDotStroke.Color = Color3.fromRGB(11, 11, 14)
	OnlineDotStroke.Thickness = 2
	OnlineDotStroke.Parent = OnlineDot
	local textOffsetX = isMobile and (AvatarSize + 20) or (AvatarSize + 24)
	local PlayerDisplayName = Instance.new("TextLabel")
	PlayerDisplayName.Name = randomName(13)
	PlayerDisplayName.Size = UDim2.new(1, -(textOffsetX + 6), 0, isMobile and 14 or 13)
	PlayerDisplayName.Position = UDim2.new(0, textOffsetX, 0, isMobile and 14 or 13)
	PlayerDisplayName.BackgroundTransparency = 1
	PlayerDisplayName.Text = Player.DisplayName
	PlayerDisplayName.Font = Enum.Font.GothamBold
	PlayerDisplayName.TextSize = isMobile and 10 or 11
	PlayerDisplayName.TextColor3 = Theme.Text
	PlayerDisplayName.TextXAlignment = Enum.TextXAlignment.Left
	PlayerDisplayName.TextTruncate = Enum.TextTruncate.AtEnd
	PlayerDisplayName.ZIndex = 4
	PlayerDisplayName.Parent = PlayerCard
	local PlayerUserName = Instance.new("TextLabel")
	PlayerUserName.Name = randomName(13)
	PlayerUserName.Size = UDim2.new(1, -(textOffsetX + 6), 0, isMobile and 12 or 11)
	PlayerUserName.Position = UDim2.new(0, textOffsetX, 0, isMobile and 30 or 28)
	PlayerUserName.BackgroundTransparency = 1
	PlayerUserName.Text = "@" .. Player.Name
	PlayerUserName.Font = Enum.Font.Gotham
	PlayerUserName.TextSize = isMobile and 9 or 10
	PlayerUserName.TextColor3 = Theme.TextMuted
	PlayerUserName.TextXAlignment = Enum.TextXAlignment.Left
	PlayerUserName.TextTruncate = Enum.TextTruncate.AtEnd
	PlayerUserName.ZIndex = 4
	PlayerUserName.Parent = PlayerCard
	task.spawn(function()
		while PlayerCard and PlayerCard.Parent do
			TweenService:Create(AvatarBorder, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				BackgroundTransparency = 0.7
			}):Play()
			task.wait(2.5)
			TweenService:Create(AvatarBorder, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				BackgroundTransparency = 0.2
			}):Play()
			task.wait(2.5)
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
	local LoadingFrame = Instance.new("Frame")
	LoadingFrame.Name = randomName(14)
	LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
	LoadingFrame.BackgroundColor3 = Theme.Background
	LoadingFrame.BorderSizePixel = 0
	LoadingFrame.ZIndex = 300
	LoadingFrame.Parent = ClipFrame
	local LoadingCorner = Instance.new("UICorner")
	LoadingCorner.CornerRadius = UDim.new(0, isMobile and 8 or 6)
	LoadingCorner.Parent = LoadingFrame
	local LoadingGlow = Instance.new("Frame")
	LoadingGlow.Name = randomName(10)
	LoadingGlow.Size = UDim2.new(1, 0, 1, 0)
	LoadingGlow.BackgroundColor3 = Theme.Primary
	LoadingGlow.BackgroundTransparency = 0.96
	LoadingGlow.BorderSizePixel = 0
	LoadingGlow.ZIndex = 301
	LoadingGlow.Parent = LoadingFrame
	local LoadingGlowGrad = Instance.new("UIGradient")
	LoadingGlowGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Theme.Primary),
		ColorSequenceKeypoint.new(0.5, Theme.Accent),
		ColorSequenceKeypoint.new(1, Theme.Primary)
	}
	LoadingGlowGrad.Rotation = 45
	LoadingGlowGrad.Parent = LoadingGlow
	local LoadingImage = Instance.new("ImageLabel")
	LoadingImage.Name = randomName(12)
	LoadingImage.Size = UDim2.new(0, isMobile and 120 or 160, 0, isMobile and 120 or 160)
	LoadingImage.AnchorPoint = Vector2.new(0.5, 0.5)
	LoadingImage.Position = UDim2.new(0.5, 0, 0.42, 0)
	LoadingImage.BackgroundTransparency = 1
	LoadingImage.Image = "rbxassetid://100628717029507"
	LoadingImage.ScaleType = Enum.ScaleType.Fit
	LoadingImage.ZIndex = 302
	LoadingImage.Parent = LoadingFrame
	local LoadingTitle = Instance.new("TextLabel")
	LoadingTitle.Name = randomName(11)
	LoadingTitle.Size = UDim2.new(1, 0, 0, 22)
	LoadingTitle.AnchorPoint = Vector2.new(0.5, 0)
	LoadingTitle.Position = UDim2.new(0.5, 0, 0.42 + (isMobile and 120 or 160)/(2*uiHeight) + 0.03, 0)
	LoadingTitle.BackgroundTransparency = 1
	LoadingTitle.Text = Window.Name
	LoadingTitle.Font = Enum.Font.GothamBold
	LoadingTitle.TextSize = isMobile and 14 or 16
	LoadingTitle.TextColor3 = Theme.Text
	LoadingTitle.ZIndex = 302
	LoadingTitle.Parent = LoadingFrame
	local LoadingBarBG = Instance.new("Frame")
	LoadingBarBG.Name = randomName(10)
	LoadingBarBG.Size = UDim2.new(0, isMobile and 200 or 280, 0, isMobile and 5 or 4)
	LoadingBarBG.AnchorPoint = Vector2.new(0.5, 0)
	LoadingBarBG.Position = UDim2.new(0.5, 0, 0.42 + (isMobile and 120 or 160)/(2*uiHeight) + 0.10, 0)
	LoadingBarBG.BackgroundColor3 = Theme.Border
	LoadingBarBG.BorderSizePixel = 0
	LoadingBarBG.ZIndex = 302
	LoadingBarBG.Parent = LoadingFrame
	local LoadingBarBGCorner = Instance.new("UICorner")
	LoadingBarBGCorner.CornerRadius = UDim.new(1, 0)
	LoadingBarBGCorner.Parent = LoadingBarBG
	local LoadingBarFill = Instance.new("Frame")
	LoadingBarFill.Name = randomName(10)
	LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
	LoadingBarFill.BackgroundColor3 = Theme.Primary
	LoadingBarFill.BorderSizePixel = 0
	LoadingBarFill.ZIndex = 303
	LoadingBarFill.Parent = LoadingBarBG
	local LoadingBarFillCorner = Instance.new("UICorner")
	LoadingBarFillCorner.CornerRadius = UDim.new(1, 0)
	LoadingBarFillCorner.Parent = LoadingBarFill
	local LoadingBarFillGrad = Instance.new("UIGradient")
	LoadingBarFillGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Theme.Primary),
		ColorSequenceKeypoint.new(1, Theme.Accent)
	}
	LoadingBarFillGrad.Parent = LoadingBarFill
	local LoadingPercent = Instance.new("TextLabel")
	LoadingPercent.Name = randomName(11)
	LoadingPercent.Size = UDim2.new(1, 0, 0, 18)
	LoadingPercent.AnchorPoint = Vector2.new(0.5, 0)
	LoadingPercent.Position = UDim2.new(0.5, 0, 0.42 + (isMobile and 120 or 160)/(2*uiHeight) + 0.155, 0)
	LoadingPercent.BackgroundTransparency = 1
	LoadingPercent.Text = "0%"
	LoadingPercent.Font = Enum.Font.GothamBold
	LoadingPercent.TextSize = isMobile and 10 or 11
	LoadingPercent.TextColor3 = Theme.Primary
	LoadingPercent.ZIndex = 302
	LoadingPercent.Parent = LoadingFrame
	local LoadingStatus = Instance.new("TextLabel")
	LoadingStatus.Name = randomName(11)
	LoadingStatus.Size = UDim2.new(1, 0, 0, 16)
	LoadingStatus.AnchorPoint = Vector2.new(0.5, 0)
	LoadingStatus.Position = UDim2.new(0.5, 0, 0.42 + (isMobile and 120 or 160)/(2*uiHeight) + 0.195, 0)
	LoadingStatus.BackgroundTransparency = 1
	LoadingStatus.Text = "Carregando..."
	LoadingStatus.Font = Enum.Font.Gotham
	LoadingStatus.TextSize = isMobile and 9 or 10
	LoadingStatus.TextColor3 = Theme.TextMuted
	LoadingStatus.ZIndex = 302
	LoadingStatus.Parent = LoadingFrame
	local loadingProgress = 0
	local loadingFinished = false
	function Window:SetLoadingProgress(value, statusText)
		if loadingFinished then return end
		loadingProgress = math.clamp(value, 0, 100)
		local pct = loadingProgress / 100
		TweenService:Create(LoadingBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(pct, 0, 1, 0)
		}):Play()
		LoadingPercent.Text = math.floor(loadingProgress) .. "%"
		if statusText then
			LoadingStatus.Text = statusText
		end
	end
	function Window:FinishLoading()
		if loadingFinished then return end
		loadingFinished = true
		TweenService:Create(LoadingBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		LoadingPercent.Text = "100%"
		LoadingStatus.Text = "Concluído!"
		task.wait(0.5)
		TweenService:Create(LoadingFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			BackgroundTransparency = 1
		}):Play()
		for _, child in ipairs(LoadingFrame:GetDescendants()) do
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			elseif child:IsA("ImageLabel") then
				TweenService:Create(child, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
			elseif child:IsA("Frame") then
				TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			end
		end
		task.wait(0.45)
		LoadingFrame.Visible = false
		LoadingFrame:Destroy()
	end
	local function CreateHUD()
		if HUDFrame then HUDFrame:Destroy() HUDFrame = nil end
		if HUDConnection then HUDConnection:Disconnect() HUDConnection = nil end
		local rowH = isMobile and 26 or 22
		local hudW = isMobile and 210 or 230
		local headerH = isMobile and 30 or 28
		local count = #HUDRegistry
		local hudH = headerH + math.max(count, 1) * rowH + 8
		local HUD = Instance.new("Frame")
		HUD.Name = randomName(12)
		HUD.Size = UDim2.new(0, hudW, 0, hudH)
		HUD.Position = UDim2.new(0, isMobile and 8 or 12, 0, isMobile and 42 or 48)
		HUD.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
		HUD.BackgroundTransparency = 0.1
		HUD.BorderSizePixel = 0
		HUD.ZIndex = 8000
		HUD.Parent = ScreenGui
		local HUDCorner = Instance.new("UICorner")
		HUDCorner.CornerRadius = UDim.new(0, 6)
		HUDCorner.Parent = HUD
		local HUDStroke = Instance.new("UIStroke")
		HUDStroke.Color = Theme.Primary
		HUDStroke.Thickness = 1
		HUDStroke.Transparency = 0.5
		HUDStroke.Parent = HUD
		local HUDAccent = Instance.new("Frame")
		HUDAccent.Size = UDim2.new(1, 0, 0, 2)
		HUDAccent.BackgroundColor3 = Theme.Primary
		HUDAccent.BorderSizePixel = 0
		HUDAccent.ZIndex = 8001
		HUDAccent.Parent = HUD
		local HUDAccentCorner = Instance.new("UICorner")
		HUDAccentCorner.CornerRadius = UDim.new(0, 6)
		HUDAccentCorner.Parent = HUDAccent
		local HUDAccentGrad = Instance.new("UIGradient")
		HUDAccentGrad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Primary),
			ColorSequenceKeypoint.new(0.5, Theme.Accent),
			ColorSequenceKeypoint.new(1, Theme.Primary)
		}
		HUDAccentGrad.Parent = HUDAccent
		local HUDHeader = Instance.new("Frame")
		HUDHeader.Size = UDim2.new(1, 0, 0, headerH)
		HUDHeader.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		HUDHeader.BackgroundTransparency = 0.2
		HUDHeader.BorderSizePixel = 0
		HUDHeader.ZIndex = 8001
		HUDHeader.Parent = HUD
		local HUDHeaderCorner = Instance.new("UICorner")
		HUDHeaderCorner.CornerRadius = UDim.new(0, 6)
		HUDHeaderCorner.Parent = HUDHeader
		local HUDHeaderFix = Instance.new("Frame")
		HUDHeaderFix.Size = UDim2.new(1, 0, 0, 6)
		HUDHeaderFix.Position = UDim2.new(0, 0, 1, -6)
		HUDHeaderFix.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		HUDHeaderFix.BackgroundTransparency = 0.2
		HUDHeaderFix.BorderSizePixel = 0
		HUDHeaderFix.ZIndex = 8001
		HUDHeaderFix.Parent = HUDHeader
		local HUDBrandDot = Instance.new("Frame")
		HUDBrandDot.Size = UDim2.new(0, 6, 0, 6)
		HUDBrandDot.Position = UDim2.new(0, 10, 0.5, -3)
		HUDBrandDot.BackgroundColor3 = Theme.Primary
		HUDBrandDot.BorderSizePixel = 0
		HUDBrandDot.ZIndex = 8002
		HUDBrandDot.Parent = HUDHeader
		Instance.new("UICorner", HUDBrandDot).CornerRadius = UDim.new(1, 0)
		local HUDTitle = Instance.new("TextLabel")
		HUDTitle.Size = UDim2.new(1, -50, 1, 0)
		HUDTitle.Position = UDim2.new(0, 22, 0, 0)
		HUDTitle.BackgroundTransparency = 1
		HUDTitle.Text = "KEYBIND LIST"
		HUDTitle.Font = Enum.Font.GothamBold
		HUDTitle.TextSize = isMobile and 9 or 10
		HUDTitle.TextColor3 = Theme.TextMuted
		HUDTitle.TextXAlignment = Enum.TextXAlignment.Left
		HUDTitle.ZIndex = 8002
		HUDTitle.Parent = HUDHeader
		local HUDHide = Instance.new("TextButton")
		HUDHide.Size = UDim2.new(0, 22, 0, 22)
		HUDHide.Position = UDim2.new(1, -26, 0.5, -11)
		HUDHide.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
		HUDHide.Text = "−"
		HUDHide.Font = Enum.Font.GothamBold
		HUDHide.TextSize = isMobile and 14 or 13
		HUDHide.TextColor3 = Theme.TextMuted
		HUDHide.AutoButtonColor = false
		HUDHide.ZIndex = 8002
		HUDHide.Parent = HUDHeader
		Instance.new("UICorner", HUDHide).CornerRadius = UDim.new(0, 4)
		HUDHide.MouseEnter:Connect(function()
			TweenService:Create(HUDHide, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover, TextColor3 = Theme.Text}):Play()
		end)
		HUDHide.MouseLeave:Connect(function()
			TweenService:Create(HUDHide, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20,20,26), TextColor3 = Theme.TextMuted}):Play()
		end)
		HUDHide.MouseButton1Click:Connect(function()
			HUDVisible = false
			TweenService:Create(HUD, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.new(HUD.Position.X.Scale, HUD.Position.X.Offset - 20, HUD.Position.Y.Scale, HUD.Position.Y.Offset)
			}):Play()
			task.delay(0.2, function()
				if HUD and HUD.Parent then HUD.Visible = false end
			end)
		end)
		local hudDragging, hudDragStart, hudStartPos = false, nil, nil
		HUDHeader.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hudDragging = true
				hudDragStart = input.Position
				hudStartPos = HUD.Position
			end
		end)
		HUDHeader.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hudDragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if hudDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - hudDragStart
				HUD.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y)
			end
		end)
		local HUDContent = Instance.new("Frame")
		HUDContent.Name = randomName(10)
		HUDContent.Size = UDim2.new(1, 0, 1, -headerH)
		HUDContent.Position = UDim2.new(0, 0, 0, headerH)
		HUDContent.BackgroundTransparency = 1
		HUDContent.ZIndex = 8001
		HUDContent.Parent = HUD
		local HUDList = Instance.new("UIListLayout")
		HUDList.SortOrder = Enum.SortOrder.LayoutOrder
		HUDList.Parent = HUDContent
		local HUDPad = Instance.new("UIPadding")
		HUDPad.PaddingTop = UDim.new(0, 4)
		HUDPad.PaddingBottom = UDim.new(0, 4)
		HUDPad.PaddingLeft = UDim.new(0, 8)
		HUDPad.PaddingRight = UDim.new(0, 8)
		HUDPad.Parent = HUDContent
		local rowRefs = {}
		for i, entry in ipairs(HUDRegistry) do
			local Row = Instance.new("Frame")
			Row.Name = randomName(8)
			Row.Size = UDim2.new(1, 0, 0, 0)
			Row.BackgroundTransparency = 1
			Row.ClipsDescendants = true
			Row.LayoutOrder = i
			Row.ZIndex = 8002
			Row.Parent = HUDContent
			local Dot = Instance.new("Frame")
			Dot.Size = UDim2.new(0, isMobile and 7 or 6, 0, isMobile and 7 or 6)
			Dot.Position = UDim2.new(0, 0, 0.5, isMobile and -3.5 or -3)
			Dot.BackgroundColor3 = Theme.Success
			Dot.BorderSizePixel = 0
			Dot.ZIndex = 8003
			Dot.Parent = Row
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
			local NameLabel = Instance.new("TextLabel")
			NameLabel.Size = UDim2.new(1, -(isMobile and 70 or 80), 1, 0)
			NameLabel.Position = UDim2.new(0, isMobile and 13 or 12, 0, 0)
			NameLabel.BackgroundTransparency = 1
			NameLabel.Text = entry.Name
			NameLabel.Font = Enum.Font.GothamMedium
			NameLabel.TextSize = isMobile and 10 or 10
			NameLabel.TextColor3 = Theme.Text
			NameLabel.TextXAlignment = Enum.TextXAlignment.Left
			NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			NameLabel.ZIndex = 8003
			NameLabel.Parent = Row
			local RightFrame = Instance.new("Frame")
			RightFrame.Size = UDim2.new(0, isMobile and 62 or 72, 1, 0)
			RightFrame.Position = UDim2.new(1, -(isMobile and 62 or 72), 0, 0)
			RightFrame.BackgroundTransparency = 1
			RightFrame.ZIndex = 8003
			RightFrame.Parent = Row
			local KeyTag = Instance.new("Frame")
			KeyTag.Size = UDim2.new(0, isMobile and 28 or 32, 0, isMobile and 16 or 14)
			KeyTag.Position = UDim2.new(0, 0, 0.5, isMobile and -8 or -7)
			KeyTag.BackgroundColor3 = Theme.SurfaceLight
			KeyTag.BorderSizePixel = 0
			KeyTag.ZIndex = 8004
			KeyTag.Parent = RightFrame
			Instance.new("UICorner", KeyTag).CornerRadius = UDim.new(0, 3)
			local KeyTagStroke = Instance.new("UIStroke")
			KeyTagStroke.Color = Theme.Border
			KeyTagStroke.Thickness = 1
			KeyTagStroke.Parent = KeyTag
			local KeyTagText = Instance.new("TextLabel")
			KeyTagText.Size = UDim2.new(1, 0, 1, 0)
			KeyTagText.BackgroundTransparency = 1
			KeyTagText.Font = Enum.Font.GothamBold
			KeyTagText.TextSize = isMobile and 7 or 8
			KeyTagText.TextColor3 = Theme.TextSecondary
			KeyTagText.ZIndex = 8005
			KeyTagText.Parent = KeyTag
			local StateTag = Instance.new("Frame")
			StateTag.Size = UDim2.new(0, isMobile and 28 or 34, 0, isMobile and 16 or 14)
			StateTag.Position = UDim2.new(1, -(isMobile and 28 or 34), 0.5, isMobile and -8 or -7)
			StateTag.BackgroundColor3 = Theme.Success
			StateTag.BackgroundTransparency = 0.5
			StateTag.BorderSizePixel = 0
			StateTag.ZIndex = 8004
			StateTag.Parent = RightFrame
			Instance.new("UICorner", StateTag).CornerRadius = UDim.new(0, 3)
			local StateText = Instance.new("TextLabel")
			StateText.Size = UDim2.new(1, 0, 1, 0)
			StateText.BackgroundTransparency = 1
			StateText.Font = Enum.Font.GothamBold
			StateText.TextSize = isMobile and 7 or 8
			StateText.ZIndex = 8005
			StateText.Parent = StateTag
			rowRefs[i] = {
				Row = Row,
				Dot = Dot,
				KeyTagText = KeyTagText,
				StateTag = StateTag,
				StateText = StateText,
				NameLabel = NameLabel,
				Entry = entry,
				visible = false
			}
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
						TweenService:Create(ref.Row, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, rowH)}):Play()
					end
					local key = entry.GetKey and entry.GetKey() or "—"
					ref.KeyTagText.Text = #key > 4 and key:sub(1,4) or key
					if eType == "Hold" then
						ref.StateTag.BackgroundColor3 = Theme.Warning
						ref.StateText.Text = "HOLD"
						ref.StateText.TextColor3 = Theme.Warning
						ref.Dot.BackgroundColor3 = Theme.Warning
					elseif eType == "Action" then
						ref.StateTag.BackgroundColor3 = Theme.Info
						ref.StateText.Text = "ACT"
						ref.StateText.TextColor3 = Theme.Info
						ref.Dot.BackgroundColor3 = Theme.Info
					else
						ref.StateTag.BackgroundColor3 = Theme.Success
						ref.StateText.Text = "ON"
						ref.StateText.TextColor3 = Theme.Success
						ref.Dot.BackgroundColor3 = Theme.Success
						ref.NameLabel.TextColor3 = Theme.Text
					end
					ref.StateTag.BackgroundTransparency = 0.5
				else
					if ref.visible then
						ref.visible = false
						TweenService:Create(ref.Row, TweenInfo.new(0.12), {Size = UDim2.new(1, 0, 0, 0)}):Play()
					end
				end
			end
			if visibleCount ~= lastVisibleCount then
				lastVisibleCount = visibleCount
				local newH = headerH + math.max(visibleCount, 0) * rowH + (visibleCount > 0 and 8 or 4)
				TweenService:Create(HUD, TweenInfo.new(0.2), {Size = UDim2.new(0, hudW, 0, newH)}):Play()
			end
		end)
		HUD.BackgroundTransparency = 1
		HUD.Position = UDim2.new(HUD.Position.X.Scale, HUD.Position.X.Offset - 20, HUD.Position.Y.Scale, HUD.Position.Y.Offset)
		for _, child in ipairs(HUD:GetDescendants()) do
			if child:IsA("TextLabel") then child.TextTransparency = 1 end
		end
		TweenService:Create(HUD, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.1,
			Position = UDim2.new(HUD.Position.X.Scale, HUD.Position.X.Offset + 20, HUD.Position.Y.Scale, HUD.Position.Y.Offset)
		}):Play()
		task.delay(0.1, function()
			for _, child in ipairs(HUD:GetDescendants()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
				end
			end
		end)
		HUDFrame = HUD
		HUDVisible = true
	end
	local function ShowHUD()
		if HUDFrame and HUDFrame.Parent then
			HUDFrame.Visible = true
			HUDVisible = true
			TweenService:Create(HUDFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.1,
				Position = UDim2.new(HUDFrame.Position.X.Scale, HUDFrame.Position.X.Offset, HUDFrame.Position.Y.Scale, HUDFrame.Position.Y.Offset)
			}):Play()
			return
		end
		CreateHUD()
	end
	local function HideHUD()
		if not HUDFrame or not HUDFrame.Parent then return end
		HUDVisible = false
		local p = HUDFrame.Position
		TweenService:Create(HUDFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(p.X.Scale, p.X.Offset - 20, p.Y.Scale, p.Y.Offset)
		}):Play()
		task.delay(0.2, function()
			if HUDFrame and HUDFrame.Parent then HUDFrame.Visible = false end
		end)
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
		CategoryButton.LayoutOrder = config._order or (config._settingsTab and 9999 or (#Window.Categories + 1))
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
			PlaySound(Sounds.Click, 0.25, 1.1)
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
			if Tab._onActivate then Tab._onActivate() end
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
			local function applyToggleVisual(state)
				TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
					BackgroundColor3 = state and Theme.Toggle or Theme.Border
				}):Play()
				local endPos = state and UDim2.new(1, isMobile and -20 or -16, 0.5, isMobile and -9 or -7) or UDim2.new(0, 2, 0.5, isMobile and -9 or -7)
				TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = endPos}):Play()
			end
			ToggleButton.MouseButton1Click:Connect(function()
				toggleState = not toggleState
				applyToggleVisual(toggleState)
				if config.Callback then
					config.Callback(toggleState)
				end
			end)
			if not config.HideFromHUD then
				table.insert(HUDRegistry, {
					Name = config.Name or "Toggle",
					Type = "Toggle",
					GetState = function() return toggleState end,
					GetKey = function()
						return config.HUDKey or "—"
					end
				})
			end
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "Toggle",
					GetValue = function() return toggleState end,
					SetValue = function(v)
						toggleState = v
						applyToggleVisual(toggleState)
						if config.Callback then config.Callback(toggleState) end
					end
				}
			end
			return {
				SetValue = function(self, value)
					toggleState = value
					applyToggleVisual(toggleState)
					if config.Callback then config.Callback(toggleState) end
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
				PlaySound(Sounds.Click, 0.3, 1.2)
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
					PlaySound(Sounds.Click, 0.2, 1.3)
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
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "Slider",
					GetValue = function() return sliderValue end,
					SetValue = function(v)
						sliderValue = math.clamp(v, config.Min, config.Max)
						ValueLabel.Text = tostring(sliderValue)
						local pct = (sliderValue - config.Min) / (config.Max - config.Min)
						SliderFill.Size = UDim2.new(pct, 0, 1, 0)
						if config.Callback then config.Callback(sliderValue) end
					end
				}
			end
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
			TextboxInput.Focused:Connect(function()
				PlaySound(Sounds.Click, 0.2, 1.1)
			end)
			TextboxInput.FocusLost:Connect(function(enterPressed)
				if enterPressed and config.Callback then
					PlaySound(Sounds.ToggleOn, 0.25, 1.2)
					config.Callback(TextboxInput.Text)
				end
			end)
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "Textbox",
					GetValue = function() return TextboxInput.Text end,
					SetValue = function(v)
						TextboxInput.Text = tostring(v)
						if config.Callback then config.Callback(TextboxInput.Text) end
					end
				}
			end
			return {
				SetValue = function(self, value)
					TextboxInput.Text = value
				end,
				GetValue = function(self)
					return TextboxInput.Text
				end
			}
		end
		function Tab:AddDropdown(config)
			local selectedOption = config.Default or (config.Options and config.Options[1]) or ""
			local dropdownOpen = false
			local dropdownTransitioning = false
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
				dropdownTransitioning = true
				TweenService:Create(Arrow, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
				TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceLight}):Play()
				local frameToDestroy = optionsListFrame
				optionsListFrame = nil
				if frameToDestroy and frameToDestroy.Parent then
					TweenService:Create(frameToDestroy, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						BackgroundTransparency = 1
					}):Play()
					for _, c in ipairs(frameToDestroy:GetDescendants()) do
						if c:IsA("TextLabel") or c:IsA("TextButton") then
							TweenService:Create(c, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
						elseif c:IsA("Frame") and c.BackgroundTransparency < 0.99 then
							TweenService:Create(c, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
						end
					end
					task.delay(0.15, function()
						if frameToDestroy and frameToDestroy.Parent then
							frameToDestroy:Destroy()
						end
						dropdownTransitioning = false
					end)
				else
					dropdownTransitioning = false
				end
				if currentOpenDropdown == closeDropdown then
					currentOpenDropdown = nil
				end
			end
			local function openDropdown()
				if dropdownTransitioning then return end
				if currentOpenDropdown and currentOpenDropdown ~= closeDropdown then
					currentOpenDropdown()
				end
				PlaySound(Sounds.Click, 0.25, 0.95)
				dropdownOpen = true
				currentOpenDropdown = closeDropdown
				TweenService:Create(Arrow, TweenInfo.new(0.2), {TextColor3 = Theme.Primary}):Play()
				TweenService:Create(DropdownButton, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover}):Play()
				local optionCount = #(config.Options or {})
				local optionH = isMobile and 28 or 26
				local maxVisible = isMobile and 4 or 5
				local listH = math.min(optionCount, maxVisible) * optionH + 2
				local listW = DropdownButton.AbsoluteSize.X
				local abs = DropdownButton.AbsolutePosition
				local mainAbs = MainContainer.AbsolutePosition
				local relX = abs.X - mainAbs.X
				local relY = abs.Y - mainAbs.Y + (isMobile and 26 or 22) + 4
				if relY + listH > uiHeight - 10 then
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
						PlaySound(Sounds.Click, 0.28, 1.15)
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
				if dropdownTransitioning then return end
				if dropdownOpen then
					closeDropdown()
				else
					openDropdown()
				end
			end)
			UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownOpen and not dropdownTransitioning then
					local mousePos = UserInputService:GetMouseLocation()
					local currentFrame = optionsListFrame
					if currentFrame and currentFrame.Parent then
						local abs = currentFrame.AbsolutePosition
						local sz = currentFrame.AbsoluteSize
						local insideList = mousePos.X >= abs.X and mousePos.X <= abs.X + sz.X and
							mousePos.Y >= abs.Y and mousePos.Y <= abs.Y + sz.Y
						local btnAbs = DropdownButton.AbsolutePosition
						local btnSz = DropdownButton.AbsoluteSize
						local insideBtn = mousePos.X >= btnAbs.X and mousePos.X <= btnAbs.X + btnSz.X and
							mousePos.Y >= btnAbs.Y and mousePos.Y <= btnAbs.Y + btnSz.Y
						if not insideList and not insideBtn then
							closeDropdown()
						end
					end
				end
			end)
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "Dropdown",
					GetValue = function() return selectedOption end,
					SetValue = function(v)
						selectedOption = v
						DropdownButton.Text = v
						if config.Callback then config.Callback(v) end
					end
				}
			end
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
				PlaySound(Sounds.Click, 0.3, 0.9)
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
							PlaySound(Sounds.ToggleOff, 0.4, 0.8)
							CreateNotification({Title = "Keybind Inválido", Message = "Essa tecla não pode ser usada!", Type = "Error", Duration = 2})
							KeybindButton.Text = currentKey.Name
							KeybindButton.TextColor3 = Theme.Primary
						else
							currentKey = key
							KeybindButton.Text = key.Name
							if config.KeyChanged then config.KeyChanged(key) end
							PlaySound(Sounds.Keybind, 0.4, 1)
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
			if not config._internal and not config.HideFromHUD then
				table.insert(HUDRegistry, {
					Name = config.Name or "Keybind",
					Type = config.HUDType or "Action",
					GetState = config.GetState or nil,
					GetKey = function()
						return currentKey.Name
					end
				})
			end
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "Keybind",
					GetValue = function() return currentKey end,
					SetValue = function(key)
						currentKey = key
						KeybindButton.Text = key.Name
					end
				}
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
				PlaySound(Sounds.Click, 0.25, 1.05)
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
			if config.Flag then
				Window.Flags[config.Flag] = {
					Type = "ColorPicker",
					GetValue = function() return {getColor(), a} end,
					SetValue = function(color, alpha)
						if color then h, s, v = color:ToHSV() end
						if alpha ~= nil then a = alpha end
						updateAll()
					end
				}
			end
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
		local ConfigsTab = Window:CreateTab({Name = "Configs", Icon = "📁", _order = 9998})
		local configListContainer = nil
		local configListLayout = nil
		local configNameInput = nil

		local function buildConfigRow(name, parentFrame)
			local rowH = isMobile and 36 or 32
			local Row = Instance.new("Frame")
			Row.Name = randomName(12)
			Row.Size = UDim2.new(1, 0, 0, rowH)
			Row.BackgroundColor3 = Theme.Surface
			Row.BorderSizePixel = 0
			Row.ZIndex = 4
			Row.Parent = parentFrame
			local RowCorner = Instance.new("UICorner")
			RowCorner.CornerRadius = UDim.new(0, 4)
			RowCorner.Parent = Row
			local RowStroke = Instance.new("UIStroke")
			RowStroke.Color = Theme.Border
			RowStroke.Thickness = 1
			RowStroke.Transparency = 0.5
			RowStroke.Parent = Row
			local LeftAccent = Instance.new("Frame")
			LeftAccent.Size = UDim2.new(0, 3, 1, 0)
			LeftAccent.BackgroundColor3 = Theme.Primary
			LeftAccent.BorderSizePixel = 0
			LeftAccent.ZIndex = 5
			LeftAccent.Parent = Row
			local LeftAccentCorner = Instance.new("UICorner")
			LeftAccentCorner.CornerRadius = UDim.new(0, 4)
			LeftAccentCorner.Parent = LeftAccent
			local NameLabel = Instance.new("TextLabel")
			NameLabel.Size = UDim2.new(1, -130, 1, 0)
			NameLabel.Position = UDim2.new(0, 12, 0, 0)
			NameLabel.BackgroundTransparency = 1
			NameLabel.Text = name
			NameLabel.Font = Enum.Font.GothamMedium
			NameLabel.TextSize = isMobile and 10 or 11
			NameLabel.TextColor3 = Theme.Text
			NameLabel.TextXAlignment = Enum.TextXAlignment.Left
			NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			NameLabel.ZIndex = 5
			NameLabel.Parent = Row
			local btnW = isMobile and 44 or 48
			local btnH = isMobile and 22 or 20
			local LoadBtn = Instance.new("TextButton")
			LoadBtn.Size = UDim2.new(0, btnW, 0, btnH)
			LoadBtn.Position = UDim2.new(1, -(btnW * 2 + 14), 0.5, -btnH / 2)
			LoadBtn.BackgroundColor3 = Theme.Primary
			LoadBtn.BackgroundTransparency = 0.2
			LoadBtn.Text = "Carregar"
			LoadBtn.Font = Enum.Font.GothamBold
			LoadBtn.TextSize = isMobile and 8 or 9
			LoadBtn.TextColor3 = Theme.Text
			LoadBtn.AutoButtonColor = false
			LoadBtn.ZIndex = 5
			LoadBtn.Parent = Row
			local LoadCorner = Instance.new("UICorner")
			LoadCorner.CornerRadius = UDim.new(0, 4)
			LoadCorner.Parent = LoadBtn
			local DelBtn = Instance.new("TextButton")
			DelBtn.Size = UDim2.new(0, btnW, 0, btnH)
			DelBtn.Position = UDim2.new(1, -(btnW + 6), 0.5, -btnH / 2)
			DelBtn.BackgroundColor3 = Theme.Error
			DelBtn.BackgroundTransparency = 0.3
			DelBtn.Text = "Deletar"
			DelBtn.Font = Enum.Font.GothamBold
			DelBtn.TextSize = isMobile and 8 or 9
			DelBtn.TextColor3 = Theme.Text
			DelBtn.AutoButtonColor = false
			DelBtn.ZIndex = 5
			DelBtn.Parent = Row
			local DelCorner = Instance.new("UICorner")
			DelCorner.CornerRadius = UDim.new(0, 4)
			DelCorner.Parent = DelBtn
			LoadBtn.MouseEnter:Connect(function()
				TweenService:Create(LoadBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
			end)
			LoadBtn.MouseLeave:Connect(function()
				TweenService:Create(LoadBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
			end)
			DelBtn.MouseEnter:Connect(function()
				TweenService:Create(DelBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
			end)
			DelBtn.MouseLeave:Connect(function()
				TweenService:Create(DelBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
			end)
			return Row, LoadBtn, DelBtn
		end

		local function refreshConfigList()
			if not configListContainer then return end
			for _, child in ipairs(configListContainer:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
			local configs = Window:GetConfigList()
			if #configs == 0 then
				local EmptyLabel = Instance.new("TextLabel")
				EmptyLabel.Size = UDim2.new(1, 0, 0, isMobile and 32 or 28)
				EmptyLabel.BackgroundTransparency = 1
				EmptyLabel.Text = "Nenhum config salvo."
				EmptyLabel.Font = Enum.Font.Gotham
				EmptyLabel.TextSize = isMobile and 10 or 11
				EmptyLabel.TextColor3 = Theme.TextMuted
				EmptyLabel.ZIndex = 4
				EmptyLabel.Parent = configListContainer
			else
				for _, cfgName in ipairs(configs) do
					local Row, LoadBtn, DelBtn = buildConfigRow(cfgName, configListContainer)
					LoadBtn.MouseButton1Click:Connect(function()
						PlaySound(Sounds.ToggleOn, 0.3, 1)
						local ok = Window:LoadConfig(cfgName)
						if ok then
							CreateNotification({Title = "Configs", Message = "Config \"" .. cfgName .. "\" carregado!", Type = "Success", Duration = 3})
						else
							CreateNotification({Title = "Configs", Message = "Falha ao carregar \"" .. cfgName .. "\".", Type = "Error", Duration = 3})
						end
					end)
					DelBtn.MouseButton1Click:Connect(function()
						PlaySound(Sounds.ToggleOff, 0.3, 0.9)
						Window:DeleteConfig(cfgName)
						CreateNotification({Title = "Configs", Message = "Config \"" .. cfgName .. "\" deletado.", Type = "Warning", Duration = 3})
						refreshConfigList()
					end)
				end
			end
		end

		ConfigsTab._onActivate = refreshConfigList

		ConfigsTab:AddSection("Salvar Config")

		configNameInput = ConfigsTab:AddTextbox({
			Name = "Nome",
			Placeholder = "Nome do config...",
			Default = ""
		})

		ConfigsTab:AddButton({
			Name = "💾  Salvar Config",
			Callback = function()
				local name = configNameInput:GetValue()
				if not name or name == "" then
					CreateNotification({Title = "Configs", Message = "Digite um nome para o config.", Type = "Warning", Duration = 3})
					return
				end
				local ok = Window:SaveConfig(name)
				if ok then
					CreateNotification({Title = "Configs", Message = "Config \"" .. name .. "\" salvo!", Type = "Success", Duration = 3})
					refreshConfigList()
				else
					CreateNotification({Title = "Configs", Message = "Falha ao salvar config.", Type = "Error", Duration = 3})
				end
			end
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

		local SettingsTab = Window:CreateTab({Name = "Settings", Icon = "⚙", _order = 9999})
		SettingsTab:AddSection("Watermark")
		SettingsTab:AddToggle({
			Name = "Mostrar Watermark",
			Default = false,
			HideFromHUD = true,
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
		SettingsTab:AddToggle({
			Name = "KeyBind List",
			Default = false,
			HideFromHUD = true,
			Callback = function(state)
				if state then
					if HUDFrame and HUDFrame.Parent then HUDFrame:Destroy() HUDFrame = nil end
					if HUDConnection then HUDConnection:Disconnect() HUDConnection = nil end
					ShowHUD()
				else
					HideHUD()
				end
			end
		})
		if not loadingFinished then
			local fakeSteps = {
				{ progress = 12,  status = "Iniciando módulos...",        delay = 0.40 },
				{ progress = 28,  status = "Carregando recursos...",       delay = 0.50 },
				{ progress = 45,  status = "Conectando ao servidor...",    delay = 0.55 },
				{ progress = 60,  status = "Verificando autenticação...",  delay = 0.50 },
				{ progress = 74,  status = "Aplicando configurações...",   delay = 0.45 },
				{ progress = 88,  status = "Quase lá...",                  delay = 0.40 },
				{ progress = 96,  status = "Finalizando...",               delay = 0.35 },
			}
			for _, step in ipairs(fakeSteps) do
				Window:SetLoadingProgress(step.progress, step.status)
				task.wait(step.delay)
			end
			Window:FinishLoading()
		end
		MainContainer.Visible = true
		if isMobile then
			FloatingButton.Visible = false
		end
	end)
	return Window
end
return QuantomLib
