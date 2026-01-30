extends Node

const SAVE_PATH := "user://skin_data.save"

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
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var({
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins
	})
	file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()

	current_skin = data.get("current_skin", "default")
	unlocked_skins.merge(data.get("unlocked_skins", {}), true)

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
		
	print("Skin débloqué : ", skin)

func check_endgame_unlocks():
	# GOLD
	if GameManager.get_total_unique_coins() >= 330 and not is_unlocked("gold"):
		unlock_skin("gold")

	# IGNATIUS
	if GameManager.run_time <= 600.0 and not is_unlocked("ignatius"):
		unlock_skin("ignatius")

	# RAINBOW
	if GameManager.no_damage_run and not is_unlocked("rainbow"):
		unlock_skin("rainbow")
