extends Node

# ------------------------
# Variables
# ------------------------
var current_skin := "default"
var unlocked_skins := {}
var time_scores := {}
var total_jumps := 0
var total_powerups := 0
var no_powerup_victories := 0
var idle_time := 0.0
var jump_boost_uses := 0
var shield_uses := 0

# ------------------------
# Initialisation
# ------------------------
func _ready():
	_reset_defaults()
	load_skin_data()

func _reset_defaults():
	unlocked_skins = Constants.DEFAULT_UNLOCKED_SKINS.duplicate(true)
	time_scores.clear()

	unlocked_skins["default"] = true

# ------------------------
# Sauvegarde
# ------------------------
func save_skin_data():
	var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.WRITE)
	file.store_var({
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins,
		"time_scores": time_scores,
		"total_jumps": total_jumps,
		"total_powerups": total_powerups,
		"no_powerup_victories": no_powerup_victories,
		"idle_time": idle_time,
		"jump_boost_uses": jump_boost_uses,
		"shield_uses": shield_uses
	})
	file.close()

func load_skin_data():
	if FileAccess.file_exists(Constants.SAVE_PATH):
		var file = FileAccess.open(Constants.SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		current_skin = data.get("current_skin", "default")
		unlocked_skins.merge(data.get("unlocked_skins", unlocked_skins), true)
		time_scores = data.get("time_scores", {})
		total_jumps = data.get("total_jumps", 0)
		total_powerups = data.get("total_powerups", 0)
		no_powerup_victories = data.get("no_powerup_victories", 0)
		idle_time = data.get("idle_time", 0.0)
		jump_boost_uses = data.get("jump_boost_uses", 0)
		shield_uses = data.get("shield_uses", 0)
		file.close()

	# Toujours débloquer les skins de base
	unlocked_skins["default"] = true

# ------------------------
# Vérifications & Déblocage
# ------------------------
func is_unlocked(skin_name: String) -> bool:
	return unlocked_skins.get(skin_name, false)

func unlock_skin(skin_name: String):
	if is_unlocked(skin_name):
		return

	unlocked_skins[skin_name] = true

	# --- Track skin unlocked during this run ---
	if not GameManager.skins_unlocked_this_run.has(skin_name):
		GameManager.skins_unlocked_this_run.append(skin_name)

	# SoundManager.play("unlock")
	save_skin_data()

func check_jump_skins():
	if total_jumps >= 1000 and not is_unlocked("mystic"):
		unlock_skin("mystic")

func on_player_jump():
	total_jumps += 1
	print("Jumps :", total_jumps)
	check_jump_skins()

func check_no_damage_skin():
	if GameManager.no_damage_run and not is_unlocked("rainbow"):
		unlock_skin("rainbow")

func add_powerup_count():
	total_powerups += 1
	print("Power-ups collectés :", total_powerups)
	check_powerup_skin()

func check_powerup_skin():
	if total_powerups >= 200 and not is_unlocked("bubblegum"):
		unlock_skin("bubblegum")

func check_ignatius_condition():
	if not GameManager.used_powerup:
		no_powerup_victories += 1
		print("No-powerup victories :", no_powerup_victories)
	
	if no_powerup_victories >= 5 and not is_unlocked("ignatius"):
		unlock_skin("ignatius")

func add_idle_time(delta):
	idle_time += delta
	check_frost_knight()

func reset_idle_timer():
	idle_time = 0

func check_frost_knight():
	if idle_time >= 30.0 and not is_unlocked("frost"):
		unlock_skin("frost")

func add_jump_boost_use():
	jump_boost_uses += 1
	print("Jump Boost utilisés :", jump_boost_uses)
	check_blue_ember()

func check_blue_ember():
	if jump_boost_uses >= 120 and not is_unlocked("gaga"):
		unlock_skin("gaga")

func add_shield_use():
	shield_uses += 1
	print("Shield utilisés :", shield_uses)
	check_sproutknight()

func check_sproutknight():
	if shield_uses >= 100 and not is_unlocked("emerald"):
		unlock_skin("emerald")

func check_blue_ember_victory():
	if current_skin == "gaga" and not is_unlocked("abyssal"):
		unlock_skin("abyssal")

func check_unlock_skins(total_coins: int):
	if total_coins >= 130 and not is_unlocked("gold"):
		unlock_skin("gold")

func set_completion_time(time_in_seconds: float) -> void:
	var best_time: float = time_scores.get("best", INF)

	if time_in_seconds < best_time:
		time_scores["best"] = time_in_seconds
		check_time_skins()

func check_time_skins():
	var best_time: float = time_scores.get("best", INF)

	if best_time <= 600.0 and not is_unlocked("hell"):
		unlock_skin("hell")
