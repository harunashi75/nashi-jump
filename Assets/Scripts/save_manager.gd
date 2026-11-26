extends Node

# Sauvegarde unique du jeu : un seul fichier ConfigFile versionné.
#
# Sections utilisées :
#   meta     version du format
#   progress current_level
#   coins    by_level, dropped
#   run      deaths, no_damage
#   skins    current, unlocked
#   timer    elapsed (run en cours), best (meilleur temps)
#   audio    volume
#
# Les anciens fichiers (savegame.cfg, skin_data.save, score.save,
# current_timer.save, settings.cfg) sont importés une seule fois au premier
# lancement ; ils ne sont ni modifiés ni supprimés.

const SAVE_PATH := "user://save.cfg"
const SAVE_VERSION := 1

const LEGACY_PROGRESS := "user://savegame.cfg"
const LEGACY_SKINS := "user://skin_data.save"
const LEGACY_BEST := "user://score.save"
const LEGACY_TIMER := "user://current_timer.save"
const LEGACY_SETTINGS := "user://settings.cfg"

var _config := ConfigFile.new()

func _ready() -> void:
	_load()

# -------- API --------

# Lit une valeur. Si le type stocké ne correspond pas à celui de `default`
# (fichier modifié/corrompu), `default` est renvoyé.
func get_value(section: String, key: String, default: Variant = null) -> Variant:
	var value: Variant = _config.get_value(section, key, default)
	if default == null or typeof(value) == typeof(default):
		return value
	if typeof(default) == TYPE_FLOAT and typeof(value) == TYPE_INT:
		return float(value)
	return default

func has_value(section: String, key: String) -> bool:
	return _config.has_section_key(section, key)

# Écrit une valeur et sauvegarde (autosave=false pour grouper plusieurs écritures
# puis appeler save()).
func set_value(section: String, key: String, value: Variant, autosave: bool = true) -> void:
	_config.set_value(section, key, value)
	if autosave:
		save()

func save() -> void:
	_config.set_value("meta", "version", SAVE_VERSION)

	# Écriture dans un fichier temporaire puis renommage : une coupure pendant
	# l'écriture ne détruit pas la sauvegarde existante.
	var tmp_path := SAVE_PATH + ".tmp"
	var error := _config.save(tmp_path)
	if error != OK:
		push_warning("Sauvegarde impossible : %s" % error_string(error))
		return

	error = DirAccess.rename_absolute(tmp_path, SAVE_PATH)
	if error != OK:
		push_warning("Sauvegarde impossible (renommage) : %s" % error_string(error))

# Vrai s'il existe une progression (sert à activer « Continuer »)
func has_progress() -> bool:
	return has_value("progress", "current_level")

# -------- Chargement --------

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error := _config.load(SAVE_PATH)
		if error == OK:
			_upgrade(int(_config.get_value("meta", "version", 0)))
			return

		# Fichier illisible : on le met de côté et on repart des anciennes données
		push_warning("Sauvegarde illisible (%s), copie conservée en .corrupt" % error_string(error))
		DirAccess.rename_absolute(SAVE_PATH, SAVE_PATH + ".corrupt")
		_config = ConfigFile.new()

	_import_legacy()

# Migrations de format : ajouter un cas par version quand SAVE_VERSION augmente
func _upgrade(from_version: int) -> void:
	if from_version >= SAVE_VERSION:
		return

	# match from_version:
	#	1: ... passage de 1 vers 2

	save()

# -------- Import des anciens fichiers --------

func _import_legacy() -> void:
	var imported := false

	# savegame.cfg : mêmes sections/clés que le nouveau format
	var legacy := ConfigFile.new()
	if legacy.load(LEGACY_PROGRESS) == OK:
		for section in legacy.get_sections():
			for key in legacy.get_section_keys(section):
				_config.set_value(section, key, legacy.get_value(section, key))
		imported = true

	var skins: Variant = _read_var(LEGACY_SKINS)
	if typeof(skins) == TYPE_DICTIONARY:
		_config.set_value("skins", "current", str(skins.get("current_skin", "default")))
		if typeof(skins.get("unlocked_skins")) == TYPE_DICTIONARY:
			_config.set_value("skins", "unlocked", skins["unlocked_skins"])
		imported = true

	var best: Variant = _read_var(LEGACY_BEST)
	if typeof(best) == TYPE_FLOAT or typeof(best) == TYPE_INT:
		_config.set_value("timer", "best", float(best))
		imported = true

	var elapsed: Variant = _read_var(LEGACY_TIMER)
	if typeof(elapsed) == TYPE_FLOAT or typeof(elapsed) == TYPE_INT:
		_config.set_value("timer", "elapsed", float(elapsed))
		imported = true

	var settings := ConfigFile.new()
	if settings.load(LEGACY_SETTINGS) == OK and settings.has_section_key("audio", "volume"):
		_config.set_value("audio", "volume", settings.get_value("audio", "volume"))
		imported = true

	if imported:
		save()

func _read_var(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var value: Variant = file.get_var()
	file.close()
	return value
