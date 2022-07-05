extends Node2D

export(NodePath) onready var tween = get_node(tween) as Tween
export(NodePath) onready var spawn_pop = get_node(spawn_pop) as AudioStreamPlayer

export(NodePath) onready var fail_popup = get_node(fail_popup) as PopupDialog
export(NodePath) onready var win_popup = get_node(win_popup) as PopupDialog
export(NodePath) onready var options_popup = get_node(options_popup) as PopupDialog

export(NodePath) onready var tiles = get_node(tiles) as Node2D
export(NodePath) onready var boxes = get_node(boxes) as Node2D

export(NodePath) onready var swipe = get_node(swipe) as Node

onready var tile_scene = preload("res://Scenes/Tile.tscn")

var tileGrid = []
var height = 4
var width = 4
var size = 600/width
var startingTiles = 2
var can_move = true

var has_won = false

var score = 0

var swipe_dir

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	buildArray()
	for t in startingTiles:
		addRandom()
	var direction
	swipe.connect("swiped", self, "set_direction")

func set_direction(dir):
	swipe_dir = dir

func reset():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func end_fail():
	Leaderboard.emit_signal("high_score_set", self.score)
	can_move = false
	if !fail_popup.visible:
		fail_popup.popup_centered()

func options_pop():
	can_move = false
	if !options_popup.visible:
		options_popup.popup_centered()

func end_win():
	Leaderboard.emit_signal("high_score_set", self.score)
	can_move = false
	has_won = true
	if !win_popup.visible:
		win_popup.popup_centered()

# creates an empty 4 x 4 grid
func buildArray():
	var tempGridy = []
	for _y in width:
		var tempGridx = []
		
		for _x in height:
			var tile = tile_scene.instance()
			tiles.add_child(tile)
			tile.set_position(Vector2(_x * size + 75, _y * size + 75))
			tile.init(self, _x, _y, size)
			tempGridx.append(tile);
			
		tempGridy.append(tempGridx)
	tileGrid = tempGridy

# print 2d array in a square
func printArray():
	print("----")
	print(simple_array())
		
func simple_array():
	var arr = []
	for x in tileGrid:
		var arrx = []
		for y in x:
			arrx.push_back(y.value)
		arr.push_back(arrx)
	return arr

# register player input
func _input(event):
	var tempArray = simple_array()
		
	if (event.is_action_pressed("ui_left") || swipe_dir == "left") && can_move:
		left()
		
	if (event.is_action_pressed("ui_right") || swipe_dir == "right") && can_move:
		right()
		
	if (event.is_action_pressed("ui_up") || swipe_dir == "up") && can_move:
		up()
		
	if (event.is_action_pressed("ui_down") || swipe_dir == "down") && can_move:
		down()
	
	# clear swipe queue
	swipe_dir = null
	
	if !has_won && checkWin():
		end_win()
	
	if checkFull():
		if checkFail():
			end_fail()
	
	#check again, should be different
	if tempArray != simple_array():
		addRandom()
		#tween.interpolate_callback(self, 1, "addRandom")
		#tween.start()

func compressLine(y):
	# starting from the leftmost going right
	y = y.duplicate();
	var lastCombo = -1
	for x in y.size():
		# set pointer to start at current tile
		var curx = x
		# bool to stop moving across
		var stopped = false
		# limit for how far left it can go
		while !stopped:
		
			if curx == lastCombo+1:
				stopped = true
				break;
			if y[curx-1].value == 0:
				curx -= 1
			elif y[curx-1].value == y[x].value:
				curx -= 1
				stopped = true
				break;
			else:
				stopped = true
				break;
		# check if difference
		if curx != x:
			#if so, move
			if(y[curx].value != 0):
				# check last combination
				lastCombo = curx;
			# move
			# skip moving 0
			if y[curx].value == 0:
				y[x].move_box(y[curx])
			y[x].combine_box(y[curx])
	return y

func left():
	# for every line
	for y in height:
		tileGrid[y] = compressLine(tileGrid[y]);
	pass

func right():
	#for every line but rightmost first
	for y in height:
		# meke empty array
		var backArr = []
		# flip the array we want
		for x in width:
			backArr.push_front(tileGrid[y][x])
		# send it through
		backArr = compressLine(backArr)
		# flip the array back to normal
		for x in width:
			tileGrid[y][x] = backArr[width-1-x];
	pass

func up():
	# starting from the topmost going down
	for x in width:
		# meke empty array
		var backArr = []
		# flip the array we want
		for y in height:
			backArr.push_back(tileGrid[y][x])
		# send it through
		backArr = compressLine(backArr)
		# flip the array back to normal
		for y in height:
			tileGrid[y][x] = backArr[y];
	pass

func down():
	# starting from the bottommost going up
	for x in width:
		# meke empty array
		var backArr = []
		# flip the array we want
		for y in height:
			backArr.push_front(tileGrid[y][x])
		# send it through
		backArr = compressLine(backArr)
		# flip the array back to normal
		for y in height:
			tileGrid[y][x] = backArr[height-1-y];
	pass

# add a new tile to a random empty tile
func addRandom():
	# check if full
	if !checkFull():
		# find empty
		var yx = findEmpty()
		var y = yx[0]
		var x = yx[1]
		# replace empty with new 2 tile
		tileGrid[y][x].spawn_box(2);

# given 
func findEmpty():
	randomize()
	var x = randi() % height
	var y = randi() % width
	if tileGrid[y][x].value == 0:
		return [y, x]
	else:
		return findEmpty()

# check to see if any tile is 2018
func checkWin():
	for x in width:
		for y in width:
			if tileGrid[x][y].value >= 2048:
				return true
	return false

# check to see if every tile is currently occupied
func checkFull():
	# loop through every tile
	for x in width:
		for y in height:
			# check against 0
			if tileGrid[x][y].value == 0:
				# return if 0 found
				return false
	# must all be non-0
	return true

# check to see if no tiles can be combined
func checkFail():
	# loop through every tile
	for x in width:
		for y in height:
			# check adjacent
			var curTile = tileGrid[x][y].value
			# don't check edge pieces
			if x < width - 1:
				# check tile underneath
				if curTile == tileGrid[x+1][y].value:
					return false
			if y < height-1:
				# check tile to the right
				if curTile == tileGrid[x][y+1].value:
					return false
	return true

func allow_move():
	can_move = true

func add_score(score):
	self.score += score
	Leaderboard.emit_signal("score_set", self.score)
