local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local ActiveStates = {}

local function setclipboard(text) if setclipboard then setclipboard(text) end end

local function ResolveTarget(name)
    if not name then return {LocalPlayer} end
    local nameLower = string.lower(name)
    if nameLower == "me" then return {LocalPlayer} end
    if nameLower == "all" then return Players:GetPlayers() end
    if nameLower == "others" then
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(others, p) end end
        return others
    end
    if nameLower == "random" then return {Players:GetPlayers()[math.random(1, #Players:GetPlayers())]} end
    local found = {}
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), nameLower) or string.find(string.lower(p.DisplayName), nameLower) then
            table.insert(found, p)
        end
    end
    return found
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
            if ActiveStates.Infjump then task.wait(0.1); LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end 
        end)
    end,
    Description = "Enable infinite jump"
}
Commands["unInfjump"] = {
    Action = function() ActiveStates.Infjump = false end,
    Description = "Disable infinite jump"
}
Commands["Flyjump"] = {
    Action = function()
        ActiveStates.Flyjump = true
        UserInputService.JumpRequest:Connect(function()
            if ActiveStates.Flyjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
        end)
    end,
    Description = "Infinite jump no cooldown"
}
Commands["JumpLimit"] = {
    Action = function(limit)
        ActiveStates.JumpLimit = tonumber(limit) or 0
        ActiveStates.JumpCount = 0
        LocalPlayer.Character.Humanoid.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Landed then ActiveStates.JumpCount = 0 end
        end)
        UserInputService.JumpRequest:Connect(function()
            if ActiveStates.JumpLimit and ActiveStates.JumpCount < ActiveStates.JumpLimit then
                ActiveStates.JumpCount = ActiveStates.JumpCount + 1
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end,
    Description = "Limit jumps in air"
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
                if Mouse.Hit then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end
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
        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0
        for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end
    end,
    Description = "Optimize FPS"
}
Commands["Invisible"] = {
    Action = function() 
        for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end
    end,
    Description = "Make character invisible"
}
Commands["Visible"] = {
    Action = function() 
        for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 end end
    end,
    Description = "Make character visible"
}
Commands["Goto"] = {
    Action = function(name)
        local targets = ResolveTarget(name)
        if targets[1] and targets[1].Character then LocalPlayer.Character:MoveTo(targets[1].Character.HumanoidRootPart.Position) end
    end,
    Description = "Teleport to player"
}
Commands["Nohats"] = {
    Action = function()
        for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end
    end,
    Description = "Remove all hats"
}
Commands["Commandloop"] = {
    Action = function(cmd, args, delay)
        task.spawn(function()
            while task.wait(tonumber(delay)) do
                if Commands[cmd] then Commands[cmd].Action(args) end
            end
        end)
    end,
    Description = "Loop a command"
}
Commands["AccountAge"] = {
    Action = function(name)
        local target = ResolveTarget(name)[1]
        local age = target and target.AccountAge or LocalPlayer.AccountAge
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Account Age", Text = tostring(age), Icon = "rbxassetid://103568481311084"})
    end,
    Description = "Get account age"
}
Commands["Airwalk"] = {
    Action = function()
        ActiveStates.Airwalk = true
        local part = Instance.new("Part", workspace)
        part.Size = Vector3.new(4, 1, 4); part.Transparency = 1; part.Anchored = true
        RunService.RenderStepped:Connect(function()
            if ActiveStates.Airwalk and LocalPlayer.Character then
                part.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            else part:Destroy() end
        end)
    end,
    Description = "Enable airwalk"
}
Commands["unAirwalk"] = {
    Action = function() ActiveStates.Airwalk = false end,
    Description = "Disable airwalk"
}
Commands["Esp"] = {
    Action = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = Instance.new("Highlight", p.Character)
                h.FillColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end,
    Description = "ESP others"
}
Commands["Esptype"] = {
    Action = function(t) ActiveStates.EspType = t end,
    Description = "Set ESP type (Chams/Highlight/Box)"
}
Commands["Locate"] = {
    Action = function(name)
        local target = ResolveTarget(name)[1]
        if target and target.Character then
            local arrow = Instance.new("Beam", LocalPlayer.Character)
            -- Logic for arrow drawing
        end
    end,
    Description = "Locate Player"
}
Commands["View"] = {
    Action = function(name)
        local target = ResolveTarget(name)[1]
        if target then Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChild("Humanoid") end
    end,
    Description = "Spectate Player"
}
Commands["unView"] = {
    Action = function() Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end,
    Description = "Stop spectate"
}
Commands["Dex"] = {
    Action = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Dex-Explorer-DPP-73687"))() end,
    Description = "Run Dex"
}
Commands["Tspy"] = {
    Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))() end,
    Description = "Run Turtle Spy"
}
Commands["cc"] = {
    Action = function()
        local count = 0
        for _ in pairs(Commands) do count = count + 1 end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Commands", Text = "Loaded: " .. count, Icon = "rbxassetid://103568481311084"})
    end,
    Description = "Show count"
}

return Commands
