extends Area2D
class_name PlayerInteractor

signal interaction_prompt_changed(text: String)
signal resource_collected(text: String)

@onready var inventory: InventoryComponent = get_node("../InventoryComponent")
var _current_target: ResourceNode

func _process(_delta: float) -> void:
	_update_target()
	if _current_target != null and Input.is_action_just_pressed("interact"):
		if _current_target.interact(inventory):
			resource_collected.emit("Recolectaste %s x%d" % [_current_target.definition.display_name, _current_target.amount])
			_set_target(null)

func _update_target() -> void:
	var closest: ResourceNode
	var closest_distance := INF
	for area in get_overlapping_areas():
		if not area is ResourceNode:
			continue
		var candidate := area as ResourceNode
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	_set_target(closest)

func _set_target(target: ResourceNode) -> void:
	if _current_target == target:
		return
	_current_target = target
	var label := "E — " + target.get_interaction_label() if target != null else ""
	interaction_prompt_changed.emit(label)
