extends CharacterBody2D
class_name WanderingAnimal

signal died(animal: WanderingAnimal)

@export var walk_speed: float = 48.0
@export var flee_speed: float = 125.0
@export var flee_distance: float = 190.0
@export var max_health: float = 100.0

var health: float = 100.0
var is_resting := false
var _player: Node2D
var _environment: DayNightController
var _target := Vector2.ZERO
var _wander_timer := 0.0
var _rest_timer := 0.0
@onready var sprite: AnimalSpriteAnimator = $Sprite

func set_player(player: Node2D) -> void:
	_player = player

func _ready() -> void:
	health = max_health
	_environment = get_tree().get_first_node_in_group("environment") as DayNightController
	add_to_group("deer")
	_pick_wander_target()

func _physics_process(delta: float) -> void:
	if _player != null and global_position.distance_to(_player.global_position) < flee_distance:
		_start_fleeing_from(_player.global_position)
	for predator in get_tree().get_nodes_in_group("wolves"):
		if predator is Node2D and predator.visible and global_position.distance_to(predator.global_position) < 44.0:
			_start_fleeing_from(predator.global_position)
	if is_resting:
		_rest_timer -= delta
		velocity = Vector2.ZERO
		if _rest_timer <= 0.0:
			is_resting = false
			_pick_wander_target()
		move_and_slide()
		sprite.set_pose(Vector2.ZERO, is_resting)
		return
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_wander_target()
	var direction := (_target - global_position).normalized()
	var speed := walk_speed
	if _player != null and global_position.distance_to(_player.global_position) < flee_distance:
		speed = flee_speed
	if _environment != null and _environment.weather_name == "Viento":
		direction = (direction + Vector2(_environment.wind_strength * 0.22, 0.0)).normalized()
	velocity = direction * speed
	move_and_slide()
	sprite.set_pose(velocity.normalized(), false)

func _start_fleeing_from(source: Vector2) -> void:
	is_resting = false
	_target = global_position + (global_position - source).normalized() * flee_distance
	_wander_timer = 1.5

func _pick_wander_target() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() < 0.32:
		is_resting = true
		_rest_timer = rng.randf_range(4.0, 9.0)
		_wander_timer = _rest_timer
		return
	is_resting = false
	_target = global_position + Vector2(rng.randf_range(-150.0, 150.0), rng.randf_range(-150.0, 150.0))
	_wander_timer = rng.randf_range(3.0, 7.0)

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	queue_redraw()
	is_resting = false
	if _player != null:
		_start_fleeing_from(_player.global_position)
	if health <= 0.0:
		died.emit(self)
		queue_free()

func _draw() -> void:
	if health < max_health:
		draw_rect(Rect2(-14, -30, 28, 4), Color("292621"))
		draw_rect(Rect2(-13, -29, 26.0 * health / max_health, 2), Color("b94d3e"))
