# Changelog

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
