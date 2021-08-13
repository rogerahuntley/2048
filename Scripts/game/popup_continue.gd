extends Button

export(NodePath) onready var popup = get_node(popup) as PopupDialog
export(NodePath) onready var grid = get_node(grid) as Node

func _pressed():
	grid.can_move = true
	popup.visible = false
