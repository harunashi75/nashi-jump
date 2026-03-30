extends CharacterBody2D

@export var follow_speed = 5.0
@export var typing_speed: float = 0.04

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $AnimatedSprite2D
@onready var bubble = $DialogueBubble
@onready var label = $DialogueBubble/DialogueLabel
@onready var dialogue_timer = $DialogueTimer

var dialogue_queue: Array = []
var is_talking := false
var current_full_text: String = ""
var current_char_index: int = 0

func _ready():
	add_to_group("gloop")
	bubble.visible = false
	# Petit test au démarrage
	# say(["Hé ! Je vais t'aider !", "C'est parti !"])

func say(lines, duration: float = 2.5):
	if lines is String:
		dialogue_queue.append(lines)
	elif lines is Array:
		for line in lines:
			dialogue_queue.append(line)

	if not is_talking:
		play_next_line(duration)

func play_next_line(duration):
	if dialogue_queue.is_empty():
		is_talking = false
		_hide_bubble()
		return

	is_talking = true
	current_full_text = dialogue_queue.pop_front()
	current_char_index = 0
	
	label.text = ""
	bubble.visible = true
	bubble.modulate.a = 1.0
	
	_type_next_char(duration)

func _type_next_char(duration):
	if current_char_index < current_full_text.length():
		label.text += current_full_text[current_char_index]
		current_char_index += 1
		
		update_bubble_size()
		
		get_tree().create_timer(typing_speed).timeout.connect(func(): _type_next_char(duration))
	else:
		dialogue_timer.stop()
		dialogue_timer.wait_time = duration
		dialogue_timer.start()

func update_bubble_size():
	await get_tree().process_frame
	var text_size = label.get_minimum_size()
	var padding = Vector2(20, 15)
	bubble.custom_minimum_size = text_size + padding

func _on_dialogue_timer_timeout():
	play_next_line(dialogue_timer.wait_time)

func _hide_bubble():
	bubble.visible = false

func _physics_process(delta):
	if Input.is_action_just_pressed("jump") and is_talking:
		dialogue_timer.stop()
		play_next_line(2.0)
	
	if player:
		var offset_x = 25 if !player.sprite.flip_h else -25
		var target_pos = player.global_position + Vector2(offset_x, -25)
		
		global_position = global_position.lerp(target_pos, follow_speed * delta)
		
		global_position.y += sin(Time.get_ticks_msec() * 0.005) * 0.5
		
		sprite.flip_h = !player.sprite.flip_h
		
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
