extends CharacterBody2D

@export var SPEED : float = 60.0
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
var max_slimes := 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox
@onready var detection_area: Area2D = $DetectionArea
@onready var inv_timer: Timer = $InvincibilityTimer
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	initial_position = global_position
	max_health = health
	
	sprite.play("run")

	hitbox.body_entered.connect(_on_body_entered)
	detection_area.body_entered.connect(_on_player_enter)
	detection_area.body_exited.connect(_on_player_exit)

	inv_timer.timeout.connect(_on_inv_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

# ========================
# PHYSICS
# ========================

func _physics_process(delta):
	if is_dead:
		return

	handle_attack_trigger()
	handle_slam(delta)
	apply_gravity(delta)
	handle_movement()
	handle_wall_collision()

	move_and_slide()

	if is_jumping and is_on_floor():
		land_slam()

# ========================
# LOGIC
# ========================

func handle_attack_trigger():
	if phase >= 2 and not is_attacking:
		start_attack()

func handle_slam(delta):
	if player_in_range and not is_jumping and phase == 1:
		slam_timer -= delta
		if slam_timer <= 0:
			start_slam()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 

func handle_movement():
	if is_on_floor() and not is_jumping:
		velocity.x = direction * SPEED
	elif not is_jumping:
		velocity.x = move_toward(velocity.x, 0, 10)

	sprite.flip_h = (direction > 0)

func handle_wall_collision():
	var hitting_wall = is_on_wall()
	var near_wall = (direction == 1 and raycast_right.is_colliding()) or (direction == -1 and raycast_left.is_colliding())

	if hitting_wall or near_wall:
		direction *= -1
		position.x += direction * 2 
		
		if health < 5:
			apply_camera_shake(0.2, 4.0)

# ========================
# ATTACK SYSTEM
# ========================

func start_attack():
	if is_attacking or is_dead:
		return
	
	is_attacking = true
	attack_timer.start()

func _on_attack_timer_timeout():
	if is_dead or phase < 2:
		is_attacking = false
		return

	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")

	await get_tree().create_timer(0.4).timeout
	spawn_slimes_around()

	if not is_jumping:
		sprite.play("run")

# ========================
# SLIME SPAWN
# ========================

func spawn_slimes_around():
	if slime_scene == null or is_dead:
		return

	var current = get_current_slime_count()
	if current >= max_slimes:
		return

	var remaining = max_slimes - current
	var spawn_count = min(1, remaining)

	for i in range(spawn_count):
		if is_dead:
			return

		var slime = slime_scene.instantiate()
		var offset_x = randf_range(-100, 100)
		slime.global_position = global_position + Vector2(offset_x, 0)

		if owner:
			owner.call_deferred("add_child", slime)

		slime.scale = Vector2.ZERO
		var tween = slime.create_tween()
		tween.tween_property(slime, "scale", Vector2(1.2, 0.8), 0.15)
		tween.tween_property(slime, "scale", Vector2.ONE, 0.1)

func get_current_slime_count():
	var count = 0
	for e in get_tree().get_nodes_in_group("enemy"):
		if e != self:
			count += 1
	return count

# ========================
# PLAYER DETECTION
# ========================

func _on_player_enter(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_player_exit(body):
	if body.is_in_group("player"):
		player_in_range = false

# ========================
# SLAM
# ========================

func start_slam():
	is_jumping = true
	velocity.y = -350
	slam_timer = slam_cooldown

	apply_camera_shake(0.2, 3.0)
	SoundManager.play("jump")

func land_slam():
	is_jumping = false
	velocity = Vector2.ZERO

	apply_camera_shake(0.4, 6.0)
	push_player()

	SoundManager.play("stomp")

func push_player():
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("bounce"):
			body.velocity.y = -300

# ========================
# DAMAGE SYSTEM
# ========================

func _on_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("player"):
		var player := body as CharacterBody2D
		if player == null:
			return

		var player_falling = player.velocity.y > 0
		var vertical_diff = player.global_position.y - global_position.y

		if player_falling and vertical_diff < 80:
			stomped(player)
		else:
			player.take_damage(1)

func stomped(player):
	if is_dead or is_invincible:
		return
	
	take_damage(1, player)
	
	if player.has_method("bounce"): 
			player.bounce()

func take_damage(amount: int, player):
	if is_invincible or is_dead:
		return

	health -= amount
	update_phase()

	if health <= 0:
		die()
		return

	is_invincible = true
	inv_timer.start()

	# HIT FEEL
	# Engine.time_scale = 0.05
	# await get_tree().create_timer(0.05).timeout
	# Engine.time_scale = 1.0

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if player.has_method("bounce"):
		player.bounce()

	SoundManager.play("stomp")

func _on_inv_timer_timeout():
	is_invincible = false

# ========================
# PHASE SYSTEM
# ========================

func update_phase():
	if health <= 7 and phase == 1:
		phase = 2
		SPEED = 75
		max_slimes = 5

# ========================
# DEATH
# ========================

func die():
	if is_dead:
		return
		
	is_dead = true
	set_physics_process(false)

	visible = false
	set_collision_layer_value(4, false)
	set_collision_mask_value(1, false)

	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	drop_coin()
	clear_all_slimes()
	spawn_victory_tp()

# ========================
# SPAWNS
# ========================

func drop_coin():
	if coin_scene == null:
		return

	for i in range(10):
		var coin = coin_scene.instantiate()
		coin.name = "boss_coin_" + str(Time.get_ticks_msec()) + "_" + str(i)

		var offset = Vector2(randf_range(-30, 30), randf_range(-10, 10))

		if owner:
			owner.call_deferred("add_child", coin)

		coin.global_position = global_position + Vector2(0, -40) + offset

		if coin.has_method("launch"):
			coin.launch(-1 if randf() < 0.5 else 1)

func spawn_victory_tp():
	if victory_tp_scene == null:
		return

	var tp = victory_tp_scene.instantiate()
	tp.global_position = Vector2(-136, -48)

	if owner:
		owner.call_deferred("add_child", tp)

	tp.scale = Vector2.ZERO
	var tween = tp.create_tween()
	tween.tween_property(tp, "scale", Vector2.ONE, 0.3)

func clear_all_slimes():
	var enemies = get_tree().get_nodes_in_group("enemy")

	for e in enemies:
		if e != self and is_instance_valid(e):
			var tween = e.create_tween()
			tween.tween_property(e, "scale", Vector2.ZERO, 0.2)
			tween.tween_callback(Callable(e, "queue_free"))

# ========================
# FX
# ========================

func apply_camera_shake(duration: float, intensity: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(duration, intensity)
