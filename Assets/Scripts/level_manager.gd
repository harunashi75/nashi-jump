extends Node

# -------- Niveaux disponibles (source unique) --------
# world : 1-4 = mondes, BOSS_WORLD = boss, 0 = hors monde (écran de victoire)
# ice   : le niveau utilise la physique de glace
const BOSS_WORLD := 5
const SCENES := "res://Assets/Scenes/"

const LEVEL_DEFS := [
	{"file": "level_plains", "world": 1},
	{"file": "level_plains_bloom", "world": 1},
	{"file": "level_plains_autumn", "world": 1},
	{"file": "level_desert", "world": 2},
	{"file": "level_sunken_amber_valley", "world": 2},
	{"file": "level_desert_tempest", "world": 2},
	{"file": "level_frozen_peaks", "world": 3, "ice": true},
	{"file": "level_deep_ice", "world": 3, "ice": true},
	{"file": "level_crystal_glacier", "world": 3, "ice": true},
	{"file": "level_sakura", "world": 4},
	{"file": "level_sakura_dream", "world": 4},
	{"file": "level_sakura_nightmare", "world": 4},
	{"file": "level_nightmare_boss", "world": BOSS_WORLD},
	{"file": "victory_scene", "world": 0},
]

# Ordre de progression (chemins), dérivé de LEVEL_DEFS
var levels: Array = LEVEL_DEFS.map(func(d): return SCENES + d["file"] + ".tscn")

# -------- Infos par niveau --------
func _find_def(scene_path: String) -> Dictionary:
	var i := levels.find(scene_path)
	return LEVEL_DEFS[i] if i >= 0 else {}

# Monde d'une scène (-1 si ce n'est pas un niveau connu)
func get_world(scene_path: String) -> int:
	return _find_def(scene_path).get("world", -1)

func is_ice_level(scene_path: String) -> bool:
	return _find_def(scene_path).get("ice", false)

# -------- Données du niveau courant --------
var current_level := 0

# -------- Chargement de niveau par index --------
func load_level(index: int) -> void:
	if index >= 0 and index < levels.size():
		current_level = index
		_load_scene_async(levels[index])

# -------- Relancer le niveau courant --------
func restart_level() -> void:
	load_level(current_level)

# -------- Charger le prochain niveau --------
func load_next_level() -> void:
	load_level(current_level + 1)

# -------- Retour au menu principal --------
func return_to_menu() -> void:
	GameManager.reset_checkpoint_data()
	_load_scene_async("res://Assets/Scenes/start_menu.tscn")

# -------- Charger un niveau via son chemin --------
func load_level_by_path(path: String) -> void:
	_load_scene_async(path)

# -------- Chargement différé de la scène --------
func _load_scene_async(path: String) -> void:
	get_tree().get_root().set_process_input(false)

	var packed_scene := load(path)
	if packed_scene == null:
		printerr("Scène non trouvée :", path)
		get_tree().get_root().set_process_input(true)
		return

	call_deferred("_deferred_change_scene", packed_scene)

func _deferred_change_scene(packed_scene: PackedScene) -> void:
	var error := get_tree().change_scene_to_packed(packed_scene)

	if error != OK:
		printerr("Erreur lors du changement de scène :", error)
		get_tree().get_root().set_process_input(true)
		return

	get_tree().get_root().set_process_input(true)
