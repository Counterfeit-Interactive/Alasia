extends Control




func _process(_float):
	var local_player:Player = Game.players.get_local()
	
	if local_player:
		$VBoxContainer/HP.text = str(local_player.health)
		$VBoxContainer/Nickname.text = local_player.nickname
	
	$VBoxContainer/OnlinePlayers.text = "Online Players" + str(len(Game.players.get_all()))
