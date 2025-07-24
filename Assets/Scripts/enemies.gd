extends Node2D

const SPEED = 100
var direction = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft

func _ready():
	sprite.play("run")

func _process(delta):
	# Inverse direction si mur détecté
	if raycast_right.is_colliding():
		direction = -1
	elif raycast_left.is_colliding():
		direction = 1

	# Déplacement
	position.x += direction * SPEED * delta

	# Flip sprite selon direction
	sprite.flip_h = direction < 0
