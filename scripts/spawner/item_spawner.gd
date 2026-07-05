extends MultiplayerSpawner

var rng = RandomNumberGenerator.new()
var auto_spawner_timer:Timer
func _ready() -> void:
	MultiplayerController.item_dropped.connect(drop_item)
	spawn_potion.call_deferred()
	
	auto_spawner_timer = Timer.new()
	auto_spawner_timer.wait_time = 2
	auto_spawner_timer.one_shot = false
	
	auto_spawner_timer.timeout.connect(spawn_potion)
	auto_spawner_timer.autostart = true
	
	add_child(auto_spawner_timer)

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
	var rng = RandomNumberGenerator.new()
	for i in 3:
		var potion:Item = Game.items.get_by_name("Potion")
		var position:Vector3 = Vector3(10 + rng.randf_range(-3, 3), 2, rng. randf_range(-3, 3))
		var entity = potion.spawn(position)
		

func drop_item(item: Item, quantity: int) -> void:
	for i in quantity:
		spawn_item(item.duplicate())
