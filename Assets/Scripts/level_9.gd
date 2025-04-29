extends Node

func _ready():
	MusicManager.music_player.stream = preload("res://Assets/Sounds/desert-rose-loop-180328.ogg")
	MusicManager.music_player.play()
	# Connecte le menu pause pour ce niveau
	GameManager.pause_menu = $UI/PauseMenu
