extends CanvasLayer

@onready var timer_label = $TimerLabel

func _process(_delta):
	if TimerManager.running:
		timer_label.text = "Time: " + TimerManager.get_formatted_time() + ""
