extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_victory.tscn"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	TimerManager.stop_timer()
	GameManager.set_completion_time(TimerManager.get_elapsed_time())
	SkinManager.check_no_damage_skin()
	SkinManager.check_ignatius_condition()
	SkinManager.check_blue_ember_victory()

	LevelManager.load_level_by_path(next_level_path)
