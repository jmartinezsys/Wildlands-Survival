# Terreno y agua

- `ground_tilesheet.png` es la hoja nueva recibida (1024 × 559, RGB); se conserva sin modificar.
- Sus 12 columnas y seis bandas completas de suelo se recortaron en celdas de 56 × 56 px. El atlas runtime contiene 108 celdas de 32 × 32 px: 60 de suelo y 48 transformaciones de las 12 piezas de transición mediante rotación de 90°, 180° y 270°.
- Las bandas usadas contienen hierba, vegetación, tierra, arena, piedra y bordes de transición. La última banda de agua se conserva en el original, pero se omite del suelo repetible porque está cortada por el borde inferior de la imagen.
- `terrain_spritesheet.png` y `assets/processed/environment/terrain_atlas.png` son el conjunto anterior; permanecen como respaldo, pero `wildness_world.gd` ya no los usa para generar el suelo.
- El agua sigue usando su shader y sus áreas de río/estanque; no depende de la banda de agua de esta hoja.

El original no se modifica. `assets/previews/ground_tilesheet_cells_preview.png` permite revisar los recortes medidos antes de importarlos al motor.
