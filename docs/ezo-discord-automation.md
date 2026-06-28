# EZO Discord automation

Este repositorio usa `ezo-addon.json` como configuracion local del addon.

## Objetivo

- Generar un ZIP limpio en `dist/`.
- Mantener fuera del ZIP los archivos internos de desarrollo.
- Preparar el addon para publicaciones de estado, beta y release en Discord cuando se anadan workflows.
- No guardar URLs reales de webhooks en el repositorio.

## Configuracion local

Para EZOGroupFrames, el ZIP se genera como:

```text
dist/EZOGroupFrames_v0.1.3.zip
```

Dentro del ZIP debe existir una carpeta raiz:

```text
EZOGroupFrames/
```

## Uso recomendado de canales

- `#addon-status`: estado tecnico corto del addon. No adjunta ZIP.
- `#beta-builds`: builds para testers. Adjunta ZIP limpio.
- `#releases`: nota tecnica de release. No adjunta ZIP por defecto.
- `#downloads`: canal limpio de descarga. Adjunta ZIP limpio.
- `#announcements`: aviso humano para jugadores/testers. No adjunta ZIP por defecto.
- `#codex-log`: log interno de automatizacion. No adjunta ZIP.

El ZIP va en `#beta-builds` para pruebas y en `#downloads` para descargas finales.

## Procedimiento

La publicacion en Discord no forma parte de cada commit o push.

Flujo normal:

```text
editar -> probar -> commit -> push
```

Flujo de publicacion:

```text
validar ZIP limpio -> pedir confirmacion -> lanzar workflow Discord
```

Antes de publicar, pedir confirmacion explicita:

```text
status
beta
release + download
no publicar
```

No publicar rutas locales, NAS, symlinks ni ramas en mensajes publicos.
