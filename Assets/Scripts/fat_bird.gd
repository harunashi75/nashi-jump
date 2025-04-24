extends Area2D

@export var damage = 3

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
