extends Node

func _ready():
	var enter_sound = $TPSound
	if enter_sound:
		enter_sound.play()
	
	var music = $LevelSound
	if music:
		music.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	GameManager.total_fruits_in_level = 17
	hud.update_fruits_display()
	
	if GameManager.difficulty != "":
		TimerManager.start_timer()

	GameManager.pause_menu = $UI/PauseMenu

func _exit_tree():
	if $TPSound:
		$TPSound.stop()
		$TPSound.stream = null
		$TPSound.queue_free()
	
	if $LevelSound:
		$LevelSound.stop()
		$LevelSound.stream = null
		$LevelSound.queue_free()
