extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "Player":
		return

	# --- Finalisation de la run ---
	TimerManager.stop_timer()
	GameManager.run_time = TimerManager.get_elapsed_time()

	GameManager.save_current_level("res://Assets/Scenes/level_1.tscn")

	# --- Stats finales ---
	SkinManager.check_endgame_unlocks()

	# --- Transition Victory ---
	LevelManager.load_level_by_path("res://Assets/Scenes/victory_scene.tscn")
