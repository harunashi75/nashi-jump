extends HBoxContainer

@onready var heart_icon: TextureRect = $HeartIcon
@onready var health_label: Label = $HealthLabel

func _ready():
	update_health_display(GameManager.player_current_health)

func update_health_display(health: int):
	health_label.text = "x" + str(health)
