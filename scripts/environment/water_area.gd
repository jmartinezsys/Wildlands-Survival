extends Area2D
class_name WaterArea

@export_enum("river", "pond") var water_body: String = "river"

const WATER_SHADER: Shader = preload("res://scripts/environment/water_surface.gdshader")

func _ready() -> void:
	add_to_group("swimmable_water")
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	var points := _get_water_polygon()
	var collision := CollisionPolygon2D.new()
	collision.polygon = points
	add_child(collision)
	var shore := Line2D.new()
	shore.points = points
	shore.closed = true
	shore.width = 15.0
	shore.default_color = Color("b9a878")
	shore.antialiased = true
	shore.z_index = -1
	add_child(shore)
	var surface := Polygon2D.new()
	surface.polygon = points
	surface.color = Color.WHITE
	surface.z_index = 0
	var shader_material := ShaderMaterial.new()
	shader_material.shader = WATER_SHADER
	surface.material = shader_material
	add_child(surface)

func _get_water_polygon() -> PackedVector2Array:
	if water_body == "pond":
		var points := PackedVector2Array()
		for index in range(32):
			var angle := TAU * float(index) / 32.0
			points.append(Vector2(430.0 + cos(angle) * 190.0, 1270.0 + sin(angle) * 115.0))
		return points
	return PackedVector2Array([
		Vector2(1900, -80), Vector2(1990, -80), Vector2(2000, 180), Vector2(2075, 420),
		Vector2(2110, 550), Vector2(2075, 650), Vector2(1970, 770), Vector2(1940, 870),
		Vector2(1995, 1010), Vector2(2020, 1090), Vector2(1980, 1170), Vector2(1860, 1280),
		Vector2(1800, 1380), Vector2(1790, 1480), Vector2(1830, 1580), Vector2(1820, 1680),
		Vector2(1710, 1840), Vector2(1620, 1840), Vector2(1700, 1680), Vector2(1730, 1580),
		Vector2(1690, 1480), Vector2(1670, 1370), Vector2(1700, 1270), Vector2(1810, 1160),
		Vector2(1840, 1090), Vector2(1810, 1010), Vector2(1810, 870), Vector2(1860, 760),
		Vector2(1960, 640), Vector2(1970, 550), Vector2(1920, 420), Vector2(1890, 180)
	])
