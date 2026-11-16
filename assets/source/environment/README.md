# Terreno y agua

- `terrain_spritesheet.png` conserva la hoja recibida (1024 × 559, RGB).
- `terrain_atlas.png` es una copia de trabajo ordenada como atlas 12 × 6 de celdas 80 × 80; elimina los márgenes entre las celdas y permite usar `TileMapLayer`.
- Los grupos de columnas 0–3, 4–7 y 8–11 contienen terreno de hierba, tierra/piedra y caminos; las dos filas inferiores incluyen arena, suelo rocoso y piezas de orilla.
- El agua usa las piezas de orilla del atlas como transición visual y un shader animado para la superficie. `WaterArea` define la forma de río/estanque, detecta al jugador y activa nado con desplazamiento reducido.

El archivo original no se modifica. Las posiciones de recorte se dedujeron de la separación visible en la hoja y se pueden ajustar si el archivo fuente tiene una plantilla de atlas más precisa.
