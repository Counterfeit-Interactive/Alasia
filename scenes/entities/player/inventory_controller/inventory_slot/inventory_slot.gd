extends MenuButton
class_name InventorySlot

@onready var icon_rect: TextureRect = $TextureRect
@onready var label: Label = $TextureRect/Label

var slot_number:int = -1

signal split_item(slot: InventorySlot)
signal drop_item(slot: InventorySlot)
signal display_details(slot: InventorySlot)
signal hide_details()

signal exchange_slot(slot_origin:int, slot_target:int)

var inventory_item: InventoryItem:
	set = _set_inventory_item

var quantity: int = 0:
	set = _set_quantity
	
func _set_inventory_item(new_inventory_item: InventoryItem) -> void:
	inventory_item = new_inventory_item
	if not inventory_item:
		icon_rect.texture = null
		label.text = ""
		return
		

	quantity = new_inventory_item.amount
	icon_rect.texture = load(inventory_item.item.icon_path)
	if inventory_item.item is Consumable:
		inventory_item.item.item_consumed.connect(func(): quantity -= 1)
	_load_popup()

func _load_popup() -> void:
	var popup = get_popup()
	popup.clear()
	if inventory_item.item is Consumable:
		popup.add_item("Use", 1)
		popup.add_separator()
	popup.add_item("Drop", 3)

func _set_quantity(new_quantity: int) -> void:
	if inventory_item.amount > 0:
		label.text = str(new_quantity)
		_handle_split_option(new_quantity)
	else:
		if inventory_item:
			inventory_item = null

func _handle_split_option(new_quantity: int) -> void:
	var popup = get_popup()
	var index = popup.get_item_index(2)
	if new_quantity > 1 and index < 0:
		popup.add_item("Split", 2)
		popup.set_item_index(popup.get_item_index(2), popup.get_item_index(3))
	elif new_quantity <= 1 and index >= 0:
		popup.remove_item(index)

func _ready() -> void:
	var popup = get_popup()
	popup.id_pressed.connect(_on_action_pressed)

func _on_action_pressed(id: int) -> void:
	match id:
		1: # Use
			#inventory_item.item.consume()
			MultiplayerController.inventory_multiplayer_controller.use_item.rpc(1, inventory_item.unique_id)
		2: # Split
			split_item.emit(self)
		3: # Drop
			drop_item.emit(self)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if inventory_item and inventory_item.item is Consumable:
					MultiplayerController.inventory_multiplayer_controller.use_item.rpc_id(1, inventory_item.unique_id)
			MOUSE_BUTTON_MIDDLE:
				split_item.emit(self)
			MOUSE_BUTTON_RIGHT:
				if inventory_item:
					show_popup()

func _get_drag_data(_at_position:Vector2) -> Variant:
	if inventory_item and inventory_item.item:
		var preview = icon_rect.duplicate()
		preview.top_level = true
		preview.z_as_relative = false
		preview.z_index = 99
		set_drag_preview(preview)
	return self

func _can_drop_data(_at_position:Vector2, _data:Variant) -> bool:
	return true

func _drop_data(_at_position:Vector2, data:Variant) -> void:
	# This should be in _can_drop_data but when
	# _can_drop_data is false there's a ugly stop sign
	if data == self or data.inventory_item == null:
		return

	if inventory_item and inventory_item.item.item_name == data.inventory_item.item.item_name:
		merge_slot(data)
	else:
		_exchange_slot(data)

## TODO: Implement
func merge_slot(slot: InventorySlot) -> void:
	pass

func _exchange_slot(slot: InventorySlot) -> void:
	inventory_item = slot.inventory_item
	slot.inventory_item = null
	
	exchange_slot.emit(slot.slot_number, slot_number)
	

func _on_mouse_entered() -> void:
	if not inventory_item: return
	display_details.emit(self)


func _on_mouse_exited() -> void:
	hide_details.emit()
