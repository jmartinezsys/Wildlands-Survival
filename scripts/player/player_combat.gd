extends Node
class_name PlayerCombat

signal attack_result(message: String)

@export var knife_damage: float = 25.0
@export_range(0.2, 2.0, 0.1) var attack_cooldown: float = 0.65
@export_range(20.0, 100.0, 1.0) var attack_range: float = 56.0

var _cooldown := 0.0
@onready var player: PlayerController = get_parent()

func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	if Input.is_action_just_pressed("attack") and not player.is_sleeping:
		_attack()

func _attack() -> void:
	if _cooldown > 0.0:
		return
	var inventory := player.get_node("InventoryComponent") as InventoryComponent
	if inventory.get_count(&"knife") <= 0:
		attack_result.emit("Necesitas un cuchillo para atacar.")
		return
	_cooldown = attack_cooldown
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = attack_range
	query.shape = shape
	query.transform = Transform2D(0.0, player.global_position)
	query.collision_mask = 8
	query.exclude = [player.get_rid()]
	var hits := player.get_world_2d().direct_space_state.intersect_shape(query, 24)
	var target: Node2D
	var nearest := INF
	for hit in hits:
		var collider := hit.get("collider") as Node2D
		if collider == null or not collider.has_method("take_damage"):
			continue
		var distance := player.global_position.distance_squared_to(collider.global_position)
		if distance < nearest:
			nearest = distance
			target = collider
	if target == null:
		attack_result.emit("El cuchillo cortó el aire.")
		return
	target.call("take_damage", knife_damage)
	_play_swing()
	attack_result.emit("Golpeaste al enemigo (%.0f de daño)." % knife_damage)

func _play_swing() -> void:
	var visual := player.get_node("CharacterVisual") as AnimatedSprite2D
	var tween := create_tween()
	visual.rotation = 0.35
	tween.tween_property(visual, "rotation", -0.35, 0.12)
	tween.tween_property(visual, "rotation", 0.0, 0.12)
