extends Node2D

signal score_changed

var score = 0 : set = set_score
@export var is_open: bool = false  # Door's state
@export var next_level_scene: PackedScene  # Assign next level scene in the inspector

@onready var animation_player = $King/AnimatedSprite2D
@onready var is_near_door = false  # Track if player is near the door

func _ready():
	score = 0
	$King.reset($SpawnPoint.position)
	set_camera_limits()

func set_camera_limits():
	if not $King:
		print("King node is null!")
		return
	
	var camera = $King.get_node_or_null("Camera2D")
	if not camera:
		print("Camera2D node is null!")
		return

	var map_size = $TileMapLayer.get_used_rect()
	var cell_size = $TileMapLayer.tile_set.tile_size
	camera.limit_left = (map_size.position.x - 5) * cell_size.x
	camera.limit_right = (map_size.end.x + 5) * cell_size.x

func set_score(value):
	score = value
	score_changed.emit(score)

func _on_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player entered door area")  # Debugging
		is_near_door = true
		$Door/AnimatedSprite2D.animation = "open"
		await $Door/AnimatedSprite2D.animation_finished
		get_tree().change_scene_to_packed(next_level_scene)
