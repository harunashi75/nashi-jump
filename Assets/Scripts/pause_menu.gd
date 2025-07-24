extends Control

@onready var pause_menu = $"."
@onready var resume_button = $VBoxContainer/Resume
@onready var quit_button = $VBoxContainer/QuitButton
@onready var start_menu_button = $VBoxContainer/StartMenu
@onready var volume_slider = $VolumeSlider

func _ready():
	print("PauseMenu visible:", pause_menu.visible)
	GameManager.pause_menu = self
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	start_menu_button.pressed.connect(_on_start_menu_button_pressed)

	var saved_volume = load_volume()
	volume_slider.value = saved_volume
	_on_volume_changed(saved_volume)
	volume_slider.value_changed.connect(_on_volume_changed)

	if is_inside_tree():
		pause_menu.hide()
		set_process(true)

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	save_volume(value)

func save_volume(value):
	var config = ConfigFile.new()
	config.set_value("audio", "volume", value)
	config.save("user://settings.cfg")

func load_volume():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value("audio", "volume", 1.0)
	return 1.0

func _process(_delta):
	if is_inside_tree():
		var viewport_size = get_viewport_rect().size
		position = (viewport_size - size) / 2

func _on_resume_button_pressed():
	GameManager.toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_start_menu_button_pressed():
	GameManager.is_game_paused = false
	get_tree().paused = false
	set_process_input(false)
	call_deferred("_go_to_main_menu")

func _go_to_main_menu():
	LevelManager.return_to_menu()
