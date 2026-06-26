local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهات السابقة
if CoreGui:FindFirstChild("KyleAdminUI") then CoreGui.KyleAdminUI:Destroy() end
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KyleAdminUI") then LocalPlayer.PlayerGui.KyleAdminUI:Destroy() end

-- 1. جلب الأوامر الخام (Raw)
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

-- 2. إعدادات الألوان المتدرجة (Blue + Cyan)
local GradientColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),   -- Blue
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))    -- Neon Cyan
})

-- 3. إنشاء الواجهة الأساسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyleAdminUI"
ScreenGui.DisplayOrder = 999
local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- 4. زر التشغيل (صغير واحترافي كما طلبت)
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, 0)
ToggleBtn.AnchorPoint = Vector2.new(0, 0.5)
ToggleBtn.Image = "rbxassetid://109474087742061"
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 1.5
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Transparency = 0.5
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BtnStroke.Parent = ToggleBtn

-- 5. الحاوية الرئيسية للسكربت (شفافة بالكامل)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 450, 0, 300)
Container.Position = UDim2.new(0.5, 0, 0.8, 0)
Container.AnchorPoint = Vector2.new(0.5, 1)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = true
Container.Parent = ScreenGui

-- 6. شريط البحث (التصميم السفلي المتوهج)
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 0, 0, 40) -- يبدأ مغلقاً
SearchBox.Position = UDim2.new(0.5, 0, 1, 0)
SearchBox.AnchorPoint = Vector2.new(0.5, 1)
SearchBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SearchBox.BackgroundTransparency = 0.2
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Kyle Admin Commands..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 15
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Container

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Thickness = 2
SearchStroke.Parent = SearchBox

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = GradientColors
StrokeGradient.Parent = SearchStroke

-- 7. قائمة الأوامر (تتراكم من الأسفل للأعلى مثل Nameless Admin)
local CmdList = Instance.new("ScrollingFrame")
CmdList.Size = UDim2.new(1, 0, 1, -50)
CmdList.Position = UDim2.new(0, 0, 0, 0)
CmdList.BackgroundTransparency = 1
CmdList.ScrollBarThickness = 0 -- إخفاء شريط التمرير لمظهر أنظف
CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
CmdList.Parent = Container

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom -- الأوامر تبدأ من فوق مربع البحث
ListLayout.Parent = CmdList

-- 8. نظام تحديث وعرض الأوامر الاحترافي
local function UpdateList(filter)
    for _, child in pairs(CmdList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local count = 0
    for cmdName, cmdData in pairs(Commands) do
        if filter == "" or string.find(string.lower(cmdName), string.lower(filter)) then
            -- خلفية الأمر
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, 0, 0, 28)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
            ItemFrame.BackgroundTransparency = 0.4 -- شفافية احترافية
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = CmdList
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 4)
            ItemCorner.Parent = ItemFrame

            -- نص الأمر
            local ItemText = Instance.new("TextLabel")
            ItemText.Size = UDim2.new(1, -20, 1, 0)
            ItemText.Position = UDim2.new(0, 10, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.Text = string.lower(cmdName) .. " (" .. (cmdData.Description or "") .. ")"
            ItemText.TextColor3 = Color3.fromRGB(220, 220, 220)
            ItemText.Font = Enum.Font.Gotham
            ItemText.TextSize = 13
            ItemText.TextXAlignment = Enum.TextXAlignment.Left
            ItemText.Parent = ItemFrame

            count = count + 1
        end
    end
    CmdList.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

UpdateList("")

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateList(SearchBox.Text)
end)

-- 9. تنفيذ الأمر بطريقة سلسة
SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = string.lower(SearchBox.Text)
        local args = string.split(input, " ")
        local cmdName = table.remove(args, 1)

        for name, data in pairs(Commands) do
            if string.lower(name) == cmdName then
                pcall(function()
                    data.Action(unpack(args))
                end)
                SearchBox.Text = ""
                UpdateList("")
                break
            end
        end
    end
end)

-- 10. أنيميشن الفتح والإغلاق (حركة انسيابية وناعمة جداً)
local isOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        SearchBox:CaptureFocus()
        TweenService:Create(SearchBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 40)}):Play()
        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 300)}):Play()
    else
        TweenService:Create(SearchBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 40)}):Play()
        TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 0)}):Play()
    end
end)
