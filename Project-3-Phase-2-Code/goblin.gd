extends CharacterBody2D

@export var health = 2  # Goblin starts with 2 health
@onready var animation_player = $AnimatedSprite2D  # Animation node

signal died

var direction = 1  # Default movement direction
var is_idle = false
const SPEED = 100.0  
const IDLE_TIME = 2.0  
const MOVE_TIME = 4.0  
const GRAVITY = 500.0

func _ready():
	start_idle()

# Goblin idle state and behavior
func start_idle() -> void:
	is_idle = true
	animation_player.play("Idle")
	velocity.x = 0
	await get_tree().create_timer(IDLE_TIME).timeout
	start_moving()

# Goblin movement logic
func start_moving() -> void:
	is_idle = false
	animation_player.play("Run")
	direction = 1 if randf() > 0.5 else -1  # Randomly choose direction
	await get_tree().create_timer(MOVE_TIME).timeout
	start_idle()

# Function to handle taking damage
func take_damage():
	health -= 1
	animation_player.play("hurt")  # Play hurt animation
	
	if health <= 0:
		die()  # Call death function if health reaches 0
	else:
		# Briefly pause movement after taking damage
		await get_tree().create_timer(0.5).timeout
		start_moving()

# Function to handle the goblin's death
func die():
	queue_free()  # Remove from scene

	print("Goblin is dying!")  # Debugging message
	animation_player.play("Dead")  # Play death animation
	queue_free()  # Remove from scene
# Movement and gravity handling
func _physics_process(delta: float) -> void:
	if is_idle:
		return 
	
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Goblin horizontal movement
	velocity.x = direction * SPEED
	move_and_slide()

	# Flip sprite based on direction
	animation_player.flip_h = direction < 0

	# Reverse direction on collision
	if is_on_wall():
		direction *= -1
