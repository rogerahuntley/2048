extends Label

func _ready():
	Leaderboard.connect("score_set", self, "set_score")
	text=str(Leaderboard.score)

func set_score(score):
	text=str(score)
