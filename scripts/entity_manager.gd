extends Node
class_name EntityManager

var entities:Dictionary[int, Entity] = {}
var current_id = 1
func _init() -> void:
	MultiplayerController.entity_take_damage.connect(_on_entity_take_damage)
	pass

func get_all():
	return entities.values()

func get_by_id(id:int) -> Entity:
	if entities.get(id):
		return entities[id]
	return null

func remove_entity(entity:Entity):
	entities.erase(entity.get_id())

func add_entity(entity:Entity):
	entities[entity.get_id()] = entity

func _on_entity_take_damage(entity_id:int, damage:int):
	print(Game.entities.get_by_id(entity_id).get_object(), " a prit ", damage)

func generate_id():
	var new_id = current_id
	current_id += 1
	return new_id
