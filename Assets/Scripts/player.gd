extends CharacterBody2D

# ------------------------
# Constantes de Physique (SMW-like)
# ------------------------
const GRAVITY = 950.0
const LOW_GRAVITY = 575.0      # gravité réduite quand jump maintenu
const HIGH_GRAVITY = 1450.0   # gravité quand jump relâché

const BASE_SPEED = 160.0
const MAX_SPEED = 185.0

const ACCELERATION = 1200.0
const DECELERATION = 1000.0
const AIR_ACCELERATION = 650.0

const JUMP_FORCE = -260.0
const RUN_JUMP_BONUS = -35.0

const COYOTE_TIME = 0.12
const JUMP_BUFFER = 0.12

# ------------------------
# Variables dynamiques
# ------------------------
var jumps_left = 1
var max_jumps = 1
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

var just_jumped = false
var jump_anim_timer = 0.15

var is_shielded: bool = false
var jump_multiplier: float = 1.0

# ------------------------
# Santé et skins
# ------------------------
var base_health: int = 1
var bonus_health: int = 0  # 0 ou 1
signal health_changed(current_health)
var current_skin := "default"

# ------------------------
# Références
# ------------------------
@onready var sprite_base: AnimatedSprite2D = $SpriteBase
@onready var sprite_power: AnimatedSprite2D = $SpritePower

var sprite: AnimatedSprite2D

var current_state := "idle"   # idle / run / jump / fall
var current_power := "none"   # none / shield / speed / jump

# ------------------------
# Initialisation
# ------------------------
func _ready():
	add_to_group("player")
	set_process_input(false)

	current_skin = SkinManager.current_skin
	print("Skin actif :", current_skin)

	await get_tree().process_frame
	set_process_input(true)
	
	sprite = sprite_base
	sprite_base.visible = true
	sprite_power.visible = false

func _show_base_sprite():
	sprite_base.visible = true
	sprite_power.visible = false
	sprite = sprite_base

func _show_power_sprite():
	sprite_base.visible = false
	sprite_power.visible = true
	sprite = sprite_power

# ------------------------
# Boucle physique
# ------------------------
func _physics_process(delta):
	handle_gravity(delta)
	handle_input(delta)
	handle_animation(delta)
	move_and_slide()
	
	_check_idle(delta)

# ------------------------
# Gravité & Saut
# ------------------------
func handle_gravity(delta):
	# Coyote
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	# Gravité variable SMW
	var gravity := GRAVITY

	if velocity.y < 0:
		if Input.is_action_pressed("jump"):
			gravity = LOW_GRAVITY
		else:
			gravity = HIGH_GRAVITY

	velocity.y += gravity * delta

func handle_input(delta):
	handle_horizontal(delta)
	handle_jump_logic(delta)

func handle_horizontal(delta):
	const AIR_DRAG = 0.97

	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		var accel := ACCELERATION if is_on_floor() else AIR_ACCELERATION
		var target_speed := BASE_SPEED

		velocity.x = move_toward(
			velocity.x,
			direction * target_speed,
			accel * delta
		)

		sprite_base.flip_h = direction < 0
		sprite_power.flip_h = sprite_base.flip_h
	else:
		# friction uniquement au sol
		if is_on_floor():
			velocity.x = move_toward(
				velocity.x,
				0,
				DECELERATION * delta
			)
	 
	if not is_on_floor():
		velocity.x *= AIR_DRAG
	
	# soft cap P-speed
	var max_speed := MAX_SPEED
	if abs(velocity.x) > max_speed:
		velocity.x = move_toward(
			velocity.x,
			sign(velocity.x) * max_speed,
			DECELERATION * delta
		)

func handle_jump_logic(delta):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)

	if jump_buffer_timer > 0 and (coyote_timer > 0 or jumps_left > 0):
		var final_jump := JUMP_FORCE * jump_multiplier

		# Bonus de saut si vitesse élevée (SMW)
		if abs(velocity.x) > BASE_SPEED * 0.9:
			final_jump += RUN_JUMP_BONUS

		velocity.y = final_jump
		velocity.x *= 0.88

		SoundManager.play("jump")
		SkinManager.on_player_jump()

		var anim := "jump" if is_on_floor() else "double_jump"
		play_player_anim(anim)

		jumps_left -= 1
		just_jumped = true
		jump_anim_timer = 0.15
		jump_buffer_timer = 0
		coyote_timer = 0

	if is_on_floor():
		jumps_left = max_jumps

func _check_idle(delta):
	var is_idle = (
		velocity.x == 0
		and not Input.is_action_pressed("move_left")
		and not Input.is_action_pressed("move_right")
		and not Input.is_action_pressed("jump")
	)

	if is_idle:
		SkinManager.add_idle_time(delta)
	else:
		SkinManager.reset_idle_timer()

# ------------------------
# Animation
# ------------------------
func handle_animation(delta):
	if current_skin != SkinManager.current_skin:
		current_skin = SkinManager.current_skin
		play_player_anim("idle")

	if just_jumped:
		jump_anim_timer -= delta
		if jump_anim_timer <= 0:
			just_jumped = false
		return

	if not is_on_floor():
		play_player_anim("fall")
	elif abs(velocity.x) > 10:
		play_player_anim("run")
	else:
		play_player_anim("idle")

func play_player_anim(state: String):
	current_state = state

	# --- Sprite BASE (skin) ---
	var base_anim := "%s_%s" % [state, current_skin]
	if sprite_base.sprite_frames.has_animation(base_anim):
		sprite_base.play(base_anim)
	else:
		var fallback := "%s_default" % state
		if sprite_base.sprite_frames.has_animation(fallback):
			sprite_base.play(fallback)

	# --- Sprite POWER (overlay) ---
	if current_power != "none":
		var power_anim := "%s_%s" % [state, current_power]
		if sprite_power.sprite_frames.has_animation(power_anim):
			sprite_power.visible = true
			sprite_power.play(power_anim)
		else:
			sprite_power.visible = false
	else:
		sprite_power.visible = false

func set_power(power: String):
	current_power = power
	sprite_power.visible = power != "none"
	play_player_anim(current_state)

# ------------------------
# Effets
# ------------------------
func apply_health_bonus():
	if bonus_health == 0:
		bonus_health = 1
		emit_signal("health_changed", get_current_health())

func apply_shield(duration: float = 6.0):
	if is_shielded:
		return

	is_shielded = true
	print("Shield ON")

	set_power("shield")

	await get_tree().create_timer(duration).timeout

	is_shielded = false
	set_power("none")
	print("Shield OFF")

func apply_jump_boost(duration: float = 3.0):
	jump_multiplier = 1.5
	print("Jump Boost ON")

	set_power("jump")

	await get_tree().create_timer(duration).timeout

	jump_multiplier = 1.0
	set_power("none")
	print("Jump Boost OFF")

# ------------------------
# Santé
# ------------------------
func get_current_health() -> int:
	return base_health + bonus_health

func take_damage(amount := 1):
	if GameManager.godmode_enabled or is_shielded:
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
	
	GameManager.no_damage_run = false
	SoundManager.play("hit")

# ------------------------
# Respawn & Mort
# ------------------------
func die():
	print("Player est mort")

	set_process_input(false)
	set_physics_process(false)

	sprite_power.visible = false
	sprite_base.visible = true

	var anim_name := "death_%s" % current_skin

	if sprite_base.sprite_frames.has_animation(anim_name):
		sprite_base.play(anim_name)

		var frames := sprite_base.sprite_frames.get_frame_count(anim_name)
		var speed := sprite_base.sprite_frames.get_animation_speed(anim_name)
		var duration := frames / speed

		await get_tree().create_timer(duration + 0.4).timeout
	else:
		await get_tree().create_timer(0.4).timeout

	respawn()

	set_process_input(true)
	set_physics_process(true)

func respawn():
	set_process_input(false)
	call_deferred("load_respawn_scene")

func load_respawn_scene():
	print("Respawn du joueur...")
	var path = GameManager.levels_checkpoint_scene_path if GameManager.levels_checkpoint_enabled else "res://Assets/Scenes/level_world.tscn"
	LevelManager.load_level_by_path(path)
