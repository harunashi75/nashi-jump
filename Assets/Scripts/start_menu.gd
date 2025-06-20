extends Control

@onready var easy_button = $VBoxContainer/Easy
@onready var normal_button = $VBoxContainer/Normal
@onready var hard_button = $VBoxContainer/Hard
@onready var quit_button = $VBoxContainer/Quit
@onready var music = $StartMusic

func _ready():
	easy_button.pressed.connect(on_easy_pressed)
	normal_button.pressed.connect(on_normal_pressed)
	hard_button.pressed.connect(on_hard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	if music and not music.playing:
		music.play()

func _exit_tree():
	if music:
		music.stop()
		music.stream = null
		music.queue_free()

func on_easy_pressed():
	GameManager.difficulty = "easy"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_fruits()
	GameManager.start_game(GameManager.player_lives)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_normal_pressed():
	GameManager.difficulty = "normal"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_fruits()
	GameManager.start_game(GameManager.player_lives)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_hard_pressed():
	GameManager.difficulty = "hard"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_fruits()
	GameManager.start_game(GameManager.player_lives)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func _on_quit_pressed():
	print("Quit button pressed!")
	get_tree().quit()
