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
	"res://Assets/Scenes/level_victory.tscn",
	"res://Assets/Scenes/level_hard_1.tscn",
	"res://Assets/Scenes/level_hard_2.tscn",
	"res://Assets/Scenes/level_hard_3.tscn",
	"res://Assets/Scenes/level_hard_4.tscn",
	"res://Assets/Scenes/level_hard_5.tscn"
]

var current_level = 0

func load_level(index: int):
	if index >= 0 and index < levels.size():
		current_level = index
		call_deferred("_load_level_deferred", levels[index])

func restart_level():
	load_level(current_level)

func load_next_level():
	load_level(current_level + 1)

func return_to_menu():
	call_deferred("_load_level_deferred", "res://Assets/Scenes/start_menu.tscn")

func load_level_by_path(path: String):
	call_deferred("_load_level_deferred", path)

func _load_level_deferred(path: String):
	print("Chargement de la scène différé :", path)
	get_tree().get_root().set_process_input(false)
	var scene = load(path)
	var error = get_tree().change_scene_to_packed(scene)
	if error != OK:
		print("Erreur lors du chargement de la scène :", error)
	await get_tree().create_timer(0.1).timeout
	get_tree().get_root().set_process_input(true)
