# EZOGroupFrames

EZOGroupFrames es un addon en beta pública para The Elder Scrolls Online que proporciona frames de grupo compactos y opcionales para grupos de mazmorra y trial.

¿Prefieres inglés? Lee el [README en inglés](README.md).
Soporte, errores y sugerencias: https://discord.gg/ekw8zUAcRm

## Estado

EZOGroupFrames está en beta pública. Es usable para pruebas, pero su diseño y conjunto de funciones pueden cambiar mientras se valida el comportamiento de los frames de grupo en grupos reales de mazmorra y trial.

## Metadatos de versión

- Versión del addon: `0.1.15`
- AddOnVersion: `115`
- APIVersion: `101049 101050`
- Estado: beta pública

## Requisitos

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Opcional: EZOCore para el acceso central desde Ajustes > EZO y estado EZO de jugador opcional en los frames de grupo.
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
- Iconos nativos de ESO para los roles de tanque, healer y DD.
- Barras de salud usando los valores de salud actual y máxima indicados por ESO.
- Texto de salud con salud actual/máxima y una etiqueta de porcentaje.
- Icono de corona de alto contraste del líder de grupo en la barra de salud del líder.
- Colores de rol configurables para tanque, healer, DD y rol desconocido.
- Texto opcional de nivel y clase, separado del nombre del jugador para mejorar la legibilidad.
- Panel movible cuando la posición de los frames está desbloqueada.
- Integración temporal con el modo compartido de disposición de interfaz de EZOCore, sin cambiar la preferencia de bloqueo guardada.
- Ajuste de escala de los frames.
- Comportamiento opcional de mostrar solo estando en grupo.
- Ocultación opcional del contenedor nativo de frames de grupo de ESO mientras EZOGroupFrames muestra activamente sus propios frames.
  Usa el mecanismo propio de ESO de motivos de ocultación de frames de grupo/raid cuando está disponible.
- Estado EZO de jugador opcional junto a cada miembro del grupo, consumido mediante presencia de grupo de EZOCore: ping como `42ms`, FPS como `58fps` y una insignia compacta de privacidad.
- Colores de aviso opcionales para el estado EZO: el ping pasa a amarillo desde `150ms` y a rojo desde `250ms`; los FPS pasan a amarillo con `45fps` o menos y a rojo con `30fps` o menos.
- Compartición opcional y expresa de tu ping, FPS y estado público de privacidad redondeados mediante presencia de grupo de EZOCore con intervalo limitado.
- Al desactivar la compartición se encola inmediatamente una retirada con estado oculto; los pares privados u ocultos nunca muestran ping o FPS con valor cero como si fueran métricas reales.
- Visibilidad HUD-only para el panel persistente de frames.
- Localización en inglés y español con selector de idioma dentro del addon.
- Modo debug con mensajes compactos enviados mediante LibDebugLogger cuando está disponible.
- Grupo simulado de cuatro solo para debug: un tanque, un healer y dos DD.

## Configuración

Con EZOCore activo, el panel completo aparece únicamente dentro de Ajustes > EZO y la superficie de frames puede participar en el modo global o individual de disposición de interfaz. Sin EZOCore, los mismos controles y el desbloqueo local siguen disponibles en la lista estándar de Addons de LibAddonMenu.

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

Opciones de estado EZO de jugador:

- Mostrar estado EZO de jugador en frames de grupo.
- Mostrar ping.
- Mostrar FPS.
- Mostrar indicador de privacidad.
- Compartir mi ping/FPS/privacidad.

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
- `modules/group_state.lua`: snapshot de miembros del grupo, ordenación por rol, estado de líder, salud, nivel y texto de clase.
- `modules/ezocore_performance.lua`: puente opcional productor/consumidor de `performanceState` de EZOCore.
- `modules/native_frames.lua`: ocultación/restauración opcional de los frames nativos de grupo de ESO.
- `modules/lam_registry.lua`: registro de opciones de LibAddonMenu.
- `modules/menu.lua`: creación del panel de LibAddonMenu.
- `modules/frames.lua`: renderizado de frames propios y layout de barras de salud.

## Límites de Seguridad

- El addon no automatiza acciones de grupo.
- El addon no invita, expulsa, promociona, apunta a cola, confirma ready checks ni disuelve grupos.
- El addon no cambia atajos de teclado ni comportamiento de entrada.
- El addon no realiza acciones de combate.
- El addon no es propietario, no registra y no maneja directamente protocolos de LibGroupBroadcast. El estado opcional de jugador se consume o comparte solo mediante la API de servicio de EZOCore.
- La compartición de estado de jugador está desactivada por defecto y se limita a ping, FPS y privacidad redondeados. Solo puede activarse mientras el transporte de grupo de EZOCore está operativo.
- Los resultados del transporte de rendimiento y los primeros estados recibidos de cada par se escriben en Log Viewer únicamente cuando el debug del addon está activo.
- El addon no incluye minimapa, sistema de marcas de brújula, sistema de marcas de raid leader ni marcas guardadas por trial en la beta actual.
- Los frames nativos de grupo de ESO solo se ocultan mientras EZOGroupFrames muestra activamente sus propios frames, y ese comportamiento puede desactivarse en configuración.
  El addon no fuerza directamente la ocultación del contenedor nativo cuando la API de motivos de ocultación de ESO está disponible.
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
- El modo central muestra una previsualización movible solo al volver a HUD/HUD_UI y no altera el ajuste de bloqueo guardado.
- Los valores de salud se actualizan cuando los miembros del grupo reciben daño o curación.
- El líder del grupo aparece marcado con un icono de corona legible en la barra de salud.
- Los iconos nativos de rol aparecen para tanque, healer y DD, y los colores de rol siguen aplicándose a los iconos y las barras.
- El texto opcional de nivel y clase puede activarse y desactivarse, y permanece separado del nombre del jugador.
- Con presencia de grupo de EZOCore disponible en clientes compatibles agrupados, activa estado EZO de jugador, ping, FPS y privacidad y comprueba que el texto compacto aparezca sin ensanchar las filas.
- Comprueba que el ping alto y los FPS bajos cambian a amarillo o rojo en los umbrales documentados.
- Activa la compartición en un cliente y comprueba que las actualizaciones estén limitadas; después desactívala y confirma que el par cambia a oculto sin mostrar `0ms` ni `0fps`.
- Repite con EZOCore desactivado para confirmar que los controles de estado EZO no generan errores Lua y los frames siguen funcionando localmente.
- El grupo simulado de debug aparece solo cuando el modo debug está activo.
- Los frames nativos de ESO vuelven cuando EZOGroupFrames está desactivado o no se está mostrando.
- Con la ocultación de frames nativos activa, cambiar entre modo teclado y modo gamepad no genera errores nativos de unit frames.
- La UI se comprueba en modo teclado y modo gamepad.

## Licencia

EZOGroupFrames tiene licencia MIT. Consulta [LICENSE](LICENSE).
