# EZOGroupFrames - AI Development Rules

Este proyecto es un addon para The Elder Scrolls Online (ESO), dentro de la familia EZO.

Referencia principal de arquitectura: `\\RZRNAS\Zuriplayer\Dev\EZOTools`.
Guia familiar: `\\RZRNAS\Zuriplayer\Dev\EZO_FAMILY.md`.
Ruta canonica esperada del proyecto: `\\RZRNAS\Zuriplayer\Dev\EZOGroupFrames`.

## Reglas obligatorias

- No inventar APIs de ESO. Si una API no esta verificada, parar y decirlo.
- No usar `os.*`, `io.*`, `require()` ni librerias Lua externas no soportadas por ESO.
- Mantener cambios pequenos, revisables y especificos.
- Si se anade un archivo runtime, anadirlo a `EZOGroupFrames.txt` en orden logico.
- Usar `LibAddonMenu-2.0` para settings y mantener textos visibles en `lang/en.lua` y `lang/es.lua`.
- Usar `OptionalDependsOn` salvo que el addon no pueda funcionar sin la dependencia.
- No tocar input, keybinds ni navegacion de ESO sin una decision explicita.
- No ocultar ni reemplazar frames vanilla por defecto. Cualquier reemplazo debe ser opcion de settings.

## Versionado

Para cambios visibles:

```powershell
.\tools\bump-version.ps1 -Patch
```

Antes de commit:

```powershell
.\tools\bump-version.ps1 -Check
git diff --check
```

Si cambia la API soportada, no adivinarla. Verificar en juego con `/script d(GetAPIVersion())` o fuente fiable.

La version debe quedar sincronizada entre:

- `EZOGroupFrames.txt` (`## Version`, `## AddOnVersion`)
- `modules/core.lua` (`EZOGroupFrames.ADDON_VERSION`)
- `ezo-addon.json` (`addon.version`, `addon.package.zipName`)

## HUD, overlays y frames

Cualquier control visual persistente del addon debe ser HUD-only:

- visible solo en `hud` o `hudui`
- registrado como fragmento de escena si aplica
- con guard central `SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")`
- oculto en menus, mapa, inventario, crafting, Champion Points, Tribute y settings

No usar listas negativas de escenas. La regla correcta es whitelist positiva de HUD/HUD_UI.

## Group frames

El objetivo del addon es gestionar group frames para dungeon y trial.

Scope inicial:

- scaffold familiar EZO
- menu bilingue
- frames propios opcionales
- estado de grupo separado del renderer
- sin sustituir vanilla UI por defecto
- sin automatizacion de acciones de grupo

Ideas futuras se documentan en `docs/IDEAS.md`; no deben implementarse sin nueva decision.

## Git y publicacion

- Rama principal: `main`.
- Remoto esperado: `https://github.com/Zuriplayer/EZOGroupFrames.git`.
- La publicacion Discord es un paso separado de commit/push.
- No lanzar workflows de Discord sin confirmacion explicita.
- Discord debe ser player-facing: no incluir rutas locales, NAS, symlinks ni nombres de ramas.

## Validacion minima

- El manifest carga todos los archivos.
- `.\tools\bump-version.ps1 -Check`.
- `.\scripts\ezo\build-addon-package.ps1 -Force`.
- `git diff --check`.
- En juego: carga sin errores Lua, `/reloadui`, menu LAM, modo teclado y modo gamepad sin regresiones.
