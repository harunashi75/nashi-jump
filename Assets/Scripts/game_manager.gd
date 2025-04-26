extends Node

@onready var pause_menu = get_node("/root/Main/Game/UI/PauseMenu")
@onready var timer_label = get_node("/root/Main/Game/UI/TimerLabel")  # Remplace ce chemin si besoin

var game_timer := 0.0
var timer_active := true
var timer_paused := false

func _ready():
	game_timer = 0.0
	timer_active = true
	timer_paused = false

func _process(delta):
	if timer_active:
		game_timer += delta
		update_timer_display()

func update_timer_display():
	var minutes := int(floor(game_timer / 60))
	var seconds := int(game_timer) % 60
	timer_label.clear()
	timer_label.append_text("%02d:%02d" % [minutes, seconds])

func stop_timer():
	timer_active = false
	timer_paused = false
	var minutes := int(floor(game_timer / 60))
	var seconds := int(game_timer) % 60
	print("Temps total : %02d:%02d" % [minutes, seconds])

func pause_timer():
	timer_active = false
	timer_paused = true

func resume_timer():
	if timer_paused:
		timer_active = true
		timer_paused = false

func toggle_pause():
	if pause_menu.visible:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_2: teleport_player(Vector2(-475, 0.0))
			KEY_3: teleport_player(Vector2(208, -576))
			KEY_4: teleport_player(Vector2(560, -48))
			KEY_5: teleport_player(Vector2(247, 416))
			KEY_6: teleport_player(Vector2(-855, -560))
			KEY_7: teleport_player(Vector2(797, -576))
			KEY_8: teleport_player(Vector2(-632, 272))
			KEY_9: teleport_player(Vector2(615, 592))
			KEY_KP_1: teleport_player(Vector2(-418, 1328))
			KEY_KP_2: teleport_player(Vector2(616, 1056))
			KEY_KP_3: teleport_player(Vector2(1017, 720))
			KEY_KP_4: teleport_player(Vector2(-8.0, 1168))
			KEY_KP_5: teleport_player(Vector2(-1031, 1200))
			KEY_KP_6: teleport_player(Vector2(865, 1744))
			KEY_KP_7: teleport_player(Vector2(246, 1744))

func teleport_player(position: Vector2):
	var player = get_node_or_null("/root/Main/Game/Player")
	if player:
		player.global_position = position
	else:
		print("Joueur introuvable pour téléportation.")
