# EZOGroupFrames Codex Handoff

Canonical path:

```text
\\RZRNAS\Zuriplayer\Dev\EZOGroupFrames
```

Live symlink:

```text
C:\Users\zurip\Documents\Elder Scrolls Online\live\AddOns\EZOGroupFrames -> \\RZRNAS\Zuriplayer\Dev\EZOGroupFrames
```

Use the UNC `\\RZRNAS` path in project handoffs and docs.

## Status

- Version: `0.1.3`
- AddOnVersion: `103`
- APIVersion: `101049 101050`
- Phase: first-playtest prototype
- Remote expected: `https://github.com/Zuriplayer/EZOGroupFrames.git`

## Scope

EZOGroupFrames is intended to manage group frames for dungeon and trial groups.

Current implementation is deliberately conservative:

- custom frames are optional
- vanilla group frames are not hidden
- no input/keybind behavior
- no raid-leader automation
- visual controls are HUD/HUD_UI only
- health bars are grouped 4 by 4 and sorted by role
- tank, healer, DD and unknown role colors are configurable
- ESO native group frames are hidden while EZOGroupFrames is actively showing its own frames
- debug mode includes a LAM button that shows a simulated group of 4: 1 tank, 1 healer and 2 DD
- detailed debug output is routed through Debug Viewer / LibDebugLogger when available

## Validation

```powershell
.\tools\bump-version.ps1 -Check
.\scripts\ezo\build-addon-package.ps1 -Force
git diff --check
```

In game:

- addon loads without Lua errors
- `/reloadui` works
- LAM menu opens
- language selector works
- enabling custom frames does not hide ESO vanilla frames
- custom frames disappear outside HUD/HUD_UI scenes
- debug simulated group button shows 4 frames without a real group
