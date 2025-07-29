extends Node

func _ready():
	var enter_sound = $TPSound
	if enter_sound:
		enter_sound.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	GameManager.total_coins_in_level = 104
	hud.update_coins_display()

	GameManager.pause_menu = $UI/PauseMenu

func _exit_tree():
	if $TPSound:
		$TPSound.stop()
		$TPSound.stream = null
		$TPSound.queue_free()
