extends Node2D

func _draw() -> void:
	draw_circle(Vector2(0, 4), 26.0, Color("4d493d"))
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 32, Color("a78e67"), 3.0, true)
	draw_line(Vector2(-14, 8), Vector2(14, -5), Color("654d35"), 7.0, true)
	draw_line(Vector2(-14, -5), Vector2(14, 8), Color("806244"), 7.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -20), Vector2(-7, -3), Vector2(0, 1), Vector2(6, -4)]), Color("e88437"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -12), Vector2(-3, -2), Vector2(1, 0), Vector2(3, -4)]), Color("f2c46f"))
