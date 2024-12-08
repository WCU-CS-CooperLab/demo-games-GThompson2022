extends CharacterBody2D

const EMISSION_TEXTURES = {
	"idle": 	preload("res://Sprites/Gothicvania/Characters/Enemies/Fill/Nightmare/nightmare-idle-emission.png"),
	"run": 	preload("res://Sprites/Gothicvania/Characters/Enemies/Fill/Nightmare/nightmare-galloping-emission.png"),
}

@export var contact_damage = 1
@export var life = 15

var move_direction = -1
@onready var move_speed = 13 * GlobalValues.CELL_SIZE
@onready var hurt_knockback = Vector2(7 * GlobalValues.CELL_SIZE, -8 * GlobalValues.CELL_SIZE)

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $Body/Sprite2D

var idle_time = 4.0
var run_time = 3.0

var velocity = Vector2()
var snap_vector = Vector2.ZERO

func apply_gravity(delta):
	velocity.y += GlobalValues.gravity * delta

func apply_movement(_delta):
	var stop_on_slope = true if get_floor_velocity().x == 0 else false	
	set_velocity(velocity)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap_vector`
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(stop_on_slope)
	set_max_slides(4)
	set_floor_max_angle(1)
	move_and_slide()
	velocity = velocity
	snap_vector = Vector2(0,24) if is_on_floor() else Vector2(0,0)
	
	if $StateMachine.state != $StateMachine.states.death and is_on_floor():
		if  is_on_wall() or not $Body/FloorRaycast.is_colliding():
			move_direction *= -1		
		
	$Body.scale.x = - move_direction
	
func apply_horizontal_movement(_delta):
	velocity.x = move_speed * move_direction

	
func damage(quantity, damage_dealer):
	life -= quantity
	if life <= 0:
		$StateMachine.set_state($StateMachine.states.death)
	else:
		var knockback_direction = -1 if self.global_position < damage_dealer.global_position else 1
		hurt_knockback.x = knockback_direction * abs(hurt_knockback.x)
				
		$StateMachine.set_state($StateMachine.states.hurt)
	
func apply_hurt_knockback():
	snap_vector = Vector2()
	velocity = hurt_knockback	

func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)

func die():
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$Body/Sprite2D.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	await $Body/DeathAnimation.animation_finished
	queue_free()

func adjust_emission_texture(animation_name):
	$Body/Sprite2D.material.set_shader_parameter("emission_texture",  EMISSION_TEXTURES[animation_name])


