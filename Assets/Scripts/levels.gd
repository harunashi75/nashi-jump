extends Node

func _ready():
	var enter_sound = $TPSound
	if enter_sound:
		enter_sound.play()
	
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	
	var level_name := get_tree().current_scene.name
	GameManager.total_coins_in_level = GameManager.get_total_coins_for_level(level_name)
	
	var total_collected := 0
	for coins in GameManager.coins_collected.values():
		total_collected += coins

	var level_collected := 0
	if GameManager.coins_collected_by_level.has(level_name):
		level_collected = GameManager.coins_collected_by_level[level_name].size()

	hud.update_coins_display(total_collected, level_collected, GameManager.total_coins_in_level)

func _exit_tree():
	if $TPSound:
		$TPSound.stop()
		$TPSound.stream = null
		$TPSound.queue_free()
