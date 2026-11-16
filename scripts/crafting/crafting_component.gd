extends Node
class_name CraftingComponent

signal recipe_crafted(recipe_name: String)

@onready var inventory: InventoryComponent = get_node("../InventoryComponent")

func can_craft(recipe: CraftingRecipe) -> bool:
	if recipe == null or recipe.result == null or not inventory.can_add_item(recipe.result, recipe.result_amount):
		return false
	for ingredient in recipe.ingredients:
		if ingredient == null or inventory.get_count(ingredient.item_id) < ingredient.amount:
			return false
	return true

func craft(recipe: CraftingRecipe) -> bool:
	if not can_craft(recipe):
		return false
	for ingredient in recipe.ingredients:
		inventory.remove_item(ingredient.item_id, ingredient.amount)
	if not inventory.add_item(recipe.result, recipe.result_amount):
		push_error("No se pudo entregar el resultado de la receta %s." % recipe.recipe_id)
		return false
	recipe_crafted.emit(recipe.display_name)
	return true
