extends Node

func _ready():
	var enter_sound = $VictorySound
	if enter_sound:
		enter_sound.play()

	var music = $LevelVictorySound
	if music:
		music.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	hud.update_coins_display()

	GameManager.pause_menu = $UI/PauseMenu

func _exit_tree():
	if $VictorySound:
		$VictorySound.stop()
		$VictorySound.stream = null
		$VictorySound.queue_free()

	if $LevelVictorySound:
		$LevelVictorySound.stop()
		$LevelVictorySound.stream = null
		$LevelVictorySound.queue_free()
