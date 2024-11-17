extends CharacterBody2D

signal life_changed
signal died

@export var gravity = 750
@export var walk_speed = 150
@export var run_speed = 300
@export var jump_speed = -300
@export var max_jumps = 2
@export var double_jump_factor = 1.5

enum {IDLE, WALK, RUN, JUMP, HURT, DEAD, HIT}
var state = IDLE
var jump_count = 0
var life = 3: 
	set = set_life

func _ready():
	change_state(IDLE)

func reset(_position):
	position = _position
	show()
	change_state(IDLE)
	life = 3
	
func hurt():
	if state != HURT:
		$HurtSound.play()
		change_state(HURT)
	
func get_input():
	if state == HURT:
		return  # Don't allow movement during hurt state
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var run = Input.is_action_pressed("Run")
	var attack = Input.is_action_just_pressed("Attack")
	
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

	# Attacking
	if attack:
		change_state(HIT)

	# IDLE transitions
	if state in [IDLE, WALK] and velocity.x != 0:
		change_state(RUN if run else WALK)
	elif state == RUN and not run and velocity.x == 0:
		change_state(IDLE)

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
			$AnimatedSprite2D.play("hit")  # Use the "hit" animation
			#$AttackSound.play()
			await get_tree().create_timer(0.2).timeout
			if state == HIT:  # Ensure no interruption
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
			died.emit()
			hide()

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

func set_life(value):
	life = value
	life_changed.emit(life)
