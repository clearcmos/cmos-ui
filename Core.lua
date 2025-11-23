local addonName, CMOS = ...

-- Addon namespace
CMOS.version = "1.0.0"
CMOS.bars = {}

-- Default settings
local defaults = {
    bottomBars = 2,     -- Number of bottom action bars (1-4)
    leftBars = 0,       -- Number of left side bars (0-2)
    rightBars = 0,      -- Number of right side bars (0-2)
    buttonSize = 36,    -- Button size in pixels
    buttonPadding = 4,  -- Padding between buttons
    showKeybinds = true,
    showMacroText = true,
}

local charDefaults = {
    -- Per-character overrides if needed
}

-- Initialize saved variables
local function InitializeDB()
    if not CMOSDB then
        CMOSDB = {}
    end
    for k, v in pairs(defaults) do
        if CMOSDB[k] == nil then
            CMOSDB[k] = v
        end
    end

    if not CMOSCharDB then
        CMOSCharDB = {}
    end
    for k, v in pairs(charDefaults) do
        if CMOSCharDB[k] == nil then
            CMOSCharDB[k] = v
        end
    end
end

-- Get a setting value
function CMOS:GetSetting(key)
    -- Character settings take priority
    if CMOSCharDB and CMOSCharDB[key] ~= nil then
        return CMOSCharDB[key]
    end
    return CMOSDB and CMOSDB[key] or defaults[key]
end

-- Set a setting value
function CMOS:SetSetting(key, value)
    if CMOSDB then
        CMOSDB[key] = value
    end
end

-- Print helper with addon prefix
function CMOS:Print(msg)
    print("|cff00ccffCMOS-UI:|r " .. tostring(msg))
end

-- Hide a frame safely (handles nil and prevents re-showing)
local function HideFrame(frame)
    if frame then
        frame:Hide()
        frame:SetAlpha(0)
        frame:SetScale(0.001)
        -- Prevent it from showing again
        frame.Show = function() end
    end
end

-- Hide a frame by name
local function HideFrameByName(name)
    local frame = _G[name]
    if frame then
        HideFrame(frame)
    end
end

-- Hide default UI elements we're replacing
local function HideDefaultUI()
    -- Hide the main action bar art (gryphons, background)
    HideFrameByName("MainMenuBarArtFrame")
    HideFrameByName("MainMenuBarArtFrameBackground")

    -- Hide gryphon textures specifically
    HideFrameByName("MainMenuBarLeftEndCap")
    HideFrameByName("MainMenuBarRightEndCap")

    -- Hide the page number/arrows
    HideFrameByName("ActionBarUpButton")
    HideFrameByName("ActionBarDownButton")
    HideFrameByName("MainMenuBarPageNumber")

    -- Hide micro menu (character, spellbook, etc buttons)
    HideFrameByName("MicroButtonAndBagsBar")

    -- Hide bag bar
    HideFrameByName("BagsBar")
    HideFrameByName("MainMenuBarBackpackButton")
    HideFrameByName("CharacterBag0Slot")
    HideFrameByName("CharacterBag1Slot")
    HideFrameByName("CharacterBag2Slot")
    HideFrameByName("CharacterBag3Slot")

    -- Hide experience/reputation bars (multiple possible names for Classic)
    HideFrameByName("MainMenuExpBar")
    HideFrameByName("MainMenuBarExpBar")
    HideFrameByName("ReputationWatchBar")
    HideFrameByName("MainMenuBarMaxLevelBar")
    HideFrameByName("ExhaustionTick")

    -- Hide the status tracking bar manager (retail/later classic)
    HideFrameByName("StatusTrackingBarManager")

    -- Hide performance/latency bar
    HideFrameByName("MainMenuBarPerformanceBar")
    HideFrameByName("MainMenuBarPerformanceBarFrame")
    HideFrameByName("MainMenuBarPerformanceBarFrameButton")

    -- Hide the entire MainMenuBar texture/background
    HideFrameByName("MainMenuBarTexture0")
    HideFrameByName("MainMenuBarTexture1")
    HideFrameByName("MainMenuBarTexture2")
    HideFrameByName("MainMenuBarTexture3")

    -- Hide MainMenuBar bottom art
    HideFrameByName("MainMenuBarArtFrame")
    HideFrameByName("MainMenuBarArtFrameBackground")

    -- Hide stancebarshading and other overlays
    HideFrameByName("StanceBarLeft")
    HideFrameByName("StanceBarMiddle")
    HideFrameByName("StanceBarRight")
    HideFrameByName("SlidingActionBarTexture0")
    HideFrameByName("SlidingActionBarTexture1")

    -- Hide micro buttons
    local microButtons = {
        "CharacterMicroButton",
        "SpellbookMicroButton",
        "TalentMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "GuildMicroButton",
        "LFDMicroButton",
        "CollectionsMicroButton",
        "EJMicroButton",
        "StoreMicroButton",
        "MainMenuMicroButton",
        "HelpMicroButton",
        "SocialsMicroButton",
        "WorldMapMicroButton",
    }

    for _, name in ipairs(microButtons) do
        HideFrameByName(name)
    end

    -- Hide the MainMenuBar itself but keep it functional for keybinds
    if MainMenuBar then
        MainMenuBar:SetAlpha(0)
        MainMenuBar:SetScale(0.001)
        MainMenuBar:ClearAllPoints()
        MainMenuBar:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -500, -500)
    end
end

-- Event frame for initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitializeDB()
        CMOS:Print("v" .. CMOS.version .. " loaded. Type /cmos for commands.")
    elseif event == "PLAYER_LOGIN" then
        -- Hide default UI after everything is loaded
        HideDefaultUI()
        -- Initialize action bars
        if CMOS.InitActionBars then
            CMOS:InitActionBars()
        end
        -- Initialize cast bar
        if CMOS.InitCastBar then
            CMOS:InitCastBar()
        end
    end
end)
