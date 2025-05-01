extends Node

var time_elapsed := 0.0
var running := false
var best_time := -1.0  # -1 = aucun record sauvegardé
const SAVE_PATH = "user://score.save"

func _process(delta):
	if running:
		time_elapsed += delta

func _ready():
	load_best_time()

func start_timer():
	if !running:
		running = true

func stop_timer():
	running = false

func get_formatted_time() -> String:
	var minutes = int(time_elapsed) / 60
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func save_best_time():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(best_time)
	file.close()

func load_best_time():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		best_time = file.get_var()
		file.close()

func get_formatted_best_time() -> String:
	if best_time == -1:
		return "--:--.--"
	var minutes = int(best_time) / 60
	var seconds = int(best_time) % 60
	var milliseconds = int((best_time - int(best_time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
