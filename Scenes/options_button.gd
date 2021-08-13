extends Button

export(NodePath) onready var grid = get_node(grid) as Node

func _pressed():
	grid.options_pop()
