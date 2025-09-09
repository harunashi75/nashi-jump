extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Joueur est tombé dans la KillZone")
		body.current_health = 0
		SoundManager.play("death")
		body.respawn()
