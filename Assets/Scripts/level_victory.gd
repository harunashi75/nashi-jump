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

	if GameManager.difficulty != "":
		await get_tree().create_timer(0.2).timeout
		TimerManager.stop_timer()
		print("Temps total :", TimerManager.get_formatted_time())

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
