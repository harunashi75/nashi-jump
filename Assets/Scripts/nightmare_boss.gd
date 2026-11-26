extends CharacterBody2D

# Boss en deux phases, piloté par une machine d'états explicite :
#   RUN  : patrouille (vitesse normale)
#   SLAM : saut + impact au sol (phase 1 uniquement, quand le joueur est à portée)
#   SPIN : patrouille rapide en toupie (phase 2, alterne avec RUN via AttackTimer)
#   DEAD : mort, plus aucune logique

@export var coin_scene: PackedScene
@export var health: int = 15
@export var victory_tp_scene: PackedScene

# -------- Réglages --------

const RUN_SPEED := 75
const SPIN_SPEED := 200
const GRAVITY := 900.0

const PHASE2_HEALTH := 7          # santé à partir de laquelle la phase 2 démarre
const ANGRY_HEALTH := 7           # en dessous : secousse de caméra sur les murs

const SLAM_COOLDOWN := 4.0
const SLAM_JUMP_VELOCITY := -350.0
const SLAM_PLAYER_LAUNCH := -300.0
const STOMP_TOLERANCE := 128.0    # écart vertical max pour compter comme un saut sur la tête

const SPIN_TOGGLE_MIN := 3.0
const SPIN_TOGGLE_MAX := 4.0

const COIN_DROP_COUNT := 10
const VICTORY_TP_POSITION := Vector2(-136, -48)

# -------- État --------

enum State { RUN, SLAM, SPIN, DEAD }

var state: State = State.RUN
var phase := 1
var direction := 1
var speed := RUN_SPEED

var is_invincible := false
var player_in_range := false
var slam_timer := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_right: RayCast2D = $RayCastRight
@onready var raycast_left: RayCast2D = $RayCastLeft
@onready var hitbox: Area2D = $Hitbox
@onready var detection_area: Area2D = $DetectionArea
@onready var inv_timer: Timer = $InvincibilityTimer
@onready var attack_timer: Timer = $AttackTimer

func _ready():
	sprite.play("run")

	hitbox.body_entered.connect(_on_body_entered)
	detection_area.body_entered.connect(_on_player_enter)
	detection_area.body_exited.connect(_on_player_exit)

	inv_timer.timeout.connect(_on_inv_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

# ========================
# MACHINE D'ÉTATS
# ========================

func set_state(new_state: State) -> void:
	if state == State.DEAD or new_state == state:
		return

	state = new_state

	match state:
		State.RUN:
			speed = RUN_SPEED
			sprite.play("run")
		State.SPIN:
			speed = SPIN_SPEED
			sprite.play("spin")
		State.SLAM:
			slam_timer = SLAM_COOLDOWN
			velocity.y = SLAM_JUMP_VELOCITY
			apply_camera_shake(0.2, 3.0)
			SoundManager.play("jump")
		State.DEAD:
			pass

func _physics_process(delta):
	if state == State.DEAD:
		return

	_update_state(delta)
	_apply_gravity(delta)
	_apply_movement()
	_handle_wall_collision()

	move_and_slide()

	if state == State.SLAM and is_on_floor():
		_land_slam()

# Transitions déclenchées par la logique (les autres viennent des timers)
func _update_state(delta: float) -> void:
	if state == State.RUN and phase == 1 and player_in_range:
		slam_timer -= delta
		if slam_timer <= 0:
			set_state(State.SLAM)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _apply_movement() -> void:
	if state != State.SLAM:
		if is_on_floor():
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, 10)

	sprite.flip_h = (direction > 0)

func _handle_wall_collision() -> void:
	var hitting_wall := is_on_wall()
	var near_wall := (direction == 1 and raycast_right.is_colliding()) \
		or (direction == -1 and raycast_left.is_colliding())

	if hitting_wall or near_wall:
		direction *= -1
		position.x += direction * 2

		if health < ANGRY_HEALTH:
			apply_camera_shake(0.2, 4.0)

# ========================
# ATTAQUES
# ========================

# Phase 2 : alterne patrouille normale / toupie
func _on_attack_timer_timeout() -> void:
	if phase < 2 or state == State.DEAD:
		return

	match state:
		State.RUN:
			set_state(State.SPIN)
		State.SPIN:
			set_state(State.RUN)

	attack_timer.start(randf_range(SPIN_TOGGLE_MIN, SPIN_TOGGLE_MAX))

func _land_slam() -> void:
	velocity = Vector2.ZERO
	set_state(State.RUN)

	apply_camera_shake(0.4, 6.0)
	_push_player()
	SoundManager.play("stomp")

func _push_player() -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("bounce"):
			body.velocity.y = SLAM_PLAYER_LAUNCH

# ========================
# DÉTECTION DU JOUEUR
# ========================

func _on_player_enter(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_player_exit(body):
	if body.is_in_group("player"):
		player_in_range = false

# ========================
# DÉGÂTS
# ========================

func _on_body_entered(body):
	if state == State.DEAD:
		return

	if body.is_in_group("player"):
		var player := body as CharacterBody2D
		if player == null:
			return

		var player_falling := player.velocity.y > 0
		var vertical_diff := player.global_position.y - global_position.y

		if player_falling and vertical_diff < STOMP_TOLERANCE:
			stomped(player)
		else:
			player.take_damage(1)

func stomped(player):
	if state == State.DEAD or is_invincible:
		return

	take_damage(1, player)

	if player.has_method("bounce"):
		player.bounce()

func take_damage(amount: int, player):
	if is_invincible or state == State.DEAD:
		return

	health -= amount
	_update_phase()

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

func _on_inv_timer_timeout() -> void:
	is_invincible = false

# ========================
# PHASES DE COMBAT
# ========================

func _update_phase() -> void:
	if health <= PHASE2_HEALTH and phase == 1:
		phase = 2

		# Un slam en cours se termine normalement (retour en RUN à l'atterrissage)
		if state != State.SLAM:
			set_state(State.RUN)

		attack_timer.start(randf_range(SPIN_TOGGLE_MIN, SPIN_TOGGLE_MAX))

# ========================
# MORT ET BUTIN
# ========================

func die() -> void:
	if state == State.DEAD:
		return

	set_state(State.DEAD)
	set_physics_process(false)

	visible = false
	set_collision_layer_value(4, false)
	set_collision_mask_value(1, false)

	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	_drop_coins()
	_spawn_victory_tp()

func _drop_coins() -> void:
	if coin_scene == null:
		return

	for i in range(COIN_DROP_COUNT):
		var coin = coin_scene.instantiate()
		coin.name = "boss_coin_" + str(Time.get_ticks_msec()) + "_" + str(i)

		var offset := Vector2(randf_range(-30, 30), randf_range(-10, 10))

		if owner:
			owner.call_deferred("add_child", coin)

		coin.global_position = global_position + Vector2(0, -40) + offset

		if coin.has_method("launch"):
			coin.launch(-1 if randf() < 0.5 else 1)

func _spawn_victory_tp() -> void:
	if victory_tp_scene == null:
		return

	var tp = victory_tp_scene.instantiate()
	tp.global_position = VICTORY_TP_POSITION

	if owner:
		owner.call_deferred("add_child", tp)

	tp.scale = Vector2.ZERO
	var tween = tp.create_tween()
	tween.tween_property(tp, "scale", Vector2.ONE, 0.3)

# ========================
# FX
# ========================

func apply_camera_shake(duration: float, intensity: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(duration, intensity)
