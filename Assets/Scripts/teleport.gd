extends Area2D

@export_file("*.tscn") var next_level_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	if next_level_path == "":
		printerr("Erreur : next_level_path est vide sur ", name)
		return

	GameManager.save_current_level(next_level_path)
	GameManager.set_levels_checkpoint(next_level_path)
	
	LevelManager.load_level_by_path(next_level_path)
