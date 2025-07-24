extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var coin_label: Label = $CoinLabel

func _process(_delta: float) -> void:
	update_timer()

func update_timer() -> void:
	timer_label.text = "Time: " + TimerManager.get_formatted_time()

func update_coins_display() -> void:
	var total_coins: int = GameManager.total_coins_in_level
	var collected_coins: int = 0

	for amount in GameManager.coins_collected.values():
		collected_coins += amount

	coin_label.text = "Coins: %d/%d" % [collected_coins, total_coins]
