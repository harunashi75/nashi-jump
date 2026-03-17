extends Node

func _ready():
	var hud = preload("res://Assets/Scenes/hud.tscn").instantiate()
	add_child(hud)
	GameManager.hud = hud

	var total_collected: int = GameManager.get_total_unique_coins()
	hud.update_coins_display(total_collected)

	# --- LOGIQUE GLOOP AVEC LEVEL MANAGER ---
	await get_tree().create_timer(0.8).timeout

	var gloop = get_tree().get_first_node_in_group("gloop")
	if gloop:
		var current_path = get_tree().current_scene.scene_file_path

		match current_path:
			"res://Assets/Scenes/level_1.tscn":
				gloop.say(["The Plains...", "It all starts here.", "Let's be careful!"])

			"res://Assets/Scenes/level_2.tscn":
				gloop.say(["Honeyland!", "The sugar makes", "them enormous!"])

			"res://Assets/Scenes/level_3.tscn":
				gloop.say(["Earthy Cave...", "They are looking", "for minerals."])

			"res://Assets/Scenes/level_4.tscn":
				gloop.say(["The Desert...", "Beware of the", "quicksand!"])

			"res://Assets/Scenes/level_5.tscn":
				gloop.say(["Glacier...", "Beware of the", "ice peaks!"])

			"res://Assets/Scenes/level_6.tscn":
				gloop.say(["Milkshake Land...", "It was once", "a paradise..."])

			"res://Assets/Scenes/level_7.tscn":
				gloop.say(["Bloodland...", "The infection is", "very violent!"])

			"res://Assets/Scenes/level_8.tscn":
				gloop.say(["Winter...", "A storm", "hides a secret."])

			"res://Assets/Scenes/level_sunken_amber_valley.tscn":
				gloop.say(["Amber Valley...", "They trap everything", "in amber!"])

			"res://Assets/Scenes/level_lunar_dream.tscn":
				gloop.say(["Lunar Dream...", "Is it really", "real?"])

			"res://Assets/Scenes/level_sakura.tscn":
				gloop.say(["Sakura...", "The last place", "still pure."])

			"res://Assets/Scenes/level_corrupted_bloom.tscn":
				gloop.say(["Here we are...", "The heart of the", "infection!"])

			"res://Assets/Scenes/level_boss.tscn":
				gloop.say(["My King!", "Hold on!", "We're coming!"])

			_:
				gloop.say("Let's go!")
