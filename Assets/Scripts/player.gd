extends CharacterBody2D

# ------------------------
# Constantes et Variables
# ------------------------
const GRAVITY = 980
const DEFAULT_MOVE_SPEED = 180
const DEFAULT_JUMP_FORCE = -310
const DECELERATION = 20

var MOVE_SPEED = DEFAULT_MOVE_SPEED
var JUMP_FORCE = DEFAULT_JUMP_FORCE
var max_jumps = 1
var jumps_left = 2

var current_health : int
var max_health : int

var just_jumped = false
var jump_anim_timer = 0.15
var current_skin := "default"

# ------------------------
# Références aux Nodes
# ------------------------
@onready var sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var hit_sound = $HitSound
@onready var health_bar = $HealthBar

# ------------------------
# Initialisation
# ------------------------
func _ready():
	add_to_group("player")
	set_process_input(false)
	current_skin = GameManager.current_skin
	var current_scene = get_tree().current_scene.scene_file_path

	if current_scene == "res://Assets/Scenes/level_victory.tscn":
		GameManager.reset_lives_by_difficulty()
		initialize_health()
	else:
		if not GameManager.has_initialized_health:
			initialize_health()
		else:
			max_health = GameManager.player_lives
			current_health = GameManager.player_current_health

	GameManager.has_initialized_health = true
	update_health_bar()

	await get_tree().create_timer(0.1).timeout
	set_process_input(true)

# ------------------------
# Physique principale
# ------------------------
func _physics_process(delta):
	apply_gravity(delta)
	handle_input()
	handle_animation(delta)
	move_and_slide()

# ------------------------
# Fonctions Physiques
# ------------------------
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func handle_input():
	handle_movement()
	handle_jump()

func handle_movement():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * MOVE_SPEED * GameManager.speed_multiplier
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)

func handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_FORCE
		jump_sound.play()

		var anim = "jump" if is_on_floor() else "double_jump"
		play_skin_anim(anim)

		jumps_left -= 1
		just_jumped = true
		jump_anim_timer = 0.15

	if is_on_floor():
		jumps_left = max_jumps

# ------------------------
# Animation
# ------------------------
func handle_animation(delta):
	if current_skin != GameManager.current_skin:
		current_skin = GameManager.current_skin
		play_skin_anim("idle")

	if just_jumped:
		jump_anim_timer -= delta
		if jump_anim_timer <= 0:
			just_jumped = false
		return

	if not is_on_floor():
		play_skin_anim("fall")
	elif velocity.x != 0:
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
# Santé
# ------------------------
func initialize_health():
	current_health = GameManager.player_lives
	max_health = current_health
	update_health_bar()

func set_lives(amount: int):
	current_health = amount
	max_health = amount
	update_health_bar()

func take_damage(amount):
	if GameManager.godmode_enabled:
		return

	current_health -= amount
	play_skin_anim("hit")
	if not hit_sound.playing:
		hit_sound.play()

	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	set_physics_process(true)

	update_health_bar()
	GameManager.player_current_health = current_health

	if current_health <= 0:
		if GameManager.difficulty == "fun":
			GameManager.has_died_in_fun_mode = true
		respawn()

func reset_health():
	current_health = max_health
	update_health_bar()

func update_health_bar():
	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

# ------------------------
# Respawn
# ------------------------
func respawn():
	GameManager.reset_lives_by_difficulty()
	initialize_health()
	set_process_input(false)
	call_deferred("load_respawn_scene")

func load_respawn_scene():
	var path = GameManager.victory_checkpoint_scene_path if GameManager.victory_checkpoint_enabled else "res://Assets/Scenes/level_1.tscn"
	LevelManager.load_level_by_path(path)

# ------------------------
# Pause
# ------------------------
func _input(event):
	if event.is_action_pressed("pause_menu"):
		GameManager.toggle_pause()
