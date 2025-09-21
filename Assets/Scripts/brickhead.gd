extends Node2D

@export var speed := 100

var direction := -1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_up: RayCast2D = $RayCastUp
@onready var raycast_down: RayCast2D = $RayCastDown
@onready var hitbox: Area2D = $Hitbox

func _ready():
	sprite.play("idle")

func _process(delta):
	if raycast_up.is_colliding():
		direction = 1
	elif raycast_down.is_colliding():
		direction = -1

	global_position.y += direction * speed * delta
