extends Label

export(NodePath) onready var grid = get_node(grid) as Node

var high_score = 0

var save_file = File.new()
var save_path = "user://hs.save"
var save_data = {"high_score": high_score}

func _ready():
	if !save_file.file_exists(save_path):
		save_score()
	high_score = load_score()
	set_score_display(high_score)

func _process(delta):
	if grid.score > high_score:
		high_score = grid.score
		save_score()
		set_score_display(high_score)

func set_score_display(score):
	text = str(score)

func save_score():
	save_data["high_score"] = high_score
	save_file.open(save_path, File.WRITE)
	save_file.store_var(save_data)
	save_file.close()

func load_score():
	save_file.open(save_path, File.READ)
	save_data = save_file.get_var()
	save_file.close()
	print(save_data["high_score"])
	return save_data["high_score"]
