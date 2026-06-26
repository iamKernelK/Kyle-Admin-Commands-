local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- إشعار الترحيب
task.spawn(function()
    local count = 0 for _, _ in pairs(Commands) do count = count + 1 end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kyle [ Admin Commands ]",
        Text = "Commands loaded: " .. count,
        Icon = "rbxassetid://103568481311084"
    })
end)

Commands["Speed"] = {Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed"}
Commands["Jumppower"] = {Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power"}
Commands["Tpwalk"] = {Action = function(v) -- إضافة سرعة التليبورت التلقائي (اختياري)
    end, Description = "Teleport walk speed"}
Commands["Fullbright"] = {Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Enable full bright"}
Commands["Night"] = {Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set time to night"}
Commands["Day"] = {Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set time to day"}
Commands["Sit"] = {Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Force sit"}
Commands["Flyjump"] = {Action = function() 
    local UIS = game:GetService("UserInputService")
    UIS.JumpRequest:Connect(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end)
end, Description = "Enable infinite jump"}
Commands["Infjump"] = {Action = function() 
    local UIS = game:GetService("UserInputService")
    UIS.JumpRequest:Connect(function() task.wait(0.1); LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end)
end, Description = "Infinite jump with 0.1 cooldown"}
Commands["Jumplimit"] = {Action = function(v) -- منطق القفز المحدود
    end, Description = "Limited infinite jump"}
Commands["Nofog"] = {Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog"}
Commands["Time"] = {Action = function(t) Lighting.TimeOfDay = t end, Description = "Set specific time"}
Commands["Localtime"] = {Action = function() 
    local time = os.date("%I:%M %p")
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Local Time", Text = time})
end, Description = "Get local time"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Close game"}
Commands["Kick"] = {Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick yourself"}
Commands["Jump"] = {Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump once"}
Commands["Freeze"] = {Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze character"}

return Commands
