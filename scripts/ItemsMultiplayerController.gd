extends Node
class_name ItemsMultiplayerController

@rpc("authority")
func spawn_item(name:String, position:Vector3):
	var item:Item = Game.items.get_by_name(name)
	item.spawn(position)
	
