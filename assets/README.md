# Inventario de recursos gráficos

Los archivos originales se guardan bajo `source/`; las derivaciones listas para importar están en `processed/`. Los originales RGB se conservan intactos. Las hojas de personaje/animal de 1024 × 559 muestran el tablero de transparencia incrustado; los PNG de `processed/` derivan de esos originales para retirar el fondo cuadriculado.

| Archivo original | Tipo / dimensiones | Distribución observable | Estado |
| --- | --- | --- | --- |
| `source/characters/player_spritesheet.png` | Personaje, 1024 × 1024, RGB | 10 columnas × 8 bandas visibles; celdas configuradas de 102 × 128 px | Integrado en `sprite_sheet_animator.gd`; mapeo de direcciones inferido y por confirmar visualmente. |
| `source/characters/player_actions_spritesheet.png` | Acciones del personaje, 1024 × 559, RGB | Paneles de talar, golpear, picar y recoger con rótulos y divisiones irregulares | Guardado intacto; aún no se divide en clips porque las celdas/márgenes de cada panel no se han medido. Las interacciones tienen una animación breve de inclinación. |
| `source/animals/deer_spritesheet.png` | Venado, 1024 × 559, RGB | 10 columnas y 4 bandas aproximadas; se configuran cuadros de 102 × 140 px | Integrado en `scenes/animals/Deer.tscn`; la orientación por fila requiere revisión visual en Godot. |
| `source/animals/deer_states_spritesheet.png` | Estados de venado, 1024 × 559, RGB | 10 columnas y 4 bandas aproximadas | Conectado como hoja de reposo; el contenido de cada fila es una interpretación visual provisional. |
| `source/animals/wolf_spritesheet.png` | Lobo, 1024 × 559, RGB | 10 columnas y 4 bandas aproximadas; cuadros configurados de 102 × 140 px | Integrado en `scenes/animals/Wolf.tscn`; la orientación por fila requiere revisión visual. |
| `source/items/natural_resources_spritesheet.png` | Recursos naturales, 1024 × 559, RGB | Paneles con tiles, objetos y rótulos; el tamaño de celda no es uniforme a simple vista | Guardado intacto; todavía no se usa como atlas runtime porque requiere definir regiones sin incluir rótulos. |
| `source/environment/terrain_spritesheet.png` | Terreno, 1024 × 559, RGB | Atlas derivado 12 × 6, celdas de 80 × 80 px según la configuración existente | Integrado mediante `processed/environment/terrain_atlas.png`. |

Las derivaciones mantienen las dimensiones de los originales salvo el atlas de terreno (960 × 480 px). Todas las distribuciones marcadas como aproximadas deben verificarse contra la vista del juego antes de considerarlas definitivas.
