-- GUI Library.
---@module GUI.Library
local Library = {}

local Constants = ModuleLoader.load("Core/Constants")
local Utilities = ModuleLoader.load("Core/Utilities")
local Logger = ModuleLoader.load("Utility/Logger")

Library.windows = {}
Library.theme = {
    background = Color3.fromRGB(30, 30, 35),
    secondary = Color3.fromRGB(40, 40, 45),
    tertiary = Color3.fromRGB(50, 50, 55),
    accent = Color3.fromRGB(0, 170, 255),
    accentHover = Color3.fromRGB(0, 200, 255),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(180, 180, 180),
    border = Color3.fromRGB(60, 60, 65),
    success = Color3.fromRGB(0, 200, 100),
    error = Color3.fromRGB(255, 80, 80),
    warning = Color3.fromRGB(255, 200, 0)
}

---Create a new window
---@param title string
---@param size Vector2?
---@return table
function Library.createWindow(title, size)
    size = size or Vector2.new(600, 500)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RUE_" .. title:gsub("%s+", "")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    screenGui = Utilities.protectGui(screenGui)

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(size.X, size.Y)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Library.theme.background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Library.theme.border
    stroke.Thickness = 1
    stroke.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Library.theme.secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 8)
    titleFix.Position = UDim2.new(0, 0, 1, -8)
    titleFix.BackgroundColor3 = Library.theme.secondary
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Library.theme.text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Library.theme.error
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Library.theme.text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.fromOffset(30, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = Library.theme.warning
    minimizeBtn.BackgroundTransparency = 0.8
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Library.theme.text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = titleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn

    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Library.theme.secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, -10, 1, -10)
    tabList.Position = UDim2.new(0, 5, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabList.Parent = tabContainer

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = tabList

    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -80)
    contentContainer.Position = UDim2.new(0, 0, 0, 80)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame

    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Minimize button
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        contentContainer.Visible = not minimized
        tabContainer.Visible = not minimized
        if minimized then
            mainFrame.Size = UDim2.fromOffset(size.X, 40)
            minimizeBtn.Text = "+"
        else
            mainFrame.Size = size
            minimizeBtn.Text = "−"
        end
    end)

    local window = {
        screenGui = screenGui,
        mainFrame = mainFrame,
        titleBar = titleBar,
        tabContainer = tabContainer,
        tabList = tabList,
        contentContainer = contentContainer,
        tabs = {},
        currentTab = nil,
        size = size
    }

    Library.windows[title] = window
    return window
end

---Create a tab
---@param window table
---@param name string
---@return table
function Library.createTab(window, name)
    -- Tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_" .. name
    tabButton.Size = UDim2.fromOffset(100, 30)
    tabButton.BackgroundColor3 = Library.theme.tertiary
    tabButton.BackgroundTransparency = 0.5
    tabButton.Text = name
    tabButton.TextColor3 = Library.theme.textDim
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.Parent = window.tabList

    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 6)
    tabBtnCorner.Parent = tabButton

    -- Tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = "Content_" .. name
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Library.theme.accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = window.contentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = tabContent

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = tabContent

    local tab = {
        name = name,
        button = tabButton,
        content = tabContent,
        sections = {}
    }

    tabButton.MouseButton1Click:Connect(function()
        Library.selectTab(window, name)
    end)

    window.tabs[name] = tab

    -- Select first tab by default
    if not window.currentTab then
        Library.selectTab(window, name)
    end

    return tab
end

---Select a tab
---@param window table
---@param name string
function Library.selectTab(window, name)
    for tabName, tab in pairs(window.tabs) do
        tab.content.Visible = (tabName == name)
        tab.button.BackgroundTransparency = (tabName == name) and 0 or 0.5
        tab.button.TextColor3 = (tabName == name) and Library.theme.text or Library.theme.textDim
        tab.button.BackgroundColor3 = (tabName == name) and Library.theme.accent or Library.theme.tertiary
    end
    window.currentTab = name
end

---Create a section in a tab
---@param tab table
---@param name string
---@return table
function Library.createSection(tab, name)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = "Section_" .. name
    sectionFrame.BackgroundColor3 = Library.theme.secondary
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Size = UDim2.new(1, 0, 0, 40)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.Parent = tab.content

    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = sectionFrame

    local sectionStroke = Instance.new("UIStroke")
    sectionStroke.Color = Library.theme.border
    sectionStroke.Thickness = 1
    sectionStroke.Parent = sectionFrame

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "Title"
    sectionTitle.Size = UDim2.new(1, -20, 0, 30)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = name
    sectionTitle.TextColor3 = Library.theme.text
    sectionTitle.TextSize = 14
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = sectionFrame

    local sectionContent = Instance.new("Frame")
    sectionContent.Name = "Content"
    sectionContent.Size = UDim2.new(1, -20, 0, 0)
    sectionContent.Position = UDim2.new(0, 10, 0, 35)
    sectionContent.BackgroundTransparency = 1
    sectionContent.AutomaticSize = Enum.AutomaticSize.Y
    sectionContent.Parent = sectionFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = sectionContent

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = sectionContent

    local section = {
        frame = sectionFrame,
        title = sectionTitle,
        content = sectionContent,
        elements = {}
    }

    tab.sections[name] = section
    return section
end

---Create a toggle
---@param section table
---@param name string
---@param default boolean
---@param callback function
---@return table
function Library.createToggle(section, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. name
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = section.content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Library.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.fromOffset(50, 24)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBtn.BackgroundColor3 = default and Library.theme.accent or Library.theme.tertiary
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.fromOffset(20, 20)
    toggleCircle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleCircle.BackgroundColor3 = Library.theme.text
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBtn

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    local state = default

    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state

            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
            local goalColor = state and Library.theme.accent or Library.theme.tertiary
            local goalPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)

            game:GetService("TweenService"):Create(toggleBtn, tweenInfo, {BackgroundColor3 = goalColor}):Play()
            game:GetService("TweenService"):Create(toggleCircle, tweenInfo, {Position = goalPos}):Play()

            if callback then
                callback(state)
            end
        end
    end)

    return {frame = toggleFrame, getState = function() return state end, setState = function(s) state = s end}
end

---Create a slider
---@param section table
---@param name string
---@param min number
---@param max number
---@param default number
---@param callback function
---@return table
function Library.createSlider(section, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider_" .. name
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = section.content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Library.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.fromOffset(50, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Library.theme.textDim
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "Background"
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Library.theme.tertiary
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Library.theme.accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.fromOffset(16, 16)
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Library.theme.text
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob

    local dragging = false
    local value = default

    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relX
        value = math.floor(value * 100) / 100

        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relX, -8, 0.5, -8)
        valueLabel.Text = tostring(value)

        if callback then
            callback(value)
        end
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {frame = sliderFrame, getValue = function() return value end, setValue = function(v) value = v end}
end

---Create a button
---@param section table
---@param name string
---@param callback function
---@return table
function Library.createButton(section, name, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. name
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Library.theme.accent
    button.BackgroundTransparency = 0.1
    button.Text = name
    button.TextColor3 = Library.theme.text
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.Parent = section.content

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    end)

    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return {frame = button}
end

---Create a dropdown
---@param section table
---@param name string
---@param options table
---@param default any
---@param callback function
---@return table
function Library.createDropdown(section, name, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown_" .. name
    dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = section.content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Library.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame

    local selectedBtn = Instance.new("TextButton")
    selectedBtn.Name = "Selected"
    selectedBtn.Size = UDim2.fromOffset(150, 30)
    selectedBtn.Position = UDim2.new(1, -150, 0.5, -15)
    selectedBtn.BackgroundColor3 = Library.theme.tertiary
    selectedBtn.Text = tostring(default)
    selectedBtn.TextColor3 = Library.theme.text
    selectedBtn.TextSize = 14
    selectedBtn.Font = Enum.Font.Gotham
    selectedBtn.Parent = dropdownFrame

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 6)
    selCorner.Parent = selectedBtn

    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.fromOffset(150, 0)
    dropdownList.Position = UDim2.new(1, -150, 1, 5)
    dropdownList.BackgroundColor3 = Library.theme.secondary
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ClipsDescendants = true
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdownFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Library.theme.border
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = dropdownList

    local open = false
    local selected = default

    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = tostring(option)
        optBtn.TextColor3 = Library.theme.text
        optBtn.TextSize = 13
        optBtn.Font = Enum.Font.Gotham
        optBtn.Parent = dropdownList

        optBtn.MouseButton1Click:Connect(function()
            selected = option
            selectedBtn.Text = tostring(option)
            dropdownList.Visible = false
            open = false
            if callback then callback(option) end
        end)

        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundTransparency = 0.8
            optBtn.BackgroundColor3 = Library.theme.accent
        end)

        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
        end)
    end

    selectedBtn.MouseButton1Click:Connect(function()
        open = not open
        dropdownList.Visible = open
        dropdownList.Size = UDim2.fromOffset(150, math.min(#options * 27 + 10, 200))
    end)

    -- Close on click outside
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and open then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local listPos = dropdownList.AbsolutePosition
            local listSize = dropdownList.AbsoluteSize

            if mousePos.X < listPos.X or mousePos.X > listPos.X + listSize.X or
               mousePos.Y < listPos.Y or mousePos.Y > listPos.Y + listSize.Y then
                dropdownList.Visible = false
                open = false
            end
        end
    end)

    return {frame = dropdownFrame, getValue = function() return selected end, setValue = function(v) selected = v end}
end

---Create a keybind
---@param section table
---@param name string
---@param default Enum.KeyCode?
---@param callback function
---@return table
function Library.createKeybind(section, name, default, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind_" .. name
    keybindFrame.Size = UDim2.new(1, 0, 0, 35)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.Parent = section.content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Library.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Name = "KeybindBtn"
    keybindBtn.Size = UDim2.fromOffset(100, 30)
    keybindBtn.Position = UDim2.new(1, -100, 0.5, -15)
    keybindBtn.BackgroundColor3 = Library.theme.tertiary
    keybindBtn.Text = default and default.Name or "None"
    keybindBtn.TextColor3 = Library.theme.text
    keybindBtn.TextSize = 13
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.Parent = keybindFrame

    local kbCorner = Instance.new("UICorner")
    kbCorner.CornerRadius = UDim.new(0, 6)
    kbCorner.Parent = keybindBtn

    local binding = false
    local currentKey = default

    keybindBtn.MouseButton1Click:Connect(function()
        binding = true
        keybindBtn.Text = "..."
        keybindBtn.TextColor3 = Library.theme.accent
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            currentKey = input.KeyCode
            keybindBtn.Text = input.KeyCode.Name
            keybindBtn.TextColor3 = Library.theme.text
            if callback then callback(input.KeyCode) end
        elseif not binding and not gameProcessed and currentKey and input.KeyCode == currentKey then
            if callback then callback(input.KeyCode) end
        end
    end)

    return {frame = keybindFrame, getKey = function() return currentKey end, setKey = function(k) currentKey = k end}
end

---Create a label
---@param section table
---@param text string
---@return table
function Library.createLabel(section, text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Library.theme.textDim
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section.content

    return {frame = label, setText = function(t) label.Text = t end}
end

---Destroy a window
---@param window table
function Library.destroyWindow(window)
    if window.screenGui then
        window.screenGui:Destroy()
    end
    Library.windows[window.mainFrame.Name] = nil
end

return Library