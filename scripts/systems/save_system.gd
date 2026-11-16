extends Node
class_name SaveSystem

const SAVE_PATH := "user://wildlands_save.json"
const SAVE_VERSION := 1
const STRUCTURE_PATHS := ["res://scenes/structures/Campfire.tscn", "res://scenes/structures/Shelter.tscn", "res://scenes/structures/StorageChest.tscn", "res://scenes/structures/CraftingTable.tscn"]

func save_game(player: PlayerController, environment: DayNightController, chunks: WorldChunkStreamer, world: Node2D) -> bool:
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	var stats := player.get_node("SurvivalStats") as SurvivalStats
	var saved_inventory: Dictionary = {}
	for item_id in inventory.get_items_snapshot():
		saved_inventory[String(item_id)] = inventory.get_count(item_id)
	var structure_data: Array[Dictionary] = []
	for node in world.get_tree().get_nodes_in_group("persistent_structure"):
		if not node is Node2D:
			continue
		var scene_path := node.scene_file_path
		if scene_path.is_empty() and node.name == "Campfire":
			scene_path = "res://scenes/structures/Campfire.tscn"
		elif scene_path.is_empty() and node.name == "Shelter":
			scene_path = "res://scenes/structures/Shelter.tscn"
		elif scene_path.is_empty() and node.name == "StorageChest":
			scene_path = "res://scenes/structures/StorageChest.tscn"
		elif scene_path.is_empty() and node.name == "CraftingTable":
			scene_path = "res://scenes/structures/CraftingTable.tscn"
		if STRUCTURE_PATHS.has(scene_path):
			structure_data.append({"scene": scene_path, "x": node.global_position.x, "y": node.global_position.y})
	var payload := {
		"version": SAVE_VERSION,
		"player": {"x": player.global_position.x, "y": player.global_position.y},
		"stats": stats.get_save_data(),
		"inventory": saved_inventory,
		"environment": {"time_of_day": environment.time_of_day, "weather": environment.weather_name},
		"collected_resources": chunks.get_collected_keys(),
		"structures": structure_data
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo de guardado: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return file.get_error() == OK

func load_game(player: PlayerController, environment: DayNightController, chunks: WorldChunkStreamer, world: Node2D) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or parsed.get("version", -1) != SAVE_VERSION:
		return false
	var data: Dictionary = parsed
	var player_data: Variant = data.get("player")
	var stats_data: Variant = data.get("stats")
	var inventory_data: Variant = data.get("inventory")
	var environment_data: Variant = data.get("environment")
	if not player_data is Dictionary or not stats_data is Dictionary or not inventory_data is Dictionary or not environment_data is Dictionary:
		return false
	if not player_data.has("x") or not player_data.has("y"):
		return false
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	var stats := player.get_node("SurvivalStats") as SurvivalStats
	if not inventory.restore_items(inventory_data) or not stats.restore_save_data(stats_data):
		return false
	player.global_position = Vector2(float(player_data["x"]), float(player_data["y"]))
	environment.time_of_day = fposmod(float(environment_data.get("time_of_day", 8.0)), 24.0)
	var saved_weather: String = str(environment_data.get("weather", "Despejado"))
	if saved_weather in ["Despejado", "Lluvia", "Niebla", "Viento"]:
		environment.weather_name = saved_weather
	chunks.restore_collected_keys(data.get("collected_resources", []))
	_restore_structures(data.get("structures", []), world)
	return true

func _restore_structures(saved_structures: Variant, world: Node2D) -> void:
	if not saved_structures is Array:
		return
	for node in world.get_tree().get_nodes_in_group("persistent_structure"):
		node.queue_free()
	for structure_data in saved_structures:
		if not structure_data is Dictionary:
			continue
		var scene_path: String = str(structure_data.get("scene", ""))
		if not STRUCTURE_PATHS.has(scene_path) or not structure_data.has("x") or not structure_data.has("y"):
			continue
		var structure := (load(scene_path) as PackedScene).instantiate() as Node2D
		structure.add_to_group("persistent_structure")
		world.add_child(structure)
		structure.global_position = Vector2(float(structure_data["x"]), float(structure_data["y"]))
