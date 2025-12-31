extends Node2D

@export var SPEED = 80
var direction = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox

func _ready():
	sprite.play("run")
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta):
	if raycast_right.is_colliding():
		direction = -1
	elif raycast_left.is_colliding():
		direction = 1
	
	position.x += direction * SPEED * delta
	sprite.flip_h = direction > 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		pass
