extends Control

# ------------------------
# UI References
# ------------------------
@onready var play_button = $VBoxContainer/Play
@onready var skins_button = $VBoxContainer/Skins
@onready var unlock_info_button = $VBoxContainer/UnlockInfo
@onready var quit_button = $VBoxContainer/Quit
@onready var unlock_info_panel = $UnlockInfoPanel

@onready var mode_popup = $ModePopup
@onready var easy_button = mode_popup.get_node("VBoxContainer/Easy")
@onready var normal_button = mode_popup.get_node("VBoxContainer/Normal")
@onready var hard_button = mode_popup.get_node("VBoxContainer/Hard")
@onready var fun_button = mode_popup.get_node("VBoxContainer/Fun")
@onready var arena_button = mode_popup.get_node("VBoxContainer/Arena")
@onready var jumpgo_button = mode_popup.get_node("VBoxContainer/JumpGo")

@onready var skin_popup = $SkinPopup
@onready var default_skin_button = skin_popup.get_node("VBoxContainer/DefaultSkin")
@onready var gold_skin_button = skin_popup.get_node("VBoxContainer/GoldSkin")
@onready var leaf_skin_button = skin_popup.get_node("VBoxContainer/LeafSkin")
@onready var mystic_skin_button = skin_popup.get_node("VBoxContainer/MysticSkin")
@onready var abyssal_skin_button = skin_popup.get_node("VBoxContainer/AbyssalSkin")
@onready var time_skin_button = skin_popup.get_node("VBoxContainer/TimeSkin")
@onready var time_skin_two_button = skin_popup.get_node("VBoxContainer/TimeSkinTwo")
@onready var rainbow_skin_button = skin_popup.get_node("VBoxContainer/RainbowSkin")
@onready var rokzor_skin_button = skin_popup.get_node("VBoxContainer/RokzorSkin")
@onready var vagabond_skin_button = skin_popup.get_node("VBoxContainer/VagabondSkin")

# ------------------------
# Ready
# ------------------------
func _ready():
	_connect_buttons()
	_update_skin_buttons()
	unlock_info_panel.hide()

# ------------------------
# Button Connections
# ------------------------
func _connect_buttons():
	play_button.pressed.connect(_show_mode_popup)
	skins_button.pressed.connect(_show_skin_popup)
	unlock_info_button.pressed.connect(_show_unlock_info)
	quit_button.pressed.connect(_quit_game)

	easy_button.pressed.connect(func(): _start_game("easy", "res://Assets/Scenes/level_1.tscn"))
	normal_button.pressed.connect(func(): _start_game("normal", "res://Assets/Scenes/level_1.tscn"))
	hard_button.pressed.connect(func(): _start_game("hard", "res://Assets/Scenes/level_1.tscn"))
	fun_button.pressed.connect(func(): _start_game("fun", "res://Assets/Scenes/level_victory.tscn"))
	arena_button.pressed.connect(func(): _start_game("arena", "res://Assets/Scenes/level_arena.tscn"))
	jumpgo_button.pressed.connect(func(): _start_game("jumpgo", "res://Assets/Scenes/level_jump.tscn"))

	default_skin_button.pressed.connect(func(): _select_skin("default"))
	gold_skin_button.pressed.connect(func(): _select_skin("gold"))
	leaf_skin_button.pressed.connect(func(): _select_skin("leaf"))
	mystic_skin_button.pressed.connect(func(): _select_skin("mystic"))
	abyssal_skin_button.pressed.connect(func(): _select_skin("abyssal"))
	time_skin_button.pressed.connect(func(): _select_skin("time"))
	time_skin_two_button.pressed.connect(func(): _select_skin("timetwo"))
	rainbow_skin_button.pressed.connect(func(): _select_skin("rainbow"))
	rokzor_skin_button.pressed.connect(func(): _select_skin("rokzor"))
	vagabond_skin_button.pressed.connect(func(): _select_skin("vagabond"))

# ------------------------
# Game Start Logic
# ------------------------
func _start_game(difficulty: String, scene_path: String):
	GameManager.difficulty = difficulty
	GameManager.reset_lives_by_difficulty()
	GameManager.reset_coins()
	GameManager.start_game(GameManager.player_lives)
	TimerManager.start_timer()
	_start_game_with_scene(scene_path)

func _start_game_with_scene(path: String):
	get_tree().get_root().set_process_input(false)
	call_deferred("_load_scene", path)

func _load_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		print("Erreur de changement de scène :", error)

# ------------------------
# Skin Logic
# ------------------------
func _select_skin(skin_name: String):
	GameManager.current_skin = skin_name
	GameManager.save_skin_data()

# ------------------------
# Skin Unlock Buttons
# ------------------------
func _update_skin_buttons():
	gold_skin_button.disabled = !GameManager.unlocked_skins.get("gold", false)
	leaf_skin_button.disabled = !GameManager.unlocked_skins.get("leaf", false)
	mystic_skin_button.disabled = !GameManager.unlocked_skins.get("mystic", false)
	abyssal_skin_button.disabled = !GameManager.unlocked_skins.get("abyssal", false)
	time_skin_button.disabled = !GameManager.unlocked_skins.get("time", false)
	time_skin_two_button.disabled = !GameManager.unlocked_skins.get("timetwo", false)
	rainbow_skin_button.disabled = !GameManager.unlocked_skins.get("rainbow", false)
	rokzor_skin_button.disabled = !GameManager.unlocked_skins.get("rokzor", false)
	vagabond_skin_button.disabled = !GameManager.unlocked_skins.get("vagabond", false)

# ------------------------
# UI Popups
# ------------------------
func _show_mode_popup():
	var popup_size = Vector2(300, 200)
	var screen_size = get_viewport().get_visible_rect().size
	var pos = Vector2(
		screen_size.x - popup_size.x - 50,  # 50px de marge à droite
		(screen_size.y - popup_size.y) / 2.0  # Centré verticalement
	)
	mode_popup.popup(Rect2(pos, popup_size))

func _show_skin_popup():
	var popup_size = Vector2(300, 200)
	var screen_size = get_viewport().get_visible_rect().size
	var pos = Vector2(
		screen_size.x - popup_size.x - 50,
		(screen_size.y - popup_size.y) / 2.0
	)
	skin_popup.popup(Rect2(pos, popup_size))

func _show_unlock_info():
	unlock_info_panel.popup_centered()

# ------------------------
# Quit
# ------------------------
func _quit_game():
	get_tree().quit()
