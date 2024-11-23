extends Node2D

signal score_changed

var score = 0 : set = set_score

var item_scene = load("res://items/item.tscn")
var door_scene = load("res://items/door.tscn")
@export var is_open: bool = false  # Door's state
@onready var animation_player = $AnimationPlayer



func _ready():
	score = 0
	#$Items.hide()
	$King.reset($SpawnPoint.position)
	set_camera_limits()
	spawn_items()
	
func set_camera_limits():
	var map_size = $TileMapLayer.get_used_rect()
	var cell_size = $TileMapLayer.tile_set.tile_size
	$King/Camera2d.limit_left = (map_size.position.x - 5) * cell_size.x
	$King/Camera2d.limit_right = (map_size.end.x + 5) * cell_size.x

func spawn_items():
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		if type == "door":
			var door = door_scene.instantiate()
			add_child(door)
			door.position = $Items.map_to_local(cell)
			door.body_entered.connect(_on_door_entered)
		else:
			var item = item_scene.instantiate()
			add_child(item)
			item.init(type, $Items.map_to_local(cell))
			item.picked_up.connect(self._on_item_picked_up)


func _on_item_picked_up():
	score += 1
	$PickupSound.play()

func set_score(value):
	score = value
	score_changed.emit(score)

func _on_door_entered(body):
	GameState.next_level()
	
func _on_player_died():
	GameState.restart()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):  # Check if the interacting body is a player
		toggle_door()

func toggle_door():
	if is_open:
		animation_player.play("Close")
		is_open = false
	else:
		animation_player.play("Open")
		is_open = true
