-- ModuleScript: UI
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = {}

function UI.Load()
    -- 1. جلب الأوامر من الرابط
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

    -- 2. إنشاء الواجهة (ScreenGui)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KyleAdminUI"
    -- حماية الواجهة في الـ CoreGui إذا كان السكربت يعمل من Executor
    local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
    if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- 3. زر التشغيل (Image Button)
    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleBtn.Image = "rbxassetid://109474087742061"
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Parent = ScreenGui

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 3
    BtnStroke.Color = Color3.fromRGB(0, 0, 255) -- أزرق
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BtnStroke.Parent = ToggleBtn
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = ToggleBtn

    -- أنيميشن UIStroke للزر (أزرق إلى Cyan)
    task.spawn(function()
        while true do
            local tween = TweenService:Create(BtnStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(0, 255, 255)})
            tween:Play()
            tween.Completed:Wait()
            local tweenBack = TweenService:Create(BtnStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(0, 0, 255)})
            tweenBack:Play()
            tweenBack.Completed:Wait()
        end
    end)

    -- 4. الإطار الرئيسي (الواجهة المخفية)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 0) -- مغلق البداية
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 255, 255)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- العنوان
    local Title = Instance.new("TextLabel")
    Title.Text = "Kyle Admin Commands"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    -- شريط البحث (Input)
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.9, 0, 0, 40)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 50)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderText = "Search command..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = MainFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    -- قائمة الأوامر (ScrollingFrame)
    local CmdList = Instance.new("ScrollingFrame")
    CmdList.Size = UDim2.new(0.9, 0, 0, 240)
    CmdList.Position = UDim2.new(0.05, 0, 0, 100)
    CmdList.BackgroundTransparency = 1
    CmdList.ScrollBarThickness = 4
    CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
    CmdList.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = CmdList

    -- 5. وظيفة تحديث قائمة البحث
    local function UpdateList(filter)
        for _, child in pairs(CmdList:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end

        local count = 0
        for cmdName, cmdData in pairs(Commands) do
            if filter == "" or string.find(string.lower(cmdName), string.lower(filter)) then
                local Item = Instance.new("TextLabel")
                Item.Size = UDim2.new(1, 0, 0, 30)
                Item.BackgroundTransparency = 1
                Item.Text = string.lower(cmdName) .. " " .. (cmdData.Description or "")
                Item.TextColor3 = Color3.fromRGB(200, 200, 200)
                Item.Font = Enum.Font.Gotham
                Item.TextSize = 14
                Item.TextXAlignment = Enum.TextXAlignment.Left
                Item.Parent = CmdList
                count = count + 1
            end
        end
        CmdList.CanvasSize = UDim2.new(0, 0, 0, count * 35)
    end

    UpdateList("")

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateList(SearchBox.Text)
    end)

    -- 6. تنفيذ الأمر عند الضغط على Enter
    SearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = string.lower(SearchBox.Text)
            local args = string.split(input, " ")
            local cmdName = table.remove(args, 1)

            -- البحث عن الأمر وتنفيذه
            for name, data in pairs(Commands) do
                if string.lower(name) == cmdName then
                    local successRun, err = pcall(function()
                        data.Action(unpack(args))
                    end)
                    if successRun then
                        SearchBox.Text = ""
                        UpdateList("")
                    else
                        warn("Command Error:", err)
                    end
                    break
                end
            end
        end
    end)

    -- 7. أنيميشن فتح وإغلاق الواجهة
    local isOpen = false
    ToggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 350)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 400, 0, 0)}):Play()
        end
    end)
end

return UI

