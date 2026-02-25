extends Node

# -------- Références de l'UI --------

var hud: Node = null
var pause_menu: Control = null

# -------- Checkpoint --------

var levels_checkpoint_enabled := false
var levels_checkpoint_scene_path := ""

# -------- Paramètres globaux --------

var godmode_enabled := false
var is_game_paused: bool = false
var no_damage_run: bool = true

const SAVE_PATH := "user://savegame.cfg"
var current_level_path: String = ""

# -------- Victory Stats --------

var run_time: float = 0.0
var deaths_count: int = 0
var skins_unlocked_this_run: Array = []

# -------- Coins --------

var coins_collected_by_level := {}
var total_possible_coins := 330

# -------- Initialisation --------

func _ready():
	load_coins()
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null

# -------- Démarrage & Pause --------

func start_game():
	no_damage_run = true

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
	
	TimerManager.save_current_progress()

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
	skins_unlocked_this_run.clear()
	
	var config := ConfigFile.new()
	config.set_value("progress", "current_level", "res://Assets/Scenes/level_1.tscn")
	config.set_value("coins", "by_level", {})
	config.save(SAVE_PATH)

# -------- Coins --------

func reset_coins():
	coins_collected_by_level.clear()

func mark_coin_collected(level: String, id: String):
	var list: Array = coins_collected_by_level.get(level, [])

	if id in list:
		return

	list.append(id)
	coins_collected_by_level[level] = list

	save_coins()
	_update_hud_coins()

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) \
	and coin_id in coins_collected_by_level[level_name]

func get_total_unique_coins() -> int:
	var total := 0
	for coins in coins_collected_by_level.values():
		total += coins.size()
	return total

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

# -------- HUD --------

func _update_hud_coins():
	if not hud or not hud.is_inside_tree():
		return

	var total_collected: int = get_total_unique_coins()

	hud.update_coins_display(
		total_collected
	)

# -------- Checkpoint --------

func set_levels_checkpoint(path: String):
	levels_checkpoint_enabled = true
	levels_checkpoint_scene_path = path
	print("Checkpoint activé :", path)

func reset_checkpoint_data():
	levels_checkpoint_enabled = false
	levels_checkpoint_scene_path = "res://Assets/Scenes/level_1.tscn"

# -------- Input --------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_G:
				_toggle_godmode()

func _toggle_godmode() -> void:
	godmode_enabled = !godmode_enabled
