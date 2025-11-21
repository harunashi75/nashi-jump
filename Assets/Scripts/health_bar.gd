extends HBoxContainer

@onready var heart_icon: TextureRect = $HeartIcon
@onready var health_label: Label = $HealthLabel

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

	if player:
		update_health_display(player.get_current_health())
		player.connect("health_changed", Callable(self, "_on_health_changed"))

func _on_health_changed(new_health):
	update_health_display(new_health)

func update_health_display(health: int):
	health_label.text = "x" + str(health)
