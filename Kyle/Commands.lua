local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local ActiveStates = {FlySpeed = 50, IsFlying = false, FlyBody = nil, FlyGyro = nil, EspInstances = {}}

local function setclipboard(text)
    if setclipboard then setclipboard(text) end
end

Commands["Speed"] = {Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed"}
Commands["ResetSpeed"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed"}
Commands["Jumppower"] = {Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power"}
Commands["ResetJumpPower"] = {Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end, Description = "Reset jump power"}
Commands["Infjump"] = {Action = function() ActiveStates.Infjump = true; UserInputService.JumpRequest:Connect(function() if ActiveStates.Infjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end) end, Description = "Enable infinite jump"}
Commands["unInfjump"] = {Action = function() ActiveStates.Infjump = false end, Description = "Disable infinite jump"}
Commands["Noclip"] = {Action = function() ActiveStates.Noclip = true; RunService.Stepped:Connect(function() if ActiveStates.Noclip and LocalPlayer.Character then for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end, Description = "Enable Noclip"}
Commands["Clip"] = {Action = function() ActiveStates.Noclip = false end, Description = "Disable Noclip"}
Commands["Freeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze character"}
Commands["unFreeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = false end, Description = "Unfreeze character"}
Commands["Fullbright"] = {Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Enable Fullbright"}
Commands["Night"] = {Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set night"}
Commands["Day"] = {Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set day"}
Commands["Sit"] = {Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Force sit"}
Commands["Nofog"] = {Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog"}
Commands["Time"] = {Action = function(t) Lighting.TimeOfDay = t end, Description = "Set time"}
Commands["Localtime"] = {Action = function() local time = os.date("%I:%M %p"); game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Local Time", Text = time}) end, Description = "Show local time"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Exit game"}
Commands["Kick"] = {Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick self"}
Commands["Jump"] = {Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump"}
Commands["ClickTp"] = {Action = function() ActiveStates.ClickTp = not ActiveStates.ClickTp; local Mouse = LocalPlayer:GetMouse(); UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and ActiveStates.ClickTp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then if Mouse.Hit then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end end end) end, Description = "Toggle ClickTp"}
Commands["Jobid"] = {Action = function() setclipboard(game.JobId) end, Description = "Copy JobId"}
Commands["JoinJobid"] = {Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end, Description = "Join JobId"}
Commands["CopyName"] = {Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName"}
Commands["CopyUsername"] = {Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Username"}
Commands["CopyPlaceId"] = {Action = function() setclipboard(tostring(game.PlaceId)) end, Description = "Copy PlaceId"}
Commands["CopyGameName"] = {Action = function() setclipboard(MarketplaceService:GetProductInfo(game.PlaceId).Name) end, Description = "Copy GameName"}
Commands["Rejoin"] = {Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server"}
Commands["FpsBoost"] = {Action = function() local Terrain = workspace:FindFirstChildOfClass("Terrain"); Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectivity = 0; Terrain.WaterTransparency = 0; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end, Description = "Optimize FPS"}
Commands["Invisible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end, Description = "Make character invisible"}
Commands["Visible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end, Description = "Make character visible"}
Commands["Goto"] = {Action = function(name) local target = Players:FindFirstChild(name); if target and target.Character then LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position) end end, Description = "Teleport to player"}

-- New Advanced Commands
Commands["Btools"] = {Action = function() for _, tool in ipairs({"Clone", "Destroy", "Grab"}) do local btool = Instance.new("HopperBin"); btool.BinType = Enum.BinType[tool]; btool.Parent = LocalPlayer.Backpack end end, Description = "Get building tools"}
Commands["AntiAfk"] = {Action = function() LocalPlayer.Idled:Connect(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end, Description = "Prevent idle kick"}
Commands["Esp"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(0, 255, 255); hl.Parent = p.Character; table.insert(ActiveStates.EspInstances, hl) end end end, Description = "Highlight players"}
Commands["UnEsp"] = {Action = function() for _,hl in pairs(ActiveStates.EspInstances) do hl:Destroy() end; ActiveStates.EspInstances = {} end, Description = "Remove highlights"}
Commands["Fling"] = {Action = function() ActiveStates.Fling = not ActiveStates.Fling; local bg = Instance.new("BodyAngularVelocity"); if ActiveStates.Fling then bg.Name = "FlingVelocity"; bg.AngularVelocity = Vector3.new(0, 99999, 0); bg.MaxTorque = Vector3.new(0, math.huge, 0); bg.Parent = LocalPlayer.Character.HumanoidRootPart else if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlingVelocity") then LocalPlayer.Character.HumanoidRootPart.FlingVelocity:Destroy() end end end, Description = "Toggle fling mode"}
Commands["Spectate"] = {Action = function(name) local target = Players:FindFirstChild(name); if target and target.Character then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end end, Description = "Spectate player"}
Commands["Unspectate"] = {Action = function() workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end, Description = "Stop spectating"}
Commands["ServerHop"] = {Action = function() local HttpService = game:GetService("HttpService"); local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data; for _, server in pairs(servers) do if server.playing < server.maxPlayers and server.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer); break end end end, Description = "Join different server"}
Commands["Xray"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then v.LocalTransparencyModifier = 0.5 end end end, Description = "Make map transparent"}
Commands["FlySpeed"] = {Action = function(v) ActiveStates.FlySpeed = tonumber(v) or 50 end, Description = "Set fly speed"}

-- Advanced Fly System
Commands["Fly"] = {
    Action = function()
        ActiveStates.IsFlying = not ActiveStates.IsFlying
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        
        if ActiveStates.IsFlying then
            char.Humanoid.PlatformStand = true
            ActiveStates.FlyBody = Instance.new("BodyVelocity")
            ActiveStates.FlyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            ActiveStates.FlyBody.Velocity = Vector3.zero
            ActiveStates.FlyBody.Parent = hrp
            
            ActiveStates.FlyGyro = Instance.new("BodyGyro")
            ActiveStates.FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            ActiveStates.FlyGyro.P = 10000
            ActiveStates.FlyGyro.CFrame = hrp.CFrame
            ActiveStates.FlyGyro.Parent = hrp
            
            ActiveStates.FlyLoop = RunService.RenderStepped:Connect(function()
                if not ActiveStates.IsFlying then return end
                local cam = workspace.CurrentCamera
                local moveDir = char.Humanoid.MoveDirection
                ActiveStates.FlyGyro.CFrame = cam.CFrame
                if moveDir.Magnitude > 0 then
                    ActiveStates.FlyBody.Velocity = cam.CFrame:VectorToWorldSpace(moveDir) * ActiveStates.FlySpeed
                else
                    ActiveStates.FlyBody.Velocity = Vector3.zero
                end
            end)
        else
            char.Humanoid.PlatformStand = false
            if ActiveStates.FlyBody then ActiveStates.FlyBody:Destroy() end
            if ActiveStates.FlyGyro then ActiveStates.FlyGyro:Destroy() end
            if ActiveStates.FlyLoop then ActiveStates.FlyLoop:Disconnect() end
        end
    end,
    Description = "Toggle Fly"
}

-- Platform Detection & UI Setup
local function SetupFlyDetector()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        local guiParent = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "SlowXHub_MobileFly"
        sg.ResetOnSpawn = false
        sg.Parent = guiParent
        
        local flyBtn = Instance.new("TextButton")
        flyBtn.Size = UDim2.new(0, 70, 0, 70)
        flyBtn.Position = UDim2.new(1, -90, 0.5, -35)
        flyBtn.BackgroundColor3 = Color3.new(0, 0, 0)
        flyBtn.BackgroundTransparency = 0.4
        flyBtn.Text = "Fly"
        flyBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        flyBtn.Font = Enum.Font.GothamBold
        flyBtn.TextSize = 18
        flyBtn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.3, 0)
        corner.Parent = flyBtn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 255, 255)
        stroke.Thickness = 2
        stroke.Parent = flyBtn
        
        flyBtn.MouseButton1Click:Connect(function()
            Commands["Fly"].Action()
            if ActiveStates.IsFlying then
                flyBtn.Text = "Unfly"
                flyBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
                stroke.Color = Color3.fromRGB(255, 50, 50)
            else
                flyBtn.Text = "Fly"
                flyBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
                stroke.Color = Color3.fromRGB(0, 255, 255)
            end
        end)
    else
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.F then
                Commands["Fly"].Action()
            end
        end)
    end
end

SetupFlyDetector()

return Commands
