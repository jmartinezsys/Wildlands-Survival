extends Node2D

## Temporary vector character silhouette; replace only after original art is provided.
var _walk_phase := 0.0

func _process(delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player != null and player.velocity.length_squared() > 1.0:
		_walk_phase += delta * (13.0 if player.velocity.length() > 200.0 else 8.0)
	else:
		_walk_phase = 0.0
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-13.0, -9.0, 26.0, 23.0), Color("493b2f"))
	draw_rect(Rect2(-11.0, -7.0, 22.0, 18.0), Color("6d563c"))
	var stride := sin(_walk_phase) * 3.0
	_draw_ellipse(Vector2(-6.5 - stride, 12.0), Vector2(5.5, 9.0), Color("272b28"))
	_draw_ellipse(Vector2(6.5 + stride, 12.0), Vector2(5.5, 9.0), Color("272b28"))
	_draw_ellipse(Vector2(0.0, 1.0), Vector2(13.0, 16.0), Color("53634b"))
	_draw_ellipse(Vector2(-2.0, -2.0), Vector2(8.0, 10.0), Color("718064"))
	_draw_ellipse(Vector2(0.0, -13.0), Vector2(8.5, 9.0), Color("c69a75"))
	_draw_ellipse(Vector2(0.0, -17.0), Vector2(8.0, 5.0), Color("46382d"))
	draw_line(Vector2(-9.0, -1.0), Vector2(-13.0, 7.0 + stride), Color("b79776"), 3.0, true)
	draw_line(Vector2(9.0, -1.0), Vector2(13.0, 7.0 - stride), Color("b79776"), 3.0, true)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radii)
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
