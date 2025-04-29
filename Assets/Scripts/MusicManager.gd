extends Node

var music_player: AudioStreamPlayer = null

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"  # Tu peux changer le bus si besoin
