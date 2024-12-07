extends Area2D

signal hit_by_player

func _ready():
	set_physics_process(false)

# Detect collisions with the player's attack area
func _on_Area2D_body_entered(body: Node) -> void:
	print("Body entered: ", body.name)  # Debug collision detection

	if body.is_in_group("player"):
		emit_signal("hit_by_player")
