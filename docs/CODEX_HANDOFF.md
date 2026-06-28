# EZOGroupFrames Codex Handoff

Canonical path:

```text
\\RZRNAS\Zuriplayer\Dev\EZOGroupFrames
```

Current thread path:

```text
C:\Users\zurip\Documents\EZOGroupFrames
```

Use the UNC `\\RZRNAS` path in project handoffs and docs.

## Status

- Version: `0.1.0`
- AddOnVersion: `100`
- APIVersion: `101049 101050`
- Phase: initial scaffold
- Remote expected: `https://github.com/Zuriplayer/EZOGroupFrames.git`

## Scope

EZOGroupFrames is intended to manage group frames for dungeon and trial groups.

Initial implementation is deliberately conservative:

- custom frames are optional
- vanilla group frames are not hidden
- no input/keybind behavior
- no raid-leader automation
- visual controls are HUD/HUD_UI only

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
