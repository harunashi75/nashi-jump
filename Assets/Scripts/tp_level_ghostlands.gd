extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_ghostlands.tscn"
@export var required_coins: int = 750

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if _has_enough_coins():
			call_deferred("_deferred_load_next_level")

func _has_enough_coins() -> bool:
	var total_collected := 0
	for coins in GameManager.coins_collected_by_level.values():
		total_collected += coins.size()
	return total_collected >= required_coins

func _deferred_load_next_level():
	GameManager.set_levels_checkpoint(next_level_path)
	LevelManager.load_level_by_path(next_level_path)
