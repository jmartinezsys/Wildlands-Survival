extends CanvasLayer
class_name GameHUD

@onready var prompt_label: Label = $Margin/Content/Prompt
@onready var notice_label: Label = $Margin/Content/Notice
@onready var notice_timer: Timer = $NoticeTimer
@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var craft_panel: PanelContainer = $CraftPanel
@onready var recipe_list: VBoxContainer = $CraftPanel/Content/Recipes
@onready var inventory_list: ItemList = $InventoryPanel/Content/InventoryList
@onready var description_label: Label = $InventoryPanel/Content/Description
@onready var health_bar: ProgressBar = $StatsPanel/Stats/Health
@onready var hunger_bar: ProgressBar = $StatsPanel/Stats/Hunger
@onready var thirst_bar: ProgressBar = $StatsPanel/Stats/Thirst
@onready var energy_bar: ProgressBar = $StatsPanel/Stats/Energy
@onready var temperature_label: Label = $StatsPanel/Stats/Temperature
@onready var clock_label: Label = $StatsPanel/Stats/Clock
@onready var weather_label: Label = $StatsPanel/Stats/Weather
@onready var weather_overlay: WeatherOverlay = $WeatherOverlay
var _player: PlayerController
var _inventory: InventoryComponent
var _crafting: CraftingComponent
var _selected_item_id: StringName

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var building := get_parent().get_node("BuildingController") as BuildingController
		if building.is_build_mode():
			building.cancel_build()
			get_viewport().set_input_as_handled()
			return
		get_tree().paused = not get_tree().paused
		show_notification("Pausa" if get_tree().paused else "Partida reanudada")
		get_viewport().set_input_as_handled()

func bind_player(player: PlayerController) -> void:
	_player = player
	_inventory = player.get_node("InventoryComponent")
	_crafting = player.get_node("CraftingComponent")
	_inventory.inventory_changed.connect(_refresh_inventory)
	player.get_node("SurvivalStats").stats_changed.connect(_refresh_stats)
	_refresh_inventory()
	_refresh_stats()
	_build_recipe_buttons()

func bind_environment(environment: DayNightController) -> void:
	environment.time_changed.connect(_on_time_changed)
	environment.weather_changed.connect(_on_weather_changed)
	weather_overlay.bind_environment(environment)
	_on_time_changed(environment.time_of_day)
	_on_weather_changed(environment.weather_name)

func _on_time_changed(hour: float) -> void:
	var hour_value := floori(hour)
	var minute_value := floori((hour - hour_value) * 60.0)
	clock_label.text = "%02d:%02d" % [hour_value, minute_value]

func _on_weather_changed(weather_name: String) -> void:
	weather_label.text = weather_name

func toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		_refresh_inventory()

func toggle_crafting() -> void:
	craft_panel.visible = not craft_panel.visible

func _build_recipe_buttons() -> void:
	for recipe_path in ["res://resources/recipes/stone_axe.tres", "res://resources/recipes/pickaxe.tres", "res://resources/recipes/campfire_kit.tres", "res://resources/recipes/shelter_kit.tres", "res://resources/recipes/storage_kit.tres", "res://resources/recipes/workbench_kit.tres"]:
		var recipe := load(recipe_path) as CraftingRecipe
		if recipe == null:
			continue
		var button := Button.new()
		button.text = recipe.display_name
		button.pressed.connect(_craft_recipe.bind(recipe))
		recipe_list.add_child(button)

func _craft_recipe(recipe: CraftingRecipe) -> void:
	if _crafting.craft(recipe):
		show_notification("Fabricaste %s." % recipe.display_name)
	else:
		show_notification("Faltan materiales o espacio para fabricar.")

func _refresh_inventory() -> void:
	if _inventory == null:
		return
	inventory_list.clear()
	var entries := _inventory.get_entries()
	for entry in entries:
		var definition: ItemDefinition = entry["definition"]
		var icon: Texture2D = definition.icon
		inventory_list.add_item("%s   × %d" % [definition.display_name, entry["count"]], icon)
		inventory_list.set_item_metadata(inventory_list.item_count - 1, definition.item_id)
	if entries.is_empty():
		_selected_item_id = &""
		description_label.text = "Tu mochila está vacía."
	else:
		inventory_list.select(0)
		_on_item_selected(0)

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= inventory_list.item_count:
		return
	_selected_item_id = inventory_list.get_item_metadata(index)
	var definition := _inventory.get_definition(_selected_item_id)
	description_label.text = definition.description if definition != null else ""

func _on_use_pressed() -> void:
	var definition := _inventory.get_definition(_selected_item_id) if _inventory != null else null
	if definition == null:
		return
	var stats := _player.get_node("SurvivalStats") as SurvivalStats
	match definition.category:
		&"food":
			stats.restore_hunger(25.0)
		&"water":
			stats.restore_thirst(30.0)
		_:
			show_notification("Este objeto no se puede usar todavía.")
			return
	_inventory.remove_item(_selected_item_id, 1)
	show_notification("Usaste %s" % definition.display_name)

func _on_drop_pressed() -> void:
	if _inventory != null and not _selected_item_id.is_empty():
		_inventory.remove_item(_selected_item_id, 1)
		show_notification("Objeto eliminado del inventario.")

func _refresh_stats() -> void:
	if _player == null:
		return
	var stats := _player.get_node("SurvivalStats") as SurvivalStats
	health_bar.value = stats.health
	hunger_bar.value = stats.hunger
	thirst_bar.value = stats.thirst
	energy_bar.value = stats.energy
	temperature_label.text = "Temperatura  %.1f °C" % stats.body_temperature

func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()

func show_notification(text: String) -> void:
	notice_label.text = text
	notice_label.visible = true
	notice_timer.start()

func _on_notice_timer_timeout() -> void:
	notice_label.visible = false
