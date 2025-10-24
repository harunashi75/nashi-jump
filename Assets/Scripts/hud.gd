extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var coin_label: Label = $CoinLabel
@onready var coin_label_level: Label = $CoinLevelLabel

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("health_changed", Callable(self, "_on_health_changed"))
		_on_health_changed(player.current_health, player.max_health)

func _process(_delta: float) -> void:
	update_timer()

func _on_health_changed(current, max_health):
	$HealthBar.set_health(current, max_health)

func update_timer() -> void:
	timer_label.text = "Time: " + TimerManager.get_formatted_time()

func update_coins_display(total_collected: int, level_collected: int, total_coins_in_level: int) -> void:
	coin_label.text = "Total Coins: %d/%d" % [total_collected, 290]
	coin_label_level.text = "Level Coins: %d/%d" % [level_collected, total_coins_in_level]
