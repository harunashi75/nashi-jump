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

const COIN_SCENE_PATH := "res://Assets/Scenes/coin.tscn"

var coins_collected_by_level := {}
# niveau (nom du nœud racine) -> noms des pièces placées ; calculé à la demande
var _placed_coins_cache := {}

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

func is_current_level_ice() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene:
		return LevelManager.is_ice_level(current_scene.scene_file_path)
	return false

func save_current_level(level_path: String) -> void:
	current_level_path = level_path
	
	TimerManager.save_current_progress()

	var config := ConfigFile.new()
	if FileAccess.file_exists(SAVE_PATH):
		config.load(SAVE_PATH)
		
	config.set_value("progress", "current_level", level_path)
	config.save(SAVE_PATH)

func load_saved_level() -> String:
	var config := ConfigFile.new()

	if config.load(SAVE_PATH) == OK:
		var level: String = config.get_value(
			"progress",
			"current_level",
			"res://Assets/Scenes/level_plains.tscn"
		)

		levels_checkpoint_scene_path = level
		levels_checkpoint_enabled = true
		return level

	levels_checkpoint_scene_path = "res://Assets/Scenes/level_plains.tscn"
	levels_checkpoint_enabled = true
	return "res://Assets/Scenes/level_plains.tscn"

func reset_progress():
	reset_coins()
	skins_unlocked_this_run.clear()
	
	var config := ConfigFile.new()
	config.set_value("progress", "current_level", "res://Assets/Scenes/level_plains.tscn")
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

# Pièces posées dans les niveaux (hors pièces lâchées par les ennemis/boss),
# lues dans les scènes elles-mêmes : plus aucun total à maintenir à la main.
func get_placed_coins() -> Dictionary:
	if not _placed_coins_cache.is_empty():
		return _placed_coins_cache

	for path in LevelManager.levels:
		var packed := load(path) as PackedScene
		if packed == null:
			continue

		var state := packed.get_state()
		var names := []
		for i in state.get_node_count():
			var instance := state.get_node_instance(i)
			if instance and instance.resource_path == COIN_SCENE_PATH:
				var coin_name := str(state.get_node_name(i))
				if not coin_name in names:
					names.append(coin_name)

		if not names.is_empty():
			_placed_coins_cache[str(state.get_node_name(0))] = names

	return _placed_coins_cache

func get_total_possible_coins() -> int:
	var total := 0
	for names in get_placed_coins().values():
		total += names.size()
	return total

# Nombre de pièces posées déjà ramassées (les pièces lâchées ne comptent pas)
func get_collected_placed_coins() -> int:
	var total := 0
	var placed := get_placed_coins()
	for level in coins_collected_by_level:
		for coin_id in coins_collected_by_level[level]:
			if level in placed and coin_id in placed[level]:
				total += 1
	return total

func has_all_coins() -> bool:
	var needed := get_total_possible_coins()
	return needed > 0 and get_collected_placed_coins() >= needed

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

func reset_checkpoint_data():
	levels_checkpoint_enabled = false
	levels_checkpoint_scene_path = "res://Assets/Scenes/level_plains.tscn"

# -------- Input --------

func _unhandled_input(event: InputEvent) -> void:
	# Godmode : uniquement dans l'éditeur / builds de debug
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_G:
				_toggle_godmode()

func _toggle_godmode() -> void:
	godmode_enabled = !godmode_enabled
