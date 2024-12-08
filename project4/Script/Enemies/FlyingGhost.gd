extends CharacterBody2D


var contact_damage = 1

var life = 1
@onready var speed = 3 * GlobalValues.CELL_SIZE

var player = null

func _physics_process(_delta):
	if player:
		$Body.scale.x = 1 if player.global_position < self.global_position else -1		
		if self.global_position.distance_to(player.global_position) > 10:
			set_velocity((player.global_position - self.global_position).normalized() * speed)
			set_up_direction(Vector2.UP)
			move_and_slide()
			var _movement = velocity
			

func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)

func damage(quantity, _damage_dealer):
	life -= quantity
	if life <= 0:
		die()

func die():
	set_physics_process(false)
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$Body/Sprite2D.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	await $Body/DeathAnimation.animation_finished
	queue_free()
	
func _on_TriggerArea_body_entered(body):
	player = body

