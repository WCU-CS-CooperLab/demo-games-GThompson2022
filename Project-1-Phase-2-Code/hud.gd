extends CanvasLayer

signal start_game

func update_score_player1(value):
	$MarginContainer/ScorePlayer1.text = str(value)

func update_score_player2(value):
	$MarginContainer/ScorePlayer2.text = str(value)

func update_timer(value):
	$MarginContainer/Time.text = str(value)

func show_message(text):
	$Message.text = text
	$Message.show()
	$Timer.start()

func _on_timer_timeout():
	$Message.hide()

func _on_start_button_pressed():
	$StartButton.hide()
	$Message.hide()
	start_game.emit()

func show_game_over():
	show_message("Game Over")
	await $Timer.timeout
	$StartButton.show()
	$Message.text = "Knight's Tale"
	$Message.show()
