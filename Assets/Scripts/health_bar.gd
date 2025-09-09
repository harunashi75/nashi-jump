extends TextureProgressBar

func set_health(current: int, max_health: int):
	max_value = max_health
	value = current

	if has_node("HealthLabel"):
		$HealthLabel.text = str(current, "/", max_health)
