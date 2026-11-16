extends Resource
class_name ItemDefinition

@export var item_id: StringName
@export var display_name: String = "Objeto"
@export_multiline var description: String = ""
@export var category: StringName = &"material"
@export_range(1, 999, 1) var max_stack: int = 20
@export var icon: Texture2D
