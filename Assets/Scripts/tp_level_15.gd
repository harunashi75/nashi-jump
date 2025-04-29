extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_15.tscn"
@onready var teleport_sound = $TPSound
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if teleport_sound and is_inside_tree():
			teleport_sound.play()
			await get_tree().create_timer(0.7).timeout
		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	LevelManager.load_level_by_path(next_level_path)
