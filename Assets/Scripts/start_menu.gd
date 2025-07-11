extends Control

@onready var easy_button = $VBoxContainer/Easy
@onready var normal_button = $VBoxContainer/Normal
@onready var hard_button = $VBoxContainer/Hard
@onready var quit_button = $VBoxContainer/Quit
@onready var default_skin_button = $HBoxContainer/DefaultSkin
@onready var gold_skin_button = $HBoxContainer/GoldSkin
@onready var easy_skin_button = $HBoxContainer/EasySkin
@onready var normal_skin_button = $HBoxContainer/NormalSkin
@onready var hard_skin_button = $HBoxContainer/HardSkin
@onready var time_skin_button = $HBoxContainer2/TimeSkin
@onready var time_skin_two_button = $HBoxContainer2/TimeSkinTwo
@onready var music = $StartMusic

func _ready():
	easy_button.pressed.connect(on_easy_pressed)
	normal_button.pressed.connect(on_normal_pressed)
	hard_button.pressed.connect(on_hard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	default_skin_button.pressed.connect(_on_default_skin_pressed)
	gold_skin_button.pressed.connect(_on_gold_skin_pressed)
	easy_skin_button.pressed.connect(on_easy_skin_pressed)
	normal_skin_button.pressed.connect(on_normal_skin_pressed)
	hard_skin_button.pressed.connect(on_hard_skin_pressed)
	time_skin_button.pressed.connect(on_time_skin_pressed)
	time_skin_two_button.pressed.connect(on_time_skin_two_pressed)

	# Désactiver le bouton Gold si le skin n’est pas encore débloqué
	gold_skin_button.disabled = not GameManager.unlocked_skins.get("gold", false)
	easy_skin_button.disabled = not GameManager.unlocked_skins.get("easy", false)
	normal_skin_button.disabled = not GameManager.unlocked_skins.get("normal", false)
	hard_skin_button.disabled = not GameManager.unlocked_skins.get("hard", false)
	time_skin_button.disabled = not GameManager.unlocked_skins.get("time", false)
	time_skin_two_button.disabled = not GameManager.unlocked_skins.get("timetwo", false)

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
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_normal_pressed():
	GameManager.difficulty = "normal"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func on_hard_pressed():
	GameManager.difficulty = "hard"
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	get_tree().change_scene_to_file("res://Assets/Scenes/level_1.tscn")

func _on_quit_pressed():
	print("Quit button pressed!")
	get_tree().quit()

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
