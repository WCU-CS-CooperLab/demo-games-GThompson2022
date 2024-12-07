extends Node

@export var music : AudioStream  # This will be assigned in the inspector
@onready var audio_player = $AudioStreamPlayer  # Reference the AudioStreamPlayer node

func _ready():
	if not audio_player.playing:
		audio_player.stream = music  # Set the background music to play
		audio_player.play()  # Start the music
