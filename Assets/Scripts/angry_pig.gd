extends Area2D

@export var speed: int = 100
@export var patrol_distance: int = 50
@export var damage: int = 1

var direction = 1
var start_position: Vector2
var target_position: Vector2

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	start_position = global_position
	target_position = start_position + Vector2(patrol_distance, 0)
	sprite.play("run")
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	var move = direction * speed * delta
	global_position.x += move

	if direction == 1 and global_position.x >= target_position.x:
		direction = -1
		target_position = start_position - Vector2(patrol_distance, 0)
		sprite.flip_h = (direction > 0)

	elif direction == -1 and global_position.x <= target_position.x:
		direction = 1
		target_position = start_position + Vector2(patrol_distance, 0)
		sprite.flip_h = (direction > 0)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
