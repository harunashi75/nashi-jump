extends CanvasLayer

@onready var timer_label: Label = $TimerContainer/TimerLabel
@onready var total_coins_label = $TotalCoinsContainer/TotalCoinsLabel

func _process(_delta: float) -> void:
	update_timer()

func update_timer() -> void:
	timer_label.text = TimerManager.get_formatted_time()

func update_coins_display(total_collected: int):
	total_coins_label.text = "%03d" % [total_collected]
