extends Label

func _ready():
	if Leaderboard.position is GDScriptFunctionState:
		yield(Leaderboard.position, "completed")
	text=str(Leaderboard.position)
