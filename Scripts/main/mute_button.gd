extends TextureButton

onready var music = get_node("/root/Music")

func _ready():
	pressed = !music.playing

func _pressed():
	if music.playing:
		music.pause()
	else:
		music.resume()
