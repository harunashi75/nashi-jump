extends Area2D

var damage: int = 1

func _ready():
	connect("body_entered", _on_body_entered)
	_set_damage_by_difficulty()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _set_damage_by_difficulty():
	var scene_name = get_tree().current_scene.name
	var difficulty = GameManager.difficulty
	damage = GameManager.enemy_damage_by_level.get(difficulty, {}).get(scene_name, 1)
	print("Enemies damage set to:", damage, "for scene:", scene_name, "difficulty:", difficulty)
