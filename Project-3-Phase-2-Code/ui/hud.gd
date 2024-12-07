extends MarginContainer

@onready var life_counter = $HBoxContainer/LifeCounter.get_children()
@onready var score_label = $HBoxContainer/Score
@onready var message_label = $Message
@onready var timer = $Timer  # Ensure this matches the actual path in your scene tree

func update_life(value: int):
	for i in range(life_counter.size()):
		life_counter[i].visible = value > i

func show_message(text: String):
	message_label.text = text
	message_label.show()
	timer.wait_time = 3.0  # Set duration if not already done
	timer.start()
	print("Timer started, duration:", timer.wait_time)



func _on_timer_timeout() -> void:
	message_label.hide()  # Hides the message when the timer finishes
	print("Timer timeout triggered, message hidden.")  # Debugging output
