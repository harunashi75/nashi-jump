extends Control

@onready var easy_button = $VBoxContainer/Easy
@onready var normal_button = $VBoxContainer/Normal
@onready var hard_button = $VBoxContainer/Hard
@onready var quit_button = $VBoxContainer/Quit

func _ready():
	easy_button.pressed.connect(on_easy_pressed)
	normal_button.pressed.connect(on_normal_pressed)
	hard_button.pressed.connect(on_hard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func on_easy_pressed():
	GameManager.start_game(10)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_normal_pressed():
	GameManager.start_game(3)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_hard_pressed():
	GameManager.start_game(1)
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func _on_quit_pressed():
	print("Quit button pressed!")  # Vérifie si ça s'affiche dans la console
	get_tree().quit()
