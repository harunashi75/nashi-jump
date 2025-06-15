extends Node

# ------------------------
# Variables Globales
# ------------------------
var player_lives: int = 3
var player_current_health = 3
var has_initialized_health := false
var difficulty := "normal"  # valeurs possibles : "easy", "normal", "hard"

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

func reset_lives_by_difficulty():
	match difficulty:
		"easy":
			player_lives = 6
		"normal":
			player_lives = 3
		"hard":
			player_lives = 1
		_:
			player_lives = 3  # Valeur par défaut

	player_current_health = player_lives
