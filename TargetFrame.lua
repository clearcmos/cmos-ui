local addonName, CMOS = ...

-- Target frame configuration (mirrors player frame)
local CONFIG = {
    width = 200,
    height = 50,
    barHeight = 12,
    xOffset = 300,   -- Right of center
    yOffset = 200,   -- Above action bars (positive = up from bottom)

    -- Buff/Debuff settings
    auraSize = 20,
    auraSpacing = 2,
    maxBuffs = 16,
    maxDebuffs = 16,

    -- Cast bar settings
    castBarHeight = 14,

    -- Colors (from theme)
    bgColor = {0.1, 0.1, 0.1, 0.85},
    borderColor = {0.3, 0.3, 0.3, 1},
    bgDark = {0.05, 0.05, 0.05, 0.8},

    -- Cast bar colors
    castColor = {0.4, 0.6, 0.9, 1},
    channelColor = {0.3, 0.8, 0.3, 1},
    uninterruptibleColor = {0.7, 0.7, 0.7, 1},

    -- Power colors
    manaColor = {0.2, 0.4, 0.8, 1},
    rageColor = {0.8, 0.2, 0.2, 1},
    energyColor = {0.9, 0.8, 0.2, 1},
    focusColor = {0.9, 0.5, 0.2, 1},

    -- Reaction colors
    friendlyColor = {0.2, 0.7, 0.2, 1},
    neutralColor = {0.9, 0.7, 0.2, 1},
    hostileColor = {0.8, 0.2, 0.2, 1},
}

-- Create the target frame
local function CreateTargetFrame()
    local frame = CreateFrame("Frame", "CMOSTargetFrame", UIParent, "BackdropTemplate")
    frame:SetSize(CONFIG.width, CONFIG.height)
    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", CONFIG.xOffset, CONFIG.yOffset)
    frame:SetFrameStrata("LOW")

    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(CONFIG.bgColor))
    frame:SetBackdropBorderColor(unpack(CONFIG.borderColor))

    -- Start hidden (no target)
    frame:Hide()

    -- Inner content area (with padding)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 4, -4)
    content:SetPoint("BOTTOMRIGHT", -4, 4)

    -- Right side container for name and bars (mirrored layout)
    local leftSide = CreateFrame("Frame", nil, content)
    leftSide:SetPoint("LEFT", content, "LEFT", 0, 0)
    leftSide:SetPoint("RIGHT", content, "RIGHT", -34, 0)
    leftSide:SetPoint("TOP", content, "TOP", 0, 0)
    leftSide:SetPoint("BOTTOM", content, "BOTTOM", 0, 0)

    -- Level text (right side - mirrored from player)
    local levelText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    levelText:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    levelText:SetWidth(28)
    levelText:SetJustifyH("CENTER")
    levelText:SetTextColor(1, 0.82, 0)  -- Gold color for level
    frame.LevelText = levelText

    -- Name text
    local nameText = leftSide:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPRIGHT", leftSide, "TOPRIGHT", 0, 0)
    nameText:SetPoint("LEFT", leftSide, "LEFT", 0, 0)
    nameText:SetHeight(14)
    nameText:SetJustifyH("RIGHT")
    nameText:SetWordWrap(false)
    frame.NameText = nameText

    -- Health bar container
    local healthContainer = CreateFrame("Frame", nil, leftSide, "BackdropTemplate")
    healthContainer:SetPoint("TOPRIGHT", nameText, "BOTTOMRIGHT", 0, -2)
    healthContainer:SetPoint("LEFT", leftSide, "LEFT", 0, 0)
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
    healthBar:SetReverseFill(true)  -- Fill from right to left
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
    local powerContainer = CreateFrame("Frame", nil, leftSide, "BackdropTemplate")
    powerContainer:SetPoint("TOPRIGHT", healthContainer, "BOTTOMRIGHT", 0, -2)
    powerContainer:SetPoint("LEFT", leftSide, "LEFT", 0, 0)
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
    powerBar:SetReverseFill(true)  -- Fill from right to left
    frame.PowerBar = powerBar

    -- Power bar background
    local powerBg = powerBar:CreateTexture(nil, "BACKGROUND")
    powerBg:SetAllPoints()
    powerBg:SetColorTexture(0.05, 0.05, 0.05, 0.8)

    -- Power text (percentage)
    local powerText = powerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    powerText:SetPoint("CENTER", powerBar, "CENTER", 0, 0)
    frame.PowerText = powerText

    -- ============ CAST BAR ============
    local castContainer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    castContainer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -4)
    castContainer:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    castContainer:SetHeight(CONFIG.castBarHeight + 4)
    castContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    castContainer:SetBackdropColor(unpack(CONFIG.bgColor))
    castContainer:SetBackdropBorderColor(unpack(CONFIG.borderColor))
    castContainer:Hide()
    frame.CastContainer = castContainer

    local castBar = CreateFrame("StatusBar", nil, castContainer)
    castBar:SetPoint("TOPLEFT", 2, -2)
    castBar:SetPoint("BOTTOMRIGHT", -2, 2)
    castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    castBar:SetStatusBarColor(unpack(CONFIG.castColor))
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0)
    frame.CastBar = castBar

    local castBg = castBar:CreateTexture(nil, "BACKGROUND")
    castBg:SetAllPoints()
    castBg:SetColorTexture(0.05, 0.05, 0.05, 0.8)

    local castText = castBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    castText:SetPoint("LEFT", castBar, "LEFT", 2, 0)
    castText:SetJustifyH("LEFT")
    frame.CastText = castText

    local castTime = castBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    castTime:SetPoint("RIGHT", castBar, "RIGHT", -2, 0)
    castTime:SetJustifyH("RIGHT")
    frame.CastTime = castTime

    -- Cast bar state
    frame.casting = false
    frame.channeling = false
    frame.castStartTime = 0
    frame.castEndTime = 0
    frame.castMaxDuration = 0

    -- ============ BUFFS (above frame) ============
    local buffContainer = CreateFrame("Frame", nil, frame)
    buffContainer:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 4)
    buffContainer:SetSize(CONFIG.width, CONFIG.auraSize)
    frame.BuffContainer = buffContainer
    frame.BuffIcons = {}

    for i = 1, CONFIG.maxBuffs do
        local buff = CreateFrame("Frame", nil, buffContainer, "BackdropTemplate")
        buff:SetSize(CONFIG.auraSize, CONFIG.auraSize)
        buff:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        buff:SetBackdropColor(0, 0, 0, 1)
        buff:SetBackdropBorderColor(0, 0, 0, 1)
        buff:Hide()

        local icon = buff:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        buff.Icon = icon

        local countText = buff:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        countText:SetPoint("BOTTOMRIGHT", -1, 1)
        buff.Count = countText

        local durationText = buff:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        durationText:SetPoint("TOP", buff, "BOTTOM", 0, -1)
        durationText:SetTextColor(1, 1, 1)
        buff.Duration = durationText

        frame.BuffIcons[i] = buff
    end

    -- ============ DEBUFFS (below cast bar) ============
    local debuffContainer = CreateFrame("Frame", nil, frame)
    debuffContainer:SetPoint("TOPLEFT", castContainer, "BOTTOMLEFT", 0, -4)
    debuffContainer:SetSize(CONFIG.width, CONFIG.auraSize)
    frame.DebuffContainer = debuffContainer
    frame.DebuffIcons = {}

    for i = 1, CONFIG.maxDebuffs do
        local debuff = CreateFrame("Frame", nil, debuffContainer, "BackdropTemplate")
        debuff:SetSize(CONFIG.auraSize, CONFIG.auraSize)
        debuff:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        debuff:SetBackdropColor(0, 0, 0, 1)
        debuff:SetBackdropBorderColor(0.8, 0, 0, 1)  -- Red border for debuffs
        debuff:Hide()

        local icon = debuff:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        debuff.Icon = icon

        local countText = debuff:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        countText:SetPoint("BOTTOMRIGHT", -1, 1)
        debuff.Count = countText

        local durationText = debuff:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        durationText:SetPoint("TOP", debuff, "BOTTOM", 0, -1)
        durationText:SetTextColor(1, 1, 1)
        debuff.Duration = durationText

        frame.DebuffIcons[i] = debuff
    end

    return frame
end

-- Get color based on unit reaction
local function GetReactionColor(unit)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
            local c = RAID_CLASS_COLORS[class]
            return c.r, c.g, c.b, 1
        end
    end

    -- NPC reaction colors
    local reaction = UnitReaction(unit, "player")
    if reaction then
        if reaction >= 5 then
            return unpack(CONFIG.friendlyColor)
        elseif reaction == 4 then
            return unpack(CONFIG.neutralColor)
        else
            return unpack(CONFIG.hostileColor)
        end
    end

    return unpack(CONFIG.hostileColor)
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

-- Update target info (name, level, colors)
local function UpdateTargetInfo(frame)
    if not UnitExists("target") then
        frame:Hide()
        return
    end

    frame:Show()

    local name = UnitName("target")
    local level = UnitLevel("target")

    frame.NameText:SetText(name)

    -- Show skull for ?? level
    if level == -1 then
        frame.LevelText:SetText("??")
        frame.LevelText:SetTextColor(1, 0.1, 0.1)
    else
        frame.LevelText:SetText(level)
        frame.LevelText:SetTextColor(1, 0.82, 0)
    end

    -- Set health bar to reaction color
    local r, g, b = GetReactionColor("target")
    frame.HealthBar:SetStatusBarColor(r, g, b, 1)
    frame.NameText:SetTextColor(r, g, b, 1)

    -- Set power bar color
    local powerType = UnitPowerType("target")
    frame.PowerBar:SetStatusBarColor(GetPowerColor(powerType))
end

-- Update health values
local function UpdateHealth(frame)
    if not UnitExists("target") then return end

    local health = UnitHealth("target")
    local maxHealth = UnitHealthMax("target")

    if maxHealth > 0 then
        local percent = health / maxHealth
        frame.HealthBar:SetValue(percent)
        frame.HealthText:SetText(string.format("%d%%", percent * 100))
    else
        frame.HealthBar:SetValue(0)
        frame.HealthText:SetText("0%")
    end
end

-- Update power values
local function UpdatePower(frame)
    if not UnitExists("target") then return end

    local power = UnitPower("target")
    local maxPower = UnitPowerMax("target")

    if maxPower > 0 then
        local percent = power / maxPower
        frame.PowerBar:SetValue(percent)
        frame.PowerText:SetText(string.format("%d%%", percent * 100))
        frame.PowerContainer:Show()
    else
        frame.PowerBar:SetValue(0)
        frame.PowerText:SetText("")
        -- Hide power bar for units without power
        frame.PowerContainer:Hide()
    end
end

-- Format duration text
local function FormatDuration(duration)
    if duration >= 3600 then
        return string.format("%dh", math.floor(duration / 3600))
    elseif duration >= 60 then
        return string.format("%dm", math.floor(duration / 60))
    elseif duration >= 1 then
        return string.format("%d", math.floor(duration))
    else
        return ""
    end
end

-- Update buffs display
local function UpdateBuffs(frame)
    if not UnitExists("target") then
        for i = 1, CONFIG.maxBuffs do
            frame.BuffIcons[i]:Hide()
        end
        return
    end

    local buffIndex = 1
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime = UnitBuff("target", i)
        if not name then break end
        if buffIndex <= CONFIG.maxBuffs then
            local buff = frame.BuffIcons[buffIndex]
            buff.Icon:SetTexture(icon)

            if count and count > 1 then
                buff.Count:SetText(count)
            else
                buff.Count:SetText("")
            end

            -- Position
            local row = math.floor((buffIndex - 1) / 8)
            local col = (buffIndex - 1) % 8
            buff:ClearAllPoints()
            buff:SetPoint("BOTTOMLEFT", frame.BuffContainer, "BOTTOMLEFT",
                col * (CONFIG.auraSize + CONFIG.auraSpacing),
                row * (CONFIG.auraSize + CONFIG.auraSpacing + 10))

            -- Store expiration for OnUpdate
            buff.expirationTime = expirationTime
            buff.duration = duration

            buff:Show()
            buffIndex = buffIndex + 1
        end
    end

    -- Hide unused buff frames
    for i = buffIndex, CONFIG.maxBuffs do
        frame.BuffIcons[i]:Hide()
    end
end

-- Update debuffs display
local function UpdateDebuffs(frame)
    if not UnitExists("target") then
        for i = 1, CONFIG.maxDebuffs do
            frame.DebuffIcons[i]:Hide()
        end
        return
    end

    local debuffIndex = 1
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("target", i)
        if not name then break end
        if debuffIndex <= CONFIG.maxDebuffs then
            local debuff = frame.DebuffIcons[debuffIndex]
            debuff.Icon:SetTexture(icon)

            if count and count > 1 then
                debuff.Count:SetText(count)
            else
                debuff.Count:SetText("")
            end

            -- Color border by debuff type
            if debuffType == "Magic" then
                debuff:SetBackdropBorderColor(0.2, 0.6, 1, 1)
            elseif debuffType == "Curse" then
                debuff:SetBackdropBorderColor(0.6, 0, 1, 1)
            elseif debuffType == "Disease" then
                debuff:SetBackdropBorderColor(0.6, 0.4, 0, 1)
            elseif debuffType == "Poison" then
                debuff:SetBackdropBorderColor(0, 0.6, 0, 1)
            else
                debuff:SetBackdropBorderColor(0.8, 0, 0, 1)
            end

            -- Position
            local row = math.floor((debuffIndex - 1) / 8)
            local col = (debuffIndex - 1) % 8
            debuff:ClearAllPoints()
            debuff:SetPoint("TOPLEFT", frame.DebuffContainer, "TOPLEFT",
                col * (CONFIG.auraSize + CONFIG.auraSpacing),
                -row * (CONFIG.auraSize + CONFIG.auraSpacing + 10))

            -- Store expiration for OnUpdate
            debuff.expirationTime = expirationTime
            debuff.duration = duration

            debuff:Show()
            debuffIndex = debuffIndex + 1
        end
    end

    -- Hide unused debuff frames
    for i = debuffIndex, CONFIG.maxDebuffs do
        frame.DebuffIcons[i]:Hide()
    end
end

-- Update auras (buffs + debuffs)
local function UpdateAuras(frame)
    UpdateBuffs(frame)
    UpdateDebuffs(frame)
end

-- Start target cast
local function StartTargetCast(frame)
    if not UnitExists("target") then return end

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target")

    if not name then return end

    frame.casting = true
    frame.channeling = false
    frame.castStartTime = startTime / 1000
    frame.castEndTime = endTime / 1000
    frame.castMaxDuration = frame.castEndTime - frame.castStartTime

    frame.CastText:SetText(name)

    if notInterruptible then
        frame.CastBar:SetStatusBarColor(unpack(CONFIG.uninterruptibleColor))
    else
        frame.CastBar:SetStatusBarColor(unpack(CONFIG.castColor))
    end

    frame.CastBar:SetMinMaxValues(0, 1)
    frame.CastBar:SetValue(0)
    frame.CastContainer:Show()
end

-- Start target channel
local function StartTargetChannel(frame)
    if not UnitExists("target") then return end

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("target")

    if not name then return end

    frame.casting = false
    frame.channeling = true
    frame.castStartTime = startTime / 1000
    frame.castEndTime = endTime / 1000
    frame.castMaxDuration = frame.castEndTime - frame.castStartTime

    frame.CastText:SetText(name)

    if notInterruptible then
        frame.CastBar:SetStatusBarColor(unpack(CONFIG.uninterruptibleColor))
    else
        frame.CastBar:SetStatusBarColor(unpack(CONFIG.channelColor))
    end

    frame.CastBar:SetMinMaxValues(0, 1)
    frame.CastBar:SetValue(1)
    frame.CastContainer:Show()
end

-- Stop target cast
local function StopTargetCast(frame)
    frame.casting = false
    frame.channeling = false
    frame.CastContainer:Hide()
end

-- OnUpdate for cast bar and aura durations
local function OnUpdate(frame, elapsed)
    local currentTime = GetTime()

    -- Update cast bar
    if frame.casting then
        local duration = currentTime - frame.castStartTime
        if duration >= frame.castMaxDuration then
            StopTargetCast(frame)
        else
            local progress = duration / frame.castMaxDuration
            frame.CastBar:SetValue(progress)
            local remaining = frame.castMaxDuration - duration
            frame.CastTime:SetText(string.format("%.1fs", remaining))
        end
    elseif frame.channeling then
        local remaining = frame.castEndTime - currentTime
        if remaining <= 0 then
            StopTargetCast(frame)
        else
            local progress = remaining / frame.castMaxDuration
            frame.CastBar:SetValue(progress)
            frame.CastTime:SetText(string.format("%.1fs", remaining))
        end
    end

    -- Update buff durations
    for i = 1, CONFIG.maxBuffs do
        local buff = frame.BuffIcons[i]
        if buff:IsShown() and buff.expirationTime then
            local remaining = buff.expirationTime - currentTime
            if remaining > 0 then
                buff.Duration:SetText(FormatDuration(remaining))
            else
                buff.Duration:SetText("")
            end
        end
    end

    -- Update debuff durations
    for i = 1, CONFIG.maxDebuffs do
        local debuff = frame.DebuffIcons[i]
        if debuff:IsShown() and debuff.expirationTime then
            local remaining = debuff.expirationTime - currentTime
            if remaining > 0 then
                debuff.Duration:SetText(FormatDuration(remaining))
            else
                debuff.Duration:SetText("")
            end
        end
    end
end

-- Event handler
local function OnEvent(self, event, unit, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        UpdateTargetInfo(self)
        UpdateHealth(self)
        UpdatePower(self)
        UpdateAuras(self)
        StopTargetCast(self)
        -- Check if target is already casting
        if UnitCastingInfo("target") then
            StartTargetCast(self)
        elseif UnitChannelInfo("target") then
            StartTargetChannel(self)
        end
    elseif event == "UNIT_HEALTH" then
        if unit == "target" then
            UpdateHealth(self)
        end
    elseif event == "UNIT_MAXHEALTH" then
        if unit == "target" then
            UpdateHealth(self)
        end
    elseif event == "UNIT_POWER_UPDATE" then
        if unit == "target" then
            UpdatePower(self)
        end
    elseif event == "UNIT_MAXPOWER" then
        if unit == "target" then
            UpdatePower(self)
        end
    elseif event == "UNIT_DISPLAYPOWER" then
        if unit == "target" then
            UpdatePower(self)
        end
    elseif event == "UNIT_AURA" then
        if unit == "target" then
            UpdateAuras(self)
        end
    elseif event == "UNIT_SPELLCAST_START" then
        if unit == "target" then
            StartTargetCast(self)
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        if unit == "target" then
            StartTargetChannel(self)
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or
           event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if unit == "target" then
            StopTargetCast(self)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateTargetInfo(self)
        UpdateHealth(self)
        UpdatePower(self)
        UpdateAuras(self)
    end
end

-- Hide default target frame
local function HideDefaultTargetFrame()
    if TargetFrame then
        TargetFrame:UnregisterAllEvents()
        TargetFrame:Hide()
        TargetFrame.Show = function() end
    end
    if ComboFrame then
        ComboFrame:UnregisterAllEvents()
        ComboFrame:Hide()
        ComboFrame.Show = function() end
    end
end

-- Initialize target frame
function CMOS:InitTargetFrame()
    local targetFrame = CreateTargetFrame()

    -- Register events
    targetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    targetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    targetFrame:RegisterEvent("UNIT_HEALTH")
    targetFrame:RegisterEvent("UNIT_MAXHEALTH")
    targetFrame:RegisterEvent("UNIT_POWER_UPDATE")
    targetFrame:RegisterEvent("UNIT_MAXPOWER")
    targetFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    targetFrame:RegisterEvent("UNIT_AURA")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_START")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    targetFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

    targetFrame:SetScript("OnEvent", OnEvent)
    targetFrame:SetScript("OnUpdate", OnUpdate)

    -- Hide default frame
    HideDefaultTargetFrame()

    -- Make frame movable (right-click to lock/unlock)
    CMOS:MakeFrameMovable(targetFrame, "TargetFrame", "BOTTOMLEFT", UIParent, "BOTTOM", CONFIG.xOffset, CONFIG.yOffset)

    -- Store reference
    CMOS.targetFrame = targetFrame

    self:Print("Target frame initialized (right-click to unlock/move)")
end
