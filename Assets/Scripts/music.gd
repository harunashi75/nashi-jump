extends AudioStreamPlayer

var excluded_scenes := [
	"res://Assets/Scenes/start_menu.tscn",
	"res://Assets/Scenes/level_victory.tscn",
	"res://Assets/Scenes/level_void.tscn"
]

func _ready():
	await get_tree().process_frame
	_check_music()
	monitor_scene_changes()

func _check_music():
	var current_scene = get_tree().current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		if scene_path in excluded_scenes:
			if playing:
				stop()
		else:
			if not playing:
				play()

func monitor_scene_changes():
	var last_scene = get_tree().current_scene
	while true:
		await get_tree().process_frame
		var current_scene = get_tree().current_scene
		if current_scene != last_scene:
			_check_music()
			last_scene = current_scene
