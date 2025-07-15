extends Area2D

@export var coin_name := "Coin"
@export var value := 1

@onready var collect_sound = $CollectSound
@onready var sprite = $AnimatedSprite2D

func _ready():
	var level_name = get_tree().current_scene.name
	var coin_id = name
	print("Collecting coin:", coin_name, "in level:", level_name, "id:", coin_id)

	if GameManager.is_coin_already_collected(level_name, coin_id):
		queue_free()
		return

	sprite.play("idle")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		if collect_sound:
			collect_sound.play()

		GameManager.add_coin(coin_name, value)
		GameManager.mark_coin_collected(get_tree().current_scene.name, name)

		hide()
		await get_tree().create_timer(0.2).timeout
		queue_free()
