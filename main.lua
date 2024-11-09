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
        if type(value) == "table" and not string.match(name, "__") and name ~= "toggle" then
            value.__index = value

            setIndex(value)
        end
    end
end

setIndex(module)

--> Variables

local settings = {}
local tabs = {}

local library = game:GetObjects("rbxassetid://103258039851971")[1]
local examples = library.Examples

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local inPosition = UDim2.new(1, -20, 0.5, 0)
local offPosition = UDim2.new(1, -40, 0.5, 0)

module.window.tab.toggle.__newindex = function(self, key, value)
    if key ~= "state" then
        rawset(self, key, value)

        return
    end

    if value == true then
        task.spawn(self.callback)

        game:GetService("TweenService"):Create(self.ui.Switch.Indicator, TweenInfo.new(0.2), {Position = inPosition, BackgroundColor3 = Color3.fromRGB(69, 132, 234)}):Play()
    else
        game:GetService("TweenService"):Create(self.ui.Switch.Indicator, TweenInfo.new(0.2), {Position = offPosition, BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
    end

    rawset(self, "__value", value)
end

module.window.tab.toggle.__index = function(self, key)
    if key ~= "state" then
        return rawget(module.window.tab.toggle, key)
    end

    return self.__value
end

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
        toggle.state = not toggle.state
    end)

    toggle.callback = callback
    toggle.ui = ui
    toggle.state = false

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

    button.ui = ui
    button.callback = callback
    button.title = title

    return button
end

function module.window:updateTabs()
    if self.selectedTab and self.selectedTab ~= 0 then
        for _, tab2 in pairs(tabs) do
            if tab2 == self.selectedTab then
                continue
            end
            
            tab2.ui.Visible = false
        end
        
        self.selectedTab.ui.Visible = true
    end

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

function module.window:setCurrentTab(tab)
    self.selectedTab = tab
    self:updateTabs()
end

function module.window:addTab(title)
    local tab = setmetatable({}, self.tab)

    local UI = examples.Tab:Clone()
    local tabButton = examples.TabButton:Clone()

    tabButton.Title.Text = title
    tabButton.Parent = self.ui.Sidebar.ScrollingFrame

    UI.Parent = self.ui.Tabs
    UI.Name = title

    tabs[tabButton] = tab
    tabButton.Interact.MouseButton1Click:Connect(function()
        self:setCurrentTab(tab)
    end)

    if self.selectedTab == 0 then
        self.selectedTab = tab
    end

    tab.title = title
    tab.ui = UI
    tab.window = self

    self:updateTabs()

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
    window.selectedTab = 0

    return window
end

local window = module:createWindow("UI Library Testing")

local tab1 = window:addTab("Tab 1")
local tab2 = window:addTab("Tab 2")

tab1:addButton("Testing Button 1", function()
    print("testing button 1")
end)

tab2:addButton("Testing Button 2", function()
    print("testing button 2")
end)

tab1:addToggle("Testing Toggle 1", function()
    print("testing toggle 1")
end)

tab2:addToggle("Testing Toggle 2", function()
    print("testing toggle 2")
end)

tab1:addLabel("Testing Label 1", "Tab 1")
tab2:addLabel("Testing Label 2", "Tab 2")