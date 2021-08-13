extends Label

var save_file = File.new()
var save_path = "user://hs.save"

func _ready():
	if save_file.file_exists(save_path):
		set_score_display(load_score())

func set_score_display(score):
	text = str(score)

func load_score():
	save_file.open(save_path, File.READ)
	var save_data = save_file.get_var()
	save_file.close()
	print(save_data["high_score"])
	return save_data["high_score"]
