extends Node

# -------- Gestion (SFX) et music --------
var sounds = {}

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var excluded_scenes := [
	"res://Assets/Scenes/start_menu.tscn",
	"res://Assets/Scenes/skin_menu.tscn",
	"res://Assets/Scenes/victory_scene.tscn"
]

@onready var background_music := preload("res://Assets/Sounds/time_for_adventure.mp3")
@onready var boss_music := preload("res://Assets/Sounds/ive_got_your_back.ogg")

var last_scene = null

# -------- Initialisation --------
func _ready():
	add_child(music_player)
	add_child(sfx_player)

	music_player.autoplay = false
	music_player.stream = background_music
	music_player.volume_db = -5
	
	if background_music is AudioStream:
		background_music.loop = true

	sfx_player.autoplay = false
	sfx_player.volume_db = 0

	sounds = {
		"stomp": preload("res://Assets/Sounds/stomp.wav"),
		"hit": preload("res://Assets/Sounds/hit.wav"),
		"jump": preload("res://Assets/Sounds/jump.wav"),
		"coin": preload("res://Assets/Sounds/coin.wav"),
		"power_up": preload("res://Assets/Sounds/power_up.wav"),
		"select": preload("res://Assets/Sounds/select.wav"),
		"confirm": preload("res://Assets/Sounds/confirm.wav")
	}

# -------- Gestion music --------
func _process(_delta):
	last_scene = get_tree().current_scene
	_check_music()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if music_player.playing:
			music_player.stop()
		
		music_player.stream = null
		
		if is_instance_valid(music_player):
			music_player.queue_free()
		if is_instance_valid(sfx_player):
			sfx_player.queue_free()
		
		if background_music:
			background_music = null

func _check_music():
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	var scene_path = current_scene.scene_file_path
	if scene_path in excluded_scenes:
		if music_player.playing:
			music_player.stop()
	
	var target_music: AudioStream
	if scene_path == "res://Assets/Scenes/level_boss.tscn":
		target_music = boss_music
	else:
		target_music = background_music

	if music_player.stream != target_music:
		music_player.stop()
		music_player.stream = target_music
		if target_music is AudioStream:
			target_music.loop = true 
		music_player.play()
	elif not music_player.playing:
		music_player.play()

# -------- Gestion SFX --------
func play(sound_name: String):
	if sounds.has(sound_name):
		var temp_player = AudioStreamPlayer.new()
		add_child(temp_player)
		
		temp_player.stream = sounds[sound_name]
		temp_player.volume_db = 0
		temp_player.play()
		
		temp_player.finished.connect(func(): temp_player.queue_free())
	else:
		push_warning("Sound not found: " + sound_name)
