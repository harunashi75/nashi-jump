extends CharacterBody2D

# ------------------------
# Constantes et Variables
# ------------------------

# Physique
const GRAVITY = 980
const JUMP_FORCE = -350
const MOVE_SPEED = 200
const DECELERATION = 20

var max_jumps = 1
var jumps_left = 2

# Santé
var max_health = 1
var current_health = max_health
var health = 3

# Animation saut
var just_jumped = false
var jump_anim_timer = 0.15

# ------------------------
# Références aux Nodes
# ------------------------
@onready var sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var hit_sound = $HitSound
@onready var health_bar = $HealthBar

# ------------------------
# Ready
# ------------------------
func _ready():
	var current_scene = get_tree().current_scene.scene_file_path

	# Si on est dans le level_victory, reset tout
	if current_scene == "res://Assets/Scenes/level_victory.tscn":
		GameManager.reset_lives_by_difficulty()
		initialize_health()
		GameManager.has_initialized_health = true
	else:
		# Sinon, si pas encore initialisé, on prend les valeurs globales
		if not GameManager.has_initialized_health:
			initialize_health()
			GameManager.has_initialized_health = true
		else:
			# Charger les vies sauvegardées
			max_health = GameManager.player_lives
			current_health = GameManager.player_current_health

	# Met à jour la HealthBar au lancement
	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

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
		jump_sound.play()

		if is_on_floor():
			sprite.play("jump")
		else:
			sprite.play("double_jump")

		jumps_left -= 1
		just_jumped = true
		jump_anim_timer = 0.15

	if is_on_floor():
		jumps_left = max_jumps

# ------------------------
# Gestion Animation
# ------------------------
func handle_animation(delta):
	if just_jumped:
		jump_anim_timer -= delta
		if jump_anim_timer <= 0:
			just_jumped = false
		return

	if not is_on_floor():
		if velocity.y > 0 and sprite.animation != "fall":
			sprite.play("fall")
	elif velocity.x != 0:
		if sprite.animation != "run":
			sprite.play("run")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

# ------------------------
# Gestion Santé
# ------------------------
func initialize_health():
	health = GameManager.player_lives
	max_health = health
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func take_damage(amount):
	current_health -= amount
	print("Vies restantes :", current_health)

	sprite.play("hit")
	if not hit_sound.playing:
		hit_sound.play()

	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	print("Délai écoulé")
	set_physics_process(true)

	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

	if current_health <= 0:
		respawn()

	GameManager.player_current_health = current_health

func reset_health():
	current_health = max_health
	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

func respawn():
	print("Respawn du joueur...")
	initialize_health()
	if GameManager.victory_checkpoint_enabled:
		LevelManager.load_level_by_path(GameManager.victory_checkpoint_scene_path)
	else:
		LevelManager.load_level_by_path("res://Assets/Scenes/level_1.tscn")

# ------------------------
# Pause Menu
# ------------------------
func _input(event):
	if event.is_action_pressed("pause_menu"):
		GameManager.toggle_pause()
