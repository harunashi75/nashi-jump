extends CharacterBody2D

# ------------------------
# Constantes de Physique
# ------------------------
const GRAVITY = 950
const LOW_JUMP_GRAVITY = 1450

const MAX_SPEED = 160
const ACCELERATION = 1200
const DECELERATION = 1000
const AIR_CONTROL = 0.8

const JUMP_FORCE = -260
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
var is_invulnerable = false

var is_shielded: bool = false
var speed_multiplier: float = 1.0
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
@onready var sprite = $AnimatedSprite2D

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
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	if velocity.y < 0 and not Input.is_action_pressed("jump"):
		velocity.y += LOW_JUMP_GRAVITY * delta
	else:
		velocity.y += GRAVITY * delta

func handle_input(delta):
	handle_horizontal(delta)
	handle_jump_logic(delta)

func handle_horizontal(delta):
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		var accel = ACCELERATION
		if not is_on_floor():
			accel *= AIR_CONTROL
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED * speed_multiplier, accel * delta)
		sprite.flip_h = direction < 0
	else:
		var decel = DECELERATION
		if not is_on_floor():
			decel *= AIR_CONTROL
		velocity.x = move_toward(velocity.x, 0, decel * delta)

func handle_jump_logic(delta):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)

	if jump_buffer_timer > 0 and (coyote_timer > 0 or jumps_left > 0):
		velocity.y = JUMP_FORCE * jump_multiplier
		SoundManager.play("jump")
		
		SkinManager.on_player_jump()

		var anim = "jump" if is_on_floor() else "double_jump"
		play_skin_anim(anim)

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
		play_skin_anim("idle")

	if just_jumped:
		jump_anim_timer -= delta
		if jump_anim_timer <= 0:
			just_jumped = false
		return

	if not is_on_floor():
		play_skin_anim("fall")
	elif abs(velocity.x) > 10:
		play_skin_anim("run")
	else:
		play_skin_anim("idle")

func get_skin_anim(base: String) -> String:
	return "%s_%s" % [base, current_skin]

func play_skin_anim(base: String):
	var anim_name = get_skin_anim(base)
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		var fallback = "%s_default" % base
		if sprite.sprite_frames.has_animation(fallback):
			sprite.play(fallback)

# ------------------------
# Effets
# ------------------------
func apply_health_bonus():
	if bonus_health == 0:
		bonus_health = 1
		emit_signal("health_changed", get_current_health())

func apply_shield(duration: float = 6.0):
	is_shielded = true
	print("Shield ON")
	_start_shield_effect(duration)

	var t = get_tree().create_timer(duration)
	await t.timeout

	#is_shielded = false
	#print("Shield OFF")

func _start_shield_effect(duration: float) -> void:
	var original_modulate = sprite.modulate
	var yellow = Color(1, 1, 0)

	var blink_time := 0.1
	var elapsed := 0.0

	while elapsed < duration:
		sprite.modulate = yellow
		await get_tree().create_timer(blink_time).timeout
		
		sprite.modulate = original_modulate
		await get_tree().create_timer(blink_time).timeout
		
		elapsed += blink_time * 2

	is_shielded = false
	print("Shield OFF")
	sprite.modulate = original_modulate

func apply_speed_boost(duration: float = 3.0):
	speed_multiplier = 1.5
	print("Speed Boost ON")

	var t = get_tree().create_timer(duration)
	await t.timeout

	speed_multiplier = 1.0
	print("Speed Boost OFF")

func apply_jump_boost(duration: float = 3.0):
	jump_multiplier = 1.5
	print("Jump Boost ON")

	var t = get_tree().create_timer(duration)
	await t.timeout

	jump_multiplier = 1.0
	print("Jump Boost OFF")

# ------------------------
# Santé
# ------------------------
func get_current_health() -> int:
	return base_health + bonus_health

func take_damage(amount := 1):
	if is_invulnerable or GameManager.godmode_enabled or is_shielded:
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
	GameManager.show_floating_text("-" + str(amount), position + Vector2(0, -40), Color.RED)

# ------------------------
# Respawn & Mort
# ------------------------
func die():
	print("Player est mort")
	SkinManager.add_death_count()
	set_process_input(false)
	set_physics_process(false)

	var anim_name = "death_" + str(current_skin)

	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		var duration = sprite.sprite_frames.get_frame_count(anim_name) / float(sprite.sprite_frames.get_animation_speed(anim_name))
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
	var path = GameManager.levels_checkpoint_scene_path if GameManager.levels_checkpoint_enabled else "res://Assets/Scenes/level_1.tscn"
	LevelManager.load_level_by_path(path)

# ------------------------
# Pics (one-shot)
# ------------------------
func enter_spikes():
	take_damage(1)

func exit_spikes():
	pass
