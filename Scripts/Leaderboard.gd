extends Node

signal score_set(score)
signal high_score_set(score)
signal high_score_publish(score)
signal user_name_set(user)

signal leaderboard_loaded

export var user = ""
export var score = 0
export var high_score = 0
export var rank = 0

var leaderboard = []
var position = 0

var save_file = File.new()
var save_path = "user://hs.save"
var save_data = {"high_score": high_score, "user": user}

func _ready():
	# load high score from file
	if !save_file.file_exists(save_path):
		set_empty_save()
	load_high_score()
	
	# load leaderboard with silent wolf
	configure_SW()
	leaderboard = load_leaderboard()
	position = get_rank_position(high_score)
	
	# register signals
	self.connect('score_set', self, 'set_score')
	self.connect('high_score_set', self, 'set_high_score')
	self.connect('high_score_publish', self, 'publish_high_score')
	self.connect('user_name_set', self, 'set_user_name')
	
	set_empty_save()

func configure_SW():
	var env = ResourceLoader.load('env.tres')
	var SW_KEY = env.SILENT_WOLF_KEY
	
	SilentWolf.configure({
		"api_key": SW_KEY,
		"game_id": "2048",
		"game_version": "1.3.0",
		"log_level": 0
	})

func save_high_score():
	save_data["high_score"] = high_score
	save_data["user"] = user
	save_file.open(save_path, File.WRITE)
	save_file.store_var(save_data)
	save_file.close()

func load_high_score():
	save_file.open(save_path, File.READ)
	save_data = save_file.get_var()
	save_file.close()
	high_score = save_data["high_score"]
	if 'user' in save_data:
		user = save_data['user']

func load_leaderboard():
	yield(SilentWolf.Scores.get_high_scores(10), "sw_scores_received")
	leaderboard =  SilentWolf.Scores.scores
	self.emit_signal("leaderboard_loaded")

func get_rank_position(score = self.high_score, user = self.user):
	var score_id = null
	
	# see if in leaderboard
	yield(self.leaderboard, "completed")
	for entry in self.leaderboard:
		if entry.player_name == self.user && entry.score == self.high_score:
			score_id = entry.score_id
	
	if score_id == null:
		yield(SilentWolf.Scores.get_score_position(score), "sw_position_received")
	else:
		yield(SilentWolf.Scores.get_score_position(score_id), "sw_position_received")
	position = int(SilentWolf.Scores.position)

func can_publish():
	return self.user != ""

func set_empty_save():
	save_data = {"high_score": high_score, "user": ""}
	save_file.open(save_path, File.WRITE)
	save_file.store_var(save_data)
	save_file.close()
	load_high_score()
	self.emit_signal("high_score_set", high_score)
	self.emit_signal("user_name_set", user)

# signal functions

func set_score(score: int):
	self.score = score
	set_high_score(score)

func set_high_score(score: int):
	if score > high_score:
		high_score = score
		save_high_score()

func publish_high_score(score: int, username: String = self.user):
	save_high_score()
	if can_publish():
		load_leaderboard()
	
func set_user_name(user: String):
	self.user = user
