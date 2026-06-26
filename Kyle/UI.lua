local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهات القديمة
if CoreGui:FindFirstChild("KyleAdminUI") then CoreGui.KyleAdminUI:Destroy() end
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KyleAdminUI") then LocalPlayer.PlayerGui.KyleAdminUI:Destroy() end

-- ==========================================
-- 1. جلب الأوامر من الرابط (بدون أي أوامر مضافة يدوياً)
-- ==========================================
local Commands = {}
local url = "https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(url))()
end)

if success and type(result) == "table" then
    Commands = result
else
    warn("[Kyle Admin]: Failed to load Commands.lua from Github. Please check the URL.")
end

-- ==========================================
-- 2. بناء الواجهة الاحترافية الراقية
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyleAdminUI"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- زر التبديل المصغر (ky)
local Ky = Instance.new("TextButton")
Ky.Name = "Ky"
Ky.Size = UDim2.new(0, 38, 0, 38)
Ky.Position = UDim2.new(0.5, 0, 0, 40)
Ky.AnchorPoint = Vector2.new(0.5, 0.5)
Ky.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
Ky.Text = "ky"
Ky.Font = Enum.Font.GothamBold
Ky.TextColor3 = Color3.fromRGB(255, 255, 255)
Ky.TextSize = 14
Ky.Parent = ScreenGui

local KyCorner = Instance.new("UICorner")
KyCorner.CornerRadius = UDim.new(1, 0)
KyCorner.Parent = Ky

-- الحاوية الرئيسية
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 380, 0, 280)
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = true 
Container.Parent = ScreenGui

-- حقل الإدخال TextBox
local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Size = UDim2.new(0.92, 0, 0, 42)
Input.Position = UDim2.new(0.5, 0, 1.5, 0) 
Input.AnchorPoint = Vector2.new(0.5, 1)
Input.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
Input.BackgroundTransparency = 0.05
Input.TextColor3 = Color3.fromRGB(255, 255, 255) 
Input.Text = "" 
Input.PlaceholderText = "Type a command here..." 
Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 105)
Input.Font = Enum.Font.GothamMedium
Input.TextSize = 14
Input.ClearTextOnFocus = false
Input.Parent = Container

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = Input

-- قائمة عرض الأوامر
local CmdList = Instance.new("ScrollingFrame")
CmdList.Size = UDim2.new(0.92, 0, 1, -62)
CmdList.Position = UDim2.new(0.5, 0, -1, 0) 
CmdList.AnchorPoint = Vector2.new(0.5, 0)
CmdList.BackgroundTransparency = 1
CmdList.ScrollBarThickness = 0 
CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
CmdList.Parent = Container

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ListLayout.Parent = CmdList

-- ==========================================
-- 3. نظام عرض الأوامر والبحث الذكي الفوري
-- ==========================================
local function UpdateList(filter)
    for _, child in pairs(CmdList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    filter = filter or ""

    for cmdName, cmdData in pairs(Commands) do
        if filter == "" or string.find(string.lower(cmdName), string.lower(filter)) then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, 0, 0, 36)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            ItemFrame.BackgroundTransparency = 0.15
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = CmdList
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 8)
            ItemCorner.Parent = ItemFrame

            local ItemText = Instance.new("TextLabel")
            ItemText.Size = UDim2.new(1, -20, 1, 0)
            ItemText.Position = UDim2.new(0, 12, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.RichText = true
            ItemText.Text = "<font color='#FF8C00'><b>" .. string.lower(cmdName) .. "</b></font>  <font color='#B0B0B5'>" .. (cmdData.Description or "") .. "</font>"
            ItemText.TextColor3 = Color3.fromRGB(255, 255, 255)
            ItemText.Font = Enum.Font.Gotham
            ItemText.TextSize = 13
            ItemText.TextXAlignment = Enum.TextXAlignment.Left
            ItemText.Parent = ItemFrame

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = ItemFrame

            ClickBtn.MouseEnter:Connect(function()
                TweenService:Create(ItemFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(36, 36, 44),
                    Size = UDim2.new(1, 4, 0, 36)
                }):Play()
            end)
            ClickBtn.MouseLeave:Connect(function()
                TweenService:Create(ItemFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(28, 28, 34),
                    Size = UDim2.new(1, 0, 0, 36)
                }):Play()
            end)

            ClickBtn.MouseButton1Click:Connect(function()
                Input.Text = string.lower(cmdName) .. " "
                Input:CaptureFocus()
                task.wait()
                Input.CursorPosition = #Input.Text + 1
            end)

            count = count + 1
        end
    end
    CmdList.CanvasSize = UDim2.new(0, 0, 0, count * 42)
end

Input:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateList(Input.Text)
end)

Input.FocusLost:Connect(function(enterPressed)
    if enterPressed and Input.Text ~= "" then
        local inputText = string.lower(Input.Text):match("^%s*(.-)%s*$")
        local args = string.split(inputText, " ")
        local cmdName = table.remove(args, 1)

        for name, data in pairs(Commands) do
            if string.lower(name) == cmdName then
                pcall(function()
                    data.Action(unpack(args))
                end)
                Input.Text = ""
                UpdateList("")
                break
            end
        end
    end
end)

-- ==========================================
-- 4. نظام الحركة والتحكم (الفتح والإغلاق)
-- ==========================================
local isOpen = false
local openTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

local function openMenu()
    isOpen = true
    Input.Text = ""
    UpdateList("")
    Input:CaptureFocus()
    TweenService:Create(Input, openTweenInfo, {Position = UDim2.new(0.5, 0, 1, -8)}):Play()
    TweenService:Create(CmdList, openTweenInfo, {Position = UDim2.new(0.5, 0, 0, 4)}):Play()
end

local function closeMenu()
    isOpen = false
    Input:ReleaseFocus()
    TweenService:Create(Input, closeTweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
    TweenService:Create(CmdList, closeTweenInfo, {Position = UDim2.new(0.5, 0, -1, 0)}):Play()
end

-- ==========================================
-- 5. حساس الإغلاق الذكي عند الضغط بالخارج
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isOpen then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local objects = ScreenGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
        
        local clickedInside = false
        for _, obj in pairs(objects) do
            if obj:IsDescendantOf(Container) or obj == Ky then
                clickedInside = true
                break
            end
        end
        
        if not clickedInside then
            closeMenu()
        end
    end
end)

-- ==========================================
-- 6. التحكم والتفاعل الخاص بزر الـ ky
-- ==========================================
local isDragging = false
local hasMoved = false
local dragStartPos = nil
local startGuiPos = nil

Ky.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        hasMoved = false
        dragStartPos = input.Position
        startGuiPos = Ky.Position
        TweenService:Create(Ky, TweenInfo.new(0.1), {Size = UDim2.new(0, 34, 0, 34)}):Play()
    end
end)

Ky.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        if delta.Magnitude > 4 then 
            hasMoved = true 
        end
        if hasMoved then
            TweenService:Create(Ky, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(startGuiPos.X.Scale, startGuiPos.X.Offset + delta.X, startGuiPos.Y.Scale, startGuiPos.Y.Offset + delta.Y)
            }):Play()
        end
    end
end)

Ky.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        TweenService:Create(Ky, TweenInfo.new(0.1), {Size = UDim2.new(0, 38, 0, 38)}):Play()
        
        if not hasMoved then
            if isOpen then
                closeMenu()
            else
                openMenu()
            end
        end
    end
end)

Ky.MouseEnter:Connect(function()
    TweenService:Create(Ky, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 160, 20)}):Play()
end)
Ky.MouseLeave:Connect(function()
    TweenService:Create(Ky, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 140, 0)}):Play()
end)
