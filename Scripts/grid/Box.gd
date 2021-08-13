extends Node2D

export(NodePath) onready var value_label = get_node(value_label) as Label
export(NodePath) onready var tween = get_node(tween) as Tween
export(NodePath) onready var sprite = get_node(sprite) as Sprite
export(NodePath) onready var animation = get_node(animation) as AnimationPlayer


export var colors = {
	2: Color("68C3D4"),
	4: Color("D38B5D"),
	8: Color("568EA3"),
	16: Color("739E82"),
	32: Color("2C5530"),
	64: Color("993955"),
	128: Color("AE76A6"),
	256: Color("32936F"),
	512: Color("E83F6F"),
	1024: Color("2274A5"),
	2048: Color("FF6B6B") 
}

func move_to(vector2):
	tween.interpolate_property(self, "position", get_position(), vector2, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func combine_at(vector2):
	tween.interpolate_callback(self, 1, "destroy")
	move_to(vector2)

func change_value(value):
	tween.interpolate_callback(self, 1, "set_value", value)
	tween.start()

func sched_play_combine():
	tween.interpolate_callback(self, 1, "play_combine")
	tween.start()

func set_value(value):
	if value != 0:
		value_label.text = str(value)
		set_color(value)
	else:
		value_label.text = ""

func set_color(value):
	if colors.has(value):
		sprite.self_modulate = colors[value]
	else:
		randomize()
		var color = Color(randf(), randf(), randf())
		colors[value] = color
		sprite.self_modulate = color

func play_spawn():
	animation.play("spawn")

func play_combine():
	animation.play("combine")

func destroy():
	queue_free()
