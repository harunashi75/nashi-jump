extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_victory.tscn"
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	GameManager.set_victory_checkpoint(next_level_path)
	TimerManager.stop_timer()
	GameManager.set_completion_time(GameManager.difficulty, TimerManager.get_elapsed_time())

	LevelManager.load_level_by_path(next_level_path)
