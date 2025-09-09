extends Node2D

@export var float_speed: float = 40.0
@export var duration: float = 1.0

var time_passed := 0.0

func _process(delta):
	time_passed += delta
	position.y -= float_speed * delta

	if time_passed >= duration:
		queue_free()
