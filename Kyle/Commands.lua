local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local ActiveStates = {}

local function setclipboard(text) if setclipboard then setclipboard(text) end end

-- ==========================================
-- دوال مساعدة (Helper Functions)
-- ==========================================
local function ResolveTarget(name)
    if not name or name == "" then return {LocalPlayer} end
    local nameLower = string.lower(name)
    if nameLower == "me" then return {LocalPlayer} end
    if nameLower == "all" then return Players:GetPlayers() end
    if nameLower == "others" then
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(others, p) end end
        return others
    end
    
    local found = {}
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #nameLower) == nameLower or string.sub(string.lower(p.DisplayName), 1, #nameLower) == nameLower then
            table.insert(found, p)
        end
    end
    return found
end

local function GetClosestPlayer()
    local closest, minDistance = nil, math.huge
    local lpPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not lpPos then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - lpPos).Magnitude
            if dist < minDistance then minDistance = dist; closest = p end
        end
    end
    return closest
end

local function CreateESP(part, color, name)
    if not part or part:FindFirstChild(name) then return end
    local h = Instance.new("Highlight", part)
    h.Name = name; h.FillColor = color; h.OutlineColor = color
end

local function RemoveESP(name)
    for _,v in pairs(Workspace:GetDescendants()) do
        if v.Name == name and v:IsA("Highlight") then v:Destroy() end
    end
end

-- ==========================================
-- الأوامر الجديدة (الأساسية)
-- ==========================================

Commands["ClickTp"] = { Action = function()
    ActiveStates.ClickTp = true
    local Mouse = LocalPlayer:GetMouse()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if ActiveStates.ClickTp and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Mouse.Hit and LocalPlayer.Character then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end
        end
    end)
end, Description = "Click to teleport" }

Commands["unClickTp"] = { Action = function() ActiveStates.ClickTp = false end, Description = "Disable ClickTp" }

Commands["TpWalk"] = { Args = "Speed", Action = function(v)
    local speed = tonumber(v) or 5
    ActiveStates.TpWalk = true
    RunService.RenderStepped:Connect(function()
        if ActiveStates.TpWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local dir = LocalPlayer.Character.Humanoid.MoveDirection
            if dir.Magnitude > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (dir * (speed / 10))
            end
        end
    end)
end, Description = "Teleport walk (Anti-Cheat bypass)" }

Commands["unTpWalk"] = { Action = function() ActiveStates.TpWalk = false end, Description = "Disable TpWalk" }

Commands["ab"] = { Args = "Command", Action = function(cmd)
    if not Commands[cmd] then return end
    local SG = Instance.new("ScreenGui", CoreGui)
    SG.Name = "KyleBtn_" .. cmd
    local Btn = Instance.new("TextButton", SG)
    Btn.Size = UDim2.new(0, 100, 0, 40); Btn.Position = UDim2.new(0, 50, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold; Btn.Text = cmd; Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local dragToggle, dragInput, dragStart, startPos
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStart = input.Position; startPos = Btn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end)
    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    Btn.MouseButton1Click:Connect(function() pcall(function() Commands[cmd].Action() end) end)
end, Description = "Add draggable Quick Run button" }

Commands["AudioLogger"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XtraYsf/AudioLogger/refs/heads/main/v1"))() end, Description = "Run AudioLogger" }

Commands["RunAudio"] = { Args = "ID", Action = function(id)
    local snd = Instance.new("Sound", Workspace)
    snd.SoundId = "rbxassetid://" .. tostring(id); snd.Volume = 1; snd:Play()
end, Description = "Play specific audio ID" }

Commands["Morph"] = { Args = "Username", Action = function(name)
    pcall(function()
        local UserId = Players:GetUserIdFromNameAsync(name)
        local desc = Players:GetHumanoidDescriptionFromUserId(UserId)
        LocalPlayer.Character.Humanoid:ApplyDescription(desc)
    end)
end, Description = "Morph to another player" }

Commands["Actnpc"] = { Action = function()
    ActiveStates.ActNpc = true
    task.spawn(function()
        while ActiveStates.ActNpc and LocalPlayer.Character do
            local rp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rp then
                local randomPos = rp.Position + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
                LocalPlayer.Character.Humanoid:MoveTo(randomPos)
            end
            task.wait(math.random(3, 6))
        end
    end)
end, Description = "Walk randomly like an NPC" }

Commands["unActnpc"] = { Action = function() ActiveStates.ActNpc = false end, Description = "Stop NPC walk" }

Commands["loopBring"] = { Args = "Player", Action = function(name)
    local target = ResolveTarget(name)[1]
    ActiveStates.LoopBring = target
    task.spawn(function()
        while ActiveStates.LoopBring == target and target.Character and LocalPlayer.Character do
            target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            task.wait(0.1)
        end
    end)
end, Description = "Continuously bring player" }

Commands["unLoopBring"] = { Action = function() ActiveStates.LoopBring = nil end, Description = "Stop loop bring" }

Commands["TpWall"] = { Action = function()
    ActiveStates.TpWall = true
    RunService.Heartbeat:Connect(function()
        if ActiveStates.TpWall and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rp = LocalPlayer.Character.HumanoidRootPart
            local dir = LocalPlayer.Character.Humanoid.MoveDirection
            if dir.Magnitude > 0 then
                local ray = Ray.new(rp.Position, dir * 3)
                local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hit and hit.CanCollide then
                    rp.CFrame = rp.CFrame + (dir * (hit.Size.Magnitude / 2 + 3))
                end
            end
        end
    end)
end, Description = "Teleport through walls" }

-- ==========================================
-- أنظمة السيارة و السبايدرمان
-- ==========================================

Commands["Car"] = { Action = function()
    if CoreGui:FindFirstChild("KyleCarUI") then CoreGui.KyleCarUI:Destroy() end
    local SG = Instance.new("ScreenGui", CoreGui); SG.Name = "KyleCarUI"
    LocalPlayer.Character.Humanoid.Sit = true

    local Wheel = Instance.new("ImageLabel", SG)
    Wheel.Size = UDim2.new(0, 150, 0, 150); Wheel.Position = UDim2.new(0, 20, 1, -170)
    Wheel.Image = "rbxassetid://102882845879311"; Wheel.BackgroundTransparency = 1
    
    local GasBtn = Instance.new("TextButton", SG)
    GasBtn.Size = UDim2.new(0, 60, 0, 100); GasBtn.Position = UDim2.new(1, -90, 1, -120)
    GasBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); GasBtn.Text = "GAS"
    GasBtn.Font = Enum.Font.GothamBold; GasBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", GasBtn).CornerRadius = UDim.new(0, 8)

    local BrakeBtn = Instance.new("TextButton", SG)
    BrakeBtn.Size = UDim2.new(0, 80, 0, 60); BrakeBtn.Position = UDim2.new(1, -180, 1, -80)
    BrakeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); BrakeBtn.Text = "BRAKE"
    BrakeBtn.Font = Enum.Font.GothamBold; BrakeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", BrakeBtn).CornerRadius = UDim.new(0, 8)

    ActiveStates.CarDriving = true
    local speed = 0
    RunService.RenderStepped:Connect(function()
        if not ActiveStates.CarDriving then return end
        local rot = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then rot = -45 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then rot = 45 end
        
        TweenService:Create(Wheel, TweenInfo.new(0.2), {Rotation = rot}):Play()
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rp = LocalPlayer.Character.HumanoidRootPart
            if rot ~= 0 then rp.CFrame = rp.CFrame * CFrame.Angles(0, math.rad(-rot / 10), 0) end
            rp.CFrame = rp.CFrame + (rp.CFrame.LookVector * (speed / 10))
        end
    end)

    GasBtn.MouseButton1Down:Connect(function() speed = 30 end)
    GasBtn.MouseButton1Up:Connect(function() speed = 0 end)
    BrakeBtn.MouseButton1Down:Connect(function() speed = -10 end)
    BrakeBtn.MouseButton1Up:Connect(function() speed = 0 end)
end, Description = "Drive a virtual car" }

Commands["unCar"] = { Action = function()
    ActiveStates.CarDriving = false
    if CoreGui:FindFirstChild("KyleCarUI") then CoreGui.KyleCarUI:Destroy() end
    LocalPlayer.Character.Humanoid.Sit = false
    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end, Description = "Stop driving" }

Commands["Spider"] = { Action = function()
    ActiveStates.Spider = true
    RunService.RenderStepped:Connect(function()
        if not ActiveStates.Spider or not LocalPlayer.Character then return end
        local rp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not rp then return end
        local ray = Ray.new(rp.Position, rp.CFrame.LookVector * 5)
        local hit, pos, normal = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
        if hit then
            local right = rp.CFrame.RightVector
            local up = normal
            local forward = right:Cross(up)
            rp.CFrame = CFrame.fromMatrix(rp.Position, right, up, -forward)
        end
    end)
end, Description = "Walk on walls" }

Commands["unSpider"] = { Action = function() ActiveStates.Spider = false end, Description = "Disable Spider" }

-- ==========================================
-- الأدوات والحماية من AFK
-- ==========================================

Commands["AntiAfk"] = { Action = function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Anti-AFK", Text="Enabled"})
end, Description = "Prevent disconnect (Anti-idle)" }

Commands["EquipTools"] = { Action = function()
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = LocalPlayer.Character end end
end, Description = "Equip all tools instantly" }

Commands["DropTools"] = { Action = function()
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = LocalPlayer.Character end end
    task.wait(0.2)
    for _, t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then t.Parent = Workspace end end
end, Description = "Drop all tools" }

Commands["Drop"] = { Action = function()
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then tool.Parent = Workspace end
end, Description = "Drop equipped tool" }

-- ==========================================
-- نظام EspInventory الاحترافي
-- ==========================================

Commands["EspInventory"] = { Action = function()
    ActiveStates.EspInv = true
    RunService.Heartbeat:Connect(function()
        if not ActiveStates.EspInv then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local rp = p.Character.HumanoidRootPart
                if not rp:FindFirstChild("KyleInvPrompt") then
                    local prompt = Instance.new("ProximityPrompt", rp)
                    prompt.Name = "KyleInvPrompt"; prompt.ActionText = "Check"; prompt.HoldDuration = 3
                    prompt.Triggered:Connect(function()
                        if CoreGui:FindFirstChild("KyleInvUI") then CoreGui.KyleInvUI:Destroy() end
                        local SG = Instance.new("ScreenGui", CoreGui); SG.Name = "KyleInvUI"
                        
                        local Main = Instance.new("Frame", SG)
                        Main.Size = UDim2.new(0, 250, 0, 300); Main.Position = UDim2.new(0.5, -125, 0.5, -150)
                        Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
                        
                        local Title = Instance.new("TextLabel", Main)
                        Title.Size = UDim2.new(1, -40, 0, 30); Title.BackgroundTransparency = 1
                        Title.Text = p.Name .. "'s Tools"; Title.TextColor3 = Color3.fromRGB(255, 140, 0)
                        Title.Font = Enum.Font.GothamBold; Title.TextSize = 14
                        
                        local Close = Instance.new("TextButton", Main)
                        Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -30, 0, 0)
                        Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50); Close.Text = "X"
                        Close.TextColor3 = Color3.new(1,1,1); Close.Font = Enum.Font.GothamBold
                        Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
                        Close.MouseButton1Click:Connect(function() SG:Destroy() end)
                        
                        local Scroll = Instance.new("ScrollingFrame", Main)
                        Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35)
                        Scroll.BackgroundTransparency = 1; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        local UIList = Instance.new("UIListLayout", Scroll); UIList.Padding = UDim.new(0, 5)
                        
                        local tools = {}
                        for _,t in pairs(p.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
                        for _,t in pairs(p.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
                        
                        for _, t in pairs(tools) do
                            local Item = Instance.new("TextLabel", Scroll)
                            Item.Size = UDim2.new(1, -10, 0, 30); Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                            Item.Text = " 🎒 " .. t.Name; Item.TextColor3 = Color3.new(1,1,1)
                            Item.Font = Enum.Font.Gotham; Item.TextXAlignment = Enum.TextXAlignment.Left
                            Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
                        end
                    end)
                end
            end
        end
    end)
end, Description = "Show ProximityPrompt to view player tools" }

-- ==========================================
-- 10 أوامر Exploits قوية
-- ==========================================
Commands["Fly"] = { Action = function()
    local rp = LocalPlayer.Character.HumanoidRootPart
    local bp = Instance.new("BodyPosition", rp); bp.Name = "KyleFlyBP"; bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    local bg = Instance.new("BodyGyro", rp); bg.Name = "KyleFlyBG"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    ActiveStates.Fly = true
    RunService.RenderStepped:Connect(function()
        if ActiveStates.Fly and LocalPlayer.Character then
            local cam = Workspace.CurrentCamera.CFrame
            bg.CFrame = cam
            bp.Position = rp.Position + (LocalPlayer.Character.Humanoid.MoveDirection * 2)
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then bp.Position = bp.Position + Vector3.new(0, 2, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then bp.Position = bp.Position - Vector3.new(0, 2, 0) end
        end
    end)
end, Description = "Enable Flight" }

Commands["unFly"] = { Action = function()
    ActiveStates.Fly = false
    local rp = LocalPlayer.Character.HumanoidRootPart
    if rp:FindFirstChild("KyleFlyBP") then rp.KyleFlyBP:Destroy() end
    if rp:FindFirstChild("KyleFlyBG") then rp.KyleFlyBG:Destroy() end
end, Description = "Disable Flight" }

Commands["Hitbox"] = { Args = "Size", Action = function(size)
    local s = tonumber(size) or 20
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = Vector3.new(s, s, s)
            p.Character.HumanoidRootPart.Transparency = 0.5
            p.Character.HumanoidRootPart.CanCollide = false
        end
    end
end, Description = "Expand all players hitboxes" }

Commands["Fling"] = { Action = function()
    local rp = LocalPlayer.Character.HumanoidRootPart
    local spin = Instance.new("BodyAngularVelocity", rp)
    spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    spin.AngularVelocity = Vector3.new(0, 50000, 0)
    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
end, Description = "Spin fast to fling players" }

Commands["Aimbot"] = { Action = function()
    ActiveStates.Aimbot = true
    RunService.RenderStepped:Connect(function()
        if ActiveStates.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestPlayer()
            if target and target.Character then
                Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end)
end, Description = "Hold Right Click to Aimbot" }

Commands["ClickDelete"] = { Action = function()
    ActiveStates.ClickDel = true
    local Mouse = LocalPlayer:GetMouse()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and ActiveStates.ClickDel and input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Target then
            Mouse.Target:Destroy()
        end
    end)
end, Description = "Click any part to destroy it" }

Commands["AntiVoid"] = { Action = function()
    local part = Instance.new("Part", Workspace)
    part.Size = Vector3.new(5000, 5, 5000); part.Position = Vector3.new(0, Workspace.FallenPartsDestroyHeight + 10, 0)
    part.Anchored = true; part.Transparency = 0.5; part.Color = Color3.fromRGB(255, 0, 0)
end, Description = "Creates floor above void" }

Commands["ServerHop"] = { Action = function()
    local HttpService = game:GetService("HttpService")
    local req = request({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
    local servers = HttpService:JSONDecode(req.Body).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) break end
    end
end, Description = "Join a different server" }

Commands["BypassGuis"] = { Action = function()
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("ScreenGui") then gui.Enabled = true end
        if gui:IsA("Frame") or gui:IsA("TextLabel") or gui:IsA("TextButton") then gui.Visible = true end
    end
end, Description = "Force enable hidden UI" }

Commands["Xray"] = { Action = function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0.5
        end
    end
end, Description = "Make map semi-transparent" }

-- ==========================================
-- واجهة الأوامر المعدلة Cmds
-- ==========================================
Commands["Cmds"] = {
    Action = function()
        if CoreGui:FindFirstChild("KyleCmdsUI") then CoreGui.KyleCmdsUI:Destroy() end
        local SG = Instance.new("ScreenGui", CoreGui); SG.Name = "KyleCmdsUI"

        local Main = Instance.new("Frame", SG)
        Main.Size = UDim2.new(0, 400, 0, 0); Main.Position = UDim2.new(0.5, -200, 0.5, -175)
        Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.ClipsDescendants = true
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 350)}):Play()

        local Topbar = Instance.new("Frame", Main)
        Topbar.Size = UDim2.new(1, 0, 0, 40); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 8)
        
        local Title = Instance.new("TextLabel", Topbar)
        Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1; Title.Text = "Kyle [ Admin Commands ]"
        Title.TextColor3 = Color3.fromRGB(255, 140, 0); Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

        local CloseBtn = Instance.new("TextButton", Topbar)
        CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

        local MinBtn = Instance.new("TextButton", Topbar)
        MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5)
        MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 14
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

        local SearchBox = Instance.new("TextBox", Main)
        SearchBox.Size = UDim2.new(0.55, 0, 0, 30); SearchBox.Position = UDim2.new(0, 10, 0, 50)
        SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SearchBox.TextColor3 = Color3.new(1,1,1)
        SearchBox.PlaceholderText = "Search Command..."
        SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 13
        Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

        local cmdTotal = 0 for _ in pairs(Commands) do cmdTotal = cmdTotal + 1 end
        local CountLbl = Instance.new("TextLabel", Main)
        CountLbl.Size = UDim2.new(0.4, -20, 0, 30); CountLbl.Position = UDim2.new(0.6, 10, 0, 50)
        CountLbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CountLbl.TextColor3 = Color3.fromRGB(255, 140, 0)
        CountLbl.Text = "Commands: " .. cmdTotal; CountLbl.Font = Enum.Font.GothamBold; CountLbl.TextSize = 13
        Instance.new("UICorner", CountLbl).CornerRadius = UDim.new(0, 6)

        local Scroll = Instance.new("ScrollingFrame", Main)
        Scroll.Size = UDim2.new(1, -20, 1, -100); Scroll.Position = UDim2.new(0, 10, 0, 90)
        Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 4
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local UIList = Instance.new("UIListLayout", Scroll)
        UIList.Padding = UDim.new(0, 5); UIList.SortOrder = Enum.SortOrder.Name

        local isMinimized, OriginalSize = false, UDim2.new(0, 400, 0, 350)
        
        CloseBtn.MouseButton1Click:Connect(function()
            local tw = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            tw:Play(); tw.Completed:Wait(); SG:Destroy()
        end)

        MinBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            if isMinimized then
                TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 40)}):Play()
                Title.Text = "Cmds"; Scroll.Visible = false; SearchBox.Visible = false; CountLbl.Visible = false
            else
                TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = OriginalSize}):Play()
                Title.Text = "Kyle [ Admin Commands ]"; Scroll.Visible = true; SearchBox.Visible = true; CountLbl.Visible = true
            end
        end)

        local function Populate(filter)
            for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for cmdName, cmdData in pairs(Commands) do
                if not filter or string.find(string.lower(cmdName), string.lower(filter)) then
                    local Item = Instance.new("Frame", Scroll)
                    Item.Name = cmdName; Item.Size = UDim2.new(1, -10, 0, 40)
                    Item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)

                    local Lbl = Instance.new("TextLabel", Item)
                    Lbl.Size = UDim2.new(0.4, 0, 1, 0); Lbl.Position = UDim2.new(0, 10, 0, 0)
                    Lbl.BackgroundTransparency = 1; Lbl.Text = cmdName
                    Lbl.TextColor3 = Color3.new(1,1,1); Lbl.Font = Enum.Font.GothamSemibold
                    Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left

                    local RunBtn = Instance.new("TextButton", Item)
                    RunBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
                    RunBtn.Text = "Run"; RunBtn.TextColor3 = Color3.new(1,1,1)
                    RunBtn.Font = Enum.Font.GothamBold; RunBtn.TextSize = 12
                    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 4)

                    -- التحقق المنطقي: إذا كان الأمر يحتوي على مدخلات Args، نظهر الـ TextBox
                    if cmdData.Args then
                        RunBtn.Size = UDim2.new(0, 60, 0, 30); RunBtn.Position = UDim2.new(1, -70, 0, 5)
                        local ArgBox = Instance.new("TextBox", Item)
                        ArgBox.Size = UDim2.new(0, 90, 0, 30); ArgBox.Position = UDim2.new(1, -170, 0, 5)
                        ArgBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); ArgBox.TextColor3 = Color3.new(1,1,1)
                        ArgBox.PlaceholderText = cmdData.Args -- يظهر نوع الإدخال (Player, Value, ID)
                        ArgBox.Font = Enum.Font.Gotham; ArgBox.TextSize = 12
                        Instance.new("UICorner", ArgBox).CornerRadius = UDim.new(0, 4)

                        RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action(ArgBox.Text) end) end)
                    else
                        -- إذا كان الأمر لا يحتاج مدخلات، نلغي الـ TextBox تماماً
                        RunBtn.Size = UDim2.new(0, 100, 0, 30); RunBtn.Position = UDim2.new(1, -110, 0, 5)
                        RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action() end) end)
                    end
                end
            end
        end

        Populate()
        SearchBox.Changed:Connect(function(prop) if prop == "Text" then Populate(SearchBox.Text) end end)
    end,
    Description = "Open Commands UI"
}

return Commands