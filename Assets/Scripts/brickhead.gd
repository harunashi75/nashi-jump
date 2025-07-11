extends Area2D

@export var speed = 100
@export var distance = 50  # Distance haut-bas
@export var wait_time = 0.5  # Pause en haut/bas

var direction := -1
var start_y := 0.0
var target_y := 0.0
var wait_timer := 0.0
var is_waiting := false

@onready var sprite := $AnimatedSprite2D

func _ready():
	start_y = global_position.y
	target_y = start_y + distance * direction
	sprite.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			is_waiting = false
			direction *= -1
			target_y = start_y + distance * direction
		return

	global_position.y += direction * speed * delta

	if (direction == -1 and global_position.y <= target_y) or (direction == 1 and global_position.y >= target_y):
		global_position.y = target_y
		is_waiting = true
		wait_timer = wait_time

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(1)
