class_name AtmosRecordingTimer
extends Node


@export_category("Recording")

@export var enabled: bool = true

@export_range(1.0, 43200.0, 1.0, "suffix:s")
var duration_seconds: float = 225.0


var elapsed_seconds: float = 0.0


func _process(delta: float) -> void:
	if not enabled:
		return

	elapsed_seconds += delta

	if elapsed_seconds >= duration_seconds:
		get_tree().quit()
