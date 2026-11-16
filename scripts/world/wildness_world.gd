extends Node2D

const WORLD_SIZE := Vector2(2400.0, 1800.0)
const TERRAIN_TILE_SIZE := 32
const TERRAIN_ATLAS_COLUMNS := 12
const TERRAIN_ATLAS_ROWS := 9
const RIVER_PATH: Array[Vector2] = [Vector2(1200, 760), Vector2(1360, 760), Vector2(1510, 795), Vector2(1660, 830), Vector2(1800, 860)]
const POND_PATH: Array[Vector2] = [Vector2(720, 1080), Vector2(690, 1130), Vector2(665, 1200), Vector2(650, 1270)]
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
	tile_set.tile_size = Vector2i(TERRAIN_TILE_SIZE, TERRAIN_TILE_SIZE)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load("res://assets/processed/environment/ground_tilesheet_atlas.png")
	atlas.texture_region_size = Vector2i(TERRAIN_TILE_SIZE, TERRAIN_TILE_SIZE)
	for row in range(TERRAIN_ATLAS_ROWS):
		for column in range(TERRAIN_ATLAS_COLUMNS):
			atlas.create_tile(Vector2i(column, row))
	tile_set.add_source(atlas, 0)
	terrain_layer.tile_set = tile_set
	terrain_layer.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 45831
	var tile_columns := ceili(WORLD_SIZE.x / TERRAIN_TILE_SIZE)
	var tile_rows := ceili(WORLD_SIZE.y / TERRAIN_TILE_SIZE)
	for y in range(tile_rows):
		for x in range(tile_columns):
			var center := Vector2((float(x) + 0.5) * TERRAIN_TILE_SIZE, (float(y) + 0.5) * TERRAIN_TILE_SIZE)
			var atlas_coordinate := _ground_tile_for_cell(x, y, center, rng)
			terrain_layer.set_cell(Vector2i(x, y), 0, atlas_coordinate)

func _ground_tile_for_cell(cell_x: int, cell_y: int, center: Vector2, rng: RandomNumberGenerator) -> Vector2i:
	var river_path_tile := _get_path_tile(center, RIVER_PATH, Vector2i(0, 2), 0)
	if river_path_tile.x >= 0:
		return river_path_tile
	var pond_path_tile := _get_path_tile(center, POND_PATH, Vector2i(0, 4), 6)
	if pond_path_tile.x >= 0:
		return pond_path_tile
	var sector := Vector2i(floori(float(cell_x) / 8.0), floori(float(cell_y) / 8.0))
	var palette := absi(sector.x * 37 + sector.y * 19 + 11) % 10
	if palette <= 5:
		var grass := [0, 3, 5, 6, 7, 8]
		return Vector2i(grass[rng.randi_range(0, grass.size() - 1)], 0)
	if palette <= 7:
		var flowers := [1, 2]
		return Vector2i(flowers[rng.randi_range(0, flowers.size() - 1)], 0)
	if palette == 8:
		var clover := [4, 5, 6, 7, 8]
		return Vector2i(clover[rng.randi_range(0, clover.size() - 1)], 1)
	var undergrowth := [9, 10, 11]
	return Vector2i(undergrowth[rng.randi_range(0, undergrowth.size() - 1)], 1)

func _get_path_tile(point: Vector2, points: Array[Vector2], ground_tile: Vector2i, transition_column: int) -> Vector2i:
	var closest_point := points[0]
	var closest_distance := INF
	for index in range(points.size() - 1):
		var start := points[index]
		var segment := points[index + 1] - start
		var projection := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
		var candidate := start + segment * projection
		var distance := point.distance_to(candidate)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = candidate
	if closest_distance <= TERRAIN_TILE_SIZE * 0.5:
		return ground_tile
	if closest_distance <= TERRAIN_TILE_SIZE * 1.5:
		var outward := point - closest_point
		var rotation := 0
		if absf(outward.x) > absf(outward.y):
			rotation = 1 if outward.x > 0.0 else 3
		elif outward.y > 0.0:
			rotation = 2
		return Vector2i(transition_column, 5 + rotation)
	return Vector2i(-1, -1)

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
