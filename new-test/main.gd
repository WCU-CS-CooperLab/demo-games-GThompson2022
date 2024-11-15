extends Node

@export var coin_scene : PackedScene
@export var powerup_scene : PackedScene
@export var enemy_scene : PackedScene
@export var goblin_scene : PackedScene
@export var playtime = 30

var level = 1
var time_left = 0
var screensize = Vector2.ZERO
var playing = false

var ScorePlayer1 = 0
var ScorePlayer2 = 0
var player1_alive = true
var player2_alive = true

func _ready():
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player2.screensize = screensize
	$Player.hide()
	$Player2.hide()

func new_game():
	playing = true
	level = 1
	ScorePlayer1 = 0
	ScorePlayer2 = 0
	time_left = playtime
	player1_alive = true
	player2_alive = true
	$Player.start()
	$Player2.start()
	$Player.show()
	$Player2.show()
	$GameTimer.start()
	spawn_coins()
	spawn_enemy()
	spawn_goblin()
	update_scores()
	$HUD.update_timer(time_left)
	$LevelSound.play()

func spawn_coins():
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screensize = screensize
		c.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))

func spawn_powerups():
	for i in level + 1:
		var p = powerup_scene.instantiate()
		add_child(p)
		p.screensize = screensize
		p.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))

func spawn_enemy():
	for i in level + 4:
		var e = enemy_scene.instantiate()
		add_child(e)
		e.screensize = screensize
		e.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))

func spawn_goblin():
	for i in level + 4:
		var g = goblin_scene.instantiate()
		add_child(g)
		g.screensize = screensize
		g.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))



func update_scores():
	$HUD.update_score_player1(ScorePlayer1)
	$HUD.update_score_player2(ScorePlayer2)

func _process(delta):
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()
		get_tree().call_group("goblin", "queue_free")
		get_tree().call_group("enemy", "queue_free")
		get_tree().call_group("powerups", "queue_free")
		spawn_goblin()
		spawn_enemy()
		spawn_powerups()

func _on_game_timer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_player_hurt():
	player1_alive = false
	check_game_over()


func _on_player_pickup(type):
	match type:
		"coin":
			$CoinSound.play()
			ScorePlayer1 += 1
		"powerup":
			$Powerup.play()
			time_left += 5
	update_scores()

func _on_player_2_pickup(type):
	match type:
		"coin":
			$CoinSound.play()
			ScorePlayer2 += 1
		"powerup":
			$Powerup.play()
			time_left += 5
	update_scores()

func _on_player_2_hurt():
	player2_alive = false
	check_game_over()


func check_game_over():
	if not player1_alive and not player2_alive:
		game_over()

func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	get_tree().call_group("powerups", "queue_free")
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("goblin", "queue_free")

	$HUD.show_game_over()
	$Player.die()
	$Player2.die()
	$EndSound.play()

# Check the scores and display the winner
	if ScorePlayer1 > ScorePlayer2:
		$HUD.show_message("Player 1 Wins!")
	elif ScorePlayer2 > ScorePlayer1:
		$HUD.show_message("Player 2 Wins!")
	else:
		$HUD.show_message("It's a Tie!")

	
func _on_hud_start_game():
	new_game()

func _on_powerup_timer_timeout():
	var p = powerup_scene.instantiate()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(randi_range(0, screensize.x), randi_range(0, screensize.y))
