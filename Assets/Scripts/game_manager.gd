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

# ------------------------
# Paramètres globaux
# ------------------------
var godmode_enabled := false
var is_game_paused: bool = false
var floating_text_scene := preload("res://Assets/Scenes/floating_text.tscn")
var no_damage_run: bool = true
var used_powerup := false

# ------------------------
# Pièces
# ------------------------
var coins_collected := {}
var coins_collected_by_level := {}
var total_coins_in_level := 10
var total_possible_coins := 120

# ------------------------
# Initialisation
# ------------------------
func _ready():
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null

# ------------------------
# Affichage texte
# ------------------------
func show_floating_text(text: String, position: Vector2, color: Color = Color.WHITE):
	var floating_text = floating_text_scene.instantiate()
	floating_text.position = position
	floating_text.get_node("Label").text = text
	floating_text.get_node("Label").modulate = color
	get_tree().current_scene.add_child(floating_text)

# ------------------------
# Démarrage & Pause
# ------------------------
func start_game():
	reset_coins()
	game_start_time = Time.get_ticks_msec()
	no_damage_run = true
	used_powerup = false

func toggle_pause():
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused
	if pause_menu and pause_menu.is_inside_tree():
		pause_menu.visible = is_game_paused

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

	print("Coin unique collecté :", id)
	_update_hud_coins()

	SkinManager.check_unlock_skins(get_total_unique_coins())

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func get_total_unique_coins() -> int:
	var total := 0
	for coins in coins_collected_by_level.values():
		total += coins.size()
	return total

func get_total_coins_for_level(level_name: String) -> int:
	if level_name == "Level_Victory":
		return 0
	return 10

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
# Temps
# ------------------------
func set_completion_time(time_in_seconds: float):
	if not SkinManager.time_scores.has("best") or SkinManager.time_scores["best"] > time_in_seconds:
		SkinManager.time_scores["best"] = time_in_seconds
		print("Nouveau meilleur temps :", time_in_seconds)

	SkinManager.check_time_skins()
	SkinManager.save_skin_data()

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
			KEY_T:
				LevelManager.load_level_by_path("res://Assets/Scenes/level_victory.tscn")
			KEY_G:
				_toggle_godmode()

func _toggle_godmode() -> void:
	godmode_enabled = !godmode_enabled
	print("Godmode " + ("activé" if godmode_enabled else "désactivé"))
