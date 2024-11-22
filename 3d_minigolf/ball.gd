extends RigidBody3D

signal ball_stopped

func shoot(angle, power):
	var force = Vector3.FORWARD.rotated(Vector3.UP, angle)
	apply_central_impulse(force * power)
	
func _integrate_forces(state):
	# Check if the ball is nearly stopped
	if linear_velocity.length() < 0.1 and not is_sleeping():
		set_sleeping(true)  # Ensure the ball is stopped completely
		emit_signal("ball_stopped")  # Notify the main script
	# Ball fell off course!
	if position.y < -20:
		get_tree().reload_current_scene()
