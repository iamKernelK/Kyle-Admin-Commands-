local CommandsUrl="https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"
local CmdsList=loadstring(game:HttpGet(CommandsUrl))()
local Guis={}

local CoreGui=game:GetService("CoreGui")
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

function Guis.CreateCmdsUI()
    local ScreenGui=Instance.new("ScreenGui")
    ScreenGui.Name="KyleGuis"; ScreenGui.ResetOnSpawn=false
    pcall(function() ScreenGui.Parent=CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end

    -- النافذة الرئيسية (خلفية سوداء مع تأثير زجاجي شفاف)
    local Main=Instance.new("Frame",ScreenGui)
    Main.Name="Main"; Main.Size=UDim2.new(0,380,0,320); Main.Position=UDim2.new(0.5,-190,0.5,-160)
    Main.BackgroundColor3=Color3.fromRGB(0,0,0) 
    Main.BackgroundTransparency=0.25 
    Instance.new("UICorner",Main).CornerRadius=UDim.new(0,8)

    -- إطار النيون السماوي
    local MainStroke=Instance.new("UIStroke",Main)
    MainStroke.Color=Color3.fromRGB(0,255,255); MainStroke.Thickness=1.5

    -- سكريبت التحريك (Draggable)
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Title=Instance.new("TextLabel",Main)
    Title.Size=UDim2.new(0.6,0,0,30); Title.Position=UDim2.new(0,12,0,10)
    Title.BackgroundTransparency=1; Title.Text="Kyle [ Admin Commands ]"; Title.TextColor3=Color3.fromRGB(0,255,255)
    Title.Font=Enum.Font.GothamBold; Title.TextSize=15; Title.TextXAlignment=Enum.TextXAlignment.Left

    local Close=Instance.new("TextButton",Main)
    Close.Size=UDim2.new(0,28,0,28); Close.Position=UDim2.new(1,-40,0,10)
    Close.BackgroundColor3=Color3.fromRGB(15,15,15); Close.Text="X"
    Close.TextColor3=Color3.fromRGB(0,255,255); Close.Font=Enum.Font.GothamBold; Close.TextSize=13
    Instance.new("UICorner",Close).CornerRadius=UDim.new(0,6)
    
    -- أنيميشن زر الإغلاق
    Close.MouseButton1Click:Connect(function()
        TS:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    local Minimize=Instance.new("TextButton",Main)
    Minimize.Size=UDim2.new(0,28,0,28); Minimize.Position=UDim2.new(1,-75,0,10)
    Minimize.BackgroundColor3=Color3.fromRGB(15,15,15); Minimize.Text="-"
    Minimize.TextColor3=Color3.fromRGB(0,255,255); Minimize.Font=Enum.Font.GothamBold; Minimize.TextSize=15
    Instance.new("UICorner",Minimize).CornerRadius=UDim.new(0,6)

    local TopInput=Instance.new("TextBox",Main)
    TopInput.Size=UDim2.new(1,-24,0,34); TopInput.Position=UDim2.new(0,12,0,48)
    TopInput.BackgroundColor3=Color3.fromRGB(15,15,15); TopInput.TextColor3=Color3.fromRGB(255,255,255)
    TopInput.PlaceholderText="Search Commands..."; TopInput.PlaceholderColor3=Color3.fromRGB(100,100,100)
    TopInput.Font=Enum.Font.Gotham; TopInput.TextSize=13
    TopInput.ClearTextOnFocus = false -- إصلاح مشكلة اختفاء النص عند الضغط
    Instance.new("UICorner",TopInput).CornerRadius=UDim.new(0,6)

    local Scroll=Instance.new("ScrollingFrame",Main)
    Scroll.Size=UDim2.new(1,-24,1,-100); Scroll.Position=UDim2.new(0,12,0,90)
    Scroll.BackgroundTransparency=1; Scroll.CanvasSize=UDim2.new(0,0,0,0)
    Scroll.ScrollBarThickness=4; Scroll.ScrollBarImageColor3=Color3.fromRGB(0,255,255)
    Scroll.BorderSizePixel=0

    local Layout=Instance.new("UIListLayout",Scroll)
    Layout.SortOrder=Enum.SortOrder.LayoutOrder; Layout.Padding=UDim.new(0,6)

    -- أنيميشن التصغير (Minimize)
    local minState=false
    Minimize.MouseButton1Click:Connect(function() 
        minState=not minState
        local targetSize = minState and UDim2.new(0,380,0,48) or UDim2.new(0,380,0,320)
        TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        Scroll.Visible=not minState
        TopInput.Visible=not minState
    end)

    local function Populate(filter)
        for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        for cmdName,cmdData in pairs(CmdsList) do
            if not filter or string.find(string.lower(cmdName),string.lower(filter)) then
                local Item=Instance.new("Frame",Scroll)
                Item.Size=UDim2.new(1,-10,0,40); Item.BackgroundColor3=Color3.fromRGB(15,15,15)
                Instance.new("UICorner",Item).CornerRadius=UDim.new(0,6)

                local Lbl=Instance.new("TextLabel",Item)
                Lbl.Size=UDim2.new(0.4,0,1,0); Lbl.Position=UDim2.new(0,10,0,0)
                Lbl.BackgroundTransparency=1; Lbl.Text=cmdName; Lbl.TextColor3=Color3.fromRGB(240,240,240)
                Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=14; Lbl.TextXAlignment=Enum.TextXAlignment.Left

                local RunBtn=Instance.new("ImageButton",Item)
                RunBtn.Size=UDim2.new(0,28,0,28); RunBtn.Position=UDim2.new(1,-38,0,6)
                RunBtn.BackgroundTransparency=1; RunBtn.Image="rbxassetid://12008449041"
                RunBtn.ImageColor3=Color3.fromRGB(0,255,255)

                -- أنيميشن زر التشغيل عند مرور الماوس
                RunBtn.MouseEnter:Connect(function()
                    TS:Create(RunBtn, TweenInfo.new(0.15), {Size = UDim2.new(0,32,0,32), Position = UDim2.new(1,-40,0,4)}):Play()
                end)
                RunBtn.MouseLeave:Connect(function()
                    TS:Create(RunBtn, TweenInfo.new(0.15), {Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-38,0,6)}):Play()
                end)

                if cmdData.Args then
                    local ArgBox=Instance.new("TextBox",Item)
                    ArgBox.Size=UDim2.new(0,100,0,28); ArgBox.Position=UDim2.new(1,-145,0,6)
                    ArgBox.BackgroundColor3=Color3.fromRGB(25,25,25); ArgBox.TextColor3=Color3.fromRGB(255,255,255)
                    ArgBox.PlaceholderText=cmdData.Args; ArgBox.PlaceholderColor3=Color3.fromRGB(100,100,100)
                    ArgBox.Font=Enum.Font.Gotham; ArgBox.TextSize=12; ArgBox.TextTruncate=Enum.TextTruncate.AtEnd
                    ArgBox.ClearTextOnFocus = false -- إصلاح الـ Textbox هنا أيضاً
                    Instance.new("UICorner",ArgBox).CornerRadius=UDim.new(0,4)
                    
                    local BoxStroke=Instance.new("UIStroke",ArgBox)
                    BoxStroke.Color=Color3.fromRGB(0,255,255); BoxStroke.Transparency=0.5

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
    
    -- أنيميشن ظهور الواجهة بالكامل عند الفتح
    Main.Size = UDim2.new(0,0,0,0)
    TS:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,380,0,320)}):Play()

    return ScreenGui
end
return Guis
