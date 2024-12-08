extends CharacterBody2D

@export var fireball_scene: PackedScene

var contact_damage = 1
var life = 1

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
	$AttackTimer.queue_free()
	$Body/Sprite2D.hide()
	$Body/DeathAnimation.show()
	$Body/DeathAnimation.play("death")
	await $Body/DeathAnimation.animation_finished
	queue_free()


func _on_AttackTimer_timeout():
	$Body/Sprite2D.play("attack")

func _on_Sprite_animation_finished():
	if $Body/Sprite2D.animation == 'attack':
		$Body/Sprite2D.play("idle")


func _on_Sprite_frame_changed():
	if $Body/Sprite2D.animation == 'attack':
		if $Body/Sprite2D.frame == 3 and $Body/Sprite2D.visible:
			var attack = fireball_scene.instantiate()
			attack.global_position = $Body/FireballPos.global_position
			if self.scale.x == -1:
				attack.direction = Vector2.RIGHT
				attack.scale.x = self.scale.x
			get_parent().add_child(attack)
