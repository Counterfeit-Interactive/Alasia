@abstract
class_name Consumable
extends Item

signal consume_item(callable: Callable)
signal item_consumed

@abstract func consume_callable(player: Player)

func consume():
	consume_item.emit(consume_callable)

func consumed():
	item_consumed.emit()
