EZO_GROUP_FRAMES_STRINGS_ES = {
    EZO_GF_MENU_GENERAL = "General",
    EZO_GF_MENU_GENERAL_TOOLTIP = "Idioma y ajustes generales de presentación de EZOGroupFrames.",
    EZO_GF_MENU_FRAMES = "Frames de grupo",
    EZO_GF_MENU_FRAMES_TOOLTIP = "Ajustes de visualización de los frames propios de grupo. " ..
        "Estos controles afectan al panel del addon, la ordenación por rol, la presentación de barras de salud " ..
        "y la ocultación opcional de los frames nativos.",
    EZO_GF_MENU_EZO_STATUS = "Estado EZO de jugador",
    EZO_GF_MENU_EZO_STATUS_TOOLTIP = "Estado opcional de jugador de la familia EZO mostrado en los frames compactos. " ..
        "Los datos se consumen y comparten solo mediante presencia de grupo de EZOCore cuando los clientes compatibles los proporcionan.",
    EZO_GF_OPTION_LANGUAGE = "Idioma",
    EZO_GF_OPTION_LANGUAGE_TOOLTIP = "Idioma local usado cuando EZOCore no está instalado o su modo de idioma es 'dejar que cada addon elija'. Los idiomas centrales de EZOCore desactivan este selector.",
    EZO_GF_OPTION_LANGUAGE_AUTO = "Auto (cliente ESO)",
    EZO_GF_OPTION_FRAMES_ENABLE = "Activar frames propios de grupo",
    EZO_GF_OPTION_FRAMES_ENABLE_TOOLTIP = "Muestra el panel propio de EZOGroupFrames. " ..
        "Los frames nativos de ESO se controlan por separado con la opción de ocultación nativa.",
    EZO_GF_OPTION_FRAMES_LOCK = "Bloquear posición",
    EZO_GF_OPTION_FRAMES_LOCK_TOOLTIP = "Cuando está bloqueado, el panel propio de frames no se puede arrastrar. " ..
        "Desbloquéalo y arrástralo con el botón izquierdo para guardar su posición.",
    EZO_GF_OPTION_FRAMES_SCALE = "Escala de frames",
    EZO_GF_OPTION_FRAMES_SCALE_TOOLTIP = "Ajusta el tamaño del panel propio de frames de grupo " ..
        "sin cambiar su posición guardada.",
    EZO_GF_OPTION_FRAMES_GROUP_ONLY = "Mostrar solo en grupo",
    EZO_GF_OPTION_FRAMES_GROUP_ONLY_TOOLTIP = "Cuando está activo, el panel propio se oculta salvo que ESO indique " ..
        "que estás en grupo.",
    EZO_GF_OPTION_HIDE_NATIVE = "Ocultar frames nativos mientras esté activo",
    EZO_GF_OPTION_HIDE_NATIVE_TOOLTIP = "Oculta el contenedor nativo de frames de grupo de ESO solo mientras " ..
        "EZOGroupFrames muestra sus propios frames.",
    EZO_GF_OPTION_SHOW_LEVEL = "Mostrar nivel",
    EZO_GF_OPTION_SHOW_LEVEL_TOOLTIP = "Añade el nivel o los Puntos de Campeón del miembro a cada frame propio " ..
        "cuando ESO proporciona ese dato.",
    EZO_GF_OPTION_SHOW_CLASS = "Mostrar clase",
    EZO_GF_OPTION_SHOW_CLASS_TOOLTIP = "Añade el texto de clase del miembro a cada frame propio " ..
        "cuando ESO proporciona ese dato.",
    EZO_GF_OPTION_COLOR_TANK = "Color de tanque",
    EZO_GF_OPTION_COLOR_TANK_TOOLTIP = "Color usado para etiquetas de rol y relleno de barra de salud de tanques.",
    EZO_GF_OPTION_COLOR_HEALER = "Color de healer",
    EZO_GF_OPTION_COLOR_HEALER_TOOLTIP = "Color usado para etiquetas de rol y relleno de barra de salud de healers.",
    EZO_GF_OPTION_COLOR_DAMAGE = "Color de DD",
    EZO_GF_OPTION_COLOR_DAMAGE_TOOLTIP = "Color usado para etiquetas de rol y relleno de barra de salud de DD.",
    EZO_GF_OPTION_COLOR_UNKNOWN = "Color de rol sin definir",
    EZO_GF_OPTION_COLOR_UNKNOWN_TOOLTIP = "Color usado cuando ESO no informa rol de tanque, healer o DD " ..
        "para un miembro.",
    EZO_GF_OPTION_SHOW_EZO_STATUS = "Mostrar estado EZO de jugador en frames de grupo",
    EZO_GF_OPTION_SHOW_EZO_STATUS_TOOLTIP = "Añade un texto compacto de estado EZO a cada fila de miembro cuando EZOCore " ..
        "tiene estado compatible de ese jugador de grupo.",
    EZO_GF_OPTION_SHOW_PING = "Mostrar ping",
    EZO_GF_OPTION_SHOW_PING_TOOLTIP = "Muestra el ping recibido como texto compacto en milisegundos, por ejemplo 42ms.",
    EZO_GF_OPTION_SHOW_FPS = "Mostrar FPS",
    EZO_GF_OPTION_SHOW_FPS_TOOLTIP = "Muestra los frames por segundo recibidos como texto compacto, por ejemplo 58fps.",
    EZO_GF_OPTION_SHOW_PRIVACY = "Mostrar indicador de privacidad",
    EZO_GF_OPTION_SHOW_PRIVACY_TOOLTIP = "Muestra el estado compacto de privacidad recibido mediante EZOCore.",
    EZO_GF_OPTION_SHARE_PERFORMANCE = "Compartir mi ping/FPS/privacidad",
    EZO_GF_OPTION_SHARE_PERFORMANCE_TOOLTIP = "Cuando está activo, publica ping, FPS y privacidad locales redondeados " ..
        "mediante presencia de grupo de EZOCore con intervalo limitado. Al desactivarlo encola inmediatamente una retirada con estado oculto. " ..
        "Esta opción requiere que el transporte de grupo de EZOCore esté activo.",
    EZO_GF_OPTION_DEBUG = "Debug",
    EZO_GF_OPTION_DEBUG_TOOLTIP = "Herramientas de desarrollo y soporte. El debug sale por LibDebugLogger " ..
        "cuando está disponible y no debe usarse como flujo normal de juego.",
    EZO_GF_OPTION_DEBUG_MODE = "Activar modo debug",
    EZO_GF_OPTION_DEBUG_MODE_TOOLTIP = "Escribe mensajes técnicos compactos solo cuando el modo debug está activo.",
    EZO_GF_OPTION_PREVIEW_MODE = "Modo previsualización de ejemplo",
    EZO_GF_OPTION_PREVIEW_MODE_TOOLTIP = "Muestra temporalmente un grupo de 4 o 12 miembros de ejemplo para ajustar la posición, escala, colores y visibilidad de los marcos sin grupo real.",
    EZO_GF_PREVIEW_OFF = "Desactivado",
    EZO_GF_PREVIEW_GROUP_4 = "Ejemplo 4 miembros (Dungeon)",
    EZO_GF_PREVIEW_GROUP_12 = "Ejemplo 12 miembros (Trial)",
    EZO_GF_OPTION_DEBUG_SIMULATED_GROUP = "Alternar grupo simulado de 4",
    EZO_GF_OPTION_DEBUG_SIMULATED_GROUP_TOOLTIP = "Ayuda de desarrollo solo en debug: muestra un tanque, " ..
        "un healer y dos DD sin grupo real.",
    EZO_GF_STATUS_NOT_GROUPED = "Sin grupo",
    EZO_GF_STATUS_GROUP = "Grupo",
    EZO_GF_STATUS_GROUP_PREVIEW_4 = "Grupo (Ejemplo 4)",
    EZO_GF_STATUS_GROUP_PREVIEW_12 = "Grupo (Ejemplo 12)",
    EZO_GF_PRIVACY_PUBLIC_SHORT = "PUB",
    EZO_GF_PRIVACY_PRIVATE_SHORT = "PRV",
    EZO_GF_PRIVACY_HIDDEN_SHORT = "OCU",
    EZO_GF_PRIVACY_UNKNOWN_SHORT = "?",
    EZO_GF_ROLE_TANK = "Tanque",
    EZO_GF_ROLE_HEALER = "Healer",
    EZO_GF_ROLE_DAMAGE = "DD",
    EZO_GF_ROLE_UNKNOWN = "Rol",
}
