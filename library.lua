-- Adicione esta função à sua QuantomLib

function QuantomLib:CreateUserProfile(config)
    config = config or {}
    
    -- User info
    local Player = Players.LocalPlayer
    local userId = Player.UserId
    local userName = config.UserName or Player.Name
    local displayName = config.DisplayName or Player.DisplayName
    
    -- Profile Container
    local ProfileContainer = Instance.new("Frame")
    ProfileContainer.Name = "UserProfile"
    ProfileContainer.Size = UDim2.new(1, -20, 0, isMobile and 65 or 60)
    ProfileContainer.Position = UDim2.new(0, 10, 1, -(isMobile and 75 or 70))
    ProfileContainer.BackgroundColor3 = Theme.Surface
    ProfileContainer.BorderSizePixel = 0
    ProfileContainer.ZIndex = 3
    ProfileContainer.Parent = config.Parent
    
    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileContainer
    
    local ProfileStroke = Instance.new("UIStroke")
    ProfileStroke.Color = Theme.Border
    ProfileStroke.Thickness = 1
    ProfileStroke.Transparency = 0.5
    ProfileStroke.Parent = ProfileContainer
    
    -- Avatar Container
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Size = UDim2.new(0, isMobile and 42 or 40, 0, isMobile and 42 or 40)
    AvatarFrame.Position = UDim2.new(0, 10, 0.5, -(isMobile and 21 or 20))
    AvatarFrame.BackgroundColor3 = Theme.SurfaceLight
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.ZIndex = 4
    AvatarFrame.Parent = ProfileContainer
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarFrame
    
    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Color = Theme.Primary
    AvatarStroke.Thickness = 2
    AvatarStroke.Transparency = 0
    AvatarStroke.Parent = AvatarFrame
    
    -- Avatar Image
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(1, 0, 1, 0)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
    AvatarImage.ZIndex = 5
    AvatarImage.Parent = AvatarFrame
    
    local AvatarImgCorner = Instance.new("UICorner")
    AvatarImgCorner.CornerRadius = UDim.new(1, 0)
    AvatarImgCorner.Parent = AvatarImage
    
    -- User Info Container
    local InfoContainer = Instance.new("Frame")
    InfoContainer.Size = UDim2.new(1, -(isMobile and 110 or 100), 1, 0)
    InfoContainer.Position = UDim2.new(0, isMobile and 60 or 58, 0, 0)
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.ZIndex = 4
    InfoContainer.Parent = ProfileContainer
    
    -- Display Name
    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Size = UDim2.new(1, 0, 0, isMobile and 18 or 16)
    DisplayNameLabel.Position = UDim2.new(0, 0, 0, isMobile and 12 or 14)
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Text = displayName
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.TextSize = isMobile and 12 or 13
    DisplayNameLabel.TextColor3 = Theme.Text
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayNameLabel.ZIndex = 5
    DisplayNameLabel.Parent = InfoContainer
    
    -- Username (@username)
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, 0, 0, isMobile and 14 or 13)
    UsernameLabel.Position = UDim2.new(0, 0, 0, isMobile and 30 or 30)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = "@" .. userName
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextSize = isMobile and 10 or 10
    UsernameLabel.TextColor3 = Theme.TextSecondary
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.ZIndex = 5
    UsernameLabel.Parent = InfoContainer
    
    -- Settings Button
    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Size = UDim2.new(0, isMobile and 36 or 34, 0, isMobile and 36 or 34)
    SettingsButton.Position = UDim2.new(1, -(isMobile and 42 or 40), 0.5, -(isMobile and 18 or 17))
    SettingsButton.BackgroundColor3 = Theme.SurfaceHover
    SettingsButton.BackgroundTransparency = 0
    SettingsButton.AutoButtonColor = false
    SettingsButton.Text = ""
    SettingsButton.ZIndex = 4
    SettingsButton.Parent = ProfileContainer
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 6)
    SettingsCorner.Parent = SettingsButton
    
    local SettingsIcon = Instance.new("TextLabel")
    SettingsIcon.Size = UDim2.new(1, 0, 1, 0)
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.Text = "⚙"
    SettingsIcon.Font = Enum.Font.GothamBold
    SettingsIcon.TextSize = isMobile and 18 or 16
    SettingsIcon.TextColor3 = Theme.TextMuted
    SettingsIcon.ZIndex = 5
    SettingsIcon.Parent = SettingsButton
    
    -- Hover Effects
    SettingsButton.MouseEnter:Connect(function()
        TweenService:Create(SettingsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Primary
        }):Play()
        TweenService:Create(SettingsIcon, TweenInfo.new(0.2), {
            TextColor3 = Theme.Text,
            Rotation = 90
        }):Play()
    end)
    
    SettingsButton.MouseLeave:Connect(function()
        TweenService:Create(SettingsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.SurfaceHover
        }):Play()
        TweenService:Create(SettingsIcon, TweenInfo.new(0.2), {
            TextColor3 = Theme.TextMuted,
            Rotation = 0
        }):Play()
    end)
    
    -- Settings Menu (você vai configurar depois)
    local SettingsMenu = {
        Container = ProfileContainer,
        Button = SettingsButton,
        IsOpen = false
    }
    
    SettingsButton.MouseButton1Click:Connect(function()
        if config.OnSettingsClick then
            config.OnSettingsClick(SettingsMenu)
        end
    end)
    
    return SettingsMenu
end
