extends Area2D
class_name ResourceNode

signal resource_consumed(resource_key: StringName)

@export var definition: ItemDefinition
@export_range(1, 20, 1) var amount: int = 1
@export var interaction_name: String = "Recolectar"
@export var resource_key: StringName
@export var required_tool_id: StringName = &""
@export_range(0.1, 8.0, 0.1) var interaction_duration: float = 0.55
@export_range(1, 8, 1) var hits_required: int = 1

var _hits_done := 0

func get_interaction_label() -> String:
	var action := interaction_name
	if required_tool_id == &"stone_axe":
		action = "Talar"
	elif required_tool_id == &"pickaxe":
		action = "Picar"
	if definition == null:
		return _tool_requirement(action)
	return _tool_requirement("%s %s" % [action, definition.display_name.to_lower()])

func _tool_requirement(label: String) -> String:
	if required_tool_id.is_empty():
		return label
	var tool_name := "hacha" if required_tool_id == &"stone_axe" else "pico"
	return "%s (requiere %s)" % [label, tool_name]

func interact(inventory: InventoryComponent) -> bool:
	if inventory == null or definition == null:
		return false
	if not required_tool_id.is_empty() and inventory.get_count(required_tool_id) <= 0:
		return false
	_hits_done += 1
	if _hits_done < hits_required:
		return false
	if not inventory.add_item(definition, amount):
		_hits_done -= 1
		return false
	resource_consumed.emit(resource_key)
	queue_free()
	return true

func _draw() -> void:
	if interaction_name == "Talar":
		draw_rect(Rect2(-8, -13, 16, 26), Color("765239"))
		draw_circle(Vector2(0, -14), 13.0, Color("58734a"))
		draw_circle(Vector2(-9, -18), 8.0, Color("668451"))
	elif interaction_name == "Picar":
		draw_colored_polygon(PackedVector2Array([Vector2(-15, 6), Vector2(-10, -8), Vector2(3, -14), Vector2(14, -8), Vector2(16, 5), Vector2(2, 11)]), Color("77786e"))
		draw_line(Vector2(-5, -5), Vector2(5, -10), Color("aaa99a"), 2.0, true)
	elif definition != null and definition.item_id == &"water_flask":
		draw_rect(Rect2(-5, -9, 10, 18), Color("8db9bf"))
		draw_rect(Rect2(-3, -12, 6, 4), Color("e1dcc5"))
		draw_line(Vector2(-3, -4), Vector2(3, -4), Color("c2e0de"), 2.0, true)
	elif definition != null and definition.item_id == &"stone":
		draw_colored_polygon(PackedVector2Array([Vector2(-10, 5), Vector2(-7, -5), Vector2(2, -9), Vector2(10, -2), Vector2(8, 6), Vector2(-1, 9)]), Color("858778"))
		draw_line(Vector2(-4, -3), Vector2(2, -6), Color("b2b3a0"), 2.0, true)
	else:
		draw_line(Vector2(-11, 5), Vector2(10, -5), Color("856843"), 4.0, true)
		draw_line(Vector2(-7, 8), Vector2(7, 0), Color("a18153"), 2.0, true)
	if definition != null and definition.item_id == &"berries":
		draw_circle(Vector2(-5, 0), 4.0, Color("8e3f55"))
		draw_circle(Vector2(3, -4), 4.0, Color("b14a5d"))
		draw_circle(Vector2(5, 4), 3.0, Color("6f344c"))
		draw_line(Vector2(-8, 7), Vector2(9, -8), Color("60754a"), 2.0, true)
