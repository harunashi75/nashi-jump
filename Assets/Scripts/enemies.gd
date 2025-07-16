extends Area2D

@export var speed: int = 100
@export var patrol_distance: int = 50

var damage: int = 1 # sera défini dynamiquement
var direction = -1
var start_position: Vector2
var target_position: Vector2

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(patrol_distance, 0)
	sprite.play("run")
	connect("body_entered", _on_body_entered)
	_update_flip()
	_set_damage_by_difficulty()

func _physics_process(delta):
	var move = direction * speed * delta
	global_position.x += move

	if direction == 1 and global_position.x >= target_position.x:
		direction = -1
		target_position = start_position - Vector2(patrol_distance, 0)
		_update_flip()
	elif direction == -1 and global_position.x <= target_position.x:
		direction = 1
		target_position = start_position + Vector2(patrol_distance, 0)
		_update_flip()

func _update_flip():
	sprite.flip_h = direction < 0

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _set_damage_by_difficulty():
	var scene_name = get_tree().current_scene.name
	var difficulty = GameManager.difficulty

	damage = GameManager.enemy_damage_by_level.get(difficulty, {}).get(scene_name, 1)
	print("Enemy damage set to:", damage, "for scene:", scene_name, "difficulty:", difficulty)
