extends Control

@onready var nickname: Label = $VBoxContainer/Nickname
@onready var health_points: Label = $VBoxContainer/Health/HealthPoints
@onready var health_bar: ColorRect = $VBoxContainer/Health/HealthBar
@onready var online_players: Label = $VBoxContainer/OnlinePlayers

func _process(_float):
	var local_player:Player = Game.players.get_local()
	
	if local_player:
		health_points.text = str(local_player.health)
		health_bar.custom_minimum_size.x = local_player.health * health_bar.custom_minimum_size.y
		nickname.text = local_player.nickname
	
	$VBoxContainer/OnlinePlayers.text = "Online Players: " + str(len(Game.players.get_all()))
