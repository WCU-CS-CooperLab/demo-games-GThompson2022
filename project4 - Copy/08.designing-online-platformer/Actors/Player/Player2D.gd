extends CharacterBody2D

signal died

@onready var animated_sprites = $AnimatedSprite2D  # Reference to the direct child AnimatedSprite2D
@onready var label = $Label

var direction = 0.0  # Tracks horizontal input
@export var jump_speed = -300  # The speed of the jump (negative for upward movement)

@rpc("any_peer", "call_local")
func setup_multiplayer(player_id):
	set_multiplayer_authority(player_id)
	var is_player = player_id == get_multiplayer_authority()
	set_physics_process(is_player)
	set_process_unhandled_input(is_player)

func _physics_process(delta):
	# Handle input for horizontal movement
	direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * 200  # Adjust movement speed (200 is an example)

	# Apply gravity
	if not is_on_floor():
		velocity.y += 400 * delta  # Adjust gravity strength
	else:
		velocity.y = 0.0

	# Check for jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():  # Space bar by default
		velocity.y = jump_speed
		animated_sprites.play("jump")  # Play jump animation when jumping

	# Apply movement
	move_and_slide()  # Automatically uses the built-in velocity

	# Flip sprite based on direction
	if direction > 0:
		animated_sprites.flip_h = false
	elif direction < 0:
		animated_sprites.flip_h = true

	# Handle animations
	if is_on_floor():
		if direction != 0.0:
			animated_sprites.play("walk")
		else:
			animated_sprites.play("idle")
	else:
		if velocity.y < 0:  # Only play the jump animation if moving upward
			animated_sprites.play("jump")
