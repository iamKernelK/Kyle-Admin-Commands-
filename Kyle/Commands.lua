local Commands = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local ActiveStates = {}

local function setclipboard(text)
    if setclipboard then setclipboard(text) end
end

-- [ User Interface Setup for Macros & Fly ] --
local MainUI = Instance.new("ScreenGui", CoreGui)
MainUI.Name = "MacroUI"
local BtnFrame = Instance.new("Frame", MainUI)
BtnFrame.Size = UDim2.new(0, 150, 0, 400); BtnFrame.Position = UDim2.new(0, 10, 0, 100); BtnFrame.BackgroundTransparency = 1
local UIList = Instance.new("UIListLayout", BtnFrame); UIList.Padding = UDim.new(0, 5)

local function CreateMacroButton(name, cmd1, cmd2)
    local btn = Instance.new("TextButton", BtnFrame)
    btn.Size = UDim2.new(1, 0, 0, 30); btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1,1,1)
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled; local cmd = toggled and cmd1 or cmd2
        if Commands[cmd] then Commands[cmd].Action() end
    end)
    return btn
end

local FlyBtn
_G.PrevWalkSpeed = 16
_G.SavedPos = CFrame.new(0,50,0)

-- [ 150 Commands List ] --

Commands["Speed"] = { Action = function(v) _G.PrevWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed; LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end, Description = "Change walk speed" }
Commands["Calc"] = { Action = function(e) local s, r = pcall(function() return loadstring("return " .. e)() end) game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Calculator", Text = s and tostring(r) or "Error"}) end, Description = "Math calculator" }
Commands["unRun"] = { Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = _G.PrevWalkSpeed or 16 end, Description = "Revert to previous speed" }
Commands["ResetSpeed"] = { Action = function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end, Description = "Reset speed" }
Commands["Jumppower"] = { Action = function(v) LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end, Description = "Change jump power" }
Commands["ResetJumpPower"] = { Action = function() LocalPlayer.Character.Humanoid.JumpPower = 50 end, Description = "Reset jump power" }
Commands["Infjump"] = { Action = function() ActiveStates.Infjump = true; UserInputService.JumpRequest:Connect(function() if ActiveStates.Infjump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end) end, Description = "Enable infinite jump" }
Commands["unInfjump"] = { Action = function() ActiveStates.Infjump = false end, Description = "Disable infinite jump" }
Commands["Noclip"] = { Action = function() ActiveStates.Noclip = true; RunService.Stepped:Connect(function() if ActiveStates.Noclip and LocalPlayer.Character then for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) end, Description = "Enable Noclip" }
-- Essential Utilities & Info
Commands["Jobid"] = {Action = function() setclipboard(game.JobId) end, Description = "Copy JobId"}
Commands["PlaceId"] = {Action = function() setclipboard(tostring(game.PlaceId)) end, Description = "Copy PlaceId"}
Commands["Name"] = {Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Name"}
Commands["DisplayName"] = {Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName"}
Commands["Fps"] = {Action = function() print(workspace:GetRealPhysicsFPS()) end, Description = "Show Fps"}
Commands["Ping"] = {Action = function() print(LocalPlayer:GetNetworkPing()) end, Description = "Show Ping"}
Commands["Exit"] = {Action = function() game:Shutdown() end, Description = "Exit game"}
Commands["Rejoin"] = {Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin"}
Commands["ServerHop"] = {Action = function() local Http = game:GetService("HttpService"); local r = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public")); TeleportService:TeleportToPlaceInstance(game.PlaceId, r.data[math.random(1,#r.data)].id) end, Description = "Server Hop"}
Commands["Clear"] = {Action = function() rconsoleclear() end, Description = "Clear console"}

-- God/Character Mods
Commands["God"] = {Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():match("kill") or v.Name:lower():match("lava")) then v.CanTouch = false end end end, Description = "God mode (KillBrick disable)"}
Commands["Fling"] = {Action = function() local b = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); b.AngularVelocity = Vector3.new(9e9,9e9,9e9); b.MaxTorque = Vector3.new(9e9,9e9,9e9) end, Description = "Fling"}
Commands["Unfling"] = {Action = function() for _,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do if v:IsA("BodyAngularVelocity") then v:Destroy() end end end, Description = "Unfling"}
Commands["Spin"] = {Action = function() local b = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); b.AngularVelocity = Vector3.new(0,100,0); b.MaxTorque = Vector3.new(0,9e9,0) end, Description = "Spin"}
Commands["Unspin"] = {Action = function() for _,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do if v:IsA("BodyAngularVelocity") then v:Destroy() end end end, Description = "Unspin"}
Commands["Ghost"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0.5 end end end, Description = "Ghost mode"}
Commands["Unghost"] = {Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 end end end, Description = "Unghost"}
Commands["BigHead"] = {Action = function() LocalPlayer.Character.Head.Size = Vector3.new(3,3,3) end, Description = "Big head"}
Commands["SmallHead"] = {Action = function() LocalPlayer.Character.Head.Size = Vector3.new(0.5,0.5,0.5) end, Description = "Small head"}
Commands["NormalHead"] = {Action = function() LocalPlayer.Character.Head.Size = Vector3.new(1,1,1) end, Description = "Normal head"}

-- Environment/Graphics
Commands["Fullbright"] = {Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1,1,1) end, Description = "Fullbright"}
Commands["LowGfx"] = {Action = function() settings().Rendering.QualityLevel = 1 end, Description = "Low graphics"}
Commands["HighGfx"] = {Action = function() settings().Rendering.QualityLevel = 21 end, Description = "High graphics"}
Commands["NoShadows"] = {Action = function() Lighting.GlobalShadows = false end, Description = "Disable shadows"}
Commands["Shadows"] = {Action = function() Lighting.GlobalShadows = true end, Description = "Enable shadows"}
Commands["Blur"] = {Action = function() Instance.new("BlurEffect", Lighting).Name = "Cust" end, Description = "Add blur"}
Commands["Unblur"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "Cust" then v:Destroy() end end end, Description = "Remove blur"}
Commands["Bloom"] = {Action = function() Instance.new("BloomEffect", Lighting).Name = "Cust" end, Description = "Add bloom"}
Commands["Unbloom"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "Cust" then v:Destroy() end end end, Description = "Remove bloom"}
Commands["Sunrays"] = {Action = function() Instance.new("SunRaysEffect", Lighting).Name = "Cust" end, Description = "Add sunrays"}
Commands["Unsunrays"] = {Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "Cust" then v:Destroy() end end end, Description = "Remove sunrays"}

-- Scripts/Hubs
Commands["Dex"] = {Action = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Dex-Explorer-DPP-73687"))() end, Description = "Load Dex"}
Commands["DarkDex"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end, Description = "Load DarkDex"}
Commands["IY"] = {Action = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end, Description = "Load IY"}
Commands["CmdX"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end, Description = "Load CmdX"}
Commands["SimpleSpy"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() end, Description = "SimpleSpy"}
Commands["Hydroxide"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/1.0.0/Hydroxide.lua"))() end, Description = "Hydroxide"}
Commands["TurtleSpy"] = {Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))() end, Description = "TurtleSpy"}

-- Aliases/Misc
Commands["AntiAfk"] = {Action = function() LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):Button1Down(Vector2.new()) end) end, Description = "Anti AFK"}
Commands["Calc"] = {Action = function(e) print(loadstring("return "..e)()) end, Description = "Calculator"}
Commands["Cc"] = {Action = function() local c=0; for _ in pairs(Commands) do c=c+1 end; print("Commands: "..c) end, Description = "Count commands"}
Commands["Btools"] = {Action = function() Instance.new("HopperBin", LocalPlayer.Backpack).BinType = Enum.BinType.Clone end, Description = "Btools"}
Commands["NoBtools"] = {Action = function() for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do if v:IsA("HopperBin") then v:Destroy() end end end, Description = "No Btools"}
Commands["Clip"] = { Action = function() ActiveStates.Noclip = false end, Description = "Disable Noclip" }
Commands["Freeze"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = true end, Description = "Freeze character" }
Commands["cc"] = { Action = function() local count = 0; for _ in pairs(Commands) do count = count + 1 end; game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Commands Count", Text = "Total: " .. count}) end, Description = "Commands Counter" }
Commands["unFreeze"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.Anchored = false end, Description = "Unfreeze character" }
Commands["Fullbright"] = { Action = function() Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.new(1, 1, 1) end, Description = "Enable Fullbright" }
Commands["Night"] = { Action = function() Lighting.TimeOfDay = "00:00:00" end, Description = "Set night" }
Commands["Day"] = { Action = function() Lighting.TimeOfDay = "14:00:00" end, Description = "Set day" }
Commands["Sit"] = { Action = function() LocalPlayer.Character.Humanoid.Sit = true end, Description = "Force sit" }
Commands["Nofog"] = { Action = function() Lighting.FogEnd = 999999 end, Description = "Remove fog" }
Commands["Time"] = { Action = function(t) Lighting.TimeOfDay = t end, Description = "Set time" }
Commands["Localtime"] = { Action = function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Time", Text = os.date("%I:%M %p")}) end, Description = "Show local time" }
Commands["Exit"] = { Action = function() game:Shutdown() end, Description = "Exit game" }
Commands["Kick"] = { Action = function(r) LocalPlayer:Kick(r or "Disconnected") end, Description = "Kick self" }
Commands["Jump"] = { Action = function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end, Description = "Jump" }
Commands["ClickTp"] = { Action = function() ActiveStates.ClickTp = not ActiveStates.ClickTp; local M = LocalPlayer:GetMouse(); UserInputService.InputBegan:Connect(function(i, gpe) if not gpe and ActiveStates.ClickTp and (i.UserInputType == Enum.UserInputType.MouseButton1) and M.Hit then LocalPlayer.Character:MoveTo(M.Hit.p) end end) end, Description = "Toggle ClickTp" }
Commands["Jobid"] = { Action = function() setclipboard(game.JobId) end, Description = "Copy JobId" }
Commands["JoinJobid"] = { Action = function(id) TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer) end, Description = "Join JobId" }
Commands["CopyName"] = { Action = function() setclipboard(LocalPlayer.DisplayName) end, Description = "Copy DisplayName" }
Commands["CopyUsername"] = { Action = function() setclipboard(LocalPlayer.Name) end, Description = "Copy Username" }
Commands["CopyPlaceId"] = { Action = function() setclipboard(tostring(game.PlaceId)) end, Description = "Copy PlaceId" }
Commands["CopyGameName"] = { Action = function() setclipboard(MarketplaceService:GetProductInfo(game.PlaceId).Name) end, Description = "Copy GameName" }
Commands["Rejoin"] = { Action = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Description = "Rejoin server" }
Commands["FpsBoost"] = { Action = function() local t = workspace:FindFirstChildOfClass("Terrain"); t.WaterWaveSize=0; t.WaterWaveSpeed=0; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end, Description = "Optimize FPS" }
Commands["Invisible"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end, Description = "Invisible" }
Commands["Visible"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency = 0 end end end, Description = "Visible" }
Commands["Goto"] = { Action = function(n) local t = Players:FindFirstChild(n); if t and t.Character then LocalPlayer.Character:MoveTo(t.Character.HumanoidRootPart.Position) end end, Description = "Tp to player" }
Commands["Dex"] = { Action = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Dex-Explorer-DPP-73687"))() end, Description = "Load Dex" }
Commands["DarkDex"] = { Action = function() local l,d=pcall(game.GetObjects,game,"rbxassetid://3567096419"); if not l or type(d[1])~="userdata" then return end local dex=d[1]; if syn and syn.protect_gui then pcall(syn.protect_gui,dex) end; local n=""; for i=1,24 do n=n..string.char(math.random(33,126)) end; dex.Name=n; dex.Parent=CoreGui; local function S(v) task.spawn(setfenv(loadstring(v.Source,"="..v:GetFullName()), setmetatable({script=v}, {__index=getfenv()}))) end; if dex:IsA("LuaSourceContainer") then S(dex) end; for _,v in ipairs(dex:GetDescendants()) do if v:IsA("LuaSourceContainer") then S(v) end end end, Description = "Load DarkDex" }
Commands["TurtleSpy"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))() end, Description = "Load TurtleSpy" }
Commands["ab"] = { Action = function(a,b,c) if not b then local t=string.split(a or ""," "); a,b,c=t[1],t[2],t[3] end; if a and b and c then CreateMacroButton(a,b,c) end end, Description = "Create Macro" }
Commands["AddButton"] = { Action = function(a,b,c) Commands["ab"].Action(a,b,c) end, Description = "Create Macro Alias" }
Commands["StartFly"] = { Action = function() ActiveStates.Flying = true; local c = LocalPlayer.Character; local bg = Instance.new("BodyGyro", c.HumanoidRootPart); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = c.HumanoidRootPart.CFrame; local bv = Instance.new("BodyVelocity", c.HumanoidRootPart); bv.velocity = Vector3.zero; bv.maxForce = Vector3.new(9e9, 9e9, 9e9); RunService.RenderStepped:Connect(function() if not ActiveStates.Flying then bg:Destroy() bv:Destroy() return end; c.Humanoid.PlatformStand = true; bv.velocity = c.Humanoid.MoveDirection * 50; bg.cframe = workspace.CurrentCamera.CFrame end) end, Description = "Core Fly" }
Commands["StopFly"] = { Action = function() ActiveStates.Flying = false; LocalPlayer.Character.Humanoid.PlatformStand = false end, Description = "Core Unfly" }
Commands["Fly"] = { Action = function() if not FlyBtn then FlyBtn = CreateMacroButton("Fly", "StartFly", "StopFly") end; FlyBtn.Visible = true; Commands["StartFly"].Action() end, Description = "Fly & Show UI" }
Commands["Unfly"] = { Action = function() if FlyBtn then FlyBtn.Visible = false end; Commands["StopFly"].Action() end, Description = "Unfly & Hide UI" }
Commands["Btools"] = { Action = function() local h = Instance.new("HopperBin", LocalPlayer.Backpack); h.BinType = Enum.BinType.Clone; Instance.new("HopperBin", LocalPlayer.Backpack).BinType = Enum.BinType.Hammer end, Description = "Give Btools" }
Commands["NoBtools"] = { Action = function() for _,v in pairs(LocalPlayer.Backpack:GetChildren()) do if v:IsA("HopperBin") then v:Destroy() end end end, Description = "Remove Btools" }
Commands["InfiniteYield"] = { Action = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end, Description = "Load IY" }
Commands["CMDX"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))() end, Description = "Load CMD-X" }
Commands["SimpleSpy"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() end, Description = "Load SimpleSpy" }
Commands["RemoteSpy"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/1.0.0/Hydroxide.lua"))() end, Description = "Load Hydroxide" }
Commands["Hydroxide"] = { Action = function() Commands["RemoteSpy"].Action() end, Description = "Alias Hydroxide" }
Commands["UnnamedESP"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"))() end, Description = "Load ESP" }
Commands["F3X"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/F3X-Tool/F3X/master/F3X.lua"))() end, Description = "Load F3X" }
Commands["OwlHub"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))() end, Description = "Load OwlHub" }
Commands["DarkHub"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomScript/DarkHub/master/DarkHub"))() end, Description = "Load DarkHub" }
Commands["HohoHub"] = { Action = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HOHO_H/main/Loading_UI'))() end, Description = "Load HohoHub" }
Commands["MukuroHub"] = { Action = function() loadstring(game:HttpGet"https://raw.githubusercontent.com/xQuartyx/DonateMe/main/ScriptLoader")() end, Description = "Load Mukuro" }
Commands["EzHub"] = { Action = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/debug420/Ez-Industries/master/EzHub.lua"))() end, Description = "Load EzHub" }
Commands["VgHub"] = { Action = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub'))() end, Description = "Load VGHub" }
Commands["Hitbox"] = { Action = function(v) _G.HitboxSize = tonumber(v) or 10; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then p.Character.HumanoidRootPart.Size = Vector3.new(_G.HitboxSize,_G.HitboxSize,_G.HitboxSize) end end end, Description = "Expand Hitboxes" }
Commands["Unhitbox"] = { Action = function() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1) end end end, Description = "Normal Hitboxes" }
Commands["Esp"] = { Action = function() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then local h = Instance.new("Highlight", p.Character); h.FillColor = Color3.new(1,0,0) end end end, Description = "Basic ESP" }
Commands["Unesp"] = { Action = function() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then for _,v in pairs(p.Character:GetChildren()) do if v:IsA("Highlight") then v:Destroy() end end end end end, Description = "Remove ESP" }
Commands["Tracers"] = { Action = function() ActiveStates.Tracers = true; RunService.RenderStepped:Connect(function() if not ActiveStates.Tracers then return end end) end, Description = "Basic Tracers (WIP)" }
Commands["Untracers"] = { Action = function() ActiveStates.Tracers = false end, Description = "Disable Tracers" }
Commands["Aimlock"] = { Action = function() print("Aimlock activated") end, Description = "Aimlock Stub" }
Commands["Unaimlock"] = { Action = function() print("Aimlock deactivated") end, Description = "Unaimlock Stub" }
Commands["Fov"] = { Action = function(v) workspace.CurrentCamera.FieldOfView = tonumber(v) or 120 end, Description = "Set FOV" }
Commands["ResetFov"] = { Action = function() workspace.CurrentCamera.FieldOfView = 70 end, Description = "Reset FOV" }
Commands["Blur"] = { Action = function(v) local b = Instance.new("BlurEffect", Lighting); b.Size = tonumber(v) or 15; b.Name = "CustBlur" end, Description = "Add Blur" }
Commands["Unblur"] = { Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "CustBlur" then v:Destroy() end end end, Description = "Remove Blur" }
Commands["Bloom"] = { Action = function() local b = Instance.new("BloomEffect", Lighting); b.Name = "CustBloom" end, Description = "Add Bloom" }
Commands["Unbloom"] = { Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "CustBloom" then v:Destroy() end end end, Description = "Remove Bloom" }
Commands["Sunrays"] = { Action = function() local s = Instance.new("SunRaysEffect", Lighting); s.Name = "CustSun" end, Description = "Add Sunrays" }
Commands["Unsunrays"] = { Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "CustSun" then v:Destroy() end end end, Description = "Remove Sunrays" }
Commands["ColorCorrection"] = { Action = function() local c = Instance.new("ColorCorrectionEffect", Lighting); c.Name = "CustColor" end, Description = "Add ColorCorrection" }
Commands["UnColorCorrection"] = { Action = function() for _,v in pairs(Lighting:GetChildren()) do if v.Name == "CustColor" then v:Destroy() end end end, Description = "Remove ColorCorrection" }
Commands["Ambient"] = { Action = function(r,g,b) Lighting.Ambient = Color3.fromRGB(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255) end, Description = "Set Ambient" }
Commands["ResetAmbient"] = { Action = function() Lighting.Ambient = Color3.fromRGB(138, 138, 138) end, Description = "Reset Ambient" }
Commands["Gravity"] = { Action = function(v) workspace.Gravity = tonumber(v) or 50 end, Description = "Change Gravity" }
Commands["ResetGravity"] = { Action = function() workspace.Gravity = 196.2 end, Description = "Reset Gravity" }
Commands["ZoomMax"] = { Action = function(v) LocalPlayer.CameraMaxZoomDistance = tonumber(v) or 10000 end, Description = "Set Max Zoom" }
Commands["ZoomMin"] = { Action = function(v) LocalPlayer.CameraMinZoomDistance = tonumber(v) or 0.5 end, Description = "Set Min Zoom" }
Commands["ResetZoom"] = { Action = function() LocalPlayer.CameraMaxZoomDistance = 400; LocalPlayer.CameraMinZoomDistance = 0.5 end, Description = "Reset Zoom" }
Commands["HideUI"] = { Action = function() LocalPlayer.PlayerGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end, Description = "Hide Game UI" }
Commands["ShowUI"] = { Action = function() LocalPlayer.PlayerGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end, Description = "Show Game UI" }
Commands["ClearConsole"] = { Action = function() print(string.rep("\n", 100)) end, Description = "Clear F9 Console" }
Commands["AntiAfk"] = { Action = function() ActiveStates.AntiAfk = true; local bb = game:GetService("VirtualUser"); LocalPlayer.Idled:Connect(function() if ActiveStates.AntiAfk then bb:CaptureController() bb:ClickButton2(Vector2.new()) end end) end, Description = "Enable AntiAFK" }
Commands["UnAntiAfk"] = { Action = function() ActiveStates.AntiAfk = false end, Description = "Disable AntiAFK" }
Commands["ChatSpam"] = { Action = function(m) ActiveStates.Spam = true; task.spawn(function() while ActiveStates.Spam do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(m or "Spam", "All"); task.wait(1) end end) end, Description = "Chat Spam" }
Commands["UnChatSpam"] = { Action = function() ActiveStates.Spam = false end, Description = "Stop Spam" }
Commands["FpsCheck"] = { Action = function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="FPS", Text=tostring(math.floor(workspace:GetRealPhysicsFPS()))}) end, Description = "Check FPS" }
Commands["PingCheck"] = { Action = function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="Ping", Text=tostring(LocalPlayer:GetNetworkPing()*1000).." ms"}) end, Description = "Check Ping" }
Commands["SavePos"] = { Action = function() _G.SavedPos = LocalPlayer.Character.HumanoidRootPart.CFrame end, Description = "Save Position" }
Commands["LoadPos"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.CFrame = _G.SavedPos end, Description = "Load Position" }
Commands["TpUp"] = { Action = function(v) LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, tonumber(v) or 50, 0) end, Description = "TP Up" }
Commands["TpDown"] = { Action = function(v) LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, -(tonumber(v) or 50), 0) end, Description = "TP Down" }
Commands["TpForward"] = { Action = function(v) LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 0, -(tonumber(v) or 50)) end, Description = "TP Forward" }
Commands["TpBackward"] = { Action = function(v) LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 0, tonumber(v) or 50) end, Description = "TP Backward" }
Commands["TpSpawn"] = { Action = function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) end, Description = "TP to Spawn" }
Commands["ServerHop"] = { Action = function() local Http = game:GetService("HttpService"); local TPS = game:GetService("TeleportService"); local Api = "https://games.roblox.com/v1/games/"; local _place = game.PlaceId; local _servers = Api..tostring(_place).."/servers/Public?sortOrder=Asc&limit=100"; local r = Http:JSONDecode(game:HttpGet(_servers)); if r and r.data then TPS:TeleportToPlaceInstance(_place, r.data[math.random(1, #r.data)].id, LocalPlayer) end end, Description = "Hop Server" }
Commands["Fling"] = { Action = function() local b = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); b.AngularVelocity = Vector3.new(9e9, 9e9, 9e9); b.MaxTorque = Vector3.new(9e9, 9e9, 9e9); b.Name = "CustFling" end, Description = "Fling" }
Commands["Unfling"] = { Action = function() for _,v in pairs(LocalPlayer.Character.HumanoidRootPaetChildren()) do if v.Name == "CustFling" then v:Destroy() end end end, Description = "Stop Fling" }
Commands["Spin"] = { Action = function(v) local b = Instance.new("BodyAngularVelocity", LocalPlayer.Character.HumanoidRootPart); b.AngularVelocity = Vector3.new(0, tonumber(v) or 50, 0); b.MaxTorque = Vector3.new(0, 9e9, 0); b.Name = "CustSpin" end, Description = "Spin" }
Commands["Unspin"] = { Action = function() for _,v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do if v.Name == "CustSpin" then v:Destroy() end end end, Description = "Stop Spin" }
Commands["God"] = { Action = function() LocalPlayer.Character.Humanoid.MaxHealth = math.huge; LocalPlayer.Character.Humanoid.Health = math.huge end, Description = "Client Godmode" }
Commands["Ungod"] = { Action = function() LocalPlayer.Character.Humanoid.MaxHealth = 100; LocalPlayer.Character.Humanoid.Health = 100 end, Description = "Remove Godmode" }
Commands["Heal"] = { Action = function() LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth end, Description = "Heal self" }
Commands["Damage"] = { Action = function(v) LocalPlayer.Character.Humanoid.Health -= (tonumber(v) or 10) end, Description = "Damage self" }
Commands["NoTrees"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v.Name:lower():match("tree") then v:Destroy() end end end, Description = "Delete Trees" }
Commands["NoWater"] = { Action = function() workspace.Terrain:Clear() end, Description = "Clear Water/Terrain" }
Commands["Wireframe"] = { Action = function() sethiddenproperty(workspace, "Wireframe", true) end, Description = "Wireframe View" }
Commands["Unwireframe"] = { Action = function() sethiddenproperty(workspace, "Wireframe", false) end, Description = "Disable Wireframe" }
Commands["Xray"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier = 0.5 end end end, Description = "Enable XRay" }
Commands["UnXray"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end end end, Description = "Disable XRay" }
Commands["Ghost"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0.5 end end end, Description = "Ghost mode" }
Commands["Unghost"] = { Action = function() for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency = 0 end end end, Description = "Remove Ghost" }
Commands["Platform"] = { Action = function() local p = Instance.new("Part", workspace); p.Name = "CustPlat"; p.Size = Vector3.new(50,1,50); p.Anchored = true; p.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0,5,0) end, Description = "Spawn Platform" }
Commands["RemovePlatform"] = { Action = function() for _,v in pairs(workspace:GetChildren()) do if v.Name == "CustPlat" then v:Destroy() end end end, Description = "Remove Platform" }
Commands["BigHead"] = { Action = function() local h = LocalPlayer.Character:FindFirstChild("Head"); if h then h.Size = Vector3.new(5,5,5) end end, Description = "Big Head" }
Commands["SmallHead"] = { Action = function() local h = LocalPlayer.Character:FindFirstChild("Head"); if h then h.Size = Vector3.new(0.5,0.5,0.5) end end, Description = "Small Head" }
Commands["NormalHead"] = { Action = function() local h = LocalPlayer.Character:FindFirstChild("Head"); if h then h.Size = Vector3.new(1.2,1,1) end end, Description = "Normal Head" }
Commands["NoShadows"] = { Action = function() Lighting.GlobalShadows = false end, Description = "Disable Shadows" }
Commands["Shadows"] = { Action = function() Lighting.GlobalShadows = true end, Description = "Enable Shadows" }
Commands["Dark"] = { Action = function() Lighting.Ambient = Color3.new(0,0,0); Lighting.OutdoorAmbient = Color3.new(0,0,0) end, Description = "Pitch Black" }
Commands["Light"] = { Action = function() Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1) end, Description = "Max Light" }
Commands["Midnight"] = { Action = function() Lighting.TimeOfDay = "24:00:00" end, Description = "Set Midnight" }
Commands["Noon"] = { Action = function() Lighting.TimeOfDay = "12:00:00" end, Description = "Set Noon" }
Commands["RedAmbient"] = { Action = function() Lighting.Ambient = Color3.new(1,0,0) end, Description = "Red Light" }
Commands["BlueAmbient"] = { Action = function() Lighting.Ambient = Color3.new(0,0,1) end, Description = "Blue Light" }
Commands["GreenAmbient"] = { Action = function() Lighting.Ambient = Color3.new(0,1,0) end, Description = "Green Light" }
Commands["AutoJump"] = { Action = function() ActiveStates.AJump = true; RunService.RenderStepped:Connect(function() if ActiveStates.AJump then LocalPlayer.Character.Humanoid.Jump = true end end) end, Description = "Auto Jump" }
Commands["UnAutoJump"] = { Action = function() ActiveStates.AJump = false end, Description = "Stop Auto Jump" }
Commands["ToggleLeaderboard"] = { Action = function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)) end, Description = "Toggle LB" }
Commands["Day2"] = { Action = function() Commands["Day"].Action() end, Description = "Alias for Day" }
Commands["Night2"] = { Action = function() Commands["Night"].Action() end, Description = "Alias for Night" }
Commands["Rejoin2"] = { Action = function() Commands["Rejoin"].Action() end, Description = "Alias for Rejoin" }
Commands["LowGfx"] = { Action = function() settings().Rendering.QualityLevel = 1 end, Description = "Low Graphics" }
Commands["HighGfx"] = { Action = function() settings().Rendering.QualityLevel = 21 end, Description = "High Graphics" }
Commands["PrintInfo"] = { Action = function() print(LocalPlayer.Name, game.PlaceId, game.JobId) end, Description = "Print Info" }
Commands["CopyPos"] = { Action = function() setclipboard(tostring(LocalPlayer.Character.HumanoidRootPart.Position)) end, Description = "Copy XYZ" }
Commands["CopyRot"] = { Action = function() setclipboard(tostring(LocalPlayer.Character.HumanoidRootPart.Orientation)) end, Description = "Copy Rotation" }
Commands["ThirdPerson"] = { Action = function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end, Description = "Third Person" }
Commands["FirstPerson"] = { Action = function() LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end, Description = "First Person" }
Commands["HideChat"] = { Action = function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end, Description = "Hide Chat" }
Commands["ShowChat"] = { Action = function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end, Description = "Show Chat" }
Commands["Mute"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Sound") then v.Volume = 0 end end end, Description = "Mute Sounds" }
Commands["Unmute"] = { Action = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Sound") then v.Volume = 1 end end end, Description = "Unmute Sounds" }
Commands["Reload"] = { Action = function() local pos = LocalPlayer.Character.HumanoidRootPart.CFrame; LocalPlayer.Character:BreakJoints(); task.wait(5); LocalPlayer.Character.HumanoidRootPart.CFrame = pos end, Description = "Reload Char" }

return Commands
