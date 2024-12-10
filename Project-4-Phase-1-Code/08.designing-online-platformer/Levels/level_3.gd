extends Node2D

@onready var checkpoint = $CheckPoint
@onready var finish_line = $FinishLine

var checkpoint_reached = false  # Tracks whether the checkpoint has been reached

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finish_line.visible = false  # Hide the finish line initially

# Called when a player enters the checkpoint area.
func _on_check_point_body_entered(body: Node2D) -> void:
	# Check if the body is a player or has a specific property/tag (e.g., is in the "players" group)
	if body.is_in_group("players"):  # Ensure your player nodes are in the "players" group
		print("Checkpoint reached!")
		checkpoint_reached = true
		finish_line.visible = true  # Show the finish line

# Called when a player enters the finish line area.
func _on_finish_line_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):  # Ensure it's the player who crosses the finish line
		print("Finish line crossed!")
		get_tree().change_scene("res://08.designing-online-platformer/Levels/Level.tscn")  # Replace with the actual path to level2
