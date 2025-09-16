extends Node

# ------------------------
# Références de l'UI
# ------------------------
var hud: Node = null
var pause_menu: Control = null

# ------------------------
# Checkpoint & Temps
# ------------------------
var levels_checkpoint_enabled := false
var levels_checkpoint_scene_path := ""
var game_start_time: int = 0

# ------------------------
# Paramètres globaux
# ------------------------
var godmode_enabled := false
var is_game_paused: bool = false
var difficulty := Constants.DEFAULT_DIFFICULTY
var has_initialized_health := false
var floating_text_scene := preload("res://Assets/Scenes/floating_text.tscn")

# ------------------------
# Joueur & Vies
# ------------------------
var player_lives: int = 10
var player_current_health := 10

# ------------------------
# Pièces
# ------------------------
var coins_collected := {}
var coins_collected_by_level := {}
var total_coins_in_level := 0

# ------------------------
# Initialisation
# ------------------------
func _ready():
	if hud and not hud.is_inside_tree():
		hud = null
	if pause_menu and not pause_menu.is_inside_tree():
		pause_menu = null

# ------------------------
# Dommages ennemis
# ------------------------
func get_enemy_damage(level_name: String) -> int:
	return Constants.BASE_ENEMY_DAMAGE.get(level_name, 1)

# ------------------------
# Affichage texte
# ------------------------
func show_floating_text(text: String, position: Vector2, color: Color = Color.WHITE):
	var floating_text = floating_text_scene.instantiate()
	floating_text.position = position
	floating_text.get_node("Label").text = text
	floating_text.get_node("Label").modulate = color
	get_tree().current_scene.add_child(floating_text)

# ------------------------
# Démarrage & Pause
# ------------------------
func start_game(lives: int):
	reset_coins()
	player_lives = lives
	player_current_health = lives
	game_start_time = Time.get_ticks_msec()

func toggle_pause():
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused
	if pause_menu and pause_menu.is_inside_tree():
		pause_menu.visible = is_game_paused

# ------------------------
# Vies
# ------------------------
func reset_lives_by_difficulty():
	player_lives = Constants.DIFFICULTY_TO_LIVES.get(difficulty, 10)
	player_current_health = player_lives

# ------------------------
# Coins
# ------------------------
func reset_coins():
	coins_collected.clear()
	coins_collected_by_level.clear()
	total_coins_in_level = 0

func add_coin(coin_name: String, amount: int = 1):
	coins_collected[coin_name] = coins_collected.get(coin_name, 0) + amount
	if is_instance_valid(hud):
		hud.update_coins_display()
	print("Coins collectés :", coins_collected)

func mark_coin_collected(level: String, id: String):
	coins_collected_by_level[level] = coins_collected_by_level.get(level, [])
	if id not in coins_collected_by_level[level]:
		coins_collected_by_level[level].append(id)
		print("Coin unique collecté :", id)

		var total := 0
		for coins in coins_collected_by_level.values():
			total += coins.size()

		SkinManager.check_unlock_skins(total, difficulty)

func is_coin_already_collected(level_name: String, coin_id: String) -> bool:
	return coins_collected_by_level.has(level_name) and coin_id in coins_collected_by_level[level_name]

func set_levels_checkpoint(path: String):
	levels_checkpoint_enabled = true
	levels_checkpoint_scene_path = path
	print("Checkpoint activé :", path)

# ------------------------
# Temps
# ------------------------
func set_completion_time(diff: String, time_in_seconds: float):
	if not SkinManager.time_scores.has(diff) or SkinManager.time_scores[diff] > time_in_seconds:
		SkinManager.time_scores[diff] = time_in_seconds
		print("Temps mis à jour pour", diff, ":", time_in_seconds)
		SkinManager.check_time_skins()
		SkinManager.save_skin_data()

# ------------------------
# Input
# ------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_T:
				LevelManager.load_level_by_path("res://Assets/Scenes/level_victory.tscn")
			KEY_G:
				_toggle_godmode()

func _toggle_godmode() -> void:
	godmode_enabled = !godmode_enabled
	print("Godmode " + ("activé" if godmode_enabled else "désactivé"))
