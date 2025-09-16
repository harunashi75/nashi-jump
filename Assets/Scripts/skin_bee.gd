extends Area2D

@export var skin_id: String = "bee"
@export var floating_text_offset: Vector2 = Vector2(0, -40)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		if not SkinManager.is_unlocked(skin_id):
			SkinManager.unlock_skin(skin_id, body.position + floating_text_offset)
		queue_free()
