local module = {}

module.window = {
    ["tab"] = {
        ["label"] = {},
        ["toggle"] = {},
        ["button"] = {}
    }
}

local setIndex; setIndex = function(t)
    for name, value in pairs(t) do
        if type(value) == "table" then
            value.__index = value

            setIndex(value)
        end
    end
end

--> Variables

local settings = {}
local tabs = {}

local library = game:GetObjects("rbxassetid://103258039851971")[1]
local examples = library.Examples

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local inPosition = UDim2.new(1, -20, 0.5, 0)
local offPosition = UDim2.new(1, -40, 0.5, 0)

--> Functions

function module.window.tab:addLabel(title)
    local label = setmetatable({}, self.label)
    local ui = examples.Label:Clone()

    ui.Parent = self.ui.ScrollingFrame
    ui.Title.Text = title

    label.ui = ui
    label.title = title

    return label
end

function module.window.tab:addToggle(title, callback)
    local toggle = setmetatable({}, self.toggle)
    local ui = examples.Toggle:Clone()

    ui.Parent = self.ui.ScrollingFrame
    ui.Title.Text = title

    ui.Interact.MouseButton1Click:Connect(function()
        toggle.value = not toggle.value

        if toggle.value == true then
            task.spawn(callback)

            game:GetService("TweenService"):Create(ui.Switch.Indicator, TweenInfo.new(0.2), {Position = inPosition, BackgroundColor3 = Color3.fromRGB(69, 132, 234)}):Play()
        else
            game:GetService("TweenService"):Create(ui.Switch.Indicator, TweenInfo.new(0.2), {Position = offPosition, BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end
    end)

    toggle.value = false

    return toggle
end

function module.window.tab:addButton(title, callback)
    local button = setmetatable({}, self.button)
    local ui = examples.Button:Clone()

    ui.Parent = self.ui.ScrollingFrame
    ui.Title.Text = title

    ui.Interact.MouseButton1Click:Connect(callback)
    ui.Interact.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(ui, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)

    ui.Interact.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(ui, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)

    return button
end

function module.window:updateTabs()
    for button, tab in pairs(tabs) do
        if tab.window ~= self then
            continue
        end

        if tab.ui.Visible then
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}):Play()
        else
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
       end
    end
end

function module.window:createTab(title)
    local tab = setmetatable({}, self.tab)

    local UI = examples.Tab:Clone()
    local tabButton = examples.TabButton:Clone()

    tabButton.Title.Text = title
    tabButton.Parent = self.ui.Sidebar.ScrollingFrame

    UI.Parent = self.ui.Tabs
    UI.Name = title

    tabs[tabButton] = tab
    tabButton.Interact.MouseButton1Click:Connect(function()
        for _, tab2 in pairs(tabs) do
            if tab2 == tab then
                continue
            end
            
            tab2.ui.Visible = false
        end
        
        tab.ui.Visible = true

        self:updateTabs()
    end)

    tab.title = title
    tab.ui = UI
    tab.window = self

    return tab
end

function module:createWindow(title)
    local window = setmetatable({}, self.window)
    local ui = library.Window:Clone()
    
    ui.Topbar.Title.Text = title
    ui.Name = title
    ui.Parent = screenGui

    ui.Topbar.Close.ImageTransparency = 0.4

    task.spawn(function()
        ui.Topbar.Close.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(ui.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
        end)
    
        ui.Topbar.Close.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(ui.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
        end)
    
        ui.Topbar.Close.MouseButton1Click:Connect(function()
            ui:Destroy()
        end)
    end)

    task.spawn(function()
        local dragToggle
        local dragInput
        local dragSpeed
        local dragStart
        local dragPos
        local startPos
        
        function dragify(frame)
            dragToggle = nil
            dragSpeed = 0.50
            dragInput = nil
            dragStart = nil
            dragPos = nil
            local function updateInput(input)
                local delta = input.Position - dragStart
                local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                game:GetService("TweenService"):Create(frame, TweenInfo.new(0.30), {Position = position}):Play()
            end
            frame.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and game:GetService("UserInputService"):GetFocusedTextBox() == nil then
                    dragToggle = true
                    dragStart = input.Position
                    startPos = frame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragToggle = false
                        end
                    end)
                end
            end)
            frame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == dragInput and dragToggle then
                    updateInput(input)
                end
            end)
        end
    
        dragify(ui)
    end)

    window.ui = ui
    window.title = title

    return window
end
