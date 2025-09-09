extends Node

func _ready():
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud
	GameManager.total_coins_in_level = 100
	hud.update_coins_display()
