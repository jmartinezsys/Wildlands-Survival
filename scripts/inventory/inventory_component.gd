extends Node
class_name InventoryComponent

signal inventory_changed
signal item_added(item_id: StringName, amount: int, total: int)

@export_range(1, 100, 1) var slot_capacity: int = 24
var _items: Dictionary[StringName, int] = {}
var _definitions: Dictionary[StringName, ItemDefinition] = {}

func _ready() -> void:
	add_item(preload("res://resources/items/knife.tres"), 1)

func add_item(definition: ItemDefinition, amount: int) -> bool:
	if definition == null or amount <= 0 or definition.item_id.is_empty():
		return false
	if not can_add_item(definition, amount):
		return false
	var current_amount := get_count(definition.item_id)
	_items[definition.item_id] = current_amount + amount
	_definitions[definition.item_id] = definition
	item_added.emit(definition.item_id, amount, _items[definition.item_id])
	inventory_changed.emit()
	return true

func can_add_item(definition: ItemDefinition, amount: int) -> bool:
	if definition == null or amount <= 0 or definition.item_id.is_empty():
		return false
	var current_amount := get_count(definition.item_id)
	if current_amount + amount > definition.max_stack:
		return false
	return current_amount > 0 or _items.size() < slot_capacity

func remove_item(item_id: StringName, amount: int) -> bool:
	if amount <= 0 or get_count(item_id) < amount:
		return false
	var remaining := get_count(item_id) - amount
	if remaining == 0:
		_items.erase(item_id)
		_definitions.erase(item_id)
	else:
		_items[item_id] = remaining
	inventory_changed.emit()
	return true

func get_count(item_id: StringName) -> int:
	return _items.get(item_id, 0)

func get_items_snapshot() -> Dictionary[StringName, int]:
	return _items.duplicate()

func get_definition(item_id: StringName) -> ItemDefinition:
	return _definitions.get(item_id)

func get_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item_id in _items:
		entries.append({"definition": _definitions[item_id], "count": _items[item_id]})
	return entries

func restore_items(saved_items: Dictionary) -> bool:
	var definitions: Dictionary[StringName, ItemDefinition] = {
		&"knife": preload("res://resources/items/knife.tres"),
		&"pickaxe": preload("res://resources/items/pickaxe.tres"),
		&"branch": preload("res://resources/items/branch.tres"),
		&"stone": preload("res://resources/items/stone.tres"),
		&"stone_axe": preload("res://resources/items/stone_axe.tres"),
		&"campfire_kit": preload("res://resources/items/campfire_kit.tres"),
		&"shelter_kit": preload("res://resources/items/shelter_kit.tres"),
		&"storage_kit": preload("res://resources/items/storage_kit.tres"),
		&"workbench_kit": preload("res://resources/items/workbench_kit.tres"),
		&"berries": preload("res://resources/items/berries.tres"),
		&"water_flask": preload("res://resources/items/water_flask.tres")
	}
	var restored: Dictionary[StringName, int] = {}
	var restored_definitions: Dictionary[StringName, ItemDefinition] = {}
	for key in saved_items:
		var item_id := StringName(str(key))
		var amount := int(saved_items[key])
		if not definitions.has(item_id) or amount <= 0:
			return false
		var definition: ItemDefinition = definitions[item_id]
		if amount > definition.max_stack:
			return false
		restored[item_id] = amount
		restored_definitions[item_id] = definition
	if restored.size() > slot_capacity:
		return false
	_items = restored
	_definitions = restored_definitions
	inventory_changed.emit()
	return true
