# EZOGroupFrames

EZOGroupFrames is a public beta addon for The Elder Scrolls Online that provides compact, optional group frames for dungeon and trial groups.

Prefer Spanish? Read the [Spanish README](README.es.md).
Support, bug reports and suggestions: https://discord.gg/ekw8zUAcRm

## Status

EZOGroupFrames is in public beta. It is usable for testing, but its layout and feature set may change while the group-frame behavior is validated in real dungeon and trial groups.

## Version Metadata

- Addon version: `0.1.16`
- AddOnVersion: `116`
- APIVersion: `101049 101050`
- Status: public beta

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Optional: EZOCore for central access through Settings > EZO and opt-in EZO player status in group frames.
- Optional for diagnostics: LibDebugLogger and DebugLogViewer.

## Installation

1. Clone this repository, or use a published ZIP package when one is available.
2. Extract it into your ESO AddOns folder so the manifest path is:

```text
AddOns/EZOGroupFrames/EZOGroupFrames.txt
```

3. Enable `EZOGroupFrames` from ESO's AddOns menu.
4. Reload the UI.
5. With EZOCore enabled, open Settings > EZO > EZOGroupFrames. Without EZOCore, use the standard Addons settings panel.

## Current Features

- Custom group-frame panel for dungeon and trial groups.
- Members displayed in blocks of four.
- Group members sorted by selected LFG role and then by name.
- Native ESO role icons for tank, healer and damage dealer.
- Health bars using the current and maximum health values reported by ESO.
- Health text with current/max health and a percentage label.
- High-contrast group leader crown icon on the leader's health bar.
- Configurable role colors for tank, healer, damage dealer and unknown role.
- Optional level and class text, separated from the player name for readability.
- Movable panel when the frame position is unlocked.
- Temporary integration with the shared EZOCore interface layout mode (`family.layout`), showing sample preview frames when entering edit mode without an active group.
- Master enable toggle for custom group frames in the addon panel.
- Sample group preview modes: temporarily display 4 members (dungeon) or 12 members (trial) to adjust layout, position, scale and colors without a real group.
- Frame scale setting.
- Optional "show only while grouped" behavior.
- Optional hiding of ESO's native group-frame container while EZOGroupFrames is actively showing its own frames.
  This uses ESO's own group/raid frame hidden-reason mechanism when available.
- Optional EZO player status beside each group member, consumed through EZOCore group presence: ping as `42ms`, FPS as `58fps`, and a compact privacy badge.
- Optional EZO status warning colors: ping turns yellow from `150ms` and red from `250ms`; FPS turns yellow at `45fps` or lower and red at `30fps` or lower.
- Optional opt-in sharing of your rounded ping, FPS and public privacy status through EZOCore group presence at a limited interval.
- Disabling sharing immediately queues a hidden-state withdrawal; private or hidden peers never display zero-valued ping or FPS as real metrics.
- HUD-only visibility for the persistent frame panel.
- English and Spanish localization with an in-addon language selector.
- Debug mode with compact messages routed through LibDebugLogger when available.
- Debug-only simulated group of four: one tank, one healer and two damage dealers.

## Settings

With EZOCore enabled, the complete panel appears only under Settings > EZO and its group-frame surface can participate in the global or individual interface layout mode. Without EZOCore, the same controls and local unlock behavior remain available in the standard LibAddonMenu Addons list.

With EZOCore active, EZOGroupFrames follows the EZO family preference storage policy: ordinary group-frame settings use the selected account-wide or per-character scope. When the scope is per character, the first load copies existing account-wide EZOGroupFrames settings into that character profile. Without EZOCore, EZOGroupFrames keeps its historical account-wide storage.

Every settings section uses the shared EZO purple information icon in its heading. Hover the section heading for general help about that group of options; hover an individual setting for field-specific help. No long explanatory paragraphs are kept permanently visible in the panel.

General options:

- Language: Auto, English or Spanish.

Group frame options:

- Enable custom group frames.
- Lock frame position.
- Sample preview mode (Off, Sample 4 members, Sample 12 members).
- Show only while grouped.
- Hide ESO group frames while active.
- Show level.
- Show class.
- Frame scale.
- Tank color.
- Healer color.
- Damage color.
- Unknown role color.

EZO player status options:

- Show EZO player status in group frames.
- Show ping.
- Show FPS.
- Show privacy indicator.
- Share my ping/FPS/privacy status.

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
- `modules/group_state.lua`: group member snapshot, role sorting, leader state, health, level and class text.
- `modules/ezocore_performance.lua`: optional EZOCore `performanceState` producer/consumer bridge.
- `modules/native_frames.lua`: optional hiding/restoring of ESO native group frames.
- `modules/lam_registry.lua`: LibAddonMenu option registration.
- `modules/menu.lua`: LibAddonMenu panel creation.
- `modules/frames.lua`: custom frame rendering and health-bar layout.

## Safety Limits

- The addon does not automate group actions.
- The addon does not invite, kick, promote, queue, ready-check or disband groups.
- The addon does not change keybinds or input behavior.
- The addon does not perform combat actions.
- The addon does not own, register or handle LibGroupBroadcast protocols directly. Optional player status is consumed or shared only through the EZOCore service API.
- Player status sharing is disabled by default and limited to rounded ping, FPS and privacy state. It can only be enabled while the EZOCore group transport is active.
- Performance transport results and first received peer states are written to Log Viewer only when addon debug is enabled.
- The addon does not include a minimap, compass marker system, raid-leader marking system or per-trial saved marks in the current beta.
- Native ESO group frames are hidden only while EZOGroupFrames is actively showing its own frames, and that behavior can be disabled in settings.
  The addon does not directly force-hide the native group frame container when ESO's hidden-reason API is available.
- Persistent visual controls are intended to be visible only in ESO HUD/HUD UI scenes.

## Recommended Testing

For beta testing, please verify:

- The addon loads without Lua errors.
- `/reloadui` works without errors.
- The settings panel opens under Settings > EZO when EZOCore is enabled, without a duplicate entry in the standard Addons list.
- The standalone LibAddonMenu fallback opens when EZOCore is unavailable.
- Every settings section shows the purple information icon and exposes its general tooltip from the heading.
- Field-specific help appears from the individual setting controls.
- Language selection works in English and Spanish.
- Custom frames appear in a real group.
- The panel can be moved when unlocked and stays fixed when locked.
- Central layout mode shows a movable preview only after returning to HUD/HUD_UI and does not alter the saved lock setting.
- Health values update when group members take damage or heal.
- The group leader is marked with a readable crown icon on the health bar.
- Native role icons appear for tank, healer and damage dealer, and role colors still apply to the icons and bars.
- Optional level and class text can be toggled and remains separated from the player name.
- With EZOCore group presence available on compatible grouped clients, enable EZO player status, ping, FPS and privacy display and confirm that compact status text appears without widening the frame rows.
- Confirm that high ping and low FPS change to yellow or red at the documented thresholds.
- Enable sharing on one client and confirm that updates are throttled, then disable it and confirm that the peer changes to hidden without showing `0ms` or `0fps`.
- Repeat with EZOCore disabled to confirm that the EZO status controls do not create Lua errors and the frames continue to work locally.
- The debug simulated group appears only when debug mode is enabled.
- ESO native group frames return when EZOGroupFrames is disabled or not showing.
- With native-frame hiding enabled, switching between keyboard and gamepad mode does not raise native unit-frame errors.
- The UI is checked in keyboard and gamepad modes.

## License

EZOGroupFrames is licensed under the MIT License. See [LICENSE](LICENSE).
