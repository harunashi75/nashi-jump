extends Area2D

@export var speed: int = 80
@export var patrol_distance: int = 50
@export var damage: int = 1

var direction = -1  # Commence vers la gauche
var start_position: Vector2
var left_limit: float
var right_limit: float

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	start_position = global_position
	left_limit = start_position.x - patrol_distance
	right_limit = start_position.x
	sprite.play("run")
	connect("body_entered", _on_body_entered)

func _process(delta):
	global_position.x += direction * speed * delta

	if direction < 0 and global_position.x <= left_limit:
		direction = 1  # Va à droite
		sprite.flip_h = true
	elif direction > 0 and global_position.x >= right_limit:
		direction = -1  # Va à gauche
		sprite.flip_h = false

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
