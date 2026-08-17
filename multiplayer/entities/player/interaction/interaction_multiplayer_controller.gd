extends Node
class_name InteractionMultiplayerController

@rpc("any_peer", "call_local")
func interact():
	var player:Player = Game.players.get_remote_player(multiplayer)
	var target = player.interaction_controller.get_nearest_interaction()
	
	player.set_can_move(false)
	#target.interact(player)
	player.interaction_controller.interact_with(target)
	print(player.get_can_move())
