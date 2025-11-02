extends Node

func _ready():
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	
	var level_name := get_tree().current_scene.name
	GameManager.total_coins_in_level = GameManager.get_total_coins_for_level(level_name)
	
	var level_collected := 0
	if GameManager.coins_collected_by_level.has(level_name):
		level_collected = GameManager.coins_collected_by_level[level_name].size()

	var level_total := GameManager.total_coins_in_level

	var total_collected := 0
	for coins in GameManager.coins_collected_by_level.values():
		total_collected += coins.size()

	var total_possible := GameManager.total_possible_coins

	hud.update_coins_display(level_collected, level_total, total_collected, total_possible)
