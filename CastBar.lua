local addonName, CMOS = ...

-- Cast bar configuration
local CONFIG = {
    width = 250,
    height = 20,
    iconSize = 24,
    yOffset = 180,  -- Distance from bottom of screen

    -- Colors
    castColor = {0.4, 0.6, 0.9, 1},       -- Blue for regular casts
    channelColor = {0.3, 0.8, 0.3, 1},    -- Green for channels
    failedColor = {0.9, 0.3, 0.3, 1},     -- Red for failed/interrupted
    bgColor = {0.1, 0.1, 0.1, 0.85},      -- Dark background
    borderColor = {0.3, 0.3, 0.3, 1},     -- Subtle border
    sparkColor = {1, 1, 1, 0.8},          -- White spark

    -- Animation
    smoothing = 0.05,  -- Smoothing factor for bar fill (lower = more responsive)
}

-- Create the cast bar frame
local function CreateCastBar()
    local frame = CreateFrame("Frame", "CMOSCastBar", UIParent)
    frame:SetSize(CONFIG.width + CONFIG.iconSize + 4, CONFIG.height)
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, CONFIG.yOffset)
    frame:SetFrameStrata("MEDIUM")
    frame:Hide()

    -- Icon background/border (dark border behind icon)
    local iconBorder = frame:CreateTexture(nil, "BACKGROUND")
    iconBorder:SetSize(CONFIG.iconSize + 4, CONFIG.iconSize + 4)
    iconBorder:SetPoint("LEFT", frame, "LEFT", -2, 0)
    iconBorder:SetColorTexture(0, 0, 0, 1)
    frame.IconBorder = iconBorder

    -- Icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(CONFIG.iconSize, CONFIG.iconSize)
    icon:SetPoint("CENTER", iconBorder, "CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)  -- Trim icon borders
    frame.Icon = icon

    -- Bar container
    local barContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    barContainer:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    barContainer:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    barContainer:SetHeight(CONFIG.height)
    barContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    barContainer:SetBackdropColor(unpack(CONFIG.bgColor))
    barContainer:SetBackdropBorderColor(unpack(CONFIG.borderColor))
    frame.BarContainer = barContainer

    -- Status bar
    local bar = CreateFrame("StatusBar", nil, barContainer)
    bar:SetPoint("TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMRIGHT", -2, 2)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetStatusBarColor(unpack(CONFIG.castColor))
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    frame.Bar = bar

    -- Bar background (darker shade behind the fill)
    local barBg = bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetColorTexture(0.05, 0.05, 0.05, 0.8)

    -- Spark (glow at the edge of progress)
    local spark = bar:CreateTexture(nil, "OVERLAY")
    spark:SetSize(12, CONFIG.height + 8)
    spark:SetBlendMode("ADD")
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    frame.Spark = spark

    -- Spell name text
    local spellText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    spellText:SetPoint("LEFT", bar, "LEFT", 4, 0)
    spellText:SetJustifyH("LEFT")
    spellText:SetWidth(CONFIG.width - 60)
    spellText:SetWordWrap(false)
    frame.SpellText = spellText

    -- Time text
    local timeText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    timeText:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
    timeText:SetJustifyH("RIGHT")
    frame.TimeText = timeText

    -- Store state
    frame.casting = false
    frame.channeling = false
    frame.startTime = 0
    frame.endTime = 0
    frame.duration = 0
    frame.maxDuration = 0
    frame.displayValue = 0  -- For smooth animation

    return frame
end

-- Update spark position
local function UpdateSpark(frame)
    local bar = frame.Bar
    local spark = frame.Spark
    local value = bar:GetValue()
    local min, max = bar:GetMinMaxValues()

    if value > min and value < max then
        local width = bar:GetWidth()
        local position = (value - min) / (max - min) * width
        spark:SetPoint("CENTER", bar, "LEFT", position, 0)
        spark:Show()
    else
        spark:Hide()
    end
end

-- Smooth value transition
local function SmoothValue(current, target, smoothing, elapsed)
    if math.abs(current - target) < 0.001 then
        return target
    end
    local diff = target - current
    local change = diff * math.min(1, elapsed / smoothing)
    return current + change
end

-- OnUpdate handler for smooth animation
local function OnUpdate(self, elapsed)
    if self.casting then
        local currentTime = GetTime()
        self.duration = currentTime - self.startTime

        if self.duration >= self.maxDuration then
            self:Hide()
            self.casting = false
            return
        end

        local progress = self.duration / self.maxDuration

        -- Smooth the display value
        self.displayValue = SmoothValue(self.displayValue, progress, CONFIG.smoothing, elapsed)
        self.Bar:SetValue(self.displayValue)

        -- Update time text
        local remaining = self.maxDuration - self.duration
        self.TimeText:SetText(string.format("%.1fs", remaining))

        UpdateSpark(self)

    elseif self.channeling then
        local currentTime = GetTime()
        self.duration = self.endTime - currentTime

        if self.duration <= 0 then
            self:Hide()
            self.channeling = false
            return
        end

        local progress = self.duration / self.maxDuration

        -- Smooth the display value
        self.displayValue = SmoothValue(self.displayValue, progress, CONFIG.smoothing, elapsed)
        self.Bar:SetValue(self.displayValue)

        -- Update time text
        self.TimeText:SetText(string.format("%.1fs", self.duration))

        UpdateSpark(self)
    end
end

-- Debug mode
CMOS.debugCastBar = false

-- Start casting
local function StartCast(frame, unit)
    if unit ~= "player" then return end

    local name, text, texture, startTime, endTime = UnitCastingInfo("player")

    if not name then return end

    -- Debug output
    if CMOS.debugCastBar then
        CMOS:Print("=== CAST START ===")
        CMOS:Print("name: " .. tostring(name))
        CMOS:Print("text: " .. tostring(text))
        CMOS:Print("texture: " .. tostring(texture))
        CMOS:Print("startTime: " .. tostring(startTime))
        CMOS:Print("endTime: " .. tostring(endTime))
        local fallbackTexture = GetSpellTexture(name)
        CMOS:Print("GetSpellTexture(name): " .. tostring(fallbackTexture))
    end

    frame.casting = true
    frame.channeling = false
    frame.startTime = startTime / 1000
    frame.endTime = endTime / 1000
    frame.maxDuration = frame.endTime - frame.startTime
    frame.duration = 0
    frame.displayValue = 0

    frame.SpellText:SetText(name)

    -- Set icon texture (with fallback)
    if texture then
        frame.Icon:SetTexture(texture)
    else
        -- Try to get texture from spell name
        local spellTexture = GetSpellTexture(name)
        frame.Icon:SetTexture(spellTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
    end

    frame.Bar:SetStatusBarColor(unpack(CONFIG.castColor))
    frame.Bar:SetMinMaxValues(0, 1)
    frame.Bar:SetValue(0)

    frame:Show()
end

-- Start channeling
local function StartChannel(frame, unit)
    if unit ~= "player" then return end

    local name, text, texture, startTime, endTime = UnitChannelInfo("player")

    if not name then return end

    frame.casting = false
    frame.channeling = true
    frame.startTime = startTime / 1000
    frame.endTime = endTime / 1000
    frame.maxDuration = frame.endTime - frame.startTime
    frame.duration = frame.maxDuration
    frame.displayValue = 1

    frame.SpellText:SetText(name)

    -- Set icon texture (with fallback)
    if texture then
        frame.Icon:SetTexture(texture)
    else
        local spellTexture = GetSpellTexture(name)
        frame.Icon:SetTexture(spellTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
    end

    frame.Bar:SetStatusBarColor(unpack(CONFIG.channelColor))
    frame.Bar:SetMinMaxValues(0, 1)
    frame.Bar:SetValue(1)

    frame:Show()
end

-- Stop casting
local function StopCast(frame, unit, failed)
    if unit ~= "player" then return end

    if failed then
        frame.Bar:SetStatusBarColor(unpack(CONFIG.failedColor))
        frame.SpellText:SetText(INTERRUPTED or "Interrupted")
        frame.Spark:Hide()

        -- Fade out after a short delay
        C_Timer.After(0.3, function()
            if not frame.casting and not frame.channeling then
                frame:Hide()
            end
        end)
    else
        frame:Hide()
    end

    frame.casting = false
    frame.channeling = false
end

-- Handle cast delay (pushback)
local function CastDelayed(frame, unit)
    if unit ~= "player" then return end

    local name, text, texture, startTime, endTime = UnitCastingInfo("player")
    if not name then return end

    frame.startTime = startTime / 1000
    frame.endTime = endTime / 1000
    frame.maxDuration = frame.endTime - frame.startTime
end

-- Handle channel update
local function ChannelUpdate(frame, unit)
    if unit ~= "player" then return end

    local name, text, texture, startTime, endTime = UnitChannelInfo("player")
    if not name then return end

    frame.startTime = startTime / 1000
    frame.endTime = endTime / 1000
    frame.maxDuration = frame.endTime - frame.startTime
end

-- Event handler
local function OnEvent(self, event, unit, ...)
    if event == "UNIT_SPELLCAST_START" then
        StartCast(self, unit)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        StartChannel(self, unit)
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        StopCast(self, unit, false)
    elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        StopCast(self, unit, true)
    elseif event == "UNIT_SPELLCAST_DELAYED" then
        CastDelayed(self, unit)
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        ChannelUpdate(self, unit)
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Check if we're already casting (e.g., after reload)
        if UnitCastingInfo("player") then
            StartCast(self, "player")
        elseif UnitChannelInfo("player") then
            StartChannel(self, "player")
        end
    end
end

-- Hide default Blizzard cast bar
local function HideBlizzardCastBar()
    if CastingBarFrame then
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:Hide()
        CastingBarFrame.Show = function() end
    end

    -- Also hide PlayerCastingBarFrame if it exists (some versions)
    if PlayerCastingBarFrame then
        PlayerCastingBarFrame:UnregisterAllEvents()
        PlayerCastingBarFrame:Hide()
        PlayerCastingBarFrame.Show = function() end
    end
end

-- Initialize cast bar
function CMOS:InitCastBar()
    local castBar = CreateCastBar()

    -- Register events
    castBar:RegisterEvent("UNIT_SPELLCAST_START")
    castBar:RegisterEvent("UNIT_SPELLCAST_STOP")
    castBar:RegisterEvent("UNIT_SPELLCAST_FAILED")
    castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    castBar:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    castBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    castBar:SetScript("OnEvent", OnEvent)
    castBar:SetScript("OnUpdate", OnUpdate)

    -- Hide Blizzard cast bar
    HideBlizzardCastBar()

    -- Store reference
    CMOS.castBar = castBar

    self:Print("Cast bar initialized")
end
