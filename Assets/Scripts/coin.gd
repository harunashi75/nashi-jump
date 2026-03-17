extends Area2D

@export var coin_name: String = "Coin"
@export var value: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $RayCast2D

var collected: bool = false

# --- mouvement pour coin droppée ---
var velocity: Vector2 = Vector2.ZERO
var fall_gravity: float = 900.0
var is_dropped: bool = false
var bounce_damping: float = 0.5

func _ready():
	_initialize_coin()

func _physics_process(delta):
	if not is_dropped:
		return

	# --- gravité ---
	velocity.y += fall_gravity * delta

	# --- déplacement ---
	var next_pos = position + velocity * delta

	# --- vérification collisions murs latéraux ---
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, Vector2(next_pos.x, position.y))
	query.exclude = [self.get_rid()]
	query.collision_mask = 2
	var collision = space.intersect_ray(query)
	if collision:
		velocity.x = -velocity.x * bounce_damping
		next_pos.x = position.x + velocity.x * delta

	# --- mise à jour position ---
	position = next_pos

	# --- vérification sol ---
	if ground_check.is_colliding():
		velocity.y = -velocity.y * bounce_damping
		if abs(velocity.y) < 20:
			velocity.y = 0
			is_dropped = false

func _initialize_coin():
	var level_name = get_tree().current_scene.name
	var coin_id = name

	if GameManager.is_coin_already_collected(level_name, coin_id):
		queue_free()
		return

	sprite.play("default")
	connect("body_entered", Callable(self, "_on_body_entered"))

func launch(direction: float):
	is_dropped = true

	velocity.x = direction * randf_range(80, 120)
	velocity.y = -220

func _on_body_entered(body: Node):
	if collected:
		return
	if not body.is_in_group("player"):
		return

	collected = true
	_collect_coin()

func _collect_coin():
	SoundManager.play("coin")
	GameManager.mark_coin_collected(
		get_tree().current_scene.name,
		name
	)

	hide()
	await get_tree().create_timer(0.2).timeout
	queue_free()
