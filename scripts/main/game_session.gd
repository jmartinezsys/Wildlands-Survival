extends Node2D

@onready var hud: GameHUD = $GameHUD
@onready var player: PlayerController = $Player
@onready var building: BuildingController = $BuildingController
@onready var chunk_streamer: WorldChunkStreamer = $World/ChunkStreamer
@onready var environment: DayNightController = $World/DayNightController
@onready var save_system: SaveSystem = $SaveSystem

func _ready() -> void:
	hud.bind_player(player)
	chunk_streamer.configure(player)
	hud.bind_environment(environment)
	building.status_message.connect(hud.show_notification)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		hud.toggle_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("craft"):
		hud.toggle_crafting()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build"):
		building.begin_next_blueprint()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("save_game"):
		hud.show_notification("Partida guardada." if save_system.save_game(player, environment, chunk_streamer, $World) else "No se pudo guardar la partida.")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("load_game"):
		var loaded := save_system.load_game(player, environment, chunk_streamer, $World)
		hud.show_notification("Partida cargada." if loaded else "No se encontró una partida válida.")
		get_viewport().set_input_as_handled()
