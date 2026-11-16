extends Area2D
class_name ResourceNode

signal resource_consumed(resource_key: StringName)

@export var definition: ItemDefinition
@export_range(1, 20, 1) var amount: int = 1
@export var interaction_name: String = "Recolectar"
@export var resource_key: StringName

func get_interaction_label() -> String:
	if definition == null:
		return interaction_name
	return "%s %s" % [interaction_name, definition.display_name.to_lower()]

func interact(inventory: InventoryComponent) -> bool:
	if inventory == null or definition == null:
		return false
	if not inventory.add_item(definition, amount):
		return false
	resource_consumed.emit(resource_key)
	queue_free()
	return true

func _draw() -> void:
	if definition != null and definition.item_id == &"water_flask":
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
