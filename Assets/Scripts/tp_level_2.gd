extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_2.tscn"
@onready var anim = $AnimatedSprite2D
@onready var tp_sound = $TPSound

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if tp_sound:
			tp_sound.play()
		
		# On attend la fin du son avant de changer de scène
		var delay: float = tp_sound.stream.get_length() if tp_sound.stream else 0.5
		await get_tree().create_timer(delay).timeout

		call_deferred("_deferred_load_next_level")

func _deferred_load_next_level():
	LevelManager.load_level_by_path(next_level_path)
