extends Node3D

enum { AIM, SET_POWER, SHOOT, WIN }

@export var power_speed = 100
@export var angle_speed = 1.1
@export var mouse_sensitivity = 150
@export var next_hole : PackedScene

var angle_change = 1
var power_change = 1
var shots = 0
var state = AIM
var power = 0
var hole_dir = 0
var is_reloading = false
var player1_score = 0
var player2_score = 0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Arrow.hide()
	$Spacesong.play()

	# Reset reload flag
	is_reloading = false

	# Disconnect signals to avoid conflicts
	if $Ball.is_connected("stopped", Callable(self, "_on_ball_stopped")):
		$Ball.disconnect("stopped", Callable(self, "_on_ball_stopped"))
	if $Player2Ball.is_connected("stopped", Callable(self, "_on_ball_stopped")):
		$Player2Ball.disconnect("stopped", Callable(self, "_on_ball_stopped"))
	# Connect only the active ball
	if GameState.current_player == 1:
		$Ball.position = $Tee.position
		$Ball.show()
		$Player2Ball.hide()
		# Correct connection using Callable
		$Ball.connect("stopped", Callable(self, "_on_ball_stopped"))
	else:
		$Player2Ball.position = $Tee.position
		$Player2Ball.show()
		$Ball.hide()
		# Correct connection using Callable
		$Player2Ball.connect("stopped", Callable(self, "_on_ball_stopped"))

	$CameraGimbal.rotation.y = PI / 2
	$CameraGimbal/GimbalInner.rotation.x = -1
	change_state(AIM)
	$UI.show_message("Get Ready, Player %d!" % GameState.current_player)



func change_state(new_state):
	state = new_state
	var active_ball = get_current_ball()
	match state:
		AIM:
			$Arrow.position = active_ball.position
			$Arrow.show()
			set_start_angle()
			$CameraGimbal.position = active_ball.position
			$CameraGimbal.rotation.y = $Arrow.rotation.y
		SET_POWER:
			power = 0
		SHOOT:
			$Arrow.hide()
			active_ball.shoot($Arrow.rotation.y, power / 15)
			shots += 1
			$UI.update_shots(shots)
		WIN:
			if is_reloading:
				return
			is_reloading = true
			
			if GameState.current_player == 1:
				player1_score += shots
				GameState.current_player = 2
				shots = 0
				$UI.show_message("Player 1 finished! Player 2, get ready!")
				await get_tree().create_timer(1.5).timeout
				get_tree().reload_current_scene()  # Reload current scene for Player 2
			else:
				player2_score += shots
				shots = 0
				$UI.show_message("Player 2 Wins!")
				await get_tree().create_timer(1).timeout
				
				if next_hole:  # Transition to the next level after Player 2 wins
					GameState.current_player = 1  # Reset to Player 1 for the next hole
					get_tree().change_scene_to_packed(next_hole)  # Load the next hole
				else:
				# If no next hole is defined, reset to Player 1 and reload the current scene
					declare_winner()

func declare_winner():
	if player1_score < player2_score:
		$UI.show_message("Player 1 Wins with %d shots! Player 2 had %d shots." % [player1_score, player2_score])
	elif player2_score < player1_score:
		$UI.show_message("Player 2 Wins with %d shots! Player 1 had %d shots." % [player2_score, player1_score])
	else:
		$UI.show_message("It's a tie! Both players had %d shots." % player1_score)
	GameState.current_player = 1
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion:
		if state == AIM and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			$Arrow.rotation.y -= event.relative.x / mouse_sensitivity
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		match state:
			AIM:
				change_state(SET_POWER)
			SET_POWER:
				change_state(SHOOT)

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	if state != WIN:
		$CameraGimbal.position = get_current_ball().position
	match state:
		SET_POWER:
			animate_power(delta)
		SHOOT:
			pass

func animate_power(delta):
	power += power_speed * power_change * delta
	if power >= 100:
		power_change = -1
	if power <= 0:
		power_change = 1
	$UI.update_power_bar(power)

func set_start_angle():
	var hole_position = Vector2($Hole.position.z, $Hole.position.x)
	var ball_position = Vector2(get_current_ball().position.z, get_current_ball().position.x)
	hole_dir = (ball_position - hole_position).angle()
	$Arrow.rotation.y = hole_dir

func get_current_ball():
	return $Ball if GameState.current_player == 1 else $Player2Ball

func _on_hole_body_entered(body):
	print("Body entered hole:", body)
	var current_ball = get_current_ball()
	if body == current_ball:
		print("Player %d wins this hole!" % GameState.current_player)
		change_state(WIN)


func _on_ball_stopped():
	var active_ball = get_current_ball()
	print("Ball stopped for: %s (Active: %s)" % [active_ball.name, GameState.current_player])
	
	if state == SHOOT:
		print("Transitioning to AIM for Player %d" % GameState.current_player)
		change_state(AIM)

	# Ensure this logic only applies to the current player’s ball
	if state == SHOOT and active_ball.name == get_current_ball().name:
		print("Ball stopped for Player %d" % GameState.current_player)

	# Transition back to AIM after the ball stops
		change_state(AIM)

func _on_blackhole_body_entered(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(1.495, 0.5, -4.51)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)


func _on_blackhole_body_entered2(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(0.5, 0.5, -5.495)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)

func _on_blackhole_body_entered3(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(-0.49, 0.5, 0.699)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)


func _on_blackhole_body_entered4(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(3.505, 0.5, -6.503)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)


func _on_blackhole_body_entered5(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(-0.485, -1.313, -12.682)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)

func _on_blackhole_body_entered6(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(-0.49, 0.649, 0.699)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)

func _on_blackhole_body_entered7(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(-0.485, -1.313, -12.682)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)

func _on_blackhole_body_entered8(body):
	var current_ball = get_current_ball()
	if body == current_ball:
		var teleport_position = Vector3(-0.49, 0.649, 0.699)  # Set the target position
		current_ball.global_transform.origin = teleport_position
		print("Teleported the ball to: ", teleport_position)
