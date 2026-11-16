# Personaje principal

- `player_spritesheet.png` conserva la imagen recibida. Es RGB y trae el patrón de cuadros incrustado; no tiene canal alfa.
- `player_spritesheet_transparent.png` es una copia derivada que retira el fondo para poder usar la hoja en el juego. El original se mantiene intacto.
- La hoja se interpreta como una cuadrícula de 10 columnas × 8 filas, con 10 cuadros por fila. `scripts/player/sprite_sheet_animator.gd` configura las filas como sur, norte, este, oeste y cuatro diagonales.
- Las celdas configuradas miden 102 × 128 píxeles, con muestreo lineal y escala de juego 0.48.

La distribución de direcciones se infirió visualmente de la imagen. Conviene confirmarla en el editor con las animaciones en movimiento antes de tratar el mapeo como definitivo.
