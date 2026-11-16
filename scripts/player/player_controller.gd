extends CharacterBody2D
class_name PlayerController

signal swimming_changed(is_swimming: bool)
signal sleep_state_changed(is_sleeping: bool)

@export var walk_speed: float = 180.0
@export var run_speed: float = 285.0
@export var swim_speed: float = 92.0

@onready var character_visual: AnimatedSprite2D = $CharacterVisual
var is_swimming := false
var is_sleeping := false
var is_performing_action := false
var _action_tween: Tween

func _ready() -> void:
	for water in get_tree().get_nodes_in_group("swimmable_water"):
		water.body_entered.connect(_on_water_body_entered)
		water.body_exited.connect(_on_water_body_exited)

func _physics_process(_delta: float) -> void:
	if is_sleeping or is_performing_action:
		velocity = Vector2.ZERO
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running := Input.is_action_pressed("run") and input_direction.length_squared() > 0.0 and not is_swimming
	var movement_speed := swim_speed if is_swimming else (run_speed if is_running else walk_speed)
	velocity = input_direction * movement_speed
	move_and_slide()
	character_visual.set_movement(input_direction, is_running, is_swimming)

func begin_sleep() -> void:
	if is_sleeping:
		return
	is_sleeping = true
	character_visual.rotation = -PI * 0.5
	character_visual.scale = Vector2(0.34, 0.34)
	sleep_state_changed.emit(true)

func finish_sleep() -> void:
	if not is_sleeping:
		return
	is_sleeping = false
	character_visual.rotation = 0.0
	character_visual.scale = Vector2(0.48, 0.48)
	sleep_state_changed.emit(false)

func begin_interaction_action(duration: float) -> void:
	is_performing_action = true
	if _action_tween != null and _action_tween.is_running():
		_action_tween.kill()
	_action_tween = create_tween()
	var half_duration := maxf(duration * 0.5, 0.08)
	_action_tween.tween_property(character_visual, "rotation", 0.18, half_duration)
	_action_tween.tween_property(character_visual, "rotation", 0.0, half_duration)
	_action_tween.finished.connect(_reset_action_visual)

func end_interaction_action() -> void:
	is_performing_action = false
	if _action_tween != null and _action_tween.is_running():
		_action_tween.kill()
	_reset_action_visual()

func _reset_action_visual() -> void:
	character_visual.rotation = 0.0

func _on_water_body_entered(body: Node2D) -> void:
	if body == self and not is_swimming:
		is_swimming = true
		swimming_changed.emit(true)

func _on_water_body_exited(body: Node2D) -> void:
	if body == self and is_swimming:
		is_swimming = false
		swimming_changed.emit(false)
