extends Node

# ------------------------
# Références de l'UI
# ------------------------
var hud: Node = null
var pause_menu: Control = null

# ------------------------
# Checkpoint & Temps
# ------------------------
var levels_checkpoint_enabled := false
var levels_checkpoint_scene_path := ""
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
var has_initialized_health := false
var floating_text_scene := preload("res://Assets/Scenes/floating_text.tscn")

# ------------------------
# Joueur & Vies
# ------------------------
var player_lives: int = 10
var player_current_health := 10

# ------------------------
# Pièces
# ------------------------
var coins_collected := {}
var coins_collected_by_level := {}
var coins_collected_by_difficulty := {
	"veryeasy": 0,
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"insane": 0,
	"jumpgo": 0,
	"gorun": 0
}
var total_coins_in_level := 0

# ------------------------
# Skins
# ------------------------
var current_skin := "default"
var unlocked_skins := {
	"bubblegum": false, "emerald": false, "mystic": false,
	"abyssal": false, "rainbow": false, "gold": false,
	"whisper": false, "hell": false, "ignatius": false,
	"barbie": false, "bloodforged": false, "frost": false,
	"void": false
}
const SAVE_PATH = "user://skin_data.save"
var difficulty_to_skin_name = {
	"veryeasy": "bubblegum",
	"easy": "emerald",
	"normal": "mystic",
	"hard": "abyssal",
	"insane": "rainbow",
	"jumpgo": "ignatius"
}

# ------------------------
# Initialisation
# ------------------------
func _ready():
	load_skin_data()
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null
	
	for diff in ["veryeasy", "easy", "normal", "hard", "insane"]:
		enemy_damage_by_level[diff] = base_enemy_damage

func show_floating_text(text: String, position: Vector2, color: Color = Color.WHITE):
	var floating_text = floating_text_scene.instantiate()
	floating_text.position = position
	floating_text.get_node("Label").text = text
	floating_text.get_node("Label").modulate = color
	get_tree().current_scene.add_child(floating_text)

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
		"veryeasy": player_lives = 20
		"easy": player_lives = 15
		"normal": player_lives = 10
		"hard": player_lives = 5
		"insane": player_lives = 1
		"jumpgo": player_lives = 10
		"gorun": player_lives = 10
		_: player_lives = 10
	player_current_health = player_lives

# ------------------------
# Coins
# ------------------------
func reset_coins():
	coins_collected.clear()
	coins_collected_by_level.clear()
	total_coins_in_level = 0

func add_coin(coin_name: String, amount: int = 1):
	coins_collected[coin_name] = coins_collected.get(coin_name, 0) + amount
	if is_instance_valid(hud):
		hud.update_coins_display()
	print("Coins collectés :", coins_collected)

func mark_coin_collected(level: String, id: String):
	coins_collected_by_level[level] = coins_collected_by_level.get(level, [])
	if id not in coins_collected_by_level[level]:
		coins_collected_by_level[level].append(id)
		print("Coin unique collecté :", id)
		check_unlock_skins()

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func set_levels_checkpoint(path: String):
	levels_checkpoint_enabled = true
	levels_checkpoint_scene_path = path
	print("Checkpoint activé :", path)

# ------------------------
# Skins : Déblocage & Sauvegarde
# ------------------------
func get_player_pos() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.position + Vector2(0, -80)
	return Vector2(200, 200)

func check_unlock_skins():
	var total = 0
	for coins in coins_collected_by_level.values():
		total += coins.size()
	coins_collected_by_difficulty[difficulty] = max(coins_collected_by_difficulty[difficulty], total)
	if total >= 180 and not unlocked_skins.get(difficulty, false):
		unlocked_skins[difficulty] = true
		var skin_name = difficulty_to_skin_name.get(difficulty, difficulty)
		unlocked_skins[skin_name] = true
		show_floating_text("Skin débloqué : " + skin_name, get_player_pos(), Color(1.0, 0.84, 0.0))
		SoundManager.play("unlock")
	call_deferred("_check_global_skin_unlocks")
	save_skin_data()

func _all_difficulties_have_min_coins(difficulties: Array, min_coins: int) -> bool:
	for d in difficulties:
		if coins_collected_by_difficulty.get(d, 0) < min_coins:
			return false
	return true

func _check_global_skin_unlocks():
	if _all_difficulties_have_min_coins(["veryeasy", "easy", "normal", "hard"], 210) and not unlocked_skins.get("gold", false):
		unlocked_skins["gold"] = true
		show_floating_text("Skin débloqué : gold", get_player_pos(), Color(1.0, 0.84, 0.0))
		SoundManager.play("unlock")
	if difficulty == "jumpgo" and coins_collected_by_difficulty["jumpgo"] >= 100 and not unlocked_skins.get("ignatius", false):
		var skin_name = difficulty_to_skin_name.get("jumpgo", "jumpgo")
		unlocked_skins[skin_name] = true
		show_floating_text("Skin débloqué : " + skin_name, get_player_pos(), Color(1.0, 0.84, 0.0))
		SoundManager.play("unlock")

	check_time_skins()
	save_skin_data()

func check_time_skins():
	var count = 0
	for d in ["easy", "normal", "hard"]:
		if time_scores.get(d, INF) <= 900.0 and coins_collected_by_difficulty.get(d, 0) >= 180:
			count += 1
	if count >= 1 and not unlocked_skins.get("whisper", false):
		unlocked_skins["whisper"] = true
		show_floating_text("Skin débloqué : whisper", get_player_pos(), Color(1.0, 0.84, 0.0))
		SoundManager.play("unlock")
	if count == 3 and not unlocked_skins.get("hell", false):
		unlocked_skins["hell"] = true
		show_floating_text("Skin débloqué : hell", get_player_pos(), Color(1.0, 0.84, 0.0))
		SoundManager.play("unlock")

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
		print("Temps mis à jour pour", diff, ":", time_in_seconds)
		check_time_skins()
		save_skin_data()

# ------------------------
# Dommages ennemis
# ------------------------
var base_enemy_damage := {
	"Level_1": 1,
	"Level_2": 1,
	"Level_3": 1,
	"Level_4": 1,
	"Level_5": 1,
	"Level_6": 2,
	"Level_7": 2,
	"Level_8": 2,
	"Level_9": 2,
	"Level_10": 2,
	"Level_11": 3,
	"Level_12": 3,
	"Level_13": 3,
	"Level_14": 3,
	"Level_15": 3,
	"Level_16": 4,
	"Level_17": 4,
	"Level_18": 4,
	"Level_Hard": 4,
	"Level_Void": 4
}

var enemy_damage_by_level := {
	"jumpgo": {
		"Level_Jump": 2
	},
	"gorun": {
		"Level_Run": 1
	}
}

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_KP_1:
				LevelManager.load_level_by_path("res://Assets/Scenes/level_victory.tscn")
