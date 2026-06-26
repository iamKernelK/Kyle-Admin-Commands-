local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ActiveStates = {} -- نظام الحالة للأوامر (تفعيل/إلغاء)

-- 1. الأوامر الأساسية والـ Reset
Commands["Speed"] = {Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Set speed"}
Commands["ResetSpeed"] = {Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed to 16"}
Commands["Jumppower"] = {Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Set jump power"}
Commands["ResetJumpPower"] = {Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end, Description = "Reset jump power to 50"}

-- 2. أوامر الطيران والقفز مع نظام un
Commands["Infjump"] = {Action = function() 
    ActiveStates.Infjump = true
    local UIS = game:GetService("UserInputService")
    UIS.JumpRequest:Connect(function() 
        if ActiveStates.Infjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end 
    end)
end, Description = "Infinite jump"}
Commands["unInfjump"] = {Action = function() ActiveStates.Infjump = false end, Description = "Disable infinite jump"}

Commands["Flyjump"] = {Action = function() 
    ActiveStates.Flyjump = true
    game:GetService("RunService").RenderStepped:Connect(function()
        if ActiveStates.Flyjump and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- منطق الطيران البسيط
        end
    end)
end, Description = "Enable fly jump"}
Commands["unFlyjump"] = {Action = function() ActiveStates.Flyjump = false end, Description = "Disable fly jump"}

-- 3. الأوامر الأخرى
Commands["Fullbright"] = {Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Full bright"}
Commands["Night"] = {Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set night"}
Commands["Day"] = {Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set day"}
Commands["Sit"] = {Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Sit"}
Commands["Nofog"] = {Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog"}
Commands["Time"] = {Action = function(t) Lighting.TimeOfDay = t end, Description = "Set time"}
Commands["Localtime"] = {Action = function() 
    local time = os.date("%I:%M %p")
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Local Time", Text = time, Icon = "rbxassetid://103568481311084"})
end, Description = "Get local time"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Close game"}
Commands["Kick"] = {Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick self"}
Commands["Jump"] = {Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump"}
Commands["Freeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze"}

-- 4. الخمسة أوامر الإضافية المفيدة
Commands["Rejoin"] = {Action = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server"}
Commands["Btools"] = {Action = function() -- يعطي أدوات البناء
    local tool = Instance.new("HopperBin", LocalPlayer.Backpack); tool.BinType = Enum.BinType.Hammer
    local tool2 = Instance.new("HopperBin", LocalPlayer.Backpack); tool2.BinType = Enum.BinType.Clone
    local tool3 = Instance.new("HopperBin", LocalPlayer.Backpack); tool3.BinType = Enum.BinType.Grab
end, Description = "Give BTools"}
Commands["Noclip"] = {Action = function() 
    ActiveStates.Noclip = true
    RunService.Stepped:Connect(function() if ActiveStates.Noclip and LocalPlayer.Character then for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
end, Description = "Enable Noclip"}
Commands["unNoclip"] = {Action = function() ActiveStates.Noclip = false end, Description = "Disable Noclip"}
Commands["ClickTp"] = {Action = function() -- تليبورت بمجرد النقر (Ctrl + Click)
    local Mouse = LocalPlayer:GetMouse()
    Mouse.Button1Down:Connect(function() if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end end)
end, Description = "Ctrl + Click to TP"}
Commands["Antilag"] = {Action = function() -- حذف الأجزاء غير الضرورية
    for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then v:Destroy() end end
end, Description = "Remove laggy particles"}

return Commands
