local addonName, CMOS = ...

-- Print XP progress
local function PrintXP()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local level = UnitLevel("player")
    local maxLevel = GetMaxPlayerLevel()

    if level >= maxLevel then
        CMOS:Print("Level " .. level .. " (Max level reached)")
        return
    end

    local percent = (currentXP / maxXP) * 100
    local remaining = maxXP - currentXP

    CMOS:Print(string.format("Level %d: %.1f%% (%s / %s XP, %s remaining)",
        level,
        percent,
        BreakUpLargeNumbers(currentXP),
        BreakUpLargeNumbers(maxXP),
        BreakUpLargeNumbers(remaining)))
end

-- Print help
local function PrintHelp()
    CMOS:Print("Commands:")
    print("  |cff00ccff/cmos xp|r - Show current XP percentage")
    print("  |cff00ccff/cmos bars <1-4>|r - Set number of bottom bars")
    print("  |cff00ccff/cmos left <0-2>|r - Set number of left side bars")
    print("  |cff00ccff/cmos right <0-2>|r - Set number of right side bars")
    print("  |cff00ccff/cmos status|r - Show current bar configuration")
    print("  |cff00ccff/cmos debug|r - Toggle cast bar debug output")
    print("  |cff00ccff/cmos help|r - Show this help message")
end

-- Print current status
local function PrintStatus()
    CMOS:Print("Current configuration:")
    print("  Bottom bars: " .. CMOS:GetSetting("bottomBars"))
    print("  Left side bars: " .. CMOS:GetSetting("leftBars"))
    print("  Right side bars: " .. CMOS:GetSetting("rightBars"))
end

-- Parse command arguments
local function ParseCommand(msg)
    msg = msg or ""
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end
    return args
end

-- Main slash command handler
SLASH_CMOS1 = "/cmos"
SLASH_CMOS2 = "/cmosui"
SlashCmdList["CMOS"] = function(msg)
    local args = ParseCommand(msg)
    local cmd = args[1]

    if not cmd or cmd == "help" then
        PrintHelp()

    elseif cmd == "xp" then
        PrintXP()

    elseif cmd == "bars" or cmd == "bottom" then
        local count = tonumber(args[2])
        if count then
            CMOS:SetBottomBars(count)
        else
            CMOS:Print("Usage: /cmos bars <1-4>")
        end

    elseif cmd == "left" then
        local count = tonumber(args[2])
        if count then
            CMOS:SetLeftBars(count)
        else
            CMOS:Print("Usage: /cmos left <0-2>")
        end

    elseif cmd == "right" then
        local count = tonumber(args[2])
        if count then
            CMOS:SetRightBars(count)
        else
            CMOS:Print("Usage: /cmos right <0-2>")
        end

    elseif cmd == "status" then
        PrintStatus()

    elseif cmd == "debug" then
        CMOS.debugCastBar = not CMOS.debugCastBar
        if CMOS.debugCastBar then
            CMOS:Print("Cast bar debug: |cff00ff00ON|r - Cast a spell to see API output")
        else
            CMOS:Print("Cast bar debug: |cffff0000OFF|r")
        end

    else
        CMOS:Print("Unknown command: " .. cmd)
        PrintHelp()
    end
end
