extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_3.tscn"

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	# Sauvegarde du niveau atteint
	GameManager.save_current_level(next_level_path)

	# Ton système actuel (on ne le casse pas)
	GameManager.set_levels_checkpoint(next_level_path)
	LevelManager.load_level_by_path(next_level_path)
