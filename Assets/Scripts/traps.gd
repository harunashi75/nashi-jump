extends Area2D

var damage: int = 1

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("damage")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
