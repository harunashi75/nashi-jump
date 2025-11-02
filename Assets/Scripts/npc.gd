extends Node2D

@onready var bubble: Control = $Bubble
@onready var bubble_label: Label = $Bubble/Label

@export var npc_message: String = "Congratulations on your victory!"
@export var display_duration: float = 4.0
@export var typing_speed: float = 0.04

var full_text: String
var current_index: int = 0

func _ready() -> void:
	bubble.visible = false
	full_text = npc_message
	_loop_dialogue()

func _loop_dialogue() -> void:
	say(full_text, display_duration)
	var loop_timer := get_tree().create_timer(display_duration + 1.0)
	loop_timer.timeout.connect(_loop_dialogue)

func say(message: String, duration: float = 3.0) -> void:
	full_text = message
	current_index = 0
	bubble_label.text = ""
	bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.visible = true
	_type_next_char()

	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(hide_bubble)

func _type_next_char() -> void:
	if current_index < full_text.length():
		bubble_label.text += full_text[current_index]
		current_index += 1
		var char_timer := get_tree().create_timer(typing_speed)
		char_timer.timeout.connect(_type_next_char)

func hide_bubble() -> void:
	bubble.visible = false
