extends Control

@onready var time_label = $Stats/Time
@onready var deaths_label = $Stats/Deaths
@onready var coins_label = $Stats/Coins
@onready var skins_label = $Stats/Skins

@onready var restart_button = $Buttons/Restart
@onready var menu_button = $Buttons/MainMenu
@onready var quit_button = $Buttons/Quit

func _ready():
	restart_button.grab_focus()

	time_label.text = "Time: " + TimerManager.format_time(GameManager.run_time)
	deaths_label.text = "Deaths: " + str(GameManager.deaths_count)
	coins_label.text = "Coins: %d / %d" % [
		GameManager.get_total_unique_coins(),
		GameManager.total_possible_coins
	]

	skins_label.text = "Skins unlocked: " + str(GameManager.skins_unlocked_this_run.size())

	restart_button.pressed.connect(_restart)
	menu_button.pressed.connect(_menu)
	quit_button.pressed.connect(get_tree().quit)

func _restart():
	GameManager.reset_progress()
	
	TimerManager.time_elapsed = 0.0 
	TimerManager.running = false
	TimerManager.save_current_progress()
	TimerManager.start_timer()
	
	LevelManager.load_level_by_path("res://Assets/Scenes/level_1.tscn")

func _menu():
	GameManager.reset_progress()
	
	TimerManager.time_elapsed = 0.0 
	TimerManager.running = false
	TimerManager.save_current_progress()
	
	LevelManager.return_to_menu()
