extends Control

@onready var nickname: Label = $Control/VBoxContainer/Nickname
@onready var health_points: Label = $Control/VBoxContainer/Health/HealthPoints
@onready var health_bar: ProgressBar = $Control/VBoxContainer/Health/HealthBar
@onready var online_players: Label = $Control/VBoxContainer/OnlinePlayers
@onready var unique_id: Label = $Control/VBoxContainer/ID

func _process(_float):
	var local_player:Player = Game.players.get_local()
	if local_player:
		var health = local_player.entity.get_health()
		var max_health = local_player.entity.get_max_health()
		
		health_points.text = str(local_player.entity.get_health())
		health_bar.value = (health / float(max_health)) * 100
		nickname.text = local_player.nickname + "server : " + str(multiplayer.is_server())
		unique_id.text = str(local_player.entity.get_name() )
	
	$Control/VBoxContainer/OnlinePlayers.text = "Online Players: " + str(len(Game.players.get_all()))
	
	for child in $Control/VBoxContainer/PlayersList.get_children():
		child.queue_free()

	for entity in Game.entities.get_all():
		var label = Label.new()
		if entity.is_player():
			label.text = str(entity.get_id()) + " " + entity.get_name() +  " " + str(entity.get_property("authority")) + " " + str(entity.get_health())
			$Control/VBoxContainer/PlayersList.add_child(label)
