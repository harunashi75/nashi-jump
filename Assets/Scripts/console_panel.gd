extends CanvasLayer

@onready var history = $TextEdit
@onready var input_line = $LineEdit

func _enter_tree():
	set_process_input(true)

func _ready():
	input_line.text_submitted.connect(_on_command_entered)
	history.editable = false
	self.visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SLASH:
			self.visible = not self.visible
			if self.visible:
				input_line.grab_focus()
		elif event.keycode == KEY_ESCAPE and self.visible:
			self.visible = false

func _on_command_entered(command_line: String):
	command_line = command_line.strip_edges()
	if command_line == "":
		return

	input_line.clear()
	history.text += "\n> " + command_line

	var args = command_line.split(" ")
	var command = args[0]

	match command:
		"give_life":
			var default_amounts = {
				"easy": 300,
				"normal": 180,
				"hard": 90,
				"fun": 600,
				"jumpgo": 300
			}

			var amount = default_amounts.get(GameManager.difficulty, 180)
			if args.size() > 1 and args[1].is_valid_int():
				amount = args[1].to_int()

			GameManager.player_lives = amount
			GameManager.player_current_health = amount

			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("set_lives"):
				player.set_lives(amount)

			history.text += "\nVies définies à %d (cheat activé)" % amount

		"set_skin":
			if args.size() > 1:
				var skin = args[1].to_lower()
				GameManager.current_skin = skin
				GameManager.save_skin_data()
				history.text += "\nSkin temporaire appliqué : %s" % skin
			else:
				history.text += "\nUsage : set_skin nashi"

		"tp":
			if args.size() > 1 and args[1] == "victory":
				get_tree().change_scene_to_file("res://Assets/Scenes/level_victory.tscn")
				history.text += "\nTéléportation vers level_victory"
			else:
				history.text += "\nUsage : tp victory"

		"reset_saves":
			GameManager.reset_coins()
			GameManager.save_skin_data()
			history.text += "\nDonnées reset"

		"heal":
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.set_lives(player.max_health)
				history.text += "\nJoueur soigné!"
			else:
				history.text += "\nAucun joueur trouvé."

		"godmode":
			GameManager.godmode_enabled = !GameManager.godmode_enabled
			history.text += "\nGodmode " + ("activé" if GameManager.godmode_enabled else "désactivé")

		"killme":
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(player.current_health)
				history.text += "\nLe joueur s'est suicidé..."
			else:
				history.text += "\nAucun joueur trouvé."

		"speedup":
			var player = get_tree().get_first_node_in_group("player")
			if player:
				GameManager.speedup_enabled = !GameManager.speedup_enabled
				if GameManager.speedup_enabled:
					player.MOVE_SPEED *= 2
					player.JUMP_FORCE *= 1.5
					history.text += "\nVitesse augmentée (cheat activé)"
				else:
					player.MOVE_SPEED = player.DEFAULT_MOVE_SPEED
					player.JUMP_FORCE = player.DEFAULT_JUMP_FORCE
					history.text += "\nVitesse réinitialisée"
			else:
				history.text += "\nAucun joueur trouvé."

		_:
			history.text += "\nCommande inconnue."
