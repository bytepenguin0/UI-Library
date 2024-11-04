local module = {}

--> Variables

local Settings = {}
local Tabs = {}
local Callbacks = {}

local Library = game:GetObjects("rbxassetid://86461665688191")[1]
local Examples = Library.Examples

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

local OnPosition = UDim2.new(1, -20, 0.5, 0)
local OffPosition = UDim2.new(1, -40, 0.5, 0)

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
    if ScreenGui:FindFirstChildWhichIsA("CanvasGroup") then
        return ScreenGui:FindFirstChildWhichIsA("CanvasGroup")
    end
    
    return nil
end

module.CreateWindow = function(Title)
    local Window = Library.Window:Clone()

    Window.Topbar.Title.Text = Title
    Window.Name = Title
    Window.Parent = ScreenGui

    loadstring(game:HttpGet("https://raw.githubusercontent.com/certified-retart/helpers/refs/heads/main/utility.lua"))().draggable(Window, 30)
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

    if not Window then
        return
    end

    for Button, TabFrame in pairs(Tabs) do
        Button.MouseButton1Click:Connect(function()
            for _, Tab in pairs(Window.Tabs:GetChildren()) do
                Tab.Visible = false
            end

            TabFrame.Visible = true
        end)
    end
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

local InitializeToggles = function()
    if not GetWindow() then
        return
    end

    if GetToggles() == {} or nil then
        return
    end

    for _, Toggle in pairs(GetToggles()) do
        Toggle.Interact.MouseButton1Click:Connect(function()

            Settings[Toggle.Name] = not Settings[Toggle.Name]

            if Settings[Toggle.Name] == true then
                game:GetService("TweenService"):Create(Toggle, TweenInfo.new(0.5), {Position = OnPosition}):Play()
            else
                game:GetService("TweenService"):Create(Toggle, TweenInfo.new(0.5), {Position = OffPosition}):Play()
            end
        end)
    end
end

local GetCallback = function(Button)
    for Object, Callback in pairs(Callbacks) do
        if string.lower(Object.Name) == tostring(string.lower(Button)) then
            return Callback
        end
    end

    return nil
end

game:GetService("RunService").Heartbeat:Connect(function()
    for Button, Value in pairs(Settings) do
        local Callback = GetCallback(Button)

        if Value then
            Callback()
        end
    end
end)

InitializeToggles()
InitializeTabs()

return module
