extends Control

# ------------------------
# UI References
# ------------------------
@onready var play_button = $Menu/Play
@onready var skins_button = $Menu/Skins
@onready var unlock_info_button = $Menu/UnlockInfo
@onready var quit_button = $Menu/Quit

@onready var unlock_info_panel = $UnlockInfoPanel
@onready var back_button3 = unlock_info_panel.get_node("Back")

@onready var skin_menu = $SkinMenu
@onready var back_button = skin_menu.get_node("ScrollContainer/VBoxContainer/Back")

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
	"bloodforged": "ScrollContainer/VBoxContainer/BloodforgedSkin",
	"frost": "ScrollContainer/VBoxContainer/FrostSkin",
	"bubblegum": "ScrollContainer/VBoxContainer/BubblegumSkin",
	"hell": "ScrollContainer/VBoxContainer/HellSkin",
	"void": "ScrollContainer/VBoxContainer/VoidSkin",
	"gaga": "ScrollContainer/VBoxContainer/GagaSkin",
	"bee": "ScrollContainer/VBoxContainer/BeeSkin",
	"hidden": "ScrollContainer/VBoxContainer/HiddenSkin",
	"murloc": "ScrollContainer/VBoxContainer/MurlocSkin",
	"soul": "ScrollContainer/VBoxContainer/SoulforgedSkin"
}

# ------------------------
# Ready
# ------------------------
func _ready():
	_connect_main_buttons()
	_init_skins()
	_update_skin_buttons()

	unlock_info_panel.visible = false
	skin_menu.visible = false

# ------------------------
# Button Connections
# ------------------------
func _connect_main_buttons():
	play_button.pressed.connect(_start_game)
	skins_button.pressed.connect(_show_skin_menu)
	back_button.pressed.connect(_hide_skin_menu)
	unlock_info_button.pressed.connect(_show_unlock_info)
	back_button3.pressed.connect(_hide_unlock_info)
	quit_button.pressed.connect(_quit_game)

func _init_skins():
	for skin_name in skin_buttons.keys():
		var button = skin_menu.get_node(skin_buttons[skin_name])
		button.pressed.connect(func(): _select_skin(skin_name))

# ------------------------
# Game Start Logic
# ------------------------
func _start_game():
	GameManager.reset_coins()
	TimerManager.start_timer()
	_start_game_with_scene("res://Assets/Scenes/level_1.tscn")

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
		var button = skin_menu.get_node(skin_buttons[skin_name])
		
		if skin_name in ["default", "murloc"]:
			button.disabled = false
		else:
			button.disabled = !SkinManager.unlocked_skins.get(skin_name, false)

# ------------------------
# UI Popups
# ------------------------
func _show_skin_menu():
	skin_menu.visible = true
	skin_menu.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(skin_menu, "modulate:a", 1.0, 0.25)

func _hide_skin_menu():
	var tween = create_tween()
	tween.tween_property(skin_menu, "modulate:a", 0.0, 0.25)
	await tween.finished
	skin_menu.visible = false

func _show_unlock_info():
	unlock_info_panel.visible = true
	unlock_info_panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(unlock_info_panel, "modulate:a", 1.0, 0.25)

func _hide_unlock_info():
	var tween = create_tween()
	tween.tween_property(unlock_info_panel, "modulate:a", 0.0, 0.25)
	await tween.finished
	unlock_info_panel.visible = false

# ------------------------
# Quit
# ------------------------
func _quit_game():
	get_tree().quit()
