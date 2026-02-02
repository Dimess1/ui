local QuantomLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function MakeDraggable(frame, dragToggle)
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.15), {Position = position}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input == dragInput and dragInput then
            update(input)
        end
    end)
end

function QuantomLib:CreateWindow(config)
    local WindowName = config.Name or "Quantom UI"
    local WindowVersion = config.Version or "v1.0"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "QuantomUI_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar

    local TopBarCover = Instance.new("Frame")
    TopBarCover.Size = UDim2.new(1, 0, 0, 10)
    TopBarCover.Position = UDim2.new(0, 0, 1, -10)
    TopBarCover.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    TopBarCover.BorderSizePixel = 0
    TopBarCover.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowName .. " " .. WindowVersion
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton

    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(0, 120, 1, -50)
    TabsContainer.Position = UDim2.new(0, 10, 0, 45)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainFrame

    local TabsCorner = Instance.new("UICorner")
    TabsCorner.CornerRadius = UDim.new(0, 8)
    TabsCorner.Parent = TabsContainer

    local TabsList = Instance.new("UIListLayout")
    TabsList.Padding = UDim.new(0, 5)
    TabsList.Parent = TabsContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -145, 1, -50)
    ContentContainer.Position = UDim2.new(0, 135, 0, 45)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer

    MakeDraggable(MainFrame, true)

    local isVisible = true
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        isVisible = false
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end
    end)

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        local MobileToggle = Instance.new("TextButton")
        MobileToggle.Name = "MobileToggle"
        MobileToggle.Size = UDim2.new(0, 60, 0, 60)
        MobileToggle.Position = UDim2.new(0, 10, 0.5, -30)
        MobileToggle.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        MobileToggle.Text = "Q"
        MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        MobileToggle.TextSize = 24
        MobileToggle.Font = Enum.Font.GothamBold
        MobileToggle.Parent = ScreenGui

        local MobileCorner = Instance.new("UICorner")
        MobileCorner.CornerRadius = UDim.new(1, 0)
        MobileCorner.Parent = MobileToggle

        MakeDraggable(MobileToggle, true)

        MobileToggle.MouseButton1Click:Connect(function()
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end)
    end

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil

    function Window:CreateTab(config)
        local TabName = config.Name or "Tab"
        local TabIcon = config.Icon or "📄"

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.Text = TabIcon .. " " .. TabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabsContainer

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton

        local TabButtonPadding = Instance.new("UIPadding")
        TabButtonPadding.PaddingLeft = UDim.new(0, 10)
        TabButtonPadding.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = TabName .. "_Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        local TabContentList = Instance.new("UIListLayout")
        TabContentList.Padding = UDim.new(0, 8)
        TabContentList.Parent = TabContent

        TabContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentList.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                tab.Content.Visible = false
            end

            TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = TabName
        end)

        if not Window.CurrentTab then
            TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = TabName
        end

        local Tab = {}
        Tab.Button = TabButton
        Tab.Content = TabContent
        Window.Tabs[TabName] = Tab

        function Tab:AddSection(sectionName)
            local Section = Instance.new("Frame")
            Section.Name = sectionName
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            Section.BorderSizePixel = 0
            Section.Parent = TabContent

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -10, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = sectionName
            SectionLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
            SectionLabel.TextSize = 14
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Section
        end

        function Tab:AddToggle(config)
            local ToggleName = config.Name or "Toggle"
            local DefaultValue = config.Default or false
            local Callback = config.Callback or function() end

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = ToggleName
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = ToggleName
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleButton.BackgroundColor3 = DefaultValue and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 65)
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame

            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
            ToggleButtonCorner.Parent = ToggleButton

            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            ToggleIndicator.Position = DefaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleButton

            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = ToggleIndicator

            local toggled = DefaultValue

            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled

                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = toggled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 65)
                }):Play()

                TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()

                Callback(toggled)
            end)
        end

        function Tab:AddButton(config)
            local ButtonName = config.Name or "Button"
            local Callback = config.Callback or function() end

            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = ButtonName
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            ButtonFrame.Text = ButtonName
            ButtonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonFrame.TextSize = 13
            ButtonFrame.Font = Enum.Font.GothamBold
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame

            ButtonFrame.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(118, 23, 206)
                }):Play()

                task.wait(0.1)

                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                }):Play()

                Callback()
            end)
        end

        function Tab:AddSlider(config)
            local SliderName = config.Name or "Slider"
            local Min = config.Min or 0
            local Max = config.Max or 100
            local Default = config.Default or Min
            local Callback = config.Callback or function() end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = SliderName
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -10, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = SliderName .. ": " .. Default
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local SliderBackground = Instance.new("Frame")
            SliderBackground.Size = UDim2.new(1, -20, 0, 4)
            SliderBackground.Position = UDim2.new(0, 10, 1, -12)
            SliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            SliderBackground.BorderSizePixel = 0
            SliderBackground.Parent = SliderFrame

            local SliderBgCorner = Instance.new("UICorner")
            SliderBgCorner.CornerRadius = UDim.new(1, 0)
            SliderBgCorner.Parent = SliderBackground

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBackground

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local dragging = false

            SliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                   input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = math.clamp((mousePos.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    local value = math.floor(Min + (Max - Min) * relativePos)

                    SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                    SliderLabel.Text = SliderName .. ": " .. value
                    Callback(value)
                end
            end)
        end

        function Tab:AddDropdown(config)
            local DropdownName = config.Name or "Dropdown"
            local Options = config.Options or {}
            local Default = config.Default or Options[1] or ""
            local Callback = config.Callback or function() end

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = DropdownName
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabContent

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -10, 0, 35)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = DropdownName .. ": " .. Default
            DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 35)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame

            local expanded = false
            local selectedOption = Default

            DropdownButton.MouseButton1Click:Connect(function()
                expanded = not expanded

                if expanded then
                    local newSize = 35 + (#Options * 30)
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, newSize)
                    }):Play()
                else
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 35)
                    }):Play()
                end
            end)

            for i, option in ipairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -10, 0, 25)
                OptionButton.Position = UDim2.new(0, 5, 0, 35 + ((i - 1) * 30))
                OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = DropdownFrame

                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton

                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    DropdownLabel.Text = DropdownName .. ": " .. option
                    expanded = false

                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 35)
                    }):Play()

                    Callback(option)
                end)
            end
        end

        return Tab
    end

    function Window:Notify(config)
        local Title = config.Title or "Notification"
        local Message = config.Message or ""
        local Type = config.Type or "Info"
        local Duration = config.Duration or 3

        local NotificationFrame = Instance.new("Frame")
        NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
        NotificationFrame.Position = UDim2.new(1, -310, 1, 10)
        NotificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.Parent = ScreenGui

        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotificationFrame

        local NotifBar = Instance.new("Frame")
        NotifBar.Size = UDim2.new(0, 4, 1, 0)
        NotifBar.BackgroundColor3 = Type == "Success" and Color3.fromRGB(0, 255, 0) or 
                                      Type == "Error" and Color3.fromRGB(255, 0, 0) or 
                                      Type == "Warning" and Color3.fromRGB(255, 200, 0) or 
                                      Color3.fromRGB(138, 43, 226)
        NotifBar.BorderSizePixel = 0
        NotifBar.Parent = NotificationFrame

        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -20, 0, 25)
        NotifTitle.Position = UDim2.new(0, 15, 0, 5)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = Title
        NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        NotifTitle.TextSize = 14
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = NotificationFrame

        local NotifMessage = Instance.new("TextLabel")
        NotifMessage.Size = UDim2.new(1, -20, 1, -30)
        NotifMessage.Position = UDim2.new(0, 15, 0, 25)
        NotifMessage.BackgroundTransparency = 1
        NotifMessage.Text = Message
        NotifMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
        NotifMessage.TextSize = 12
        NotifMessage.Font = Enum.Font.Gotham
        NotifMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotifMessage.TextYAlignment = Enum.TextYAlignment.Top
        NotifMessage.TextWrapped = true
        NotifMessage.Parent = NotificationFrame

        TweenService:Create(NotificationFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -310, 1, -90)
        }):Play()

        task.delay(Duration, function()
            TweenService:Create(NotificationFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(1, -310, 1, 10)
            }):Play()

            task.wait(0.3)
            NotificationFrame:Destroy()
        end)
    end

    function Window:Show()
        MainFrame.Visible = true
    end

    function Window:Hide()
        MainFrame.Visible = false
    end

    return Window
end

return QuantomLib
