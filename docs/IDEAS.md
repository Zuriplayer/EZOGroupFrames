# EZOGroupFrames Ideas

Estas ideas quedan aparcadas para cuando se pidan propuestas o roadmap. No son scope implementado.

## Trial and dungeon group frames

- Frames propios por rol, subgrupo, vida, estado y funciones imprescindibles.
- Opciones separadas para dungeon y trial.
- Sustitucion de frames vanilla solo si existe setting explicito.
- Guardar perfiles por trial o tipo de contenido.
- Asimilar escudos/absorciones activos sobre la salud y estados similares que ayuden a leer supervivencia real.
- Avisar de miembros sin comida activa o con comida al limite, si la API permite detectarlo de forma fiable.
- Indicador de dano total de grupo, si los datos disponibles permiten calcularlo de forma fiable y sin coste excesivo.
- Indicador de porcentaje de dano por jugador dentro del grupo, si los datos disponibles permiten calcularlo de forma fiable y sin coste excesivo.
- Alternative Group Frame instalado localmente puede servir como referencia secundaria de comportamiento: rol LFG, capas de shield/trauma y opciones de iconos, sin convertirlo en dependencia.

## "Ya veremos donde"

Puede ser un panel, brujula, minimap propio, overlay de sala u otra superficie futura.

- Puntos personalizados del jugador: un punto concreto en una sala de una trial, por ejemplo.
- Posicion de companeros del grupo con algun tipo de brujula o minimap.
- Que el raid lider pueda marcar acciones, grupos, posiciones u ordenes en esa superficie.
- Que esas marcas se puedan guardar por trial.
- Cuando los frames basicos funcionen, analizar un minimap o brujula con la posicion de todos los jugadores que tengan el addon.

## Limites iniciales

- No automatizar acciones de grupo.
- No depender de que todos los jugadores tengan el addon salvo que se disene una fase de sincronizacion explicita.
- No usar una UI visible fuera de `hud` / `hudui`.
- No tocar input ni keybinds sin definir modo afectado, trigger exacto y modos que no deben cambiar.
