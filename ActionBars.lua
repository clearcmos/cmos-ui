local addonName, CMOS = ...

-- Action bar definitions
-- Classic has action slots 1-120
-- Main bar (pages): 1-12, 13-24, 25-36, 37-48, 49-60, 61-72 (pages 1-6)
-- Bar 2 (Bottom Left): 61-72
-- Bar 3 (Bottom Right): 49-60
-- Bar 4 (Right): 25-36
-- Bar 5 (Right 2): 37-48

local BAR_CONFIG = {
    -- Bottom bars
    {id = "Bar1", slots = 1, count = 12, type = "bottom", default = true},   -- Main action bar (paged)
    {id = "Bar2", slots = 61, count = 12, type = "bottom", default = true},  -- Bottom Left (MultiBarBottomLeft)
    {id = "Bar3", slots = 49, count = 12, type = "bottom", default = false}, -- Bottom Right (MultiBarBottomRight)
    {id = "Bar4", slots = 25, count = 12, type = "bottom", default = false}, -- Extra bottom
    -- Side bars
    {id = "BarL1", slots = 73, count = 12, type = "left", default = false},   -- Left side 1
    {id = "BarL2", slots = 85, count = 12, type = "left", default = false},   -- Left side 2
    {id = "BarR1", slots = 25, count = 12, type = "right", default = false},  -- Right side 1 (MultiBarRight)
    {id = "BarR2", slots = 37, count = 12, type = "right", default = false},  -- Right side 2 (MultiBarLeft)
}

-- Store created bars
CMOS.actionBars = {}

-- Button size and spacing
local BUTTON_SIZE = 36
local BUTTON_PADDING = 2  -- Tighter spacing

-- Minimal styling colors
local BORDER_COLOR = {0.2, 0.2, 0.2, 1}
local BG_COLOR = {0.05, 0.05, 0.05, 0.9}

-- Apply minimal styling to a button
local function StyleActionButton(button)
    local name = button:GetName()

    -- Hide default border/chrome textures
    local texturesToHide = {
        "Border",
        "NormalTexture",
        "NormalTexture2",
        "FloatingBG",
    }

    for _, texName in ipairs(texturesToHide) do
        local tex = _G[name .. texName] or button[texName]
        if tex then
            tex:SetAlpha(0)
        end
    end

    -- Reduce normal texture (the border that shows on buttons)
    local normalTex = button:GetNormalTexture()
    if normalTex then
        normalTex:SetAlpha(0)
    end

    -- Style the icon
    local icon = _G[name .. "Icon"] or button.icon
    if icon then
        icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)  -- Slight crop
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    end

    -- Create thin border
    if not button.cmosBorder then
        local border = button:CreateTexture(nil, "OVERLAY", nil, 7)
        border:SetAllPoints()
        border:SetColorTexture(0, 0, 0, 0)

        -- Use 1px border lines
        local edgeSize = 1
        local left = button:CreateTexture(nil, "OVERLAY", nil, 6)
        left:SetColorTexture(unpack(BORDER_COLOR))
        left:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        left:SetWidth(edgeSize)

        local right = button:CreateTexture(nil, "OVERLAY", nil, 6)
        right:SetColorTexture(unpack(BORDER_COLOR))
        right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        right:SetWidth(edgeSize)

        local top = button:CreateTexture(nil, "OVERLAY", nil, 6)
        top:SetColorTexture(unpack(BORDER_COLOR))
        top:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        top:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        top:SetHeight(edgeSize)

        local bottom = button:CreateTexture(nil, "OVERLAY", nil, 6)
        bottom:SetColorTexture(unpack(BORDER_COLOR))
        bottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
        bottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        bottom:SetHeight(edgeSize)

        button.cmosBorder = true
    end
end

-- Get keybind text for an action slot
local function GetActionButtonKeybindText(slot)
    local binding
    -- Map slots to binding names
    if slot >= 1 and slot <= 12 then
        -- Main action bar
        binding = GetBindingKey("ACTIONBUTTON" .. slot)
    elseif slot >= 61 and slot <= 72 then
        -- MultiBarBottomLeft (Bar 2)
        binding = GetBindingKey("MULTIACTIONBAR1BUTTON" .. (slot - 60))
    elseif slot >= 49 and slot <= 60 then
        -- MultiBarBottomRight (Bar 3)
        binding = GetBindingKey("MULTIACTIONBAR2BUTTON" .. (slot - 48))
    elseif slot >= 25 and slot <= 36 then
        -- MultiBarRight (Bar 4)
        binding = GetBindingKey("MULTIACTIONBAR3BUTTON" .. (slot - 24))
    elseif slot >= 37 and slot <= 48 then
        -- MultiBarLeft (Bar 5)
        binding = GetBindingKey("MULTIACTIONBAR4BUTTON" .. (slot - 36))
    end

    if not binding then
        return ""
    end

    -- Shorten common modifiers
    binding = binding:gsub("ALT%-", "A-")
    binding = binding:gsub("CTRL%-", "C-")
    binding = binding:gsub("SHIFT%-", "S-")
    binding = binding:gsub("NUMPAD", "N")

    return binding
end

-- Update hotkey text for a button
local function UpdateButtonHotkey(button)
    local hotkey = button.HotKey or _G[button:GetName() .. "HotKey"]
    if hotkey then
        local slot = button:GetAttribute("action") or button.actionSlot
        local text = GetActionButtonKeybindText(slot)
        hotkey:SetText(text)
        if text == "" then
            hotkey:Hide()
        else
            hotkey:Show()
            hotkey:SetVertexColor(0.9, 0.9, 0.9)
        end
    end
end

-- Create a single action button
local function CreateActionButton(parent, barID, index, actionSlot)
    local buttonName = "CMOSActionButton" .. barID .. "_" .. index
    local button = CreateFrame("CheckButton", buttonName, parent, "ActionBarButtonTemplate")

    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)

    -- Set the action for this button
    button:SetAttribute("type", "action")
    button:SetAttribute("action", actionSlot)

    -- Store reference
    button.actionSlot = actionSlot
    button.buttonIndex = index

    -- Set up hotkey text (use same font as Blizzard default)
    local hotkey = button.HotKey or _G[buttonName .. "HotKey"]
    if hotkey then
        hotkey:ClearAllPoints()
        hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -2)
    end

    -- Update button visuals
    button:SetScript("OnEvent", function(self, event, ...)
        if event == "ACTIONBAR_UPDATE_STATE" or
           event == "ACTIONBAR_UPDATE_USABLE" or
           event == "ACTIONBAR_UPDATE_COOLDOWN" then
            ActionButton_Update(self)
        elseif event == "UPDATE_BINDINGS" then
            UpdateButtonHotkey(self)
        end
    end)

    button:RegisterEvent("ACTIONBAR_UPDATE_STATE")
    button:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    button:RegisterEvent("UPDATE_BINDINGS")

    -- Initialize button state
    ActionButton_Update(button)
    UpdateButtonHotkey(button)

    -- Apply minimal styling
    StyleActionButton(button)

    return button
end

-- Create an action bar
local function CreateActionBar(config, index)
    local barFrame = CreateFrame("Frame", "CMOSActionBar_" .. config.id, UIParent, "SecureHandlerStateTemplate")
    barFrame.id = config.id
    barFrame.config = config
    barFrame.buttons = {}

    -- Create buttons for this bar
    for i = 1, config.count do
        local actionSlot = config.slots + i - 1
        local button = CreateActionButton(barFrame, config.id, i, actionSlot)
        barFrame.buttons[i] = button
    end

    -- Store the bar
    CMOS.actionBars[config.id] = barFrame

    return barFrame
end

-- Position bottom bars (centered, stacked)
local function PositionBottomBars()
    local bottomBars = {}

    -- Collect visible bottom bars
    for _, config in ipairs(BAR_CONFIG) do
        if config.type == "bottom" then
            local bar = CMOS.actionBars[config.id]
            if bar and bar:IsShown() then
                table.insert(bottomBars, bar)
            end
        end
    end

    if #bottomBars == 0 then return end

    local barWidth = (BUTTON_SIZE * 12) + (BUTTON_PADDING * 11)
    local barHeight = BUTTON_SIZE
    local yOffset = 8  -- Distance from bottom of screen

    for barIndex, bar in ipairs(bottomBars) do
        -- Position the bar frame
        bar:ClearAllPoints()
        bar:SetSize(barWidth, barHeight)
        bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, yOffset + ((barIndex - 1) * (barHeight + BUTTON_PADDING)))

        -- Position buttons within the bar
        for i, button in ipairs(bar.buttons) do
            button:ClearAllPoints()
            button:SetPoint("LEFT", bar, "LEFT", (i - 1) * (BUTTON_SIZE + BUTTON_PADDING), 0)
        end
    end
end

-- Position side bars (vertical, on sides of screen)
local function PositionSideBars()
    local leftBars = {}
    local rightBars = {}

    -- Collect visible side bars
    for _, config in ipairs(BAR_CONFIG) do
        local bar = CMOS.actionBars[config.id]
        if bar and bar:IsShown() then
            if config.type == "left" then
                table.insert(leftBars, bar)
            elseif config.type == "right" then
                table.insert(rightBars, bar)
            end
        end
    end

    local barWidth = BUTTON_SIZE
    local barHeight = (BUTTON_SIZE * 12) + (BUTTON_PADDING * 11)
    local xOffset = 8

    -- Position left bars
    for barIndex, bar in ipairs(leftBars) do
        bar:ClearAllPoints()
        bar:SetSize(barWidth, barHeight)
        bar:SetPoint("LEFT", UIParent, "LEFT", xOffset + ((barIndex - 1) * (barWidth + BUTTON_PADDING)), 0)

        for i, button in ipairs(bar.buttons) do
            button:ClearAllPoints()
            button:SetPoint("TOP", bar, "TOP", 0, -((i - 1) * (BUTTON_SIZE + BUTTON_PADDING)))
        end
    end

    -- Position right bars
    for barIndex, bar in ipairs(rightBars) do
        bar:ClearAllPoints()
        bar:SetSize(barWidth, barHeight)
        bar:SetPoint("RIGHT", UIParent, "RIGHT", -(xOffset + ((barIndex - 1) * (barWidth + BUTTON_PADDING))), 0)

        for i, button in ipairs(bar.buttons) do
            button:ClearAllPoints()
            button:SetPoint("TOP", bar, "TOP", 0, -((i - 1) * (BUTTON_SIZE + BUTTON_PADDING)))
        end
    end
end

-- Show/hide bars based on settings
local function UpdateBarVisibility()
    local bottomCount = CMOS:GetSetting("bottomBars")
    local leftCount = CMOS:GetSetting("leftBars")
    local rightCount = CMOS:GetSetting("rightBars")

    local bottomIndex = 0
    local leftIndex = 0
    local rightIndex = 0

    for _, config in ipairs(BAR_CONFIG) do
        local bar = CMOS.actionBars[config.id]
        if bar then
            local shouldShow = false

            if config.type == "bottom" then
                bottomIndex = bottomIndex + 1
                shouldShow = bottomIndex <= bottomCount
            elseif config.type == "left" then
                leftIndex = leftIndex + 1
                shouldShow = leftIndex <= leftCount
            elseif config.type == "right" then
                rightIndex = rightIndex + 1
                shouldShow = rightIndex <= rightCount
            end

            if shouldShow then
                bar:Show()
            else
                bar:Hide()
            end
        end
    end
end

-- Layout all bars
function CMOS:LayoutBars()
    UpdateBarVisibility()
    PositionBottomBars()
    PositionSideBars()
end

-- Set number of bottom bars
function CMOS:SetBottomBars(count)
    count = math.max(1, math.min(4, count))
    self:SetSetting("bottomBars", count)
    self:LayoutBars()
    self:Print("Bottom bars set to " .. count)
end

-- Set number of left side bars
function CMOS:SetLeftBars(count)
    count = math.max(0, math.min(2, count))
    self:SetSetting("leftBars", count)
    self:LayoutBars()
    self:Print("Left side bars set to " .. count)
end

-- Set number of right side bars
function CMOS:SetRightBars(count)
    count = math.max(0, math.min(2, count))
    self:SetSetting("rightBars", count)
    self:LayoutBars()
    self:Print("Right side bars set to " .. count)
end

-- Initialize all action bars
function CMOS:InitActionBars()
    -- Create all bars
    for index, config in ipairs(BAR_CONFIG) do
        CreateActionBar(config, index)
    end

    -- Layout bars according to settings
    self:LayoutBars()

    -- Handle paging for main action bar (Bar1)
    local mainBar = CMOS.actionBars["Bar1"]
    if mainBar then
        -- Register for stance/form changes to update paging
        mainBar:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
        mainBar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
        mainBar:SetScript("OnEvent", function(self, event)
            CMOS:UpdateMainBarPaging()
        end)
    end

    self:UpdateMainBarPaging()
end

-- Update main bar paging based on stance/form
function CMOS:UpdateMainBarPaging()
    local mainBar = CMOS.actionBars["Bar1"]
    if not mainBar then return end

    local page = GetActionBarPage()
    local bonusBar = GetBonusBarOffset()

    -- Calculate actual page
    local actualPage = page
    if bonusBar > 0 then
        actualPage = bonusBar + 6  -- Bonus bars start at slot 73+
    end

    -- Update button actions based on page
    local startSlot = ((actualPage - 1) * 12) + 1
    for i, button in ipairs(mainBar.buttons) do
        local newSlot = startSlot + i - 1
        button:SetAttribute("action", newSlot)
        button.actionSlot = newSlot
        ActionButton_Update(button)
        UpdateButtonHotkey(button)
    end
end

-- Update all button hotkeys (called on binding changes)
function CMOS:UpdateAllHotkeys()
    for _, bar in pairs(self.actionBars) do
        if bar.buttons then
            for _, button in ipairs(bar.buttons) do
                UpdateButtonHotkey(button)
            end
        end
    end
end

-- Register for layout events
local layoutFrame = CreateFrame("Frame")
layoutFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
layoutFrame:RegisterEvent("UI_SCALE_CHANGED")
layoutFrame:RegisterEvent("UPDATE_BINDINGS")
layoutFrame:SetScript("OnEvent", function(self, event)
    if CMOS.actionBars["Bar1"] then
        if event == "UPDATE_BINDINGS" then
            CMOS:UpdateAllHotkeys()
        else
            CMOS:LayoutBars()
        end
    end
end)
