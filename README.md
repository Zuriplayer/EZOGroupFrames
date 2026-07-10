# EZOGroupFrames

EZOGroupFrames is a public beta addon for The Elder Scrolls Online that provides compact, optional group frames for dungeon and trial groups.

¿Prefieres español? Lee el [README en español](README.es.md).
Support, bug reports and suggestions: https://discord.gg/MpVCJ9h4Gk

## Status

EZOGroupFrames is in public beta. It is usable for testing, but its layout and feature set may change while the group-frame behavior is validated in real dungeon and trial groups.

## Version Metadata

- Addon version: `0.1.4`
- AddOnVersion: `104`
- APIVersion: `101049 101050`
- Status: public beta

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Optional for diagnostics: LibDebugLogger and DebugLogViewer.

## Installation

1. Clone this repository, or use a published ZIP package when one is available.
2. Extract it into your ESO AddOns folder so the manifest path is:

```text
AddOns/EZOGroupFrames/EZOGroupFrames.txt
```

3. Enable `EZOGroupFrames` from ESO's AddOns menu.
4. Reload the UI.
5. Open the addon settings from LibAddonMenu to review the frame options.

## Current Features

- Custom group-frame panel for dungeon and trial groups.
- Members displayed in blocks of four.
- Group members sorted by selected LFG role and then by name.
- Role labels for tank, healer, damage dealer and unknown role.
- Health bars using the current and maximum health values reported by ESO.
- Health text with current/max health and a percentage label.
- Configurable role colors for tank, healer, damage dealer and unknown role.
- Optional level text.
- Optional class text.
- Movable panel when the frame position is unlocked.
- Frame scale setting.
- Optional "show only while grouped" behavior.
- Optional hiding of ESO's native group-frame container while EZOGroupFrames is actively showing its own frames.
- HUD-only visibility for the persistent frame panel.
- English and Spanish localization with an in-addon language selector.
- Debug mode with compact messages routed through LibDebugLogger when available.
- Debug-only simulated group of four: one tank, one healer and two damage dealers.

## Settings

The addon adds a LibAddonMenu panel named `EZOGroupFrames`.

General options:

- Language: Auto, English or Spanish.

Group frame options:

- Enable custom group frames.
- Lock frame position.
- Show only while grouped.
- Hide ESO group frames while active.
- Show level.
- Show class.
- Frame scale.
- Tank color.
- Healer color.
- Damage color.
- Unknown role color.

Debug options:

- Enable debug mode.
- Toggle simulated group of four. This button is disabled unless debug mode is enabled.

## Implementation Notes

The addon manifest loads the current runtime in this order:

- `EZOGroupFrames.lua`: saved variables, defaults and addon startup.
- `modules/core.lua`: addon identity and version constants.
- `modules/i18n.lua`: English/Spanish string application.
- `modules/debug.lua`: LibDebugLogger and DebugLogViewer integration.
- `modules/hud_visibility.lua`: HUD/HUD UI visibility guard and scene fragment registration.
- `modules/debug_simulation.lua`: debug-only simulated four-player group.
- `modules/group_state.lua`: group member snapshot, role sorting, health, level and class text.
- `modules/native_frames.lua`: optional hiding/restoring of ESO native group frames.
- `modules/lam_registry.lua`: LibAddonMenu option registration.
- `modules/menu.lua`: LibAddonMenu panel creation.
- `modules/frames.lua`: custom frame rendering and health-bar layout.

## Safety Limits

- The addon does not automate group actions.
- The addon does not invite, kick, promote, queue, ready-check or disband groups.
- The addon does not change keybinds or input behavior.
- The addon does not perform combat actions.
- The addon does not synchronize data between players.
- The addon does not include a minimap, compass marker system, raid-leader marking system or per-trial saved marks in the current beta.
- Native ESO group frames are hidden only while EZOGroupFrames is actively showing its own frames, and that behavior can be disabled in settings.
- Persistent visual controls are intended to be visible only in ESO HUD/HUD UI scenes.

## Recommended Testing

For beta testing, please verify:

- The addon loads without Lua errors.
- `/reloadui` works without errors.
- The LibAddonMenu settings panel opens.
- Language selection works in English and Spanish.
- Custom frames appear in a real group.
- The panel can be moved when unlocked and stays fixed when locked.
- Health values update when group members take damage or heal.
- Role colors apply to tank, healer, damage dealer and unknown roles.
- Optional level and class text can be toggled.
- The debug simulated group appears only when debug mode is enabled.
- ESO native group frames return when EZOGroupFrames is disabled or not showing.
- The UI is checked in keyboard and gamepad modes.

## License

EZOGroupFrames is licensed under the MIT License. See [LICENSE](LICENSE).
