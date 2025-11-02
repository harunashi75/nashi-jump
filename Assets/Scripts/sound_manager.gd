extends Node

# ------------------------------------------------------------
# Gestion des sons (SFX) et de la musique de fond
# ------------------------------------------------------------
var sounds = {}

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var excluded_scenes := [
	"res://Assets/Scenes/start_menu.tscn",
	#"res://Assets/Scenes/level_victory.tscn",
	"res://Assets/Scenes/level_void.tscn",
	"res://Assets/Scenes/level_hidden.tscn"
]

@onready var background_music := preload("res://Assets/Sounds/time_for_adventure.ogg")

var last_scene = null

# ------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------

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
		"unlock": preload("res://Assets/Sounds/unlock.wav"),
		#"death": preload("res://Assets/Sounds/death.wav"),
		"hit": preload("res://Assets/Sounds/hit.wav"),
		"jump": preload("res://Assets/Sounds/jump.wav"),
		"coin": preload("res://Assets/Sounds/coin.wav")
	}

# ------------------------------------------------------------
# Gestion musique (comme dans ton ancien script music.gd)
# ------------------------------------------------------------
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
	else:
		if not music_player.playing:
			music_player.play()

# ------------------------------------------------------------
# Gestion des sons SFX
# ------------------------------------------------------------
func play(sound_name: String):
	if sounds.has(sound_name):
		sfx_player.stream = sounds[sound_name]
		sfx_player.play()
	else:
		push_warning("Sound not found: " + sound_name)
