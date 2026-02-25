extends Camera2D

@export var follow_speed := 15.0
@export var deadzone := Vector2(24, 24)
@export var vertical_shift_dist := 40.0

@onready var player := get_parent()

var target_pos: Vector2
var current_v_shift := 0.0

func _ready():
	target_pos = global_position
	top_level = true

func _physics_process(delta):
	if not player: return

	if player.velocity.y > 50: 
		current_v_shift = lerp(current_v_shift, vertical_shift_dist, 2.0 * delta)
	elif player.velocity.y < -50:
		current_v_shift = lerp(current_v_shift, -vertical_shift_dist / 2.0, 2.0 * delta)
	else:
		current_v_shift = lerp(current_v_shift, 0.0, 1.0 * delta)

	var player_pos = player.global_position
	player_pos.y += current_v_shift
	
	var diff = player_pos - target_pos
	var move_target = target_pos

	if abs(diff.x) > deadzone.x:
		move_target.x = player_pos.x - (deadzone.x * sign(diff.x))
	if abs(diff.y) > deadzone.y:
		move_target.y = player_pos.y - (deadzone.y * sign(diff.y))

	var weight = clamp(follow_speed * delta, 0.0, 1.0)
	target_pos = target_pos.lerp(move_target, weight)

	global_position = target_pos
