extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# --- Finalisation de la run ---
	TimerManager.stop_timer()
	TimerManager.maybe_set_best_time()
	GameManager.run_time = TimerManager.get_elapsed_time()

	GameManager.save_current_level("res://Assets/Scenes/level_plains.tscn")

	# --- Stats finales ---
	SkinManager.check_endgame_unlocks()

	# --- Transition Victory ---
	LevelManager.load_level_by_path("res://Assets/Scenes/victory_scene.tscn")
