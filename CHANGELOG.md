# Changelog

## Unreleased

- Follows EZOCore's family preference storage policy for group-frame settings, with one-time account-to-character migration when the default scope is per character.
- Replaces native group-frame hidden-reason toggling with visual hiding of `ZO_UnitFramesGroups` to avoid interfering with ESO keyboard/gamepad style refreshes.

## 0.1.15 - Leader Crown Overlay

- Draws the group leader crown as a high-layer overlay anchored to the health bar so the bar fill and caps cannot cover it.

## 0.1.14 - Role Icons and Status Warnings

- Replaces role text with native ESO role icons for tank, healer and damage dealer.
- Keeps the group leader crown inside the health bar while still showing the member's role icon.
- Highlights optional EZO status values when they become unfavorable: ping from 150 ms in yellow and 250 ms in red; FPS at 45 or lower in yellow and 30 or lower in red.
- Keeps role icon, leader detection, performance sharing and saved settings behavior unchanged.

## 0.1.13 - Leader Icon Contrast

- Replaces the group leader marker with a clearer crown-style group leader icon.
- Adds a compact dark backing behind the leader icon so it remains visible over bright role-colored health bars.
- Keeps the leader detection and saved settings unchanged.

## 0.1.12 - Group Leader Indicator

- Shows a compact crown icon on the group leader's custom health bar.
- Tracks leader changes through ESO's group leader update event.
- Marks the simulated debug tank as leader so the indicator can be tested outside a real group.

## 0.1.11 - Performance Status Privacy

- Immediately queues a hidden-state withdrawal when optional performance sharing is disabled.
- Shows ping and FPS only for explicitly public peer states instead of rendering private values as zero.
- Delays initial and group-change publishing until EZOCore presence has been queued first.
- Reports distinct performance publish and receive state transitions through Log Viewer when debug is enabled.
- Prevents enabling performance sharing while the EZOCore group transport is unavailable.
- Avoids network publication attempts while the optional transport is inactive and resumes automatically when it returns.
- Clamps local performance samples to the limits of the shared wire contract.

## 0.1.10 - Native Style Refresh Safety

- Force-restores ESO's native group/raid frame visibility before keyboard/gamepad style refreshes.
- Prevents stale addon visibility state from leaving native group-frame anchors unavailable during `UpdateGroupFramesVisualStyle`.
- Reapplies the configured native-frame hiding only after the platform-style transition completes.
- Registers debug logging and simulation with EZOCore for family-wide disable control.
- Avoids unsupported mouse-button initialization on the custom group-frame panel while preserving locked/unlocked movement behavior.
- Reuses an existing custom frame container if refresh events reach the renderer before the local frame registry is attached.

## 0.1.9 - EZOCore Player Status

- Added disabled-by-default settings for optional EZO player status in group frames.
- Consumes EZOCore `performanceState` data to show compact ping, FPS and privacy status beside group members.
- Added opt-in local ping/FPS/privacy publishing through the EZOCore group presence service at a limited interval.
- Separated optional player name, level and class text with clear delimiters above the health bar.
- Kept EZOGroupFrames free of direct LibGroupBroadcast protocol ownership, handlers or custom group events.

## 0.1.8 - Shared Layout Integration

- Registers the group-frame surface with EZOCore for temporary global or individual movement control.
- Shows a HUD-only placement preview while either the central edit mode or the standalone unlock option is active.
- Keeps native ESO frame hiding tied to functional custom-frame visibility rather than placement preview visibility.

## 0.1.7 - Native Frame Hiding

- Replaced direct hiding of ESO's native group-frame container with ESO's group/raid frame hidden-reason API when available.
- Kept a defensive fallback for clients where the native hidden-reason API is unavailable.
- Avoided repeated native-frame visibility writes when the requested hidden state has not changed.
- Synchronized EZOCore registration metadata with the manifest AddOnVersion.

## 0.1.6 - EZOCore settings integration

- Registered the complete settings panel in Settings > EZO when EZOCore is available.
- Kept the standard LibAddonMenu panel only as a standalone fallback.

## 0.1.5 - Settings Presentation

- Updated the LibAddonMenu panel to use shared EZO informational section headers.
- Added purple 26 px information icons and section-level tooltips for General, Group frames and Debug.
- Added field-specific tooltips for existing frame and color settings without changing defaults or behavior.
- Kept English and Spanish public documentation synchronized with the settings presentation.

## 0.1.4 - Public Beta

- Prepared the addon for public beta publication.
- Added public README, MIT license and changelog.
- Marked project metadata as public beta.
- Hardened repository ignore rules for local assistant, secret and scratch files.
- Kept internal agent/handoff files out of Git tracking.
- Current beta features include role-sorted group frames, configurable role colors, optional level/class text, debug group simulation and conservative native-frame hiding while EZOGroupFrames is active.
