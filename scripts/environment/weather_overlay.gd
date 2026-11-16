extends Node2D
class_name WeatherOverlay

var _weather := "Despejado"
var _elapsed := 0.0

func bind_environment(environment: DayNightController) -> void:
	_weather = environment.weather_name
	environment.weather_changed.connect(_on_weather_changed)

func _process(delta: float) -> void:
	if _weather == "Despejado":
		return
	_elapsed += delta
	queue_redraw()

func _on_weather_changed(weather_name: String) -> void:
	_weather = weather_name
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	if _weather == "Lluvia":
		for index in range(115):
			var x := fposmod(float(index * 131) + _elapsed * 270.0, size.x)
			var y := fposmod(float(index * 79) + _elapsed * 470.0, size.y)
			draw_line(Vector2(x, y), Vector2(x - 8.0, y + 22.0), Color(0.78, 0.86, 0.91, 0.28), 1.0, true)
	elif _weather == "Niebla":
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.82, 0.86, 0.82, 0.16))
	elif _weather == "Viento":
		for index in range(24):
			var x := fposmod(float(index * 97) + _elapsed * 150.0, size.x)
			var y := fposmod(float(index * 53), size.y)
			draw_line(Vector2(x, y), Vector2(x + 18.0, y - 3.0), Color(0.8, 0.83, 0.72, 0.2), 2.0, true)
