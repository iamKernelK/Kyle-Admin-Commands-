local CommandsUrl="https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"
local CmdsList=loadstring(game:HttpGet(CommandsUrl))()
local Guis={}
local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
function Guis.CreateCmdsUI()
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="KyleGuis"; ScreenGui.ResetOnSpawn=false
pcall(function() ScreenGui.Parent=CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
local Main=Instance.new("Frame",ScreenGui)
Main.Name="Main"; Main.Size=UDim2.new(0,380,0,320); Main.Position=UDim2.new(0.5,-190,0.5,-160)
Main.BackgroundColor3=Color3.fromRGB(20,20,20)
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,8)
local MainStroke=Instance.new("UIStroke",Main)
MainStroke.Color=Color3.fromRGB(255,140,0); MainStroke.Thickness=1.5
local Title=Instance.new("TextLabel",Main)
Title.Size=UDim2.new(0.6,0,0,30); Title.Position=UDim2.new(0,12,0,10)
Title.BackgroundTransparency=1; Title.Text="Kyle [ Admin Commands ]"; Title.TextColor3=Color3.fromRGB(255,140,0)
Title.Font=Enum.Font.GothamBold; Title.TextSize=15; Title.TextXAlignment=Enum.TextXAlignment.Left
local Close=Instance.new("TextButton",Main)
Close.Size=UDim2.new(0,28,0,28); Close.Position=UDim2.new(1,-40,0,10)
Close.BackgroundColor3=Color3.fromRGB(35,35,35); Close.Text="X"
Close.TextColor3=Color3.fromRGB(255,140,0); Close.Font=Enum.Font.GothamBold; Close.TextSize=13
Instance.new("UICorner",Close).CornerRadius=UDim.new(0,6)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local Minimize=Instance.new("TextButton",Main)
Minimize.Size=UDim2.new(0,28,0,28); Minimize.Position=UDim2.new(1,-75,0,10)
Minimize.BackgroundColor3=Color3.fromRGB(35,35,35); Minimize.Text="-"
Minimize.TextColor3=Color3.fromRGB(255,140,0); Minimize.Font=Enum.Font.GothamBold; Minimize.TextSize=15
Instance.new("UICorner",Minimize).CornerRadius=UDim.new(0,6)
local TopInput=Instance.new("TextBox",Main)
TopInput.Size=UDim2.new(1,-24,0,34); TopInput.Position=UDim2.new(0,12,0,48)
TopInput.BackgroundColor3=Color3.fromRGB(30,30,30); TopInput.TextColor3=Color3.fromRGB(255,255,255)
TopInput.PlaceholderText="Search Commands..."; TopInput.PlaceholderColor3=Color3.fromRGB(150,150,150)
TopInput.Font=Enum.Font.Gotham; TopInput.TextSize=13
Instance.new("UICorner",TopInput).CornerRadius=UDim.new(0,6)
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,-24,1,-100); Scroll.Position=UDim2.new(0,12,0,90)
Scroll.BackgroundTransparency=1; Scroll.CanvasSize=UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness=4; Scroll.ScrollBarImageColor3=Color3.fromRGB(255,140,0)
local Layout=Instance.new("UIListLayout",Scroll)
Layout.SortOrder=Enum.SortOrder.LayoutOrder; Layout.Padding=UDim.new(0,6)
local minState=false
Minimize.MouseButton1Click:Connect(function() minState=not minState; Scroll.Visible=not minState; TopInput.Visible=not minState; Main.Size=minState and UDim2.new(0,380,0,48) or UDim2.new(0,380,0,320) end)
local function Populate(filter)
for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
for cmdName,cmdData in pairs(CmdsList) do
if not filter or string.find(string.lower(cmdName),string.lower(filter)) then
local Item=Instance.new("Frame",Scroll)
Item.Size=UDim2.new(1,-10,0,40); Item.BackgroundColor3=Color3.fromRGB(28,28,28)
Instance.new("UICorner",Item).CornerRadius=UDim.new(0,6)
local Lbl=Instance.new("TextLabel",Item)
Lbl.Size=UDim2.new(0.4,0,1,0); Lbl.Position=UDim2.new(0,10,0,0)
Lbl.BackgroundTransparency=1; Lbl.Text=cmdName; Lbl.TextColor3=Color3.fromRGB(240,240,240)
Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=14; Lbl.TextXAlignment=Enum.TextXAlignment.Left
local RunBtn=Instance.new("ImageButton",Item)
RunBtn.Size=UDim2.new(0,28,0,28); RunBtn.Position=UDim2.new(1,-38,0,6)
RunBtn.BackgroundTransparency=1; RunBtn.Image="rbxassetid://12008449041"
RunBtn.ImageColor3=Color3.fromRGB(255,140,0)
if cmdData.Args then
local ArgBox=Instance.new("TextBox",Item)
ArgBox.Size=UDim2.new(0,100,0,28); ArgBox.Position=UDim2.new(1,-145,0,6)
ArgBox.BackgroundColor3=Color3.fromRGB(40,40,40); ArgBox.TextColor3=Color3.fromRGB(255,255,255)
ArgBox.PlaceholderText=cmdData.Args; ArgBox.PlaceholderColor3=Color3.fromRGB(170,170,170)
ArgBox.Font=Enum.Font.Gotham; ArgBox.TextSize=12; ArgBox.TextTruncate=Enum.TextTruncate.AtEnd
Instance.new("UICorner",ArgBox).CornerRadius=UDim.new(0,4)
local BoxStroke=Instance.new("UIStroke",ArgBox)
BoxStroke.Color=Color3.fromRGB(255,140,0); BoxStroke.Transparency=0.5
RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action(ArgBox.Text) end) end)
else
RunBtn.MouseButton1Click:Connect(function() pcall(function() cmdData.Action() end) end)
end
end
end
Scroll.CanvasSize=UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+10)
end
TopInput:GetPropertyChangedSignal("Text"):Connect(function() Populate(TopInput.Text) end)
Populate()
return ScreenGui
end
return Guis
