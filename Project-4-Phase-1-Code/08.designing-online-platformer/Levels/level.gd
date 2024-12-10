extends Node2D

@onready var checkpoint = $CheckPoint
@onready var finish_line = $FinishLine
@onready var barrier = $Barrier  # Reference to the barrier area

# Load the scene as a PackedScene
var arena_screen_scene = preload("res://08.designing-online-platformer/Levels/Level2.tscn")

var checkpoint_reached = false  # Tracks whether the checkpoint has been reached

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finish_line.visible = false  # Hide the finish line initially

# Called when a player enters the checkpoint area.
func _on_check_point_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		print("Checkpoint reached!")
		checkpoint_reached = true
		finish_line.visible = true  # Show the finish line
		barrier.queue_free()  # Remove the barrier from the scene

# Called when a player enters the finish line area.
func _on_finish_line_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if checkpoint_reached:
			print("Finish line crossed!")
			# Reset the current scene
			get_tree().reload_current_scene()
		else:
			print("Finish line not active yet. Reach the checkpoint first!")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		$AnimationPlayer.play("bridge")
	else:
		print("Animation 'bridge' not found in AnimationPlayer!")
