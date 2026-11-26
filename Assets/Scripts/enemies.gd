extends Node2D

@export var SPEED := 80
@export var coin_scene: PackedScene

# Écart vertical max entre joueur et ennemi pour compter comme un saut sur la tête
const STOMP_TOLERANCE := 24.0

var direction := 1
var is_dead := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	sprite.play("run")
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
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

func _on_body_entered(body: Node2D) -> void:
	if is_dead:
		return

	if body.is_in_group("player"):

		var player := body as CharacterBody2D
		if player == null:
			return

		var player_falling: bool = player.velocity.y > 0
		var vertical_diff: float = player.global_position.y - global_position.y

		if player_falling and vertical_diff < STOMP_TOLERANCE:
			stomped(player)
		else:
			player.take_damage(1)

func stomped(player: CharacterBody2D) -> void:
	die()

	if player.has_method("bounce"):
		player.bounce()

	SoundManager.play("stomp")

func drop_coin() -> void:
	if coin_scene == null:
		return

	var coin: Node2D = coin_scene.instantiate()
	coin.name = "enemy_coin_" + str(Time.get_ticks_msec())

	get_tree().current_scene.call_deferred("add_child", coin)

	coin.global_position = global_position + Vector2(0, -20)

	var dir: int = -1 if randf() < 0.5 else 1
	if coin.has_method("launch"):
		coin.launch(dir)

func die() -> void:
	if is_dead:
		return

	is_dead = true

	hitbox.set_deferred("monitoring", false)

	drop_coin()

	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	else:
		await get_tree().create_timer(0.15).timeout

	queue_free()
