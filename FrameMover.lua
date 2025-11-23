local addonName, CMOS = ...

-- Gridlines frame (created once, reused)
local gridFrame = nil

-- Create gridlines overlay
local function CreateGridlines()
    if gridFrame then return gridFrame end

    gridFrame = CreateFrame("Frame", "CMOSGridlines", UIParent)
    gridFrame:SetAllPoints(UIParent)
    gridFrame:SetFrameStrata("TOOLTIP")
    gridFrame:Hide()

    local numLines = 20
    gridFrame.lines = {}

    -- Vertical lines
    for i = 1, numLines do
        local line = gridFrame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 1, 0.3)
        line:SetSize(1, UIParent:GetHeight())
        table.insert(gridFrame.lines, line)
    end

    -- Horizontal lines
    for i = 1, numLines do
        local line = gridFrame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 1, 0.3)
        line:SetSize(UIParent:GetWidth(), 1)
        table.insert(gridFrame.lines, line)
    end

    -- Center lines (brighter)
    local centerV = gridFrame:CreateTexture(nil, "OVERLAY")
    centerV:SetColorTexture(0, 1, 1, 0.6)
    centerV:SetSize(2, UIParent:GetHeight())
    centerV:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    gridFrame.centerV = centerV

    local centerH = gridFrame:CreateTexture(nil, "OVERLAY")
    centerH:SetColorTexture(0, 1, 1, 0.6)
    centerH:SetSize(UIParent:GetWidth(), 2)
    centerH:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    gridFrame.centerH = centerH

    -- Position grid lines
    local function UpdateGrid()
        local screenWidth = UIParent:GetWidth()
        local screenHeight = UIParent:GetHeight()
        local spacing = 50

        local idx = 1
        -- Vertical lines
        for i = 1, numLines do
            local line = gridFrame.lines[idx]
            local x = (i - numLines/2) * spacing
            line:ClearAllPoints()
            line:SetPoint("CENTER", UIParent, "CENTER", x, 0)
            line:SetSize(1, screenHeight)
            idx = idx + 1
        end
        -- Horizontal lines
        for i = 1, numLines do
            local line = gridFrame.lines[idx]
            local y = (i - numLines/2) * spacing
            line:ClearAllPoints()
            line:SetPoint("CENTER", UIParent, "CENTER", 0, y)
            line:SetSize(screenWidth, 1)
            idx = idx + 1
        end

        centerV:SetSize(2, screenHeight)
        centerH:SetSize(screenWidth, 2)
    end

    gridFrame:SetScript("OnShow", UpdateGrid)

    return gridFrame
end

-- Make a frame movable with right-click lock/unlock
function CMOS:MakeFrameMovable(frame, frameName, defaultPoint, defaultRelative, defaultRelPoint, defaultX, defaultY)
    if not frame then return end

    -- Initialize gridlines
    CreateGridlines()

    -- Ensure saved positions table exists
    if not CMOSCharDB then CMOSCharDB = {} end
    if not CMOSCharDB.framePositions then CMOSCharDB.framePositions = {} end
    if not CMOSCharDB.frameLocked then CMOSCharDB.frameLocked = {} end

    -- Default to locked
    if CMOSCharDB.frameLocked[frameName] == nil then
        CMOSCharDB.frameLocked[frameName] = true
    end

    -- Create unlock indicator
    local unlockText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    unlockText:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    unlockText:SetText("|cffff0000UNLOCKED|r - Drag to move, Right-click to lock")
    unlockText:Hide()
    frame.unlockText = unlockText

    -- Apply saved position or default
    local function ApplyPosition()
        frame:ClearAllPoints()
        local saved = CMOSCharDB.framePositions[frameName]
        if saved then
            frame:SetPoint(saved.point, UIParent, saved.relPoint, saved.x, saved.y)
        else
            frame:SetPoint(defaultPoint, defaultRelative, defaultRelPoint, defaultX, defaultY)
        end
    end

    -- Save current position
    local function SavePosition()
        local point, _, relPoint, x, y = frame:GetPoint()
        CMOSCharDB.framePositions[frameName] = {
            point = point,
            relPoint = relPoint,
            x = x,
            y = y,
        }
    end

    -- Toggle lock state
    local function ToggleLock()
        local isLocked = CMOSCharDB.frameLocked[frameName]
        CMOSCharDB.frameLocked[frameName] = not isLocked

        if CMOSCharDB.frameLocked[frameName] then
            -- Locking
            frame:SetMovable(false)
            frame.unlockText:Hide()
            gridFrame:Hide()
            SavePosition()
            CMOS:Print(frameName .. " locked")
        else
            -- Unlocking
            frame:SetMovable(true)
            frame.unlockText:Show()
            gridFrame:Show()
            CMOS:Print(frameName .. " unlocked - drag to move, right-click to lock")
        end
    end

    -- Setup frame for dragging
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)

    frame:SetScript("OnDragStart", function(self)
        if not CMOSCharDB.frameLocked[frameName] then
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)

    -- Right-click to toggle lock
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            ToggleLock()
        end
    end)

    -- Apply initial position
    ApplyPosition()

    -- Set initial lock state visuals
    if not CMOSCharDB.frameLocked[frameName] then
        frame:SetMovable(true)
        frame.unlockText:Show()
    end

    return frame
end

-- Show gridlines (can be called manually)
function CMOS:ShowGridlines()
    CreateGridlines()
    gridFrame:Show()
end

-- Hide gridlines
function CMOS:HideGridlines()
    if gridFrame then
        gridFrame:Hide()
    end
end
