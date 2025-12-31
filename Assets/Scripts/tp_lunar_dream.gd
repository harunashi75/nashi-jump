extends Area2D

@export var next_level_path: String = "res://Assets/Scenes/level_lunar_dream.tscn"
@export var required_coins: int = 100

@onready var bubble: Control = $Bubble
@onready var hint_label: Label = $Bubble/HintLabel

var player_inside := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	bubble.visible = false
	bubble.modulate.a = 0.0

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("enter"):
		if _has_enough_coins():
			call_deferred("_deferred_load_next_level")
		else:
			_update_hint_text() # au cas où les coins ont changé

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		_update_hint_text()
		_show_bubble()

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		_hide_bubble()

func _update_hint_text():
	if _has_enough_coins():
		hint_label.text = "Press ↓ to enter"
	else:
		hint_label.text = str(required_coins) + " coins required!"

func _has_enough_coins() -> bool:
	var total_collected := 0
	for coins in GameManager.coins_collected_by_level.values():
		total_collected += coins.size()
	return total_collected >= required_coins

func _show_bubble():
	bubble.visible = true
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 1.0, 0.25)

func _hide_bubble():
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func(): bubble.visible = false)

func _deferred_load_next_level():
	GameManager.set_levels_checkpoint(next_level_path)
	LevelManager.load_level_by_path(next_level_path)
