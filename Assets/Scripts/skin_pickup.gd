extends Area2D

# Ramassage de skin secret : définir skin_id dans l'inspecteur de la scène.
@export var skin_id: String = ""
@export var floating_text_offset: Vector2 = Vector2(0, -40)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if skin_id != "" and not SkinManager.is_unlocked(skin_id):
		SkinManager.unlock_skin(skin_id)
	queue_free()
