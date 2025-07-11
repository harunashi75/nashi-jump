extends Node

# ------------------------
# Variables Globales
# ------------------------
var hud: Node = null
var victory_checkpoint_enabled := false
var victory_checkpoint_scene_path := ""
var time_scores := {}
var game_start_time: int = 0

# Vies
var player_lives: int = 3
var player_current_health = 3
var has_initialized_health := false
var difficulty := "normal"

# Coins
var coins_collected := {}
var coins_collected_by_level := {}
var total_coins_in_level := 0

# Pause
var is_game_paused: bool = false
var pause_menu: Control = null

# Skins
var current_skin := "default"
var unlocked_skins := {
	"easy": false,
	"normal": false,
	"hard": false,
	"gold": false,
	"time": false,
	"timetwo": false
}

var coins_collected_by_difficulty := {
	"easy": 0,
	"normal": 0,
	"hard": 0
}
const SAVE_PATH = "user://skin_data.save"

# ------------------------
# Fonctions principales
# ------------------------

func _ready():
	load_skin_data()

func start_game(lives: int):
	reset_coins()
	player_lives = lives
	player_current_health = lives
	game_start_time = Time.get_ticks_msec()
	print("Game démarré avec ", lives, " vies.")

func toggle_pause():
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused

	if pause_menu:
		pause_menu.visible = is_game_paused

	print("Pause :", is_game_paused)

func reset_lives_by_difficulty():
	match difficulty:
		"easy":
			player_lives = 6
		"normal":
			player_lives = 3
		"hard":
			player_lives = 1
		_:
			player_lives = 3

	player_current_health = player_lives

# ------------------------
# Coins
# ------------------------

func reset_coins():
	coins_collected.clear()
	coins_collected_by_level.clear()
	total_coins_in_level = 0

func add_coin(coin_name: String, amount: int = 1):
	if coins_collected.has(coin_name):
		coins_collected[coin_name] += amount
	else:
		coins_collected[coin_name] = amount

	if hud:
		hud.update_coins_display()

	print("Coins collectés :", coins_collected)

func mark_coin_collected(level_name: String, coin_id: String):
	if not coins_collected_by_level.has(level_name):
		coins_collected_by_level[level_name] = []

	if coin_id not in coins_collected_by_level[level_name]:
		coins_collected_by_level[level_name].append(coin_id)
		print("Coin unique collecté :", coin_id)
		check_unlock_skins()

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func set_victory_checkpoint(path: String):
	victory_checkpoint_enabled = true
	victory_checkpoint_scene_path = path
	print("Checkpoint activé :", path)

# ------------------------
# Skins (Déblocage & Sauvegarde)
# ------------------------

func check_unlock_skins():
	var total = 0
	for level_coins in coins_collected_by_level.values():
		total += level_coins.size()

	# Met à jour le nombre de coins collectés pour la difficulté actuelle
	if difficulty in coins_collected_by_difficulty:
		coins_collected_by_difficulty[difficulty] = total

	# Débloque les skins par difficulté
	if total >= 94 and not unlocked_skins.get(difficulty, false):
		unlocked_skins[difficulty] = true
		print("Skin", difficulty, "débloqué!")

	# Vérifie si toutes les difficultés ont 94 coins => débloque le skin doré
	var all_done = true
	for d in ["easy", "normal", "hard"]:
		if coins_collected_by_difficulty.get(d, 0) < 94:
			all_done = false
			break

	if all_done and not unlocked_skins.get("gold", false):
		unlocked_skins["gold"] = true
		print("Skin doré débloqué!")

	check_time_skins()
	# Sauvegarde après mise à jour
	save_skin_data()

func save_skin_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins,
		"coins_collected_by_difficulty": coins_collected_by_difficulty,
		"time_scores": time_scores
	}
	file.store_var(data)
	file.close()

func load_skin_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		current_skin = data.get("current_skin", "default")
		unlocked_skins = data.get("unlocked_skins", unlocked_skins)
		coins_collected_by_difficulty = data.get("coins_collected_by_difficulty", coins_collected_by_difficulty)
		time_scores = data.get("time_scores", {})
		file.close()
	else:
		current_skin = "default"
		unlocked_skins = {
			"easy": false,
			"normal": false,
			"hard": false,
			"gold": false,
			"time": false,
			"timetwo": false
		}
		coins_collected_by_difficulty = {
			"easy": 0,
			"normal": 0,
			"hard": 0
		}
		time_scores = {}

func check_time_skins():
	var eligible_difficulties = 0
	for diff in ["easy", "normal", "hard"]:
		if time_scores.get(diff, INF) <= 600.0 and coins_collected_by_difficulty.get(diff, 0) >= 94:
			eligible_difficulties += 1

	if eligible_difficulties >= 1 and not unlocked_skins["time"]:
		unlocked_skins["time"] = true
		print("Skin TIME débloqué!")

	if eligible_difficulties == 3 and not unlocked_skins["timetwo"]:
		unlocked_skins["timetwo"] = true
		print("Skin TIME TWO débloqué!")

func set_completion_time(diff: String, time_in_seconds: float):
	if not time_scores.has(diff) or time_scores[diff] > time_in_seconds:
		time_scores[diff] = time_in_seconds
		print("Temps mis à jour pour", diff, ":", time_in_seconds)
		check_time_skins()
		save_skin_data()
