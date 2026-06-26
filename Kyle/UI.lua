local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهات السابقة
if CoreGui:FindFirstChild("KyleAdminUI") then CoreGui.KyleAdminUI:Destroy() end
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KyleAdminUI") then LocalPlayer.PlayerGui.KyleAdminUI:Destroy() end

-- ==========================================
-- 1. جلب الأوامر
-- ==========================================
local Commands = {}
local url = "https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(url))()
end)

if success and type(result) == "table" and next(result) ~= nil then
    Commands = result
else
    Commands["Empty"] = {
        Action = function() print("No commands found.") end,
        Description = "Empty limit (0-0)"
    }
end

-- ==========================================
-- 2. إعدادات الألوان والأنيميشن للـ UIStroke
-- ==========================================
local COLOR_CYAN = Color3.fromRGB(0, 255, 255)
local COLOR_BLUE = Color3.fromRGB(0, 100, 255)

local function AnimateStroke(StrokeObject)
    if not StrokeObject or not StrokeObject:IsA("UIStroke") then return end
    
    local tweenInfo = TweenInfo.new(
        2, 
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        -1, 
        true 
    )

    local tween = TweenService:Create(StrokeObject, tweenInfo, {Color = COLOR_BLUE})
    StrokeObject.Color = COLOR_CYAN
    tween:Play()
end

-- ==========================================
-- 3. بناء الواجهة
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyleAdminUI"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- زر Ky (الأيقونة الصغيرة)
local Ky = Instance.new("ImageButton")
Ky.Name = "Ky"
Ky.Size = UDim2.new(0, 45, 0, 45)
Ky.Position = UDim2.new(0.5, 0, 0, 50) -- فوق في المنتصف، نازل قليلاً
Ky.AnchorPoint = Vector2.new(0.5, 0.5)
Ky.Image = "rbxassetid://109474087742061"
Ky.BackgroundTransparency = 1
Ky.Parent = ScreenGui

local KyCorner = Instance.new("UICorner")
KyCorner.CornerRadius = UDim.new(1, 0)
KyCorner.Parent = Ky

-- التأكد 100% من تطبيق UIStroke على الزر
local KyStroke = Instance.new("UIStroke")
KyStroke.Thickness = 2.5
KyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
KyStroke.Parent = Ky

-- تشغيل دالة الأنيميشن على إطار Ky
AnimateStroke(KyStroke)

-- حاوية الإدخال والقائمة (في وسط الشاشة)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 400, 0, 300)
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = true
Container.Parent = ScreenGui

-- الـ Textbox (Input)
local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Size = UDim2.new(0, 0, 0, 45) -- يبدأ بحجم صفر (مخفي)
Input.Position = UDim2.new(0.5, 0, 1, -10) -- في أسفل الحاوية (والتي هي في وسط الشاشة)
Input.AnchorPoint = Vector2.new(0.5, 1)
Input.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Input.BackgroundTransparency = 0.1
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Text = "" -- فارغ تماماً كما طلبت
Input.PlaceholderText = "" -- لا يوجد نص بديل
Input.Font = Enum.Font.GothamMedium
Input.TextSize = 16
Input.ClearTextOnFocus = false
Input.ClipsDescendants = true
Input.Parent = Container

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = Input

local InputStroke = Instance.new("UIStroke")
InputStroke.Thickness = 1.5
InputStroke.Color = COLOR_CYAN
InputStroke.Parent = Input

-- قائمة الأوامر المتراكمة فوق Input
local CmdList = Instance.new("ScrollingFrame")
CmdList.Size = UDim2.new(1, 0, 1, -65) -- تملأ المساحة فوق الـ Input
CmdList.Position = UDim2.new(0.5, 0, 0, 0)
CmdList.AnchorPoint = Vector2.new(0.5, 0)
CmdList.BackgroundTransparency = 1
CmdList.ScrollBarThickness = 0 
CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
CmdList.Parent = Container

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom -- الأوامر تتراكم من الأسفل
ListLayout.Parent = CmdList

-- ==========================================
-- 4. نظام تحديث وعرض الأوامر
-- ==========================================
local function UpdateList(filter)
    for _, child in pairs(CmdList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    for cmdName, cmdData in pairs(Commands) do
        if filter == "" or string.find(string.lower(cmdName), string.lower(filter)) then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, 0, 0, 32)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
            ItemFrame.BackgroundTransparency = 0.35 
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = CmdList
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = ItemFrame

            local ItemText = Instance.new("TextLabel")
            ItemText.Size = UDim2.new(1, -20, 1, 0)
            ItemText.Position = UDim2.new(0, 10, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.Text = string.lower(cmdName) .. " (" .. (cmdData.Description or "") .. ")"
            ItemText.TextColor3 = Color3.fromRGB(230, 230, 230)
            ItemText.Font = Enum.Font.Gotham
            ItemText.TextSize = 14
            ItemText.TextXAlignment = Enum.TextXAlignment.Left
            ItemText.Parent = ItemFrame

            count = count + 1
        end
    end
    CmdList.CanvasSize = UDim2.new(0, 0, 0, count * 37)
end

UpdateList("")

Input:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateList(Input.Text)
end)

-- تنفيذ الأمر
Input.FocusLost:Connect(function(enterPressed)
    if enterPressed and Input.Text ~= "" then
        local inputText = string.lower(Input.Text)
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
-- 5. نظام السحب الاحترافي (Drag System) لـ Ky
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
    end
end)

Ky.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        -- نعتبر أن اللاعب يقوم بالسحب إذا تحرك الماوس مسافة معينة
        if delta.Magnitude > 3 then 
            hasMoved = true 
        end
        
        if hasMoved then
            TweenService:Create(Ky, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(startGuiPos.X.Scale, startGuiPos.X.Offset + delta.X, startGuiPos.Y.Scale, startGuiPos.Y.Offset + delta.Y)
            }):Play()
        end
    end
end)

-- ==========================================
-- 6. الفتح والإغلاق (عند النقر فقط بدون سحب)
-- ==========================================
local isOpen = false
Ky.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        
        -- إذا لم يتم السحب، اعتبره نقرة (Click) وافتح الواجهة
        if not hasMoved then
            isOpen = not isOpen
            if isOpen then
                Input:CaptureFocus()
                TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 45)}):Play()
            else
                TweenService:Create(Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 45)}):Play()
            end
        end
    end
end)
