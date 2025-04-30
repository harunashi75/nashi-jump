extends Node

@onready var music_player = $LevelSecretSound

func _ready():
	# Lancer la musique du niveau
	if music_player:
		music_player.play()

	# Connecte le menu pause pour ce niveau
	GameManager.pause_menu = $UI/PauseMenu
