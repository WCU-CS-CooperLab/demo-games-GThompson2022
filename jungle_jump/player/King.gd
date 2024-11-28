extends CharacterBody2D

signal life_changed
signal died

@export var gravity = 750
@export var walk_speed = 150
@export var run_speed = 300
@export var jump_speed = -300
@export var max_jumps = 2
@export var double_jump_factor = 1.5
@onready var AttackArea = $AttackArea  # The Area2D representing the attack hitbox
@onready var attack_area_shape = $AttackArea/CollisionShape2D  # The collision shape for detecting collisions
@export var attack_animation: String = "hit"  # Attack animation name

enum {IDLE, WALK, RUN, JUMP, HURT, DEAD, HIT}
var state = IDLE
var jump_count = 0
var life = 3  # Player starts with 3 lives
var invincible = false  # To prevent being hurt multiple times in quick succession

# Player setup and attack logic
func _ready():
	change_state(IDLE)
	attack_area_shape.disabled = true  # Ensure the attack area is disabled initially
	AttackArea.connect("body_entered", Callable(self, "_on_attack_area_entered"))

func reset(_position):
	position = _position
	show()
	change_state(IDLE)
	life = 3  # Reset life to 3 when restarting

func _process(delta):
	if Input.is_action_just_pressed("Attack"):
		# Play the attack animation
		$AnimatedSprite2D.play(attack_animation)

		# Enable the attack area collision detection
		attack_area_shape.disabled = false

		# Wait for the attack animation to finish, then disable the AttackArea
		await $AnimatedSprite2D.animation_finished
		attack_area_shape.disabled = true  # Disable after attack

# When the attack area enters a body, check for an enemy and deal damage
func _on_attack_area_entered(area):
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		area.take_damage()  # Call the enemy's take_damage method

# Handle the player's hurt logic
func hurt():
	if invincible or state == HURT:
		return
	$HurtSound.play()  # Play hurt sound effect
	change_state(HURT)

	life -= 1
	if life <= 0:
		change_state(DEAD)  # Trigger death state when health reaches 0
	else:
		invincible = true
		await get_tree().create_timer(1.0).timeout  # 1 second of invincibility
		invincible = false

	life_changed.emit(life)  # Emit life change signal to update HUD or UI

# Input handling for player movement and jumping
func get_input():
	if state == HURT:
		return

	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var run = Input.is_action_pressed("Run")

	velocity.x = 0
	if right:
		velocity.x += run_speed if run else walk_speed
		$AnimatedSprite2D.flip_h = false
	if left:
		velocity.x -= run_speed if run else walk_speed
		$AnimatedSprite2D.flip_h = true

	# Jumping
	if jump and is_on_floor():
		$JumpSound.play()
		change_state(JUMP)
		velocity.y = jump_speed
	elif jump and state == JUMP and jump_count < max_jumps:
		$JumpSound.play()
		$AnimatedSprite2D.play("jump")
		velocity.y = jump_speed / double_jump_factor
		jump_count += 1

# State handling for different actions like idle, walking, etc.
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimatedSprite2D.play("idle")
		WALK:
			$AnimatedSprite2D.play("walk")
		RUN:
			$AnimatedSprite2D.play("run")
		JUMP:
			$AnimatedSprite2D.play("jump")
			jump_count = 1
		HIT:
			$AnimatedSprite2D.play("hit")
			await get_tree().create_timer(0.2).timeout
			if state == HIT:
				change_state(IDLE)
		HURT:
			$AnimatedSprite2D.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(IDLE if life > 0 else DEAD)
		DEAD:
			$AnimatedSprite2D.play("dead")
			died.emit()  # Trigger death signal
			hide()

# Physics process for movement and collisions
func _physics_process(delta):    
	velocity.y += gravity * delta
	get_input()
	move_and_slide()

	if state == HURT:
		return
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("danger"):
			hurt()
		if collision.get_collider().is_in_group("enemies"):
			if position.y < collision.get_collider().position.y:
				collision.get_collider().take_damage()
				velocity.y = -200
			else:
				hurt()

	if state == JUMP and is_on_floor():
		change_state(IDLE)
		jump_count = 0
		$Dust.emitting = true
