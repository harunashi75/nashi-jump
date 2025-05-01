extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_7.tscn"
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	LevelManager.load_level_by_path(next_level_path)
