extends Node

var time_elapsed: float = 0.0
var running: bool = false

var best_times: Dictionary = {
	"easy": -1.0,
	"normal": -1.0,
	"hard": -1.0,
	"insane": -1.0
}

const SAVE_PATH := "user://score.save"

func _ready() -> void:
	load_best_times()

func _process(delta: float) -> void:
	if running:
		time_elapsed += delta

func start_timer() -> void:
	time_elapsed = 0.0
	running = true

func stop_timer() -> void:
	running = false

func get_elapsed_time() -> float:
	return time_elapsed

func get_formatted_time() -> String:
	return _format_time(time_elapsed)

func save_best_times() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(best_times)
		file.close()

func load_best_times() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best_times = file.get_var()
			file.close()

func get_formatted_best_time(difficulty: String) -> String:
	var best_time: float = best_times.get(difficulty, -1.0)
	return _format_time(best_time)

func maybe_set_best_time(difficulty: String) -> void:
	var current_time := time_elapsed
	var best_time: float = best_times.get(difficulty, -1.0)

	if best_time == -1.0 or current_time < best_time:
		best_times[difficulty] = current_time
		save_best_times()

func _format_time(time: float) -> String:
	if time < 0.0:
		return "--:--.--"
	var minutes: int = floor(time / 60)
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
