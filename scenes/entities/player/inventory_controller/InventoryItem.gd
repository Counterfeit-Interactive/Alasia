class_name InventoryItem

var item:Item
const LIMIT = 64
var amount:int = 0
var slot_number:int

# Create unique id to facilitate the identification of the item
# Useful for new ordering, consume item, dropping item..
var unique_id:int = -1

func _init(_item:Item, _amount:int) -> void:
	item = _item
	amount = _amount
	
func set_id(id:int):
	unique_id = id

func add_amount(_amount:int) -> bool:
	if amount + _amount <= LIMIT:
		amount += _amount
		return true
	return false
