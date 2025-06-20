extends Node

# ------------------------
# Variables Globales
# ------------------------
var hud: Node = null
var victory_checkpoint_enabled := false
var victory_checkpoint_scene_path := ""

# Vies
var player_lives: int = 3
var player_current_health = 3
var has_initialized_health := false
var difficulty := "normal"  # "easy", "normal", "hard"

# Fruits
var fruits_collected := {}  # {"Apple": 3}
var fruits_collected_by_level := {}  # {"level_1": ["Fruit1", "Fruit2"]}
var total_fruits_in_level := 0

# Pause
var is_game_paused: bool = false
var pause_menu: Control = null

# ------------------------
# Fonctions principales
# ------------------------

func _ready():
	pass  # On attend les scènes pour définir pause_menu ou hud

func start_game(lives: int):
	reset_fruits()
	player_lives = lives
	player_current_health = lives
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
# Fruits
# ------------------------

func reset_fruits():
	fruits_collected.clear()
	fruits_collected_by_level.clear()
	total_fruits_in_level = 0

func add_fruit(fruit_name: String, amount: int = 1):
	if fruits_collected.has(fruit_name):
		fruits_collected[fruit_name] += amount
	else:
		fruits_collected[fruit_name] = amount

	if hud:
		hud.update_fruits_display()

	print("Fruits collectés :", fruits_collected)

func mark_fruit_collected(level_name: String, fruit_id: String):
	if not fruits_collected_by_level.has(level_name):
		fruits_collected_by_level[level_name] = []

	if fruit_id not in fruits_collected_by_level[level_name]:
		fruits_collected_by_level[level_name].append(fruit_id)

func is_fruit_already_collected(level_name: String, fruit_id: String) -> bool:
	return fruits_collected_by_level.has(level_name) and fruit_id in fruits_collected_by_level[level_name]

func set_victory_checkpoint(path: String):
	victory_checkpoint_enabled = true
	victory_checkpoint_scene_path = path
	print("Checkpoint activé :", path)
