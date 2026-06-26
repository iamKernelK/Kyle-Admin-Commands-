local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- تنظيف الواجهات القديمة
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
        Description = "Check your connection"
    }
end

-- ==========================================
-- 2. بناء الواجهة
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyleAdminUI"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- زر Ky (بدون UIStroke كما طلبت)
local Ky = Instance.new("ImageButton")
Ky.Name = "Ky"
Ky.Size = UDim2.new(0, 45, 0, 45)
Ky.Position = UDim2.new(0.5, 0, 0, 40)
Ky.AnchorPoint = Vector2.new(0.5, 0.5)
Ky.Image = "rbxassetid://109474087742061"
Ky.BackgroundTransparency = 1
Ky.Parent = ScreenGui

local KyCorner = Instance.new("UICorner")
KyCorner.CornerRadius = UDim.new(1, 0)
KyCorner.Parent = Ky

-- الحاوية الرئيسية (لإخفاء الأشياء أثناء الأنيميشن)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 400, 0, 300)
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = true -- هذا السر اللي يخلي الدخول والخروج سحري
Container.Parent = ScreenGui

-- الـ Input (مخفي تحت الحاوية كبداية)
local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Size = UDim2.new(0.9, 0, 0, 45)
Input.Position = UDim2.new(0.5, 0, 1.5, 0) -- موقع البداية (تحت)
Input.AnchorPoint = Vector2.new(0.5, 1)
Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- لون احترافي داكن
Input.BackgroundTransparency = 0.1
Input.TextColor3 = Color3.fromRGB(255, 255, 255) -- نص أبيض نقي
Input.Text = "" 
Input.PlaceholderText = "" 
Input.Font = Enum.Font.GothamMedium
Input.TextSize = 16
Input.ClearTextOnFocus = false
Input.Parent = Container

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = Input

-- قائمة الأوامر (مخفية فوق الحاوية كبداية)
local CmdList = Instance.new("ScrollingFrame")
CmdList.Size = UDim2.new(0.9, 0, 1, -65)
CmdList.Position = UDim2.new(0.5, 0, -1, 0) -- موقع البداية (فوق)
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
-- 3. نظام الأوامر والبحث الذكي
-- ==========================================
local function UpdateList(filter)
    for _, child in pairs(CmdList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    -- إذا كان الـ Input فارغاً، لا تظهر أي أوامر!
    if filter == "" then 
        CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
        return 
    end

    local count = 0
    for cmdName, cmdData in pairs(Commands) do
        if string.find(string.lower(cmdName), string.lower(filter)) then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, 0, 0, 35)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            ItemFrame.BackgroundTransparency = 0.2
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = CmdList
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = ItemFrame

            -- النص باستخدام RichText ليكون الاسم أبيض والوصف رمادي
            local ItemText = Instance.new("TextLabel")
            ItemText.Size = UDim2.new(1, -20, 1, 0)
            ItemText.Position = UDim2.new(0, 10, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.RichText = true
            ItemText.Text = string.lower(cmdName) .. " <font color='#999999'>- " .. (cmdData.Description or "") .. "</font>"
            ItemText.TextColor3 = Color3.fromRGB(255, 255, 255)
            ItemText.Font = Enum.Font.Gotham
            ItemText.TextSize = 14
            ItemText.TextXAlignment = Enum.TextXAlignment.Left
            ItemText.Parent = ItemFrame

            -- زر شفاف يغطي الأمر بالكامل لجعله قابلاً للضغط
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = ItemFrame

            -- لما تضغط على الأمر، يكتبه لك في الـ Input
            ClickBtn.MouseButton1Click:Connect(function()
                Input.Text = string.lower(cmdName) .. " "
                Input:CaptureFocus() -- يرجع الماوس للكتابة
                task.wait()
                Input.CursorPosition = #Input.Text + 1 -- يخلي الماوس في نهاية الكلمة
            end)

            count = count + 1
        end
    end
    CmdList.CanvasSize = UDim2.new(0, 0, 0, count * 41)
end

Input:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateList(Input.Text)
end)

-- التنفيذ الفعلي عند ضغط Enter فقط
Input.FocusLost:Connect(function(enterPressed)
    if enterPressed and Input.Text ~= "" then
        -- ترتيب النص وحذف المسافات الزائدة
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
-- 4. نظام السحب لـ Ky
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
-- 5. الأنيميشن الخرافي (الفتح والإغلاق)
-- ==========================================
local isOpen = false
local openTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

Ky.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        
        if not hasMoved then
            isOpen = not isOpen
            if isOpen then
                -- الدخول
                Input.Text = ""
                UpdateList("")
                Input:CaptureFocus()
                -- Input يأتي من تحت، والأوامر تأتي من فوق لموقعها الطبيعي
                TweenService:Create(Input, openTweenInfo, {Position = UDim2.new(0.5, 0, 1, -10)}):Play()
                TweenService:Create(CmdList, openTweenInfo, {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
            else
                -- الخروج
                -- Input ينزل لتحت ويختفي، والأوامر تطلع لفوق وتختفي
                TweenService:Create(Input, closeTweenInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
                TweenService:Create(CmdList, closeTweenInfo, {Position = UDim2.new(0.5, 0, -1, 0)}):Play()
            end
        end
    end
end)
