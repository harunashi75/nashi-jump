extends Node

@onready var pause_menu = $Game/UI/PauseMenu

func _ready():
	GameManager.pause_menu = get_node("Game/UI/PauseMenu")
	GameManager.timer_label = get_node("Game/UI/TimerLabel")

func toggle_pause():
	if pause_menu.visible:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true
