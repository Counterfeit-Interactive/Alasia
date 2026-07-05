extends Node
class_name InventoryMultiplayerController

## Called from client and executed on server
##
## It will retrieve the item on the player inventory based on the [param unique_id][br]
##
## Next step is to spawn the item on the world[br]
## Finally remove the item from the player inventory
@rpc("any_peer", "call_local")
func drop_item(unique_id:int):
	if not Game.is_server():
		assert("Attempting to call drop_item on client side")
		return
	
	var player:Player = Game.players.get_remote_player(multiplayer)
	var inventory_manager = player.inventory_manager
	var item = inventory_manager.get_by_unique_id(unique_id)
	
	if item:
		var item_position = Vector3(player.position.x + 5, 3, player.position.z)
		var item_model:ItemModel = item.item.spawn(item_position)
		item_model.amount = item.amount
		inventory_manager.remove_by_unique_id(unique_id)
	else:
		assert(item, "The player " + str(player.multiplayer.get_unique_id()) + " hasn't item" + str(unique_id))

@rpc("authority")
func loot_item(player_id:int, item_name:String):
	return true

## Called from client side when they click on "Use" or double click on the inventory item
@rpc("any_peer", "call_local")
func use_item(inventory_slot_id:int):
	if not Game.is_server():
		return
	

	var player_id = multiplayer.get_remote_sender_id()
	var player = Game.players.get_by_id(player_id)
	var inventory_item:InventoryItem = player.inventory_manager.get_inventory_item_by_id(inventory_slot_id)
	
	if inventory_item:
		inventory_item.item.consume_callable(player)
		inventory_item.amount -= 1
		
		# TODO partial update to only update the consumed item
		player.inventory_manager.update_inventory()

## Called from client side to update the inventory disposition [br]
## It also check if the client doesn't try to inject new items
@rpc("any_peer", "call_local")
func update_inventory_order(client_inventory_order:Dictionary[int,int]):
	if not Game.is_server():
		return
	var player:Player = Game.players.get_remote_player(multiplayer)
	var inventory = player.inventory_manager.inventory
	
	var items_by_item_id:Dictionary[int, InventoryItem] = {}
	var verified_ids:Dictionary[int, bool] = {}

	
	for slot in range(len(inventory)):
		var item = inventory[slot]
		if item:
			items_by_item_id[item.unique_id] = item
			verified_ids[item.unique_id] = false
	
	
	for slot in range(len(client_inventory_order)):
		var item = client_inventory_order[slot]
		# -1 means no item
		if item == -1:
			continue
		
		verified_ids[item] = true
	
	# Check if both contains the same ids
	var is_valid:bool = not verified_ids.values().has(false)
	assert(is_valid, "Inventory stored on the client side mistaching with the server side")
	
	# Update inventory order
	var new_inventory_order:Dictionary[int, InventoryItem] = {}

	for slot in range(Game.constants.INVENTORY_SIZE):
		var item_id = client_inventory_order[slot]
		if item_id < 0:
			new_inventory_order[slot] = null
			continue
		
		var item = items_by_item_id[item_id]
		new_inventory_order[slot] = item
	# Verify if client current inventory match with the server inventory
	
	player.inventory_manager.inventory = inventory
	player.inventory_manager.update_inventory()
	
	
