extends Node2D

@onready var hitbox: Area2D = $Hitbox

func _ready():
	hitbox.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		pass
