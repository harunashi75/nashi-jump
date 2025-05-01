extends Node

func _ready():
	var music = $LevelSecretSound
	if music:
		music.play()

	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)

	if GameManager.difficulty != "":
		TimerManager.start_timer()

	GameManager.pause_menu = $UI/PauseMenu
	
func _exit_tree():
	if $LevelSecretSound:
		$LevelSecretSound.stop()
		$LevelSecretSound.stream = null
		$LevelSecretSound.queue_free()
