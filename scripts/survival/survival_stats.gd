extends Node
class_name SurvivalStats

signal stats_changed

@export_range(1.0, 100.0) var max_health: float = 100.0
@export_range(1.0, 100.0) var max_hunger: float = 100.0
@export_range(1.0, 100.0) var max_thirst: float = 100.0
@export_range(1.0, 100.0) var max_energy: float = 100.0
@export_range(-20.0, 50.0) var body_temperature: float = 37.0

var health: float = 100.0
var hunger: float = 100.0
var thirst: float = 100.0
var energy: float = 100.0
var _elapsed := 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	var player := get_parent() as CharacterBody2D
	var moving_fast := player != null and player.velocity.length() > 200.0
	hunger = maxf(0.0, hunger - delta * 0.035)
	thirst = maxf(0.0, thirst - delta * 0.07)
	energy = clampf(energy + ( -delta * 0.9 if moving_fast else delta * 1.4), 0.0, max_energy)
	if hunger <= 0.0 or thirst <= 0.0:
		health = maxf(0.0, health - delta * 0.12)
	var environment := get_tree().get_first_node_in_group("environment") as DayNightController
	if environment != null and environment.weather_name in ["Lluvia", "Viento"]:
		body_temperature = maxf(30.0, body_temperature - delta * 0.006)
	else:
		body_temperature = minf(37.0, body_temperature + delta * 0.003)
	if _elapsed >= 0.5:
		_elapsed = 0.0
		stats_changed.emit()

func restore_hunger(amount: float) -> void:
	hunger = clampf(hunger + amount, 0.0, max_hunger)
	stats_changed.emit()

func restore_thirst(amount: float) -> void:
	thirst = clampf(thirst + amount, 0.0, max_thirst)
	stats_changed.emit()

func get_save_data() -> Dictionary:
	return {"health": health, "hunger": hunger, "thirst": thirst, "energy": energy, "body_temperature": body_temperature}

func restore_save_data(data: Dictionary) -> bool:
	for key in ["health", "hunger", "thirst", "energy", "body_temperature"]:
		if not data.has(key) or not data[key] is float and not data[key] is int:
			return false
	health = clampf(float(data["health"]), 0.0, max_health)
	hunger = clampf(float(data["hunger"]), 0.0, max_hunger)
	thirst = clampf(float(data["thirst"]), 0.0, max_thirst)
	energy = clampf(float(data["energy"]), 0.0, max_energy)
	body_temperature = clampf(float(data["body_temperature"]), -20.0, 50.0)
	stats_changed.emit()
	return true
