extends Node

@onready var pause_menu = get_node("/root/Main/Game/UI/PauseMenu")
@onready var timer_label = get_node("/root/Main/Game/UI/TimerLabel")  # Remplace ce chemin si besoin

var game_timer := 0.0
var timer_active := true

func _ready():
	game_timer = 0.0
	timer_active = true

func _process(delta):
	if timer_active:
		game_timer += delta
		update_timer_display()

func update_timer_display():
	var minutes = int(game_timer) / 60
	var seconds = int(game_timer) % 60
	timer_label.clear()
	timer_label.append_text("%02d:%02d" % [minutes, seconds])

func stop_timer():
	timer_active = false
	var minutes = int(game_timer) / 60
	var seconds = int(game_timer) % 60
	print("Temps total : %02d:%02d" % [minutes, seconds])

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
			KEY_KP_1: teleport_player(Vector2(-418, 1328))
			KEY_KP_2: teleport_player(Vector2(616, 1056))
			KEY_KP_3: teleport_player(Vector2(1017, 720))
			KEY_KP_4: teleport_player(Vector2(-8.0, 1168))
			KEY_KP_5: teleport_player(Vector2(-1031, 1200))

func teleport_player(position: Vector2):
	var player = get_node_or_null("/root/Main/Game/Player")
	if player:
		player.global_position = position
	else:
		print("Joueur introuvable pour téléportation.")
