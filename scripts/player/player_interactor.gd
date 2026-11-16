extends Area2D
class_name PlayerInteractor

signal interaction_prompt_changed(text: String)
signal resource_collected(text: String)

@onready var inventory: InventoryComponent = get_node("../InventoryComponent")
var _current_target: Area2D
var _action_target: Area2D
var _action_timer := 0.0
var _action_duration := 0.0

func _process(delta: float) -> void:
	_update_target()
	if _action_target != null:
		if not is_instance_valid(_action_target) or _action_target != _current_target:
			_cancel_action()
			return
		_action_timer += delta
		var progress := clampf(_action_timer / maxf(_action_duration, 0.01), 0.0, 1.0)
		interaction_prompt_changed.emit("E — %s  %d%%" % [_get_label(_action_target), roundi(progress * 100.0)])
		if _action_timer >= _action_duration:
			_finish_action()
		return
	if _current_target != null and Input.is_action_just_pressed("interact"):
		_begin_action()

func _update_target() -> void:
	var closest: Area2D
	var closest_distance := INF
	for area in get_overlapping_areas():
		if not (area is ResourceNode or area.has_method("start_sleep")):
			continue
		var candidate := area as Area2D
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	_set_target(closest)

func _begin_action() -> void:
	if _current_target is ResourceNode:
		var resource := _current_target as ResourceNode
		if not resource.required_tool_id.is_empty() and inventory.get_count(resource.required_tool_id) <= 0:
			resource_collected.emit("Necesitas %s para esta acción." % _tool_name(resource.required_tool_id))
			return
	_action_target = _current_target
	var duration: Variant = _current_target.get("interaction_duration")
	_action_duration = float(duration) if duration != null else 0.6
	_action_timer = 0.0
	var player := get_parent() as PlayerController
	if player != null:
		player.begin_interaction_action(_action_duration)
	if _action_duration <= 0.0:
		_finish_action()

func _finish_action() -> void:
	var target := _action_target
	_action_target = null
	_action_timer = 0.0
	var player := get_parent() as PlayerController
	if player != null:
		player.end_interaction_action()
	if not is_instance_valid(target):
		return
	if target is ResourceNode:
		var resource := target as ResourceNode
		var name := resource.definition.display_name if resource.definition != null else "recurso"
		if resource.interact(inventory):
			resource_collected.emit("Recolectaste %s x%d" % [name, resource.amount])
			_set_target(null)
		elif is_instance_valid(resource) and resource._hits_done < resource.hits_required:
			resource_collected.emit("Golpe aplicado. Repite para terminar.")
		else:
			resource_collected.emit("No hay espacio en la mochila.")
	elif target.has_method("start_sleep"):
		target.call("start_sleep", get_parent())

func _cancel_action() -> void:
	_action_target = null
	_action_timer = 0.0
	var player := get_parent() as PlayerController
	if player != null:
		player.end_interaction_action()
	interaction_prompt_changed.emit("E — " + _get_label(_current_target) if _current_target != null else "")

func _set_target(target: Area2D) -> void:
	if _current_target == target:
		return
	if _action_target != null:
		_cancel_action()
	_current_target = target
	var label := _get_label(target)
	interaction_prompt_changed.emit("E — " + label if not label.is_empty() else "")

func _get_label(target: Area2D) -> String:
	if target == null:
		return ""
	if target is ResourceNode:
		return (target as ResourceNode).get_interaction_label()
	if target.has_method("get_interaction_label"):
		return str(target.call("get_interaction_label"))
	return "Interactuar"

func _tool_name(tool_id: StringName) -> String:
	match tool_id:
		&"stone_axe": return "un hacha"
		&"pickaxe": return "un pico"
		_: return "la herramienta adecuada"
