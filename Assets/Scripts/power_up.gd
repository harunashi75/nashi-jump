extends Area2D

@onready var collision := $CollisionShape2D
@onready var sprite := $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if not collision.disabled:
		_collect_powerup(body)

func _collect_powerup(body):
	SoundManager.play("power_up")
	SkinManager.add_powerup_count()
	GameManager.used_powerup = true


	var effects = [
		"health",
		"shield",
		"speed",
		"jump"
	]

	var chosen = effects[randi() % effects.size()]
	print("Power-up obtenu :", chosen)

	match chosen:
		"health":
			body.apply_health_bonus()

		"shield":
			body.apply_shield(6.0)
			SkinManager.add_shield_use()

		"speed":
			body.apply_speed_boost(3.0)
			SkinManager.add_speed_boost_use()

		"jump":
			body.apply_jump_boost(3.0)
			SkinManager.add_jump_boost_use()

	_hide_powerup()

	await get_tree().create_timer(5.0).timeout
	_show_powerup()

func _hide_powerup():
	sprite.visible = false
	collision.set_deferred("disabled", true)

func _show_powerup():
	sprite.visible = true
	collision.set_deferred("disabled", false)
