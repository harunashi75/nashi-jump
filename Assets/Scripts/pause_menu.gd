extends Control

@onready var resume_button = $VBoxContainer/Resume
@onready var quit_button = $VBoxContainer/Quit
@onready var menu_button = $VBoxContainer/Menu
@onready var volume_slider = $VolumeSlider

func _input(event):
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		GameManager.toggle_pause()

func _ready():
	GameManager.pause_menu = self
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	_connect_focus_sounds()
	_connect_pressed_sounds()

	var saved_volume = load_volume()
	volume_slider.value = saved_volume
	_on_volume_changed(saved_volume)
	volume_slider.value_changed.connect(_on_volume_changed)

	volume_slider.drag_ended.connect(func(_changed): save_volume(volume_slider.value))

	get_viewport().size_changed.connect(_center)
	_center()
	hide()

func show_pause_menu():
	_center()
	show()
	resume_button.grab_focus()

func hide_pause_menu():
	hide()

func _play_tap():
	SoundManager.play("select")

func _connect_focus_sounds():
	var buttons := [
		resume_button,
		quit_button,
		menu_button
	]

	for btn in buttons:
		if btn:
			btn.focus_entered.connect(_play_tap)

func _connect_pressed_sounds():
	var buttons := [
		resume_button,
		quit_button,
		menu_button
	]

	for btn in buttons:
		if btn:
			btn.pressed.connect(func():
				SoundManager.play("confirm")
			)

func _on_volume_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	# Au clavier/manette il n'y a pas de drag : on sauvegarde si le slider n'est pas glissé
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		save_volume(value)

func save_volume(value: float) -> void:
	SaveManager.set_value("audio", "volume", value)

func load_volume() -> float:
	return SaveManager.get_value("audio", "volume", 1.0)

func _center():
	position = (get_viewport_rect().size - size) / 2

func _on_resume_button_pressed():
	GameManager.toggle_pause()

func _on_quit_button_pressed():
	TimerManager.save_current_progress()
	get_tree().quit()

func _on_menu_button_pressed():
	TimerManager.save_current_progress()
	GameManager.is_game_paused = false
	get_tree().paused = false
	set_process_input(false)
	call_deferred("_go_to_main_menu")

func _go_to_main_menu():
	LevelManager.return_to_menu()
