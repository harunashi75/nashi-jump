extends Area2D

@export var fruit_name := "Apple"
@export var value := 1

@onready var collect_sound = $CollectSound
@onready var sprite = $AnimatedSprite2D

func _ready():
	var level_name = get_tree().current_scene.name
	var fruit_id = name

	# Si déjà collecté dans ce niveau, on ne le montre pas
	if GameManager.is_fruit_already_collected(level_name, fruit_id):
		queue_free()
		return

	sprite.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		if collect_sound:
			collect_sound.play()

		GameManager.add_fruit(fruit_name, value)
		GameManager.mark_fruit_collected(get_tree().current_scene.name, name)

		hide()
		await get_tree().create_timer(0.2).timeout
		queue_free()
