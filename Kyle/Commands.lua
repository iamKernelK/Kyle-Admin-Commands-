local Commands = {}

Commands["Speed"] = {
    Action = function(val)
        val = tonumber(val) or 16
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end,
    Description = "Change walk speed (Default: 16)"
}

Commands["JumpPower"] = {
    Action = function(val)
        val = tonumber(val) or 50
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.UseJumpPower = true
            char.Humanoid.JumpPower = val
        end
    end,
    Description = "Change jump height (Default: 50)"
}

Commands["Sit"] = {
    Action = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Sit = true
        end
    end,
    Description = "Force character to sit"
}

return Commands
