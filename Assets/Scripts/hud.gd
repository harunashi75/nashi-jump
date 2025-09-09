extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var coin_label: Label = $CoinLabel

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

func update_coins_display() -> void:
	var total_coins: int = GameManager.total_coins_in_level
	var collected_coins: int = 0

	for amount in GameManager.coins_collected.values():
		collected_coins += amount

	coin_label.text = "Coins: %d/%d" % [collected_coins, total_coins]
