extends Node

# -------- Gestion (SFX) et music --------
var sounds: Dictionary = {}

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var excluded_scenes := [
	"res://Assets/Scenes/start_menu.tscn",
	"res://Assets/Scenes/skin_menu.tscn",
	"res://Assets/Scenes/victory_scene.tscn"
]

# Musique par monde (index = LevelManager.get_world)
@onready var world_music := {
	1: preload("res://Assets/Sounds/Grasslands Theme.mp3"),
	2: preload("res://Assets/Sounds/Desert Theme.mp3"),
	3: preload("res://Assets/Sounds/Iceland Theme.mp3"),
	4: preload("res://Assets/Sounds/Mushroom Theme.mp3"),
	LevelManager.BOSS_WORLD: preload("res://Assets/Sounds/Boss Theme.mp3"),
}

# -------- Initialisation --------
func _ready() -> void:
	# Les sons du menu pause doivent jouer même quand l'arbre est en pause
	# (la musique continue aussi pendant la pause)
	process_mode = Node.PROCESS_MODE_ALWAYS

	add_child(music_player)

	# Le bouclage est réglé à l'import (loop=true) ; ceci sert de filet de sécurité
	music_player.finished.connect(music_player.play)

	music_player.autoplay = false
	music_player.volume_db = -5
	

	sounds = {
		"stomp": preload("res://Assets/Sounds/stomp.wav"),
		"hit": preload("res://Assets/Sounds/hit.wav"),
		"jump": preload("res://Assets/Sounds/jump.wav"),
		"coin": preload("res://Assets/Sounds/coin.wav"),
		"power_up": preload("res://Assets/Sounds/power_up.wav"),
		"select": preload("res://Assets/Sounds/select.wav"),
		"confirm": preload("res://Assets/Sounds/confirm.wav")
	}

	# La musique ne change qu'au changement de scène (plus de test à chaque frame)
	get_tree().scene_changed.connect(_check_music)
	# La scène initiale n'émet pas de signal : on attend qu'elle soit prête
	await get_tree().process_frame
	_check_music()

# -------- Gestion music --------

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if music_player.playing:
			music_player.stop()
		
		music_player.stream = null
		
		if is_instance_valid(music_player):
			music_player.queue_free()

func _check_music() -> void:
	var current_scene: Node = get_tree().current_scene
	if not current_scene:
		return

	var scene_path: String = current_scene.scene_file_path
	if scene_path in excluded_scenes:
		if music_player.playing:
			music_player.stop()
		return
	
	# Scène inconnue : musique du monde 1 par défaut
	var target_music: AudioStream = world_music.get(
		LevelManager.get_world(scene_path), world_music[1]
	)
	
	if music_player.stream != target_music:
		music_player.stop()
		music_player.stream = target_music
		music_player.play()
	elif not music_player.playing:
		music_player.play()

# -------- Gestion SFX --------
func play(sound_name: String) -> void:
	if sounds.has(sound_name):
		var temp_player := AudioStreamPlayer.new()
		add_child(temp_player)
		
		temp_player.stream = sounds[sound_name]
		temp_player.volume_db = 0
		temp_player.play()
		
		temp_player.finished.connect(func(): temp_player.queue_free())
	else:
		push_warning("Son introuvable : " + sound_name)
