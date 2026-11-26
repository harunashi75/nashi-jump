extends Area2D

@export_file("*.tscn") var next_level_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level() -> void:
	if next_level_path == "":
		printerr("Erreur : next_level_path est vide sur ", name)
		return

	GameManager.save_current_level(next_level_path)
	GameManager.save_run_stats()
	GameManager.set_levels_checkpoint(next_level_path)
	
	LevelManager.load_level_by_path(next_level_path)
