extends AudioStreamPlayer

var position

func resume():
	play(position)
	pass

func pause():
	position = get_playback_position()
	stop()
	pass
