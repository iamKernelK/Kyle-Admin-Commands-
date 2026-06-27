local CommandsUrl="https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"
local CmdsList=loadstring(game:HttpGet(CommandsUrl))()
local Guis={}
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local CoreGui=game:GetService("CoreGui")
function Guis.CreateCmdsUI()
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="KyleGuis"; ScreenGui.ResetOnSpawn=false
pcall(function() ScreenGui.Parent=CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
local Main=Instance.new("Frame",ScreenGui)
Main.Name="Main"; Main.Size=UDim2.new(0,360,0,300); Main.Position=UDim2.new(0.5,-180,0.5,-150)
Main.BackgroundColor3=Color3.fromRGB(255,255,255); Main.BackgroundTransparency=0.85
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local MainStroke=Instance.new("UIStroke",Main)
MainStroke.Color=Color3.fromRGB(255,255,255); MainStroke.Transparency=0.6; MainStroke.Thickness=1.5
local Gradient=Instance.new("UIGradient",Main)
Gradient.Rotation=45; Gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.15),NumberSequenceKeypoint.new(1,0)})
local Title=Instance.new("TextLabel",Main)
Title.Size=UDim2.new(0.6,0,0,30); Title.Position=UDim2.new(0,15,0,8)
Title.BackgroundTransparency=1; Title.Text="Kyle Admin"; Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold; Title.TextSize=16; Title.TextXAlignment=Enum.TextXAlignment.Left
local Close=Instance.new("TextButton",Main)
Close.Size=UDim2.new(0,28,0,28); Close.Position=UDim2.new(1,-38,0,8)
Close.BackgroundColor3=Color3.fromRGB(255,255,255); Close.BackgroundTransparency=0.9
Close.Text="X"; Close.TextColor3=Color3.fromRGB(220,220,220); Close.Font=Enum.Font.GothamBold; Close.TextSize=12
Instance.new("UICorner",Close).CornerRadius=UDim.new(0,6)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local Minimize=Instance.new("TextButton",Main)
Minimize.Size=UDim2.new(0,28,0,28); Minimize.Position=UDim2.new(1,-72,0,8)
Minimize.BackgroundColor3=Color3.fromRGB(255,255,255); Minimize.BackgroundTransparency=0.9
Minimize.Text="-"; Minimize.TextColor3=Color3.fromRGB(220,220,220); Minimize.Font=Enum.Font.GothamBold; Minimize.TextSize=14
Instance.new("UICorner",Minimize).CornerRadius=UDim.new(0,6)
local TopInput=Instance.new("TextBox",Main)
TopInput.Size=UDim2.new(1,-30,0,32); TopInput.Position=UDim2.new(0,15,0,45)
TopInput.BackgroundColor3=Color3.fromRGB(255,255,255); TopInput.BackgroundTransparency=0.88
TopInput.TextColor3=Color3.fromRGB(255,255,255); TopInput.PlaceholderText="Search Commands..."
TopInput.PlaceholderColor3=Color3.fromRGB(200,200,200)
TopInput.Font=Enum.Font.Gotham; TopInput.TextSize=14
Instance.new("UICorner",TopInput).CornerRadius=UDim.new(0,6)
local InputStroke=Instance.new("UIStroke",TopInput)
InputStroke.Color=Color3.fromRGB(255,255,255); InputStroke.Transparency=0.7
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,-30,1,-95); Scroll.Position=UDim2.new(0,15,0,85)
Scroll.BackgroundTransparency=1; Scroll.CanvasSize=UDim2.new(0,0,0,0); Scroll.ScrollBarThickness=3
Scroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255); Scroll.ScrollBarImageTransparency=0.6
local Layout=Instance.new("UIListLayout",Scroll)
Layout.SortOrder=Enum.SortOrder.LayoutOrder; Layout.Padding=UDim.new(0,8)
local minState=false
Minimize.MouseButton1Click:Connect(function() minState=not minState; Scroll.Visible=not minState; TopInput.Visible=not minState; Main.Size=minState and UDim2.new(0,360,0,45) or UDim2.new(0,360,0,300) end)
local function Populate(filter)
for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
for cmdName,cmdData in pairs(CmdsList) do
if not filter or string.find(string.lower(cmdName),string.lower(filter)) then
local Item=Instance.new("Frame",Scroll)
Item.Size=UDim2.new(1,-5,0,40)
Item.BackgroundColor3=Color3.fromRGB(255,255,255); Item.BackgroundTransparency=0.95
Instance.new("UICorner",Item).CornerRadius=UDim.new(0,6)
local ItemStroke=Instance.new("UIStroke",Item)
ItemStroke.Color=Color3.fromRGB(255,255,255); ItemStroke.Transparency=0.8
local Lbl=Instance.new("TextLabel",Item)
Lbl.Size=UDim2.new(0.4,0,1,0); Lbl.Position=UDim2.new(0,12,0,0)
Lbl.BackgroundTransparency=1; Lbl.Text=cmdName; Lbl.TextColor3=Color3.fromRGB(245,245,245)
Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=14; Lbl.TextXAlignment=Enum.TextXAlignment.Left
local RunBtn=Instance.new("ImageButton",Item)
RunBtn.Size=UDim2.new(0,26,0,26); RunBtn.Position=UDim2.new(1,-36,0,7)
RunBtn.BackgroundTransparency=1; RunBtn.Image="rbxassetid://12008449041"; RunBtn.ImageColor3=Color3.fromRGB(255,255,255)
if cmdData.Args then
local ArgBox=Instance.new("TextBox",Item)
ArgBox.Size=UDim2.new(0,90,0,28); ArgBox.Position=UDim2.new(1,-135,0,6)
ArgBox.BackgroundColor3=Color3.fromRGB(255,255,255); ArgBox.BackgroundTransparency=0.9
ArgBox.TextColor3=Color3.fromRGB(255,255,255); ArgBox.PlaceholderText=cmdData.Args
ArgBox.PlaceholderColor3=Color3.fromRGB(190,190,190)
ArgBox.Font=Enum.Font.Gotham; ArgBox.TextSize=12
Instance.new("UICorner",ArgBox).CornerRadius=UDim.new(0,4)
local BoxStroke=Instance.new("UIStroke",ArgBox)
BoxStroke.Color=Color3.fromRGB(255,255,255); BoxStroke.Transparency=0.7
RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action(ArgBox.Text) end) end)
else
RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action() end) end)
end
end
end
Scroll.CanvasSize=UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+15)
end
TopInput:GetPropertyChangedSignal("Text"):Connect(function() Populate(TopInput.Text) end)
Populate()
return ScreenGui
end
return Guis

