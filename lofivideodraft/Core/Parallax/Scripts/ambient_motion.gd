class_name AtmosAmbientMotion
extends Node


@export_category("Targets")

@export var target_group: StringName = &"ambient_motion_target"


@export_category("Gentle Sway")

@export_range(0.0, 5.0, 0.1)
var horizontal_amount: float = 1.2

@export_range(0.0, 5.0, 0.1)
var vertical_amount: float = 0.8

@export_range(0.01, 2.0, 0.01)
var sway_speed: float = 0.22


@export_category("Fine Vibration")

@export_range(0.0, 2.0, 0.05)
var vibration_amount: float = 0.3

@export_range(0.1, 20.0, 0.1)
var vibration_speed: float = 7.0


var elapsed_time: float = 0.0
var target_layers: Array[CanvasLayer] = []
var starting_offsets: Array[Vector2] = []


func _ready() -> void:
	_find_targets()


func _process(delta: float) -> void:
	elapsed_time += delta

	var sway := Vector2(
		sin(elapsed_time * sway_speed * TAU) * horizontal_amount,
		sin(elapsed_time * sway_speed * 1.37 * TAU + 1.2)
			* vertical_amount
	)

	var vibration := Vector2(
		sin(elapsed_time * vibration_speed * TAU + 0.7),
		sin(elapsed_time * vibration_speed * 1.19 * TAU)
	) * vibration_amount

	var final_offset := sway + vibration

	for index in target_layers.size():
		target_layers[index].offset = (
			starting_offsets[index] + final_offset
		)


func _find_targets() -> void:
	target_layers.clear()
	starting_offsets.clear()

	for node in get_tree().get_nodes_in_group(target_group):
		if node is CanvasLayer:
			target_layers.append(node)
			starting_offsets.append(node.offset)
