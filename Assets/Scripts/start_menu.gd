extends Control

# ------------------------
# UI References
# ------------------------
var skin_scroll: ScrollContainer
var skin_vbox: VBoxContainer

@onready var play_button = $Menu/Play
@onready var skins_button = $Menu/Skins
@onready var unlock_info_button = $Menu/UnlockInfo
@onready var quit_button = $Menu/Quit

@onready var unlock_info_panel = $UnlockInfoPanel

@onready var skin_menu = $SkinMenu
@onready var back_button = skin_menu.get_node("ScrollContainer/VBoxContainer/Back")

@onready var unlock_scroll: ScrollContainer = $UnlockInfoPanel/MarginContainer/ScrollContainer
@onready var unlock_text: Label = $UnlockInfoPanel/MarginContainer/ScrollContainer/InfoTextLabel
@onready var back2_button: Button = $UnlockInfoPanel/Back2

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
	"soul": "ScrollContainer/VBoxContainer/SoulforgedSkin"
}

# ------------------------
# Ready
# ------------------------
func _ready():
	play_button.grab_focus()
	_connect_main_buttons()
	_init_skins()
	_update_skin_buttons()
	_connect_focus_sounds()
	_connect_pressed_sounds()

	unlock_info_panel.visible = false
	skin_menu.visible = false
	
	skin_scroll = skin_menu.get_node("ScrollContainer")
	skin_vbox = skin_menu.get_node("ScrollContainer/VBoxContainer")

func _set_main_menu_focus(enabled: bool):
	play_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	skins_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	unlock_info_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	quit_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

# ------------------------
# Button Connections
# ------------------------
func _connect_main_buttons():
	play_button.pressed.connect(_start_game)
	skins_button.pressed.connect(_show_skin_menu)
	back_button.pressed.connect(_hide_skin_menu)
	back_button.focus_entered.connect(func():
		skin_scroll.scroll_vertical = 0
	)

	unlock_info_button.pressed.connect(_show_unlock_info)
	back2_button.pressed.connect(_hide_unlock_info)
	quit_button.pressed.connect(_quit_game)

func _init_skins():
	for skin_name in skin_buttons.keys():
		var button = skin_menu.get_node(skin_buttons[skin_name])

		button.pressed.connect(func(): _select_skin(skin_name))

		button.focus_entered.connect(func():
			_scroll_to_skin_button(button)
		)

func _unhandled_input(event):
	if not unlock_info_panel.visible:
		return

	if event.is_action_pressed("ui_down"):
		unlock_scroll.scroll_vertical += 40
	elif event.is_action_pressed("ui_up"):
		unlock_scroll.scroll_vertical -= 40

func _play_tap():
	SoundManager.play("select")

func _connect_focus_sounds():
	var buttons := [
		play_button,
		skins_button,
		unlock_info_button,
		quit_button,
		back_button,
		back2_button
	]

	for btn in buttons:
		if btn:
			btn.focus_entered.connect(_play_tap)

func _connect_pressed_sounds():
	var buttons := [
		play_button,
		skins_button,
		unlock_info_button,
		quit_button,
		back_button,
		back2_button
	]

	for btn in buttons:
		if btn:
			btn.pressed.connect(func():
				SoundManager.play("confirm")
			)

# ------------------------
# Game Start Logic
# ------------------------
func _start_game():
	GameManager.reset_coins()
	_start_game_with_scene("res://Assets/Scenes/level_world.tscn")

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
	
	await tween.finished
	back_button.grab_focus()

func _hide_skin_menu():
	var tween = create_tween()
	tween.tween_property(skin_menu, "modulate:a", 0.0, 0.25)
	await tween.finished
	
	skin_menu.visible = false
	skins_button.grab_focus()

func _show_unlock_info():
	_set_main_menu_focus(false)

	unlock_info_panel.visible = true
	unlock_info_panel.modulate = Color(1, 1, 1, 0)

	var tween = create_tween()
	tween.tween_property(unlock_info_panel, "modulate:a", 1.0, 0.25)

	await tween.finished

	back2_button.grab_focus()
	unlock_scroll.scroll_vertical = 0

func _hide_unlock_info():
	var tween = create_tween()
	tween.tween_property(unlock_info_panel, "modulate:a", 0.0, 0.25)
	await tween.finished

	unlock_info_panel.visible = false
	_set_main_menu_focus(true)
	unlock_info_button.grab_focus()

func _scroll_to_skin_button(button: Control):
	await get_tree().process_frame
	skin_scroll.ensure_control_visible(button)

# ------------------------
# Quit
# ------------------------
func _quit_game():
	get_tree().quit()
