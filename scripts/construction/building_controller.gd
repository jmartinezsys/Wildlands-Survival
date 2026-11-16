extends Node2D
class_name BuildingController

signal status_message(text: String)

const BLUEPRINTS := {
	&"campfire_kit": {"name": "Fogata", "scene": "res://scenes/structures/Campfire.tscn"},
	&"shelter_kit": {"name": "Refugio", "scene": "res://scenes/structures/Shelter.tscn"},
	&"storage_kit": {"name": "Almacenamiento", "scene": "res://scenes/structures/StorageChest.tscn"},
	&"workbench_kit": {"name": "Mesa de fabricación", "scene": "res://scenes/structures/CraftingTable.tscn"}
}

@onready var player: PlayerController = get_node("../Player")
@onready var world: Node2D = get_node("../World")
var _build_mode := false
var _preview_position := Vector2.ZERO
var _placement_shape := CircleShape2D.new()
var _selected_kit: StringName

func _process(_delta: float) -> void:
	if not _build_mode:
		return
	_preview_position = get_global_mouse_position()
	queue_redraw()
	if Input.is_action_just_pressed("place_structure"):
		_place_structure()

func is_build_mode() -> bool:
	return _build_mode

func cancel_build() -> void:
	_build_mode = false
	status_message.emit("Construcción cancelada.")

func begin_next_blueprint() -> void:
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	for kit_id in BLUEPRINTS:
		if inventory.get_count(kit_id) > 0:
			_selected_kit = kit_id
			_build_mode = true
			status_message.emit("%s: apunta a un lugar libre y haz clic. Esc cancela." % BLUEPRINTS[kit_id]["name"])
			return
	status_message.emit("Fabrica primero un kit de construcción.")

func begin_blueprint(kit_id: StringName) -> void:
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	if not BLUEPRINTS.has(kit_id) or inventory.get_count(kit_id) < 1:
		status_message.emit("No tienes ese kit de construcción.")
		return
	_selected_kit = kit_id
	_build_mode = true
	status_message.emit("%s: apunta a un lugar libre y haz clic. Esc cancela." % BLUEPRINTS[kit_id]["name"])

func _place_structure() -> void:
	if not _is_placement_valid():
		status_message.emit("No puedes construir en ese lugar.")
		return
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	if not inventory.remove_item(_selected_kit, 1):
		_build_mode = false
		status_message.emit("Ya no tienes el kit seleccionado.")
		return
	var blueprint: Dictionary = BLUEPRINTS[_selected_kit]
	var structure := (load(blueprint["scene"]) as PackedScene).instantiate() as Node2D
	structure.add_to_group("persistent_structure")
	world.add_child(structure)
	structure.global_position = _preview_position
	_build_mode = false
	status_message.emit("%s construido." % blueprint["name"])

func _is_placement_valid() -> bool:
	_placement_shape.radius = 30.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _placement_shape
	query.transform = Transform2D(0.0, _preview_position)
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _draw() -> void:
	if not _build_mode:
		return
	var tint := Color(0.2, 0.9, 0.35, 0.48) if _is_placement_valid() else Color(0.9, 0.2, 0.15, 0.48)
	draw_circle(to_local(_preview_position), 24.0, tint)
	draw_arc(to_local(_preview_position), 30.0, 0.0, TAU, 48, tint, 3.0, true)
