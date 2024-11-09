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

local win

--> Functions

function module.window:createTab(title)
    local tab = setmetatable({}, self.tab)

    local UI = examples.Tab:Clone()
    local tabButton = examples.TabButton:Clone()

    tabButton.Title.Text = title
    tabButton.Parent = self.ui.Sidebar.ScrollingFrame

    UI.Parent = self.ui.Tabs
    UI.Name = title

    tabs[tabButton] = UI

    tab.title = title
    tab.ui = UI

    return tab
end

function module:createWindow(title)
    local window = setmetatable({}, self.window)
    local ui = library.Window:Clone()
    
    ui.Topbar.Title.Text = title
    ui.Name = title
    ui.Parent = screenGui

    window.ui = ui
    window.title = title

    return window
end