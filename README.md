# EZOGroupFrames

Addon de la familia EZO para gestionar group frames en dungeon y trial.

Este repositorio sigue la filosofia de EZOTools: cambios pequenos, estructura modular, textos bilingues, settings claros, versionado trazable y publicacion separada.

Ruta canonica de desarrollo:

```text
\\RZRNAS\Zuriplayer\Dev\EZOGroupFrames
```

Usar siempre esta ruta UNC en handoffs o documentacion nueva.

## Estado inicial

- Scaffold EZO independiente.
- Manifest ESO.
- Bootstrap Lua.
- `en/es` con selector de idioma en el menu.
- Menu LibAddonMenu.
- Guard HUD/HUD_UI para controles visuales.
- Group frames propios opcionales, sin ocultar los frames vanilla.
- Herramientas de versionado y empaquetado.

## Comandos de trabajo

```powershell
.\tools\bump-version.ps1 -Check
.\scripts\ezo\build-addon-package.ps1 -Force
git diff --check
```

## Publicacion

El ZIP se genera en `dist/`. La publicacion Discord no forma parte automatica de cada commit o push. Ver `docs/ezo-discord-automation.md`.

## Ideas futuras

Ver `docs/IDEAS.md`.
