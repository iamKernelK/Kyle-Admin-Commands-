local args = {...}
local name, cmd, toggleCmd = args[1], args[2], args[3]
if not name or not cmd then return end

local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui"):FindFirstChild("KyleBtns")

if not gui then
    gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "KyleBtns"
    gui.ResetOnSpawn = false
    
    local container = Instance.new("ScrollingFrame", gui)
    container.Name = "Container"
    container.Size = UDim2.new(0, 160, 0, 400)
    container.Position = UDim2.new(0.85, 0, 0.2, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 0
    
    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 8)
end

local container = gui.Container

local btn = Instance.new("TextButton", container)
btn.Name = name
btn.Size = UDim2.new(1, 0, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.Text = name
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.Active = true
btn.Draggable = true

local corner = Instance.new("UICorner", btn)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 1.5

local active = false
btn.MouseButton1Click:Connect(function()
    if toggleCmd then
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(40, 40, 40)
        pcall(function() 
            if active then 
                Commands[cmd].Action() 
            else 
                Commands[toggleCmd].Action() 
            end 
        end)
    else
        pcall(function() Commands[cmd].Action() end)
    end
end)
