extends Resource
class_name CraftingRecipe

@export var recipe_id: StringName
@export var display_name: String = "Receta"
@export_multiline var description: String = ""
@export var ingredients: Array[RecipeIngredient] = []
@export var result: ItemDefinition
@export_range(1, 999, 1) var result_amount: int = 1
