extends Node

var time_elapsed: float = 0.0
var running: bool = false

var best_time: float = -1.0

func _ready() -> void:
	load_best_time()

func _process(delta: float) -> void:
	if running:
		time_elapsed += delta

# -------- Timer controls --------

func start_timer() -> void:
	time_elapsed = 0.0
	running = true

func resume_timer():
	running = true

func stop_timer() -> void:
	running = false

# -------- Getters --------

func get_elapsed_time() -> float:
	return time_elapsed

func get_formatted_time() -> String:
	return _format_time(time_elapsed)

func format_time(time: float) -> String:
	return _format_time(time)

# -------- Best time logic --------

func maybe_set_best_time() -> void:
	if best_time == -1.0 or time_elapsed < best_time:
		best_time = time_elapsed
		save_best_time()

func get_formatted_best_time() -> String:
	return _format_time(best_time)

# -------- Save / Load --------

func save_best_time() -> void:
	SaveManager.set_value("timer", "best", best_time)

func load_best_time() -> void:
	best_time = SaveManager.get_value("timer", "best", -1.0)

func save_current_progress() -> void:
	SaveManager.set_value("timer", "elapsed", time_elapsed)

func load_current_progress() -> void:
	time_elapsed = SaveManager.get_value("timer", "elapsed", 0.0)

# -------- Util --------

func _format_time(time: float) -> String:
	if time < 0.0:
		return "--:--.--"
	var minutes := int(time / 60)
	var seconds := int(time) % 60
	var milliseconds := int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
