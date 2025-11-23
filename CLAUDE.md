# CLAUDE.md - Development Guidelines for CMOS-UI

## Project Overview

CMOS-UI is a WoW Classic Era addon that replaces default UI elements with a clean, minimal dark theme. Target client: Classic Era (Interface: 11508).

## Code Structure

```
cmos-ui/
├── CMOS-UI.toc      # Addon manifest, load order matters
├── Core.lua         # Loads first - namespace, settings, HideDefaultUI()
├── FrameMover.lua   # Shared utility for movable frames
├── ActionBars.lua   # Action bar replacement
├── CastBar.lua      # Player cast bar
├── PlayerFrame.lua  # Player unit frame
├── TargetFrame.lua  # Target frame + buffs/debuffs + target cast bar
└── Commands.lua     # Slash commands, loads last
```

## Key Patterns

### Addon Namespace
```lua
local addonName, CMOS = ...
-- All modules share the CMOS table
```

### Frame Creation
- Use `BackdropTemplate` for frames with borders
- Backdrop: `Interface\Buttons\WHITE8x8` for solid colors
- Standard border size: 1px
- Inner padding: 2px from border to content

### Theme Colors (from devdocs/wow/cmos-ui-theme.md)
```lua
bgColor = {0.1, 0.1, 0.1, 0.85}      -- Container background
borderColor = {0.3, 0.3, 0.3, 1}     -- Subtle border
bgDark = {0.05, 0.05, 0.05, 0.8}     -- Bar backgrounds
```

### Status Bars
```lua
local bar = CreateFrame("StatusBar", nil, container)
bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
bar:SetMinMaxValues(0, 1)
bar:SetValue(percent)  -- 0 to 1
```

### Movable Frames
```lua
CMOS:MakeFrameMovable(frame, "FrameName", point, relativeTo, relPoint, xOfs, yOfs)
-- Adds right-click lock/unlock, drag support, gridlines, saves to CMOSCharDB
```

## Saved Variables

- `CMOSDB` - Account-wide (declared in TOC)
- `CMOSCharDB` - Per-character (frame positions, lock states)

## Testing

1. Copy files to WoW AddOns folder
2. `/reload` in-game
3. Check for lua errors in chat or BugSack

## Common Tasks

### Adding a New Frame
1. Create `NewFrame.lua`
2. Add to `CMOS-UI.toc` (before Commands.lua)
3. Create `CMOS:InitNewFrame()` function
4. Call init from `Core.lua` in PLAYER_LOGIN handler
5. Use `CMOS:MakeFrameMovable()` if it should be repositionable

### Hiding Default Blizzard Frames
```lua
local function HideDefaultFrame()
    if FrameName then
        FrameName:UnregisterAllEvents()
        FrameName:Hide()
        FrameName.Show = function() end  -- Prevent re-showing
    end
end
```

## API Reference

Refer to `../devdocs/wow/` for:
- `addon-development-guide.md` - General patterns
- `cmos-ui-theme.md` - Color palette and styling
- `wow-build-info.md` - Client version info

## Copy to WoW

```bash
cp *.lua *.toc "/path/to/World of Warcraft/_classic_era_/Interface/AddOns/cmos-ui/"
```
