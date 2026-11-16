extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene := load("res://scenes/main/Main.tscn") as PackedScene
	if main_scene == null:
		_fail("No se pudo cargar Main.tscn.")
		return
	var game := main_scene.instantiate()
	root.add_child(game)
	await process_frame
	var player := game.get_node("Player") as PlayerController
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	var crafting := player.get_node("CraftingComponent") as CraftingComponent
	if inventory.get_count(&"knife") != 1:
		_fail("El jugador no recibe el cuchillo inicial.")
		return
	if load("res://scenes/structures/Shelter.tscn") == null:
		_fail("No se pudo cargar la escena de carpa con zona de descanso.")
		return
	var gated_resource := (load("res://scenes/resources/ResourceNode.tscn") as PackedScene).instantiate() as ResourceNode
	gated_resource.definition = load("res://resources/items/branch.tres")
	gated_resource.required_tool_id = &"pickaxe"
	if gated_resource.interact(inventory):
		_fail("Un recurso de minería se recolectó sin pico.")
		return
	gated_resource.free()
	var branch: ItemDefinition = load("res://resources/items/branch.tres")
	var stone: ItemDefinition = load("res://resources/items/stone.tres")
	if not inventory.add_item(branch, 6) or not inventory.add_item(stone, 4):
		_fail("El inventario no acepta materiales válidos.")
		return
	var axe_recipe := load("res://resources/recipes/stone_axe.tres") as CraftingRecipe
	var fire_recipe := load("res://resources/recipes/campfire_kit.tres") as CraftingRecipe
	if not crafting.craft(axe_recipe) or not crafting.craft(fire_recipe):
		_fail("No se pudieron fabricar las recetas con sus materiales.")
		return
	if inventory.get_count(&"stone_axe") != 1 or inventory.get_count(&"campfire_kit") != 1:
		_fail("Los resultados de fabricación no llegaron al inventario.")
		return
	var world := game.get_node("World") as Node2D
	var chunk_streamer := game.get_node("World/ChunkStreamer") as WorldChunkStreamer
	var environment := game.get_node("World/DayNightController") as DayNightController
	var save_system := game.get_node("SaveSystem") as SaveSystem
	var stats := player.get_node("SurvivalStats") as SurvivalStats
	player.global_position = Vector2(1400, 900)
	stats.hunger = 54.0
	stats.thirst = 63.0
	environment.time_of_day = 16.25
	chunk_streamer.restore_collected_keys(["smoke_test_pickup"])
	var campfire := (load("res://scenes/structures/Campfire.tscn") as PackedScene).instantiate() as Node2D
	campfire.add_to_group("persistent_structure")
	world.add_child(campfire)
	campfire.global_position = Vector2(1350, 910)
	if not save_system.save_game(player, environment, chunk_streamer, world):
		_fail("No se pudo guardar el estado de partida.")
		return
	player.global_position = Vector2(100, 100)
	stats.hunger = 1.0
	if not save_system.load_game(player, environment, chunk_streamer, world):
		_fail("No se pudo cargar el estado de partida.")
		return
	if player.global_position.distance_to(Vector2(1400, 900)) > 0.01 or absf(stats.hunger - 54.0) > 0.01:
		_fail("El guardado no restauró posición y necesidades.")
		return
	if inventory.get_count(&"stone_axe") != 1 or inventory.get_count(&"campfire_kit") != 1:
		_fail("El guardado no restauró el inventario.")
		return
	if not chunk_streamer.get_collected_keys().has("smoke_test_pickup"):
		_fail("El guardado no restauró los recursos recolectados.")
		return
	if get_nodes_in_group("persistent_structure").is_empty():
		_fail("El guardado no restauró las estructuras.")
		return
	player.global_position = Vector2(430, 1270)
	for _frame in range(5):
		await physics_frame
	var pond := game.get_node("World/Pond") as WaterArea
	if not player.is_swimming or player.swim_speed >= player.walk_speed:
		_fail("El jugador no activa el nado o su velocidad no disminuye en el río.")
		return
	player.global_position = Vector2(1200, 760)
	await physics_frame
	await physics_frame
	if player.is_swimming:
		_fail("El jugador sigue nadando después de salir del agua.")
		return
	player.global_position = Vector2(1950, 300)
	for _frame in range(5):
		await physics_frame
	var river := game.get_node("World/River") as WaterArea
	if not player.is_swimming:
		_fail("El jugador no detecta el río.")
		return
	var wolves := get_nodes_in_group("wolves")
	if wolves.is_empty():
		_fail("No se generaron lobos en los sectores cargados.")
		return
	environment.set_time_of_day(22.0)
	var active_wolf: WolfController
	for wolf in wolves:
		if wolf is WolfController and wolf.visible:
			active_wolf = wolf
			break
	if active_wolf == null:
		_fail("Los lobos no se activaron durante la noche.")
		return
	var health_before := active_wolf.health
	active_wolf.take_damage(25.0)
	if active_wolf.health >= health_before:
		_fail("El lobo no recibió daño ni redujo su vida.")
		return
	var shelter := (load("res://scenes/structures/Shelter.tscn") as PackedScene).instantiate() as Node2D
	world.add_child(shelter)
	var sleep_area := shelter.get_node("SleepArea") as SleepArea
	sleep_area.start_sleep(player)
	await create_timer(2.7).timeout
	if player.is_sleeping or absf(environment.time_of_day - 7.0) > 0.01:
		_fail("Dormir en la carpa no terminó al amanecer.")
		return
	for wolf in get_nodes_in_group("wolves"):
		if wolf is WolfController and wolf.visible:
			_fail("Los lobos siguen activos durante el día.")
			return
	for water_area in get_nodes_in_group("swimmable_water"):
		water_area.monitoring = false
	print("Prueba de integración aprobada: juego, crafting, guardado/carga, nado, cuchillo inicial, herramientas requeridas, daño, lobos nocturnos y descanso hasta el día.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
