extends Consumable

const HEALTH_POINTS = 20

func _init() -> void:
	super("Potion", "res://assets/items/potion.png",
	"Heal " + str(HEALTH_POINTS) + " HP")

	self.set_model(preload("res://scenes/entities/items/consumables/potion/model.tscn"))

func consume_callable(player: Player):
	if Game.is_server():
		if player.entity.get_health() < player.max_health:
			if player.entity.get_health() + HEALTH_POINTS > player.max_health:
				player.entity.set_health(player.max_health)
			else:
				player.entity.set_health(player.entity.get_health() + HEALTH_POINTS)
			consumed()

func on_body_entered(body, object:ItemModel):
	var item:Item = object.attached_item
	body.loot(item, object.amount)

	# Delete entity
	object.queue_free()
