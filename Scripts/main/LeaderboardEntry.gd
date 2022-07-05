extends VBoxContainer

export(NodePath) onready var rank = get_node(rank) as Label
export(NodePath) onready var user = get_node(user) as Label
export(NodePath) onready var points = get_node(points) as Label

func set_data(rank, user, points):
	self.rank.text = '#' + str(rank)
	if user == Leaderboard.user && points == Leaderboard.high_score:
		self.user.text = user
	else:
		self.user.text = "User " + str(rank)
	self.points.text = str(points)
