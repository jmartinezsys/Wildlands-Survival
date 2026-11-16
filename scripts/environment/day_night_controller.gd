extends CanvasModulate
class_name DayNightController

signal time_changed(hour: float)
signal weather_changed(weather_name: String)

@export_range(120.0, 3600.0) var day_length_seconds: float = 900.0
@export_range(0.0, 24.0) var start_hour: float = 8.0

var time_of_day: float = 8.0
var weather_name := "Despejado"
var wind_strength := 0.0
var _weather_timer := 90.0
var _signal_timer := 0.0

func _ready() -> void:
	time_of_day = start_hour
	add_to_group("environment")

func _process(delta: float) -> void:
	time_of_day = fposmod(time_of_day + 24.0 * delta / day_length_seconds, 24.0)
	var daylight := clampf((sin((time_of_day - 6.0) * TAU / 24.0) + 0.18) / 1.18, 0.0, 1.0)
	var night_color := Color("53617e")
	var day_color := Color("ffffff")
	var target := night_color.lerp(day_color, daylight)
	if weather_name == "Lluvia":
		target = target.lerp(Color("87939c"), 0.3)
	elif weather_name == "Niebla":
		target = target.lerp(Color("d1d4c9"), 0.22)
	color = color.lerp(target, delta * 0.7)
	_weather_timer -= delta
	if _weather_timer <= 0.0:
		_roll_weather()
	_signal_timer += delta
	if _signal_timer >= 1.0:
		_signal_timer = 0.0
		time_changed.emit(time_of_day)

func _roll_weather() -> void:
	var choices := ["Despejado", "Lluvia", "Niebla", "Viento"]
	weather_name = choices[randi() % choices.size()]
	wind_strength = 0.0 if weather_name != "Viento" else randf_range(0.4, 1.0)
	_weather_timer = randf_range(90.0, 180.0)
	weather_changed.emit(weather_name)
