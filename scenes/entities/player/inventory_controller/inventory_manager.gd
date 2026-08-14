extends Node
class_name InventoryManager

signal item_added
signal item_removed
signal inventory_updated

var player:Player

var inventory:Dictionary[int, InventoryItem] = {}

func update_inventory():
	if Game.is_server():
		var serialized_inventory:Dictionary[int, Array] = {}
		for slot in range(len(inventory)):
			var inventory_item:InventoryItem = inventory[slot]
			if not inventory_item:
				serialized_inventory[slot] = []
			else:
				serialized_inventory[slot] = [inventory_item.unique_id, inventory_item.item.item_name, inventory_item.amount]
					
		player.entity.set_property("inventory", serialized_inventory)
	
func _init(_player:Player):
	player = _player
	for i in range(Game.constants.INVENTORY_SIZE):
		inventory[i] = null
			
	MultiplayerController.property_changed.connect(on_property_changed)

	
func add_item(item:Item, amount:int):
	var inventory_slot:int = get_next_available_slot(item, amount)
	if inventory_slot < 0:
		return

	var selected_slot = inventory[inventory_slot]

	if not selected_slot:
		var inventory_item = InventoryItem.new(item, amount)
		## This ID will be usefull when the client side will click on "Use" item to identify without any
		## confusion
		inventory_item.unique_id = Game.items.generate_new_id()
		inventory[inventory_slot] = inventory_item
	else:
		var inventory_item:InventoryItem = selected_slot
		inventory_item.add_amount(1)

	update_inventory()
	
func remove_item(slot:int):
	pass

## This method search available slot on the inventory [br]
## 
## It will check if there are existing slot with the provided item and check its limit [br][br]
##
## If it can't find the slot, it will return the first available slot [br]
## Finally if there aren't any available slot, the method will return -1
func get_next_available_slot(item:Item, amount:int) -> int:
	var item_existing_slot = null
	var first_slot = null
	for i in range(Game.constants.INVENTORY_SIZE):
		if inventory[i] == null:
			if first_slot:
				continue
			first_slot = i
			continue
		
		var inventory_item:InventoryItem = inventory[i]
		if inventory_item.amount + amount <= inventory_item.LIMIT:
			item_existing_slot = i
	
	if item_existing_slot:
		return item_existing_slot
	
	if first_slot:
		return first_slot
	
	return -1


func get_inventory_item_by_id(id:int) -> InventoryItem:
	for slot in range(len(inventory)):
		var inventory_item:InventoryItem = inventory[slot]
		if not inventory_item:
			return null
		else:
			return inventory_item
	return null
			
func get_by_unique_id(unique_id:int) -> InventoryItem:
	for slot in range(len(inventory)):
		var inventory_item:InventoryItem = inventory[slot]
		if not inventory_item:
			continue
		elif inventory_item.unique_id == unique_id:
			return inventory_item
			
	return null
	
func remove_by_unique_id(unique_id:int):
	for slot in range(len(inventory)):
		var inventory_item:InventoryItem = inventory[slot]
		if not inventory_item:
			continue
		elif inventory_item.unique_id == unique_id:
			inventory[slot] = null
			update_inventory()
			
## Emit event to update inventoru rendering only when its concerns the local player inventory
func on_property_changed(entity_id, property, value):
	var player = Game.entities.get_by_id(entity_id).object
	if player == Game.players.get_local() and property == "inventory":
		var is_server = Game.is_server()
		inventory_updated.emit()
