extends Node

var time_elapsed: float = 0.0
var running: bool = false

var best_time: float = -1.0

const SAVE_PATH := "user://score.save"

func _ready() -> void:
	load_best_time()

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

# ------------------------
# Sauvegarde / Chargement
# ------------------------
func save_best_time() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(best_time)
		file.close()

func load_best_time() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			best_time = file.get_var()
			file.close()

# ------------------------
# Best time logic
# ------------------------
func get_formatted_best_time() -> String:
	return _format_time(best_time)

func maybe_set_best_time() -> void:
	var current_time := time_elapsed

	if best_time == -1.0 or current_time < best_time:
		best_time = current_time
		save_best_time()

# ------------------------
# Utilitaires
# ------------------------
func _format_time(time: float) -> String:
	if time < 0.0:
		return "--:--.--"
	var minutes: int = floor(time / 60)
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
