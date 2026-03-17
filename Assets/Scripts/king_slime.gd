extends CharacterBody2D

@export var SPEED : float = 80.0
@export var coin_scene: PackedScene
@export var health: int = 10

var direction := 1
var is_dead := false
var is_invincible := false
var gravity := 900.0
var initial_position : Vector2
var max_health : int

var player_in_range := false
var slam_cooldown := 4.0
var slam_timer := 0.0
var is_jumping := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox
@onready var detection_area: Area2D = $DetectionArea

func _ready():
	initial_position = global_position
	max_health = health
	sprite.play("run")
	hitbox.body_entered.connect(_on_body_entered)
	
	detection_area.body_entered.connect(_on_player_enter)
	detection_area.body_exited.connect(_on_player_exit)

func _physics_process(delta):
	if is_dead:
		return

	# --- Gestion du Timer de saut ---
	if player_in_range and not is_jumping:
		slam_timer -= delta
		if slam_timer <= 0:
			start_slam()

	# --- Gravité constante ---
	if not is_on_floor():
		velocity.y += gravity * delta 

	# --- Intelligence du demi-tour ---
	var hitting_wall = is_on_wall()
	var near_wall = (direction == 1 and raycast_right.is_colliding()) or (direction == -1 and raycast_left.is_colliding())
	if hitting_wall or near_wall:
		direction *= -1
		position.x += direction * 2 
		
		if health < 5:
			apply_camera_shake(0.2, 4.0)

	# --- Mouvement horizontal ---
	if is_on_floor() and not is_jumping:
		velocity.x = direction * SPEED
	elif not is_jumping:
		velocity.x = move_toward(velocity.x, 0, 10)

	# --- MISE À JOUR DU FLIP ---
	sprite.flip_h = (direction > 0)

	# --- Exécution du mouvement ---
	move_and_slide()

	# --- Détection atterrissage ---
	if is_jumping and is_on_floor():
		land_slam()

func _on_player_enter(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_player_exit(body):
	if body.is_in_group("player"):
		player_in_range = false

func start_slam():
	is_jumping = true
	velocity.y = -350
	slam_timer = slam_cooldown

	SoundManager.play("jump")

func land_slam():
	is_jumping = false
	velocity = Vector2.ZERO

	apply_camera_shake(0.4, 6.0)

	push_player()
	
	SoundManager.play("stomp")

func push_player():
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.has_method("bounce"):
				body.velocity.y = -300

func apply_camera_shake(duration: float, intensity: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(duration, intensity)

func _on_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("player"):

		var player := body as CharacterBody2D
		if player == null:
			return

		var player_falling: bool = player.velocity.y > 0
		var vertical_diff: float = player.global_position.y - global_position.y
		var stomp_tolerance := 80.0

		if player_falling and vertical_diff < stomp_tolerance:
			stomped(player)
		else:
			player.take_damage(1)

func stomped(player):
	if is_dead or is_invincible:
		return
	
	take_damage(1, player)

func take_damage(amount: int, player):
	health -= amount
	
	if health == 5:
		SPEED *= 1.5
	
	if health <= 0:
		die()
	else:
		is_invincible = true
		
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
		if player.has_method("bounce"):
			player.bounce() 
			
		SoundManager.play("stomp") 
		
		await get_tree().create_timer(0.5).timeout
		is_invincible = false

func drop_coin():
	if coin_scene == null:
		return

	for i in range(5):
		var coin = coin_scene.instantiate()
		coin.name = "boss_coin_" + str(Time.get_ticks_msec()) + "_" + str(i)

		get_tree().current_scene.call_deferred("add_child", coin)

		coin.global_position = global_position + Vector2(0, -80)

		var dir = -1 if randf() < 0.5 else 1
		if coin.has_method("launch"):
			coin.launch(dir)

func die():
	if is_dead: return
	is_dead = true
	
	# -------- Récompense unique --------
	if not GameManager.king_slime_defeated:
		GameManager.king_slime_defeated = true
		GameManager.save_boss_progress()

		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.apply_permanent_health_bonus()
	
	drop_coin()
	
	visible = false
	set_collision_layer_value(4, false) 
	set_collision_mask_value(1, false)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	await get_tree().create_timer(10.0).timeout
	
	respawn()

func respawn():
	health = max_health
	global_position = initial_position
	is_dead = false
	is_invincible = false
	direction = 1
	velocity.y = 0
	
	visible = true
	set_collision_layer_value(4, true)
	set_collision_mask_value(1, true)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	
	sprite.play("run")
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.0)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
