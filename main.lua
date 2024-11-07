local module = {}

--> Variables

local Settings = {}
local Tabs = {}
local Callbacks = {}

local Library = game:GetObjects("rbxassetid://120885785477427")[1]
local Examples = Library.Examples

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local OnPosition = UDim2.new(1, -20, 0.5, 0)
local OffPosition = UDim2.new(1, -40, 0.5, 0)

local Window

--> Functions

local GetTab = function(Tab)
    for Button, TabFrame in pairs(Tabs) do
        if TabFrame.Name == Tab then
            return TabFrame
        end
    end
    
    return nil
end

local GetWindow = function()
    if Window then
        return Window
    end
    
    return nil
end

local GetToggles = function()
    local Toggles = {}

    for _, Window in pairs(GetWindow():GetChildren()) do
        for _, Tab in pairs(Window.Tabs:GetChildren()) do
            for _, Button in pairs(Tab.ScrollingFrame:GetChildren()) do
                if Button:IsA("Frame") and Button:FindFirstChild("Switch") then
                    table.insert(Toggles, Button)
                end
            end
        end
    end

    return Toggles
end

local GetCallback = function(Button)
    for Object, Callback in pairs(Callbacks) do
        if string.lower(Object.Name) == tostring(string.lower(Button)) then
            return Callback
        end
    end

    return nil
end

module.CreateWindow = function(Title)
    Window = Library.Window:Clone()

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

    Tabs[TabButton] = Tab
end

module.AddLabel = function(Title, Tab)
    if not GetTab(Tab) then
        return
    end

    local Label = Examples.Label:Clone()

    Label.Parent = GetTab(Tab)
    Label.Title.Text = Title
end

module.AddToggle = function(Title, Tab, Callback)
    if not GetTab(Tab) then
        return
    end

    local Toggle = Examples.Toggle:Clone()

    Toggle.Parent = GetTab(Tab)
    Toggle.Title.Text = Title

    Settings[Toggle.Name] = false
    table.insert(Callbacks, {Toggle, Callback})
end

module.AddButton = function(Title, Tab, Callback)
    if not GetTab(Tab) then
        return
    end

    local Button = Examples.Button:Clone()

    Button.Parent = GetTab(Tab)
    Button.Title.Text = Title

    Button.Interact.MouseButton1Click:Connect(function()
        Callback()
    end)
end

--> Initialization

local InitializeTabs = function()
    local Window = GetWindow()

    if Window then
        task.spawn(function()
            for Button, TabFrame in pairs(Tabs) do
                Button.MouseButton1Click:Connect(function()
                    for _, Tab in pairs(Window.Tabs:GetChildren()) do
                        Tab.Visible = false
                    end
        
                    TabFrame.Visible = true
                end)
            end
        end)
    end
end

local InitializeToggles = function()
    if GetWindow() and GetToggles() ~= {} or not GetToggles() then
        task.spawn(function()
            for _, Toggle in pairs(GetToggles()) do
                Toggle.Interact.MouseButton1Click:Connect(function()
                    local Callback = GetCallback(Toggle)
                    Settings[Toggle.Name] = not Settings[Toggle.Name]
        
                    if Settings[Toggle.Name] == true then
                        game:GetService("TweenService"):Create(Toggle, TweenInfo.new(0.5), {Position = OnPosition}):Play()
                    else
                        task.spawn(function()
                            Callback()
                        end)

                        game:GetService("TweenService"):Create(Toggle, TweenInfo.new(0.5), {Position = OffPosition}):Play()
                    end
                end)
            end
        end)
    end
end

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

local InitializeButtons = function()
    local Window = GetWindow()

    if Window then
        task.spawn(function()
            Window.Topbar.Close.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(Window.Topbar.Close, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
            end)
        
            Window.Topbar.Close.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(Window.Topbar.Close, TweenInfo.new(0.5), {ImageTransparency = 0.3}):Play()
            end)
        
            Window.Topbar.Close.MouseButton1Click:Connect(function()
                Window:Destroy()
            end)
        end)
    end
end

local Initialize = function()
    InitializeDragify()
    InitializeToggles()
    InitializeTabs()
    InitializeButtons()
end

Initialize()

return module