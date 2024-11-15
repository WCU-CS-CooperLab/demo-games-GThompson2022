extends Area2D

signal pickup
signal hurt

@export var speed = 350
var velocity = Vector2.ZERO
var screensize = Vector2(480, 720)
@export var player_number = 1  # 1 for Player 1, 2 for Player 2

var is_invincible = false
var invincibility_timer = 2.0  # 2 seconds of invincibility

func _ready():
	# Create a Timer node dynamically if it doesn't exist in the scene
	if not has_node("InvincibilityTimer"):
		var timer = Timer.new()
		timer.name = "InvincibilityTimer"
		timer.one_shot = true
		timer.wait_time = invincibility_timer
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_invincibility_timeout"))

func _process(delta):
	# Determine input based on player_number
	if player_number == 1:
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
		velocity = Input.get_vector("ui_left_2", "ui_right_2", "ui_up_2", "ui_down_2")

	position += velocity * speed * delta
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)

	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "run"
	else:
		$AnimatedSprite2D.animation = "idle"

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

func start():
	set_process(true)
	position = screensize / 2
	$AnimatedSprite2D.animation = "idle"
	become_invincible()  # Activate invincibility when the game starts

func die():
	$AnimatedSprite2D.animation = "hurt"
	set_process(false)

func _on_area_entered(area):
	# Check if player is not invincible before emitting hurt signal
	if not is_invincible:
		if area.is_in_group("enemy") or area.is_in_group("goblin"):
			hurt.emit()
			die()
			return
	
	# Pickup events can still be handled even when invincible
	if area.is_in_group("coins"):
		area.pickup()
		pickup.emit("coin")
	elif area.is_in_group("powerups"):
		area.pickup()
		pickup.emit("powerup")

func become_invincible():
	is_invincible = true
	$InvincibilityTimer.start()

func _on_invincibility_timeout():
	is_invincible = false  # Disable invincibility after the timer runs out
