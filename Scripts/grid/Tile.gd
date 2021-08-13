extends Node

export(NodePath) onready var background_sprite = get_node(background_sprite) as Sprite
onready var box_scene = preload("res://Scenes/Box.tscn")

var value = 0
var grid_position = []
var size = 0
var grid = null
var currentbox = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if randi() % 2 == 1:
		background_sprite.flip_h = true
	if randi() % 2 == 1:
		background_sprite.flip_v = true
	pass # Replace with function body.

func init(grid, x, y, size):
	self.grid = grid
	grid_position = [x,y]
	self.size = size
	
func set_value(val):
	value = val
	if currentbox != null:
		currentbox.set_value(val)

func get_position():
	var x = grid_position[0]
	var y = grid_position[1]
	return Vector2(x * size, y * size)
	

func spawn_box(num):
	var box = box_scene.instance()
	currentbox = box
	# add to top to avoid drawing on top of others
	grid.boxes.add_child(box)
	box.set_position(get_position())
	box.play_spawn()
	grid.spawn_pop.play()
	set_value(num)

func move_box(target_tile):
	if !currentbox:
		return
	currentbox.move_to(target_tile.get_position())
	target_tile.currentbox = currentbox
	currentbox = null
	target_tile.value = value;
	value = 0

func combine_box(target_tile):
	if !currentbox:
		return
	currentbox.combine_at(target_tile.get_position())
	currentbox = null
	var new_value = target_tile.value + value
	target_tile.currentbox.sched_play_combine()
	target_tile.currentbox.change_value(new_value)
	target_tile.value = new_value;
	value = 0
	grid.add_score(new_value)
