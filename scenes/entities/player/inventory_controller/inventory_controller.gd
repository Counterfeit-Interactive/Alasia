extends Control
class_name InventoryController
const MAX_INVENTORY = 42
const MAX_QUICK_ACCESS = 4

signal connect_consumable(consumable: Item)
signal drop_item(slot: InventorySlot, quantity: int)

var inventory_slot: PackedScene = load("res://scenes/entities/player/inventory_controller/inventory_slot/inventory_slot.tscn")
@onready var inventory_grid: GridContainer = $Inventory/MarginContainer/GridContainer
@onready var quick_acess_grid: GridContainer = $QuickAccess/MarginContainer/GridContainer
@onready var inventory: Panel = $Inventory
@onready var item_details: Panel = $ItemDetails

var player:Player = null
var inventory_grid_container:GridContainer

func _ready() -> void:
	inventory.visible = false
	item_details.visible = false
	
	_init_slots(inventory_grid, MAX_INVENTORY)
	_init_slots(quick_acess_grid, MAX_QUICK_ACCESS)
	
	inventory_grid_container = inventory_grid
	
func set_player(_player:Player) -> void:
	player = _player

func _init_slots(_container: GridContainer, nb_slots: int) -> void:
	for i in nb_slots:
		var slot: InventorySlot = inventory_slot.instantiate()
		slot.slot_number = i
		slot.split_item.connect(split_item)
		slot.drop_item.connect(func(dropped_slot: InventorySlot): drop_item.emit(dropped_slot, 1))
		slot.display_details.connect(display_details)
		slot.hide_details.connect(func(): item_details.visible = false)
		slot.exchange_slot.connect(update_inventory_order)
		_container.add_child(slot)



func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return

	for i in MAX_QUICK_ACCESS:
		if Input.is_action_just_pressed("quick_access_" + str(i+1)):
			var slot: InventorySlot = quick_acess_grid.get_child(i)
			if slot.item and slot.item is Consumable:
				slot.item.consume()
			return

func add_item(inventory_item: InventoryItem) -> bool:
	var item_slot = _get_item_slot(inventory_item.item)
	if item_slot:
		item_slot.inventory_item.amount = inventory_item.amount
		item_slot.quantity = inventory_item.amount
		return true

	var available_slot = _get_first_available_slot()
	if not available_slot:
		return false
	
	available_slot.inventory_item = inventory_item
	return true
	
func remove_item(slot:int):
	var inventory_slot:InventorySlot = inventory_grid.get_child(slot)
	inventory_slot.inventory_item = null
	
func split_item(slot: InventorySlot):
	if not slot.inventory_item:
		return
	
	var item:Item = slot.inventory_item.item
	if not item or slot.quantity < 2:
		return

	var available_slot = _get_first_available_slot()
	if not available_slot:
		return

	# TODO send to server split value
	@warning_ignore("integer_division")
	var quantity1 = slot.quantity / 2
	@warning_ignore("integer_division")
	var quantity2 = slot.quantity - quantity1
	
	slot.quantity = quantity2

	available_slot.quantity = quantity1
	if available_slot.item is Consumable:
		connect_consumable.emit(available_slot.item)

func _get_item_slot(item: Item) -> InventorySlot:
	for slot in inventory_grid.get_children():
		if not slot.inventory_item:
			continue

		if slot.inventory_item.item.item_name == item.item_name:
			return slot
	return

func _get_first_available_slot() -> InventorySlot:
	for slot in inventory_grid.get_children():
		if not slot.inventory_item:
			return slot
	return

func _can_drop_data(_at_position:Vector2, _data:Variant) -> bool:
	return true

func _drop_data(_at_position:Vector2, data:Variant) -> void:
	if data is not InventorySlot or data.item == null:
		return
	drop_item.emit(data, data.quantity)

func display_details(slot: InventorySlot) -> void:
	item_details.visible = true
	var panel = item_details.get_node("MarginContainer/Panel")
	var item:Item = slot.inventory_item.item
	panel.get_node("Icon").texture = load(item.icon_path)
	panel.get_node("Name").text = item.item_name
	panel.get_node("Description").text = item.description
	panel.get_node("Quantity").text = "Quantity: " + str(slot.quantity)

func inventory_updated():
	var inventory_items = player.entity.get_property("inventory")
	if not inventory_items:
		return
	
	for slot in range(len(inventory_items)):
		if not len(inventory_items[slot]) > 0:
			remove_item(slot)
		else:
			var serialized_inventory_item:Array = inventory_items[slot]

			var unique_id = serialized_inventory_item[0]
			var item_name:String = serialized_inventory_item[1]
			var item_amount = serialized_inventory_item[2]
			var item:Item = Game.items.get_by_name(item_name)
			if not item:
				var message = "Canno't found item " + item_name + " on the regisred items"
				assert(item, message)
				continue
			
			var inventory_item:InventoryItem = InventoryItem.new(item, item_amount)
			inventory_item.unique_id = unique_id
			add_item(inventory_item)


func update_inventory_order(slot_origin,slot_target):
	var new_order:Dictionary[int, int] = {}
	for slot in range(Game.constants.INVENTORY_SIZE):
		new_order[slot] = -1

	for slot in inventory_grid_container.get_children():
		var inventory_slot:InventorySlot = slot
		if inventory_slot.inventory_item:
			new_order[inventory_slot.slot_number] = inventory_slot.inventory_item.unique_id

	MultiplayerController.inventory_multiplayer_controller.update_inventory_order.rpc_id(1,new_order)
