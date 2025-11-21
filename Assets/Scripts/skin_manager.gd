extends Node

# ------------------------
# Variables
# ------------------------
var current_skin := "default"
var unlocked_skins := {}
var time_scores := {}
var total_jumps := 0
var total_powerups := 0
var total_deaths := 0
var no_powerup_victories := 0
var idle_time := 0.0
var jump_boost_uses := 0
var speed_boost_uses := 0
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
	unlocked_skins["murloc"] = true

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
		"total_deaths": total_deaths,
		"no_powerup_victories": no_powerup_victories,
		"idle_time": idle_time,
		"jump_boost_uses": jump_boost_uses,
		"speed_boost_uses": speed_boost_uses,
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
		total_deaths = data.get("total_deaths", 0)
		no_powerup_victories = data.get("no_powerup_victories", 0)
		idle_time = data.get("idle_time", 0.0)
		jump_boost_uses = data.get("jump_boost_uses", 0)
		speed_boost_uses = data.get("speed_boost_uses", 0)
		shield_uses = data.get("shield_uses", 0)
		file.close()

	# Toujours débloquer les skins de base
	unlocked_skins["default"] = true
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

func check_jump_skins():
	if total_jumps >= 300 and not is_unlocked("mystic"):
		unlock_skin("mystic")
		save_skin_data()

func on_player_jump():
	total_jumps += 1
	print("Jumps :", total_jumps)
	check_jump_skins()
	save_skin_data()

func check_no_damage_skin():
	if GameManager.no_damage_run and not is_unlocked("rainbow"):
		unlock_skin("rainbow")
		save_skin_data()

func add_powerup_count():
	total_powerups += 1
	print("Power-ups collectés :", total_powerups)
	check_powerup_skin()
	save_skin_data()

func check_powerup_skin():
	if total_powerups >= 200 and not is_unlocked("bubblegum"):
		unlock_skin("bubblegum")
		save_skin_data()

func add_death_count():
	total_deaths += 1
	print("Deaths :", total_deaths)
	check_death_skin()
	save_skin_data()

func check_death_skin():
	if total_deaths >= 100 and not is_unlocked("soul"):
		unlock_skin("soul")
		save_skin_data()

func check_ignatius_condition():
	if not GameManager.used_powerup:
		no_powerup_victories += 1
		print("No-powerup victories :", no_powerup_victories)
		save_skin_data()
	
	if no_powerup_victories >= 5 and not is_unlocked("ignatius"):
		unlock_skin("ignatius")
		save_skin_data()

func add_idle_time(delta):
	idle_time += delta
	check_frost_knight()
	save_skin_data()

func reset_idle_timer():
	idle_time = 0

func check_frost_knight():
	if idle_time >= 30.0 and not is_unlocked("frost"):
		unlock_skin("frost")
		save_skin_data()

func add_jump_boost_use():
	jump_boost_uses += 1
	print("Jump Boost utilisés :", jump_boost_uses)
	check_blue_ember()
	save_skin_data()

func check_blue_ember():
	if jump_boost_uses >= 20 and not is_unlocked("gaga"):
		unlock_skin("gaga")
		save_skin_data()

func add_speed_boost_use():
	speed_boost_uses += 1
	print("Speed Boost utilisés :", speed_boost_uses)
	check_emerald()
	save_skin_data()

func check_emerald():
	if speed_boost_uses >= 20 and not is_unlocked("emerald"):
		unlock_skin("emerald")
		save_skin_data()

func add_shield_use():
	shield_uses += 1
	print("Shield utilisés :", shield_uses)
	check_bloodforged()
	save_skin_data()

func check_bloodforged():
	if shield_uses >= 10 and not is_unlocked("bloodforged"):
		unlock_skin("bloodforged")
		save_skin_data()

func check_blue_ember_victory():
	if current_skin == "blue_ember" and not is_unlocked("abyssal"):
		unlock_skin("abyssal")
		save_skin_data()

# ------------------------
# Déblocage par pièces
# ------------------------
func check_unlock_skins(total_coins: int):
	if total_coins >= 120 and not is_unlocked("gold"):
		unlock_skin("gold")
		save_skin_data()

# ------------------------ 
# Déblocage par temps 
# ------------------------ 
func check_time_skins():
	var best_time: float = time_scores.get("best", INF)

	if best_time <= 600.0 and not is_unlocked("hell"):
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
