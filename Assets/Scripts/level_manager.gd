extends Node

# ------------------------
# Niveaux disponibles
# ------------------------
var levels := [
	"res://Assets/Scenes/level_world.tscn",
	"res://Assets/Scenes/level_1.tscn",
	"res://Assets/Scenes/level_2.tscn",
	"res://Assets/Scenes/level_3.tscn",
	"res://Assets/Scenes/level_4.tscn",
	"res://Assets/Scenes/level_5.tscn",
	"res://Assets/Scenes/level_6.tscn",
	"res://Assets/Scenes/level_7.tscn",
	"res://Assets/Scenes/level_8.tscn",
	"res://Assets/Scenes/level_ghostlands.tscn",
	"res://Assets/Scenes/level_firelands.tscn",
	"res://Assets/Scenes/level_lunar_dream.tscn",
	"res://Assets/Scenes/level_corrupted_bloom.tscn",
	"res://Assets/Scenes/level_hidden.tscn"
]

# ------------------------
# Données du niveau courant
# ------------------------
var current_level := 0

# ------------------------
# Chargement de niveau par index
# ------------------------
func load_level(index: int) -> void:
	if index >= 0 and index < levels.size():
		current_level = index
		_load_scene_async(levels[index])

# ------------------------
# Relancer le niveau courant
# ------------------------
func restart_level() -> void:
	load_level(current_level)

# ------------------------
# Charger le prochain niveau
# ------------------------
func load_next_level() -> void:
	load_level(current_level + 1)

# ------------------------
# Retour au menu principal
# ------------------------
func return_to_menu() -> void:
	GameManager.reset_checkpoint_data()
	_load_scene_async("res://Assets/Scenes/start_menu.tscn")

# ------------------------
# Charger un niveau via son chemin
# ------------------------
func load_level_by_path(path: String) -> void:
	_load_scene_async(path)

# ------------------------
# Chargement différé de la scène
# ------------------------
func _load_scene_async(path: String) -> void:
	get_tree().get_root().set_process_input(false)
	var packed_scene = load(path)

	if packed_scene == null:
		printerr("Scène non trouvée :", path)
		get_tree().get_root().set_process_input(true)
		return

	var error = get_tree().change_scene_to_packed(packed_scene)

	if error != OK:
		printerr("Erreur lors du changement de scène :", error)
		get_tree().get_root().set_process_input(true)
		return

	get_tree().get_root().call_deferred("set_process_input", true)
