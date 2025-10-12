extends Node

# ------------------------
# Paramètres globaux
# ------------------------
const DEFAULT_DIFFICULTY := "normal"
const SAVE_PATH := "user://skin_data.save"

# ------------------------
# Vies par difficulté
# ------------------------
const DIFFICULTY_TO_LIVES := {
	"easy": 15,
	"normal": 10,
	"hard": 5,
	"insane": 1
}

# ------------------------
# Coins par difficulté (par défaut)
# ------------------------
const DEFAULT_COINS_BY_DIFFICULTY := {
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"insane": 0
}

# ------------------------
# Skins par défaut (verrouillés)
# ------------------------
const DEFAULT_UNLOCKED_SKINS := {
	"emerald": false, "mystic": false, "bubblegum": false,
	"abyssal": false, "rainbow": false, "gold": false,
	"whisper": false, "hell": false, "ignatius": false,
	"barbie": false, "bloodforged": false, "frost": false,
	"void": false, "bee": false, "gaga": false,
	"hidden": false, "bear": false
}

# ------------------------
# Correspondance difficulté -> skin
# ------------------------
const DIFFICULTY_TO_SKIN_NAME := {
	"easy": "emerald",
	"normal": "mystic",
	"hard": "abyssal",
	"insane": "rainbow"
}
