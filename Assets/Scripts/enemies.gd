extends Node2D

const SPEED = 100
var direction = 1
var is_attacking = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox

func _ready():
	sprite.play("run")
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta):
	if is_attacking:
		return
	
	if raycast_right.is_colliding():
		direction = -1
	elif raycast_left.is_colliding():
		direction = 1
	
	position.x += direction * SPEED * delta
	sprite.flip_h = direction > 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		play_attack_anim()

func play_attack_anim():
	if is_attacking:
		return
	is_attacking = true
	if sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")
		sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	else:
		_on_attack_finished()

func _on_attack_finished():
	is_attacking = false
	sprite.play("run")
