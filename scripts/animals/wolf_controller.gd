extends CharacterBody2D
class_name WolfController

@export var move_speed: float = 76.0
@export var attack_distance: float = 28.0
@export var bite_damage: float = 18.0
@export var bite_interval: float = 1.4
@export var max_health: float = 120.0

var health: float = 120.0
var _environment: DayNightController
var _target: WanderingAnimal
var _attack_timer := 0.0
var _wander_timer := 0.0
var _wander_target := Vector2.ZERO
@onready var sprite: AnimalSpriteAnimator = $Sprite

func _ready() -> void:
	health = max_health
	add_to_group("wolves")
	_environment = get_tree().get_first_node_in_group("environment") as DayNightController
	if _environment != null:
		_environment.day_night_changed.connect(_on_day_night_changed)
	_sync_night()

func _on_day_night_changed(_night: bool) -> void:
	_sync_night()

func _sync_night() -> void:
	var active := _environment != null and _environment.is_night
	visible = active
	set_physics_process(active)
	collision_layer = 8 if active else 0
	if not active:
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_attack_timer = maxf(0.0, _attack_timer - delta)
	if _target == null or not is_instance_valid(_target) or not _target.is_resting:
		_target = _find_resting_deer()
	if _target != null:
		var offset := _target.global_position - global_position
		if offset.length() <= attack_distance:
			velocity = Vector2.ZERO
			if _attack_timer <= 0.0:
				_target.take_damage(bite_damage)
				_attack_timer = bite_interval
		else:
			velocity = offset.normalized() * move_speed
	else:
		_wander_timer -= delta
		if _wander_timer <= 0.0:
			var rng := RandomNumberGenerator.new()
			rng.randomize()
			_wander_target = global_position + Vector2(rng.randf_range(-120.0, 120.0), rng.randf_range(-120.0, 120.0))
			_wander_timer = rng.randf_range(2.0, 5.0)
		velocity = (_wander_target - global_position).normalized() * move_speed * 0.45
	move_and_slide()
	sprite.set_pose(velocity.normalized(), false)

func _find_resting_deer() -> WanderingAnimal:
	var closest: WanderingAnimal
	var closest_distance := INF
	for candidate in get_tree().get_nodes_in_group("deer"):
		if candidate is WanderingAnimal and candidate.is_resting:
			var distance := global_position.distance_squared_to(candidate.global_position)
			if distance < closest_distance:
				closest = candidate
				closest_distance = distance
	return closest

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	queue_redraw()
	if health <= 0.0:
		queue_free()

func _draw() -> void:
	if health < max_health:
		draw_rect(Rect2(-15, -31, 30, 4), Color("292621"))
		draw_rect(Rect2(-14, -30, 28.0 * health / max_health, 2), Color("b94d3e"))
