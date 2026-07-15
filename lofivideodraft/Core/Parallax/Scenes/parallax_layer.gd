@tool
class_name AtmosParallaxLayer
extends Parallax2D


@export_category("Layer Content")

@export var layer_texture: Texture2D:
	set(value):
		layer_texture = value
		_refresh_layer()


@export_category("Movement")

@export_range(0.0, 2000.0, 1.0)
var speed: float = 100.0:
	set(value):
		speed = value
		_refresh_movement()

@export var move_left: bool = true:
	set(value):
		move_left = value
		_refresh_movement()


@export_category("Placement")

@export var layer_position: Vector2 = Vector2.ZERO:
	set(value):
		layer_position = value
		_refresh_layer()

@export_range(1, 5, 1)
var repeat_count: int = 3:
	set(value):
		repeat_count = value
		repeat_times = value


@onready var layer_sprite: Sprite2D = $LayerSprite


func _ready() -> void:
	_refresh_layer()
	_refresh_movement()


func _refresh_layer() -> void:
	if not is_node_ready():
		return

	layer_sprite.texture = layer_texture
	layer_sprite.position = layer_position
	layer_sprite.centered = false

	if layer_texture:
		repeat_size = Vector2(
			layer_texture.get_width(),
			0.0
		)

	repeat_times = repeat_count


func _refresh_movement() -> void:
	var movement_direction := -1.0 if move_left else 1.0
	autoscroll = Vector2(speed * movement_direction, 0.0)
