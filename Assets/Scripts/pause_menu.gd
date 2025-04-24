extends Control

@onready var pause_menu = $"."  # Référence au menu pause
@onready var resume_button = $ResumeButton  # Chemin correct vers le bouton Resume
@onready var quit_button = $QuitButton  # Chemin correct vers le bouton Quit
@onready var start_menu_button = $StartMenuButton  # Chemin correct vers le bouton Main Menu
@onready var volume_slider = $VolumeSlider

func _ready():
	print("PauseMenu visible:", pause_menu.visible)
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	start_menu_button.pressed.connect(_on_start_menu_button_pressed)

	# Charger le volume sauvegardé
	var saved_volume = load_volume()
	volume_slider.value = saved_volume
	_on_volume_changed(saved_volume)
	volume_slider.value_changed.connect(_on_volume_changed)

	pause_menu.hide()  # Cache le menu pause au début
	set_process(true)  # Active le process pour surveiller ESC

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
	return 1.0  # Volume par défaut

func _process(_delta):
	var viewport_size = get_viewport_rect().size
	position = (viewport_size - size) / 2

func toggle_pause():
	if pause_menu.visible:
		pause_menu.hide()
		get_tree().paused = false  # Désactive la pause
	else:
		pause_menu.show()
		get_tree().paused = true  # Active la pause

func _on_resume_button_pressed():
	toggle_pause()  # Reprend le jeu

func _on_quit_button_pressed():
	get_tree().quit()  # Quitte le jeu

func _on_start_menu_button_pressed():
	get_tree().paused = false  # Désactive la pause avant de changer de scène
	get_tree().change_scene_to_file("res://Assets/Scenes/start_menu.tscn")
