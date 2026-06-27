local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ActiveStates = {}

local function setclipboard(text) if setclipboard then setclipboard(text) end end

local function GetClosestPlayer()
    local closest, minDistance = nil, math.huge
    local lpChar = LocalPlayer.Character
    if not lpChar or not lpChar:FindFirstChild("HumanoidRootPart") then return nil end
    local lpPos = lpChar.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - lpPos).Magnitude
            if dist < minDistance then minDistance = dist; closest = p end
        end
    end
    return closest and {closest} or {}
end

local function ResolveTarget(name)
    if not name or name == "" then return {LocalPlayer} end
    local nameLower = string.lower(name)
    if nameLower == "me" then return {LocalPlayer} end
    if nameLower == "all" then return Players:GetPlayers() end
    if nameLower == "others" then
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(others, p) end end
        return others
    end
    if nameLower == "random" then return {Players:GetPlayers()[math.random(1, #Players:GetPlayers())]} end
    if nameLower == "near" then return GetClosestPlayer() end

    local found = {}
    for _, p in pairs(Players:GetPlayers()) do
        if string.sub(string.lower(p.Name), 1, #nameLower) == nameLower or string.sub(string.lower(p.DisplayName), 1, #nameLower) == nameLower then
            table.insert(found, p)
        end
    end
    return found
end

-- نظام مساعد لإنشاء وحذف الـ ESP
local function CreateESP(part, color, name)
    if not part or part:FindFirstChild(name) then return end
    local h = Instance.new("Highlight", part)
    h.Name = name; h.FillColor = color; h.OutlineColor = color
end
local function RemoveESP(name)
    for _,v in pairs(Workspace:GetDescendants()) do
        if v.Name == name and v:IsA("Highlight") then v:Destroy() end
    end
end

-- ==========================================
-- الأوامر الأساسية والحركة
-- ==========================================
Commands["Speed"] = { Args = "Value", Action = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed" }
Commands["ResetSpeed"] = { Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed" }
Commands["Jumppower"] = { Args = "Value", Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power" }
Commands["ResetJumpPower"] = { Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end, Description = "Reset jump power" }
Commands["Gravity"] = { Args = "Value", Action = function(v) Workspace.Gravity = tonumber(v) or 196.2 end, Description = "Set gravity" }
Commands["ResetGravity"] = { Action = function() Workspace.Gravity = 196.2 end, Description = "Reset gravity" }

Commands["Infjump"] = {
    Action = function() 
        ActiveStates.Infjump = true
        local debounce = false
        UserInputService.JumpRequest:Connect(function() 
            if ActiveStates.Infjump and not debounce then 
                debounce = true
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.2)
                debounce = false
            end 
        end)
    end,
    Description = "Enable infinite jump (0.2s cooldown)"
}
Commands["unInfjump"] = { Action = function() ActiveStates.Infjump = false end, Description = "Disable infinite jump" }

Commands["Flyjump"] = {
    Action = function()
        ActiveStates.Flyjump = true
        UserInputService.JumpRequest:Connect(function()
            if ActiveStates.Flyjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end,
    Description = "Infinite jump no cooldown"
}
Commands["unFlyjump"] = { Action = function() ActiveStates.Flyjump = false end, Description = "Disable fly jump" }

Commands["Noclip"] = {
    Action = function() 
        ActiveStates.Noclip = true
        RunService.Stepped:Connect(function() 
            if ActiveStates.Noclip and LocalPlayer.Character then 
                for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end 
            end 
        end)
    end,
    Description = "Enable Noclip"
}
Commands["Clip"] = { Action = function() ActiveStates.Noclip = false end, Description = "Disable Noclip" }
Commands["Freeze"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze character" }
Commands["unFreeze"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = false end, Description = "Unfreeze character" }
Commands["Sit"] = { Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Force sit" }
Commands["Jump"] = { Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump once" }

-- ==========================================
-- الاستهداف والانتقال
-- ==========================================
Commands["Goto"] = { Args = "Player Name", Action = function(name)
    local targets = ResolveTarget(name)
    if targets[1] and targets[1].Character then LocalPlayer.Character:MoveTo(targets[1].Character.HumanoidRootPart.Position) end
end, Description = "Teleport to player" }

Commands["Bring"] = { Args = "Player Name", Action = function(name)
    local targets = ResolveTarget(name)
    for _, t in pairs(targets) do
        if t.Character and LocalPlayer.Character then t.Character:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position) end
    end
end, Description = "Bring player" }

Commands["ClickTp"] = { Action = function()
    ActiveStates.ClickTp = not ActiveStates.ClickTp
    local Mouse = LocalPlayer:GetMouse()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if ActiveStates.ClickTp and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if Mouse.Hit then LocalPlayer.Character:MoveTo(Mouse.Hit.p) end
        end
    end)
end, Description = "Toggle ClickTp" }

-- ==========================================
-- الـ ESP (Touch, Click, Proximity)
-- ==========================================
Commands["TouchEsp"] = { Action = function()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent:IsA("BasePart") then CreateESP(v.Parent, Color3.new(0, 1, 0), "KyleTouchESP") end
    end
end, Description = "Green ESP on Touch interests" }
Commands["unTouchEsp"] = { Action = function() RemoveESP("KyleTouchESP") end, Description = "Remove Touch ESP" }

Commands["ClickEsp"] = { Action = function()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ClickDetector") and v.Parent and v.Parent:IsA("BasePart") then CreateESP(v.Parent, Color3.new(1, 0, 0), "KyleClickESP") end
    end
end, Description = "Red ESP on ClickDetectors" }
Commands["unClickEsp"] = { Action = function() RemoveESP("KyleClickESP") end, Description = "Remove Click ESP" }

Commands["ProxiEsp"] = { Action = function()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then CreateESP(v.Parent, Color3.new(0, 0, 1), "KyleProxiESP") end
    end
end, Description = "Blue ESP on ProximityPrompts" }
Commands["unProxiEsp"] = { Action = function() RemoveESP("KyleProxiESP") end, Description = "Remove Proximity ESP" }

-- ==========================================
-- الشخصية والبيئة
-- ==========================================
Commands["Invisible"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end, Description = "Make character invisible" }
Commands["Visible"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end, Description = "Make character visible" }
Commands["Nohats"] = { Action = function() for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end, Description = "Remove all accessories" }
Commands["Fullbright"] = { Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Enable Fullbright" }
Commands["Night"] = { Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set night" }
Commands["Day"] = { Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set day" }
Commands["Time"] = { Args = "Time (00:00:00)", Action = function(t) Lighting.TimeOfDay = tostring(t) end, Description = "Set custom time" }
Commands["Nofog"] = { Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog" }

-- ==========================================
-- الأدوات والمعلومات (مع إعادة cc)
-- ==========================================
Commands["cc"] = {
    Action = function()
        local count = 0
        for _ in pairs(Commands) do count = count + 1 end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Kyle Admin", Text = "Commands Loaded: " .. count, Icon = "rbxassetid://103568481311084"})
    end,
    Description = "Show commands count"
}
Commands["Jobid"] = { Action = function() setclipboard(game.JobId) end, Description = "Copy JobId" }
Commands["JoinJobid"] = { Args = "JobId", Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end, Description = "Join JobId" }
Commands["CopyName"] = { Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName" }
Commands["CopyUsername"] = { Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Username" }
Commands["Rejoin"] = { Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server" }
Commands["Exit"] = { Action = function() game:Shutdown() end, Description = "Exit game" }
Commands["Kick"] = { Args = "Reason", Action = function(r) LocalPlayer:Kick(r or "Disconnected by Kyle Admin") end, Description = "Kick self" }

-- ==========================================
-- واجهة الأوامر Cmds 
-- ==========================================
Commands["Cmds"] = {
    Action = function()
        if game.CoreGui:FindFirstChild("KyleCmdsUI") then game.CoreGui.KyleCmdsUI:Destroy() end
        local SG = Instance.new("ScreenGui", game.CoreGui)
        SG.Name = "KyleCmdsUI"

        local Main = Instance.new("Frame", SG)
        Main.Size = UDim2.new(0, 400, 0, 0); Main.Position = UDim2.new(0.5, -200, 0.5, -175)
        Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.ClipsDescendants = true
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 350)}):Play()

        local Topbar = Instance.new("Frame", Main)
        Topbar.Size = UDim2.new(1, 0, 0, 40); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 8)
        
        local Title = Instance.new("TextLabel", Topbar)
        Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1; Title.Text = "Kyle [ Admin Commands ]"
        Title.TextColor3 = Color3.fromRGB(255, 140, 0); Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

        local CloseBtn = Instance.new("TextButton", Topbar)
        CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

        local MinBtn = Instance.new("TextButton", Topbar)
        MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5)
        MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 14
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

        local SearchBox = Instance.new("TextBox", Main)
        SearchBox.Size = UDim2.new(0.55, 0, 0, 30); SearchBox.Position = UDim2.new(0, 10, 0, 50)
        SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SearchBox.TextColor3 = Color3.new(1,1,1)
        SearchBox.PlaceholderText = "Search Command..."
        SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 13
        Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

        local cmdTotal = 0 for _ in pairs(Commands) do cmdTotal = cmdTotal + 1 end
        local CountLbl = Instance.new("TextLabel", Main)
        CountLbl.Size = UDim2.new(0.4, -20, 0, 30); CountLbl.Position = UDim2.new(0.6, 10, 0, 50)
        CountLbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CountLbl.TextColor3 = Color3.fromRGB(255, 140, 0)
        CountLbl.Text = "Commands: " .. cmdTotal; CountLbl.Font = Enum.Font.GothamBold; CountLbl.TextSize = 13
        Instance.new("UICorner", CountLbl).CornerRadius = UDim.new(0, 6)

        local Scroll = Instance.new("ScrollingFrame", Main)
        Scroll.Size = UDim2.new(1, -20, 1, -100); Scroll.Position = UDim2.new(0, 10, 0, 90)
        Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 4
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local UIList = Instance.new("UIListLayout", Scroll)
        UIList.Padding = UDim.new(0, 5); UIList.SortOrder = Enum.SortOrder.Name

        local isMinimized, OriginalSize = false, UDim2.new(0, 400, 0, 350)
        
        CloseBtn.MouseButton1Click:Connect(function()
            local tw = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            tw:Play(); tw.Completed:Wait(); SG:Destroy()
        end)

        MinBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            if isMinimized then
                TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 40)}):Play()
                Title.Text = "Cmds"; Title.TextColor3 = Color3.new(1,1,1)
                Scroll.Visible = false; SearchBox.Visible = false; CountLbl.Visible = false
            else
                TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = OriginalSize}):Play()
                Title.Text = "Kyle [ Admin Commands ]"; Title.TextColor3 = Color3.fromRGB(255, 140, 0)
                Scroll.Visible = true; SearchBox.Visible = true; CountLbl.Visible = true
            end
        end)

        local function Populate(filter)
            for _, v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for cmdName, cmdData in pairs(Commands) do
                if not filter or string.find(string.lower(cmdName), string.lower(filter)) then
                    local Item = Instance.new("Frame", Scroll)
                    Item.Name = cmdName; Item.Size = UDim2.new(1, -10, 0, 40)
                    Item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 6)

                    local Lbl = Instance.new("TextLabel", Item)
                    Lbl.Size = UDim2.new(0.4, 0, 1, 0); Lbl.Position = UDim2.new(0, 10, 0, 0)
                    Lbl.BackgroundTransparency = 1; Lbl.Text = cmdName
                    Lbl.TextColor3 = Color3.new(1,1,1); Lbl.Font = Enum.Font.GothamSemibold
                    Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left

                    local RunBtn = Instance.new("TextButton", Item)
                    RunBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
                    RunBtn.Text = "Run"; RunBtn.TextColor3 = Color3.new(1,1,1)
                    RunBtn.Font = Enum.Font.GothamBold; RunBtn.TextSize = 12
                    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 4)

                    -- التحقق إذا كان الأمر يتطلب مدخلات (TextBox)
                    if cmdData.Args then
                        RunBtn.Size = UDim2.new(0, 60, 0, 30); RunBtn.Position = UDim2.new(1, -70, 0, 5)
                        
                        local ArgBox = Instance.new("TextBox", Item)
                        ArgBox.Size = UDim2.new(0, 90, 0, 30); ArgBox.Position = UDim2.new(1, -170, 0, 5)
                        ArgBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20); ArgBox.TextColor3 = Color3.new(1,1,1)
                        ArgBox.PlaceholderText = cmdData.Args -- كتابة نوع الطلب (Player Name, Value, etc)
                        ArgBox.Font = Enum.Font.Gotham; ArgBox.TextSize = 12
                        Instance.new("UICorner", ArgBox).CornerRadius = UDim.new(0, 4)

                        RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action(ArgBox.Text) end) end)
                    else
                        -- بدون TextBox، الزر يأخذ مساحة مختلفة أو نفس المكان
                        RunBtn.Size = UDim2.new(0, 60, 0, 30); RunBtn.Position = UDim2.new(1, -70, 0, 5)
                        RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action() end) end)
                    end
                end
            end
        end

        Populate()
        SearchBox.Changed:Connect(function(prop) if prop == "Text" then Populate(SearchBox.Text) end end)
    end,
    Description = "Open Commands UI"
}

return Commands
