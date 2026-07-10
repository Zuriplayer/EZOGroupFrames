# EZOGroupFrames

Public beta addon for The Elder Scrolls Online that provides compact dungeon and trial group frames.

## Status

EZOGroupFrames is in public beta. The addon is usable for testing, but the layout and feature set may change while group-frame behavior is validated in real dungeon and trial groups.

## Requirements

- The Elder Scrolls Online
- LibAddonMenu-2.0
- Optional for diagnostics: LibDebugLogger and DebugLogViewer

## Installation

1. Download the release ZIP.
2. Extract it into your ESO AddOns folder so the manifest path is:

```text
AddOns/EZOGroupFrames/EZOGroupFrames.txt
```

3. Enable `EZOGroupFrames` from ESO's AddOns menu.
4. Reload the UI.

## Features

- Custom group frames for dungeon and trial groups.
- Members grouped visually in blocks of four.
- Role sorting and role labels for tank, healer and DD.
- Role-based health bar colors with settings for tank, healer, DD and unknown roles.
- Optional level and class text.
- ESO native group frames can be hidden while EZOGroupFrames is active.
- English and Spanish localization with an in-addon language selector.
- Debug-only simulated group of four for testing without a real group.

## Safety Limits

- The addon does not automate group actions.
- The addon does not change keybinds or input behavior.
- The addon only shows its persistent visual controls in ESO HUD/HUD UI scenes.
- Native group frames are hidden only while EZOGroupFrames is actively showing its own frames, and this can be disabled in settings.

## Testing Notes

For beta testing, please verify:

- Addon loads without Lua errors.
- `/reloadui` works.
- The settings menu opens.
- Custom frames appear in a real group.
- The debug simulated group appears only when debug mode is enabled.
- Native group frames return when EZOGroupFrames is disabled or not showing.
