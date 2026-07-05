extends Control
class_name InventoryController
# TODO: Sync inventory
const MAX_INVENTORY = 42
const MAX_QUICK_ACCESS = 4

signal connect_consumable(consumable: Item)
signal drop_item(slot: InventorySlot, quantity: int)

var inventory_slot: PackedScene = load("res://scenes/entities/player/inventory_controller/inventory_slot/inventory_slot.tscn")
@onready var inventory_grid: GridContainer = $Inventory/MarginContainer/GridContainer
@onready var quick_acess_grid: GridContainer = $QuickAccess/MarginContainer/GridContainer
@onready var inventory: Panel = $Inventory
@onready var item_details: Panel = $ItemDetails

func _ready() -> void:
	inventory.visible = false
	item_details.visible = false
	
	_init_slots(inventory_grid, MAX_INVENTORY)
	_init_slots(quick_acess_grid, MAX_QUICK_ACCESS)

func _init_slots(container: GridContainer, nb_slots: int) -> void:
	for i in nb_slots:
		var slot: InventorySlot = inventory_slot.instantiate()
		slot.split_item.connect(split_item)
		slot.drop_item.connect(func(dropped_slot: InventorySlot): drop_item.emit(dropped_slot, 1))
		slot.display_details.connect(display_details)
		slot.hide_details.connect(func(): item_details.visible = false)
		container.add_child(slot)
	

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return

	for i in MAX_QUICK_ACCESS:
		if Input.is_action_just_pressed("quick_access_" + str(i+1)):
			var slot: InventorySlot = quick_acess_grid.get_child(i)
			if slot.item and slot.item is Consumable:
				slot.item.consume()
			return

func add_item(new_item: Item) -> bool:
	var item_slot = _get_item_slot(new_item)
	if item_slot:
		item_slot.quantity += 1
		return true

	var available_slot = _get_first_available_slot()
	if not available_slot:
		return false
	
	# Duplicating because new_item is freed so it doesn't appear on the map
	available_slot.item = new_item.duplicate()
	if available_slot.item is Consumable:
		connect_consumable.emit(available_slot.item)
	return true

func split_item(slot: InventorySlot):
	if not slot.item or slot.quantity < 2:
		return

	var available_slot = _get_first_available_slot()
	if not available_slot:
		return

	@warning_ignore("integer_division")
	var quantity1 = slot.quantity / 2
	@warning_ignore("integer_division")
	var quantity2 = slot.quantity - quantity1
	
	# If odd number, quantity2 is the higher number
	slot.quantity = quantity2

	available_slot.item = slot.item.duplicate()
	available_slot.quantity = quantity1
	if available_slot.item is Consumable:
		connect_consumable.emit(available_slot.item)

func _get_item_slot(item: Item) -> InventorySlot:
	for slot in inventory_grid.get_children():
		if slot.item and slot.item.item_name == item.item_name:
			return slot
	return

func _get_first_available_slot() -> InventorySlot:
	for slot in inventory_grid.get_children():
		if not slot.item:
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
	panel.get_node("Icon").texture = load(slot.item.icon_path)
	panel.get_node("Name").text = slot.item.item_name
	panel.get_node("Description").text = slot.item.description
	panel.get_node("Quantity").text = "Quantity: " + str(slot.quantity)
