local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local ActiveStates = {FlySpeed = 50, IsFlying = false, FlyBody = nil, FlyGyro = nil, EspInstances = {}, SavedPos = nil}

local function setclipboard(text) if setclipboard then setclipboard(text) end end
local function Notify(title, text) game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text}) end

local function SetupJumpMod(stateName)
    return function()
        ActiveStates[stateName] = true
        local lastJump = 0
        if ActiveStates[stateName.."Conn"] then ActiveStates[stateName.."Conn"]:Disconnect() end
        ActiveStates[stateName.."Conn"] = UserInputService.JumpRequest:Connect(function()
            if ActiveStates[stateName] and tick() - lastJump >= 0.2 then
                lastJump = tick()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end
        end)
    end
end

-- [ Movement & Character Commands ] --
Commands["Speed"] = {Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed"}
Commands["ResetSpeed"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed"}
Commands["Jumppower"] = {Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power"}
Commands["Unfly"] = {Action = function() ActiveStates.IsFlying = false; LocalPlayer.Character.Humanoid.PlatformStand = false; if ActiveStates.FlyBody then ActiveStates.FlyBody:Destroy() end; if ActiveStates.FlyGyro then ActiveStates.FlyGyro:Destroy() end; if ActiveStates.FlyLoop then ActiveStates.FlyLoop:Disconnect() end end, Description = "Disable fly"}
Commands["Unrun"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed to normal"}
Commands["Blur"] = {Action = function() Instance.new("BlurEffect", game.Lighting).Name = "SXH_Blur" end, Description = "Add screen blur"}
Commands["ResetJumpPower"] = {Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end, Description = "Reset jump power"}
Commands["Infjump"] = {Action = SetupJumpMod("Infjump"), Description = "Enable infinite jump"}
Commands["unInfjump"] = {Action = function() ActiveStates.Infjump = false end, Description = "Disable infinite jump"}
Commands["Flyjump"] = {Action = SetupJumpMod("Flyjump"), Description = "Enable fly jump"}
Commands["unFlyjump"] = {Action = function() ActiveStates.Flyjump = false end, Description = "Disable fly jump"}
Commands["Noclip"] = {Action = function() ActiveStates.Noclip = true; RunService.Stepped:Connect(function() if ActiveStates.Noclip and LocalPlayer.Character then for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end, Description = "Enable Noclip"}
Commands["Clip"] = {Action = function() ActiveStates.Noclip = false end, Description = "Disable Noclip"}
Commands["FlySpeed"] = {Action = function(v) ActiveStates.FlySpeed = tonumber(v) or 50 end, Description = "Set fly speed"}
Commands["Freeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze character"}
Commands["ThirdPerson"] = {Action = function() LocalPlayer.CameraMaxZoomDistance = 100; LocalPlayer.CameraMinZoomDistance = 10 end, Description = "Third person mode"}
Commands["FirstPerson"] = {Action = function() LocalPlayer.CameraMaxZoomDistance = 0.5; LocalPlayer.CameraMinZoomDistance = 0.5 end, Description = "First person mode"}
Commands["HideUI"] = {Action = function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end, Description = "Hide core UI"}
Commands["ShowUI"] = {Action = function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end, Description = "Show core UI"}
Commands["DropTools"] = {Action = function() for _,t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then t.Parent = workspace end end end, Description = "Drop tools"}
Commands["ClearTools"] = {Action = function() LocalPlayer.Backpack:ClearAllChildren() end, Description = "Delete tools"}
Commands["EquipAll"] = {Action = function() for _,t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = LocalPlayer.Character end end end, Description = "Equip all"}
Commands["Print"] = {Action = function(v) print(v or "Slow X Executed") end, Description = "Print message"}
Commands["Warn"] = {Action = function(v) warn(v or "Warning!") end, Description = "Warn message"}
Commands["Error"] = {Action = function(v) error(v or "Error!") end, Description = "Error message"}
Commands["ClearConsole"] = {Action = function() print(string.rep("\n", 200)) end, Description = "Clear console"}
Commands["Chat"] = {Action = function(v) game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v or "Slow X Hub!", "All") end, Description = "Chat message"}
Commands["Spam"] = {Action = function(v) ActiveStates.Spam = true; task.spawn(function() while ActiveStates.Spam do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v or "Spam!", "All"); task.wait(0.5) end end) end, Description = "Spam chat"}
Commands["unSpam"] = {Action = function() ActiveStates.Spam = false end, Description = "Stop spam"}
Commands["Re"] = {Action = function() LocalPlayer.Character:BreakJoints() end, Description = "Reset character"}
Commands["Respawn"] = {Action = function() LocalPlayer.Character:Destroy() end, Description = "Respawn character"}
Commands["HatSpin"] = {Action = function() for _,h in pairs(LocalPlayer.Character:GetChildren()) do if h:IsA("Accessory") then h.Handle.AssemblyLinearVelocity = Vector3.new(0, 100, 0) end end end, Description = "Spin hats"}
Commands["AntiRagdoll"] = {Action = function() LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end, Description = "Anti ragdoll"}
Commands["unFreeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = false end, Description = "Unfreeze character"}
Commands["Sit"] = {Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Force sit"}
Commands["Jump"] = {Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump"}
Commands["Invisible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end end end, Description = "Make character invisible"}
Commands["Visible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end, Description = "Make character visible"}
Commands["Walk"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Normal walk"}
Commands["Run"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 50 end, Description = "Fast run"}
Commands["StopAnim"] = {Action = function() for _,t in pairs(LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do t:Stop() end end, Description = "Stop all animations"}
Commands["NoFall"] = {Action = function() local h = LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end end, Description = "Prevent fall state"}
Commands["Spin"] = {Action = function() ActiveStates.Spin = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); ActiveStates.Spin.AngularVelocity = Vector3.new(0, 50, 0); ActiveStates.Spin.MaxTorque = Vector3.new(0, math.huge, 0) end, Description = "Spin character"}
Commands["unSpin"] = {Action = function() if ActiveStates.Spin then ActiveStates.Spin:Destroy() end end, Description = "Stop spinning"}
Commands["Float"] = {Action = function() ActiveStates.Float = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart); ActiveStates.Float.Velocity = Vector3.zero; ActiveStates.Float.MaxForce = Vector3.new(0, math.huge, 0) end, Description = "Float in air"}
Commands["unFloat"] = {Action = function() if ActiveStates.Float then ActiveStates.Float:Destroy() end end, Description = "Stop floating"}
Commands["GodMode"] = {Action = function() local cam = workspace.CurrentCamera; local char = LocalPlayer.Character; char.Humanoid.Health = char.Humanoid.MaxHealth; cam.CameraSubject = char.Humanoid end, Description = "Fake GodMode"}
Commands["Headless"] = {Action = function() local h = LocalPlayer.Character:FindFirstChild("Head"); if h then h:Destroy() end end, Description = "Client headless"}
Commands["Korblox"] = {Action = function() local l = LocalPlayer.Character:FindFirstChild("RightLowerLeg"); if l then l:Destroy() end end, Description = "Client korblox"}
Commands["CC"] = {Action = function() local c = 0; for _ in pairs(Commands) do c = c + 1 end; game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Command Count", Text = "There are " .. c .. " commands currently available."}) end, Description = "Shows the total number of commands in English"}

-- [ World & Lighting Commands ] --
Commands["Fullbright"] = {Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Enable Fullbright"}
Commands["Night"] = {Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set night"}
Commands["Day"] = {Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set day"}
Commands["Nofog"] = {Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog"}
Commands["Time"] = {Action = function(t) Lighting.TimeOfDay = tostring(t) or "14:00:00" end, Description = "Set specific time"}
Commands["RemoveShadows"] = {Action = function() Lighting.GlobalShadows = false end, Description = "Disable shadows"}
Commands["RestoreShadows"] = {Action = function() Lighting.GlobalShadows = true end, Description = "Enable shadows"}
Commands["Blur"] = {Action = function() Instance.new("BlurEffect", Lighting).Name = "SXH_Blur" end, Description = "Add screen blur"}
Commands["unBlur"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "SXH_Blur" then v:Destroy() end end end, Description = "Remove blur"}
Commands["Bloom"] = {Action = function() Instance.new("BloomEffect", Lighting).Name = "SXH_Bloom" end, Description = "Add bloom effect"}
Commands["unBloom"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "SXH_Bloom" then v:Destroy() end end end, Description = "Remove bloom effect"}
Commands["ColorCorrection"] = {Action = function() Instance.new("ColorCorrectionEffect", Lighting).Name = "SXH_CC" end, Description = "Add color correction"}
Commands["unColorCorrection"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "SXH_CC" then v:Destroy() end end end, Description = "Remove color correction"}
Commands["FpsBoost"] = {Action = function() local Terrain = workspace:FindFirstChildOfClass("Terrain"); Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectivity = 0; Terrain.WaterTransparency = 0; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end, Description = "Optimize FPS"}
Commands["Xray"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then v.LocalTransparencyModifier = 0.5 end end end, Description = "Make map transparent"}
Commands["unXray"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end end end, Description = "Disable Xray"}
Commands["Gravity"] = {Action = function(v) workspace.Gravity = tonumber(v) or 196.2 end, Description = "Change gravity"}
Commands["ResetGravity"] = {Action = function() workspace.Gravity = 196.2 end, Description = "Reset gravity"}

-- [ Teleport & Positions Commands ] --
Commands["ClickTp"] = {Action = function() ActiveStates.ClickTp = not ActiveStates.ClickTp; local Mouse = LocalPlayer:GetMouse(); UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and ActiveStates.ClickTp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then if Mouse.Hit then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end end end) end, Description = "Toggle ClickTp"}
Commands["Goto"] = {Action = function(name) local target = Players:FindFirstChild(name); if target and target.Character then LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position) end end, Description = "Teleport to player"}
Commands["SavePos"] = {Action = function() ActiveStates.SavedPos = LocalPlayer.Character.HumanoidRootPart.CFrame; Notify("Saved", "Position saved") end, Description = "Save current position"}
Commands["LoadPos"] = {Action = function() if ActiveStates.SavedPos then LocalPlayer.Character.HumanoidRootPart.CFrame = ActiveStates.SavedPos end end, Description = "Teleport to saved position"}
Commands["TpSpawn"] = {Action = function() local s = workspace:FindFirstChild("SpawnLocation", true); if s then LocalPlayer.Character:MoveTo(s.Position) end end, Description = "Teleport to spawn"}
Commands["TpVoid"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -9999, 0) end, Description = "Teleport to void"}
Commands["TpSky"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 9999, 0) end, Description = "Teleport to sky"}

-- [ Utility & UI Commands ] --
Commands["Localtime"] = {Action = function() Notify("Local Time", os.date("%I:%M %p")) end, Description = "Show local time"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Exit game"}
Commands["Kick"] = {Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick self"}
Commands["Jobid"] = {Action = function() setclipboard(game.JobId) end, Description = "Copy JobId"}
Commands["JoinJobid"] = {Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end, Description = "Join JobId"}
Commands["CopyName"] = {Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName"}
Commands["CopyUsername"] = {Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Username"}
Commands["CopyPlaceId"] = {Action = function() setclipboard(tostring(game.PlaceId)) end, Description = "Copy PlaceId"}
Commands["CopyGameName"] = {Action = function() setclipboard(MarketplaceService:GetProductInfo(game.PlaceId).Name) end, Description = "Copy GameName"}
Commands["Rejoin"] = {Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server"}
Commands["ServerHop"] = {Action = function() local Http = game:GetService("HttpService"); local s = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data; for _, v in pairs(s) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer); break end end end, Description = "Join different server"}
Commands["AntiAfk"] = {Action = function() LocalPlayer.Idled:Connect(function() VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame) end) end, Description = "Prevent idle kick"}
Commands["Fov"] = {Action = function(v) workspace.CurrentCamera.FieldOfView = tonumber(v) or 120 end, Description = "Change FOV"}
Commands["ResetFov"] = {Action = function() workspace.CurrentCamera.FieldOfView = 70 end, Description = "Reset FOV"}
Commands["HideUI"] = {Action = function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end, Description = "Hide core UI"}
Commands["ShowUI"] = {Action = function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end, Description = "Show core UI"}
Commands["Btools"] = {Action = function() for _, t in ipairs({"Clone", "Destroy", "Grab"}) do local b = Instance.new("HopperBin"); b.BinType = Enum.BinType[t]; b.Parent = LocalPlayer.Backpack end end, Description = "Get building tools"}
Commands["DropTools"] = {Action = function() for _, t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then t.Parent = workspace end end end, Description = "Drop equipped tools"}
Commands["ClearTools"] = {Action = function() LocalPlayer.Backpack:ClearAllChildren() end, Description = "Destroy all tools"}
Commands["EquipAll"] = {Action = function() for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent = LocalPlayer.Character end end end, Description = "Equip all tools"}
Commands["Print"] = {Action = function(v) print(v or "Slow X Hub") end, Description = "Print to console"}
Commands["Warn"] = {Action = function(v) warn(v or "Slow X Hub") end, Description = "Warn in console"}
Commands["Error"] = {Action = function(v) error(v or "Slow X Hub") end, Description = "Error in console"}
Commands["ClearConsole"] = {Action = function() print(string.rep("\n", 100)) end, Description = "Clear F9 console"}
Commands["Chat"] = {Action = function(v) game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v or "Slow X Hub on top!", "All") end, Description = "Send chat message"}
Commands["Spam"] = {Action = function(v) ActiveStates.Spam = true; task.spawn(function() while ActiveStates.Spam do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v or "Spam", "All"); task.wait(1) end end) end, Description = "Spam chat"}
Commands["unSpam"] = {Action = function() ActiveStates.Spam = false end, Description = "Stop spam"}

-- [ Target & Esp Commands ] --
Commands["Esp"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local h = Instance.new("Highlight"); h.FillColor = Color3.fromRGB(0, 255, 255); h.Parent = p.Character; table.insert(ActiveStates.EspInstances, h) end end end, Description = "Highlight players"}
Commands["unEsp"] = {Action = function() for _,h in pairs(ActiveStates.EspInstances) do h:Destroy() end; ActiveStates.EspInstances = {} end, Description = "Remove highlights"}
Commands["Spectate"] = {Action = function(name) local target = Players:FindFirstChild(name); if target and target.Character then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end end, Description = "Spectate player"}
Commands["unSpectate"] = {Action = function() workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end, Description = "Stop spectating"}
Commands["Fling"] = {Action = function() ActiveStates.Fling = not ActiveStates.Fling; local bg = Instance.new("BodyAngularVelocity"); if ActiveStates.Fling then bg.Name = "SXH_Fling"; bg.AngularVelocity = Vector3.new(0, 99999, 0); bg.MaxTorque = Vector3.new(0, math.huge, 0); bg.Parent = LocalPlayer.Character.HumanoidRootPart else if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SXH_Fling") then LocalPlayer.Character.HumanoidRootPart.SXH_Fling:Destroy() end end end, Description = "Toggle fling mode"}
Commands["Hitbox"] = {Action = function(v) for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(v or 10, v or 10, v or 10); p.Character.HumanoidRootPart.Transparency = 0.5 end end end, Description = "Expand hitboxes"}
Commands["ResetHitbox"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); p.Character.HumanoidRootPart.Transparency = 1 end end end, Description = "Reset hitboxes"}
Commands["Chams"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then for _,part in pairs(p.Character:GetChildren()) do if part:IsA("BasePart") then local c = Instance.new("BoxHandleAdornment", part); c.Size = part.Size; c.AlwaysOnTop = true; c.ZIndex = 5; c.Adornee = part; c.Transparency = 0.5; c.Color3 = Color3.new(1,0,0) end end end end end, Description = "Enable Chams"}
Commands["unChams"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p.Character then for _,part in pairs(p.Character:GetChildren()) do for _,v in pairs(part:GetChildren()) do if v:IsA("BoxHandleAdornment") then v:Destroy() end end end end end end, Description = "Disable Chams"}
Commands["Aura"] = {Action = function() local a = Instance.new("Part", LocalPlayer.Character); a.Name = "SXH_Aura"; a.Size = Vector3.new(10, 0.1, 10); a.Anchored = false; a.CanCollide = false; a.Material = Enum.Material.Neon; a.Color = Color3.fromRGB(0, 255, 255); local w = Instance.new("Weld", a); w.Part0 = a; w.Part1 = LocalPlayer.Character.HumanoidRootPart end, Description = "Show aura"}
Commands["unAura"] = {Action = function() if LocalPlayer.Character:FindFirstChild("SXH_Aura") then LocalPlayer.Character.SXH_Aura:Destroy() end end, Description = "Remove aura"}
Commands["Trail"] = {Action = function() local t = Instance.new("Trail", LocalPlayer.Character.HumanoidRootPart); t.Name = "SXH_Trail"; local a0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart); a0.Position = Vector3.new(0, 1, 0); local a1 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart); a1.Position = Vector3.new(0, -1, 0); t.Attachment0 = a0; t.Attachment1 = a1; t.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)) end, Description = "Add trail"}
Commands["unTrail"] = {Action = function() for _,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do if v.Name == "SXH_Trail" or v:IsA("Attachment") then v:Destroy() end end end, Description = "Remove trail"}

-- [ Advanced Fly System ] --
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
            ActiveStates.FlyGyro.CFrame = workspace.CurrentCamera.CFrame
            ActiveStates.FlyGyro.Parent = hrp

            ActiveStates.FlyLoop = RunService.RenderStepped:Connect(function()
                if not ActiveStates.IsFlying or not char or not char:FindFirstChild("Humanoid") then return end
                local cam = workspace.CurrentCamera
                ActiveStates.FlyGyro.CFrame = cam.CFrame
                local moveDir = char.Humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    ActiveStates.FlyBody.Velocity = moveDir * ActiveStates.FlySpeed + Vector3.new(0, cam.CFrame.LookVector.Y * ActiveStates.FlySpeed, 0)
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

-- [ Platform Detection & UI Setup ] --
local function SetupFlyDetector()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        local guiParent = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "SlowXHub_MobileFly"
        sg.ResetOnSpawn = false
        sg.Parent = guiParent
        
        local flyBtn = Instance.new("TextButton")
        flyBtn.Size = UDim2.new(0, 60, 0, 60)
        flyBtn.Position = UDim2.new(1, -80, 0.5, -30)
        flyBtn.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
        flyBtn.BackgroundTransparency = 0.2
        flyBtn.Text = "Fly"
        flyBtn.TextColor3 = Color3.new(1, 1, 1)
        flyBtn.Font = Enum.Font.GothamBold
        flyBtn.TextSize = 16
        flyBtn.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = flyBtn
        
        flyBtn.MouseButton1Click:Connect(function()
            Commands["Fly"].Action()
            if ActiveStates.IsFlying then
                flyBtn.Text = "Unfly"
            else
                flyBtn.Text = "Fly"
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
