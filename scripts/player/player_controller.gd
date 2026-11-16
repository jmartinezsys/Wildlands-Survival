extends CharacterBody2D
class_name PlayerController

@export var walk_speed: float = 180.0
@export var run_speed: float = 285.0

@onready var character_visual: Node2D = $CharacterVisual

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running := Input.is_action_pressed("run") and input_direction.length_squared() > 0.0
	var movement_speed := run_speed if is_running else walk_speed
	velocity = input_direction * movement_speed
	move_and_slide()
	if input_direction.length_squared() > 0.0:
		character_visual.rotation = input_direction.angle() + PI / 2.0
