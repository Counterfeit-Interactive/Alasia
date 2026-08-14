extends Node
class_name ItemManager

var available_items:Dictionary[String, Item] = {}
var loaded_items:Dictionary[String, Script] = {}
var current_id:int = 0

func _load_path(dir_path:String):	
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.ends_with(".gd") and file_name not in ["item.gd", "consumable.gd"]:
					var full_path = dir_path.path_join(file_name)
					if loaded_items.get(full_path) != null:
						continue
					
					var script = load(full_path)
					script.new()
					loaded_items[full_path] = script
			else:
				_load_path(dir_path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()


func load_items():
	var path:String = "res://scenes/entities/items/"
	_load_path(path)

func register_item(item:Item):
	if not item.item_name in available_items:
		available_items[item.item_name] = item
		print("Registered ", item.item_name)
		
func generate_new_id() -> int:
	current_id += 1
	return current_id

func get_by_name(name:String) -> Item:
	assert(name in available_items, "Item " + name + " not registered")
	return available_items[name] 
