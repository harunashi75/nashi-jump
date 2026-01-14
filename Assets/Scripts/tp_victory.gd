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

	SkinManager.set_completion_time(GameManager.run_time)
	SkinManager.check_no_damage_skin()
	SkinManager.check_ignatius_condition()
	SkinManager.check_blue_ember_victory()

	# --- Transition Victory ---
	LevelManager.load_level_by_path("res://Assets/Scenes/victory_scene.tscn")
