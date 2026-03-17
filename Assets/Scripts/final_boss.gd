extends CharacterBody2D

@export var SPEED : float = 80.0
@export var coin_scene: PackedScene
@export var health: int = 15
@export var slime_scene: PackedScene
@export var victory_tp_scene: PackedScene

var direction := 1
var is_dead := false
var is_invincible := false
var gravity := 900.0
var initial_position : Vector2
var max_health : int
var phase := 1
var is_attacking := false

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

	if phase == 3 and not is_attacking and is_on_floor() and not is_jumping:
		start_attack()

	# --- Gestion du Timer de saut ---
	if player_in_range and not is_jumping and phase < 3:
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

func start_attack():
	is_attacking = true
	
	while phase == 3 and not is_dead:
		if sprite.sprite_frames.has_animation("attack"):
			sprite.play("attack")
		
		await get_tree().create_timer(0.4).timeout
		spawn_slimes_around()
		await get_tree().create_timer(1.5).timeout
		
		if not is_dead and not is_jumping:
			sprite.play("run")

func spawn_slimes_around():
	if slime_scene == null:
		return

	for i in range(2):
		var slime = slime_scene.instantiate()
		var offset_x = randf_range(-100, 100)
		var spawn_pos = global_position + Vector2(offset_x, 0)
		
		slime.global_position = spawn_pos
		get_tree().current_scene.call_deferred("add_child", slime)
		
		# effet apparition
		slime.scale = Vector2.ZERO

		var tween = slime.create_tween()
		tween.tween_property(slime, "scale", Vector2(1.2, 0.8), 0.15)
		tween.tween_property(slime, "scale", Vector2.ONE, 0.1)

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
	update_phase()
	
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

func update_phase():
	if health <= 5 and phase < 3:
		phase = 3
		SPEED *= 1.5

	elif health <= 10 and phase < 2:
		phase = 2

func drop_coin():
	if coin_scene == null:
		return

	for i in range(10):
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
	
	drop_coin()
	clear_all_slimes()
	spawn_victory_tp()
	
	visible = false
	set_collision_layer_value(4, false) 
	set_collision_mask_value(1, false)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

func spawn_victory_tp():
	if victory_tp_scene == null:
		return

	var tp = victory_tp_scene.instantiate()

	# position fixe sur la plateforme
	tp.global_position = Vector2(-136, -48)

	get_tree().current_scene.call_deferred("add_child", tp)

	# effet apparition
	tp.scale = Vector2.ZERO
	var tween = tp.create_tween()
	tween.tween_property(tp, "scale", Vector2.ONE, 0.3)

func clear_all_slimes():
	var enemies = get_tree().get_nodes_in_group("enemy")

	for e in enemies:
		if e != self:
			var tween = e.create_tween()
			tween.tween_property(e, "scale", Vector2.ZERO, 0.2)
			tween.tween_callback(e.queue_free)
