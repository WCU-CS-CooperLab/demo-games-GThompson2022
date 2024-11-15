extends Area2D

var screensize = Vector2.ZERO

func pickup():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("goblin"):
		position = Vector2(randi_range(0, screensize.x),
			randi_range(0, screensize.y))
