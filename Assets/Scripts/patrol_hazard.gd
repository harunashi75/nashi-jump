extends Node2D

# Piège qui fait des allers-retours sur un axe (scie : horizontal, brickhead : vertical).
# Il repart dans l'autre sens dès qu'un de ses RayCast touche un obstacle.
#   HORIZONTAL : RayCastRight / RayCastLeft, sens positif = droite
#   VERTICAL   : RayCastDown / RayCastUp,    sens positif = bas

enum Axis { HORIZONTAL, VERTICAL }

@export var axis: Axis = Axis.HORIZONTAL
@export var speed := 100.0
@export_enum("Positif:1", "Négatif:-1") var start_direction := 1
@export var animation := "run"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1
var ray_positive: RayCast2D
var ray_negative: RayCast2D

func _ready():
	direction = start_direction

	if axis == Axis.HORIZONTAL:
		ray_positive = $RayCastRight
		ray_negative = $RayCastLeft
	else:
		ray_positive = $RayCastDown
		ray_negative = $RayCastUp

	sprite.play(animation)

func _process(delta):
	if ray_positive.is_colliding():
		direction = -1
	elif ray_negative.is_colliding():
		direction = 1

	var step := direction * speed * delta
	if axis == Axis.HORIZONTAL:
		position.x += step
	else:
		global_position.y += step
