extends Node2D
class_name WorldChunkStreamer

const CHUNK_SIZE := 600.0
const GRID_SIZE := Vector2i(4, 3)
const RESOURCE_SCENE: PackedScene = preload("res://scenes/resources/ResourceNode.tscn")
const BRANCH: ItemDefinition = preload("res://resources/items/branch.tres")
const STONE: ItemDefinition = preload("res://resources/items/stone.tres")
const BERRIES: ItemDefinition = preload("res://resources/items/berries.tres")
const WATER: ItemDefinition = preload("res://resources/items/water_flask.tres")
const DEER_SCENE: PackedScene = preload("res://scenes/animals/Deer.tscn")

var _player: Node2D
var _loaded_chunks: Dictionary[Vector2i, Node2D] = {}
var _collected_keys: Dictionary[StringName, bool] = {}
var _last_center := Vector2i(-99, -99)

func configure(player: Node2D) -> void:
	_player = player
	_update_loaded_chunks()

func _process(_delta: float) -> void:
	if _player == null:
		return
	var center := Vector2i(floori(_player.global_position.x / CHUNK_SIZE), floori(_player.global_position.y / CHUNK_SIZE))
	if center != _last_center:
		_update_loaded_chunks()

func _update_loaded_chunks() -> void:
	if _player == null:
		return
	_last_center = Vector2i(floori(_player.global_position.x / CHUNK_SIZE), floori(_player.global_position.y / CHUNK_SIZE))
	var desired: Dictionary[Vector2i, bool] = {}
	for y in range(_last_center.y - 1, _last_center.y + 2):
		for x in range(_last_center.x - 1, _last_center.x + 2):
			var coord := Vector2i(x, y)
			if x >= 0 and y >= 0 and x < GRID_SIZE.x and y < GRID_SIZE.y:
				desired[coord] = true
				if not _loaded_chunks.has(coord):
					_load_chunk(coord)
	for coord in _loaded_chunks.keys():
		if not desired.has(coord):
			_loaded_chunks[coord].queue_free()
			_loaded_chunks.erase(coord)

func _load_chunk(coord: Vector2i) -> void:
	var chunk := Node2D.new()
	chunk.name = "Chunk_%d_%d" % [coord.x, coord.y]
	chunk.position = Vector2(coord) * CHUNK_SIZE
	add_child(chunk)
	_loaded_chunks[coord] = chunk
	var seed_value := coord.x * 7919 + coord.y * 104729 + 733
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for index in range(3):
		var key := StringName("pickup_%d_%d_%d" % [coord.x, coord.y, index])
		if _collected_keys.has(key):
			continue
		var pickup := RESOURCE_SCENE.instantiate() as ResourceNode
		pickup.definition = BRANCH if index == 0 else (STONE if index == 1 else BERRIES)
		if coord == Vector2i(2, 1):
			pickup.amount = 6 if index == 0 else (4 if index == 1 else 3)
		else:
			pickup.amount = 2 if index == 0 else (1 if index == 1 else 2)
		pickup.resource_key = key
		if coord == Vector2i(2, 1):
			pickup.position = Vector2(60.0, 155.0) if index == 0 else (Vector2(170.0, 215.0) if index == 1 else Vector2(100.0, 260.0))
		else:
			pickup.position = Vector2(rng.randf_range(100.0, 500.0), rng.randf_range(100.0, 500.0))
		if coord == Vector2i(3, 1) and index == 2:
			pickup.definition = WATER
			pickup.amount = 2
		pickup.resource_consumed.connect(_on_resource_consumed)
		chunk.add_child(pickup)
	if coord in [Vector2i(0, 1), Vector2i(3, 1), Vector2i(2, 0)]:
		var deer := DEER_SCENE.instantiate() as WanderingAnimal
		deer.position = Vector2(300.0, 300.0)
		chunk.add_child(deer)
		deer.set_player(_player)

func _on_resource_consumed(resource_key: StringName) -> void:
	_collected_keys[resource_key] = true

func get_collected_keys() -> PackedStringArray:
	var keys := PackedStringArray()
	for key in _collected_keys:
		keys.append(String(key))
	return keys

func restore_collected_keys(keys: Array) -> void:
	_collected_keys.clear()
	for key in keys:
		if key is String:
			_collected_keys[StringName(key)] = true
	for chunk in _loaded_chunks.values():
		chunk.queue_free()
	_loaded_chunks.clear()
	_last_center = Vector2i(-99, -99)
	_update_loaded_chunks()
