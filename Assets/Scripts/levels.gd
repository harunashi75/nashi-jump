extends Node

func _ready():
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud

	var total_collected: int = GameManager.get_total_unique_coins()

	hud.update_coins_display(
		total_collected
	)
