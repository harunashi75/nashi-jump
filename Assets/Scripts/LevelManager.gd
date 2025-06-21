extends Node

var levels = [
	"res://Assets/Scenes/level_1.tscn",
	"res://Assets/Scenes/level_2.tscn",
	"res://Assets/Scenes/level_3.tscn",
	"res://Assets/Scenes/level_4.tscn",
	"res://Assets/Scenes/level_5.tscn",
	"res://Assets/Scenes/level_6.tscn",
	"res://Assets/Scenes/level_bonus_1.tscn",
	"res://Assets/Scenes/level_bonus_2.tscn",
	"res://Assets/Scenes/level_skip.tscn",
	"res://Assets/Scenes/level_victory.tscn",
	"res://Assets/Scenes/level_hard_1.tscn",
	"res://Assets/Scenes/level_hard_2.tscn",
	"res://Assets/Scenes/level_hard_3.tscn",
	"res://Assets/Scenes/level_hard_4.tscn",
	"res://Assets/Scenes/level_hard_5.tscn",
	# ...
]

var current_level = 0

func load_level(index: int):
	if index >= 0 and index < levels.size():
		var level_scene = load(levels[index])
		get_tree().change_scene_to_packed(level_scene)
		current_level = index

func load_next_level():
	load_level(current_level + 1)

func restart_level():
	load_level(current_level)

func return_to_menu():
	get_tree().change_scene_to_file("res://Assets/Scenes/start_menu.tscn")

func load_level_by_path(path: String):
	var level_scene = load(path)
	get_tree().change_scene_to_packed(level_scene)
