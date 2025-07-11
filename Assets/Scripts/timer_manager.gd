extends Node

var time_elapsed := 0.0
var running := false

# Nouveaux records par difficulté
var best_times := {
	"easy": -1.0,
	"normal": -1.0,
	"hard": -1.0
}

const SAVE_PATH = "user://score.save"

func _ready():
	load_best_times()

func _process(delta):
	if running:
		time_elapsed += delta

func start_timer():
	time_elapsed = 0.0
	running = true
	print("Timer lancé")

func stop_timer():
	running = false
	print("Timer arrêté à :", time_elapsed)

func get_elapsed_time() -> float:
	return time_elapsed

func get_formatted_time() -> String:
	var minutes = floor(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var milliseconds = int((time_elapsed - int(time_elapsed)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func save_best_times():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(best_times)
	file.close()

func load_best_times():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		best_times = file.get_var()
		file.close()

func get_formatted_best_time(difficulty: String) -> String:
	var best_time = best_times.get(difficulty, -1.0)
	if best_time == -1.0:
		return "--:--.--"
	var minutes = floor(best_time / 60)
	var seconds = int(best_time) % 60
	var milliseconds = int((best_time - int(best_time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

# Appelé quand le joueur atteint la fin (tp final par exemple)
func maybe_set_best_time(difficulty: String):
	var current_time = time_elapsed
	if best_times.get(difficulty, -1.0) == -1.0 or current_time < best_times[difficulty]:
		best_times[difficulty] = current_time
		save_best_times()
		print("Nouveau meilleur temps pour", difficulty, ":", current_time)
