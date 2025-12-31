extends Area2D

@export var teleport_target_position: Vector2
@export var required_coins: int = 80

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if _has_enough_coins():
			body.global_position = teleport_target_position
			print("Téléporté à", teleport_target_position)
		else:
			print(required_coins, "coins required!")

func _has_enough_coins() -> bool:
	var total_collected := 0
	for coins in GameManager.coins_collected_by_level.values():
		total_collected += coins.size()
	return total_collected >= required_coins
