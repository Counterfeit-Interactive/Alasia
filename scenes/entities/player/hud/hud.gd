extends Control

@onready var nickname: Label = $VBoxContainer/Nickname
@onready var health_points: Label = $VBoxContainer/Health/HealthPoints
@onready var health_bar: ColorRect = $VBoxContainer/Health/HealthBar
@onready var online_players: Label = $VBoxContainer/OnlinePlayers
@onready var unique_id: Label = $VBoxContainer/ID

func _process(_float):
	var local_player:Player = Game.players.get_local()
	if local_player:
		health_points.text = str(local_player.entity.getProperty("health"))
		health_bar.custom_minimum_size.x = local_player.entity.getProperty("health") * health_bar.custom_minimum_size.y
		nickname.text = local_player.nickname + "server : " + str(multiplayer.is_server())
		unique_id.text = str(local_player.entity.get_name() )
	
	$VBoxContainer/OnlinePlayers.text = "Online Players: " + str(len(Game.players.get_all()))
	
	for child in $VBoxContainer/PlayersList.get_children():
		child.queue_free()

	for entity in Game.entities.get_all():
		var label = Label.new()
		if entity.is_player():
			label.text = str(entity.get_id()) + " " + entity.get_name() +  " " + str(entity.getProperty("authority"))
			$VBoxContainer/PlayersList.add_child(label)
