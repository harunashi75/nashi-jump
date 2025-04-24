extends Area2D

@export var speed: int = 100
@export var patrol_distance: int = 50
@export var damage: int = 1

var direction = 1
var start_position

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	start_position = global_position
	sprite.play("run")
	connect("body_entered", _on_body_entered)

func _process(delta):
	global_position.x += direction * speed * delta

	if abs(global_position.x - start_position.x) >= patrol_distance:
		direction *= -1
		sprite.flip_h = (direction > 0)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
