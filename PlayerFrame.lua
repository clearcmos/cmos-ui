local addonName, CMOS = ...

-- Player frame configuration
local CONFIG = {
    width = 200,
    height = 50,
    barHeight = 12,
    xOffset = -300,  -- Left of center
    yOffset = 200,   -- Above action bars (positive = up from bottom)

    -- Colors (from theme)
    bgColor = {0.1, 0.1, 0.1, 0.85},
    borderColor = {0.3, 0.3, 0.3, 1},
    bgDark = {0.05, 0.05, 0.05, 0.8},

    -- Power colors
    manaColor = {0.2, 0.4, 0.8, 1},
    rageColor = {0.8, 0.2, 0.2, 1},
    energyColor = {0.9, 0.8, 0.2, 1},
    focusColor = {0.9, 0.5, 0.2, 1},
}

-- Create the player frame
local function CreatePlayerFrame()
    -- Use SecureUnitButtonTemplate for left-click targeting
    local frame = CreateFrame("Button", "CMOSPlayerFrame", UIParent, "SecureUnitButtonTemplate, BackdropTemplate")
    frame:SetSize(CONFIG.width, CONFIG.height)
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", CONFIG.xOffset, CONFIG.yOffset)
    frame:SetFrameStrata("LOW")

    -- Secure attributes for targeting
    frame:SetAttribute("unit", "player")
    frame:SetAttribute("type1", "target")  -- Left-click targets
    frame:RegisterForClicks("AnyUp")

    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(CONFIG.bgColor))
    frame:SetBackdropBorderColor(unpack(CONFIG.borderColor))

    -- Inner content area (with padding)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 4, -4)
    content:SetPoint("BOTTOMRIGHT", -4, 4)

    -- Level text (left side)
    local levelText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    levelText:SetPoint("LEFT", content, "LEFT", 0, 0)
    levelText:SetWidth(28)
    levelText:SetJustifyH("CENTER")
    levelText:SetTextColor(1, 0.82, 0)  -- Gold color for level
    frame.LevelText = levelText

    -- Right side container for name and bars
    local rightSide = CreateFrame("Frame", nil, content)
    rightSide:SetPoint("LEFT", levelText, "RIGHT", 6, 0)
    rightSide:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    rightSide:SetPoint("TOP", content, "TOP", 0, 0)
    rightSide:SetPoint("BOTTOM", content, "BOTTOM", 0, 0)

    -- Name text (left-aligned)
    local nameText = rightSide:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", rightSide, "TOPLEFT", 0, 0)
    nameText:SetPoint("RIGHT", rightSide, "RIGHT", 0, 0)
    nameText:SetHeight(14)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    frame.NameText = nameText

    -- Health bar container
    local healthContainer = CreateFrame("Frame", nil, rightSide, "BackdropTemplate")
    healthContainer:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
    healthContainer:SetPoint("RIGHT", rightSide, "RIGHT", 0, 0)
    healthContainer:SetHeight(CONFIG.barHeight)
    healthContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    healthContainer:SetBackdropColor(unpack(CONFIG.bgDark))
    healthContainer:SetBackdropBorderColor(unpack(CONFIG.borderColor))
    frame.HealthContainer = healthContainer

    -- Health bar
    local healthBar = CreateFrame("StatusBar", nil, healthContainer)
    healthBar:SetPoint("TOPLEFT", 1, -1)
    healthBar:SetPoint("BOTTOMRIGHT", -1, 1)
    healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(1)
    frame.HealthBar = healthBar

    -- Health bar background
    local healthBg = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints()
    healthBg:SetColorTexture(0.05, 0.05, 0.05, 0.8)

    -- Health text (percentage)
    local healthText = healthBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    frame.HealthText = healthText

    -- Mana/Power bar container
    local powerContainer = CreateFrame("Frame", nil, rightSide, "BackdropTemplate")
    powerContainer:SetPoint("TOPLEFT", healthContainer, "BOTTOMLEFT", 0, -2)
    powerContainer:SetPoint("RIGHT", rightSide, "RIGHT", 0, 0)
    powerContainer:SetHeight(CONFIG.barHeight)
    powerContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    powerContainer:SetBackdropColor(unpack(CONFIG.bgDark))
    powerContainer:SetBackdropBorderColor(unpack(CONFIG.borderColor))
    frame.PowerContainer = powerContainer

    -- Power bar
    local powerBar = CreateFrame("StatusBar", nil, powerContainer)
    powerBar:SetPoint("TOPLEFT", 1, -1)
    powerBar:SetPoint("BOTTOMRIGHT", -1, 1)
    powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    powerBar:SetMinMaxValues(0, 1)
    powerBar:SetValue(1)
    frame.PowerBar = powerBar

    -- Power bar background
    local powerBg = powerBar:CreateTexture(nil, "BACKGROUND")
    powerBg:SetAllPoints()
    powerBg:SetColorTexture(0.05, 0.05, 0.05, 0.8)

    -- Power text (percentage)
    local powerText = powerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    powerText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    frame.PowerText = powerText

    return frame
end

-- Get class color for player
local function GetPlayerClassColor()
    local _, class = UnitClass("player")
    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return c.r, c.g, c.b, 1
    end
    return 0.2, 0.7, 0.2, 1  -- Default green
end

-- Get power color based on power type
local function GetPowerColor(powerType)
    if powerType == 0 then  -- Mana
        return unpack(CONFIG.manaColor)
    elseif powerType == 1 then  -- Rage
        return unpack(CONFIG.rageColor)
    elseif powerType == 2 then  -- Focus
        return unpack(CONFIG.focusColor)
    elseif powerType == 3 then  -- Energy
        return unpack(CONFIG.energyColor)
    else
        return unpack(CONFIG.manaColor)
    end
end

-- Update player info (name, level, class color)
local function UpdatePlayerInfo(frame)
    local name = UnitName("player")
    local level = UnitLevel("player")

    frame.NameText:SetText(name)
    frame.LevelText:SetText(level)

    -- Set health bar to class color
    frame.HealthBar:SetStatusBarColor(GetPlayerClassColor())

    -- Set power bar color
    local powerType = UnitPowerType("player")
    frame.PowerBar:SetStatusBarColor(GetPowerColor(powerType))

    -- Set name to class color
    frame.NameText:SetTextColor(GetPlayerClassColor())
end

-- Update health values
local function UpdateHealth(frame)
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")

    if maxHealth > 0 then
        local percent = health / maxHealth
        frame.HealthBar:SetValue(percent)
        frame.HealthText:SetText(string.format("%d%%", percent * 100))
    else
        frame.HealthBar:SetValue(0)
        frame.HealthText:SetText("0%")
    end
end

-- Update power values (mana/rage/energy)
local function UpdatePower(frame)
    local power = UnitPower("player")
    local maxPower = UnitPowerMax("player")

    if maxPower > 0 then
        local percent = power / maxPower
        frame.PowerBar:SetValue(percent)
        frame.PowerText:SetText(string.format("%d%%", percent * 100))
    else
        frame.PowerBar:SetValue(0)
        frame.PowerText:SetText("")
    end

    -- Update power color in case it changed (e.g., druid form)
    local powerType = UnitPowerType("player")
    frame.PowerBar:SetStatusBarColor(GetPowerColor(powerType))
end

-- Event handler
local function OnEvent(self, event, unit, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdatePlayerInfo(self)
        UpdateHealth(self)
        UpdatePower(self)
    elseif event == "UNIT_HEALTH" then
        if unit == "player" then
            UpdateHealth(self)
        end
    elseif event == "UNIT_MAXHEALTH" then
        if unit == "player" then
            UpdateHealth(self)
        end
    elseif event == "UNIT_POWER_UPDATE" then
        if unit == "player" then
            UpdatePower(self)
        end
    elseif event == "UNIT_MAXPOWER" then
        if unit == "player" then
            UpdatePower(self)
        end
    elseif event == "UNIT_DISPLAYPOWER" then
        if unit == "player" then
            UpdatePower(self)
        end
    elseif event == "PLAYER_LEVEL_UP" then
        UpdatePlayerInfo(self)
    end
end

-- Hide default player frame
local function HideDefaultPlayerFrame()
    if PlayerFrame then
        PlayerFrame:UnregisterAllEvents()
        PlayerFrame:Hide()
        PlayerFrame.Show = function() end
    end
end

-- Initialize player frame
function CMOS:InitPlayerFrame()
    local playerFrame = CreatePlayerFrame()

    -- Force show
    playerFrame:Show()

    -- Register events
    playerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerFrame:RegisterEvent("UNIT_HEALTH")
    playerFrame:RegisterEvent("UNIT_MAXHEALTH")
    playerFrame:RegisterEvent("UNIT_POWER_UPDATE")
    playerFrame:RegisterEvent("UNIT_MAXPOWER")
    playerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    playerFrame:RegisterEvent("PLAYER_LEVEL_UP")

    playerFrame:SetScript("OnEvent", OnEvent)

    -- Hide default frame
    HideDefaultPlayerFrame()

    -- Make frame movable (right-click to lock/unlock)
    CMOS:MakeFrameMovable(playerFrame, "PlayerFrame", "BOTTOMRIGHT", UIParent, "BOTTOM", CONFIG.xOffset, CONFIG.yOffset)

    -- Store reference
    CMOS.playerFrame = playerFrame

    self:Print("Player frame initialized (right-click to unlock/move)")
end
