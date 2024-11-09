local module = {}

module.window = {}
module.window.__index = module.window

module.window.tab = {}
module.window.tab.__index = module.window.tab

module.window.tab.label = {}
module.window.tab.label.__index = module.window.tab.label

module.window.tab.toggle = {}
module.window.tab.toggle.__index = module.window.tab.toggle

module.window.tab.button = {}
module.window.tab.button.__index = module.window.tab.button

local setIndex; setIndex = function(t)
    for name, value in pairs(t) do
        if type(value) == "table" then
            value.__index = value

            setIndex(value)
        end
    end
end

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

function module.window:createTab(title)
    local tab = setmetatable({}, self.tab)

    local UI = Examples.Tab:Clone()
    local TabButton = Examples.TabButton:Clone()

    TabButton.Title.Text = title
    TabButton.Parent = self.ui.Sidebar.ScrollingFrame

    UI.Parent = self.ui.Tabs
    UI.Name = title

    Tabs[TabButton] = UI

    tab.title = title
    tab.ui = UI

    return tab
end

function module:createWindow(title)
    local window = setmetatable({}, self.window)
    local ui = Library.Window:Clone()
    
    ui.Topbar.Title.Text = title
    ui.Name = title
    ui.Parent = ScreenGui

    window.ui = ui
    window.title = title

    return window
end