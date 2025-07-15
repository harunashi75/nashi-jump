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
var current_skin := "default"

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
	add_to_group("player")
	set_process_input(false) # Désactiver les entrées au démarrage
	current_skin = GameManager.current_skin
	print("Skin actif :", current_skin)
	var current_scene = get_tree().current_scene.scene_file_path
	if current_scene == "res://Assets/Scenes/level_victory.tscn":
		GameManager.reset_lives_by_difficulty()
		initialize_health()
		GameManager.has_initialized_health = true
	else:
		if not GameManager.has_initialized_health:
			initialize_health()
			GameManager.has_initialized_health = true
		else:
			max_health = GameManager.player_lives
			current_health = GameManager.player_current_health
	if is_instance_valid(health_bar) and health_bar.is_inside_tree():
		health_bar.set_health(current_health, max_health)
	else:
		print("Erreur : health_bar n'est pas dans l'arbre ou est null")
	await get_tree().create_timer(0.1).timeout # Attendre que la scène soit chargée
	set_process_input(true) # Réactiver les entrées

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
			play_skin_anim("jump")
		else:
			play_skin_anim("double_jump")

		jumps_left -= 1
		just_jumped = true
		jump_anim_timer = 0.15

	if is_on_floor():
		jumps_left = max_jumps

# ------------------------
# Gestion Animation
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
		if velocity.y > 0 and sprite.animation != get_skin_anim("fall"):
			play_skin_anim("fall")
	elif velocity.x != 0:
		if sprite.animation != get_skin_anim("run"):
			play_skin_anim("run")
	else:
		if sprite.animation != get_skin_anim("idle"):
			play_skin_anim("idle")

func get_skin_anim(base: String) -> String:
	return "%s_%s" % [base, current_skin]

func play_skin_anim(base: String):
	var anim_name = get_skin_anim(base)

	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		var fallback_anim = "%s_default" % base
		if sprite.sprite_frames.has_animation(fallback_anim):
			sprite.play(fallback_anim)
		else:
			print("Aucune animation trouvée pour :", anim_name, "ni", fallback_anim)

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

func set_lives(amount: int):
	current_health = amount
	max_health = amount

	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

	print("Nouvelles vies définies : %d" % current_health)

func take_damage(amount):
	current_health -= amount
	print("Vies restantes :", current_health)

	play_skin_anim("hit")
	if not hit_sound.playing:
		hit_sound.play()

	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	print("Délai écoulé")
	set_physics_process(true)

	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

	if current_health <= 0:
		if GameManager.difficulty == "fun":
			GameManager.has_died_in_fun_mode = true
		respawn()

	GameManager.player_current_health = current_health

func reset_health():
	current_health = max_health
	if is_instance_valid(health_bar):
		health_bar.set_health(current_health, max_health)

func respawn():
	print("Respawn du joueur...")
	initialize_health()
	set_process_input(false)  # Désactive les inputs pour éviter les appels à _input()

	call_deferred("do_respawn")  # Attend la fin de frame pour changer de scène

func do_respawn():
	if GameManager.victory_checkpoint_enabled:
		LevelManager.load_level_by_path(GameManager.victory_checkpoint_scene_path)
	else:
		LevelManager.load_level_by_path("res://Assets/Scenes/level_1.tscn")

# ------------------------
# Pause Menu
# ------------------------
func _input(event):
	if is_inside_tree() and event.is_action_pressed("pause_menu"):
		GameManager.toggle_pause()
	elif not is_inside_tree():
		print("Erreur : Player n'est pas dans l'arbre lors de la gestion de l'entrée")
