extends Area2D

@export var speed: int = 80
@export var patrol_distance: int = 50

var damage: int = 1
var direction = 1  # Commence vers la droite
var start_position: Vector2
var left_limit: float
var right_limit: float

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	start_position = global_position
	left_limit = start_position.x
	right_limit = start_position.x + patrol_distance
	sprite.play("run")
	connect("body_entered", _on_body_entered)
	_set_damage_by_scene()

func _process(delta):
	global_position.x += direction * speed * delta

	if direction > 0 and global_position.x >= right_limit:
		direction = -1  # Repart à gauche
		sprite.flip_h = false
	elif direction < 0 and global_position.x <= left_limit:
		direction = 1  # Repart à droite
		sprite.flip_h = true

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _set_damage_by_scene():
	var scene_name = get_tree().current_scene.name
	damage = GameManager.get_enemy_damage(scene_name)
	print("Enemies damage set to:", damage, "for scene:", scene_name)
