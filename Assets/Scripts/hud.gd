extends CanvasLayer

@onready var timer_label = $TimerLabel
@onready var fruit_label = $FruitLabel

func _process(_delta):
	if TimerManager.running:
		timer_label.text = "Time: " + TimerManager.get_formatted_time() + ""

func update_fruits_display():
	var total = GameManager.total_fruits_in_level
	var collected = 0

	for fruit in GameManager.fruits_collected.values():
		collected += fruit

	$FruitLabel.text = "Fruits : %d / %d" % [collected, total]
