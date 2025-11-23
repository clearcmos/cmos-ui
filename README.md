# CMOS-UI

Clean, minimal World of Warcraft Classic UI addon. Replaces default action bars, cast bar, and unit frames with a modern dark theme.

## Features

### Action Bars
- Clean flat design with subtle borders
- Configurable number of bottom bars (1-4)
- Optional left/right side bars
- Keybind and macro text display

### Cast Bar
- Positioned above action bars
- Spell icon with name and cast time
- Different colors for casts (blue), channels (green), and interrupts (red)
- Smooth animation with spark effect

### Unit Frames
- **Player Frame**: Level, name, health/mana bars with class colors
- **Target Frame**: Reaction-colored bars (friendly/neutral/hostile), level indicator
- **Target Buffs/Debuffs**: Displayed with duration timers, color-coded borders by debuff type
- **Target Cast Bar**: Shows spell name and remaining time

### Frame Positioning
- Right-click any unit frame to unlock
- Drag to reposition with gridline overlay
- Right-click again to lock
- Positions saved per-character

## Installation

1. Download or clone this repository
2. Copy the `cmos-ui` folder to your WoW addons directory:
   - **Windows**: `World of Warcraft\_classic_era_\Interface\AddOns\`
   - **macOS**: `/Applications/World of Warcraft/_classic_era_/Interface/AddOns/`
   - **Linux (Wine/Proton)**: `~/.steam/steam/steamapps/compatdata/<id>/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/Interface/AddOns/`
3. Restart WoW or `/reload`

## Commands

- `/cmos` - Show available commands
- `/cmos debug` - Toggle debug mode

## Files

| File | Description |
|------|-------------|
| `Core.lua` | Addon initialization, settings, hide default UI |
| `ActionBars.lua` | Custom action bar frames |
| `CastBar.lua` | Player cast bar |
| `PlayerFrame.lua` | Player unit frame |
| `TargetFrame.lua` | Target unit frame with buffs/debuffs and cast bar |
| `FrameMover.lua` | Drag-to-move functionality with gridlines |
| `Commands.lua` | Slash command handling |

## Configuration

Settings are stored in:
- `CMOSDB` - Account-wide settings
- `CMOSCharDB` - Per-character settings (frame positions)

## Theme

Dark minimal theme inspired by ElvUI:
- Background: `{0.1, 0.1, 0.1, 0.85}`
- Borders: `{0.3, 0.3, 0.3, 1}`
- Uses `Interface\Buttons\WHITE8x8` for solid color textures

## License

MIT
