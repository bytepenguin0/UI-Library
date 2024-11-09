local module = {}

--> Variables

local settings = {}
local tabs = {}

local library = game:GetObjects("rbxassetid://103258039851971")[1]
local examples = library.Examples

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local onPosition = UDim2.new(1, -20, 0.5, 0)
local offPosition = UDim2.new(1, -40, 0.5, 0)

local win

--> Functions

local getWindow = function()
    if win then
        return win
    end

    return nil
end

local getTab = function(name)
    local window = getWindow()

    if not window then
        warn("No window found!")
        return
    end

    for _, tab in pairs(window.Tabs:GetChildren()) do
        if tab.Name == tostring(name) then
            return tab
        end
    end
    
    return nil
end

local getCurrentTab = function()
    local window = getWindow()

    if not window then
        warn("No window found!")
        return
    end

    for _, tab in pairs(window.Tabs:GetChildren()) do
        if tab.Visible then
            for button, tab2 in pairs(tabs) do
                if tab == tab2 then
                    return {button, tab2}
                end
            end
        end
    end

    return nil
end

local getToggles = function()
    local toggles = {}
    local window = getWindow()

    if not window then
        warn("No window found!")
        return
    end

    for _, tab in pairs(window.Tabs:GetChildren()) do
        for _, button in pairs(tab.ScrollingFrame:GetChildren()) do
            if button:IsA("Frame") and button:FindFirstChild("Switch") then
                table.insert(toggles, button)
            end
        end
    end

    return toggles
end

module.createWindow = function(title)
    local window = library.Window:Clone()
    win = window

    window.Topbar.Title.Text = title
    window.Name = title
    window.Parent = screenGui
end

module.addTab = function(title)
    local window = getWindow()

    if not window then
        return
    end

    local tab = examples.Tab:Clone()
    local tabButton = examples.TabButton:Clone()

    tabButton.Title.Text = title
    tabButton.Parent = window.Sidebar.ScrollingFrame
    tab.Parent = window.Tabs
    tab.Name = title

    tabs[tabButton] = tab
end

module.addLabel = function(title, tab)
    if not getTab(tab) then
        warn("Tab not found.")
        return
    end

    local label = examples.Label:Clone()

    label.Parent = getTab(tab).ScrollingFrame
    label.Title.Text = title
end

module.addToggle = function(title, tab, callback)
    if not getTab(tab) then
        warn("Tab not found.")
        return
    end

    local toggle = examples.Toggle:Clone()

    toggle.Parent = getTab(tab).ScrollingFrame
    toggle.Title.Text = title

    settings[toggle.Name] = false

    toggle.Interact.MouseButton1Click:Connect(function()
        settings[toggle.Name] = not settings[toggle.Name]

        if settings[toggle.Name] == true then
            task.spawn(function()
                callback()
            end)

            game:GetService("TweenService"):Create(toggle.Switch.Indicator, TweenInfo.new(0.2), {Position = onPosition, BackgroundColor3 = Color3.fromRGB(69, 132, 234)}):Play()
        else
            game:GetService("TweenService"):Create(toggle.Switch.Indicator, TweenInfo.new(0.2), {Position = offPosition, BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end
    end)
end

module.addButton = function(title, tab, callback)
    if not getTab(tab) then
        warn("Tab not found.")
        return
    end

    local button = examples.Button:Clone()

    button.Parent = getTab(tab).ScrollingFrame
    button.Title.Text = title

    button.Interact.MouseButton1Click:Connect(function()
        callback()
    end)
end

module.setTab = function(tab)
    if not getWindow() then
        warn("No window found.")
        return
    end

    if not getTab(tab) then
        warn("Tab not found.")
        return
    end

    for _, object in pairs(getWindow().Tabs:GetChildren()) do
        object.Visible = false
    end

    getTab(tab).Visible = true
end

--> Initialization

local initializeDragify = function()
    local window = getWindow()

    if window then
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
            
            dragify(window)
        end)
    end
end

local initializeTabs = function()
    local window = getWindow()

    if window then
        task.spawn(function()
            for button, tab in pairs(tabs) do
                button.Interact.MouseButton1Click:Connect(function()
                    for _, tab2 in pairs(tabs) do
                        if tab2 == tab then
                            continue
                        end
                        
                        tab2.Visible = false
                    end
                    
                    tab.Visible = true
                end)
            end

            game:GetService("RunService").Heartbeat:Connect(function()
                for button, tab in pairs(tabs) do
                    if tab.Visible then
                        game:GetService("TweenService"):Create(button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}):Play()
                    else
                        game:GetService("TweenService"):Create(button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
                   end
                end
            end)
        end)
    end
end

local initializeButtons = function()
    local window = getWindow()

    if window then
        window.Topbar.Close.ImageTransparency = 0.4

        task.spawn(function()
            window.Topbar.Close.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(window.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
            end)
        
            window.Topbar.Close.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(window.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
            end)
        
            window.Topbar.Close.MouseButton1Click:Connect(function()
                screenGui:Destroy()
            end)

            for button, tab in pairs(tabs) do
                for _, object in pairs(tab.ScrollingFrame:GetChildren()) do
                    if #object:GetChildren() == 4 and object.Interact and object.Title then
                        object.Interact.MouseEnter:Connect(function()
                            game:GetService("TweenService"):Create(object, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end)

                        object.Interact.MouseLeave:Connect(function()
                            game:GetService("TweenService"):Create(object, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                        end)
                    end
                end
            end
        end)
    end
end

module.initialize = function()
    initializeDragify()
    initializeTabs()
    initializeButtons()
end

module.createWindow("UI Library Testing")

module.addTab("Tab 1")
module.addTab("Tab 2")

module.addButton("Testing Button 1", "Tab 1", function()
    print("testing button 1")
end)

module.addButton("Testing Button 2", "Tab 2", function()
    print("testing button 2")
end)

module.addToggle("Testing Toggle 1", "Tab 1", function()
    print("testing toggle 1")
end)

module.addToggle("Testing Toggle 2", "Tab 2", function()
    print("testing toggle 2")
end)

module.addLabel("Testing Label 1", "Tab 1")
module.addLabel("Testing Label 2", "Tab 2")

module.setTab("Tab 1")

module.initialize()