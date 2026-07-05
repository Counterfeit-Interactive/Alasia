extends MultiplayerSpawner

@export var potion: PackedScene
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	MultiplayerController.item_dropped.connect(drop_item)
	spawn_potion.call_deferred()

func spawn_item(item: Item) -> void:
	if !multiplayer.is_server(): return
	# Slightly randomize position so if two item same in
	# the same positions, they are not perfectly aligned
	item.position.y += rng.randf_range(-0.1, 0.1)
	item.position.z += rng.randf_range(-0.1, 0.1)
	item.position.x += rng.randf_range(-0.1, 0.1)
	get_node(spawn_path).call_deferred("add_child", item, true)

func spawn_potion() -> void:
	if !multiplayer.is_server(): return
	for i in 10:
		var new_potion = potion.instantiate()
		new_potion.position.y = 5
		new_potion.position.z = -5
		spawn_item(new_potion)

func drop_item(item: Item, quantity: int) -> void:
	for i in quantity:
		spawn_item(item.duplicate())
