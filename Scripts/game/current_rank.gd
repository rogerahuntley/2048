extends Label

func _ready():
	Leaderboard.connect("high_score_set", self, "set_score")
	text=str(Leaderboard.high_score)

func set_score(score):
	text=str(score)
