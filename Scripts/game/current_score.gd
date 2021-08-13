extends Label

export(NodePath) onready var grid = get_node(grid) as Node

func _process(delta):
	set_score_display(grid.score)

func set_score_display(score):
	text = str(score)
