extends Area2D
class_name SleepArea

signal sleep_started
signal sleep_finished

@export_range(0.5, 6.0, 0.1) var interaction_duration: float = 1.0
@export_range(1.0, 8.0, 0.1) var sleep_transition_seconds: float = 2.4
var _sleep_in_progress := false

func get_interaction_label() -> String:
	return "Dormir hasta el amanecer"

func start_sleep(player: Node) -> void:
	if _sleep_in_progress or player == null:
		return
	var environment := get_tree().get_first_node_in_group("environment") as DayNightController
	if environment == null:
		return
	_sleep_in_progress = true
	player.begin_sleep()
	sleep_started.emit()
	await get_tree().create_timer(sleep_transition_seconds).timeout
	if is_instance_valid(player):
		environment.sleep_until_day()
		player.finish_sleep()
	_sleep_in_progress = false
	sleep_finished.emit()
