extends TextureProgressBar

func set_health(current: int, max_health: int):
	max_value = max_health
	value = current
