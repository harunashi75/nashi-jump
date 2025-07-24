extends Node

# ------------------------
# Références de l'UI
# ------------------------
var hud: Node = null
var pause_menu: Control = null

# ------------------------
# Checkpoint & Temps
# ------------------------
var victory_checkpoint_enabled := false
var victory_checkpoint_scene_path := ""
var game_start_time: int = 0
var time_scores := {}

# ------------------------
# Paramètres globaux
# ------------------------
var godmode_enabled := false
var speed_multiplier := 1.0
var speedup_enabled := false
var is_game_paused: bool = false
var difficulty := "normal"
var has_died_in_fun_mode := false
var has_initialized_health := false

# ------------------------
# Joueur & Vies
# ------------------------
var player_lives: int = 60
var player_current_health := 60

# ------------------------
# Pièces
# ------------------------
var coins_collected := {}
var coins_collected_by_level := {}
var coins_collected_by_difficulty := {
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"fun": 0
}
var total_coins_in_level := 0

# ------------------------
# Skins
# ------------------------
var current_skin := "default"
var unlocked_skins := {
	"easy": false, "normal": false, "hard": false,
	"gold": false, "time": false, "timetwo": false,
	"cyber": false, "rokzor": false
}
const SAVE_PATH = "user://skin_data.save"

# ------------------------
# Initialisation
# ------------------------
func _ready():
	load_skin_data()
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null

# ------------------------
# Démarrage & Pause
# ------------------------
func start_game(lives: int):
	reset_coins()
	player_lives = lives
	player_current_health = lives
	game_start_time = Time.get_ticks_msec()

func toggle_pause():
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused
	if pause_menu and pause_menu.is_inside_tree():
		pause_menu.visible = is_game_paused

# ------------------------
# Vies
# ------------------------
func reset_lives_by_difficulty():
	match difficulty:
		"easy": player_lives = 100
		"normal": player_lives = 60
		"hard": player_lives = 30
		"fun": player_lives = 200
		_: player_lives = 60
	player_current_health = player_lives

# ------------------------
# Coins
# ------------------------
func reset_coins():
	coins_collected.clear()
	coins_collected_by_level.clear()
	total_coins_in_level = 0

func add_coin(_coin_name: String, amount: int = 1):
	coins_collected[name] = coins_collected.get(name, 0) + amount
	if is_instance_valid(hud):
		hud.update_coins_display()

func mark_coin_collected(level: String, id: String):
	coins_collected_by_level[level] = coins_collected_by_level.get(level, [])
	if id not in coins_collected_by_level[level]:
		coins_collected_by_level[level].append(id)
		check_unlock_skins()

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func set_victory_checkpoint(path: String):
	victory_checkpoint_enabled = true
	victory_checkpoint_scene_path = path

# ------------------------
# Skins : Déblocage & Sauvegarde
# ------------------------
func check_unlock_skins():
	var total = 0
	for coins in coins_collected_by_level.values():
		total += coins.size()
	coins_collected_by_difficulty[difficulty] = max(coins_collected_by_difficulty[difficulty], total)
	if total >= 94 and not unlocked_skins.get(difficulty, false):
		unlocked_skins[difficulty] = true
	call_deferred("_check_global_skin_unlocks")
	save_skin_data()

func _all_difficulties_have_min_coins(difficulties: Array, min_coins: int) -> bool:
	for d in difficulties:
		if coins_collected_by_difficulty.get(d, 0) < min_coins:
			return false
	return true

func _check_global_skin_unlocks():
	if _all_difficulties_have_min_coins(["easy", "normal", "hard"], 94):
		unlocked_skins["gold"] = true
	if _all_difficulties_have_min_coins(["easy", "normal", "hard", "fun"], 94):
		unlocked_skins["rokzor"] = true
	if difficulty == "fun" and coins_collected_by_difficulty["fun"] >= 94 and has_died_in_fun_mode:
		unlocked_skins["cyber"] = true
	check_time_skins()
	save_skin_data()

func check_time_skins():
	var count = 0
	for d in ["easy", "normal", "hard"]:
		if time_scores.get(d, INF) <= 720.0 and coins_collected_by_difficulty.get(d, 0) >= 94:
			count += 1
	if count >= 1:
		unlocked_skins["time"] = true
	if count == 3:
		unlocked_skins["timetwo"] = true

# ------------------------
# Sauvegarde
# ------------------------
func save_skin_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var({
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins,
		"coins_collected_by_difficulty": coins_collected_by_difficulty,
		"time_scores": time_scores
	})
	file.close()

func load_skin_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		current_skin = data.get("current_skin", "default")
		unlocked_skins.merge(data.get("unlocked_skins", unlocked_skins), true)
		coins_collected_by_difficulty.merge(data.get("coins_collected_by_difficulty", coins_collected_by_difficulty), true)
		time_scores = data.get("time_scores", {})
		file.close()

# ------------------------
# Temps
# ------------------------
func set_completion_time(diff: String, time_in_seconds: float):
	if not time_scores.has(diff) or time_scores[diff] > time_in_seconds:
		time_scores[diff] = time_in_seconds
		check_time_skins()
		save_skin_data()

# ------------------------
# Dommages ennemis
# ------------------------
var enemy_damage_by_level := {
	"easy": {
		"Level_1": 5,
		"Level_2": 7,
		"Level_3": 10,
		"Level_4": 12,
		"Level_5": 15,
		"Level_6": 18,
		"Level_Bonus_1": 20,
		"Level_Bonus_2": 25,
		"Level_Hard_1": 30,
		"Level_Hard_2": 35,
		"Level_Hard_3": 40,
		"Level_Hard_4": 45
	},
	"normal": {
		"Level_1": 10,
		"Level_2": 13,
		"Level_3": 17,
		"Level_4": 20,
		"Level_5": 25,
		"Level_6": 30,
		"Level_Bonus_1": 35,
		"Level_Bonus_2": 40,
		"Level_Hard_1": 50,
		"Level_Hard_2": 60,
		"Level_Hard_3": 70,
		"Level_Hard_4": 80
	},
	"hard": {
		"Level_1": 15,
		"Level_2": 20,
		"Level_3": 25,
		"Level_4": 30,
		"Level_5": 35,
		"Level_6": 40,
		"Level_Bonus_1": 50,
		"Level_Bonus_2": 60,
		"Level_Hard_1": 70,
		"Level_Hard_2": 80,
		"Level_Hard_3": 90,
		"Level_Hard_4": 100
	},
	"fun": {
		"Level_1": 3,
		"Level_2": 4,
		"Level_3": 5,
		"Level_4": 6,
		"Level_5": 7,
		"Level_6": 8,
		"Level_Bonus_1": 10,
		"Level_Bonus_2": 12,
		"Level_Hard_1": 14,
		"Level_Hard_2": 16,
		"Level_Hard_3": 18,
		"Level_Hard_4": 20,
	}
}
