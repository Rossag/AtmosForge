class_name AtmosMusicPlaylist
extends Node


@export_category("Playlist")

@export var tracks: Array[AudioStream] = []
@export var autoplay: bool = true
@export var shuffle: bool = true


@export_category("Playback")

@export_range(0.0, 20.0, 0.5)
var crossfade_duration: float = 6.0

@export_range(-40.0, 6.0, 0.5)
var output_volume_db: float = -8.0


@onready var player_a: AudioStreamPlayer = $PlayerA
@onready var player_b: AudioStreamPlayer = $PlayerB


var active_player: AudioStreamPlayer
var waiting_player: AudioStreamPlayer

var track_order: Array[int] = []
var order_position: int = 0
var last_track_index: int = -1
var is_crossfading: bool = false


func _ready() -> void:
	active_player = player_a
	waiting_player = player_b

	player_a.finished.connect(
		_on_player_finished.bind(player_a)
	)

	player_b.finished.connect(
		_on_player_finished.bind(player_b)
	)

	_build_track_order()

	if autoplay and not tracks.is_empty():
		_start_playlist()


func _process(_delta: float) -> void:
	if is_crossfading:
		return

	if not active_player.playing:
		return

	if active_player.stream == null:
		return

	var track_length := active_player.stream.get_length()

	if track_length <= 0.0:
		return

	var crossfade_start: float = maxf(
	0.0,
	track_length - crossfade_duration
)

	if active_player.get_playback_position() >= crossfade_start:
		_crossfade_to_next()


func _start_playlist() -> void:
	var next_track := _get_next_track()

	if next_track == null:
		return

	active_player.stream = next_track
	active_player.volume_linear = db_to_linear(
		output_volume_db
	)
	active_player.play()


func _crossfade_to_next() -> void:
	if is_crossfading or tracks.is_empty():
		return

	var next_track := _get_next_track()

	if next_track == null:
		return

	is_crossfading = true

	waiting_player.stream = next_track
	waiting_player.volume_linear = 0.0
	waiting_player.play()

	var target_volume := db_to_linear(
		output_volume_db
	)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		active_player,
		"volume_linear",
		0.0,
		crossfade_duration
	)

	tween.tween_property(
		waiting_player,
		"volume_linear",
		target_volume,
		crossfade_duration
	)

	await tween.finished

	active_player.stop()

	var previous_player := active_player
	active_player = waiting_player
	waiting_player = previous_player

	is_crossfading = false


func _on_player_finished(
	finished_player: AudioStreamPlayer
) -> void:
	if is_crossfading:
		return

	if finished_player != active_player:
		return

	_start_playlist()


func _build_track_order() -> void:
	track_order.clear()

	for index in tracks.size():
		track_order.append(index)

	if shuffle:
		track_order.shuffle()

	order_position = 0


func _get_next_track() -> AudioStream:
	if tracks.is_empty():
		return null

	if track_order.size() != tracks.size():
		_build_track_order()

	if order_position >= track_order.size():
		_build_track_order()

		# Avoid repeating the same track across shuffle cycles.
		if (
			shuffle
			and track_order.size() > 1
			and track_order[0] == last_track_index
		):
			var swap_index := 1
			var temporary := track_order[0]
			track_order[0] = track_order[swap_index]
			track_order[swap_index] = temporary

	var track_index := track_order[order_position]
	order_position += 1
	last_track_index = track_index

	return tracks[track_index]
