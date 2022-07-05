extends VBoxContainer

export var entry_path: String
export(NodePath) onready var load_error = get_node(load_error) as Label

func _ready():
	Leaderboard.connect("leaderboard_loaded", self, "replace_entries")
	Leaderboard.load_leaderboard()
	add_entries()

func replace_entries(_res = null):
	clear_entries()
	add_entries()

func add_entries():
	load_error.visible = Leaderboard.leaderboard.size() == 0
	for i in range(0, Leaderboard.leaderboard.size()):
		var entry = Leaderboard.leaderboard[i]
		add_entry(i + 1, entry.player_name, entry.score)

func clear_entries():
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()

func add_entry(index, player, score):
	var entry = load(entry_path).instance()
	add_child(entry)
	entry.set_data(index, player, score)
