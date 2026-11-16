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
	_generate_terrain()
	_create_obstacles()

func _generate_terrain() -> void:
	var terrain_layer := get_node("TerrainLayer") as TileMapLayer
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(80, 80)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load("res://assets/processed/environment/terrain_atlas.png")
	atlas.texture_region_size = Vector2i(80, 80)
	for row in range(6):
		for column in range(12):
			atlas.create_tile(Vector2i(column, row))
	tile_set.add_source(atlas, 0)
	terrain_layer.tile_set = tile_set
	terrain_layer.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 45831
	for y in range(23):
		for x in range(30):
			var atlas_coordinate := Vector2i(rng.randi_range(0, 3), rng.randi_range(0, 3))
			var clearing_center := 9.0 + sin(float(x) * 0.22) * 1.4
			if x >= 3 and x <= 6 and y >= 14 and y <= 15:
				atlas_coordinate = Vector2i(8 + x - 3, 4 + y - 14)
			elif absf(float(y) - clearing_center) < 1.4:
				atlas_coordinate = Vector2i(rng.randi_range(8, 11), rng.randi_range(0, 3))
			elif (x * 13 + y * 7) % 31 == 0:
				atlas_coordinate = Vector2i(rng.randi_range(4, 7), rng.randi_range(4, 5))
			elif (x * 5 + y * 11) % 37 == 0:
				atlas_coordinate = Vector2i(rng.randi_range(4, 7), rng.randi_range(0, 3))
			terrain_layer.set_cell(Vector2i(x, y), 0, atlas_coordinate)

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
	_draw_brush()
	_draw_trees()
	_draw_rocks()

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
