@abstract
class_name Item

var item_name: String
var icon_path: String
var description: String

@export var model:PackedScene = null

func _init(new_item_name: String, new_icon_path: String, new_description: String) -> void:
	item_name = new_item_name
	icon_path = new_icon_path
	description = new_description
	
	Game.items.register_item(self)

func set_model(_model):
	model = _model
	Game.items_spawner.add_spawnable_scene(model.resource_path)

func get_model():
	return model

func on_body_entered(body, root):
	pass

func spawn(position:Vector3):
	if Game.is_server():
		MultiplayerController.items_multiplayer_controller.spawn_item.rpc(item_name,position)

	if model:
		var entity:ItemModel = model.instantiate()
		entity.position = position
		entity.entity_entered.connect(on_body_entered)
		entity.attached_item = self
		Game.get_tree().get_first_node_in_group("ItemsContainer").add_child(entity, true)
	
		return entity
