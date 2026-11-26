extends Area2D

@export var teleport_target_position: Vector2

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.global_position = teleport_target_position
