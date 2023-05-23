extends Node3D

enum States {PLAYER_1_TURN, PLAYER_2_TURN, PLAYER_3_TURN, PLAYER_4_TURN, GAME_OVER}

# For testing purposes, start with player 4 to loop back to player 1
var curstate = States.PLAYER_4_TURN
var game_ending = false
var game_ending_index = 0

@export
var players = []
var curr_player
var player_text

var can_lay_block = true

func _process(delta):
	$UI.display_player(curr_player, player_text)
	
	if (curr_player.tokens_left == 0):
		game_ending = true
		switch_turn()
		game_ending_index = 1
	
func switch_turn():
	
	if (game_ending_index == 4):
		curstate = States.GAME_OVER
		return
		
	if (game_ending):
		game_ending_index += 1
	
	var text = ""
	var player_path = ""
	
	if curstate == States.PLAYER_1_TURN:
		curstate = States.PLAYER_2_TURN
		text = "Player 2: Play"
		player_path = players[1]
	elif curstate == States.PLAYER_2_TURN:
		curstate = States.PLAYER_3_TURN
		text = "Player 3: Play"
		player_path = players[2]
	elif curstate == States.PLAYER_3_TURN:
		curstate = States.PLAYER_4_TURN
		text = "Player 4: Play"
		player_path = players[3]
	elif curstate == States.PLAYER_4_TURN:
		curstate = States.PLAYER_1_TURN
		text = "Player 1: Play"
		player_path = players[0]
	
	curr_player = get_node(player_path)
	player_text = text
	
	$UI.display_player(curr_player, text)
	turn()

func turn():
	move_token(roll_dice())
	can_lay_block = true
	
func roll_dice():
	# Random logic here
	var rand = RandomNumberGenerator.new()
	var num = int((rand.randf_range(0, 1) * 6) + 1)
	
	# Display the visual
	$UI.display_dice(num)
	
	return num
	
func move_token(spaces):
	curr_player.board_position = (curr_player.board_position + spaces) % 20
	curr_player.position = get_node("../Board").get_pos(curr_player.board_position)
	
	curr_player.check_corner()

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_turn()
	turn()

func lay_block(x, y, z):
	if(can_lay_block):
		can_lay_block = !get_node("../Board").lay_block(x, y, z)

# Returns an array with [x_left_bound, x_right_bound, y_left_bound, y_right_bound]
# -1 if no bound
func get_x_y_bound():
	var board_position = curr_player.board_position
	pass
	if (board_position == 0 || board_position == 5 || board_position == 10 || board_position == 15):
		# Corners are an edge case (no pun intended)
		# Return -1 for all bounds
		return [-1, -1, -1, -1]
	elif (board_position == 1 || board_position == 14):
		return [0, 2, -1, -1]
	elif (board_position == 2 || board_position == 13):
		return [2, 4, -1, -1]
	elif (board_position == 3 || board_position == 12):
		return [4, 6, -1, -1]
	elif (board_position == 4 || board_position == 11):
		return [6, 8, -1, -1]
	elif (board_position == 6 || board_position == 19):
		return [-1, -1, 0, 2]
	elif (board_position == 7 || board_position == 18):
		return [-1, -1, 2, 4]
	elif (board_position == 8 || board_position == 17):
		return [-1, -1, 4, 6]
	elif (board_position == 9 || board_position == 16):
		return [-1, -1, 6, 8]
