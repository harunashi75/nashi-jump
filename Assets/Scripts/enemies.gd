extends Node2D

@export var SPEED := 80
@export var coin_scene: PackedScene

var direction := 1
var is_dead := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox

func _ready():
	sprite.play("run")
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta):
	if is_dead:
		return

	# --- Changement de direction ---
	if raycast_right.is_colliding():
		direction = -1
	elif raycast_left.is_colliding():
		direction = 1

	# --- Mouvement ---
	position.x += direction * SPEED * delta
	sprite.flip_h = direction > 0

func _on_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("player"):

		var player := body as CharacterBody2D
		if player == null:
			return

		var player_falling: bool = player.velocity.y > 0
		var vertical_diff: float = player.global_position.y - global_position.y
		var stomp_tolerance := 16.0

		if player_falling and vertical_diff < stomp_tolerance:
			stomped(player)
		else:
			player.take_damage(1)

func stomped(player):
	die()

	if player.has_method("bounce"):
		player.bounce()

	SoundManager.play("stomp")

func drop_coin():
	if coin_scene == null:
		return

	var coin = coin_scene.instantiate()
	coin.name = "enemy_coin_" + str(Time.get_ticks_msec())

	get_tree().current_scene.call_deferred("add_child", coin)

	coin.global_position = global_position + Vector2(0, -20)

	var dir = -1 if randf() < 0.5 else 1
	if coin.has_method("launch"):
		coin.launch(dir)

func die():
	if is_dead:
		return

	is_dead = true
	SPEED = 0

	hitbox.set_deferred("monitoring", false)

	drop_coin()

	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.15).timeout

	queue_free()
