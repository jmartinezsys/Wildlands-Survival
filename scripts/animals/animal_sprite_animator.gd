extends AnimatedSprite2D
class_name AnimalSpriteAnimator

@export var movement_sheet: Texture2D
@export var idle_sheet: Texture2D
@export_range(1, 16, 1) var columns: int = 10
@export_range(1, 8, 1) var movement_rows: int = 4
@export var frame_width: int = 102
@export var frame_height: int = 140

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite_frames = SpriteFrames.new()
	_add_sheet("move", movement_sheet, movement_rows, 10.0)
	if idle_sheet != null:
		_add_sheet("idle", idle_sheet, 4, 5.0)

func _add_sheet(prefix: String, texture: Texture2D, rows: int, fps: float) -> void:
	if texture == null:
		return
	for row in range(rows):
		var animation_name := "%s_%d" % [prefix, row]
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_speed(animation_name, fps)
		sprite_frames.set_animation_loop(animation_name, true)
		for column in range(columns):
			var frame := AtlasTexture.new()
			frame.atlas = texture
			frame.region = Rect2i(column * frame_width, row * frame_height, frame_width, frame_height)
			sprite_frames.add_frame(animation_name, frame)
	play("move_0")

func set_pose(direction: Vector2, resting: bool) -> void:
	var row := _direction_row(direction)
	var prefix := "idle" if resting and idle_sheet != null else "move"
	var animation_name := "%s_%d" % [prefix, 2 if resting else row]
	flip_h = direction.x < 0.0 and not resting
	if animation != animation_name or not is_playing():
		play(animation_name)

func _direction_row(direction: Vector2) -> int:
	if direction.length_squared() < 0.01:
		return 0
	if absf(direction.y) > absf(direction.x) * 1.5:
		return 0 if direction.y > 0.0 else 2
	if absf(direction.x) > absf(direction.y) * 1.5:
		return 1
	return 3
