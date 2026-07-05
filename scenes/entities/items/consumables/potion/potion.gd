extends Consumable

const HEALTH_POINTS = 5

func _init() -> void:
	super("Potion", "res://assets/items/potion.png",
	"Heal " + str(HEALTH_POINTS) + " HP")

func consume_callable(player: Player):
	if player.health < player.max_health:
		player.health += HEALTH_POINTS # TODO: sync health
		consumed()
