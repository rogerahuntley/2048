extends Node

signal swiped

var swipe_start
var minimum_dist = 75
var quick_trigger = 150

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		elif swipe_start != null:
			var distance = swipe_start.distance_to(event.position)
			if distance > minimum_dist:
				calculate_swipe(swipe_start.direction_to(event.position))
	if event is InputEventScreenDrag:
		if abs(event.speed.x) > quick_trigger || abs(event.speed.y) > quick_trigger:
			if swipe_start != null:
				calculate_swipe(swipe_start.direction_to(event.position))
				print(swipe_start.direction_to(event.position))
				swipe_start = null

func calculate_swipe(dist):
	if dist.x > .5:
		emit_signal("swiped", "right")
	elif dist.x < -.5:
		emit_signal("swiped", "left")
	elif dist.y > .5:
		emit_signal("swiped", "down")
	elif dist.y < -.5:
		emit_signal("swiped", "up")
