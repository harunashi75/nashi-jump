extends Area2D

@export var coin_name: String = "Coin"
@export var value: int = 1

@onready var collect_sound: AudioStreamPlayer2D = $PickupSound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	_initialize_coin()

func _initialize_coin():
	var level_name = get_tree().current_scene.name
	var coin_id = name

	if GameManager.is_coin_already_collected(level_name, coin_id):
		queue_free()
		return

	sprite.play("default")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.name != "Player":
		return

	_collect_coin()

func _collect_coin():
	if collect_sound:
		collect_sound.play()

	GameManager.add_coin(coin_name, value)
	GameManager.mark_coin_collected(get_tree().current_scene.name, name)

	hide()
	await get_tree().create_timer(0.2).timeout
	queue_free()
