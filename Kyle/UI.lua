-- // Ton Admin Commands - UI Module
-- // UI/UX Design & Logic: Aura Scripts

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // Clean up existing UI instances
if CoreGui:FindFirstChild("TonAdminUI") then CoreGui.TonAdminUI:Destroy() end
if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TonAdminUI") then LocalPlayer.PlayerGui.TonAdminUI:Destroy() end

-- // Theme Configuration (Black + Orange + Gradients)
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Secondary = Color3.fromRGB(20, 20, 20),
    OrangeLight = Color3.fromRGB(255, 140, 0),
    OrangeDark = Color3.fromRGB(255, 70, 0),
    TextWhite = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150)
}

-- // Animation Configuration
local AnimConfig = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    Bouncy = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

-- ==========================================
-- 1. Command Fetching
-- ==========================================
local Commands = {}
local url = "https://raw.githubusercontent.com/iamKernelK/Kyle-Admin-Commands-/refs/heads/main/Kyle/Commands.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(url))()
end)

if success and type(result) == "table" then
    Commands = result
else
    warn("[Ton Admin]: Failed to load Commands module.")
end

-- ==========================================
-- 2. Core UI Construction
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TonAdminUI"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
local successMount = pcall(function() ScreenGui.Parent = CoreGui end)
if not successMount then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Toggle Button
local MainButton = Instance.new("ImageButton")
MainButton.Name = "MainToggleButton"
MainButton.Size = UDim2.new(0, 45, 0, 45)
MainButton.Position = UDim2.new(0.5, 0, 0, 40)
MainButton.AnchorPoint = Vector2.new(0.5, 0.5) -- Locked AnchorPoint to prevent jumping
MainButton.Image = "rbxassetid://103568481311084"
MainButton.BackgroundTransparency = 1
MainButton.Parent = ScreenGui

-- Apply Orange Gradient Stroke to Main Button
local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.new(1, 1, 1)
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BtnStroke.Parent = MainButton

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = MainButton

local BtnGradient = Instance.new("UIGradient")
BtnGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.OrangeLight),
    ColorSequenceKeypoint.new(1, Theme.OrangeDark)
}
BtnGradient.Parent = BtnStroke

-- Main Container (Hidden by default)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 550, 0, 300) 
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BackgroundTransparency = 1
Container.ClipsDescendants = true 
Container.Parent = ScreenGui

-- Search Input Field
local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Size = UDim2.new(1, 0, 0, 45)
Input.Position = UDim2.new(0.5, 0, 1.5, 0) -- Starts off-screen
Input.AnchorPoint = Vector2.new(0.5, 1)
Input.BackgroundColor3 = Theme.Background
Input.BackgroundTransparency = 0.1
Input.TextColor3 = Theme.TextWhite
Input.Text = "" 
Input.PlaceholderText = "Search command..." 
Input.PlaceholderColor3 = Theme.TextDim
Input.Font = Enum.Font.GothamMedium
Input.TextSize = 16
Input.ClearTextOnFocus = false
Input.Parent = Container

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = Input

local InputStroke = Instance.new("UIStroke")
InputStroke.Thickness = 1.5
InputStroke.Color = Theme.OrangeDark
InputStroke.Transparency = 0.5
InputStroke.Parent = Input

-- Command List (ScrollingFrame)
local CmdList = Instance.new("ScrollingFrame")
CmdList.Size = UDim2.new(1, 0, 1, -55)
CmdList.Position = UDim2.new(0.5, 0, -1, 0) -- Starts off-screen
CmdList.AnchorPoint = Vector2.new(0.5, 0)
CmdList.BackgroundTransparency = 1
CmdList.ScrollBarImageColor3 = Theme.OrangeLight
CmdList.ScrollBarThickness = 4
CmdList.CanvasSize = UDim2.new(0, 0, 0, 0)
CmdList.Parent = Container

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom 
ListLayout.Parent = CmdList

-- ==========================================
-- 3. Dynamic Command List & Hover Effects
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
            ItemFrame.Size = UDim2.new(1, -8, 0, 36)
            ItemFrame.Position = UDim2.new(0, 4, 0, 0)
            ItemFrame.BackgroundColor3 = Theme.Secondary
            ItemFrame.BackgroundTransparency = 0.3
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = CmdList
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = ItemFrame
            
            local ItemStroke = Instance.new("UIStroke")
            ItemStroke.Thickness = 1
            ItemStroke.Color = Theme.OrangeLight
            ItemStroke.Transparency = 1 -- Hidden by default
            ItemStroke.Parent = ItemFrame

            local ItemText = Instance.new("TextLabel")
            ItemText.Size = UDim2.new(1, -20, 1, 0)
            ItemText.Position = UDim2.new(0, 15, 0, 0)
            ItemText.BackgroundTransparency = 1
            ItemText.RichText = true
            ItemText.Text = "<b><font color='#FF8C00'>" .. string.upper(cmdName) .. "</font></b> <font color='#969696'>- " .. (cmdData.Description or "No description") .. "</font>"
            ItemText.TextColor3 = Theme.TextWhite
            ItemText.Font = Enum.Font.Gotham
            ItemText.TextSize = 13
            ItemText.TextXAlignment = Enum.TextXAlignment.Left
            ItemText.Parent = ItemFrame

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = ItemFrame

            -- Hover Animations
            ClickBtn.MouseEnter:Connect(function()
                TweenService:Create(ItemFrame, AnimConfig.Fast, {BackgroundTransparency = 0}):Play()
                TweenService:Create(ItemStroke, AnimConfig.Fast, {Transparency = 0.5}):Play()
            end)
            ClickBtn.MouseLeave:Connect(function()
                TweenService:Create(ItemFrame, AnimConfig.Fast, {BackgroundTransparency = 0.3}):Play()
                TweenService:Create(ItemStroke, AnimConfig.Fast, {Transparency = 1}):Play()
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

-- Input Focus Animations
Input.Focused:Connect(function()
    TweenService:Create(InputStroke, AnimConfig.Fast, {Transparency = 0, Thickness = 2}):Play()
end)
Input.FocusLost:Connect(function()
    TweenService:Create(InputStroke, AnimConfig.Fast, {Transparency = 0.5, Thickness = 1.5}):Play()
end)

-- ==========================================
-- 4. Open & Close Animations
-- ==========================================
local isOpen = false

local function openMenu()
    isOpen = true
    Input.Text = ""
    UpdateList("")
    Input:CaptureFocus()
    
    TweenService:Create(Input, AnimConfig.Smooth, {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
    TweenService:Create(CmdList, AnimConfig.Smooth, {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
end

local function closeMenu()
    isOpen = false
    Input:ReleaseFocus()
    
    TweenService:Create(Input, AnimConfig.Smooth, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
    TweenService:Create(CmdList, AnimConfig.Smooth, {Position = UDim2.new(0.5, 0, -1, 0)}):Play()
end

-- Execute Command Logic
Input.FocusLost:Connect(function(enterPressed)
    if enterPressed and Input.Text ~= "" then
        local inputText = string.lower(Input.Text):match("^%s*(.-)%s*$")
        local args = string.split(inputText, " ")
        local cmdName = table.remove(args, 1)

        for name, data in pairs(Commands) do
            if string.lower(name) == cmdName then
                pcall(function() data.Action(unpack(args)) end)
                break
            end
        end
        closeMenu()
    end
end)

-- Smart Click-Outside Logic
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isOpen then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local objects = ScreenGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
        
        local clickedInside = false
        for _, obj in pairs(objects) do
            if obj:IsDescendantOf(Container) or obj == MainButton then
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
-- 5. Draggable Button Logic (With Transparency Effects)
-- ==========================================
local isDragging = false
local hasMoved = false
local dragStartPos = nil
local startGuiPos = nil

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        hasMoved = false
        dragStartPos = input.Position
        startGuiPos = MainButton.Position
        
        -- Initial click scale down
        TweenService:Create(MainButton, AnimConfig.Fast, {Size = UDim2.new(0, 40, 0, 40)}):Play()
    end
end)

MainButton.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        
        if delta.Magnitude > 4 then 
            hasMoved = true 
            
            -- Apply transparency and slight shrink while dragging
            TweenService:Create(MainButton, AnimConfig.Fast, {
                ImageTransparency = 0.6,
                Size = UDim2.new(0, 36, 0, 36)
            }):Play()
            TweenService:Create(BtnStroke, AnimConfig.Fast, {Transparency = 0.6}):Play()
        end
        
        if hasMoved then
            TweenService:Create(MainButton, AnimConfig.Fast, {
                Position = UDim2.new(startGuiPos.X.Scale, startGuiPos.X.Offset + delta.X, startGuiPos.Y.Scale, startGuiPos.Y.Offset + delta.Y)
            }):Play()
        end
    end
end)

MainButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        
        -- Return to full size and opacity upon release
        TweenService:Create(MainButton, AnimConfig.Bouncy, {
            Size = UDim2.new(0, 45, 0, 45),
            ImageTransparency = 0
        }):Play()
        TweenService:Create(BtnStroke, AnimConfig.Fast, {Transparency = 0}):Play()
        
        if not hasMoved then
            if isOpen then closeMenu() else openMenu() end
        end
    end
end)
