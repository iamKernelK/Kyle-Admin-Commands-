-- ModuleScript: Commands
local Commands = {}

Commands["Speed"] = {
    Action = function(val) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val end,
    Description = "Change walk speed (Default: 16)"
}

Commands["JumpPower"] = {
    Action = function(val) game.Players.LocalPlayer.Character.Humanoid.JumpPower = val end,
    Description = "Change jump height (Default: 50)"
}

return Commands
