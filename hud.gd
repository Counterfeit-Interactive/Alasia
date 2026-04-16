extends Control

func _ready():
	MultiplayerController.player_is_ready.connect(setup)

func setup(player_info):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Nickname.text = player_info["name"]
