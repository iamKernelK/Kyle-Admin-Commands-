local Commands={}
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local ActiveStates={}
local GlobalTweenSpeed=150
local LastDeath=nil
local function trackDeath(c) c:WaitForChild("Humanoid").Died:Connect(function() if c:FindFirstChild("HumanoidRootPart") then LastDeath=c.HumanoidRootPart.CFrame end end) end
LocalPlayer.CharacterAdded:Connect(trackDeath)
if LocalPlayer.Character then trackDeath(LocalPlayer.Character) end
local lastJump=0
Commands["Speed"] = {Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed"}
Commands["ResetSpeed"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed"}
Commands["Cmds"]={Action=function() if not KyleUI then local Guis=loadstring(game:HttpGet("https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Guis/Cmds.lua"))() KyleUI=Guis.CreateCmdsUI() end KyleUI.Enabled=not KyleUI.Enabled end,Description="Toggle UI"}
Commands["cc"]={Action=function() local c=0 for _ in pairs(Commands) do c=c+1 end game:GetService("StarterGui"):SetCore("SendNotification",{Title="Kyle Admin",Text="Total Commands: "..c,Duration=5}) end,Description="Check total command count"}
Commands["AirWalk"]={Action=function() ActiveStates.AirWalk=not ActiveStates.AirWalk; if ActiveStates.AirWalk then local p=Instance.new("Part",workspace); p.Name="AdminAirWalk"; p.Size=Vector3.new(5,1,5); p.Anchored=true; p.Transparency=1; task.spawn(function() while ActiveStates.AirWalk and task.wait() do if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then p.CFrame=LocalPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,-3.5,0) end end; p:Destroy() end) else ActiveStates.AirWalk=false end end,Description="Toggle AirWalk"}
Commands["unHitbox"]={Action=function() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size=Vector3.new(2,2,1); p.Character.HumanoidRootPart.Transparency=1 end end end,Description="Reset Hitboxes"}
Commands["unClicktp"]={Action=function() ActiveStates.ClickTp=false end,Description="Disable ClickTp"}
Commands["Infjump"]={Action=function() ActiveStates.Infjump=true; UserInputService.JumpRequest:Connect(function() if ActiveStates.Infjump and tick()-lastJump>=0.2 then lastJump=tick(); LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end) end,Description="Infjump with 0.2s cooldown"}
Commands["unInfjump"]={Action=function() ActiveStates.Infjump=false end,Description="Disable Infjump"}
Commands["tto"]={Args="Player",Action=function(n) local t=Players:FindFirstChild(n); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then local hrp=LocalPlayer.Character.HumanoidRootPart; local dist=(hrp.Position-t.Character.HumanoidRootPart.Position).Magnitude; local tween=TweenService:Create(hrp,TweenInfo.new(dist/GlobalTweenSpeed,Enum.EasingStyle.Linear),{CFrame=t.Character.HumanoidRootPart.CFrame}); tween:Play() end end,Description="Tween TP to player"}
Commands["TweenSpeed"]={Args="Speed",Action=function(v) GlobalTweenSpeed=tonumber(v) or 150 end,Description="Set TweenSpeed"}
Commands["AntiVoid2"] = {Action = function() game.Workspace.FallenPartsDestroyHeight = -999999 end, Description = "Prevent death in void"}
Commands["Explode"] = {Action = function() Instance.new("Explosion", game.Players.LocalPlayer.Character.HumanoidRootPart) end, Description = "Explode yourself"}
Commands["Firework"] = {Action = function() 
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.new(0, 100, 0); bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
    local bg = Instance.new("BodyAngularVelocity", hrp); bg.AngularVelocity = Vector3.new(0, 50, 0); bg.MaxTorque = Vector3.new(1/0, 1/0, 1/0)
    task.wait(1.5); bv:Destroy(); bg:Destroy(); Instance.new("Explosion", hrp)
end, Description = "Firework effect"}
Commands["BubbleChat"] = {Args = "Message", Action = function(msg)
    local Players = game:GetService("Players")
    local Chat = game:GetService("Chat")
    Chat:Chat(Players.LocalPlayer.Character.Head, msg, Enum.ChatColor.White)
end, Description = "Chat above your head"}
Commands["AntiVoid"] = {Action = function() local p=game.Players.LocalPlayer; p.Character.HumanoidRootPart.Touched:Connect(function(h) if h.Name=="FallenPartsDestroyHeight" then p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,50,0) end end) end, Description = "Walk over void"}
Commands["Flashback"]={Action=function() if LastDeath and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame=LastDeath end end,Description="TP to last death"}
Commands["Jumppower"] = {Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power"}
-- ProximityPrompt Commands
Commands["ShowProxi"]={Action=function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.Enabled=true end end end,Description="Show all ProximityPrompts"}
Commands["HideProxi"]={Action=function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.Enabled=false end end end,Description="Hide all ProximityPrompts"}

-- TouchInterest Commands
Commands["ShowTouch"]={Action=function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("TouchTransmitter") then v.Parent.Transparency=0.5 end end end,Description="Show all TouchInterests"}
Commands["HideTouch"]={Action=function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("TouchTransmitter") then v.Parent.Transparency=1 end end end,Description="Hide all TouchInterests"}
local BackupTouch={}
Commands["AntiTouch"]={Action=function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("TouchTransmitter") then BackupTouch[v]=v.Parent; v:Destroy() end end end,Description="Remove all TouchInterests"}
Commands["UnAntiTouch"]={Action=function() for v,p in pairs(BackupTouch) do if p and not v.Parent then v.Parent=p end end end,Description="Restore all TouchInterests"}
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
Commands["Localtime"] = {Action = function() local time = os.date("%I:%M %p"); game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Local Time", Text = time, Icon = "rbxassetid://103568481311084"}) end, Description = "Show local time"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Exit game"}
Commands["Kick"] = {Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick self"}
Commands["Jump"] = {Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump"}
Commands["ClickTp"] = {Action = function() ActiveStates.ClickTp = not ActiveStates.ClickTp; local Mouse = LocalPlayer:GetMouse(); UserInputService.InputBegan:Connect(function(input, gpe) if gpe then return end; if ActiveStates.ClickTp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then if Mouse.Hit then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end end end) end, Description = "Toggle ClickTp"}
Commands["Jobid"] = {Action = function() setclipboard(game.JobId) end, Description = "Copy JobId"}
Commands["Ambient"] = {Args = "R G B", Action = function(args) local r,g,b = args:match("(%d+) (%d+) (%d+)") game:GetService("Lighting").Ambient = Color3.fromRGB(r,g,b) end, Description = "Set ambient color"}
Commands["Headless"] = {Action = function() pcall(function() local char = game.Players.LocalPlayer.Character char.Head.Transparency = 1 char.Head.face:Destroy() for _,v in pairs(char.Head:GetChildren()) do if v:IsA("Accessory") or v:IsA("Decal") then v:Destroy() end end end) end, Description = "Headless mode"}
Commands["JoinJobid"] = {Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end, Description = "Join JobId"}
-- Korblox Command
Commands["Korblox"] = {
    Action = function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char and char:FindFirstChild("Right Leg") then
            char["Right Leg"]:Destroy()
        end
        local korblox = Instance.new("MeshPart")
        korblox.MeshId = "rbxassetid://139607718"
        korblox.Name = "Right Leg"
        korblox.Parent = char
    end,
    Description = "Apply Korblox leg"
}

-- Morph Command (Requires username)
Commands["Morph"] = {
    Args = "Username",
    Action = function(target)
        local player = game:GetService("Players").LocalPlayer
        local desc = game:GetService("Players"):GetHumanoidDescriptionFromUserName(target)
        if desc then
            player.Character.Humanoid:ApplyDescription(desc)
        end
    end,
    Description = "Morph into another player"
}

Commands["CopyName"] = {Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName"}
Commands["CopyUsername"] = {Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Username"}
Commands["CopyPlaceId"] = {Action = function() setclipboard(tostring(game.PlaceId)) end, Description = "Copy PlaceId"}
Commands["CopyGameName"] = {Action = function() setclipboard(MarketplaceService:GetProductInfo(game.PlaceId).Name) end, Description = "Copy GameName"}
Commands["Rejoin"] = {Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server"}
Commands["FpsBoost"] = {Action = function() local Terrain = workspace:FindFirstChildOfClass("Terrain"); Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectivity = 0; Terrain.WaterTransparency = 0; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end, Description = "Optimize FPS"}
Commands["Invisible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end, Description = "Make character invisible"}
Commands["Visible"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 end end end, Description = "Make character visible"}
Commands["Goto"] = {Action = function(name) local target = Players:FindFirstChild(name); if target and target.Character then LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position) end end, Description = "Teleport to player"}
Commands["Dex"] = {Action = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Dex-Explorer-DPP-73687"))() end, Description = "Run Dex Explorer"}
Commands["TurtleSpy"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))() end, Description = "Run Turtle Spy"}
Commands["ToolName"] = {Action = function() local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool"); local name = tool and tool.Name or "No tool equipped"; game.StarterGui:SetCore("SendNotification", {Title = "Equipped Tool", Text = "Tool Name: " .. name, Duration = 5}) end, Description = "Notify equipped tool name"}
Commands["Btools"] = {Action = function() loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))() end, Description = "Give Btools"}
Commands["Console"] = {Action = function() game.StarterGui:SetCore("DevConsoleVisible", true) end, Description = "Open Dev Console"}
Commands["Suicide"] = {Action = function() LocalPlayer.Character:BreakJoints() end, Description = "Kill character"}
Commands["FOV"] = {Action = function(v) workspace.CurrentCamera.FieldOfView = tonumber(v) or 70 end, Description = "Change FOV"}
Commands["ResetFOV"] = {Action = function() workspace.CurrentCamera.FieldOfView = 70 end, Description = "Reset FOV"}
Commands["Gravity"] = {Action = function(v) workspace.Gravity = tonumber(v) or 196.2 end, Description = "Set Gravity"}
Commands["ResetGravity"] = {Action = function() workspace.Gravity = 196.2 end, Description = "Reset Gravity"}
Commands["UnlockAll"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = false end end end, Description = "Unlock workspace parts"}
Commands["RemoveHats"] = {Action = function() for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end, Description = "Remove accessories"}
Commands["ServerHop"] = {Action = function() local servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data; for _,s in ipairs(servers) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) break end end end, Description = "Hop to another server"}
Commands["Xray"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then v.LocalTransparencyModifier = 0.5 end end end, Description = "Make map semi-transparent"}
Commands["unXray"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end end end, Description = "Revert Xray"}
Commands["Hitbox"] = {Action = function(v) local size = tonumber(v) or 5; for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(size, size, size); p.Character.HumanoidRootPart.Transparency = 0.5 end end end, Description = "Expand player hitboxes"}
Commands["Esp"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local hl = Instance.new("Highlight"); hl.Parent = p.Character; hl.FillColor = Color3.new(1,0,0); hl.Name = "AdminESP" end end end, Description = "Highlight players"}
Commands["unEsp"] = {Action = function() for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("AdminESP") then p.Character.AdminESP:Destroy() end end end, Description = "Remove Highlights"}
Commands["Spin"] = {Action = function(v) local speed = tonumber(v) or 10; local spin = Instance.new("BodyAngularVelocity"); spin.Name = "AdminSpin"; spin.Parent = LocalPlayer.Character.HumanoidRootPart; spin.MaxTorque = Vector3.new(0, math.huge, 0); spin.AngularVelocity = Vector3.new(0, speed, 0) end, Description = "Spin character"}
Commands["unSpin"] = {Action = function() if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("AdminSpin") then LocalPlayer.Character.HumanoidRootPart.AdminSpin:Destroy() end end, Description = "Stop spinning"}
return Commands
