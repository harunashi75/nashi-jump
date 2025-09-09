extends Area2D

@export var skin_id: String = "void"
@export var floating_text_offset: Vector2 = Vector2(0, -40)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		if not GameManager.unlocked_skins.get(skin_id, false):
			GameManager.unlocked_skins[skin_id] = true
			GameManager.show_floating_text("Skin débloqué : " + skin_id, body.position + floating_text_offset, Color(1.0, 0.84, 0.0))
			SoundManager.play("unlock")
			GameManager.save_skin_data()

		queue_free()
