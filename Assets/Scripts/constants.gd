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
	"veryeasy": 20,
	"easy": 15,
	"normal": 10,
	"hard": 5,
	"insane": 1,
	"exploration": 10,
	"gorun": 10
}

# ------------------------
# Coins par difficulté (par défaut)
# ------------------------
const DEFAULT_COINS_BY_DIFFICULTY := {
	"veryeasy": 0,
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"insane": 0,
	"exploration": 0,
	"gorun": 0
}

# ------------------------
# Skins par défaut (verrouillés)
# ------------------------
const DEFAULT_UNLOCKED_SKINS := {
	"bubblegum": false, "emerald": false, "mystic": false,
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
	"veryeasy": "bubblegum",
	"easy": "emerald",
	"normal": "mystic",
	"hard": "abyssal",
	"insane": "rainbow",
	"exploration": "ignatius"
}

# ------------------------
# Dommages ennemis par niveau
# ------------------------
const BASE_ENEMY_DAMAGE := {
	"Level_1": 1,
	"Level_2": 1,
	"Level_3": 1,
	"Level_4": 1,
	"Level_5": 1,
	"Level_6": 2,
	"Level_7": 2,
	"Level_8": 2,
	"Level_9": 2,
	"Level_10": 2,
	"Level_11": 3,
	"Level_12": 3,
	"Level_13": 3,
	"Level_14": 3,
	"Level_15": 3,
	"Level_16": 4,
	"Level_17": 4,
	"Level_18": 4,
	"Level_Hard": 5,
	"Level_Void": 4,
	"Level_Jump": 1,
	"Level_Run": 1
}
