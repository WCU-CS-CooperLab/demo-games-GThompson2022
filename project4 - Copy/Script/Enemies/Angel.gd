extends CharacterBody2D

# We store angel's attack scene into a variable.
@export var angel_attack_scene: PackedScene

# Define damage and life
var contact_damage = 1

var life = 1

# Trigger when collides with player, call the damage function at the player and pass the damage direction for knockback be applied
func _on_CollideWithPlayer_body_entered(body):
	var damage_direction = -1 if body.global_position.x < self.global_position.x else 1
	body.damage(contact_damage, damage_direction, self)

# Receive damage and control life
func damage(quantity, _damage_dealer):
	life -= quantity
	if life <= 0:
		die()

# Get away of trouble nodes that could cause weird behavior and then apply the death animation.	
func die():
	$CollisionShape2D.queue_free()
	$CollideWithPlayer/CollisionShape2D.queue_free()
	$AttackTimer.queue_free()
	$Body/Sprite2D.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	await $Body/DeathAnimation.animation_finished
	queue_free()

# Triggered by a timer, put the angel's attack
func _on_AttackTimer_timeout():
	$Body/Sprite2D.play("attack")
	var attack = angel_attack_scene.instantiate()
	attack.global_position = self.global_position
	get_parent().add_child(attack)

# When we finish the attack animation we return to idle.
func _on_Sprite_animation_finished():
	if $Body/Sprite2D.animation == 'attack':
		$Body/Sprite2D.play("idle")
