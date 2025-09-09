extends Node

func _ready():
	var music = $LevelVictorySound
	if music:
		music.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	GameManager.total_coins_in_level = 210
	hud.update_coins_display()

	GameManager.pause_menu = $UI/PauseMenu
	
	#$Npc.say("Congratulations on your victory!", 4.0)

func _exit_tree():
	if $LevelVictorySound:
		$LevelVictorySound.stop()
		$LevelVictorySound.stream = null
		$LevelVictorySound.queue_free()
