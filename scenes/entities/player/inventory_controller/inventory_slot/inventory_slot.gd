extends MenuButton
class_name InventorySlot

@onready var icon_rect: TextureRect = $TextureRect
@onready var label: Label = $TextureRect/Label

signal split_item(slot: InventorySlot)
signal drop_item(slot: InventorySlot)
signal display_details(slot: InventorySlot)
signal hide_details()

var item: Item:
	set = _set_item

var quantity: int = 0:
	set = _set_quantity

func _set_item(new_item: Item) -> void:
	item = new_item
	if not item:
		return

	quantity = 1
	icon_rect.texture = load(item.icon_path)
	if item is Consumable:
		item.item_consumed.connect(func(): quantity -= 1)
	_load_popup()

func _load_popup() -> void:
	var popup = get_popup()
	popup.clear()
	if item is Consumable:
		popup.add_item("Use", 1)
		popup.add_separator()
	popup.add_item("Drop", 3)

func _set_quantity(new_quantity: int) -> void:
	quantity = new_quantity
	if quantity > 0:
		label.text = str(quantity)
		_handle_split_option(quantity)
	else:
		icon_rect.texture = null
		label.text = ""
		if item:
			item.queue_free()
			item = null

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
			item.consume()
		2: # Split
			split_item.emit(self)
		3: # Drop
			drop_item.emit(self)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if item is Consumable:
					item.consume()
			MOUSE_BUTTON_MIDDLE:
				split_item.emit(self)
			MOUSE_BUTTON_RIGHT:
				if item:
					show_popup()

func _get_drag_data(_at_position:Vector2) -> Variant:
	if item:
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
	if data == self or data.item == null:
		return

	if item and item.item_name == data.item.item_name:
		merge_slot(data)
	else:
		exchange_slot(data)

func merge_slot(slot: InventorySlot) -> void:
	quantity += slot.quantity
	slot.quantity = 0

func exchange_slot(slot: InventorySlot) -> void:
	var slot_item = slot.item
	var slot_quantity = slot.quantity

	slot.item = item
	slot.quantity = quantity

	item = slot_item
	quantity = slot_quantity


func _on_mouse_entered() -> void:
	if not item: return
	display_details.emit(self)


func _on_mouse_exited() -> void:
	hide_details.emit()
