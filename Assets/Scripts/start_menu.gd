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
@onready var veryeasy_button = mode_popup.get_node("VBoxContainer/VeryEasy")
@onready var easy_button = mode_popup.get_node("VBoxContainer/Easy")
@onready var normal_button = mode_popup.get_node("VBoxContainer/Normal")
@onready var hard_button = mode_popup.get_node("VBoxContainer/Hard")
@onready var insane_button = mode_popup.get_node("VBoxContainer/Insane")
@onready var jumpgo_button = mode_popup.get_node("VBoxContainer/JumpGo")
@onready var gorun_button = mode_popup.get_node("VBoxContainer/GoRun")

@onready var skin_popup = $SkinPopup
@onready var default_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/DefaultSkin")
@onready var gold_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/GoldSkin")
@onready var emerald_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/EmeraldSkin")
@onready var mystic_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/MysticSkin")
@onready var abyssal_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/AbyssalSkin")
@onready var rainbow_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/RainbowSkin")
@onready var ignatius_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/IgnatiusSkin")
@onready var thecreator_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/TheCreatorSkin")
@onready var whisper_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/WhisperSkin")
@onready var barbie_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/BarbieSkin")
@onready var bloodforged_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/BloodforgedSkin")
@onready var frost_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/FrostSkin")
@onready var murloc_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/MurlocSkin")
@onready var bubblegum_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/BubblegumSkin")
@onready var hell_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/HellSkin")
@onready var void_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/VoidSkin")
@onready var gaga_skin_button = skin_popup.get_node("ScrollContainer/VBoxContainer/GagaSkin")

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

	veryeasy_button.pressed.connect(func(): _start_game("veryeasy", "res://Assets/Scenes/level_1.tscn"))
	easy_button.pressed.connect(func(): _start_game("easy", "res://Assets/Scenes/level_1.tscn"))
	normal_button.pressed.connect(func(): _start_game("normal", "res://Assets/Scenes/level_1.tscn"))
	hard_button.pressed.connect(func(): _start_game("hard", "res://Assets/Scenes/level_1.tscn"))
	insane_button.pressed.connect(func(): _start_game("insane", "res://Assets/Scenes/level_1.tscn"))
	jumpgo_button.pressed.connect(func(): _start_game("jumpgo", "res://Assets/Scenes/level_jump.tscn"))
	gorun_button.pressed.connect(func(): _start_game("gorun", "res://Assets/Scenes/level_run.tscn"))

	default_skin_button.pressed.connect(func(): _select_skin("default"))
	gold_skin_button.pressed.connect(func(): _select_skin("gold"))
	emerald_skin_button.pressed.connect(func(): _select_skin("emerald"))
	mystic_skin_button.pressed.connect(func(): _select_skin("mystic"))
	abyssal_skin_button.pressed.connect(func(): _select_skin("abyssal"))
	rainbow_skin_button.pressed.connect(func(): _select_skin("rainbow"))
	ignatius_skin_button.pressed.connect(func(): _select_skin("ignatius"))
	thecreator_skin_button.pressed.connect(func(): _select_skin("thecreator"))
	whisper_skin_button.pressed.connect(func(): _select_skin("whisper"))
	barbie_skin_button.pressed.connect(func(): _select_skin("barbie"))
	bloodforged_skin_button.pressed.connect(func(): _select_skin("bloodforged"))
	frost_skin_button.pressed.connect(func(): _select_skin("frost"))
	murloc_skin_button.pressed.connect(func(): _select_skin("murloc"))
	bubblegum_skin_button.pressed.connect(func(): _select_skin("bubblegum"))
	hell_skin_button.pressed.connect(func(): _select_skin("hell"))
	void_skin_button.pressed.connect(func(): _select_skin("void"))
	gaga_skin_button.pressed.connect(func(): _select_skin("gaga"))

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
	emerald_skin_button.disabled = !GameManager.unlocked_skins.get("emerald", false)
	mystic_skin_button.disabled = !GameManager.unlocked_skins.get("mystic", false)
	abyssal_skin_button.disabled = !GameManager.unlocked_skins.get("abyssal", false)
	rainbow_skin_button.disabled = !GameManager.unlocked_skins.get("rainbow", false)
	ignatius_skin_button.disabled = !GameManager.unlocked_skins.get("ignatius", false)
	barbie_skin_button.disabled = !GameManager.unlocked_skins.get("barbie", false)
	bloodforged_skin_button.disabled = !GameManager.unlocked_skins.get("bloodforged", false)
	frost_skin_button.disabled = !GameManager.unlocked_skins.get("frost", false)
	void_skin_button.disabled = !GameManager.unlocked_skins.get("void", false)
	bubblegum_skin_button.disabled = !GameManager.unlocked_skins.get("bubblegum", false)
	whisper_skin_button.disabled = !GameManager.unlocked_skins.get("whisper", false)
	hell_skin_button.disabled = !GameManager.unlocked_skins.get("hell", false)

# ------------------------
# UI Popups
# ------------------------
func _show_mode_popup():
	var popup_size = Vector2(180, 120)
	var screen_size = get_viewport().get_visible_rect().size
	var pos = Vector2(
		screen_size.x - popup_size.x - 20,
		(screen_size.y - popup_size.y) / 2.0
	)
	mode_popup.popup(Rect2(pos, popup_size))

func _show_skin_popup():
	var popup_size = Vector2(180, 120)
	var screen_size = get_viewport().get_visible_rect().size
	var pos = Vector2(
		screen_size.x - popup_size.x - 20,
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
