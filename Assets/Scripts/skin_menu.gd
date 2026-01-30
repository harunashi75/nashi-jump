extends Control

@onready var back_button = $Back

@onready var skin_buttons := {
	"default": $Menu_1/DefaultSkin,
	"abyssal": $Menu_1/AbyssalSkin,
	"bee": $Menu_1/BeeSkin,
	"blueember": $Menu_1/BlueEmberSkin,
	"bubblegum": $Menu_1/BubblegumSkin,
	"frost": $Menu_1/FrostSkin,
	"gold": $Menu_1/GoldSkin,
	"hell": $Menu_1/HellSkin,
	"ignatius": $Menu_1/IgnatiusSkin,
	"mystic": $Menu_1/MysticSkin,
	"rainbow": $Menu_1/RainbowSkin,
	"emerald": $Menu_1/EmeraldSkin,
	"void": $Menu_1/VoidSkin
}

func _ready():
	back_button.pressed.connect(_go_back)

	for skin_name in skin_buttons:
		var button: BaseButton = skin_buttons[skin_name]

		button.pressed.connect(func():
			_select_skin(skin_name)
		)

	_update_skin_buttons()
	back_button.grab_focus()

func _select_skin(skin_name: String):
	SkinManager.current_skin = skin_name
	SoundManager.play("confirm")

func _update_skin_buttons():
	for skin_name in skin_buttons:
		var button: BaseButton = skin_buttons[skin_name]
		var unlocked: bool = skin_name == "default" or SkinManager.is_unlocked(skin_name)

		button.disabled = !unlocked
		button.focus_mode = Control.FOCUS_ALL if unlocked else Control.FOCUS_NONE

func _go_back():
	SoundManager.play("confirm")
	LevelManager.return_to_menu()
