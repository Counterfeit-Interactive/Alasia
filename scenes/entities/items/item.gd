@abstract
class_name Item
extends Node3D

var item_name: String
var icon_path: String
var description: String

func _init(new_item_name: String, new_icon_path: String, new_description: String) -> void:
	item_name = new_item_name
	icon_path = new_icon_path
	description = new_description

func _on_area_3d_body_entered(player: Player) -> void:
	if (player.loot(self)):
		MultiplayerController.remove_item.rpc(get_path())
