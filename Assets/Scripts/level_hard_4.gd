extends Node

func _ready():
	var enter_sound = $TPSound
	if enter_sound:
		enter_sound.play()
	
	var music = $LevelHardSound
	if music:
		music.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	
	if GameManager.difficulty != "":
		TimerManager.start_timer()

	GameManager.pause_menu = $UI/PauseMenu
	
func _exit_tree():
	if $TPSound:
		$TPSound.stop()
		$TPSound.stream = null
		$TPSound.queue_free()
	
	if $LevelHardSound:
		$LevelHardSound.stop()
		$LevelHardSound.stream = null
		$LevelHardSound.queue_free()
