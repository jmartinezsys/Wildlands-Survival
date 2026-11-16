extends CharacterBody2D
class_name WanderingAnimal

@export var walk_speed: float = 48.0
@export var flee_speed: float = 125.0
@export var flee_distance: float = 190.0

var _player: Node2D
var _environment: DayNightController
var _target := Vector2.ZERO
var _wander_timer := 0.0

func set_player(player: Node2D) -> void:
	_player = player

func _ready() -> void:
	_environment = get_tree().get_first_node_in_group("environment") as DayNightController
	_pick_wander_target()

func _physics_process(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_wander_target()
	var direction := (_target - global_position).normalized()
	var speed := walk_speed
	if _environment != null and _environment.weather_name == "Viento":
		direction = (direction + Vector2(_environment.wind_strength * 0.22, 0.0)).normalized()
	if _player != null:
		var distance := global_position.distance_to(_player.global_position)
		if distance < flee_distance:
			direction = (global_position - _player.global_position).normalized()
			speed = flee_speed
			_target = global_position + direction * flee_distance
	velocity = direction * speed
	move_and_slide()
	queue_redraw()

func _pick_wander_target() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_target = global_position + Vector2(rng.randf_range(-130.0, 130.0), rng.randf_range(-130.0, 130.0))
	_wander_timer = rng.randf_range(2.0, 5.0)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, velocity.angle() + PI / 2.0 if velocity.length_squared() > 0.0 else 0.0, Vector2.ONE)
	draw_circle(Vector2(0, 4), 9.0, Color("4b3928"))
	draw_circle(Vector2(0, -3), 7.0, Color("896644"))
	draw_circle(Vector2(0, -12), 4.5, Color("a98258"))
	draw_line(Vector2(-6, 4), Vector2(-8, 14), Color("55432f"), 2.0, true)
	draw_line(Vector2(6, 4), Vector2(8, 14), Color("55432f"), 2.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
