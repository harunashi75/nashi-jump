extends Area2D

@export var teleport_position: Vector2  # Position où téléporter le joueur
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		var player = body
		player.reset_health()
		player.global_position = teleport_position

		# Appelle stop_timer() depuis Main si disponible
		var game_manager = GameManager
		if game_manager and game_manager.has_method("stop_timer"):
			game_manager.stop_timer()
