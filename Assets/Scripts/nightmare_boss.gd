extends CharacterBody2D

@export var coin_scene: PackedScene
@export var health: int = 15
@export var victory_tp_scene: PackedScene

const RUN_SPEED := 75
const SPIN_SPEED := 200

var direction := 1
var speed := RUN_SPEED
var is_dead := false
var is_invincible := false
var gravity := 900.0
var initial_position : Vector2
var max_health : int
var phase := 1

var player_in_range := false
var slam_cooldown := 4.0
var slam_timer := 0.0
var is_jumping := false
var is_spinning := false

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
		velocity.x = direction * speed
	elif not is_jumping:
		velocity.x = move_toward(velocity.x, 0, 10)

	sprite.flip_h = (direction > 0)

func handle_wall_collision():
	var hitting_wall = is_on_wall()
	var near_wall = (direction == 1 and raycast_right.is_colliding()) or (direction == -1 and raycast_left.is_colliding())

	if hitting_wall or near_wall:
		direction *= -1
		position.x += direction * 2 
		
		if health < 7:
			apply_camera_shake(0.2, 4.0)

# ========================
# ATTACK SYSTEM
# ========================

func _on_attack_timer_timeout():
	if phase < 2 or is_dead:
		return

	is_spinning = !is_spinning

	if is_spinning:
		speed = SPIN_SPEED
		sprite.play("spin")
	else:
		speed = RUN_SPEED
		sprite.play("run")

	attack_timer.start(randf_range(3.0, 4.0))

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

		if player_falling and vertical_diff < 100:
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

		speed = RUN_SPEED
		sprite.play("run")

		attack_timer.start(randf_range(3.0, 4.0))

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

# ========================
# FX
# ========================

func apply_camera_shake(duration: float, intensity: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(duration, intensity)
