extends Area2D

@export var teleport_position: Vector2  # Position où téléporter le joueur
@onready var teleport_sound = $TPSound  # Ton nœud audio
@onready var player = get_node("/root/Main/Game/Player")
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")  # Joue l'animation de base (par défaut)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		body.global_position = teleport_position
		teleport_sound.play()

		var manager = get_node_or_null("/root/Main")
		if manager:
			manager.resume_timer()  # ← reprend le timer là où il était
