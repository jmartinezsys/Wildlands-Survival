extends Node2D

@export var structure_type: StringName = &"shelter"

func _draw() -> void:
	match structure_type:
		&"shelter":
			draw_colored_polygon(PackedVector2Array([Vector2(-38, 20), Vector2(-30, -10), Vector2(0, -30), Vector2(30, -10), Vector2(38, 20)]), Color("766348"))
			draw_colored_polygon(PackedVector2Array([Vector2(-28, 15), Vector2(-22, -7), Vector2(0, -22), Vector2(23, -7), Vector2(28, 15)]), Color("9a8057"))
			draw_rect(Rect2(-7, 0, 14, 20), Color("473c2f"))
		&"storage":
			draw_rect(Rect2(-20, -14, 40, 28), Color("725639"))
			draw_rect(Rect2(-17, -11, 34, 7), Color("96754b"))
			draw_line(Vector2(-18, 0), Vector2(18, 0), Color("bd9b61"), 3.0, true)
		&"workbench":
			draw_rect(Rect2(-28, -11, 56, 22), Color("856945"))
			draw_line(Vector2(-22, 11), Vector2(-25, 26), Color("493b2c"), 4.0, true)
			draw_line(Vector2(22, 11), Vector2(25, 26), Color("493b2c"), 4.0, true)
