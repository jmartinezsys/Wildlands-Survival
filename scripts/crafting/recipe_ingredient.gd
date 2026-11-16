extends Resource
class_name RecipeIngredient

@export var item_id: StringName
@export_range(1, 999, 1) var amount: int = 1
