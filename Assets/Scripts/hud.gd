extends CanvasLayer

@onready var timer_label = $TimerLabel
@onready var coin_label = $CoinLabel

func _process(_delta):
	timer_label.text = "Time: " + TimerManager.get_formatted_time()

func update_coins_display():
	var total = GameManager.total_coins_in_level
	var collected = 0

	for coin in GameManager.coins_collected.values():
		collected += coin

	$CoinLabel.text = "Coins: %d/%d" % [collected, total]
