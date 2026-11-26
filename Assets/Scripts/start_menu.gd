extends Control

@onready var play_button: TextureButton = $Menu/Play
@onready var new_game_button: TextureButton = $Menu/NewGame
@onready var skins_button: TextureButton = $Menu/Skins
@onready var quit_button: TextureButton = $Menu/Quit

func _ready() -> void:
	if not SaveManager.has_progress():
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

func _open_skin_menu() -> void:
	SoundManager.play("confirm")
	get_tree().change_scene_to_file("res://Assets/Scenes/skin_menu.tscn")

func _start_game() -> void:
	GameManager.load_run_stats()
	TimerManager.load_current_progress()
	TimerManager.resume_timer()
	var level_path := GameManager.get_saved_level()
	GameManager.set_levels_checkpoint(level_path)
	LevelManager.load_level_by_path(level_path)

func _start_new_game() -> void:
	GameManager.reset_progress()
	TimerManager.start_timer()
	TimerManager.save_current_progress()
	LevelManager.load_level_by_path("res://Assets/Scenes/level_plains.tscn")

func _quit_game() -> void:
	TimerManager.save_current_progress()
	get_tree().quit()
