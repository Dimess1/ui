local QuantomLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dimess1/ui/refs/heads/main/library.lua'))()

local cloneref = cloneref or function(instance) return instance end
local clonefunction = clonefunction or function(f) return f end

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Stats = cloneref(game:GetService("Stats"))
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local player = LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local function bindCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    bindCharacter()
end)

local SilentAimSettings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = false,
    FOV = 150,
    MaxDistance = 10000000000,
    LockPart = "Head",
    ShowFOV = true,
    Mode = "FPS"
}

local CurrentSilentTarget = nil
local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Visible = false
SilentFOVCircle.Thickness = 2
SilentFOVCircle.Color = Color3.fromRGB(138, 43, 226)
SilentFOVCircle.Filled = false
SilentFOVCircle.Radius = SilentAimSettings.FOV
SilentFOVCircle.Transparency = 0.5

local function isPlayerAliveSilent(targetPlayer)
    local character = targetPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isVisibleSilent(targetPlayer, part)
    if not SilentAimSettings.WallCheck then return true end
    local character = LocalPlayer.Character
    if not character then return false end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude

    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character, Camera})

    if hit then
        return hit:IsDescendantOf(targetPlayer.Character)
    end

    return true
end

local function getClosestSilentAimTarget()
    local nearest = nil
    local shortestDist = math.huge
    local viewportCenter = Camera.ViewportSize / 2

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and targetPlayer.Team == LocalPlayer.Team then continue end
        if SilentAimSettings.AliveCheck and not isPlayerAliveSilent(targetPlayer) then continue end

        local character = targetPlayer.Character
        if not character then continue end

        local part = character:FindFirstChild(SilentAimSettings.LockPart)
        if not part then
            part = character:FindFirstChild("Head")
        end
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
        if distance >= SilentAimSettings.FOV then continue end

        local distance3D = (part.Position - Camera.CFrame.Position).Magnitude
        if distance3D >= SilentAimSettings.MaxDistance then continue end

        if not isVisibleSilent(targetPlayer, part) then continue end

        if distance < shortestDist then
            shortestDist = distance
            nearest = {player = targetPlayer, part = part, distance = distance}
        end
    end

    return nearest
end

local function getClosestSilentAimTargetTPS()
    local nearest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == LocalPlayer then continue end
        if SilentAimSettings.TeamCheck and targetPlayer.Team == LocalPlayer.Team then continue end
        if SilentAimSettings.AliveCheck and not isPlayerAliveSilent(targetPlayer) then continue end

        local character = targetPlayer.Character
        if not character then continue end

        local part = character:FindFirstChild(SilentAimSettings.LockPart)
        if not part then
            part = character:FindFirstChild("Head")
        end
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance >= SilentAimSettings.FOV then continue end

        local distance3D = (part.Position - Camera.CFrame.Position).Magnitude
        if distance3D >= SilentAimSettings.MaxDistance then continue end

        if not isVisibleSilent(targetPlayer, part) then continue end

        if distance < shortestDist then
            shortestDist = distance
            nearest = {player = targetPlayer, part = part, distance = distance}
        end
    end

    return nearest
end

local Mouse = LocalPlayer:GetMouse()

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if SilentAimSettings.Enabled and CurrentSilentTarget and CurrentSilentTarget.part then
        if (Method == "FireServer" or Method == "InvokeServer") then
            local remoteName = tostring(Self)

            if remoteName:lower():find("fire") or remoteName:lower():find("shoot") or 
               remoteName:lower():find("hit") or remoteName:lower():find("damage") or
               remoteName:lower():find("bullet") or remoteName:lower():find("ray") then

                for i = 1, #Args do
                    local arg = Args[i]

                    if typeof(arg) == "Vector3" then
                        Args[i] = CurrentSilentTarget.part.Position
                    elseif typeof(arg) == "CFrame" then
                        Args[i] = CurrentSilentTarget.part.CFrame
                    elseif typeof(arg) == "Ray" then
                        local direction = (CurrentSilentTarget.part.Position - Camera.CFrame.Position).Unit * 1000
                        Args[i] = Ray.new(Camera.CFrame.Position, direction)
                    elseif typeof(arg) == "table" then
                        if arg.Position or arg.position then
                            arg.Position = CurrentSilentTarget.part.Position
                            arg.position = CurrentSilentTarget.part.Position
                        end
                        if arg.Hit or arg.hit then
                            arg.Hit = CurrentSilentTarget.part
                            arg.hit = CurrentSilentTarget.part
                        end
                        if arg.Part or arg.part then
                            arg.Part = CurrentSilentTarget.part
                            arg.part = CurrentSilentTarget.part
                        end
                    end
                end
            end
        end
    end

    return OldNamecall(Self, unpack(Args))
end))

local OldIndex
OldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, Key)
    if checkcaller() then return OldIndex(Self, Key) end

    if SilentAimSettings.Enabled and CurrentSilentTarget and CurrentSilentTarget.part then
        if Self == Mouse then
            if Key == "Hit" then
                return CurrentSilentTarget.part.CFrame
            elseif Key == "Target" then
                return CurrentSilentTarget.part
            elseif Key == "X" then
                return CurrentSilentTarget.part.Position.X
            elseif Key == "Y" then
                return CurrentSilentTarget.part.Position.Y  
            elseif Key == "Z" then
                return CurrentSilentTarget.part.Position.Z
            end
        end
    end

    return OldIndex(Self, Key)
end))

local Window = QuantomLib:CreateWindow({
    Name = "Quantom.gg",
    Version = "v1.1.0"
})

Window:Notify({
    Title = "Bem-vindo!",
    Message = "UI carregada com sucesso",
    Type = "Success",
    Duration = 3
})

local AimTab = Window:CreateTab({
    Name = "Aim",
    Icon = "🎯"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁"
})

local PlayersTab = Window:CreateTab({
    Name = "Players",
    Icon = "👥"
})

local ExploitsTab = Window:CreateTab({
    Name = "Exploits",
    Icon = "⚡"
})

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "⚙️"
})

local NoRecoilEnabled = false
local OriginalSettings = {}

local function ModifyWeaponSettings(weapon, removeRecoil)
    if weapon and weapon:FindFirstChild("ACS_Settings") then
        local settingsModule = weapon.ACS_Settings
        local success, settings = pcall(function()
            return require(settingsModule)
        end)

        if success and settings then
            local weaponKey = weapon.Name

            if removeRecoil then
                if not OriginalSettings[weaponKey] then
                    OriginalSettings[weaponKey] = {
                        camRecoil = {
                            camRecoilUp = {settings.camRecoil.camRecoilUp[1], settings.camRecoil.camRecoilUp[2]},
                            camRecoilTilt = {settings.camRecoil.camRecoilTilt[1], settings.camRecoil.camRecoilTilt[2]},
                            camRecoilLeft = {settings.camRecoil.camRecoilLeft[1], settings.camRecoil.camRecoilLeft[2]},
                            camRecoilRight = {settings.camRecoil.camRecoilRight[1], settings.camRecoil.camRecoilRight[2]}
                        },
                        gunRecoil = {
                            gunRecoilUp = {settings.gunRecoil.gunRecoilUp[1], settings.gunRecoil.gunRecoilUp[2]},
                            gunRecoilTilt = {settings.gunRecoil.gunRecoilTilt[1], settings.gunRecoil.gunRecoilTilt[2]},
                            gunRecoilLeft = {settings.gunRecoil.gunRecoilLeft[1], settings.gunRecoil.gunRecoilLeft[2]},
                            gunRecoilRight = {settings.gunRecoil.gunRecoilRight[1], settings.gunRecoil.gunRecoilRight[2]}
                        }
                    }
                end

                settings.camRecoil.camRecoilUp = {0, 0}
                settings.camRecoil.camRecoilTilt = {0, 0}
                settings.camRecoil.camRecoilLeft = {0, 0}
                settings.camRecoil.camRecoilRight = {0, 0}

                settings.gunRecoil.gunRecoilUp = {0, 0}
                settings.gunRecoil.gunRecoilTilt = {0, 0}
                settings.gunRecoil.gunRecoilLeft = {0, 0}
                settings.gunRecoil.gunRecoilRight = {0, 0}
            else
                if OriginalSettings[weaponKey] then
                    settings.camRecoil.camRecoilUp = OriginalSettings[weaponKey].camRecoil.camRecoilUp
                    settings.camRecoil.camRecoilTilt = OriginalSettings[weaponKey].camRecoil.camRecoilTilt
                    settings.camRecoil.camRecoilLeft = OriginalSettings[weaponKey].camRecoil.camRecoilLeft
                    settings.camRecoil.camRecoilRight = OriginalSettings[weaponKey].camRecoil.camRecoilRight

                    settings.gunRecoil.gunRecoilUp = OriginalSettings[weaponKey].gunRecoil.gunRecoilUp
                    settings.gunRecoil.gunRecoilTilt = OriginalSettings[weaponKey].gunRecoil.gunRecoilTilt
                    settings.gunRecoil.gunRecoilLeft = OriginalSettings[weaponKey].gunRecoil.gunRecoilLeft
                    settings.gunRecoil.gunRecoilRight = OriginalSettings[weaponKey].gunRecoil.gunRecoilRight
                end
            end
        end
    end
end

local function UpdateAllWeapons()
    local character = LocalPlayer.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                ModifyWeaponSettings(item, NoRecoilEnabled)
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                ModifyWeaponSettings(item, NoRecoilEnabled)
            end
        end
    end
end

AimTab:AddSection("NO RECOIL")

AimTab:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(state)
        NoRecoilEnabled = state
        UpdateAllWeapons()
        Window:Notify({
            Title = "No Recoil",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and NoRecoilEnabled then
            wait(0.1)
            ModifyWeaponSettings(child, true)
        end
    end)
end)

local Backpack = LocalPlayer:WaitForChild("Backpack")
Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and NoRecoilEnabled then
        wait(0.1)
        ModifyWeaponSettings(child, true)
    end
end)

AimTab:AddSection("AIMBOT PC")

local ValidBodyParts = {
    "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"
}

local AimbotSettings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = false,
    InvisibleCheck = true,
    Sensitivity = 0.15,
    FOV = 60,
    MaxDistance = 10000000000,
    TargetPart = "Head"
}

local AimbotRunning = false
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(138, 43, 226)
FOVCircle.Filled = false
FOVCircle.Radius = AimbotSettings.FOV
FOVCircle.Transparency = 0.5

local function isPlayerAlive(targetPlayer)
    local character = targetPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isPlayerInvisible(targetPlayer)
    local character = targetPlayer.Character
    if not character then return true end

    local totalTransparency = 0
    local partsCount = 0

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            totalTransparency = totalTransparency + part.Transparency
            partsCount = partsCount + 1
        end
    end

    if partsCount > 0 then
        return (totalTransparency / partsCount) > 0.9
    end
    return false
end

local function isVisible(targetPlayer, part)
    if not AimbotSettings.WallCheck then return true end
    local character = LocalPlayer.Character
    if not character then return false end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude

    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character, Camera})

    if hit then
        return hit:IsDescendantOf(targetPlayer.Character)
    end

    return true
end

local function getTargetPart(character, partName)
    local part = character:FindFirstChild(partName)
    if not part then
        part = character:FindFirstChild("Head")
    end
    return part
end

local function getClosestAimbotTarget()
    local nearest = nil
    local shortestDist = math.huge
    local viewportCenter = Camera.ViewportSize / 2

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == LocalPlayer then continue end
        if AimbotSettings.TeamCheck and targetPlayer.Team == LocalPlayer.Team then continue end
        if AimbotSettings.AliveCheck and not isPlayerAlive(targetPlayer) then continue end
        if AimbotSettings.InvisibleCheck and isPlayerInvisible(targetPlayer) then continue end

        local character = targetPlayer.Character
        if not character then continue end

        local part = getTargetPart(character, AimbotSettings.TargetPart)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
        if distance >= AimbotSettings.FOV or distance >= AimbotSettings.MaxDistance then continue end

        if not isVisible(targetPlayer, part) then continue end

        if distance < shortestDist then
            shortestDist = distance
            nearest = {player = targetPlayer, part = part, distance = distance}
        end
    end

    return nearest
end

local function smoothLookAt(target)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, target)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSettings.Sensitivity)
end

AimTab:AddToggle({
    Name = "Aimbot PC",
    Default = false,
    Callback = function(state)
        AimbotSettings.Enabled = state
        if not state then AimbotRunning = false end
        Window:Notify({
            Title = "Aimbot PC",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

AimTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(state)
        AimbotSettings.TeamCheck = state
    end
})

AimTab:AddToggle({
    Name = "Invisible Check",
    Default = true,
    Callback = function(state)
        AimbotSettings.InvisibleCheck = state
    end
})

AimTab:AddToggle({
    Name = "Wall Check",
    Default = false,
    Callback = function(state)
        AimbotSettings.WallCheck = state
    end
})

AimTab:AddDropdown({
    Name = "Parte do Corpo",
    Options = ValidBodyParts,
    Default = "Head",
    Callback = function(value)
        AimbotSettings.TargetPart = value
        Window:Notify({
            Title = "Aimbot PC",
            Message = "Mirando em: " .. value,
            Type = "Info"
        })
    end
})

AimTab:AddSlider({
    Name = "FOV",
    Min = 10,
    Max = 300,
    Default = 60,
    Callback = function(value)
        AimbotSettings.FOV = value
    end
})

AimTab:AddSlider({
    Name = "Suavidade",
    Min = 1,
    Max = 100,
    Default = 15,
    Callback = function(value)
        AimbotSettings.Sensitivity = value / 100
    end
})

AimTab:AddSection("AIMBOT MOBILE")

local MobileAimbotSettings = {
    Enabled = false,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = false,
    FOV = 60,
    MaxDistance = 400,
    MaxTransparency = 0.1,
    TargetPart = "Head",
    Smoothness = 0.15
}

local MobileFOVRing = Drawing.new("Circle")
MobileFOVRing.Visible = false
MobileFOVRing.Thickness = 2
MobileFOVRing.Color = Color3.fromRGB(138, 43, 226)
MobileFOVRing.Filled = false
MobileFOVRing.Radius = MobileAimbotSettings.FOV
MobileFOVRing.Position = Camera.ViewportSize / 2
MobileFOVRing.Transparency = MobileAimbotSettings.MaxTransparency

local function getClosestMobileTarget()
    local nearest = nil
    local shortestDist = math.huge
    local viewportCenter = Camera.ViewportSize / 2

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if MobileAimbotSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
        if MobileAimbotSettings.AliveCheck and not isPlayerAlive(p) then continue end

        local character = p.Character
        if not character then continue end

        local part = getTargetPart(character, MobileAimbotSettings.TargetPart)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
        if distance >= MobileAimbotSettings.FOV then continue end

        local dist3D = (part.Position - Camera.CFrame.Position).Magnitude
        if dist3D >= MobileAimbotSettings.MaxDistance then continue end

        if MobileAimbotSettings.WallCheck then
            local char = LocalPlayer.Character
            if char then
                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position))
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                if hit and not hit:IsDescendantOf(character) then continue end
            end
        end

        if distance < shortestDist then
            shortestDist = distance
            nearest = {player = p, part = part, distance = distance}
        end
    end

    return nearest
end

local function mobileSmoothLookAt(target)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, target)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, MobileAimbotSettings.Smoothness)
end

AimTab:AddToggle({
    Name = "Aimbot Mobile",
    Default = false,
    Callback = function(state)
        MobileAimbotSettings.Enabled = state
        MobileFOVRing.Visible = state
        Window:Notify({
            Title = "Aimbot Mobile",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

AimTab:AddToggle({
    Name = "Team Check (Mobile)",
    Default = false,
    Callback = function(state)
        MobileAimbotSettings.TeamCheck = state
    end
})

AimTab:AddToggle({
    Name = "Wall Check (Mobile)",
    Default = false,
    Callback = function(state)
        MobileAimbotSettings.WallCheck = state
    end
})

AimTab:AddDropdown({
    Name = "Parte do Corpo (Mobile)",
    Options = ValidBodyParts,
    Default = "Head",
    Callback = function(value)
        MobileAimbotSettings.TargetPart = value
        Window:Notify({
            Title = "Aimbot Mobile",
            Message = "Mirando em: " .. value,
            Type = "Info"
        })
    end
})

AimTab:AddSlider({
    Name = "FOV (Mobile)",
    Min = 10,
    Max = 300,
    Default = 60,
    Callback = function(value)
        MobileAimbotSettings.FOV = value
    end
})

AimTab:AddSlider({
    Name = "Suavidade (Mobile)",
    Min = 1,
    Max = 100,
    Default = 15,
    Callback = function(value)
        MobileAimbotSettings.Smoothness = value / 100
    end
})

AimTab:AddSlider({
    Name = "Distância Máxima",
    Min = 100,
    Max = 1000,
    Default = 400,
    Callback = function(value)
        MobileAimbotSettings.MaxDistance = value
    end
})

AimTab:AddSection("SILENT AIM")

AimTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(state)
        SilentAimSettings.Enabled = state
        if not state then CurrentSilentTarget = nil end
        Window:Notify({
            Title = "Silent Aim",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

AimTab:AddDropdown({
    Name = "Modo Silent Aim",
    Options = {"FPS - 1ª Pessoa", "TPS - 3ª Pessoa"},
    Default = "FPS - 1ª Pessoa",
    Callback = function(value)
        if value == "FPS - 1ª Pessoa" then
            SilentAimSettings.Mode = "FPS"
        else
            SilentAimSettings.Mode = "TPS"
        end
        Window:Notify({
            Title = "Silent Aim",
            Message = "Modo: " .. value,
            Type = "Info"
        })
    end
})

AimTab:AddToggle({
    Name = "Team Check (Silent)",
    Default = false,
    Callback = function(state)
        SilentAimSettings.TeamCheck = state
    end
})

AimTab:AddToggle({
    Name = "FOV Circle",
    Default = true,
    Callback = function(state)
        SilentAimSettings.ShowFOV = state
    end
})

AimTab:AddToggle({
    Name = "Wall Check (Silent)",
    Default = false,
    Callback = function(state)
        SilentAimSettings.WallCheck = state
    end
})

AimTab:AddDropdown({
    Name = "Parte do Corpo (Silent)",
    Options = ValidBodyParts,
    Default = "Head",
    Callback = function(value)
        SilentAimSettings.LockPart = value
        Window:Notify({
            Title = "Silent Aim",
            Message = "Acertando em: " .. value,
            Type = "Info"
        })
    end
})

AimTab:AddSlider({
    Name = "FOV (Silent)",
    Min = 10,
    Max = 300,
    Default = 150,
    Callback = function(value)
        SilentAimSettings.FOV = value
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotSettings.Enabled then
        AimbotRunning = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotRunning = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = AimbotSettings.FOV

    if AimbotSettings.Enabled and AimbotRunning then
        FOVCircle.Visible = true
        local target = getClosestAimbotTarget()
        if target then
            smoothLookAt(target.part.Position)
            FOVCircle.Color = Color3.fromRGB(255, 70, 70)
        else
            FOVCircle.Color = Color3.fromRGB(138, 43, 226)
        end
    else
        FOVCircle.Visible = false
    end

    if MobileAimbotSettings.Enabled then
        MobileFOVRing.Position = Camera.ViewportSize / 2
        MobileFOVRing.Radius = MobileAimbotSettings.FOV
        MobileFOVRing.Visible = true

        local mTarget = getClosestMobileTarget()
        if mTarget then
            mobileSmoothLookAt(mTarget.part.Position)
            MobileFOVRing.Transparency = (1 - (mTarget.distance / MobileAimbotSettings.FOV)) * MobileAimbotSettings.MaxTransparency
            MobileFOVRing.Color = Color3.fromRGB(255, 70, 70)
        else
            MobileFOVRing.Transparency = MobileAimbotSettings.MaxTransparency
            MobileFOVRing.Color = Color3.fromRGB(138, 43, 226)
        end
    else
        MobileFOVRing.Visible = false
    end

    SilentFOVCircle.Position = UserInputService:GetMouseLocation()
    SilentFOVCircle.Radius = SilentAimSettings.FOV
    SilentFOVCircle.Visible = SilentAimSettings.Enabled and SilentAimSettings.ShowFOV

    if SilentAimSettings.Enabled then
        if SilentAimSettings.Mode == "TPS" then
            CurrentSilentTarget = getClosestSilentAimTargetTPS()
        else
            CurrentSilentTarget = getClosestSilentAimTarget()
        end

        if CurrentSilentTarget then
            SilentFOVCircle.Color = Color3.fromRGB(255, 70, 70)
        else
            SilentFOVCircle.Color = Color3.fromRGB(138, 43, 226)
        end
    else
        CurrentSilentTarget = nil
    end
end)

local ESP = {
    Box = false,
    Name = false,
    Health = false,
    Skeleton = false,
    Tracer = false,
    Distance = false,
    TeamCheck = true,
    DeadCheck = true,
    UseWhitelist = false,
    WhitelistedPlayers = {},
    IgnoredTeams = {},
    MaxDistance = 10000000000
}

local ESPObjects = {}
local ESPPlayerCache = {}

local function NewLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Transparency = 1
    l.Thickness = 1
    return l
end

local function NewText(size, center)
    local t = Drawing.new("Text")
    t.Size = size
    t.Center = center
    t.Outline = true
    t.Visible = false
    t.Transparency = 1
    return t
end

local function NewBox()
    local b = Drawing.new("Square")
    b.Filled = false
    b.Visible = false
    b.Transparency = 1
    b.Thickness = 1.5
    return b
end

local function IsWhitelisted(targetPlayer)
    if not ESP.UseWhitelist then return false end
    for _, name in ipairs(ESP.WhitelistedPlayers) do
        if targetPlayer.Name == name or targetPlayer.DisplayName == name then
            return true
        end
    end
    return false
end

local function IsTeamIgnored(targetPlayer)
    if not targetPlayer.Team then return false end
    for _, team in ipairs(ESP.IgnoredTeams) do
        if targetPlayer.Team.Name == team then return true end
    end
    return false
end

local function IsSameTeam(targetPlayer)
    if not LocalPlayer.Team or not targetPlayer.Team then return false end
    return LocalPlayer.Team == targetPlayer.Team
end

local function TeamColor(targetPlayer)
    return Color3.fromRGB(0, 100, 200)
end

local function ClearESPPlayer(targetPlayer)
    if ESPObjects[targetPlayer] then
        for _, obj in pairs(ESPObjects[targetPlayer]) do
            if typeof(obj) == "table" then
                for _, d in pairs(obj) do 
                    pcall(function() d:Remove() end)
                end
            else
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[targetPlayer] = nil
    end
    if ESPPlayerCache[targetPlayer] then
        ESPPlayerCache[targetPlayer] = nil
    end
end

local function SetupESPPlayer(targetPlayer)
    if targetPlayer == LocalPlayer then return end

    ESPObjects[targetPlayer] = {
        Box = NewBox(),
        Name = NewText(10,true),
        Health = NewText(12,false),
        Distance = NewText(10,true),
        Tracer = NewLine(),
        Skeleton = {
            Head = NewLine(),
            LA = NewLine(),
            RA = NewLine(),
            LL = NewLine(),
            RL = NewLine()
        }
    }

    ESPPlayerCache[targetPlayer] = {}
end

local function HideAllESP(esp)
    for _, v in pairs(esp) do
        if typeof(v) == "table" then
            for _, d in pairs(v) do d.Visible = false end
        else
            v.Visible = false
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do SetupESPPlayer(p) end
Players.PlayerAdded:Connect(SetupESPPlayer)
Players.PlayerRemoving:Connect(ClearESPPlayer)

RunService.RenderStepped:Connect(function()
    local localChar = LocalPlayer.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if localHRP then
        local localPos = localHRP.Position

        for targetPlayer, esp in pairs(ESPObjects) do
            pcall(function()
                local char = targetPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if not char or not hum or not hrp then
                    HideAllESP(esp)
                    return
                end

                if ESP.DeadCheck and hum.Health <= 0 then
                    HideAllESP(esp)
                    return
                end

                if ESP.TeamCheck and IsSameTeam(targetPlayer) then
                    HideAllESP(esp)
                    return
                end

                if IsWhitelisted(targetPlayer) then
                    HideAllESP(esp)
                    return
                end

                if IsTeamIgnored(targetPlayer) then
                    HideAllESP(esp)
                    return
                end

                local distance = (hrp.Position - localPos).Magnitude
                if distance > ESP.MaxDistance then
                    HideAllESP(esp)
                    return
                end

                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if not onScreen or pos.Z <= 0 then
                    HideAllESP(esp)
                    return
                end

                local h = math.clamp(3000 / pos.Z, 20, 300)
                local w = h / 1.5
                local color = TeamColor(targetPlayer)

                if ESP.Box then
                    esp.Box.Size = Vector2.new(w,h)
                    esp.Box.Position = Vector2.new(pos.X-w/2,pos.Y-h/2)
                    esp.Box.Color = color
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                if ESP.Name then
                    esp.Name.Text = targetPlayer.Name
                    esp.Name.Position = Vector2.new(pos.X,pos.Y-h/2-12)
                    esp.Name.Color = color
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                if ESP.Health then
                    esp.Health.Text = math.floor(hum.Health)
                    esp.Health.Position = Vector2.new(pos.X+w/2+4,pos.Y)
                    esp.Health.Color = Color3.fromRGB(0,255,0)
                    esp.Health.Visible = true
                else
                    esp.Health.Visible = false
                end

                if ESP.Distance then
                    esp.Distance.Text = string.format("[%.0f studs]", distance)
                    esp.Distance.Position = Vector2.new(pos.X, pos.Y+h/2+12)
                    esp.Distance.Color = color
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end

                if ESP.Tracer then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.Tracer.Color = color
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end

                if ESP.Skeleton and distance <= 10000 then
                    local head = char:FindFirstChild("Head")
                    local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                    local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                    local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                    local function DrawLine(line, fromPart, toPart)
                        if fromPart and toPart then
                            local p1, v1 = Camera:WorldToViewportPoint(fromPart.Position)
                            local p2, v2 = Camera:WorldToViewportPoint(toPart.Position)
                            if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
                                line.From = Vector2.new(p1.X,p1.Y)
                                line.To = Vector2.new(p2.X,p2.Y)
                                line.Color = color
                                line.Visible = true
                                return
                            end
                        end
                        line.Visible = false
                    end

                    DrawLine(esp.Skeleton.Head, head, upperTorso)
                    DrawLine(esp.Skeleton.LA, upperTorso, leftArm)
                    DrawLine(esp.Skeleton.RA, upperTorso, rightArm)
                    DrawLine(esp.Skeleton.LL, upperTorso, leftLeg)
                    DrawLine(esp.Skeleton.RL, upperTorso, rightLeg)
                else
                    for _, l in pairs(esp.Skeleton) do l.Visible = false end
                end
            end)
        end
    end
end)

VisualsTab:AddSection("ESP")

VisualsTab:AddToggle({
    Name = "ESP Box",
    Default = false,
    Callback = function(v)
        ESP.Box = v
        Window:Notify({
            Title = "ESP Box",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "ESP Nome",
    Default = false,
    Callback = function(v)
        ESP.Name = v
        Window:Notify({
            Title = "ESP Nome",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "ESP Vida",
    Default = false,
    Callback = function(v)
        ESP.Health = v
        Window:Notify({
            Title = "ESP Vida",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "ESP Distância",
    Default = false,
    Callback = function(v)
        ESP.Distance = v
        Window:Notify({
            Title = "ESP Distância",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "ESP Tracer",
    Default = false,
    Callback = function(v)
        ESP.Tracer = v
        Window:Notify({
            Title = "ESP Tracer",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "ESP Skeleton",
    Default = false,
    Callback = function(v)
        ESP.Skeleton = v
        Window:Notify({
            Title = "ESP Skeleton",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddSection("CONFIGURAÇÕES ESP")

VisualsTab:AddToggle({
    Name = "Team Check (ESP)",
    Default = true,
    Callback = function(v)
        ESP.TeamCheck = v
        Window:Notify({
            Title = "ESP Team Check",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "Dead Check (ESP)",
    Default = true,
    Callback = function(v)
        ESP.DeadCheck = v
        Window:Notify({
            Title = "ESP Dead Check",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

VisualsTab:AddToggle({
    Name = "Use Whitelist (ESP)",
    Default = false,
    Callback = function(v)
        ESP.UseWhitelist = v
        Window:Notify({
            Title = "ESP Whitelist",
            Message = v and "Ativado" or "Desativado",
            Type = v and "Success" or "Warning"
        })
    end
})

local SelectedPlayerForTP = nil

local function GetPlayerList()
    local playerList = {}
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer then
            table.insert(playerList, targetPlayer.Name)
        end
    end
    return playerList
end

PlayersTab:AddSection("SELEÇÃO DE JOGADOR")

local playerListCache = GetPlayerList()
PlayersTab:AddDropdown({
    Name = "Selecionar Jogador",
    Options = playerListCache,
    Default = playerListCache[1] or "",
    Callback = function(value)
        SelectedPlayerForTP = value
        Window:Notify({
            Title = "Jogador Selecionado",
            Message = value,
            Type = "Info"
        })
    end
})

PlayersTab:AddSection("WHITELIST ESP")

PlayersTab:AddButton({
    Name = "Adicionar à Whitelist",
    Callback = function()
        if not SelectedPlayerForTP then
            Window:Notify({
                Title = "Erro",
                Message = "Selecione um jogador primeiro",
                Type = "Error"
            })
            return
        end
        if not table.find(ESP.WhitelistedPlayers, SelectedPlayerForTP) then
            table.insert(ESP.WhitelistedPlayers, SelectedPlayerForTP)
            Window:Notify({
                Title = "Whitelist",
                Message = "Adicionado: " .. SelectedPlayerForTP,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Whitelist",
                Message = "Já está na whitelist",
                Type = "Warning"
            })
        end
    end
})

PlayersTab:AddButton({
    Name = "Remover da Whitelist",
    Callback = function()
        if not SelectedPlayerForTP then
            Window:Notify({
                Title = "Erro",
                Message = "Selecione um jogador primeiro",
                Type = "Error"
            })
            return
        end
        local index = table.find(ESP.WhitelistedPlayers, SelectedPlayerForTP)
        if index then
            table.remove(ESP.WhitelistedPlayers, index)
            Window:Notify({
                Title = "Whitelist",
                Message = "Removido: " .. SelectedPlayerForTP,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Whitelist",
                Message = "Não está na whitelist",
                Type = "Warning"
            })
        end
    end
})

PlayersTab:AddSection("AÇÕES")

PlayersTab:AddButton({
    Name = "View Player",
    Callback = function()
        if not SelectedPlayerForTP then
            Window:Notify({
                Title = "Erro",
                Message = "Selecione um jogador primeiro",
                Type = "Error"
            })
            return
        end
        local targetPlayer = Players:FindFirstChild(SelectedPlayerForTP)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
            Window:Notify({
                Title = "View Player",
                Message = "Vendo: " .. SelectedPlayerForTP,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Erro",
                Message = "Jogador não tem personagem",
                Type = "Error"
            })
        end
    end
})

PlayersTab:AddButton({
    Name = "Reset View",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
            Window:Notify({
                Title = "Reset View",
                Message = "Câmera resetada",
                Type = "Success"
            })
        end
    end
})

PlayersTab:AddButton({
    Name = "Teleportar",
    Callback = function()
        if not SelectedPlayerForTP then
            Window:Notify({
                Title = "Erro",
                Message = "Selecione um jogador primeiro",
                Type = "Error"
            })
            return
        end
        local targetPlayer = Players:FindFirstChild(SelectedPlayerForTP)
        if not targetPlayer then
            Window:Notify({
                Title = "Erro",
                Message = "Jogador não encontrado",
                Type = "Error"
            })
            return
        end
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                Window:Notify({
                    Title = "Teleporte",
                    Message = "Teleportado para " .. SelectedPlayerForTP,
                    Type = "Success"
                })
            else
                Window:Notify({
                    Title = "Erro",
                    Message = "Seu personagem não foi encontrado",
                    Type = "Error"
                })
            end
        else
            Window:Notify({
                Title = "Erro",
                Message = "Jogador não tem personagem",
                Type = "Error"
            })
        end
    end
})

ExploitsTab:AddSection("HITBOX EXPANDER")

local HitboxEnabled = false
local HitboxSize = 5
local originalHeadProps = {}

local function applyHitbox()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            pcall(function()
                local c = v.Character
                if c and c:FindFirstChild("Head") then
                    local head = c.Head
                    if not originalHeadProps[v] then
                        originalHeadProps[v] = {
                            Size = head.Size,
                            Transparency = head.Transparency,
                            BrickColor = head.BrickColor,
                            Material = head.Material,
                            CanCollide = head.CanCollide,
                            Massless = head.Massless
                        }
                    end
                    head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    head.Transparency = 0.6
                    head.BrickColor = BrickColor.new("Really red")
                    head.Material = Enum.Material.Neon
                    head.CanCollide = false
                    head.Massless = true
                end
            end)
        end
    end
end

local function restoreHitbox()
    for v, props in pairs(originalHeadProps) do
        pcall(function()
            if v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                head.Size = props.Size
                head.Transparency = props.Transparency
                head.BrickColor = props.BrickColor
                head.Material = props.Material
                head.CanCollide = props.CanCollide
                head.Massless = props.Massless
            end
        end)
    end
    originalHeadProps = {}
end

ExploitsTab:AddToggle({
    Name = "Hitbox Expander",
    Default = false,
    Callback = function(state)
        HitboxEnabled = state
        if state then applyHitbox() else restoreHitbox() end
        Window:Notify({
            Title = "Hitbox Expander",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

ExploitsTab:AddSlider({
    Name = "Tamanho da Hitbox",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(value)
        HitboxSize = value
        if HitboxEnabled then applyHitbox() end
    end
})

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if HitboxEnabled then
            task.wait(1)
            applyHitbox()
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    if HitboxEnabled then applyHitbox() end
end)

ExploitsTab:AddSection("NOCLIP")

local noclipConn
local NoclipEnabled = false

ExploitsTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            Window:Notify({
                Title = "Noclip",
                Message = "Ativado",
                Type = "Success"
            })
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Window:Notify({
                Title = "Noclip",
                Message = "Desativado",
                Type = "Warning"
            })
        end
    end
})

ExploitsTab:AddSection("FLY")

local flySpeed = 50
local flying = false
local flyKeys = { W=false, A=false, S=false, D=false, Space=false, LeftControl=false }

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    local kc = i.KeyCode and i.KeyCode.Name
    if kc and flyKeys[kc] ~= nil then flyKeys[kc] = true end
end)

UserInputService.InputEnded:Connect(function(i)
    local kc = i.KeyCode and i.KeyCode.Name
    if kc and flyKeys[kc] ~= nil then flyKeys[kc] = false end
end)

RunService.RenderStepped:Connect(function(dt)
    if flying and HRP then
        local moveDir = Vector3.new(0,0,0)
        local dir = Vector3.new(
            (flyKeys.D and 1 or 0) - (flyKeys.A and 1 or 0),
            (flyKeys.Space and 1 or 0) - (flyKeys.LeftControl and 1 or 0),
            (flyKeys.S and 1 or 0) - (flyKeys.W and 1 or 0)
        )
        if dir.Magnitude > 0 then
            moveDir = moveDir + dir.Unit
        end
        local humanoid = HRP.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local md = humanoid.MoveDirection
            moveDir = moveDir + Vector3.new(md.X, 0, md.Z)
        end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            local move = (Camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X,0,moveDir.Z)) + Vector3.new(0, moveDir.Y, 0)) * flySpeed * dt
            pcall(function() HRP.CFrame = HRP.CFrame + move end)
        end
    end
end)

ExploitsTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(s)
        flying = s
        pcall(function()
            if HRP then HRP.Anchored = s end
        end)
        Window:Notify({
            Title = "Fly",
            Message = s and "Ativado" or "Desativado",
            Type = s and "Success" or "Warning"
        })
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade do Fly",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        flySpeed = value
    end
})

ExploitsTab:AddSection("SPEED")

local speed = 40 
local walking = false

RunService.RenderStepped:Connect(function(dt)
    if walking and HRP then
        local dir = Vector3.new(
            (flyKeys.D and 1 or 0) - (flyKeys.A and 1 or 0),
            0,
            (flyKeys.S and 1 or 0) - (flyKeys.W and 1 or 0)
        )
        if dir.Magnitude > 0 then
            dir = dir.Unit
            local move = Camera.CFrame:VectorToWorldSpace(Vector3.new(dir.X,0,dir.Z)) * speed * dt
            HRP.CFrame = HRP.CFrame + Vector3.new(move.X, 0, move.Z)
        end
    end
end)

ExploitsTab:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(state)
        walking = state
        Window:Notify({
            Title = "Speed",
            Message = state and "Ativado" or "Desativado",
            Type = state and "Success" or "Warning"
        })
    end
})

ExploitsTab:AddSlider({
    Name = "Velocidade do Speed",
    Min = 10,
    Max = 200,
    Default = 40,
    Callback = function(value)
        speed = value
    end
})

MiscTab:AddSection("INFORMAÇÕES")

MiscTab:AddButton({
    Name = "Mostrar FPS",
    Callback = function()
        local fps = math.floor(Stats.Workspace.Heartbeat:GetValue())
        Window:Notify({
            Title = "FPS",
            Message = "FPS atual: " .. fps,
            Type = "Info",
            Duration = 3
        })
    end
})

MiscTab:AddButton({
    Name = "Mostrar Ping",
    Callback = function()
        local success, ping = pcall(function()
            return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if success then
            Window:Notify({
                Title = "Ping",
                Message = "Ping atual: " .. ping .. "ms",
                Type = "Info",
                Duration = 3
            })
        end
    end
})

MiscTab:AddButton({
    Name = "Copiar Nome do Jogo",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Window:Notify({
            Title = "Copiado",
            Message = "Place ID copiado: " .. game.PlaceId,
            Type = "Success"
        })
    end
})

Window:Show()

Window:Notify({
    Title = "Quantom.gg",
    Message = "Bypass Adonis ativo!",
    Type = "Success",
    Duration = 4
})
