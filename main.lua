local module = {}

--> Variables

local Settings = {}
local Tabs = {}

local Library = game:GetObjects("rbxassetid://103258039851971")[1]
local Examples = Library.Examples

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local OnPosition = UDim2.new(1, -20, 0.5, 0)
local OffPosition = UDim2.new(1, -40, 0.5, 0)

local Win

--> Functions

local GetWindow = function()
    if Win then
        return Win
    end

    return nil
end

local GetTab = function(Name)
    local Window = GetWindow()

    if not Window then
        warn("No window found!")
        return
    end

    for _, Tab in pairs(Window.Tabs:GetChildren()) do
        if Tab.Name == tostring(Name) then
            return Tab
        end
    end
    
    return nil
end

local GetCurrentTab = function()
    local Window = GetWindow()

    if not Window then
        warn("No window found!")
        return
    end

    for _, Tab in pairs(Window.Tabs:GetChildren()) do
        if Tab.Visible then
            for Button, Tab2 in pairs(Tabs) do
                if Tab == Tab2 then
                    return {Button, Tab2}
                end
            end
        end
    end

    return nil
end

local GetToggles = function()
    local Toggles = {}
    local Window = GetWindow()

    if not Window then
        warn("No window found!")
        return
    end

    for _, Tab in pairs(Window.Tabs:GetChildren()) do
        for _, Button in pairs(Tab.ScrollingFrame:GetChildren()) do
            if Button:IsA("Frame") and Button:FindFirstChild("Switch") then
                table.insert(Toggles, Button)
            end
        end
    end

    return Toggles
end

module.CreateWindow = function(Title)
    local Window = Library.Window:Clone()
    Win = Window

    Window.Topbar.Title.Text = Title
    Window.Name = Title
    Window.Parent = ScreenGui
end

module.AddTab = function(Title)
    local Window = GetWindow()

    if not Window then
        return
    end

    local Tab = Examples.Tab:Clone()
    local TabButton = Examples.TabButton:Clone()

    TabButton.Title.Text = Title
    TabButton.Parent = Window.Sidebar.ScrollingFrame
    Tab.Parent = Window.Tabs
    Tab.Name = Title

    Tabs[TabButton] = Tab
end

module.AddLabel = function(Title, Tab)
    if not GetTab(Tab) then
        warn("Tab not found.")

        return
    end

    local Label = Examples.Label:Clone()

    Label.Parent = GetTab(Tab).ScrollingFrame
    Label.Title.Text = Title
end

module.AddToggle = function(Title, Tab, Callback)
    if not GetTab(Tab) then
        warn("Tab not found.")

        return
    end

    local Toggle = Examples.Toggle:Clone()

    Toggle.Parent = GetTab(Tab).ScrollingFrame
    Toggle.Title.Text = Title

    Settings[Toggle.Name] = false

    Toggle.Interact.MouseButton1Click:Connect(function()
        Settings[Toggle.Name] = not Settings[Toggle.Name]

        if Settings[Toggle.Name] == true then
            task.spawn(function()
                Callback()
            end)

            game:GetService("TweenService"):Create(Toggle.Switch.Indicator, TweenInfo.new(0.2), {Position = OnPosition, BackgroundColor3 = Color3.fromRGB(69, 132, 234)}):Play()
        else
            game:GetService("TweenService"):Create(Toggle.Switch.Indicator, TweenInfo.new(0.2), {Position = OffPosition, BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end
    end)
end

module.AddButton = function(Title, Tab, Callback)
    if not GetTab(Tab) then
        warn("Tab not found.")

        return
    end

    local Button = Examples.Button:Clone()

    Button.Parent = GetTab(Tab).ScrollingFrame
    Button.Title.Text = Title

    Button.Interact.MouseButton1Click:Connect(function()
        Callback()
    end)
end

module.SetTab = function(Tab)
    if not GetWindow() then
        warn("No window found.")
        
        return
    end

    if not GetTab(Tab) then
        warn("Tab not found.")

        return
    end

    for _, Object in pairs(GetWindow().Tabs:GetChildren()) do
        Object.Visible = false
    end

    GetTab(Tab).Visible = true
end

--> Initialization

local InitializeDragify = function()
    local Window = GetWindow()

    if Window then
        task.spawn(function()
            local dragToggle
            local dragInput
            local dragSpeed
            local dragStart
            local dragPos
            local startPos
            
            function dragify(Frame)
                dragToggle = nil
                dragSpeed = 0.50
                dragInput = nil
                dragStart = nil
                dragPos = nil
                local function updateInput(input)
                    local Delta = input.Position - dragStart
                    local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
                    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.30), {Position = Position}):Play()
                end
                Frame.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and game:GetService("UserInputService"):GetFocusedTextBox() == nil then
                        dragToggle = true
                        dragStart = input.Position
                        startPos = Frame.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragToggle = false
                            end
                        end)
                    end
                end)
                Frame.InputChanged:Connect(function(input)
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
            
            dragify(Window)
        end)
    end
end

local InitializeTabs = function()
    local Window = GetWindow()

    if Window then
        task.spawn(function()
            for Button, Tab in pairs(Tabs) do
                Button.Interact.MouseButton1Click:Connect(function()
                    for _, Tab2 in pairs(Tabs) do
                        if Tab2 == Tab then
                            continue
                        end
                        
                        Tab2.Visible = false
                    end
                    
                    Tab.Visible = true
                end)
            end

            game:GetService("RunService").Heartbeat:Connect(function()
                for Button, Tab in pairs(Tabs) do
                    if Tab.Visible then
                        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}):Play()
                    else
                        game:GetService("TweenService"):Create(Button, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
                   end
                end
            end)
        end)
    end
end

local InitializeButtons = function()
    local Window = GetWindow()

    if Window then
        Window.Topbar.Close.ImageTransparency = 0.4

        task.spawn(function()
            Window.Topbar.Close.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(Window.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
            end)
        
            Window.Topbar.Close.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(Window.Topbar.Close, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play()
            end)
        
            Window.Topbar.Close.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
            end)

            for Button, Tab in pairs(Tabs) do
                for _, Object in pairs(Tab.ScrollingFrame:GetChildren()) do
                    if #Object:GetChildren() == 4 and Object.Interact and Object.Title then
                        Object.Interact.MouseEnter:Connect(function()
                            game:GetService("TweenService"):Create(Object, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                        end)

                        Object.Interact.MouseLeave:Connect(function()
                            game:GetService("TweenService"):Create(Object, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                        end)
                    end
                end
            end
        end)
    end
end

module.Initialize = function()
    InitializeDragify()
    InitializeTabs()
    InitializeButtons()
end

module.CreateWindow("UI Library Testing")

module.AddTab("Tab 1")
module.AddTab("Tab 2")

module.AddButton("Testing Button 1", "Tab 1", function()
    print("testing button 1")
end)

module.AddButton("Testing Button 2", "Tab 2", function()
    print("testing button 2")
end)

module.AddToggle("Testing Toggle 1", "Tab 1", function()
    print("testing toggle 1")
end)

module.AddToggle("Testing Toggle 2", "Tab 2", function()
    print("testing toggle 2")
end)

module.AddLabel("Testing Label 1", "Tab 1")
module.AddLabel("Testing Label 2", "Tab 2")

module.SetTab("Tab 1")

module.Initialize()