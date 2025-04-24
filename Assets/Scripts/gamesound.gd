extends AudioStreamPlayer

func _ready():
	play()  # Joue la musique au démarrage

func _exit_tree():
	if $"/root/Main/Audio/GameSound":
		$"/root/Main/Audio/GameSound".stop()
		$"/root/Main/Audio/GameSound".stream = null  # Libère la musique de la mémoire
