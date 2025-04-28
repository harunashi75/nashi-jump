extends Node

var pause_menu = null
var timer_label = null

var game_timer := 0.0
var timer_active := true
var timer_paused := false
var player_lives = 3

func _ready():
	pass  # NE PAS charger de nodes ici !

func _process(delta):
	if timer_active:
		game_timer += delta
		update_timer_display()

func update_timer_display():
	if timer_label != null:
		var minutes := int(floor(game_timer / 60))
		var seconds := int(game_timer) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func start_game(lives: int):
	player_lives = lives
	game_timer = 0.0
	timer_active = true
	print("Game démarré avec ", lives, " vies.")

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
