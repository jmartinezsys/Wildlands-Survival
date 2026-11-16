# Wildlands Survival — arquitectura y plan

## Estado de la Fase 1

Este documento cierra el análisis inicial y define una propuesta para implementar el proyecto por fases. No se implementaron funcionalidades ni se crearon escenas o scripts.

## Hallazgos del proyecto actual

- `project.godot` tiene `config_version=5` y declara `4.7` en `config/features`; esto identifica la versión objetivo configurada, pero no confirma qué versión está instalada.
- El proyecto define nombre, icono, opciones de stretch (`canvas_items`, `expand`), física 3D Jolt y renderizador Windows D3D12/Forward Plus.
- No hay escena principal configurada, sección de controles (`input`) ni escenas, scripts o datos de juego en los directorios inspeccionados.
- `assets/`, `resources/`, `scenes/`, `scripts/` y `tests/` existen y están vacíos. `.godot/` contiene caché/importación local y está excluida del repositorio.
- El icono SVG sí tiene configuración de importación. No se encontraron spritesheets, tilesheets ni otros recursos gráficos originales.
- No se pudo ejecutar Godot en modo headless ni comprobar escenas, recursos o scripts: el comando `rtk` requerido por las instrucciones locales no está disponible y no se encontró un ejecutable Godot en el entorno consultado.

## Dirección visual

El juego será 2D top-down HD, con un personaje de apariencia realista y no pixelada. La implementación visual debe adaptarse a los spritesheets, tilesheets y texturas originales proporcionados por el usuario. No se deben alterar ni reemplazar esos originales. Antes de configurar animaciones o tiles, se confirmarán dimensiones y distribución de fotogramas. Si aún no existen los recursos necesarios, se documentarán como bloqueantes para la presentación visual; no se presentarán gráficos provisionales como arte final.

## Arquitectura propuesta

Se conserva la separación por sistemas indicada en `AGENTS.md` y se organiza cada sistema por tipo de archivo. Las escenas componen entidades; scripts pequeños implementan comportamiento; `Resource` guarda definiciones de datos. Los sistemas se comunican mediante señales o interfaces explícitas. La UI observa estado y emite solicitudes; no será propietaria de las reglas del juego.

```text
assets/
  characters/ environment/ animals/ items/ structures/ audio/ interface/
scenes/
  main/ player/ world/ resources/ animals/ structures/ interface/
scripts/
  player/ inventory/ survival/ interaction/ resources/ crafting/
  construction/ animals/ world/ environment/ systems/
resources/
  items/ recipes/ animals/ world/
tests/
```

La estructura propuesta coincide con la del documento de visión y debe materializarse gradualmente al crear contenido, evitando carpetas vacías innecesarias. `tests/` queda reservado para comprobaciones que puedan ejecutarse con las herramientas disponibles.

### Escenas y nodos iniciales para la Fase 2

- `scenes/main/Main.tscn`: raíz `Node2D` para coordinar `World` y la interfaz de juego.
- `scenes/world/World.tscn`: raíz `Node2D`; capas separadas mediante `TileMapLayer` para terreno y elementos que requieran capas de dibujo/colisión distintas. El mapa de prueba será pequeño y ampliable.
- `scenes/player/Player.tscn`: raíz `CharacterBody2D`; hijos para colisión, presentación animada y `Camera2D`. El tipo concreto de nodo de animación se decidirá tras inspeccionar los recursos originales disponibles.
- La interfaz se mantendrá separada del mundo (raíz `CanvasLayer` en su escena propia) cuando se introduzca.

La cámara seguirá al jugador con suavizado y límites configurables. El movimiento usará el ciclo de física y vectores normalizados para que las diagonales no sean más rápidas. El prototipo debe usar `TileMapLayer`, tal como pide la visión, y verificar su API contra la versión real instalada antes de escribir escenas.

### Límites entre sistemas

- **Player:** movimiento, orientación, colisiones y coordinación de componentes propios.
- **World:** composición del mapa, límites y, en la etapa posterior, carga de sectores.
- **Interaction:** selección/solicitud de interacción y señal hacia el objetivo; no contiene lógica de inventario.
- **Resources:** entidades recolectables y definiciones de recursos; las cantidades y requisitos se describen en `Resource`.
- **Inventory:** almacenamiento y operaciones de añadir/quitar; independiente de la presentación.
- **Survival:** estadísticas y evolución temporal del jugador.
- **Crafting / Construction:** validación de recetas o emplazamiento y solicitudes al inventario/mundo.
- **Animals / Environment:** comportamiento de fauna y estado ambiental respectivamente.
- **Systems:** servicios globales solo cuando exista una necesidad transversal demostrada (por ejemplo, guardado). Evitar autoloads para estado que pueda pertenecer a una partida/escena.
- **Save System:** serialización versionada y validada, conectada a los sistemas mediante interfaces de captura/restauración; no accede a nodos por rutas frágiles.
- **User Interface:** muestra estado y despacha acciones; recibe señales de los sistemas.

## Riesgos y decisiones pendientes

1. Confirmar versión de Godot instalada antes de implementar, especialmente por la API de `TileMapLayer` y las opciones de renderizado.
2. Revisar Forward Plus/D3D12 y Jolt 3D en el editor. No son errores comprobados, pero su necesidad en un juego 2D debe decidirse con el objetivo de plataforma y las capacidades requeridas.
3. No hay escena ejecutable, controles ni recursos de mundo/personaje. La Fase 2 requiere los spritesheets/tilesheets originales adecuados o una decisión explícita sobre cómo cubrir temporalmente ese faltante sin alterar originales.
4. El mundo abierto por chunks se pospone hasta validar el mapa limitado y medir necesidades reales de rendimiento.
5. El repositorio reportó `AGENTS.md` modificado al comenzar esta tarea; se dejó intacto porque no es parte de la documentación solicitada.

## Registro de implementación por fases

### Fase 1 — Análisis y arquitectura

- **Resultado:** arquitectura y plan registrados en este documento; análisis completado antes de crear funcionalidades.
- **Archivos:** `docs/ARQUITECTURA_Y_PLAN.md`.
- **Conexiones/pruebas:** lectura de instrucciones, configuración e inventario de archivos; después se ejecutó Godot 4.7.2 para confirmar que el proyecto base abría.
- **Pendiente entonces:** versión instalada y recursos originales. La versión se resolvió con una descarga portable oficial; los recursos originales siguen sin estar en `assets/`.

### Fase 2 — Prototipo jugable

- **Implementado:** escena principal, mapa limitado de 2400×1800, movimiento en ocho direcciones, correr, seguimiento suave de cámara, límites y obstáculos físicos. El terreno y el personaje tienen gráficos vectoriales temporales no pixelados.
- **Archivos:** `project.godot`, `scenes/main/Main.tscn`, `scenes/world/World.tscn`, `scenes/player/Player.tscn`, `scripts/main/game_session.gd`, `scripts/world/wildness_world.gd`, `scripts/player/player_controller.gd`, `scripts/player/vector_character.gd`.
- **Conexiones:** la escena principal instancia mundo, jugador e interfaz; el jugador usa InputMap, `CharacterBody2D`, `Camera2D` y colisiones.
- **Pruebas:** importación del editor y arranque headless con la escena principal en Godot 4.7.2; limpios al cerrar esta fase.
- **Límite:** las dos `TileMapLayer` están preparadas, pero el arte temporal del terreno se dibuja por código; faltan tilesheets originales para convertirlo en terreno por atlas.

### Fase 3 — Interacción y recursos

- **Implementado:** objetivo cercano, prompt E, recursos de ramas, piedra, bayas y agua, notificación y registro de objetos recolectados por sector.
- **Archivos:** `scenes/resources/ResourceNode.tscn`, `scripts/resources/resource_node.gd`, `scripts/player/player_interactor.gd`, `scripts/resources/item_definition.gd`, `resources/items/*.tres`, `scripts/inventory/inventory_component.gd`, `scripts/ui/game_hud.gd`, `scenes/interface/GameHUD.tscn`, `scripts/world/world_chunk_streamer.gd`.
- **Conexiones:** Interactor → ResourceNode → InventoryComponent → HUD; el objeto recolectado avisa al sector para persistir su ausencia durante la sesión y en el guardado.
- **Pruebas:** carga y arranque headless sin errores de scripts/escenas.
- **Pendiente:** todavía no hay tala/minería por herramientas ni interacción con fuentes de agua del mapa; el agua se representa con un recurso recogible.

### Fase 4 — Inventario y supervivencia

- **Implementado:** mochila de 24 tipos de objeto, apilado limitado por definición, selección, descripción, uso de comida/agua, eliminación; salud, hambre, sed, energía y temperatura con HUD.
- **Archivos:** `scripts/inventory/inventory_component.gd`, `scripts/survival/survival_stats.gd`, `scenes/player/Player.tscn`, `scripts/ui/game_hud.gd`, `scenes/interface/GameHUD.tscn`, `scripts/main/game_session.gd`.
- **Conexiones:** señales de inventario y estadísticas actualizan la UI; el jugador consume energía al correr y las necesidades evolucionan con el tiempo/clima.
- **Pruebas:** arranque headless y carga del HUD; sin errores reportados.
- **Pendiente:** el inventario conserva un stack por tipo (no divide un mismo tipo en varias pilas); falta balance de supervivencia mediante juego manual.

### Fase 5 — Fabricación y construcción

- **Implementado:** recetas data-driven para hacha básica, kit de fogata, refugio, almacenamiento y mesa; comprobación de materiales/espacio; previsualización de colocación, rechazo de colisiones y consumo del kit.
- **Archivos:** `scripts/crafting/*.gd`, `resources/recipes/*.tres`, `resources/items/*.tres`, `scripts/construction/building_controller.gd`, `scripts/structures/*.gd`, `scenes/structures/*.tscn`, escenas Player/Main y HUD.
- **Conexiones:** CraftingComponent retira insumos y agrega resultados; BuildingController consume kits y añade estructuras colisionables al mundo; guardado identifica estructuras permitidas.
- **Pruebas:** importación, arranque de todas las escenas y test automatizado de fabricación; limpio.
- **Pendiente:** el almacenamiento es una estructura colocable, aún no tiene inventario propio; la mesa no limita la fabricación a proximidad; hacha no altera todavía la recolección.

### Fase 6 — Mundo, fauna y ambiente

- **Implementado:** mapa limitado subdividido en chunks 600×600, carga de sectores cercanos y descarga fuera del radio; recursos reproducibles por semilla; ciervo errante que huye; ciclo día/noche, lluvia, niebla y viento con superposición visual y reloj/estado en HUD.
- **Archivos:** `scripts/world/world_chunk_streamer.gd`, `scripts/animals/wandering_animal.gd`, `scenes/animals/Deer.tscn`, `scripts/environment/day_night_controller.gd`, `scripts/environment/weather_overlay.gd`, `scripts/survival/survival_stats.gd`, HUD y escenas de mundo.
- **Conexiones:** jugador → ChunkStreamer; entorno → HUD, temperatura y fauna.
- **Pruebas:** carga de escena, registro de clases y ejecución headless limpia.
- **Pendiente:** el fondo del mapa completo todavía se dibuja como una sola escena, así que solo recursos/fauna se transmiten por chunks; faltan otras especies y una pasada de rendimiento en modo gráfico.

### Fase 7 — Guardado y carga

- **Implementado:** archivo JSON versionado en `user://wildlands_save.json`, validación de versión/tipos, posición, estadísticas, inventario, hora/clima, recursos recogidos y estructuras permitidas; F5 guarda y F9 carga.
- **Archivos:** `scripts/systems/save_system.gd`, métodos de serialización en InventoryComponent, SurvivalStats y WorldChunkStreamer, escena Main y `tests/smoke_test.gd`.
- **Conexiones:** SaveSystem recibe estado explícitamente; evita búsquedas globales por rutas de nodo para los sistemas del jugador.
- **Pruebas:** `tests/smoke_test.gd` fabricó recetas, guardó estado, lo alteró y cargó; comprobó posición, hambre, objetos, recurso recogido y fogata. Aprobado.
- **Pendiente:** guardar recursos persistentes por versión de sector es básico; el formato admite solo versión 1 y catálogo de estructuras permitido.

### Fase 8 — Presentación y pulido

- **Implementado:** animación vectorial sencilla al caminar/correr, variación ambiental día/noche, indicadores de salud/necesidades/hora/clima, efecto visual de lluvia/niebla/viento y controles visibles en HUD.
- **Archivos:** `scripts/player/vector_character.gd`, `scripts/environment/weather_overlay.gd`, `scripts/environment/day_night_controller.gd`, `scripts/ui/game_hud.gd`, `scenes/interface/GameHUD.tscn`.
- **Pruebas:** importación completa y arranque headless final; test de fabricación/guardado aprobado.
- **Pendiente:** no hay arte ni audio original en el proyecto. El arte vectorial autorizado es temporal, no realista ni definitivo. Faltan spritesheets/tilesheets del personaje y entorno, animaciones HD, audio, ajustes visuales en editor y comprobación manual del juego en ventana.

## Validación final y estado

- **Motor:** Godot 4.7.2 stable, descargado de forma portable desde el sitio oficial para esta validación. La configuración del proyecto declara Godot 4.7.
- **Resultado técnico:** Godot 4.7.2 importó el proyecto en modo headless. La prueba ampliada `tests/smoke_test.gd` aprobó escena principal, crafting, guardado/carga, nado, cuchillo inicial, requisito de pico, daño, activación nocturna de lobos y sueño hasta las 07:00.
- **Errores detectados y corregidos durante el trabajo:** API inexistente `draw_ellipse`/`draw_rounded_rect`, polígono de río inválido, clases globales aún sin indexar, identificador de estructura no conservado por el primer enfoque. La validación final no reprodujo esos errores.
- **Verificación no realizada:** una captura de ventana para revisar encuadre, escala y animaciones no pudo completarse porque la automatización visual agotó su tiempo de aprobación. La prueba headless no valida la apariencia final.
- **Limitación visual:** venado y lobo usan las hojas del usuario con recortes estimados; la hoja compuesta de acciones y el atlas compuesto de objetos se conservan en `assets/source/` pero todavía no se cortan en clips/celdas runtime.
- **Git:** no se modificó ni se incluyó `.godot`; el `AGENTS.md` aparece modificado por cambios del usuario y debe permanecer fuera de este commit.

## Actualización: personaje y terreno con hojas del usuario

- Los originales están organizados bajo `assets/source/` y las derivaciones bajo `assets/processed/`. La hoja del personaje conserva sus píxeles originales; el patrón de transparencia se retira en la copia procesada. `sprite_sheet_animator.gd` prepara 10 cuadros por cada una de 8 filas/direcciones; la asignación aún debe confirmarse visualmente.
- `assets/source/environment/ground_tilesheet.png` conserva la hoja de suelo más reciente. Sus celdas medidas se procesan en un atlas de 32 × 32 sin gutters; los bordes hierba/tierra y arena/tierra tienen orientaciones rotadas para el perímetro de los caminos. `wildness_world.gd` agrupa variaciones de vegetación y genera caminos continuos al río y al estanque. El atlas anterior se conserva, pero ya no genera el suelo.
- Las áreas `River` y `Pond` combinan piezas de orilla del atlas con un shader animado. Al entrar, el jugador cambia a estado de nado, se desplaza más despacio y tiene un movimiento vertical leve; al salir vuelve a su desplazamiento normal.
- **Validación ejecutada:** importación y arranque headless en Godot 4.7.2; `tests/smoke_test.gd` confirma entrada/salida de agua en río y estanque, además de crafting y guardado/carga. Aprobada sin errores.
- **Pendiente:** revisión en ventana para ajustar el mapeo visual de filas del personaje, la escala y las juntas de las orillas; el nadador usa el ciclo direccional existente, pues la hoja no incluye una pose específica de nado.
