# EZOGroupFrames - AI Development Rules


<!-- EZO-SHARED-LAM-START -->
## Estándar LAM compartido

Antes de crear o modificar ajustes LibAddonMenu, leer y aplicar:
`E:\DEV\EZOFamilyDocs\docs\ezo-lam-settings-style.md`

Las reglas específicas de este addon tienen prioridad. Si el archivo compartido
no está accesible, no modificar LAM e indicarlo explícitamente.
<!-- EZO-SHARED-LAM-END -->
Este proyecto es un addon para The Elder Scrolls Online (ESO), dentro de la familia EZO.

Referencia principal de arquitectura: `E:\DEV\EZOTools`.
Guia familiar: `E:\DEV\EZO_FAMILY.md`.
Ruta canonica esperada del proyecto: `E:\DEV\EZOGroupFrames`.

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

## Debug

- El debug detallado debe ir a Debug Viewer mediante `LibDebugLogger` siempre que este disponible.
- No volcar debug detallado en chat.
- Siempre que sea posible y razonable, las herramientas de debug deben vivir en un modulo especifico y dedicado.
- Las simulaciones de desarrollo deben quedar separadas del renderer y del estado real de grupo.

## Git y publicacion

- Rama principal: `main`.
- Remoto esperado: `https://github.com/Zuriplayer/EZOGroupFrames.git`.
- La publicacion Discord es un paso separado de commit/push.
- No lanzar workflows de Discord sin confirmacion explicita.
- Discord debe ser player-facing: no incluir rutas locales, NAS, symlinks ni nombres de ramas.

## Documentación

- Toda modificación funcional, de configuración, comportamiento, alcance o requisitos debe incluir en el mismo trabajo la revisión y actualización de `README.md` y `README.es.md`.
- Ambos README deben mantenerse equivalentes y sincronizados.
- Ningún README debe anunciar funciones, límites o requisitos que no coincidan con el código actual.
- Deben actualizarse las secciones afectadas: funciones, límites de seguridad, requisitos, instalación y pruebas.
- Antes de cerrar cualquier cambio se debe comprobar expresamente que ambos README siguen completos y actualizados.

## Validacion minima

- El manifest carga todos los archivos.
- `.\tools\bump-version.ps1 -Check`.
- Ejecutar `.\scripts\ezo\build-addon-package.ps1 -Force` solo para una publicación o cuando el usuario solicite expresamente generar el paquete.
- `git diff --check`.
- En juego: carga sin errores Lua, `/reloadui`, menu LAM, modo teclado y modo gamepad sin regresiones.

<!-- EZO-ESO-UPDATE-START -->
## Baseline obligatorio de ESO

Antes de analizar, modificar, validar, versionar o publicar este proyecto, leer
`..\EZOFamilyDocs\docs\eso-updates\current.md` y aplicar la política enlazada.

Baseline vigente: `U51-PTS-v12.1.0`.

- La matriz por addon vive en `..\EZOFamilyDocs\data\eso-update-baseline.json`.
- U51 sigue siendo PTS provisional hasta que exista verificación explícita.
- No cambiar `## APIVersion` por inferencia; verificarla en el cliente o en una
  fuente fiable de API.
- Si estos archivos no están disponibles, detener el trabajo sensible a
  compatibilidad e indicar el bloqueo.

Fuente remota de respaldo:
https://github.com/Zuriplayer/EZOFamilyDocs/blob/main/docs/eso-updates/current.md
<!-- EZO-ESO-UPDATE-END -->
