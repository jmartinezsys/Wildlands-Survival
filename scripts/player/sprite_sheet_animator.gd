extends AnimatedSprite2D

const SOURCE_TEXTURE: Texture2D = preload("res://assets/processed/characters/player_spritesheet_transparent.png")
const FRAME_WIDTH := 102
const FRAME_HEIGHT := 128
const FRAME_COUNT := 10
var _swim_time := 0.0
const ANIMATION_ROWS := {
	&"south": 0,
	&"north": 1,
	&"east": 2,
	&"west": 3,
	&"south_east": 4,
	&"south_west": 5,
	&"north_east": 6,
	&"north_west": 7
}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite_frames = SpriteFrames.new()
	for animation_name in ANIMATION_ROWS:
		sprite_frames.add_animation(String(animation_name))
		sprite_frames.set_animation_speed(String(animation_name), 9.0)
		sprite_frames.set_animation_loop(String(animation_name), true)
		var row: int = ANIMATION_ROWS[animation_name]
		for column in range(FRAME_COUNT):
			var atlas_frame := AtlasTexture.new()
			atlas_frame.atlas = SOURCE_TEXTURE
			atlas_frame.region = Rect2i(column * FRAME_WIDTH, row * FRAME_HEIGHT, FRAME_WIDTH, FRAME_HEIGHT)
			sprite_frames.add_frame(String(animation_name), atlas_frame)
	animation = "south"
	stop()

func set_movement(direction: Vector2, is_running: bool, is_swimming: bool) -> void:
	if is_swimming:
		_swim_time += get_process_delta_time()
		position.y = -2.0 + sin(_swim_time * 4.0) * 1.5
	else:
		position.y = 0.0
	if direction.length_squared() <= 0.0:
		if is_playing():
			stop()
		frame = 0
		return
	var selected_animation := _get_direction_animation(direction)
	if animation != selected_animation or not is_playing():
		play(selected_animation)
	speed_scale = 0.68 if is_swimming else (1.35 if is_running else 1.0)

func _get_direction_animation(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y) * 2.4:
		return &"east" if direction.x > 0.0 else &"west"
	if absf(direction.y) > absf(direction.x) * 2.4:
		return &"south" if direction.y > 0.0 else &"north"
	if direction.y > 0.0:
		return &"south_east" if direction.x > 0.0 else &"south_west"
	return &"north_east" if direction.x > 0.0 else &"north_west"
