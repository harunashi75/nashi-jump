extends HBoxContainer

@onready var heart_icon: TextureRect = $HeartIcon
@onready var health_label: Label = $HealthLabel

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player

	if player:
		update_health_display(player.get_current_health())
		player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int) -> void:
	update_health_display(new_health)

func update_health_display(health: int) -> void:
	health_label.text = "x" + str(health)
