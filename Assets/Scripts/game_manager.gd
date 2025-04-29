extends Node

# ------------------------
# Variables Globales
# ------------------------
var player_lives: int = 3

# Pause
var is_game_paused: bool = false
var pause_menu: Control = null  # Le menu pause (optionnel)

# ------------------------
# Fonctions
# ------------------------

func _ready():
	pass  # On ne force pas la recherche ici

# Gestion des vies
func start_game(lives: int):
	player_lives = lives
	print("Game démarré avec ", lives, " vies.")

# Gestion de la Pause
func toggle_pause():
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused

	# Si un menu pause est défini, on le montre/cache
	if pause_menu:
		pause_menu.visible = is_game_paused
	print("Pause :", is_game_paused)
