extends Area2D

@export var damage = 1

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("damage")
	connect("body_entered", Callable(self, "_on_body_entered"))
	_set_damage_by_scene()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)

func _set_damage_by_scene():
	var scene_name = get_tree().current_scene.name
	damage = GameManager.get_enemy_damage(scene_name)
	print("Enemies damage set to:", damage, "for scene:", scene_name)
