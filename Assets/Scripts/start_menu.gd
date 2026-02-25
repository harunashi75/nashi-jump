extends Control

@onready var play_button = $Menu/Play
@onready var new_game_button = $Menu/NewGame
@onready var skins_button = $Menu/Skins
@onready var quit_button = $Menu/Quit

func _ready():
	if not FileAccess.file_exists("user://savegame.cfg"):
		play_button.disabled = true
		play_button.focus_mode = Control.FOCUS_NONE
		new_game_button.grab_focus()
	else:
		play_button.disabled = false
		play_button.focus_mode = Control.FOCUS_ALL
		play_button.grab_focus()

	play_button.pressed.connect(_start_game)
	new_game_button.pressed.connect(_start_new_game)
	skins_button.pressed.connect(_open_skin_menu)
	quit_button.pressed.connect(_quit_game)

func _open_skin_menu():
	SoundManager.play("confirm")
	get_tree().change_scene_to_file("res://Assets/Scenes/skin_menu.tscn")

func _start_game():
	TimerManager.load_current_progress()
	TimerManager.resume_timer()
	var level_path := GameManager.load_saved_level()
	LevelManager.load_level_by_path(level_path)

func _start_new_game():
	GameManager.reset_progress()
	GameManager.reset_coins()
	TimerManager.start_timer()
	TimerManager.save_current_progress()
	LevelManager.load_level_by_path("res://Assets/Scenes/level_1.tscn")

func _quit_game():
	TimerManager.save_current_progress()
	get_tree().quit()
