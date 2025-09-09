extends Area2D

var damage: int = 1

func _ready():
	connect("body_entered", _on_body_entered)
	_set_damage_by_scene()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _set_damage_by_scene():
	var scene_name = get_tree().current_scene.name
	damage = GameManager.get_enemy_damage(scene_name)
	print("Enemies damage set to:", damage, "for scene:", scene_name)
