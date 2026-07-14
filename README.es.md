# EZOGroupFrames

EZOGroupFrames es un addon en beta pública para The Elder Scrolls Online que proporciona frames de grupo compactos y opcionales para grupos de mazmorra y trial.

¿Prefieres inglés? Lee el [README en inglés](README.md).
Soporte, errores y sugerencias: https://discord.gg/ekw8zUAcRm

## Estado

EZOGroupFrames está en beta pública. Es usable para pruebas, pero su diseño y conjunto de funciones pueden cambiar mientras se valida el comportamiento de los frames de grupo en grupos reales de mazmorra y trial.

## Metadatos de versión

- Versión del addon: `0.1.6`
- AddOnVersion: `106`
- APIVersion: `101049 101050`
- Estado: beta pública

## Requisitos

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Opcional: EZOCore para el acceso central desde Ajustes > EZO.
- Opcional para diagnóstico: LibDebugLogger y DebugLogViewer.

## Instalación

1. Clona este repositorio, o usa un paquete ZIP publicado cuando esté disponible.
2. Extráelo en la carpeta de AddOns de ESO para que la ruta del manifiesto sea:

```text
AddOns/EZOGroupFrames/EZOGroupFrames.txt
```

3. Activa `EZOGroupFrames` desde el menú de AddOns de ESO.
4. Recarga la interfaz.
5. Con EZOCore activo, abre Ajustes > EZO > EZOGroupFrames. Sin EZOCore, usa el panel estándar de ajustes de Addons.

## Funciones Actuales

- Panel propio de frames de grupo para grupos de mazmorra y trial.
- Miembros mostrados en bloques de cuatro.
- Miembros del grupo ordenados por rol LFG seleccionado y después por nombre.
- Etiquetas de rol para tanque, healer, DD y rol desconocido.
- Barras de salud usando los valores de salud actual y máxima indicados por ESO.
- Texto de salud con salud actual/máxima y una etiqueta de porcentaje.
- Colores de rol configurables para tanque, healer, DD y rol desconocido.
- Texto de nivel opcional.
- Texto de clase opcional.
- Panel movible cuando la posición de los frames está desbloqueada.
- Ajuste de escala de los frames.
- Comportamiento opcional de mostrar solo estando en grupo.
- Ocultación opcional del contenedor nativo de frames de grupo de ESO mientras EZOGroupFrames muestra activamente sus propios frames.
- Visibilidad HUD-only para el panel persistente de frames.
- Localización en inglés y español con selector de idioma dentro del addon.
- Modo debug con mensajes compactos enviados mediante LibDebugLogger cuando está disponible.
- Grupo simulado de cuatro solo para debug: un tanque, un healer y dos DD.

## Configuración

Con EZOCore activo, el panel completo aparece únicamente dentro de Ajustes > EZO. Sin EZOCore, los mismos controles siguen disponibles en la lista estándar de Addons de LibAddonMenu.

Cada sección de ajustes usa el icono informativo morado compartido de la familia EZO en su cabecera. Pasa el ratón sobre la cabecera de sección para ver la ayuda general de ese grupo de opciones; pasa el ratón sobre un ajuste concreto para ver su ayuda específica. El panel no mantiene párrafos explicativos largos visibles de forma permanente.

Opciones generales:

- Idioma: Auto, inglés o español.

Opciones de frames de grupo:

- Activar frames propios de grupo.
- Bloquear posición de los frames.
- Mostrar solo en grupo.
- Ocultar frames de grupo de ESO mientras está activo.
- Mostrar nivel.
- Mostrar clase.
- Escala de frames.
- Color de tanque.
- Color de healer.
- Color de DD.
- Color de rol desconocido.

Opciones de debug:

- Activar modo debug.
- Alternar grupo simulado de cuatro. Este botón está desactivado salvo que el modo debug esté activo.

## Notas de Implementación

El manifiesto del addon carga el runtime actual en este orden:

- `EZOGroupFrames.lua`: variables guardadas, valores por defecto e inicialización del addon.
- `modules/core.lua`: identidad del addon y constantes de versión.
- `modules/i18n.lua`: aplicación de textos en inglés/español.
- `modules/debug.lua`: integración con LibDebugLogger y DebugLogViewer.
- `modules/hud_visibility.lua`: guarda de visibilidad HUD/HUD UI y registro de fragmento de escena.
- `modules/debug_simulation.lua`: grupo simulado de cuatro jugadores solo para debug.
- `modules/group_state.lua`: snapshot de miembros del grupo, ordenación por rol, salud, nivel y texto de clase.
- `modules/native_frames.lua`: ocultación/restauración opcional de los frames nativos de grupo de ESO.
- `modules/lam_registry.lua`: registro de opciones de LibAddonMenu.
- `modules/menu.lua`: creación del panel de LibAddonMenu.
- `modules/frames.lua`: renderizado de frames propios y layout de barras de salud.

## Límites de Seguridad

- El addon no automatiza acciones de grupo.
- El addon no invita, expulsa, promociona, apunta a cola, confirma ready checks ni disuelve grupos.
- El addon no cambia atajos de teclado ni comportamiento de entrada.
- El addon no realiza acciones de combate.
- El addon no sincroniza datos entre jugadores.
- El addon no incluye minimapa, sistema de marcas de brújula, sistema de marcas de raid leader ni marcas guardadas por trial en la beta actual.
- Los frames nativos de grupo de ESO solo se ocultan mientras EZOGroupFrames muestra activamente sus propios frames, y ese comportamiento puede desactivarse en configuración.
- Los controles visuales persistentes están pensados para mostrarse solo en escenas HUD/HUD UI de ESO.

## Pruebas Recomendadas

Para probar la beta, revisa:

- El addon carga sin errores Lua.
- `/reloadui` funciona sin errores.
- El panel se abre dentro de Ajustes > EZO cuando EZOCore está activo, sin una entrada duplicada en la lista estándar de Addons.
- El fallback independiente de LibAddonMenu se abre cuando EZOCore no está disponible.
- Cada sección de ajustes muestra el icono informativo morado y expone su tooltip general desde la cabecera.
- La ayuda específica aparece desde los controles individuales de cada ajuste.
- La selección de idioma funciona en inglés y español.
- Los frames propios aparecen en un grupo real.
- El panel puede moverse cuando está desbloqueado y queda fijo cuando está bloqueado.
- Los valores de salud se actualizan cuando los miembros del grupo reciben daño o curación.
- Los colores de rol se aplican a tanque, healer, DD y roles desconocidos.
- El texto opcional de nivel y clase puede activarse y desactivarse.
- El grupo simulado de debug aparece solo cuando el modo debug está activo.
- Los frames nativos de ESO vuelven cuando EZOGroupFrames está desactivado o no se está mostrando.
- La UI se comprueba en modo teclado y modo gamepad.

## Licencia

EZOGroupFrames tiene licencia MIT. Consulta [LICENSE](LICENSE).
