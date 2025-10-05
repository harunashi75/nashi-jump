extends Node

# ------------------------
# Variables
# ------------------------
var current_skin := "default"
var unlocked_skins := {}
var coins_collected_by_difficulty := {}
var time_scores := {}

# ------------------------
# Initialisation
# ------------------------
func _ready():
	_reset_defaults()
	load_skin_data()

func _reset_defaults():
	unlocked_skins = Constants.DEFAULT_UNLOCKED_SKINS.duplicate(true)
	coins_collected_by_difficulty = Constants.DEFAULT_COINS_BY_DIFFICULTY.duplicate(true)
	time_scores.clear()

	# Skins de base toujours débloqués
	unlocked_skins["default"] = true
	unlocked_skins["thecreator"] = true
	unlocked_skins["murloc"] = true

# ------------------------
# Sauvegarde
# ------------------------
func save_skin_data():
	var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.WRITE)
	file.store_var({
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins,
		"coins_collected_by_difficulty": coins_collected_by_difficulty,
		"time_scores": time_scores
	})
	file.close()

func load_skin_data():
	if FileAccess.file_exists(Constants.SAVE_PATH):
		var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		current_skin = data.get("current_skin", "default")
		unlocked_skins.merge(data.get("unlocked_skins", unlocked_skins), true)
		coins_collected_by_difficulty.merge(data.get("coins_collected_by_difficulty", coins_collected_by_difficulty), true)
		time_scores = data.get("time_scores", {})
		file.close()

	# Toujours débloquer les skins de base
	unlocked_skins["default"] = true
	unlocked_skins["thecreator"] = true
	unlocked_skins["murloc"] = true

# ------------------------
# Vérifications & Déblocage
# ------------------------
func is_unlocked(skin_name: String) -> bool:
	return unlocked_skins.get(skin_name, false)

func unlock_skin(skin_name: String, pos: Vector2 = Vector2.ZERO):
	if not is_unlocked(skin_name):
		unlocked_skins[skin_name] = true
		_show_unlock_feedback(skin_name, pos)
		save_skin_data()

# ------------------------
# Déblocage par pièces
# ------------------------
func check_unlock_skins(total: int, difficulty: String):
	coins_collected_by_difficulty[difficulty] = max(coins_collected_by_difficulty[difficulty], total)
	if total >= 225 and not is_unlocked(difficulty):
		unlocked_skins[difficulty] = true
		var skin_name = Constants.DIFFICULTY_TO_SKIN_NAME.get(difficulty, difficulty)
		unlocked_skins[skin_name] = true
		_show_unlock_feedback(skin_name)
	save_skin_data()
	call_deferred("_check_global_skin_unlocks")

func _check_global_skin_unlocks():
	if _all_difficulties_have_min_coins(["easy", "normal", "hard"], 245) and not is_unlocked("gold"):
		unlock_skin("gold")

	check_time_skins()
	save_skin_data()

func _all_difficulties_have_min_coins(difficulties: Array, min_coins: int) -> bool:
	for d in difficulties:
		if coins_collected_by_difficulty.get(d, 0) < min_coins:
			return false
	return true

# ------------------------
# Déblocage par temps
# ------------------------
func check_time_skins():
	var count = 0
	for d in ["easy", "normal", "hard"]:
		if time_scores.get(d, INF) <= 900.0 and coins_collected_by_difficulty.get(d, 0) >= 215:
			count += 1

	if count >= 1 and not is_unlocked("whisper"):
		unlock_skin("whisper")

	if count == 3 and not is_unlocked("hell"):
		unlock_skin("hell")

	save_skin_data()

# ------------------------
# Utilitaires
# ------------------------
func _show_unlock_feedback(skin_name: String, pos: Vector2 = Vector2.ZERO):
	if pos == Vector2.ZERO:
		pos = _get_player_pos()
	GameManager.show_floating_text("Skin unlocked : " + skin_name, pos, Color(1.0, 0.84, 0.0))
	SoundManager.play("unlock")

func _get_player_pos() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.position + Vector2(0, -80)
	return Vector2(200, 200)
