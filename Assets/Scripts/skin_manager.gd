extends Node

var current_skin := "default"

var unlocked_skins := {
	"default": true,

	# Unlock par défaut
	"abyssal": true,
	"bubblegum": true,
	"hell": true,
	"mystic": true,
	"emerald": true,

	# Unlock conditions
	"gold": false,
	"ignatius": false,
	"rainbow": false,

	# Secrets
	"void": false,
	"frost": false,
	"bee": false,
	"blueember": false
}

func _ready():
	load_data()

# -------- SAVE / LOAD --------

func save_data():
	SaveManager.set_value("skins", "current", current_skin, false)
	SaveManager.set_value("skins", "unlocked", unlocked_skins, false)
	SaveManager.save()

func load_data():
	current_skin = SaveManager.get_value("skins", "current", "default")
	var saved: Dictionary = SaveManager.get_value("skins", "unlocked", {})
	unlocked_skins.merge(saved, true)

# -------- API SIMPLE --------

func is_unlocked(skin: String) -> bool:
	return unlocked_skins.get(skin, false)

func unlock_skin(skin: String):
	if is_unlocked(skin):
		return

	unlocked_skins[skin] = true
	save_data()
	
	if not skin in GameManager.skins_unlocked_this_run:
		GameManager.skins_unlocked_this_run.append(skin)
		

func check_endgame_unlocks():
	# GOLD
	if GameManager.has_all_coins() and not is_unlocked("gold"):
		unlock_skin("gold")

	# IGNATIUS
	if GameManager.run_time <= 600.0 and not is_unlocked("ignatius"):
		unlock_skin("ignatius")

	# RAINBOW
	if GameManager.no_damage_run and not is_unlocked("rainbow"):
		unlock_skin("rainbow")
