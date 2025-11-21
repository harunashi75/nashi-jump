extends Node2D

@export var SPEED = 100
var direction = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox

func _ready():
	sprite.play("run")

func _process(delta):
	if raycast_right.is_colliding():
		direction = -1
	elif raycast_left.is_colliding():
		direction = 1
	
	position.x += direction * SPEED * delta
