extends Node

# ------------------------
# Références de l'UI
# ------------------------
var hud: Node = null
var pause_menu: Control = null

# ------------------------
# Checkpoint
# ------------------------
var levels_checkpoint_enabled := false
var levels_checkpoint_scene_path := ""

# ------------------------
# Paramètres globaux
# ------------------------
var godmode_enabled := false
var is_game_paused: bool = false
var no_damage_run: bool = true
var used_powerup := false

const SAVE_PATH := "user://savegame.cfg"
var current_level_path: String = ""

# -------- Victory Stats --------
var run_time: float = 0.0
var deaths_count: int = 0
var skins_unlocked_this_run: Array = []

# ------------------------
# Pièces
# ------------------------
var coins_collected := {}
var coins_collected_by_level := {}
var total_coins_in_level := 10
var total_possible_coins := 130

# ------------------------
# Initialisation
# ------------------------
func _ready():
	load_coins()
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null

# ------------------------
# Démarrage & Pause
# ------------------------
func start_game():
	no_damage_run = true
	used_powerup = false

func toggle_pause():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused

	if pause_menu:
		if is_game_paused:
			pause_menu.show_pause_menu()
		else:
			pause_menu.hide_pause_menu()

func save_current_level(level_path: String) -> void:
	current_level_path = level_path

	var config := ConfigFile.new()
	config.set_value("progress", "current_level", level_path)
	config.save(SAVE_PATH)

func load_saved_level() -> String:
	var config := ConfigFile.new()

	if config.load(SAVE_PATH) == OK:
		var level: String = config.get_value(
			"progress",
			"current_level",
			"res://Assets/Scenes/level_1.tscn"
		)

		levels_checkpoint_scene_path = level
		levels_checkpoint_enabled = true
		return level

	levels_checkpoint_scene_path = "res://Assets/Scenes/level_1.tscn"
	levels_checkpoint_enabled = true
	return "res://Assets/Scenes/level_1.tscn"

func reset_progress():
	reset_coins()
	
	var config := ConfigFile.new()
	config.set_value("progress", "current_level", "res://Assets/Scenes/level_1.tscn")
	config.set_value("coins", "by_level", {})
	config.save(SAVE_PATH)

# ------------------------
# Coins
# ------------------------
func reset_coins():
	coins_collected.clear()
	coins_collected_by_level.clear()
	total_coins_in_level = 10

func add_coin(coin_name: String, amount: int = 1):
	coins_collected[coin_name] = coins_collected.get(coin_name, 0) + amount
	_update_hud_coins()

func mark_coin_collected(level: String, id: String):
	var list: Array = coins_collected_by_level.get(level, [])

	if id in list:
		return

	list.append(id)
	coins_collected_by_level[level] = list
	
	save_coins()

	SkinManager.check_unlock_skins(get_total_unique_coins())
	_update_hud_coins()

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func get_total_unique_coins() -> int:
	var total := 0
	for coins in coins_collected_by_level.values():
		total += coins.size()
	return total

func get_total_coins_for_level(level_name: String) -> int:
	if level_name == "Level_World":
		return 0
	return 10

func save_coins():
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	config.set_value("coins", "by_level", coins_collected_by_level)
	config.save(SAVE_PATH)

func load_coins():
	var config := ConfigFile.new()

	if config.load(SAVE_PATH) != OK:
		return

	coins_collected_by_level = config.get_value("coins", "by_level", {})

# ------------------------
# HUD
# ------------------------
func _update_hud_coins():
	if hud and hud.is_inside_tree():
		if hud.has_method("update_coins_display"):
			
			var current_level: String = get_tree().current_scene.name

			var level_coins: Array = coins_collected_by_level.get(current_level, [])
			var level_collected: int = level_coins.size()
			var level_total: int = get_total_coins_for_level(current_level)

			var total_collected: int = 0
			for coins in coins_collected_by_level.values():
				total_collected += coins.size()
			
			hud.update_coins_display(level_collected, level_total, total_collected, total_possible_coins)

# ------------------------
# Checkpoint
# ------------------------
func set_levels_checkpoint(path: String):
	levels_checkpoint_enabled = true
	levels_checkpoint_scene_path = path
	print("Checkpoint activé :", path)

func reset_checkpoint_data():
	levels_checkpoint_enabled = false
	levels_checkpoint_scene_path = "res://Assets/Scenes/level_1.tscn"
	print("Checkpoint reset -> retour au niveau 1")

# ------------------------
# Input
# ------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_G:
				_toggle_godmode()

func _toggle_godmode() -> void:
	godmode_enabled = !godmode_enabled
	print("Godmode " + ("activé" if godmode_enabled else "désactivé"))
