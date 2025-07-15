extends Control

@onready var play_button = $VBoxContainer/Play
@onready var easy_button = $ModePopup/VBoxContainer/Easy
@onready var normal_button = $ModePopup/VBoxContainer/Normal
@onready var hard_button = $ModePopup/VBoxContainer/Hard
@onready var fun_button = $ModePopup/VBoxContainer/Fun
@onready var quit_button = $VBoxContainer/Quit
@onready var default_skin_button = $SkinPopup/VBoxContainer/DefaultSkin
@onready var gold_skin_button = $SkinPopup/VBoxContainer/GoldSkin
@onready var easy_skin_button = $SkinPopup/VBoxContainer/EasySkin
@onready var normal_skin_button = $SkinPopup/VBoxContainer/NormalSkin
@onready var hard_skin_button = $SkinPopup/VBoxContainer/HardSkin
@onready var skins_button = $VBoxContainer/Skins
@onready var time_skin_button = $SkinPopup/VBoxContainer/TimeSkin
@onready var time_skin_two_button = $SkinPopup/VBoxContainer/TimeSkinTwo
@onready var cyber_skin_button = $SkinPopup/VBoxContainer/CyberSkin
@onready var rokzor_skin_button = $SkinPopup/VBoxContainer/RokzorSkin
@onready var unlock_info_button = $VBoxContainer/HowToUnlock
@onready var unlock_info_panel = $UnlockInfoPanel

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	easy_button.pressed.connect(on_easy_pressed)
	normal_button.pressed.connect(on_normal_pressed)
	hard_button.pressed.connect(on_hard_pressed)
	fun_button.pressed.connect(on_fun_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	default_skin_button.pressed.connect(_on_default_skin_pressed)
	gold_skin_button.pressed.connect(_on_gold_skin_pressed)
	easy_skin_button.pressed.connect(on_easy_skin_pressed)
	normal_skin_button.pressed.connect(on_normal_skin_pressed)
	hard_skin_button.pressed.connect(on_hard_skin_pressed)
	skins_button.pressed.connect(_on_skins_button_pressed)
	time_skin_button.pressed.connect(on_time_skin_pressed)
	time_skin_two_button.pressed.connect(on_time_skin_two_pressed)
	cyber_skin_button.pressed.connect(on_cyber_skin_pressed)
	rokzor_skin_button.pressed.connect(on_rokzor_skin_pressed)
	unlock_info_button.pressed.connect(show_unlock_info)
	unlock_info_panel.hide()

	gold_skin_button.disabled = not GameManager.unlocked_skins.get("gold", false)
	easy_skin_button.disabled = not GameManager.unlocked_skins.get("easy", false)
	normal_skin_button.disabled = not GameManager.unlocked_skins.get("normal", false)
	hard_skin_button.disabled = not GameManager.unlocked_skins.get("hard", false)
	time_skin_button.disabled = not GameManager.unlocked_skins.get("time", false)
	time_skin_two_button.disabled = not GameManager.unlocked_skins.get("timetwo", false)
	cyber_skin_button.disabled = not GameManager.unlocked_skins.get("cyber", false)
	rokzor_skin_button.disabled = not GameManager.unlocked_skins.get("rokzor", false)

func _on_play_button_pressed():
	var button_pos = play_button.get_global_position()
	var button_size = play_button.size
	var popup_size = $ModePopup.size
	var popup_position = button_pos + Vector2(button_size.x + 10, 0)
	$ModePopup.popup(Rect2(popup_position, popup_size))

func on_easy_pressed():
	GameManager.difficulty = "easy"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	start_game_with_scene("res://Assets/Scenes/level_1.tscn")

func on_normal_pressed():
	GameManager.difficulty = "normal"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	start_game_with_scene("res://Assets/Scenes/level_1.tscn")

func on_hard_pressed():
	GameManager.difficulty = "hard"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	start_game_with_scene("res://Assets/Scenes/level_1.tscn")

func on_fun_pressed():
	GameManager.difficulty = "fun"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	start_game_with_scene("res://Assets/Scenes/level_victory.tscn")

func _on_skins_button_pressed():
	var button_pos = skins_button.get_global_position()
	var popup_size = $SkinPopup.size
	var popup_position = button_pos - Vector2(popup_size.x + 10, 0)
	$SkinPopup.popup(Rect2(popup_position, popup_size))

func _on_quit_pressed():
	print("Quit button pressed!")
	get_tree().quit()

func show_unlock_info():
	unlock_info_panel.popup_centered()

func _on_default_skin_pressed():
	GameManager.current_skin = "default"
	print("Skin sélectionné : default")

func _on_gold_skin_pressed():
	GameManager.current_skin = "gold"
	GameManager.save_skin_data()
	print("Skin gold activé.")

func on_easy_skin_pressed():
	GameManager.current_skin = "easy"
	GameManager.save_skin_data()
	print("Skin easy activé.")

func on_normal_skin_pressed():
	GameManager.current_skin = "normal"
	GameManager.save_skin_data()
	print("Skin normal activé.")

func on_hard_skin_pressed():
	GameManager.current_skin = "hard"
	GameManager.save_skin_data()
	print("Skin hard activé.")

func on_time_skin_pressed():
	GameManager.current_skin = "time"
	GameManager.save_skin_data()
	print("Skin time activé.")

func on_time_skin_two_pressed():
	GameManager.current_skin = "timetwo"
	GameManager.save_skin_data()
	print("Skin time two activé.")

func on_cyber_skin_pressed():
	GameManager.current_skin = "cyber"
	GameManager.save_skin_data()
	print("Skin cyber activé.")

func on_rokzor_skin_pressed():
	GameManager.current_skin = "rokzor"
	GameManager.save_skin_data()
	print("Skin rokzor activé.")

func start_game_with_scene(path: String):
	get_tree().get_root().set_process_input(false)
	call_deferred("_start_game", path)

func _start_game(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		print("Erreur lors du changement de scène :", error)
