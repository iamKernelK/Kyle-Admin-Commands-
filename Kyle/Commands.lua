local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ActiveStates = {}

local function setclipboard(text)
    if setclipboard then setclipboard(text) end
end

Commands["Speed"] = {
    Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end,
    Description = "Change walk speed"
}
Commands["ResetSpeed"] = {
    Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end,
    Description = "Reset speed"
}
Commands["Jumppower"] = {
    Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end,
    Description = "Change jump power"
}
Commands["ResetJumpPower"] = {
    Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end,
    Description = "Reset jump power"
}
Commands["Infjump"] = {
    Action = function() 
        ActiveStates.Infjump = true
        UserInputService.JumpRequest:Connect(function() 
            if ActiveStates.Infjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end 
        end)
    end,
    Description = "Enable infinite jump"
}
Commands["unInfjump"] = {
    Action = function() ActiveStates.Infjump = false end,
    Description = "Disable infinite jump"
}
Commands["Noclip"] = {
    Action = function() 
        ActiveStates.Noclip = true
        RunService.Stepped:Connect(function() 
            if ActiveStates.Noclip and LocalPlayer.Character then 
                for _,p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end 
            end 
        end)
    end,
    Description = "Enable Noclip"
}
Commands["Clip"] = {
    Action = function() ActiveStates.Noclip = false end,
    Description = "Disable Noclip"
}
Commands["Freeze"] = {
    Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end,
    Description = "Freeze character"
}
Commands["unFreeze"] = {
    Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = false end,
    Description = "Unfreeze character"
}
Commands["Fullbright"] = {
    Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end,
    Description = "Enable Fullbright"
}
Commands["Night"] = {
    Action = function() Lighting.TimeOfDay = "00:00:00" end,
    Description = "Set night"
}
Commands["Day"] = {
    Action = function() Lighting.TimeOfDay = "14:00:00" end,
    Description = "Set day"
}
Commands["Sit"] = {
    Action = function() LocalPlayer.Character.Humanoid.Sit = true end,
    Description = "Force sit"
}
Commands["Nofog"] = {
    Action = function() Lighting.FogEnd = 999999 end,
    Description = "Remove fog"
}
Commands["Time"] = {
    Action = function(t) Lighting.TimeOfDay = t end,
    Description = "Set time"
}
Commands["Localtime"] = {
    Action = function() 
        local time = os.date("%I:%M %p")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Local Time", Text = time, Icon = "rbxassetid://103568481311084"})
    end,
    Description = "Show local time"
}
Commands["Exit"] = {
    Action = function() game:Shutdown() end,
    Description = "Exit game"
}
Commands["Kick"] = {
    Action = function(r) LocalPlayer:Kick(r or "Disconnected") end,
    Description = "Kick self"
}
Commands["Jump"] = {
    Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end,
    Description = "Jump"
}
Commands["ClickTp"] = {
    Action = function()
        ActiveStates.ClickTp = not ActiveStates.ClickTp
        local Mouse = LocalPlayer:GetMouse()
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if ActiveStates.ClickTp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                if Mouse.Hit then
                    LocalPlayer.Character:MoveTo(Mouse.Hit.p)
                end
            end
        end)
    end,
    Description = "Toggle ClickTp"
}
Commands["Jobid"] = {
    Action = function() setclipboard(game.JobId) end,
    Description = "Copy JobId"
}
Commands["JoinJobid"] = {
    Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end,
    Description = "Join JobId"
}
Commands["CopyName"] = {
    Action = function() setclipboard(LocalPlayer.DisplayName) end,
    Description = "Copy DisplayName"
}
Commands["CopyUsername"] = {
    Action = function() setclipboard(LocalPlayer.Name) end,
    Description = "Copy Username"
}
Commands["CopyPlaceId"] = {
    Action = function() setclipboard(tostring(game.PlaceId)) end,
    Description = "Copy PlaceId"
}
Commands["CopyGameName"] = {
    Action = function() setclipboard(MarketplaceService:GetProductInfo(game.PlaceId).Name) end,
    Description = "Copy GameName"
}
Commands["Rejoin"] = {
    Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
    Description = "Rejoin server"
}
Commands["FpsBoost"] = {
    Action = function() 
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectivity = 0
        Terrain.WaterTransparency = 0
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end,
    Description = "Optimize FPS"
}
Commands["Invisible"] = {
    Action = function() 
        for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 1 end
        end
    end,
    Description = "Make character invisible"
}
Commands["Visible"] = {
    Action = function() 
        for _,p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0 end
        end
    end,
    Description = "Make character visible"
}
Commands["Goto"] = {
    Action = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
        end
    end,
    Description = "Teleport to player"
}

return Commands
