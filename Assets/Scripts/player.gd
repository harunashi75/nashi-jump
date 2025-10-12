extends CharacterBody2D

# ------------------------
# Constantes et Variables
# ------------------------
const GRAVITY = 980
const DEFAULT_MOVE_SPEED = 160
const DEFAULT_JUMP_FORCE = -310
const DECELERATION = 20

var MOVE_SPEED = DEFAULT_MOVE_SPEED
var JUMP_FORCE = DEFAULT_JUMP_FORCE
var max_jumps = 1
var jumps_left = 2

var current_health : int
var max_health : int
signal health_changed(current_health, max_health)

var spikes_overlap_count: int = 0
var spikes_damage_timer: Timer

var just_jumped = false
var is_invulnerable = false
var jump_anim_timer = 0.15
var current_skin := "default"

var camera: Camera2D = null

# ------------------------
# Références aux Nodes
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
	
	spikes_overlap_count = 0
	spikes_damage_timer = Timer.new()
	spikes_damage_timer.wait_time = 0.5
	spikes_damage_timer.one_shot = false
	add_child(spikes_damage_timer)
	spikes_damage_timer.timeout.connect(_on_spikes_damage)

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
		velocity.x = direction * MOVE_SPEED
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)

func handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_FORCE
		SoundManager.play("jump")

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
	emit_signal("health_changed", current_health, max_health)

func set_lives(amount: int):
	current_health = amount
	max_health = amount
	print("Nouvelles vies définies : %d" % current_health)
	GameManager.emit_signal("health_changed", current_health, max_health)

func take_damage(amount):
	if GameManager.godmode_enabled or is_invulnerable:
		return

	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	GameManager.player_current_health = current_health
	
	print("Vies restantes :", current_health)
	SoundManager.play("hit")
	
	GameManager.show_floating_text("-" + str(amount), position + Vector2(0, -40), Color.RED)

	start_invulnerability(1.0)

	if current_health <= 0:
		die()

# ------------------------
# Invulnérabilité
# ------------------------
func start_invulnerability(duration: float):
	if is_invulnerable:
		return

	is_invulnerable = true

	var blink_timer = 0.1
	var elapsed = 0.0
	while elapsed < duration:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(blink_timer).timeout
		elapsed += blink_timer

	sprite.visible = true
	is_invulnerable = false

# ------------------------
# Pics et Respawn
# ------------------------
func enter_spikes():
	spikes_overlap_count += 1
	if spikes_overlap_count == 1:
		if spikes_damage_timer != null:
			spikes_damage_timer.start()
			_on_spikes_damage()

func exit_spikes():
	if spikes_overlap_count > 0:
		spikes_overlap_count -= 1
		if spikes_overlap_count == 0:
			if spikes_damage_timer != null:
				spikes_damage_timer.stop()

func _on_spikes_damage():
	take_damage(1)

func reset_health():
	current_health = max_health
	GameManager.emit_signal("health_changed", current_health, max_health)

# ------------------------
# Respawn
# ------------------------
func die():
	print("Player est mort")
	set_process_input(false)
	set_physics_process(false)
	
	SoundManager.play("death")

	var anim_name = "death_" + str(current_skin)

	if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
		var duration = $AnimatedSprite2D.sprite_frames.get_frame_count(anim_name) / float($AnimatedSprite2D.sprite_frames.get_animation_speed(anim_name))
		await get_tree().create_timer(duration + 0.5).timeout
	else:
		print("Animation de mort manquante pour le skin :", current_skin)
		await get_tree().create_timer(0.5).timeout

	respawn()
	set_process_input(true)
	set_physics_process(true)

func respawn():
	GameManager.reset_lives_by_difficulty()
	initialize_health()
	set_process_input(false)
	call_deferred("load_respawn_scene")

func load_respawn_scene():
	print("Respawn du joueur...")
	var current_scene = get_tree().current_scene.scene_file_path
	if current_scene == "res://Assets/Scenes/level_jump.tscn":
		LevelManager.load_level_by_path(current_scene)
		return
	
	var path = GameManager.levels_checkpoint_scene_path if GameManager.levels_checkpoint_enabled else "res://Assets/Scenes/level_1.tscn"
	LevelManager.load_level_by_path(path)
