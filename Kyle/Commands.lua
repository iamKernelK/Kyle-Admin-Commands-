local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local ActiveStates = {}
_G.PrevWalkSpeed = 16
_G.SavedPos = CFrame.new(0, 50, 0)
local lastInfJump = 0

local function setclipboard(text)
    if setclipboard then setclipboard(text) end
end

-- [ Setup Kyle Admin Folders ] --
local kyleFolder = workspace:FindFirstChild("Kyle [ Admin Commands ]")
if not kyleFolder then
    kyleFolder = Instance.new("Folder", workspace)
    kyleFolder.Name = "Kyle [ Admin Commands ]"
    local cmdFolder = Instance.new("Folder", kyleFolder)
    cmdFolder.Name = "Commands"
end

-- [ Flight Vector Math ] --
local function getFlyVelocity(cam, moveDir, speed)
    if moveDir.Magnitude == 0 then return Vector3.zero end
    local lv = cam.CFrame.LookVector
    local rv = cam.CFrame.RightVector
    local flatLv = Vector3.new(lv.X, 0, lv.Z)
    
    if flatLv.Magnitude > 0.001 then
        flatLv = flatLv.Unit
        local flatRv = Vector3.new(rv.X, 0, rv.Z).Unit
        local forwardMove = flatLv:Dot(moveDir)
        local rightMove = flatRv:Dot(moveDir)
        return (lv * forwardMove + rv * rightMove).Unit * speed
    else
        return moveDir * speed
    end
end

-- [ 1. Movement & Flight Commands ] --

Commands["Fly"] = {
    Action = function(args)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if ActiveStates.FlyStop then ActiveStates.FlyStop() end
        
        local speed = tonumber(args) or 50
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1/0, 1/0, 1/0); bg.P = 10000
        
        local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://507765000"
        local track = hum:LoadAnimation(anim); track:Play()
        
        ActiveStates.FlyLoop = RunService.RenderStepped:Connect(function()
            bv.Velocity = getFlyVelocity(workspace.CurrentCamera, hum.MoveDirection, speed)
            bg.CFrame = workspace.CurrentCamera.CFrame
        end)
        
        ActiveStates.FlyStop = function()
            hum.PlatformStand = false; if bv then bv:Destroy() end; if bg then bg:Destroy() end
            if track then track:Stop() end; if ActiveStates.FlyLoop then ActiveStates.FlyLoop:Disconnect() end
            ActiveStates.FlyStop = nil
        end
    end
}
Commands["UnFly"] = { Action = function() if ActiveStates.FlyStop then ActiveStates.FlyStop() end end }

Commands["VFly"] = {
    Action = function(args)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.SeatPart then return end
        if ActiveStates.VFlyStop then ActiveStates.VFlyStop() end
        
        local speed = tonumber(args) or 50
        local seat = hum.SeatPart
        local bv = Instance.new("BodyVelocity", seat); bv.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        local bg = Instance.new("BodyGyro", seat); bg.MaxTorque = Vector3.new(1/0, 1/0, 1/0); bg.P = 10000
        
        ActiveStates.VFlyLoop = RunService.RenderStepped:Connect(function()
            bv.Velocity = getFlyVelocity(workspace.CurrentCamera, hum.MoveDirection, speed)
            bg.CFrame = workspace.CurrentCamera.CFrame
        end)
        
        ActiveStates.VFlyStop = function()
            if bv then bv:Destroy() end; if bg then bg:Destroy() end
            if ActiveStates.VFlyLoop then ActiveStates.VFlyLoop:Disconnect() end
            ActiveStates.VFlyStop = nil
        end
    end
}
Commands["UnVFly"] = { Action = function() if ActiveStates.VFlyStop then ActiveStates.VFlyStop() end end }

Commands["CFly"] = {
    Action = function(args)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if ActiveStates.CFlyStop then ActiveStates.CFlyStop() end
        
        local speed = tonumber(args) or 50
        hum.PlatformStand = true
        
        ActiveStates.CFlyLoop = RunService.Heartbeat:Connect(function(dt)
            hrp.Velocity = Vector3.zero 
            if hum.MoveDirection.Magnitude > 0 then
                local flyVel = getFlyVelocity(workspace.CurrentCamera, hum.MoveDirection, speed)
                hrp.CFrame = hrp.CFrame + (flyVel * dt)
            end
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector)
        end)
        
        ActiveStates.CFlyStop = function()
            hum.PlatformStand = false
            if ActiveStates.CFlyLoop then ActiveStates.CFlyLoop:Disconnect() end
            ActiveStates.CFlyStop = nil
        end
    end
}
Commands["UnCFly"] = { Action = function() if ActiveStates.CFlyStop then ActiveStates.CFlyStop() end end }

Commands["TpWalk"] = {
    Action = function(args)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if ActiveStates.TpWalkStop then ActiveStates.TpWalkStop() end
        
        local speedMult = tonumber(args) or 2 
        ActiveStates.TpWalkLoop = RunService.Heartbeat:Connect(function()
            if hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * speedMult)
            end
        end)
        
        ActiveStates.TpWalkStop = function()
            if ActiveStates.TpWalkLoop then ActiveStates.TpWalkLoop:Disconnect() end
            ActiveStates.TpWalkStop = nil
        end
    end
}
Commands["UnTpWalk"] = { Action = function() if ActiveStates.TpWalkStop then ActiveStates.TpWalkStop() end end }

-- [ 2. Jump & Speed Modifiers ] --
Commands["Speed"] = { Action = function(v) _G.PrevWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed; LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end }
Commands["ResetSpeed"] = { Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end }
Commands["Jumppower"] = { Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end }
Commands["ResetJumpPower"] = { Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end }

Commands["Infjump"] = { 
    Action = function() 
        ActiveStates.Infjump = true 
        if not ActiveStates.InfJumpConn then
            ActiveStates.InfJumpConn = UserInputService.JumpRequest:Connect(function()
                if ActiveStates.Infjump and os.clock() - lastInfJump >= 0.2 then
                    lastInfJump = os.clock()
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end
    end 
}
Commands["UnInfjump"] = { Action = function() ActiveStates.Infjump = false end }

Commands["Flyjump"] = { 
    Action = function() 
        ActiveStates.Flyjump = true 
        if not ActiveStates.FlyJumpConn then
            ActiveStates.FlyJumpConn = UserInputService.JumpRequest:Connect(function()
                if ActiveStates.Flyjump then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end
    end 
}
Commands["UnFlyjump"] = { Action = function() ActiveStates.Flyjump = false end }

-- [ 3. Morph & Skin System ] --
Commands["Morph"] = {
    Action = function(args)
        local targetName = tostring(args)
        pcall(function()
            local id = Players:GetUserIdFromNameAsync(targetName)
            local desc = Players:GetHumanoidDescriptionFromUserId(id)
            LocalPlayer.Character.Humanoid:ApplyDescription(desc)
            ActiveStates.CurrentMorphID = id
        end)
    end
}

Commands["LoopMorph"] = {
    Action = function()
        ActiveStates.LoopMorph = true
        if not ActiveStates.LoopMorphConn then
            ActiveStates.LoopMorphConn = LocalPlayer.CharacterAdded:Connect(function(char)
                if ActiveStates.LoopMorph and ActiveStates.CurrentMorphID then
                    local hum = char:WaitForChild("Humanoid", 5)
                    if hum then
                        pcall(function()
                            local desc = Players:GetHumanoidDescriptionFromUserId(ActiveStates.CurrentMorphID)
                            hum:ApplyDescription(desc)
                        end)
                    end
                end
            end)
        end
    end
}
Commands["UnLoopMorph"] = { Action = function() ActiveStates.LoopMorph = false end }

Commands["SaveSkin"] = {
    Action = function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local desc = hum:GetAppliedDescription()
            local folder = workspace:FindFirstChild("Kyle [ Admin Commands ]")
            if folder and folder:FindFirstChild("Commands") then
                local oldSkin = folder.Commands:FindFirstChild("SavedSkin")
                if oldSkin then oldSkin:Destroy() end
                desc.Name = "SavedSkin"
                desc.Parent = folder.Commands
            end
        end
    end
}

Commands["LoadSkin"] = {
    Action = function()
        local folder = workspace:FindFirstChild("Kyle [ Admin Commands ]")
        if folder and folder:FindFirstChild("Commands") then
            local savedSkin = folder.Commands:FindFirstChild("SavedSkin")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if savedSkin and hum then
                hum:ApplyDescription(savedSkin)
            end
        end
    end
}

Commands["LoopLoadSkin"] = {
    Action = function()
        ActiveStates.LoopLoadSkin = true
        if not ActiveStates.LoopLoadConn then
            ActiveStates.LoopLoadConn = LocalPlayer.CharacterAdded:Connect(function(char)
                if ActiveStates.LoopLoadSkin then
                    local hum = char:WaitForChild("Humanoid", 5)
                    local folder = workspace:FindFirstChild("Kyle [ Admin Commands ]")
                    if hum and folder and folder:FindFirstChild("Commands") then
                        local savedSkin = folder.Commands:FindFirstChild("SavedSkin")
                        if savedSkin then hum:ApplyDescription(savedSkin) end
                    end
                end
            end)
        end
    end
}
Commands["UnLoopLoadSkin"] = { Action = function() ActiveStates.LoopLoadSkin = false end }

-- [ 4. Utility & Server Commands ] --
Commands["Jobid"] = { Action = function() setclipboard(game.JobId) end }
Commands["JoinJobid"] = { Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(id), LocalPlayer) end }
Commands["PlaceId"] = { Action = function() setclipboard(tostring(game.PlaceId)) end }
Commands["Rejoin"] = { Action = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end }
Commands["ServerHop"] = { 
    Action = function() 
        local r = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public"))
        TeleportService:TeleportToPlaceInstance(game.PlaceId, r.data[math.random(1,#r.data)].id) 
    end 
}
Commands["CopyPos"] = { Action = function() setclipboard(tostring(LocalPlayer.Character.HumanoidRootPart.Position)) end }
Commands["SavePos"] = { Action = function() _G.SavedPos = LocalPlayer.Character.HumanoidRootPart.CFrame end }
Commands["LoadPos"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.CFrame = _G.SavedPos end }
Commands["Fov"] = { Action = function(v) workspace.CurrentCamera.FieldOfView = tonumber(v) or 70 end }
Commands["Exit"] = { Action = function() game:Shutdown() end }
Commands["Clear"] = { Action = function() if rconsoleclear then rconsoleclear() end end }

-- [ 5. World & Rendering ] --
Commands["Fullbright"] = { Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1,1,1) end }
Commands["LowGfx"] = { Action = function() settings().Rendering.QualityLevel = 1; workspace.Terrain.WaterWaveSize = 0 end }
Commands["HighGfx"] = { Action = function() settings().Rendering.QualityLevel = 21 end }
Commands["NoShadows"] = { Action = function() Lighting.GlobalShadows = false end }
Commands["Shadows"] = { Action = function() Lighting.GlobalShadows = true end }
Commands["Day"] = { Action = function() Lighting.TimeOfDay = "12:00:00" end }
Commands["Night"] = { Action = function() Lighting.TimeOfDay = "24:00:00" end }
Commands["NoWater"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Water") then v.Enabled = false end end end }
Commands["ClearDecals"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") then v:Destroy() end end end }

-- [ 6. Character Mods ] --
Commands["Noclip"] = { 
    Action = function() 
        ActiveStates.Noclip = true
        if not ActiveStates.NoclipConn then
            ActiveStates.NoclipConn = RunService.Stepped:Connect(function() 
                if ActiveStates.Noclip and LocalPlayer.Character then 
                    for _,p in pairs(LocalPlayer.Character:GetDescendants()) do 
                        if p:IsA("BasePart") then p.CanCollide = false end 
                    end 
                end 
            end)
        end
    end 
}
Commands["UnNoclip"] = { Action = function() ActiveStates.Noclip = false end }
Commands["God"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():match("kill") or v.Name:lower():match("lava")) then v.CanTouch = false end end end }
Commands["Ghost"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end end }
Commands["Unghost"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end }

return Commands

