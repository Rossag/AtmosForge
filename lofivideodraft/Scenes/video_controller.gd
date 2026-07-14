extends Node

@export var duration := 225.0

var timer := 0.0

func _process(delta):
	timer += delta

	if timer >= duration:
		get_tree().quit()
