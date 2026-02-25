extends CharacterBody2D

# -------- Constantes de Physique (SMW-like) --------

const GRAVITY = 950.0
const LOW_GRAVITY = 575.0
const HIGH_GRAVITY = 1450.0

const BASE_SPEED = 160.0
const MAX_SPEED = 185.0

const ACCELERATION = 1200.0
const DECELERATION = 1000.0
const AIR_ACCELERATION = 650.0

const JUMP_FORCE = -260.0
const RUN_JUMP_BONUS = -35.0

const COYOTE_TIME = 0.12
const JUMP_BUFFER = 0.12

# -------- Variables dynamiques --------

var jumps_left = 1
var max_jumps = 1
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

# -------- Santé et skins --------

var base_health: int = 1
var bonus_health: int = 0
signal health_changed(current_health)
var current_skin := "default"

# -------- Références --------

@onready var sprite: AnimatedSprite2D = $Sprite

var current_state := "idle"

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	DEATH
}

var state: PlayerState = PlayerState.IDLE
var did_double_jump := false

# -------- Initialisation --------

func _ready():
	add_to_group("player")
	set_process_input(false)

	current_skin = SkinManager.current_skin
	print("Skin actif :", current_skin)

	await get_tree().process_frame
	set_process_input(true)

# -------- Boucle physique --------

func _physics_process(delta):
	handle_jump(delta)
	apply_gravity(delta)
	handle_movement(delta)
	update_state()
	update_animation()
	move_and_slide()

# -------- Gravité & Saut --------

func apply_gravity(delta):
	var gravity := GRAVITY

	if velocity.y < 0:
		gravity = LOW_GRAVITY if Input.is_action_pressed("jump") else HIGH_GRAVITY

	velocity.y += gravity * delta

func handle_movement(delta):
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		var accel := ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(
			velocity.x,
			direction * BASE_SPEED,
			accel * delta
		)

		sprite.flip_h = direction < 0
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	if not is_on_floor():
		velocity.x *= 0.97

	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func handle_jump(delta):
	# --- Jump buffer ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)

	# --- Coyote time ---
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		jumps_left = max_jumps
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	# --- Déclenchement du saut ---
	if jump_buffer_timer > 0:
		# Saut sol / coyote
		if coyote_timer > 0:
			_do_jump(false)
			coyote_timer = 0
			jump_buffer_timer = 0
			return

		# Double jump (air)
		if jumps_left > 0:
			jumps_left -= 1
			_do_jump(true)
			jump_buffer_timer = 0

func _do_jump(is_air_jump := false):
	var jump_force := JUMP_FORCE
	if abs(velocity.x) > BASE_SPEED * 0.9:
		jump_force += RUN_JUMP_BONUS

	velocity.y = jump_force
	did_double_jump = is_air_jump
	SoundManager.play("jump")

func update_state():
	if state == PlayerState.DEATH:
		return
	
	if is_on_floor():
		did_double_jump = false

	if not is_on_floor():
		state = PlayerState.JUMP if velocity.y < 0 else PlayerState.FALL
	elif abs(velocity.x) > 10:
		state = PlayerState.RUN
	else:
		state = PlayerState.IDLE

# -------- Animation --------

func update_animation():
	var anim := ""

	match state:
		PlayerState.IDLE:
			anim = "idle"
		PlayerState.RUN:
			anim = "run"
		PlayerState.JUMP:
			anim = "double_jump" if did_double_jump else "jump"
		PlayerState.FALL:
			anim = "fall"
		PlayerState.DEATH:
			anim = "death"

	play_player_anim(anim)

func play_player_anim(anim_name: String):
	if sprite.animation == "%s_%s" % [anim_name, current_skin]:
		return

	var anim := "%s_%s" % [anim_name, current_skin]

	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	else:
		var fallback := "%s_default" % anim_name
		if sprite.sprite_frames.has_animation(fallback):
			sprite.play(fallback)

# -------- Effets --------

func apply_health_bonus():
	if bonus_health == 0:
		bonus_health = 1
		emit_signal("health_changed", get_current_health())

# -------- Santé --------

func get_current_health() -> int:
	return base_health + bonus_health

func take_damage(amount := 1):
	if GameManager.godmode_enabled:
		return

	if bonus_health > 0:
		bonus_health = 0
		emit_signal("health_changed", get_current_health())
	else:
		base_health -= amount
		if base_health <= 0:
			die()
		else:
			emit_signal("health_changed", get_current_health())

	SoundManager.play("hit")

# -------- Respawn & Mort --------

func die():
	if state == PlayerState.DEATH:
		return

	state = PlayerState.DEATH
	GameManager.deaths_count += 1
	GameManager.no_damage_run = false

	set_physics_process(false)
	set_process_input(false)

	play_player_anim("death")

	await sprite.animation_finished
	respawn()

func respawn():
	set_process_input(false)
	call_deferred("load_respawn_scene")

func load_respawn_scene():
	var path := GameManager.levels_checkpoint_scene_path
	if path == "":
		path = GameManager.load_saved_level()

	LevelManager.load_level_by_path(path)
