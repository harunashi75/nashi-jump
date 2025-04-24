extends Area2D

@export var speed = 100
@export var distance = 50  # Distance haut-bas
@export var wait_time = 0.5  # Pause en haut/bas

var direction = -1
var start_y
var target_y
var is_waiting = false

@onready var sprite = $AnimatedSprite2D

func _ready():
	start_y = global_position.y
	target_y = start_y + distance * direction
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if is_waiting:
		return

	global_position.y += direction * speed * delta

	if (direction == -1 and global_position.y <= target_y) or (direction == 1 and global_position.y >= target_y):
		global_position.y = target_y
		_play_hit_animation()
		await _wait_and_switch()
		
func _play_hit_animation():
	if direction == -1:
		sprite.play("hittop")
	else:
		sprite.play("hitbottom")
	
	# Revenir à "idle" après un court délai
	await get_tree().create_timer(0.3).timeout
	sprite.play("idle")

func _on_hit_animation_finished():
	sprite.play("idle")

func _wait_and_switch():
	is_waiting = true
	await get_tree().create_timer(wait_time).timeout
	direction *= -1
	target_y = start_y + distance * direction
	is_waiting = false

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(1)
