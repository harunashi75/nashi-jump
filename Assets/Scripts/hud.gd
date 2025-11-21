extends CanvasLayer

@onready var timer_label: Label = $TimerContainer/TimerLabel
@onready var level_coins_label = $CoinsContainer/LevelCoinsLabel
@onready var total_coins_label = $TotalCoinsContainer/TotalCoinsLabel

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("health_changed", Callable(self, "_on_health_changed"))
		_on_health_changed(player.get_current_health())

func _process(_delta: float) -> void:
	update_timer()

func _on_health_changed(current_health):
	if has_node("HealthDisplay"):
		$HealthDisplay.update_health_display(current_health)

func update_timer() -> void:
	timer_label.text = TimerManager.get_formatted_time()

func update_coins_display(level_collected: int, level_total: int, total_collected: int, total_possible: int):
	level_coins_label.text = "%02d/%d" % [level_collected, level_total]
	total_coins_label.text = "%03d/%d" % [total_collected, total_possible]
