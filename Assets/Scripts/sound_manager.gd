extends Node

var sounds = {}

@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(sfx_player)

	sounds = {
		"unlock": preload("res://Assets/Sounds/unlock.wav"),
		"death": preload("res://Assets/Sounds/death.wav"),
		"hit": preload("res://Assets/Sounds/hit.wav"),
		"jump": preload("res://Assets/Sounds/jump.wav"),
		"coin": preload("res://Assets/Sounds/coin.wav")
	}

func play(sound_name: String):
	if sounds.has(sound_name):
		sfx_player.stream = sounds[sound_name]
		sfx_player.play()
	else:
		push_warning("Sound not found: " + sound_name)
