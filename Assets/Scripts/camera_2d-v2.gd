extends Camera2D

@export var follow_speed := 15.0
@export var deadzone := Vector2(24, 24)
@export var vertical_shift_dist := 40.0 # Jusqu'où la caméra descend pour montrer le bas

@onready var player := get_parent()

var target_pos: Vector2
var current_v_shift := 0.0

func _ready():
	target_pos = global_position
	top_level = true

func _physics_process(delta):
	if not player: return

	# 1. LOGIQUE DE DÉCALAGE VERTICAL (Le secret pour les niveaux carrés)
	# Si le joueur tombe (vitesse Y positive), on descend la cible de la caméra
	if player.velocity.y > 50: 
		current_v_shift = lerp(current_v_shift, vertical_shift_dist, 2.0 * delta)
	# Si le joueur monte, on recentre ou on monte un peu la vue
	elif player.velocity.y < -50:
		current_v_shift = lerp(current_v_shift, -vertical_shift_dist / 2.0, 2.0 * delta)
	else:
		current_v_shift = lerp(current_v_shift, 0.0, 1.0 * delta)

	# 2. Position cible ajustée avec le Shift
	var player_pos = player.global_position
	player_pos.y += current_v_shift # On ajoute le décalage ici
	
	var diff = player_pos - target_pos
	var move_target = target_pos
	
	# 3. Deadzone (ton feeling Nintendo que tu aimes)
	if abs(diff.x) > deadzone.x:
		move_target.x = player_pos.x - (deadzone.x * sign(diff.x))
	if abs(diff.y) > deadzone.y:
		move_target.y = player_pos.y - (deadzone.y * sign(diff.y))

	# 4. Interpolation
	var weight = clamp(follow_speed * delta, 0.0, 1.0)
	target_pos = target_pos.lerp(move_target, weight)

	global_position = target_pos
