extends Area2D

@export var damage = 1

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("damage")
	connect("body_entered", Callable(self, "_on_body_entered"))
	_set_damage_by_difficulty()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)

func _set_damage_by_difficulty():
	var scene_name = get_tree().current_scene.name
	var difficulty = GameManager.difficulty

	damage = GameManager.enemy_damage_by_level.get(difficulty, {}).get(scene_name, 1)
	print("Traps damage set to:", damage, "for scene:", scene_name, "difficulty:", difficulty)
