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
@onready var insane_button = mode_popup.get_node("VBoxContainer/Insane")

@onready var skin_popup = $SkinPopup

# ------------------------
# Skin Setup
# ------------------------
var skin_buttons := {
	"default": "ScrollContainer/VBoxContainer/DefaultSkin",
	"gold": "ScrollContainer/VBoxContainer/GoldSkin",
	"emerald": "ScrollContainer/VBoxContainer/EmeraldSkin",
	"mystic": "ScrollContainer/VBoxContainer/MysticSkin",
	"abyssal": "ScrollContainer/VBoxContainer/AbyssalSkin",
	"rainbow": "ScrollContainer/VBoxContainer/RainbowSkin",
	"ignatius": "ScrollContainer/VBoxContainer/IgnatiusSkin",
	"thecreator": "ScrollContainer/VBoxContainer/TheCreatorSkin",
	"whisper": "ScrollContainer/VBoxContainer/WhisperSkin",
	"barbie": "ScrollContainer/VBoxContainer/BarbieSkin",
	"bloodforged": "ScrollContainer/VBoxContainer/BloodforgedSkin",
	"frost": "ScrollContainer/VBoxContainer/FrostSkin",
	"murloc": "ScrollContainer/VBoxContainer/MurlocSkin",
	"bubblegum": "ScrollContainer/VBoxContainer/BubblegumSkin",
	"hell": "ScrollContainer/VBoxContainer/HellSkin",
	"void": "ScrollContainer/VBoxContainer/VoidSkin",
	"gaga": "ScrollContainer/VBoxContainer/GagaSkin",
	"bee": "ScrollContainer/VBoxContainer/BeeSkin",
	"hidden": "ScrollContainer/VBoxContainer/HiddenSkin",
	"bear": "ScrollContainer/VBoxContainer/BearSkin"
}

# ------------------------
# Ready
# ------------------------
func _ready():
	_connect_main_buttons()
	_connect_mode_buttons()
	_init_skins()
	_update_skin_buttons()
	unlock_info_panel.hide()

# ------------------------
# Button Connections
# ------------------------
func _connect_main_buttons():
	play_button.pressed.connect(_show_mode_popup)
	skins_button.pressed.connect(_show_skin_popup)
	unlock_info_button.pressed.connect(_show_unlock_info)
	quit_button.pressed.connect(_quit_game)

func _connect_mode_buttons():
	easy_button.pressed.connect(func(): _start_game("easy", "res://Assets/Scenes/level_1.tscn"))
	normal_button.pressed.connect(func(): _start_game("normal", "res://Assets/Scenes/level_1.tscn"))
	hard_button.pressed.connect(func(): _start_game("hard", "res://Assets/Scenes/level_1.tscn"))
	insane_button.pressed.connect(func(): _start_game("insane", "res://Assets/Scenes/level_1.tscn"))

func _init_skins():
	for skin_name in skin_buttons.keys():
		var button = skin_popup.get_node(skin_buttons[skin_name])
		button.pressed.connect(func(): _select_skin(skin_name))

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
	SkinManager.current_skin = skin_name

func _update_skin_buttons():
	for skin_name in skin_buttons.keys():
		var button = skin_popup.get_node(skin_buttons[skin_name])
		
		if skin_name in ["default", "thecreator", "murloc"]:
			button.disabled = false
		else:
			button.disabled = !SkinManager.unlocked_skins.get(skin_name, false)

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
