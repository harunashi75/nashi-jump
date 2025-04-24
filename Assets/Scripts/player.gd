extends CharacterBody2D

# Physique
var gravity = 980
var jump_force = -350
var max_jumps = 1
var jumps_left = 2
var max_health = 1
var current_health = max_health

# Timer pour éviter de switch direct vers "fall"
var just_jumped = false
var jump_anim_timer = 0.15  # Durée pendant laquelle on bloque l'animation "fall"

# Références
@onready var sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound
@onready var health_bar = $"/root/Main/Game/UI/HealthBar"
@onready var hit_sound = $HitSound

func _physics_process(delta):
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	_handle_animations(delta)
	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_jump():
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_force
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

func _handle_movement():
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * 200
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 20)

func _handle_animations(delta):
	if just_jumped:
		jump_anim_timer -= delta
		if jump_anim_timer <= 0:
			just_jumped = false
		return  # On bloque l'anim ici le temps du saut

	if not is_on_floor():
		if velocity.y > 0 and sprite.animation != "fall":
			sprite.play("fall")
	elif velocity.x != 0:
		if sprite.animation != "run":
			sprite.play("run")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

# Pause menu
func _input(event):
	if event.is_action_pressed("pause_menu"):
		var game_manager = get_node("/root/Main")
		if game_manager:
			game_manager.toggle_pause()
		else:
			print("Erreur: Main introuvable!")

# Gestion des dégâts
func take_damage(amount):
	current_health -= amount
	print("Vies restantes :", current_health)

	sprite.play("hit")
	
	if not hit_sound.playing:
		hit_sound.play()
	
	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	set_physics_process(true)

	health_bar.value = current_health

	if current_health <= 0:
		respawn()

# Respawn
func respawn():
	print("Respawn du joueur...")
	current_health = max_health
	health_bar.value = max_health
	global_position = Vector2(0, 0)

# Remettre la vie au max
func reset_health():
	current_health = max_health
	health_bar.value = max_health
