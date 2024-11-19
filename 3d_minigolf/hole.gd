extends Node3D

enum {AIM, SET_POWER, SHOOT, WIN}

@export var power_speed = 100
@export var angle_speed = 1.1
@export var mouse_sensitivity = 150
@export var next_hole: PackedScene

# Players and states
var players = []
var current_player = 0
var state = AIM
var power = 0
var hole_dir = 0

func _ready():
	# Initialize players
	players = [
		{"name": "Player 1", "ball": get_node("Ball"), "shots": 0},
		{"name": "Player 2", "ball": get_node("Player2Ball"), "shots": 0}
	]
	
	# Ensure nodes exist
	assert(players[0]["ball"] != null and players[1]["ball"] != null, "Ball or Player2Ball not found!")

	# Hide Player 2's ball initially
	players[1]["ball"].hide()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Arrow.hide()
	reset_player_positions()
	change_state(AIM)
	show_message("%s's Turn!" % players[current_player]["name"])
func reset_player_positions():
	players[0]["ball"].position = $Tee.position
	players[1]["ball"].position = $Tee.position  # Offset slightly

func change_state(new_state):
	state = new_state
	var player = players[current_player]
	match state:
		AIM:
			# Reset arrow position and rotation to the current player's ball
			$Arrow.position = player["ball"].position
			$Arrow.rotation.y = 0
			$Arrow.show()
			set_start_angle()
			$CameraGimbal.position = player["ball"].position
		SET_POWER:
			# Reset power for the current shot
			power = 0
			$UI.update_power_bar(power)
		SHOOT:
			# Hide the arrow and apply the shoot logic
			$Arrow.hide()
			player["ball"].shoot($Arrow.rotation.y, power / 15)
			player["shots"] += 1
			$UI.update_shots(current_player, player["shots"])
		WIN:
			# End game for the current player
			player["ball"].hide()
			$Arrow.hide()
			$UI.show_message("%s Wins!" % player["name"])
			await get_tree().create_timer(1.5).timeout
			if next_hole:
				get_tree().change_scene_to_packed(next_hole)

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	if state != WIN:
		if event.is_action_pressed("click"):
			match state:
				AIM:
					change_state(SET_POWER)
				SET_POWER:
					change_state(SHOOT)
		elif event is InputEventMouseMotion:
			if state == AIM:
				$Arrow.rotation.y -= event.relative.x / mouse_sensitivity

func _process(delta):
	if state == SET_POWER:
		# Animate power bar
		power += power_speed * delta
		if power > 100:
			power = 100
		$UI.update_power_bar(power)

func _on_ball_stopped():
	if state == SHOOT:
		switch_player()
		change_state(AIM)

func switch_player():
	# Hide the current player's ball and show the next player's ball
	players[current_player]["ball"].hide()

	# Switch to the next player
	current_player = (current_player + 1) % players.size()

	# Show the next player's ball
	players[current_player]["ball"].show()

	# Display turn message
	show_message("%s's Turn!" % players[current_player]["name"])

func set_start_angle():
	var player = players[current_player]
	var hole_position = Vector2($Hole.position.z, $Hole.position.x)
	var ball_position = Vector2(player["ball"].position.z, player["ball"].position.x)
	hole_dir = (ball_position - hole_position).angle()
	$Arrow.rotation.y = hole_dir

func show_message(text):
	$UI.show_message(text)
