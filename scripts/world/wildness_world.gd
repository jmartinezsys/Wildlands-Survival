extends Node2D

const WORLD_SIZE := Vector2(2400.0, 1800.0)
const TREE_POSITIONS: Array[Vector2] = [
	Vector2(250, 250), Vector2(450, 320), Vector2(700, 220), Vector2(970, 360),
	Vector2(1250, 220), Vector2(1540, 330), Vector2(1810, 240), Vector2(2130, 380),
	Vector2(330, 800), Vector2(640, 1020), Vector2(990, 850), Vector2(1370, 1090),
	Vector2(1740, 890), Vector2(2050, 1150), Vector2(500, 1510), Vector2(1110, 1470),
	Vector2(1660, 1510), Vector2(2180, 1540)
]
const ROCK_POSITIONS: Array[Vector2] = [Vector2(350, 520), Vector2(740, 1350), Vector2(1260, 520), Vector2(1510, 770), Vector2(2180, 700)]

func _ready() -> void:
	_create_obstacles()

func _create_obstacles() -> void:
	for tree_position in TREE_POSITIONS:
		_add_circle_obstacle(tree_position + Vector2(2, 16), 9.0)
	for rock_position in ROCK_POSITIONS:
		_add_circle_obstacle(rock_position, 15.0)

func _add_circle_obstacle(obstacle_position: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.position = obstacle_position
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	collision.shape = circle
	body.add_child(collision)
	add_child(body)

func _draw() -> void:
	_draw_ground()
	_draw_water()
	_draw_brush()
	_draw_trees()
	_draw_rocks()

func _draw_ground() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("536b45"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 14291
	for index in range(360):
		var point := Vector2(rng.randf_range(20.0, WORLD_SIZE.x - 20.0), rng.randf_range(20.0, WORLD_SIZE.y - 20.0))
		var size := rng.randf_range(5.0, 20.0)
		var tint := Color("61794c") if index % 3 == 0 else Color("4b6241")
		_draw_ellipse(point, Vector2(size * 1.4, size), tint)
	var clearing := PackedVector2Array([
		Vector2(0, 690), Vector2(0, 630), Vector2(380, 650), Vector2(730, 700),
		Vector2(1090, 670), Vector2(1450, 610), Vector2(1810, 640), Vector2(2400, 580),
		Vector2(2400, 850), Vector2(1960, 870), Vector2(1600, 830), Vector2(1220, 900),
		Vector2(850, 870), Vector2(470, 820), Vector2(0, 860)
	])
	draw_colored_polygon(clearing, Color("718052"))

func _draw_water() -> void:
	var watercourse := PackedVector2Array([
		Vector2(1930, -60), Vector2(1950, 220), Vector2(2020, 490), Vector2(1980, 730),
		Vector2(1890, 960), Vector2(1900, 1190), Vector2(1760, 1450), Vector2(1660, 1840)
	])
	draw_polyline(watercourse, Color("b5a779"), 196.0, true)
	draw_polyline(watercourse, Color("527c80"), 154.0, true)
	for point in watercourse:
		_draw_ellipse(point, Vector2(98, 98), Color("b5a779"))
		_draw_ellipse(point, Vector2(77, 77), Color("527c80"))
	_draw_ellipse(Vector2(430, 1270), Vector2(190, 115), Color("b5a779"))
	_draw_ellipse(Vector2(430, 1265), Vector2(168, 94), Color("527c80"))

func _draw_brush() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 713
	for index in range(85):
		var point := Vector2(rng.randf_range(40.0, WORLD_SIZE.x - 40.0), rng.randf_range(40.0, WORLD_SIZE.y - 40.0))
		if point.distance_to(Vector2(1200, 760)) < 160.0:
			continue
		var radius := rng.randf_range(14.0, 31.0)
		_draw_ellipse(point + Vector2(3, 5), Vector2(radius, radius * 0.72), Color("343f31"))
		_draw_ellipse(point, Vector2(radius, radius * 0.72), Color("40563a") if index % 2 == 0 else Color("4d6340"))

func _draw_trees() -> void:
	for point in TREE_POSITIONS:
		_draw_ellipse(point + Vector2(5, 11), Vector2(35, 24), Color("374633"))
		_draw_ellipse(point + Vector2(0, 2), Vector2(28, 29), Color("344332"))
		_draw_ellipse(point + Vector2(-5, -3), Vector2(23, 23), Color("536d45"))
		_draw_ellipse(point + Vector2(5, -8), Vector2(17, 17), Color("61784c"))
		draw_circle(point + Vector2(2, 16), 5.0, Color("796248"))

func _draw_rocks() -> void:
	for point in ROCK_POSITIONS:
		_draw_ellipse(point + Vector2(4, 7), Vector2(23, 14), Color("3d493b"))
		_draw_ellipse(point, Vector2(19, 12), Color("777a6b"))
		_draw_ellipse(point + Vector2(-4, -3), Vector2(8, 4), Color("a0a08a"))

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radii)
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
